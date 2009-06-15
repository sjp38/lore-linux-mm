Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D5A4C6B006A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 13:58:14 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 10/11] ext3: Implement delayed allocation on page_mkwrite time
Date: Mon, 15 Jun 2009 19:59:57 +0200
Message-Id: <1245088797-29533-11-git-send-email-jack@suse.cz>
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

We don't want to really allocate blocks on page_mkwrite() time because for
random writes via mmap it results is much more fragmented files. So just
reserve enough free blocks in page_mkwrite() and do the real allocation from
writepage().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/ext3/balloc.c           |   96 ++++++++++++++--------
 fs/ext3/ialloc.c           |    2 +-
 fs/ext3/inode.c            |  196 +++++++++++++++++++++++++++-----------------
 fs/ext3/resize.c           |    2 +-
 fs/ext3/super.c            |   42 ++++++----
 include/linux/ext3_fs.h    |    9 ++-
 include/linux/ext3_fs_i.h  |    1 +
 include/linux/ext3_fs_sb.h |    3 +-
 8 files changed, 219 insertions(+), 132 deletions(-)

diff --git a/fs/ext3/balloc.c b/fs/ext3/balloc.c
index 27967f9..0e294a1 100644
--- a/fs/ext3/balloc.c
+++ b/fs/ext3/balloc.c
@@ -19,6 +19,8 @@
 #include <linux/ext3_jbd.h>
 #include <linux/quotaops.h>
 #include <linux/buffer_head.h>
+#include <linux/delalloc_counter.h>
+#include <linux/writeback.h>
 
 /*
  * balloc.c contains the blocks allocation and deallocation routines
@@ -632,7 +634,7 @@ do_more:
 	spin_lock(sb_bgl_lock(sbi, block_group));
 	le16_add_cpu(&desc->bg_free_blocks_count, group_freed);
 	spin_unlock(sb_bgl_lock(sbi, block_group));
-	percpu_counter_add(&sbi->s_freeblocks_counter, count);
+	dac_free(&sbi->s_alloc_counter, count);
 
 	/* We dirtied the bitmap block */
 	BUFFER_TRACE(bitmap_bh, "dirtied bitmap block");
@@ -1410,23 +1412,19 @@ out:
 }
 
 /**
- * ext3_has_free_blocks()
- * @sbi:		in-core super block structure.
+ * ext3_free_blocks_limit()
+ * @sb:			super block
  *
  * Check if filesystem has at least 1 free block available for allocation.
  */
