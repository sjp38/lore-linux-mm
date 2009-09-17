Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C03E6B007E
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:23:03 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/7] ext4: Convert ext4 to new mkwrite code
Date: Thu, 17 Sep 2009 17:21:46 +0200
Message-Id: <1253200907-31392-7-git-send-email-jack@suse.cz>
In-Reply-To: <1253200907-31392-1-git-send-email-jack@suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/ext4.h    |    2 -
 fs/ext4/extents.c |    4 -
 fs/ext4/inode.c   |  239 +++++++++++++++++++++++------------------------------
 3 files changed, 102 insertions(+), 143 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 9714db3..9110114 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1374,8 +1374,6 @@ extern void ext4_set_aops(struct inode *inode);
 extern int ext4_writepage_trans_blocks(struct inode *);
 extern int ext4_meta_trans_blocks(struct inode *, int nrblocks, int idxblocks);
 extern int ext4_chunk_trans_blocks(struct inode *, int nrblocks);
-extern int ext4_block_truncate_page(handle_t *handle,
-		struct address_space *mapping, loff_t from);
 extern int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 extern qsize_t ext4_get_reserved_space(struct inode *inode);
 
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 73ebfb4..76ece1b 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -2996,7 +2996,6 @@ out2:
 
 void ext4_ext_truncate(struct inode *inode)
 {
-	struct address_space *mapping = inode->i_mapping;
 	struct super_block *sb = inode->i_sb;
 	ext4_lblk_t last_block;
 	handle_t *handle;
@@ -3010,9 +3009,6 @@ void ext4_ext_truncate(struct inode *inode)
 	if (IS_ERR(handle))
 		return;
 
-	if (inode->i_size & (sb->s_blocksize - 1))
-		ext4_block_truncate_page(handle, mapping, inode->i_size);
-
 	if (ext4_orphan_add(handle, inode))
 		goto out_stop;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index be25874..1df027c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1451,6 +1451,53 @@ static int do_journal_get_write_access(handle_t *handle,
 	return ext4_journal_get_write_access(handle, bh);
 }
 
+/*
+ * If we create a hole by this write, zero out a block partially under
+ * the hole created
+ */
+static int ext4_prepare_hole(handle_t *handle, struct inode *inode,
+			     loff_t from, loff_t to, unsigned flags)
+{
+	struct buffer_head *bh;
+	unsigned hole_start, hole_len;
+	unsigned bsize = 1 << inode->i_blkbits;
+	int ret;
+
+	/* No hole created? */
+	if (from >= to)
+		return 0;
+
+	bh = block_prepare_hole_bh(inode, from, to, flags, ext4_get_block);
+	if (IS_ERR(bh))
+		return PTR_ERR(bh);
+	if (!bh)
+		return 0;
+
+	if (ext4_should_journal_data(inode)) {
+		ret = ext4_journal_get_write_access(handle, bh);
+		if (ret)
+			goto out;
+	}
+	/* Zero the tail of the block upto 'from' */
+	hole_start = from & (PAGE_CACHE_SIZE - 1);
+	if (to > ALIGN(from, bsize))
+		hole_len = bsize - (hole_start & (bsize - 1));
+	else
+		hole_len = to - from;
+
+	zero_user(bh->b_page, hole_start, hole_len);
+	if (ext4_should_order_data(inode)) {
+		ret = ext4_jbd2_file_inode(handle, inode);
+		mark_buffer_dirty(bh);
+	} else if (ext4_should_journal_data(inode))
+		ret = ext4_handle_dirty_metadata(handle, inode, bh);
+	else
+		mark_buffer_dirty(bh);
+out:
+	brelse(bh);
+	return ret;
+}
+
 static int ext4_write_begin(struct file *file, struct address_space *mapping,
 			    loff_t pos, unsigned len, unsigned flags,
 			    struct page **pagep, void **fsdata)
@@ -1465,10 +1512,13 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 
 	trace_ext4_write_begin(inode, pos, len, flags);
 	/*
-	 * Reserve one block more for addition to orphan list in case
-	 * we allocate blocks but write fails for some reason
+	 * Reserve one block for addition to orphan list in case
+	 * we allocate blocks but write fails for some reason and
+	 * one block for zeroed block in case we create hole
+	 * (needed only if we journal data)
 	 */
-	needed_blocks = ext4_writepage_trans_blocks(inode) + 1;
+	needed_blocks = ext4_writepage_trans_blocks(inode) + 1 +
+		(pos > inode->i_size && ext4_should_journal_data(inode));
 	index = pos >> PAGE_CACHE_SHIFT;
 	from = pos & (PAGE_CACHE_SIZE - 1);
 	to = from + len;
@@ -1484,6 +1534,12 @@ retry:
 	 * started */
 	flags |= AOP_FLAG_NOFS;
 
+	ret = ext4_prepare_hole(handle, inode, inode->i_size, pos, flags);
+	if (ret) {
+		ext4_journal_stop(handle);
+		goto out;
+	}
+
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page) {
 		ext4_journal_stop(handle);
@@ -1548,23 +1604,17 @@ static int ext4_generic_write_end(struct file *file,
 				  loff_t pos, unsigned len, unsigned copied,
 				  struct page *page, void *fsdata)
 {
-	int i_size_changed = 0;
 	struct inode *inode = mapping->host;
 	handle_t *handle = ext4_journal_current_handle();
+	loff_t old_i_size = inode->i_size;
 
 	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
-	/*
-	 * No need to use i_size_read() here, the i_size
-	 * cannot change under us because we hold i_mutex.
-	 *
-	 * But it's important to update i_size while still holding page lock:
-	 * page writeout could otherwise come in and zero beyond i_size.
-	 */
-	if (pos + copied > inode->i_size) {
+	unlock_page(page);
+	page_cache_release(page);
+
+	if (pos + copied > inode->i_size)
 		i_size_write(inode, pos + copied);
-		i_size_changed = 1;
-	}
 
 	if (pos + copied >  EXT4_I(inode)->i_disksize) {
 		/* We need to mark inode dirty even if
@@ -1572,19 +1622,9 @@ static int ext4_generic_write_end(struct file *file,
 		 * bu greater than i_disksize.(hint delalloc)
 		 */
 		ext4_update_i_disksize(inode, (pos + copied));
-		i_size_changed = 1;
-	}
-	unlock_page(page);
-	page_cache_release(page);
-
-	/*
-	 * Don't mark the inode dirty under page lock. First, it unnecessarily
-	 * makes the holding time of page lock longer. Second, it forces lock
-	 * ordering of page lock and transaction start for journaling
-	 * filesystems.
-	 */
-	if (i_size_changed)
 		ext4_mark_inode_dirty(handle, inode);
+	}
+	block_finish_hole(inode, old_i_size, pos);
 
 	return copied;
 }
