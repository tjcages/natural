//
//  ListItem.swift
//  natural
//
//  Created by Tyler Cagle on 1/2/22.
//

import Foundation
import SwiftUI
import FavIcon

struct ListItem: View {
    @Environment(\.openURL) var openURL
    
    var index: Int
    var item: Links
    @Binding var selectKeeper: Int?
    
    @State var isPopover = false
    @State var image: NSImage?
    
    func getFavicon(_ link: URL) {
        do {
            try FavIcon.downloadPreferred(link, width: 24, height: 24) { result in
                if case let .success(image) = result {
                    self.image = image
                }
            }
        } catch {
            print("ERROR: Couldn't get Favicon")
        }
    }
    
    var body: some View {
        HStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            } else {
                Image(nsImage: NSImage(imageLiteralResourceName: NSImage.touchBarFolderTemplateName))
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            }
            
            Text(item.name)
                .font(.system(size: 16, weight: .regular, design: .rounded))
            
            Spacer()
            
            if index < 10 {
                HStack(spacing: 0) {
                    Text("⌘")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(selectKeeper == index ? Color.white : Color.systemGray)
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                        .padding([.trailing], 4)
                    
                    Text("\(index)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(selectKeeper == index ? Color.white : Color.systemGray)
                        .padding([.leading, .trailing], 6)
                        .padding([.top, .bottom], 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                    Button("") {
                        guard let link = item.link else { return }
                        openURL(link)
                    }
                    .opacity(0)
                    .frame(width: 0, height: 0, alignment: .top)
                    .keyboardShortcut(KeyboardShortcut.init(KeyEquivalent.init(Character("\(index)"))))
                }
            }
        }
        .padding(4)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .tag(index)
        .onHover { hovering in
            selectKeeper = index
            
            if hovering {
                isPopover = true
            } else {
                isPopover = false
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard let link = item.link else { return }
            openURL(link)
        }
        .popover(isPresented: self.$isPopover, arrowEdge: .trailing) {
            if let link = item.link {
                PopoverView(mesgURL: link.absoluteString, item: item)
                    .disabled(true)
            }
        }
        .onAppear {
            guard let link = item.link else { return }
            getFavicon(link)
        }
    }
}