-static int ext3_has_free_blocks(struct ext3_sb_info *sbi)
+ext3_fsblk_t ext3_free_blocks_limit(struct super_block *sb)
 {
-	ext3_fsblk_t free_blocks, root_blocks;
+	struct ext3_sb_info *sbi = EXT3_SB(sb);
 
-	free_blocks = percpu_counter_read_positive(&sbi->s_freeblocks_counter);
-	root_blocks = le32_to_cpu(sbi->s_es->s_r_blocks_count);
-	if (free_blocks < root_blocks + 1 && !capable(CAP_SYS_RESOURCE) &&
-		sbi->s_resuid != current_fsuid() &&
-		(sbi->s_resgid == 0 || !in_group_p (sbi->s_resgid))) {
-		return 0;
-	}
-	return 1;
+	if (!capable(CAP_SYS_RESOURCE) && sbi->s_resuid != current_fsuid() &&
+	    (sbi->s_resgid == 0 || !in_group_p(sbi->s_resgid)))
+		return le32_to_cpu(sbi->s_es->s_r_blocks_count) + 1;
+	return 0;
 }
 
 /**
@@ -1443,12 +1441,23 @@ static int ext3_has_free_blocks(struct ext3_sb_info *sbi)
  */
 int ext3_should_retry_alloc(struct super_block *sb, int *retries)
 {
-	if (!ext3_has_free_blocks(EXT3_SB(sb)) || (*retries)++ > 3)
+	struct ext3_sb_info *sbi = EXT3_SB(sb);
+	ext3_fsblk_t free_blocks, limit, reserved_blocks;
+
+	free_blocks = dac_get_avail(&sbi->s_alloc_counter);
+	limit = ext3_free_blocks_limit(sb);
+	reserved_blocks = dac_get_reserved(&sbi->s_alloc_counter);
+	if (!free_blocks + reserved_blocks < limit || (*retries)++ > 3)
 		return 0;
 
 	jbd_debug(1, "%s: retrying operation after ENOSPC\n", sb->s_id);
-
-	return journal_force_commit_nested(EXT3_SB(sb)->s_journal);
+	/*
+	 * There's a chance commit will free some blocks and writeback can
+	 * write delayed blocks so that excessive reservation gets released.
+	 */
+	if (reserved_blocks)
+		wakeup_pdflush(0);
+	return journal_force_commit_nested(sbi->s_journal);
 }
 
 /**
@@ -1466,7 +1475,8 @@ int ext3_should_retry_alloc(struct super_block *sb, int *retries)
  *
  */
 ext3_fsblk_t ext3_new_blocks(handle_t *handle, struct inode *inode,
-			ext3_fsblk_t goal, unsigned long *count, int *errp)
+			ext3_fsblk_t goal, unsigned long *count,
+			unsigned int *reserved, int *errp)
 {
 	struct buffer_head *bitmap_bh = NULL;
 	struct buffer_head *gdp_bh;
@@ -1477,7 +1487,7 @@ ext3_fsblk_t ext3_new_blocks(handle_t *handle, struct inode *inode,
 	ext3_fsblk_t ret_block;		/* filesyetem-wide allocated block */
 	int bgi;			/* blockgroup iteration index */
 	int fatal = 0, err;
-	int performed_allocation = 0;
+	int got_quota = 0, got_space = 0;
 	ext3_grpblk_t free_blocks;	/* number of free blocks in a group */
 	struct super_block *sb;
 	struct ext3_group_desc *gdp;
@@ -1498,16 +1508,27 @@ ext3_fsblk_t ext3_new_blocks(handle_t *handle, struct inode *inode,
 		printk("ext3_new_block: nonexistent device");
 		return 0;
 	}
+	sbi = EXT3_SB(sb);
 
-	/*
-	 * Check quota for allocation of this block.
-	 */
-	if (vfs_dq_alloc_block(inode, num)) {
-		*errp = -EDQUOT;
-		return 0;
+	if (!*reserved) {
+		/*
+		 * Check quota for allocation of this block.
+		 */
+		if (vfs_dq_alloc_block(inode, num)) {
+			*errp = -EDQUOT;
+			goto out;
+		}
+		got_quota = 1;
+		if (dac_alloc(&sbi->s_alloc_counter, num,
+			      ext3_free_blocks_limit(sb)) < 0) {
+			*errp = -ENOSPC;
+			goto out;
+		}
+		got_space = 1;
+	} else {
+		WARN_ON(*reserved < num);
 	}
 
-	sbi = EXT3_SB(sb);
 	es = EXT3_SB(sb)->s_es;
 	ext3_debug("goal=%lu.\n", goal);
 	/*
@@ -1522,11 +1543,6 @@ ext3_fsblk_t ext3_new_blocks(handle_t *handle, struct inode *inode,
 	if (block_i && ((windowsz = block_i->rsv_window_node.rsv_goal_size) > 0))
 		my_rsv = &block_i->rsv_window_node;
 
-	if (!ext3_has_free_blocks(sbi)) {
-		*errp = -ENOSPC;
-		goto out;
-	}
-
 	/*
 	 * First, test whether the goal block is free.
 	 */
@@ -1650,8 +1666,6 @@ allocated:
 		goto retry_alloc;
 	}
 
-	performed_allocation = 1;
-
 #ifdef CONFIG_JBD_DEBUG
 	{
 		struct buffer_head *debug_bh;
@@ -1701,7 +1715,6 @@ allocated:
 	spin_lock(sb_bgl_lock(sbi, group_no));
 	le16_add_cpu(&gdp->bg_free_blocks_count, -num);
 	spin_unlock(sb_bgl_lock(sbi, group_no));
-	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
 	BUFFER_TRACE(gdp_bh, "journal_dirty_metadata for group descriptor");
 	err = ext3_journal_dirty_metadata(handle, gdp_bh);
@@ -1713,7 +1726,15 @@ allocated:
 
 	*errp = 0;
 	brelse(bitmap_bh);
-	vfs_dq_free_block(inode, *count-num);
+	if (*reserved) {
+		dac_alloc_reserved(&sbi->s_alloc_counter, num);
+		vfs_dq_claim_block(inode, num);
+		atomic_sub(num, &EXT3_I(inode)->i_reserved_blocks);
+		*reserved -= num;
+	} else {
+		dac_free(&sbi->s_alloc_counter, *count - num);
+		vfs_dq_free_block(inode, *count - num);
+	}
 	*count = num;
 	return ret_block;
 
@@ -1727,8 +1748,10 @@ out:
 	/*
 	 * Undo the block allocation
 	 */
-	if (!performed_allocation)
+	if (got_quota)
 		vfs_dq_free_block(inode, *count);
+	if (got_space)
+		dac_free(&sbi->s_alloc_counter, *count);
 	brelse(bitmap_bh);
 	return 0;
 }
@@ -1737,8 +1760,9 @@ ext3_fsblk_t ext3_new_block(handle_t *handle, struct inode *inode,
 			ext3_fsblk_t goal, int *errp)
 {
 	unsigned long count = 1;
+	unsigned int reserved = 0;
 
-	return ext3_new_blocks(handle, inode, goal, &count, errp);
+	return ext3_new_blocks(handle, inode, goal, &count, &reserved, errp);
 }
 
 /**
diff --git a/fs/ext3/ialloc.c b/fs/ext3/ialloc.c
index b399912..347e24c 100644
--- a/fs/ext3/ialloc.c
+++ b/fs/ext3/ialloc.c
@@ -269,7 +269,7 @@ static int find_group_orlov(struct super_block *sb, struct inode *parent)
 
 	freei = percpu_counter_read_positive(&sbi->s_freeinodes_counter);
 	avefreei = freei / ngroups;
-	freeb = percpu_counter_read_positive(&sbi->s_freeblocks_counter);
+	freeb = dac_get_avail(&sbi->s_alloc_counter);
 	avefreeb = freeb / ngroups;
 	ndirs = percpu_counter_read_positive(&sbi->s_dirs_counter);
 
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index ec112b4..cfec38b 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -38,6 +38,7 @@
 #include <linux/bio.h>
 #include <linux/fiemap.h>
 #include <linux/namei.h>
+#include <linux/mount.h>
 #include "xattr.h"
 #include "acl.h"
 
@@ -516,7 +517,8 @@ static int ext3_blks_to_allocate(Indirect *branch, int k, unsigned long blks,
  */
 static int ext3_alloc_blocks(handle_t *handle, struct inode *inode,
 			ext3_fsblk_t goal, int indirect_blks, int blks,
-			ext3_fsblk_t new_blocks[4], int *err)
+			unsigned int *reserved, ext3_fsblk_t new_blocks[4],
+			int *err)
 {
 	int target, i;
 	unsigned long count = 0;
@@ -537,7 +539,8 @@ static int ext3_alloc_blocks(handle_t *handle, struct inode *inode,
 	while (1) {
 		count = target;
 		/* allocating blocks for indirect blocks and direct blocks */
-		current_block = ext3_new_blocks(handle,inode,goal,&count,err);
+		current_block = ext3_new_blocks(handle, inode, goal, &count,
+						reserved, err);
 		if (*err)
 			goto failed_out;
 
@@ -591,8 +594,8 @@ failed_out:
  *	as described above and return 0.
  */
 static int ext3_alloc_branch(handle_t *handle, struct inode *inode,
-			int indirect_blks, int *blks, ext3_fsblk_t goal,
-			int *offsets, Indirect *branch)
+			int indirect_blks, int *blks, unsigned int *reserved,
+			ext3_fsblk_t goal, int *offsets, Indirect *branch)
 {
 	int blocksize = inode->i_sb->s_blocksize;
 	int i, n = 0;
@@ -603,7 +606,7 @@ static int ext3_alloc_branch(handle_t *handle, struct inode *inode,
 	ext3_fsblk_t current_block;
 
 	num = ext3_alloc_blocks(handle, inode, goal, indirect_blks,
-				*blks, new_blocks, &err);
+				*blks, reserved, new_blocks, &err);
 	if (err)
 		return err;
 
@@ -800,6 +803,7 @@ int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 	int depth;
 	struct ext3_inode_info *ei = EXT3_I(inode);
 	int count = 0;
+	unsigned int reserved = 0;
 	ext3_fsblk_t first_block = 0;
 
 
@@ -898,8 +902,24 @@ int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 	/*
 	 * Block out ext3_truncate while we alter the tree
 	 */
-	err = ext3_alloc_branch(handle, inode, indirect_blks, &count, goal,
-				offsets + (partial - chain), partial);
+	if (buffer_delay(bh_result)) {
+		WARN_ON(maxblocks != 1);
+		WARN_ON(!bh_result->b_page || !PageLocked(bh_result->b_page));
+		reserved = EXT3_DA_BLOCK_RESERVE;
+	}
+	err = ext3_alloc_branch(handle, inode, indirect_blks, &count,
+				&reserved, goal, offsets + (partial - chain),
+				partial);
+	/* Release additional reservation we had for this block */
+	if (!err && buffer_delay(bh_result)) {
+		dac_cancel_reserved(&EXT3_SB(inode->i_sb)->s_alloc_counter,
+				    reserved);
+		vfs_dq_release_reservation_block(inode, reserved);
+		atomic_sub(reserved, &ei->i_reserved_blocks);
+		clear_buffer_delay(bh_result);
+	} else if (!err) {
+		set_buffer_new(bh_result);
+	}
 
 	/*
 	 * The ext3_splice_branch call will free and forget any buffers
@@ -914,8 +934,6 @@ int ext3_get_blocks_handle(handle_t *handle, struct inode *inode,
 	mutex_unlock(&ei->truncate_mutex);
 	if (err)
 		goto cleanup;
-
-	set_buffer_new(bh_result);
 got_it:
 	map_bh(bh_result, inode->i_sb, le32_to_cpu(chain[depth-1].key));
 	if (count > blocks_to_boundary)
@@ -1432,9 +1450,9 @@ static sector_t ext3_bmap(struct address_space *mapping, sector_t block)
 	return generic_block_bmap(mapping,block,ext3_get_block);
 }
 
-static int buffer_unmapped(handle_t *handle, struct buffer_head *bh)
+static int ext3_bh_delay(handle_t *handle, struct buffer_head *bh)
 {
-	return !buffer_mapped(bh);
+	return buffer_delay(bh);
 }
 
 /*
@@ -1496,12 +1514,31 @@ static int ext3_common_writepage(struct page *page,
 				struct writeback_control *wbc)
 {
 	struct inode *inode = page->mapping->host;
-	int ret = 0;
+	int ret = 0, delay = 1, err;
+	handle_t *handle = NULL;
 
+	/* Start a transaction only if the page has delayed buffers */
+	if (page_has_buffers(page))
+		delay = walk_page_buffers(NULL, page_buffers(page), 0,
+				PAGE_CACHE_SIZE, NULL, ext3_bh_delay);
+	if (delay) {
+		handle = ext3_journal_start(inode,
+				ext3_writepage_trans_blocks(inode));
+		if (IS_ERR(handle)) {
+			ret = PTR_ERR(handle);
+			goto out;
+		}
+	}
 	if (test_opt(inode->i_sb, NOBH) && ext3_should_writeback_data(inode))
 		ret = nobh_writepage(page, ext3_get_block, wbc);
 	else
 		ret = block_write_full_page(page, ext3_get_block, wbc);
+	if (delay) {
+		err = ext3_journal_stop(handle);
+		if (!ret)
+			ret = err;
+	}
+out:
 	return ret;
 }
 
@@ -1576,15 +1613,37 @@ ext3_readpages(struct file *file, struct address_space *mapping,
 	return mpage_readpages(mapping, pages, nr_pages, ext3_get_block);
 }
 
+
+static int truncate_delayed_bh(handle_t *handle, struct buffer_head *bh)
+{
+	if (buffer_delay(bh)) {
+		struct inode *inode = bh->b_page->mapping->host;
+		struct ext3_inode_info *ei = EXT3_I(inode);
+
+		atomic_sub(EXT3_DA_BLOCK_RESERVE, &ei->i_reserved_blocks);
+		vfs_dq_release_reservation_block(inode, EXT3_DA_BLOCK_RESERVE);
+		dac_cancel_reserved(&EXT3_SB(inode->i_sb)->s_alloc_counter,
+				    EXT3_DA_BLOCK_RESERVE);
+		clear_buffer_delay(bh);
+	}
+	return 0;
+}
+
 static void ext3_invalidatepage(struct page *page, unsigned long offset)
 {
-	journal_t *journal = EXT3_JOURNAL(page->mapping->host);
+	struct inode *inode = page->mapping->host;
+	journal_t *journal = EXT3_JOURNAL(inode);
+	int bsize = 1 << inode->i_blkbits;
 
 	/*
 	 * If it's a full truncate we just forget about the pending dirtying
 	 */
 	if (offset == 0)
 		ClearPageChecked(page);
+	if (page_has_buffers(page)) {
+		walk_page_buffers(NULL, page_buffers(page), offset + bsize - 1,
+				  PAGE_CACHE_SIZE, NULL, truncate_delayed_bh);
+	}
 
 	journal_invalidatepage(journal, page, offset);
 }
@@ -1685,75 +1744,58 @@ out:
 	return ret;
 }
 
-int ext3_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+/*
+ * Reserve block writes instead of allocation. Called only on buffer heads
+ * attached to a page (and thus for 1 block).
+ */
+static int ext3_da_get_block(struct inode *inode, sector_t iblock,
+			     struct buffer_head *bh, int create)
 {
-	struct page *page = vmf->page;
-	struct file *file = vma->vm_file;
-	struct address_space *mapping = file->f_mapping;
-	struct inode *inode = file->f_path.dentry->d_inode;
-	int ret = VM_FAULT_NOPAGE;
-	loff_t size;
-	int len;
-	void *fsdata;
-
-	block_wait_on_hole_extend(inode, page_offset(page));
-	/*
-	 * Get i_alloc_sem to stop truncates messing with the inode. We cannot
-	 * get i_mutex because we are already holding mmap_sem.
-	 */
-	down_read(&inode->i_alloc_sem);
-	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
-	    (page_offset(page) > size)) {
-		/* page got truncated out from underneath us */
-		goto out_unlock;
-	}
-
-	/* page is wholly or partially inside EOF */
-	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
-		len = size & ~PAGE_CACHE_MASK;
-	else
-		len = PAGE_CACHE_SIZE;
+	int ret, rsv;
+	struct ext3_sb_info *sbi;
 
-	/*
-	 * Check for the common case that everything is already mapped. We
-	 * have to get the page lock so that buffers cannot be released
-	 * under us.
-	 */
-	lock_page(page);
-	if (page_has_buffers(page)) {
-		if (!walk_page_buffers(NULL, page_buffers(page), 0, len, NULL,
-				       buffer_unmapped)) {
-			unlock_page(page);
-			ret = 0;
-			goto out_unlock;
-		}
-	}
-	unlock_page(page);
+	/* Buffer has already blocks reserved? */
+	if (buffer_delay(bh))
+		return 0;
 
-	/*
-	 * OK, we may need to fill the hole... Do write_begin write_end to do
-	 * block allocation/reservation. We are not holding inode.i_mutex
-	 * here. That allows parallel write_begin, write_end call. lock_page
-	 * prevent this from happening on the same page though.
-	 */
-	ret = mapping->a_ops->write_begin(file, mapping, page_offset(page),
-			len, AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+	ret = ext3_get_blocks_handle(NULL, inode, iblock, 1, bh, 0);
 	if (ret < 0)
-		goto out_unlock;
-	ret = mapping->a_ops->write_end(file, mapping, page_offset(page),
-			len, len, page, fsdata);
-	if (ret < 0)
-		goto out_unlock;
-	ret = 0;
-out_unlock:
-	if (unlikely(ret)) {
-		if (ret == -ENOMEM)
-			ret = VM_FAULT_OOM;
-		else /* -ENOSPC, -EIO, etc */
-			ret = VM_FAULT_SIGBUS;
+		goto out;
+	if (ret > 0 || !create) {
+		ret = 0;
+		goto out;
+	}
+	/* Upperbound on number of needed blocks */
+	rsv = EXT3_DA_BLOCK_RESERVE;
+	/* Delayed allocation needed */
+	if (vfs_dq_reserve_block(inode, rsv)) {
+		ret = -EDQUOT;
+		goto out;
+	}
+	sbi = EXT3_SB(inode->i_sb);
+	ret = dac_reserve(&sbi->s_alloc_counter, rsv,
+			  ext3_free_blocks_limit(inode->i_sb));
+	if (ret < 0) {
+		vfs_dq_release_reservation_block(inode, rsv);
+		goto out;
 	}
-	up_read(&inode->i_alloc_sem);
+	set_buffer_delay(bh);
+	set_buffer_new(bh);
+	atomic_add(rsv, &EXT3_I(inode)->i_reserved_blocks);
+out:
+	return ret;
+}
+
+int ext3_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	int retry = 0;
+	int ret;
+	struct super_block *sb = vma->vm_file->f_path.mnt->mnt_sb;
+
+	do {
+		ret = block_page_mkwrite(vma, vmf, ext3_da_get_block);
+	} while (ret == VM_FAULT_SIGBUS &&
+		 ext3_should_retry_alloc(sb, &retry));
 	return ret;
 }
 
diff --git a/fs/ext3/resize.c b/fs/ext3/resize.c
index 8a0b263..2f6688a 100644
--- a/fs/ext3/resize.c
+++ b/fs/ext3/resize.c
@@ -928,7 +928,7 @@ int ext3_group_add(struct super_block *sb, struct ext3_new_group_data *input)
 	le32_add_cpu(&es->s_r_blocks_count, input->reserved_blocks);
 
 	/* Update the free space counts */
-	percpu_counter_add(&sbi->s_freeblocks_counter,
+	percpu_counter_add(&sbi->s_alloc_counter.free,
 			   input->free_blocks_count);
 	percpu_counter_add(&sbi->s_freeinodes_counter,
 			   EXT3_INODES_PER_GROUP(sb));
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index 26aa64d..036e953 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -417,7 +417,7 @@ static void ext3_put_super (struct super_block * sb)
 	for (i = 0; i < sbi->s_gdb_count; i++)
 		brelse(sbi->s_group_desc[i]);
 	kfree(sbi->s_group_desc);
-	percpu_counter_destroy(&sbi->s_freeblocks_counter);
+	dac_destroy(&sbi->s_alloc_counter);
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
 	brelse(sbi->s_sbh);
@@ -494,6 +494,7 @@ static void init_once(void *foo)
 #ifdef CONFIG_EXT3_FS_XATTR
 	init_rwsem(&ei->xattr_sem);
 #endif
+	atomic_set(&ei->i_reserved_blocks, 0);
 	mutex_init(&ei->truncate_mutex);
 	inode_init_once(&ei->vfs_inode);
 }
@@ -517,23 +518,26 @@ static void destroy_inodecache(void)
 
 static void ext3_clear_inode(struct inode *inode)
 {
-	struct ext3_block_alloc_info *rsv = EXT3_I(inode)->i_block_alloc_info;
+	struct ext3_inode_info *ei = EXT3_I(inode);
+	struct ext3_block_alloc_info *rsv = ei->i_block_alloc_info;
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
-	if (EXT3_I(inode)->i_acl &&
-			EXT3_I(inode)->i_acl != EXT3_ACL_NOT_CACHED) {
-		posix_acl_release(EXT3_I(inode)->i_acl);
-		EXT3_I(inode)->i_acl = EXT3_ACL_NOT_CACHED;
+	if (ei->i_acl && ei->i_acl != EXT3_ACL_NOT_CACHED) {
+		posix_acl_release(ei->i_acl);
+		ei->i_acl = EXT3_ACL_NOT_CACHED;
 	}
-	if (EXT3_I(inode)->i_default_acl &&
-			EXT3_I(inode)->i_default_acl != EXT3_ACL_NOT_CACHED) {
-		posix_acl_release(EXT3_I(inode)->i_default_acl);
-		EXT3_I(inode)->i_default_acl = EXT3_ACL_NOT_CACHED;
+	if (ei->i_default_acl && ei->i_default_acl != EXT3_ACL_NOT_CACHED) {
+		posix_acl_release(ei->i_default_acl);
+		ei->i_default_acl = EXT3_ACL_NOT_CACHED;
 	}
 #endif
 	ext3_discard_reservation(inode);
-	EXT3_I(inode)->i_block_alloc_info = NULL;
+	ei->i_block_alloc_info = NULL;
 	if (unlikely(rsv))
 		kfree(rsv);
+	if (atomic_read(&ei->i_reserved_blocks))
+		ext3_warning(inode->i_sb, __func__, "Releasing inode %lu with "
+			"%lu reserved blocks.\n", inode->i_ino,
+			(unsigned long)atomic_read(&ei->i_reserved_blocks));
 }
 
 static inline void ext3_show_quota_options(struct seq_file *seq, struct super_block *sb)
@@ -728,10 +732,19 @@ static ssize_t ext3_quota_read(struct super_block *sb, int type, char *data,
 static ssize_t ext3_quota_write(struct super_block *sb, int type,
 				const char *data, size_t len, loff_t off);
 
+static qsize_t ext3_get_reserved_space(struct inode *inode)
+{
+	return atomic_read(&EXT3_I(inode)->i_reserved_blocks);
+}
+
 static struct dquot_operations ext3_quota_operations = {
 	.initialize	= dquot_initialize,
 	.drop		= dquot_drop,
 	.alloc_space	= dquot_alloc_space,
+	.reserve_space	= dquot_reserve_space,
+	.claim_space	= dquot_claim_space,
+	.release_rsv	= dquot_release_reserved_space,
+	.get_reserved_space = ext3_get_reserved_space,
 	.alloc_inode	= dquot_alloc_inode,
 	.free_space	= dquot_free_space,
 	.free_inode	= dquot_free_inode,
@@ -1851,8 +1864,7 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
 	get_random_bytes(&sbi->s_next_generation, sizeof(u32));
 	spin_lock_init(&sbi->s_next_gen_lock);
 
-	err = percpu_counter_init(&sbi->s_freeblocks_counter,
-			ext3_count_free_blocks(sb));
+	err = dac_init(&sbi->s_alloc_counter, ext3_count_free_blocks(sb));
 	if (!err) {
 		err = percpu_counter_init(&sbi->s_freeinodes_counter,
 				ext3_count_free_inodes(sb));
@@ -2005,7 +2017,7 @@ cantfind_ext3:
 failed_mount4:
 	journal_destroy(sbi->s_journal);
 failed_mount3:
-	percpu_counter_destroy(&sbi->s_freeblocks_counter);
+	dac_destroy(&sbi->s_alloc_counter);
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
 failed_mount2:
@@ -2674,7 +2686,7 @@ static int ext3_statfs (struct dentry * dentry, struct kstatfs * buf)
 	buf->f_type = EXT3_SUPER_MAGIC;
 	buf->f_bsize = sb->s_blocksize;
 	buf->f_blocks = le32_to_cpu(es->s_blocks_count) - sbi->s_overhead_last;
-	buf->f_bfree = percpu_counter_sum_positive(&sbi->s_freeblocks_counter);
+	buf->f_bfree = dac_get_avail_sum(&sbi->s_alloc_counter);
 	es->s_free_blocks_count = cpu_to_le32(buf->f_bfree);
 	buf->f_bavail = buf->f_bfree - le32_to_cpu(es->s_r_blocks_count);
 	if (buf->f_bfree < le32_to_cpu(es->s_r_blocks_count))
diff --git a/include/linux/ext3_fs.h b/include/linux/ext3_fs.h
index 5051874..7f28907 100644
--- a/include/linux/ext3_fs.h
+++ b/include/linux/ext3_fs.h
@@ -809,6 +809,11 @@ ext3_group_first_block_no(struct super_block *sb, unsigned long group_no)
 #define ERR_BAD_DX_DIR	-75000
 
 /*
+ * Number of blocks we reserve in delayed allocation for one block
+ */
+#define EXT3_DA_BLOCK_RESERVE 4
+
+/*
  * Function prototypes
  */
 
@@ -821,12 +826,14 @@ ext3_group_first_block_no(struct super_block *sb, unsigned long group_no)
 # define NORET_AND     noreturn,
 
 /* balloc.c */
+extern ext3_fsblk_t ext3_free_blocks_limit(struct super_block *sb);
 extern int ext3_bg_has_super(struct super_block *sb, int group);
 extern unsigned long ext3_bg_num_gdb(struct super_block *sb, int group);
 extern ext3_fsblk_t ext3_new_block (handle_t *handle, struct inode *inode,
 			ext3_fsblk_t goal, int *errp);
 extern ext3_fsblk_t ext3_new_blocks (handle_t *handle, struct inode *inode,
-			ext3_fsblk_t goal, unsigned long *count, int *errp);
+			ext3_fsblk_t goal, unsigned long *count,
+			unsigned int *reserved, int *errp);
 extern void ext3_free_blocks (handle_t *handle, struct inode *inode,
 			ext3_fsblk_t block, unsigned long count);
 extern void ext3_free_blocks_sb (handle_t *handle, struct super_block *sb,
diff --git a/include/linux/ext3_fs_i.h b/include/linux/ext3_fs_i.h
index 7894dd0..ef288bd 100644
--- a/include/linux/ext3_fs_i.h
+++ b/include/linux/ext3_fs_i.h
@@ -129,6 +129,7 @@ struct ext3_inode_info {
 
 	/* on-disk additional length */
 	__u16 i_extra_isize;
+	atomic_t i_reserved_blocks;
 
 	/*
 	 * truncate_mutex is for serialising ext3_truncate() against
diff --git a/include/linux/ext3_fs_sb.h b/include/linux/ext3_fs_sb.h
index f07f34d..f92e162 100644
--- a/include/linux/ext3_fs_sb.h
+++ b/include/linux/ext3_fs_sb.h
@@ -21,6 +21,7 @@
 #include <linux/wait.h>
 #include <linux/blockgroup_lock.h>
 #include <linux/percpu_counter.h>
+#include <linux/delalloc_counter.h>
 #endif
 #include <linux/rbtree.h>
 
@@ -58,7 +59,7 @@ struct ext3_sb_info {
 	u32 s_hash_seed[4];
 	int s_def_hash_version;
 	int s_hash_unsigned;	/* 3 if hash should be signed, 0 if not */
-	struct percpu_counter s_freeblocks_counter;
+	struct delalloc_counter s_alloc_counter;
 	struct percpu_counter s_freeinodes_counter;
 	struct percpu_counter s_dirs_counter;
 	struct blockgroup_lock *s_blockgroup_lock;
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