@@ -1691,7 +1731,7 @@ static int ext4_journalled_write_end(struct file *file,
 	int ret = 0, ret2;
 	int partial = 0;
 	unsigned from, to;
-	loff_t new_i_size;
+	loff_t new_i_size, old_i_size = inode->i_size;
 
 	trace_ext4_journalled_write_end(inode, pos, len, copied);
 	from = pos & (PAGE_CACHE_SIZE - 1);
@@ -1707,6 +1747,10 @@ static int ext4_journalled_write_end(struct file *file,
 				to, &partial, write_end_fn);
 	if (!partial)
 		SetPageUptodate(page);
+
+	unlock_page(page);
+	page_cache_release(page);
+
 	new_i_size = pos + copied;
 	if (new_i_size > inode->i_size)
 		i_size_write(inode, pos+copied);
@@ -1718,8 +1762,8 @@ static int ext4_journalled_write_end(struct file *file,
 			ret = ret2;
 	}
 
-	unlock_page(page);
-	page_cache_release(page);
+	block_finish_hole(inode, old_i_size, pos);
+
 	if (pos + len > inode->i_size && ext4_can_truncate(inode))
 		/* if we have allocated more blocks and copied
 		 * less. We will have blocks allocated outside
@@ -2967,6 +3011,12 @@ retry:
 	 * started */
 	flags |= AOP_FLAG_NOFS;
 
+	ret = ext4_prepare_hole(handle, inode, inode->i_size, pos, flags);
+	if (ret) {
+		ext4_journal_stop(handle);
+		goto out;
+	}
+
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page) {
 		ext4_journal_stop(handle);
@@ -3434,100 +3484,6 @@ void ext4_set_aops(struct inode *inode)
 }
 
 /*
- * ext4_block_truncate_page() zeroes out a mapping from file offset `from'
- * up to the end of the block which corresponds to `from'.
- * This required during truncate. We need to physically zero the tail end
- * of that block so it doesn't yield old data if the file is later grown.
- */
-int ext4_block_truncate_page(handle_t *handle,
-		struct address_space *mapping, loff_t from)
-{
-	ext4_fsblk_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE-1);
-	unsigned blocksize, length, pos;
-	ext4_lblk_t iblock;
-	struct inode *inode = mapping->host;
-	struct buffer_head *bh;
-	struct page *page;
-	int err = 0;
-
-	page = find_or_create_page(mapping, from >> PAGE_CACHE_SHIFT,
-				   mapping_gfp_mask(mapping) & ~__GFP_FS);
-	if (!page)
-		return -EINVAL;
-
-	blocksize = inode->i_sb->s_blocksize;
-	length = blocksize - (offset & (blocksize - 1));
-	iblock = index << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
-
-	if (!page_has_buffers(page))
-		create_empty_buffers(page, blocksize, 0);
-
-	/* Find the buffer that contains "offset" */
-	bh = page_buffers(page);
-	pos = blocksize;
-	while (offset >= pos) {
-		bh = bh->b_this_page;
-		iblock++;
-		pos += blocksize;
-	}
-
-	err = 0;
-	if (buffer_freed(bh)) {
-		BUFFER_TRACE(bh, "freed: skip");
-		goto unlock;
-	}
-
-	if (!buffer_mapped(bh)) {
-		BUFFER_TRACE(bh, "unmapped");
-		ext4_get_block(inode, iblock, bh, 0);
-		/* unmapped? It's a hole - nothing to do */
-		if (!buffer_mapped(bh)) {
-			BUFFER_TRACE(bh, "still unmapped");
-			goto unlock;
-		}
-	}
-
-	/* Ok, it's mapped. Make sure it's up-to-date */
-	if (PageUptodate(page))
-		set_buffer_uptodate(bh);
-
-	if (!buffer_uptodate(bh)) {
-		err = -EIO;
-		ll_rw_block(READ, 1, &bh);
-		wait_on_buffer(bh);
-		/* Uhhuh. Read error. Complain and punt. */
-		if (!buffer_uptodate(bh))
-			goto unlock;
-	}
-
-	if (ext4_should_journal_data(inode)) {
-		BUFFER_TRACE(bh, "get write access");
-		err = ext4_journal_get_write_access(handle, bh);
-		if (err)
-			goto unlock;
-	}
-
-	zero_user(page, offset, length);
-
-	BUFFER_TRACE(bh, "zeroed end of block");
-
-	err = 0;
-	if (ext4_should_journal_data(inode)) {
-		err = ext4_handle_dirty_metadata(handle, inode, bh);
-	} else {
-		if (ext4_should_order_data(inode))
-			err = ext4_jbd2_file_inode(handle, inode);
-		mark_buffer_dirty(bh);
-	}
-
-unlock:
-	unlock_page(page);
-	page_cache_release(page);
-	return err;
-}
-
-/*
  * Probably it should be a library function... search for first non-zero word
  * or memcmp with zero_page, whatever is better for particular architecture.
  * Linus?
@@ -3932,7 +3888,6 @@ void ext4_truncate(struct inode *inode)
 	struct ext4_inode_info *ei = EXT4_I(inode);
 	__le32 *i_data = ei->i_data;
 	int addr_per_block = EXT4_ADDR_PER_BLOCK(inode->i_sb);
-	struct address_space *mapping = inode->i_mapping;
 	ext4_lblk_t offsets[4];
 	Indirect chain[4];
 	Indirect *partial;
@@ -3960,10 +3915,6 @@ void ext4_truncate(struct inode *inode)
 	last_block = (inode->i_size + blocksize-1)
 					>> EXT4_BLOCK_SIZE_BITS(inode->i_sb);
 
-	if (inode->i_size & (blocksize - 1))
-		if (ext4_block_truncate_page(handle, mapping, inode->i_size))
-			goto out_stop;
-
 	n = ext4_block_to_path(inode, last_block, offsets, NULL);
 	if (n == 0)
 		goto out_stop;	/* error */
