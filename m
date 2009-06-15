Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0D76B0062
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:13 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/11] vfs: Unmap underlying metadata of new data buffers only when buffer is mapped
Date: Mon, 15 Jun 2009 19:59:54 +0200
Message-Id: <1245088797-29533-8-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

When we do delayed allocation of some buffer, we want to signal to VFS that
the buffer is new (set buffer_new) so that it properly zeros out everything.
But we don't have the buffer mapped yet so we cannot really unmap underlying
metadata in this state. Make VFS avoid doing unmapping of metadata when the
buffer is not yet mapped.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 80e2630..7eb1710 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1683,8 +1683,9 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 			if (buffer_new(bh)) {
 				/* blockdev mappings never come here */
 				clear_buffer_new(bh);
-				unmap_underlying_metadata(bh->b_bdev,
-							bh->b_blocknr);
+				if (buffer_mapped(bh))
+					unmap_underlying_metadata(bh->b_bdev,
+						bh->b_blocknr);
 			}
 		}
 		bh = bh->b_this_page;
@@ -1869,8 +1870,9 @@ static int __block_prepare_write(struct inode *inode, struct page *page,
 			if (err)
 				break;
 			if (buffer_new(bh)) {
-				unmap_underlying_metadata(bh->b_bdev,
-							bh->b_blocknr);
+				if (buffer_mapped(bh))
+					unmap_underlying_metadata(bh->b_bdev,
+						bh->b_blocknr);
 				if (PageUptodate(page)) {
 					clear_buffer_new(bh);
 					set_buffer_uptodate(bh);
@@ -2683,7 +2685,7 @@ int nobh_write_begin(struct file *file, struct address_space *mapping,
 			goto failed;
 		if (!buffer_mapped(bh))
 			is_mapped_to_disk = 0;
-		if (buffer_new(bh))
+		if (buffer_new(bh) && buffer_mapped(bh))
 			unmap_underlying_metadata(bh->b_bdev, bh->b_blocknr);
 		if (PageUptodate(page)) {
 			set_buffer_uptodate(bh);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
