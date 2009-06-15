Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 018656B0055
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:10 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/11] ext4: Make sure blocks are properly allocated under mmaped page even when blocksize < pagesize
Date: Mon, 15 Jun 2009 19:59:51 +0200
Message-Id: <1245088797-29533-5-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

In a situation like:
  truncate(f, 1024);
  a = mmap(f, 0, 4096);
  a[0] = 'a';
  truncate(f, 4096);

we end up with a dirty page which does not have all blocks allocated /
reserved.  Fix the problem by using new VFS infrastructure.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext4/extents.c |    2 +-
 fs/ext4/inode.c   |   20 ++++++++++++++++++--
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 2593f74..764c394 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -3073,7 +3073,7 @@ static void ext4_falloc_update_inode(struct inode *inode,
 	 */
 	if (!(mode & FALLOC_FL_KEEP_SIZE)) {
 		if (new_size > i_size_read(inode))
-			i_size_write(inode, new_size);
+			block_extend_i_size(inode, new_size, 0);
 		if (new_size > EXT4_I(inode)->i_disksize)
 			ext4_update_i_disksize(inode, new_size);
 	}
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 875db94..3cad61b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1478,7 +1478,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
  	index = pos >> PAGE_CACHE_SHIFT;
 	from = pos & (PAGE_CACHE_SIZE - 1);
 	to = from + len;
-
+	block_lock_hole_extend(inode, pos);
 retry:
 	handle = ext4_journal_start(inode, needed_blocks);
 	if (IS_ERR(handle)) {
@@ -1537,6 +1537,8 @@ retry:
 	if (ret == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
 		goto retry;
 out:
+	if (ret)
+		block_unlock_hole_extend(inode);
 	return ret;
 }
 
@@ -1735,6 +1737,7 @@ static int ext4_journalled_write_end(struct file *file,
 
 	unlock_page(page);
 	page_cache_release(page);
+	block_unlock_hole_extend(inode);
 	if (pos + len > inode->i_size)
 		/* if we have allocated more blocks and copied
 		 * less. We will have blocks allocated outside
@@ -2909,6 +2912,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 		   "dev %s ino %lu pos %llu len %u flags %u",
 		   inode->i_sb->s_id, inode->i_ino,
 		   (unsigned long long) pos, len, flags);
+	block_lock_hole_extend(inode, pos);
 retry:
 	/*
 	 * With delayed allocation, we don't log the i_disksize update
@@ -2951,6 +2955,8 @@ retry:
 	if (ret == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
 		goto retry;
 out:
+	if (ret)
+		block_unlock_hole_extend(inode);
 	return ret;
 }
 
@@ -3496,7 +3502,7 @@ static ssize_t ext4_direct_IO(int rw, struct kiocb *iocb,
 			loff_t end = offset + ret;
 			if (end > inode->i_size) {
 				ei->i_disksize = end;
-				i_size_write(inode, end);
+				block_extend_i_size(inode, offset, ret);
 				/*
 				 * We're going to return a positive `ret'
 				 * here due to non-zero-length I/O, so there's
@@ -3541,6 +3547,7 @@ static const struct address_space_operations ext4_ordered_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext4_write_begin,
 	.write_end		= ext4_ordered_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext4_bmap,
 	.invalidatepage		= ext4_invalidatepage,
 	.releasepage		= ext4_releasepage,
@@ -3556,6 +3563,7 @@ static const struct address_space_operations ext4_writeback_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext4_write_begin,
 	.write_end		= ext4_writeback_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext4_bmap,
 	.invalidatepage		= ext4_invalidatepage,
 	.releasepage		= ext4_releasepage,
@@ -3571,6 +3579,7 @@ static const struct address_space_operations ext4_journalled_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext4_write_begin,
 	.write_end		= ext4_journalled_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.set_page_dirty		= ext4_journalled_set_page_dirty,
 	.bmap			= ext4_bmap,
 	.invalidatepage		= ext4_invalidatepage,
@@ -3586,6 +3595,7 @@ static const struct address_space_operations ext4_da_aops = {
 	.sync_page		= block_sync_page,
 	.write_begin		= ext4_da_write_begin,
 	.write_end		= ext4_da_write_end,
+	.extend_i_size		= block_extend_i_size,
 	.bmap			= ext4_bmap,
 	.invalidatepage		= ext4_da_invalidatepage,
 	.releasepage		= ext4_releasepage,
@@ -5433,6 +5443,12 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct address_space *mapping = inode->i_mapping;
 
 	/*
+	 * Wait for extending of i_size, after this moment, next truncate /
+	 * write can create holes under us but they writeprotect our page so
+	 * we'll be called again to fill the hole.
+	 */
+	block_wait_on_hole_extend(inode, page_offset(page));
+	/*
 	 * Get i_alloc_sem to stop truncates messing with the inode. We cannot
 	 * get i_mutex because we are already holding mmap_sem.
 	 */
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