@@ -4744,16 +4695,30 @@ static int ext4_setsize(struct inode *inode, loff_t newsize)
 				goto err_out;
 			}
 		}
-	} else if (!(EXT4_I(inode)->i_flags & EXT4_EXTENTS_FL)) {
-		struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
+	} else {
+		if (!(EXT4_I(inode)->i_flags & EXT4_EXTENTS_FL)) {
+			struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
 
-		if (newsize > sbi->s_bitmap_maxbytes) {
-			error = -EFBIG;
-			goto out;
+			if (newsize > sbi->s_bitmap_maxbytes) {
+				error = -EFBIG;
+				goto out;
+			}
 		}
+		handle = ext4_journal_start(inode, 1);
+		if (IS_ERR(handle)) {
+			error = PTR_ERR(handle);
+			goto err_out;
+		}
+		error = ext4_prepare_hole(handle, inode, oldsize, newsize,
+					  AOP_FLAG_NOFS);
+		ext4_journal_stop(handle);
+		if (error)
+			goto err_out;
 	}
 
 	i_size_write(inode, newsize);
+	if (newsize > oldsize)
+		block_finish_hole(inode, oldsize, newsize);
 	truncate_pagecache(inode, oldsize, newsize);
 	ext4_truncate(inode);
 
@@ -5301,10 +5266,10 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	}
 	/*
 	 * OK, we need to fill the hole... Do write_begin write_end
-	 * to do block allocation/reservation.We are not holding
-	 * inode.i__mutex here. That allow * parallel write_begin,
-	 * write_end call. lock_page prevent this from happening
-	 * on the same page though
+	 * to do block allocation/reservation. We are not holding
+	 * inode->i_mutex here. That allows parallel write_begin,
+	 * write_end calls. lock_page prevent this from happening
+	 * on the same page though.
 	 */
 	ret = mapping->a_ops->write_begin(file, mapping, page_offset(page),
 			len, AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
