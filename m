Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EC4B26B0095
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 05:10:37 -0400 (EDT)
Date: Fri, 10 Jul 2009 11:34:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/3] fs: buffer_head writepage no zero
Message-ID: <20090710093403.GH14666@wotan.suse.de>
References: <20090710073028.782561541@suse.de> <20090710093325.GG14666@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090710093325.GG14666@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


When writing a page to filesystem, buffer.c zeroes out parts of the page past
i_size in an attempt to get zeroes into those blocks on disk, so as to honour
the requirement that an expanding truncate should zero-fill the file.

Unfortunately, this is racy. The reason we can get something other than
zeroes here is via an mmaped write to the block beyond i_size. Zeroing it
out before writepage narrows the window, but it is still possible to store
junk beyond i_size on disk, by storing into the page after writepage zeroes,
but before DMA (or copy) completes. This allows process A to break posix
semantics for process B (or even inadvertently for itsef).

It could also be possible that the filesystem has written data into the
block but not yet expanded the inode size when the system crashes for
some reason. Unless its journal reply / fsck process etc checks for this
condition, it could also cause subsequent breakage in semantics.

---
 fs/buffer.c      |   94 +++++++++++++++++++++++++------------------------------
 fs/ext2/inode.c  |   30 ++++++++++++++++-
 fs/mpage.c       |   13 +------
 mm/filemap_xip.c |   15 ++++----
 mm/truncate.c    |    1 
 5 files changed, 82 insertions(+), 71 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -2656,26 +2656,14 @@ int nobh_writepage(struct page *page, ge
 	unsigned offset;
 	int ret;
 
-	/* Is the page fully inside i_size? */
-	if (page->index < end_index)
-		goto out;
-
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
-	if (page->index >= end_index+1 || !offset) {
+	if (page->index >= end_index &&
+			(page->index >= end_index+1 || !offset)) {
 		unlock_page(page);
 		return 0;
 	}
 
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
 		ret = __block_write_full_page(inode, page, get_block, wbc,
@@ -2695,22 +2683,23 @@ int nobh_truncate_page(struct address_sp
 	struct inode *inode = mapping->host;
 	struct page *page;
 	struct buffer_head map_bh;
-	int err;
+	int err = 0;
 
 	blocksize = 1 << inode->i_blkbits;
 	length = offset & (blocksize - 1);
 
 	/* Block boundary? Nothing to do */
 	if (!length)
-		return 0;
+		goto out;
 
 	length = blocksize - length;
 	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
 
 	page = grab_cache_page(mapping, index);
-	err = -ENOMEM;
-	if (!page)
+	if (!page) {
+		err = -ENOMEM;
 		goto out;
+	}
 
 	if (page_has_buffers(page)) {
 has_buffers:
@@ -2752,7 +2741,6 @@ has_buffers:
 	}
 	zero_user(page, offset, length);
 	set_page_dirty(page);
-	err = 0;
 
 unlock:
 	unlock_page(page);
@@ -2762,8 +2750,8 @@ out:
 }
 EXPORT_SYMBOL(nobh_truncate_page);
 
-int block_truncate_page(struct address_space *mapping,
-			loff_t from, get_block_t *get_block)
+int __block_truncate_page(struct address_space *mapping,
+			loff_t from, loff_t to, get_block_t *get_block)
 {
 	pgoff_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
@@ -2773,22 +2761,22 @@ int block_truncate_page(struct address_s
 	struct inode *inode = mapping->host;
 	struct page *page;
 	struct buffer_head *bh;
-	int err;
+	int err = 0;
 
-	blocksize = 1 << inode->i_blkbits;
-	length = offset & (blocksize - 1);
+	/* Page boundary? Nothing to do */
+	if (!offset)
+		goto out;
 
-	/* Block boundary? Nothing to do */
-	if (!length)
-		return 0;
+	blocksize = 1 << inode->i_blkbits;
 
-	length = blocksize - length;
+	length = (unsigned)min_t(loff_t, to - from, PAGE_CACHE_SIZE - offset);
 	iblock = (sector_t)index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
 	
 	page = grab_cache_page(mapping, index);
-	err = -ENOMEM;
-	if (!page)
+	if (!page) {
+		err = -ENOMEM;
 		goto out;
+	}
 
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize, 0);
@@ -2802,15 +2790,20 @@ int block_truncate_page(struct address_s
 		pos += blocksize;
 	}
 
-	err = 0;
 	if (!buffer_mapped(bh)) {
 		WARN_ON(bh->b_size != blocksize);
 		err = get_block(inode, iblock, bh, 0);
 		if (err)
 			goto unlock;
-		/* unmapped? It's a hole - nothing to do */
-		if (!buffer_mapped(bh))
+		/*
+		 * unmapped? It's a hole - must zero out partial
+		 * in the case of an extending truncate where mmap has
+		 * previously written past i_size of the page
+		 */
+		if (!buffer_mapped(bh)) {
+			zero_user(page, offset, length);
 			goto unlock;
+		}
 	}
 
 	/* Ok, it's mapped. Make sure it's up-to-date */
@@ -2818,17 +2811,17 @@ int block_truncate_page(struct address_s
 		set_buffer_uptodate(bh);
 
 	if (!buffer_uptodate(bh) && !buffer_delay(bh) && !buffer_unwritten(bh)) {
-		err = -EIO;
 		ll_rw_block(READ, 1, &bh);
 		wait_on_buffer(bh);
 		/* Uhhuh. Read error. Complain and punt. */
-		if (!buffer_uptodate(bh))
+		if (!buffer_uptodate(bh)) {
+			err = -EIO;
 			goto unlock;
+		}
 	}
 
 	zero_user(page, offset, length);
 	mark_buffer_dirty(bh);
-	err = 0;
 
 unlock:
 	unlock_page(page);
@@ -2836,6 +2829,19 @@ unlock:
 out:
 	return err;
 }
+EXPORT_SYMBOL(__block_truncate_page);
+
+int block_truncate_page(struct address_space *mapping,
+			loff_t from, get_block_t *get_block)
+{
+	struct inode *inode = mapping->host;
+	int err = 0;
+
+	if (from > inode->i_size)
+		err = __block_truncate_page(mapping, inode->i_size, from, get_block);
+
+	return err;
+}
 
 /*
  * The generic ->writepage function for buffer-backed address_spaces
@@ -2849,26 +2855,14 @@ int block_write_full_page_endio(struct p
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
 
-	/* Is the page fully inside i_size? */
-	if (page->index < end_index)
-		return __block_write_full_page(inode, page, get_block, wbc,
-					       handler);
-
 	/* Is the page fully outside i_size? (truncate in progress) */
 	offset = i_size & (PAGE_CACHE_SIZE-1);
-	if (page->index >= end_index+1 || !offset) {
+	if (page->index >= end_index &&
+			(page->index >= end_index+1 || !offset)) {
 		unlock_page(page);
 		return 0;
 	}
 
-	/*
-	 * The page straddles i_size.  It must be zeroed out on each and every
-	 * writepage invokation because it may be mmapped.  "A file is mapped
-	 * in multiples of the page size.  For a file that is not a multiple of
-	 * the  page size, the remaining memory is zeroed when mapped, and
-	 * writes to that region are not written out to the file."
-	 */
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
 	return __block_write_full_page(inode, page, get_block, wbc, handler);
 }
 
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -440,22 +440,23 @@ EXPORT_SYMBOL_GPL(xip_file_write);
 int
 xip_truncate_page(struct address_space *mapping, loff_t from)
 {
+	struct inode *inode = mapping->host;
 	pgoff_t index = from >> PAGE_CACHE_SHIFT;
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
 	unsigned blocksize;
 	unsigned length;
 	void *xip_mem;
 	unsigned long xip_pfn;
-	int err;
+	int err = 0;
 
 	BUG_ON(!mapping->a_ops->get_xip_mem);
 
-	blocksize = 1 << mapping->host->i_blkbits;
+	blocksize = 1 << inode->i_blkbits;
 	length = offset & (blocksize - 1);
 
 	/* Block boundary? Nothing to do */
 	if (!length)
-		return 0;
+		goto out;
 
 	length = blocksize - length;
 
@@ -464,11 +465,11 @@ xip_truncate_page(struct address_space *
 	if (unlikely(err)) {
 		if (err == -ENODATA)
 			/* Hole? No need to truncate */
-			return 0;
-		else
-			return err;
+			err = 0;
+		goto out;
 	}
 	memset(xip_mem + offset, 0, length);
-	return 0;
+out:
+	return err;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c
+++ linux-2.6/fs/mpage.c
@@ -559,19 +559,10 @@ static int __mpage_writepage(struct page
 page_is_mapped:
 	end_index = i_size >> PAGE_CACHE_SHIFT;
 	if (page->index >= end_index) {
-		/*
-		 * The page straddles i_size.  It must be zeroed out on each
-		 * and every writepage invokation because it may be mmapped.
-		 * "A file is mapped in multiples of the page size.  For a file
-		 * that is not a multiple of the page size, the remaining memory
-		 * is zeroed when mapped, and writes to that region are not
-		 * written out to the file."
-		 */
 		unsigned offset = i_size & (PAGE_CACHE_SIZE - 1);
 
-		if (page->index > end_index || !offset)
-			goto confused;
-		zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+		if (page->index >= end_index+1 || !offset)
+			goto confused; /* page fully outside i_size */
 	}
 
 	/*
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -777,14 +777,40 @@ ext2_write_begin(struct file *file, stru
 	return ret;
 }
 
+int __block_truncate_page(struct address_space *mapping,
+			loff_t from, loff_t to, get_block_t *get_block);
 static int ext2_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
+	struct inode *inode = mapping->host;
 	int ret;
 
-	ret = generic_write_end(file, mapping, pos, len, copied, page, fsdata);
-	if (ret < len) {
+	ret = block_write_end(file, mapping, pos, len, copied, page, fsdata);
+	unlock_page(page);
+	page_cache_release(page);
+        if (pos+copied > inode->i_size) {
+		int err;
+                if (pos > inode->i_size) {
+                        /* expanding a hole */
+			err = __block_truncate_page(mapping, inode->i_size,
+						pos, ext2_get_block);
+			if (err) {
+				ret = err;
+				goto out;
+			}
+			err = __block_truncate_page(mapping, pos+copied,
+						LLONG_MAX, ext2_get_block);
+			if (err) {
+				ret = err;
+				goto out;
+			}
+                }
+                i_size_write(inode, pos+copied);
+                mark_inode_dirty(inode);
+        }
+out:
+	if (ret < 0 || ret < len) {
 		struct inode *inode = mapping->host;
 		loff_t isize = inode->i_size;
 		if (pos + len > isize)
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -49,7 +49,6 @@ void do_invalidatepage(struct page *page
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
-	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
 	if (page_has_private(page))
 		do_invalidatepage(page, partial);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
