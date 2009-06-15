Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 332436B0082
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:20 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/11] fs: Don't clear dirty bits in block_write_full_page()
Date: Mon, 15 Jun 2009 19:59:55 +0200
Message-Id: <1245088797-29533-9-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

If getblock() fails in block_write_full_page(), we don't want to clear
dirty bits on buffers. Actually, we even want to redirty the page. This
way we just won't silently discard users data (written e.g. through mmap)
in case of ENOSPC, EDQUOT, EIO or other write error (which may be just
transient e.g. because we have to commit a transaction to free up some space).
The downside of this approach is that if the error is persistent we have this
page pinned in memory forever and if there are lots of such pages, we can bring
the machine OOM.

We also don't want to clear dirty bits from buffers above i_size because that
is a generally a bussiness of invalidatepage where filesystem might want to do
some additional work. If we clear dirty bits already in block_write_full_page,
memory reclaim can reap the page before invalidatepage is called on the page
and thus confusing the filesystem.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c |   40 +++++++++++++++++-----------------------
 1 files changed, 17 insertions(+), 23 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 7eb1710..21a8cb9 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1662,19 +1662,14 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	 * handle any aliases from the underlying blockdev's mapping.
 	 */
 	do {
-		if (block > last_block) {
-			/*
-			 * mapped buffers outside i_size will occur, because
-			 * this page can be outside i_size when there is a
-			 * truncate in progress.
-			 */
-			/*
-			 * The buffer was zeroed by block_write_full_page()
-			 */
-			clear_buffer_dirty(bh);
-			set_buffer_uptodate(bh);
-		} else if ((!buffer_mapped(bh) || buffer_delay(bh)) &&
-			   buffer_dirty(bh)) {
+		/*
+		 * Mapped buffers outside i_size will occur, because
+		 * this page can be outside i_size when there is a
+		 * truncate in progress.
+		 */
+		if (block <= last_block &&
+		    (!buffer_mapped(bh) || buffer_delay(bh)) &&
+		    buffer_dirty(bh)) {
 			WARN_ON(bh->b_size != blocksize);
 			err = get_block(inode, block, bh, 1);
 			if (err)
@@ -1692,9 +1687,10 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 		block++;
 	} while (bh != head);
 
+	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
 	do {
-		if (!buffer_mapped(bh))
-			continue;
+		if (!buffer_mapped(bh) || block > last_block)
+			goto next;
 		/*
 		 * If it's a fully non-blocking write attempt and we cannot
 		 * lock the buffer then redirty the page.  Note that this can
@@ -1706,13 +1702,15 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
 			redirty_page_for_writepage(wbc, page);
-			continue;
+			goto next;
 		}
 		if (test_clear_buffer_dirty(bh)) {
 			mark_buffer_async_write_endio(bh, handler);
 		} else {
 			unlock_buffer(bh);
 		}
+next:
+		block++;
 	} while ((bh = bh->b_this_page) != head);
 
 	/*
@@ -1753,9 +1751,11 @@ recover:
 	/*
 	 * ENOSPC, or some other error.  We may already have added some
 	 * blocks to the file, so we need to write these out to avoid
-	 * exposing stale data.
+	 * exposing stale data. We redirty the page so that we don't
+	 * loose data we are unable to write.
 	 * The page is currently locked and not marked for writeback
 	 */
+	redirty_page_for_writepage(wbc, page);
 	bh = head;
 	/* Recovery: lock and submit the mapped buffers */
 	do {
@@ -1763,12 +1763,6 @@ recover:
 		    !buffer_delay(bh)) {
 			lock_buffer(bh);
 			mark_buffer_async_write_endio(bh, handler);
-		} else {
-			/*
-			 * The buffer may have been set dirty during
-			 * attachment to a dirty page.
-			 */
-			clear_buffer_dirty(bh);
 		}
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
