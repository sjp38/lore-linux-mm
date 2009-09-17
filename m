Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 45FFA6B0083
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:21:47 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/7] fs: Remove zeroing from nobh_writepage
Date: Thu, 17 Sep 2009 17:21:42 +0200
Message-Id: <1253200907-31392-3-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

It isn't necessary to zero page in nobh_writepage() since mpage_writepage()
takes care of that. We just have to use block_write_full_page() instead
of __block_write_full_page() to properly zero the page in case we have
to fallback to ordinary writepage.

Since __block_write_full_page is then only used from
block_write_full_page_endio() join them.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/buffer.c |  426 +++++++++++++++++++++++++++--------------------------------
 1 files changed, 196 insertions(+), 230 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 67b260a..0eaa961 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1589,207 +1589,6 @@ void unmap_underlying_metadata(struct block_device *bdev, sector_t block)
 EXPORT_SYMBOL(unmap_underlying_metadata);
 
 /*
- * NOTE! All mapped/uptodate combinations are valid:
- *
- *	Mapped	Uptodate	Meaning
- *
- *	No	No		"unknown" - must do get_block()
- *	No	Yes		"hole" - zero-filled
- *	Yes	No		"allocated" - allocated on disk, not read in
- *	Yes	Yes		"valid" - allocated and up-to-date in memory.
- *
- * "Dirty" is valid only with the last case (mapped+uptodate).
- */
-
-/*
- * While block_write_full_page is writing back the dirty buffers under
- * the page lock, whoever dirtied the buffers may decide to clean them
- * again at any time.  We handle that by only looking at the buffer
- * state inside lock_buffer().
- *
- * If block_write_full_page() is called for regular writeback
- * (wbc->sync_mode == WB_SYNC_NONE) then it will redirty a page which has a
- * locked buffer.   This only can happen if someone has written the buffer
- * directly, with submit_bh().  At the address_space level PageWriteback
- * prevents this contention from occurring.
- *
- * If block_write_full_page() is called with wbc->sync_mode ==
- * WB_SYNC_ALL, the writes are posted using WRITE_SYNC_PLUG; this
- * causes the writes to be flagged as synchronous writes, but the
- * block device queue will NOT be unplugged, since usually many pages
- * will be pushed to the out before the higher-level caller actually
- * waits for the writes to be completed.  The various wait functions,
- * such as wait_on_writeback_range() will ultimately call sync_page()
- * which will ultimately call blk_run_backing_dev(), which will end up
- * unplugging the device queue.
- */
-static int __block_write_full_page(struct inode *inode, struct page *page,
-			get_block_t *get_block, struct writeback_control *wbc,
-			bh_end_io_t *handler)
-{
-	int err;
-	sector_t block;
-	sector_t last_block;
-	struct buffer_head *bh, *head;
-	const unsigned blocksize = 1 << inode->i_blkbits;
-	int nr_underway = 0;
-	int write_op = (wbc->sync_mode == WB_SYNC_ALL ?
-			WRITE_SYNC_PLUG : WRITE);
-
-	BUG_ON(!PageLocked(page));
-
-	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
-
-	if (!page_has_buffers(page)) {
-		create_empty_buffers(page, blocksize,
-					(1 << BH_Dirty)|(1 << BH_Uptodate));
-	}
-
-	/*
-	 * Be very careful.  We have no exclusion from __set_page_dirty_buffers
-	 * here, and the (potentially unmapped) buffers may become dirty at
-	 * any time.  If a buffer becomes dirty here after we've inspected it
-	 * then we just miss that fact, and the page stays dirty.
-	 *
-	 * Buffers outside i_size may be dirtied by __set_page_dirty_buffers;
-	 * handle that here by just cleaning them.
-	 */
-
-	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
-	head = page_buffers(page);
-	bh = head;
-
-	/*
-	 * Get all the dirty buffers mapped to disk addresses and
-	 * handle any aliases from the underlying blockdev's mapping.
-	 */
-	do {
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
-			WARN_ON(bh->b_size != blocksize);
-			err = get_block(inode, block, bh, 1);
-			if (err)
-				goto recover;
-			clear_buffer_delay(bh);
-			if (buffer_new(bh)) {
-				/* blockdev mappings never come here */
-				clear_buffer_new(bh);
-				unmap_underlying_metadata(bh->b_bdev,
-							bh->b_blocknr);
-			}
-		}
-		bh = bh->b_this_page;
-		block++;
-	} while (bh != head);
-
-	do {
-		if (!buffer_mapped(bh))
-			continue;
-		/*
-		 * If it's a fully non-blocking write attempt and we cannot
-		 * lock the buffer then redirty the page.  Note that this can
-		 * potentially cause a busy-wait loop from pdflush and kswapd
-		 * activity, but those code paths have their own higher-level
-		 * throttling.
-		 */
-		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
-			lock_buffer(bh);
-		} else if (!trylock_buffer(bh)) {
-			redirty_page_for_writepage(wbc, page);
-			continue;
-		}
-		if (test_clear_buffer_dirty(bh)) {
-			mark_buffer_async_write_endio(bh, handler);
-		} else {
-			unlock_buffer(bh);
-		}
-	} while ((bh = bh->b_this_page) != head);
-
-	/*
-	 * The page and its buffers are protected by PageWriteback(), so we can
-	 * drop the bh refcounts early.
-	 */
-	BUG_ON(PageWriteback(page));
-	set_page_writeback(page);
-
-	do {
-		struct buffer_head *next = bh->b_this_page;
-		if (buffer_async_write(bh)) {
-			submit_bh(write_op, bh);
-			nr_underway++;
-		}
-		bh = next;
-	} while (bh != head);
-	unlock_page(page);
-
-	err = 0;
-done:
-	if (nr_underway == 0) {
-		/*
-		 * The page was marked dirty, but the buffers were
-		 * clean.  Someone wrote them back by hand with
-		 * ll_rw_block/submit_bh.  A rare case.
-		 */
-		end_page_writeback(page);
-
-		/*
-		 * The page and buffer_heads can be released at any time from
-		 * here on.
-		 */
-	}
-	return err;
-
-recover:
-	/*
-	 * ENOSPC, or some other error.  We may already have added some
-	 * blocks to the file, so we need to write these out to avoid
-	 * exposing stale data.
-	 * The page is currently locked and not marked for writeback
-	 */
-	bh = head;
-	/* Recovery: lock and submit the mapped buffers */
-	do {
-		if (buffer_mapped(bh) && buffer_dirty(bh) &&
-		    !buffer_delay(bh)) {
-			lock_buffer(bh);
-			mark_buffer_async_write_endio(bh, handler);
-		} else {
-			/*
-			 * The buffer may have been set dirty during
-			 * attachment to a dirty page.
-			 */
-			clear_buffer_dirty(bh);
-		}
-	} while ((bh = bh->b_this_page) != head);
-	SetPageError(page);
-	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
-	set_page_writeback(page);
-	do {
-		struct buffer_head *next = bh->b_this_page;
-		if (buffer_async_write(bh)) {
-			clear_buffer_dirty(bh);
-			submit_bh(write_op, bh);
-			nr_underway++;
-		}
-		bh = next;
-	} while (bh != head);
-	unlock_page(page);
-	goto done;
-}
-
-/*
  * If a page has any new buffers, zero them out here, and mark them uptodate
  * and dirty so they'll be written out (in order to prevent uninitialised
  * block data from leaking). And clear the new bit.
@@ -2653,36 +2452,11 @@ EXPORT_SYMBOL(nobh_write_end);
 int nobh_writepage(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
-	loff_t i_size = i_size_read(inode);
-	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
-	unsigned offset;
 	int ret;
 
-	/* Is the page fully inside i_size? */
-	if (page->index < end_index)
-		goto out;
-
-	/* Is the page fully outside i_size? (truncate in progress) */
-	offset = i_size & (PAGE_CACHE_SIZE-1);
-	if (page->index >= end_index+1 || !offset) {
-		unlock_page(page);
-		return 0;
-	}
-
-	/*
-	 * The page straddles i_size.  It must be zeroed out on each and every
-	 * writepage invocation because it may be mmapped.  "A file is mapped
-	 * in multiples of the page size.  For a file that is not a multiple of
-	 * the  page size, the remaining memory is zeroed when mapped, and
-	 * writes to that region are not written out to the file."
-	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
-out:
 	ret = mpage_writepage(page, get_block, wbc);
 	if (ret == -EAGAIN)
-		ret = __block_write_full_page(inode, page, get_block, wbc,
-					      end_buffer_async_write);
+		ret = block_write_full_page(page, get_block, wbc);
 	return ret;
 }
 EXPORT_SYMBOL(nobh_writepage);
@@ -2841,21 +2615,64 @@ out:
 }
 
 /*
+ * NOTE! All mapped/uptodate combinations are valid:
+ *
+ *	Mapped	Uptodate	Meaning
+ *
+ *	No	No		"unknown" - must do get_block()
+ *	No	Yes		"hole" - zero-filled
+ *	Yes	No		"allocated" - allocated on disk, not read in
+ *	Yes	Yes		"valid" - allocated and up-to-date in memory.
+ *
+ * "Dirty" is valid only with the last case (mapped+uptodate).
+ */
+
+/*
  * The generic ->writepage function for buffer-backed address_spaces
  * this form passes in the end_io handler used to finish the IO.
+ *
+ * While block_write_full_page is writing back the dirty buffers under
+ * the page lock, whoever dirtied the buffers may decide to clean them
+ * again at any time.  We handle that by only looking at the buffer
+ * state inside lock_buffer().
+ *
+ * If block_write_full_page() is called for regular writeback
+ * (wbc->sync_mode == WB_SYNC_NONE) then it will redirty a page which has a
+ * locked buffer. This only can happen if someone has written the buffer
+ * directly, with submit_bh().  At the address_space level PageWriteback
+ * prevents this contention from occurring.
+ *
+ * If block_write_full_page() is called with wbc->sync_mode ==
+ * WB_SYNC_ALL, the writes are posted using WRITE_SYNC_PLUG; this
+ * causes the writes to be flagged as synchronous writes, but the
+ * block device queue will NOT be unplugged, since usually many pages
+ * will be pushed to the out before the higher-level caller actually
+ * waits for the writes to be completed.  The various wait functions,
+ * such as wait_on_writeback_range() will ultimately call sync_page()
+ * which will ultimately call blk_run_backing_dev(), which will end up
+ * unplugging the device queue.
  */
 int block_write_full_page_endio(struct page *page, get_block_t *get_block,
 			struct writeback_control *wbc, bh_end_io_t *handler)
 {
+	int err;
 	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
+	sector_t block;
+	sector_t last_block;
+	struct buffer_head *bh, *head;
+	const unsigned blocksize = 1 << inode->i_blkbits;
+	int nr_underway = 0;
+	int write_op = (wbc->sync_mode == WB_SYNC_ALL ?
+			WRITE_SYNC_PLUG : WRITE);
+
+	BUG_ON(!PageLocked(page));
 
 	/* Is the page fully inside i_size? */
 	if (page->index < end_index)
-		return __block_write_full_page(inode, page, get_block, wbc,
-					       handler);
+		goto write_page;
 
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
@@ -2872,7 +2689,156 @@ int block_write_full_page_endio(struct page *page, get_block_t *get_block,
 	 * writes to that region are not written out to the file."
 	 */
 	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
-	return __block_write_full_page(inode, page, get_block, wbc, handler);
+write_page:
+	last_block = i_size >> inode->i_blkbits;
+
+	if (!page_has_buffers(page)) {
+		create_empty_buffers(page, blocksize,
+					(1 << BH_Dirty)|(1 << BH_Uptodate));
+	}
+
+	/*
+	 * Be very careful.  We have no exclusion from __set_page_dirty_buffers
+	 * here, and the (potentially unmapped) buffers may become dirty at
+	 * any time.  If a buffer becomes dirty here after we've inspected it
+	 * then we just miss that fact, and the page stays dirty.
+	 *
+	 * Buffers outside i_size may be dirtied by __set_page_dirty_buffers;
+	 * handle that here by just cleaning them.
+	 */
+
+	block = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
+	head = page_buffers(page);
+	bh = head;
+
+	/*
+	 * Get all the dirty buffers mapped to disk addresses and
+	 * handle any aliases from the underlying blockdev's mapping.
+	 */
+	do {
+		if (block > last_block) {
+			/*
+			 * mapped buffers outside i_size will occur, because
+			 * this page can be outside i_size when there is a
+			 * truncate in progress.
+			 */
+			/*
+			 * The buffer was zeroed by block_write_full_page()
+			 */
+			clear_buffer_dirty(bh);
+			set_buffer_uptodate(bh);
+		} else if ((!buffer_mapped(bh) || buffer_delay(bh)) &&
+			   buffer_dirty(bh)) {
+			WARN_ON(bh->b_size != blocksize);
+			err = get_block(inode, block, bh, 1);
+			if (err)
+				goto recover;
+			clear_buffer_delay(bh);
+			if (buffer_new(bh)) {
+				/* blockdev mappings never come here */
+				clear_buffer_new(bh);
+				unmap_underlying_metadata(bh->b_bdev,
+							bh->b_blocknr);
+			}
+		}
+		bh = bh->b_this_page;
+		block++;
+	} while (bh != head);
+
+	do {
+		if (!buffer_mapped(bh))
+			continue;
+		/*
+		 * If it's a fully non-blocking write attempt and we cannot
+		 * lock the buffer then redirty the page.  Note that this can
+		 * potentially cause a busy-wait loop from pdflush and kswapd
+		 * activity, but those code paths have their own higher-level
+		 * throttling.
+		 */
+		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
+			lock_buffer(bh);
+		} else if (!trylock_buffer(bh)) {
+			redirty_page_for_writepage(wbc, page);
+			continue;
+		}
+		if (test_clear_buffer_dirty(bh)) {
+			mark_buffer_async_write_endio(bh, handler);
+		} else {
+			unlock_buffer(bh);
+		}
+	} while ((bh = bh->b_this_page) != head);
+
+	/*
+	 * The page and its buffers are protected by PageWriteback(), so we can
+	 * drop the bh refcounts early.
+	 */
+	BUG_ON(PageWriteback(page));
+	set_page_writeback(page);
+
+	do {
+		struct buffer_head *next = bh->b_this_page;
+		if (buffer_async_write(bh)) {
+			submit_bh(write_op, bh);
+			nr_underway++;
+		}
+		bh = next;
+	} while (bh != head);
+	unlock_page(page);
+
+	err = 0;
+done:
+	if (nr_underway == 0) {
+		/*
+		 * The page was marked dirty, but the buffers were
+		 * clean.  Someone wrote them back by hand with
+		 * ll_rw_block/submit_bh.  A rare case.
+		 */
+		end_page_writeback(page);
+
+		/*
+		 * The page and buffer_heads can be released at any time from
+		 * here on.
+		 */
+	}
+	return err;
+
+recover:
+	/*
+	 * ENOSPC, or some other error.  We may already have added some
+	 * blocks to the file, so we need to write these out to avoid
+	 * exposing stale data.
+	 * The page is currently locked and not marked for writeback
+	 */
+	bh = head;
+	/* Recovery: lock and submit the mapped buffers */
+	do {
+		if (buffer_mapped(bh) && buffer_dirty(bh) &&
+		    !buffer_delay(bh)) {
+			lock_buffer(bh);
+			mark_buffer_async_write_endio(bh, handler);
+		} else {
+			/*
+			 * The buffer may have been set dirty during
+			 * attachment to a dirty page.
+			 */
+			clear_buffer_dirty(bh);
+		}
+	} while ((bh = bh->b_this_page) != head);
+	SetPageError(page);
+	BUG_ON(PageWriteback(page));
+	mapping_set_error(page->mapping, err);
+	set_page_writeback(page);
+	do {
+		struct buffer_head *next = bh->b_this_page;
+		if (buffer_async_write(bh)) {
+			clear_buffer_dirty(bh);
+			submit_bh(write_op, bh);
+			nr_underway++;
+		}
+		bh = next;
+	} while (bh != head);
+	unlock_page(page);
+	goto done;
 }
 
 /*
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
