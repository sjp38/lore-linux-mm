Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2F96B004F
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:43:03 -0500 (EST)
Date: Sat, 28 Feb 2009 12:42:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 4/5] ext2: fsblock "quick" conversion
Message-ID: <20090228114255.GH28496@wotan.suse.de>
References: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228112858.GD28496@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>

Quick because it uses ->data pointer. Otherwise it is more complete than
the minix conversion because it implements fsb_extentmap but minix doesn't.

---
 fs/ext2/balloc.c           |  173 ++++++++++++----------
 fs/ext2/dir.c              |    8 -
 fs/ext2/ext2.h             |   11 -
 fs/ext2/file.c             |   16 +-
 fs/ext2/fsync.c            |    4 
 fs/ext2/ialloc.c           |   81 +++++-----
 fs/ext2/inode.c            |  348 ++++++++++++++++++++++++---------------------
 fs/ext2/namei.c            |   13 -
 fs/ext2/super.c            |  163 +++++----------------
 fs/ext2/xattr.c            |  144 +++++++++---------
 fs/ext2/xip.c              |   14 -
 include/linux/ext2_fs_sb.h |    6 
 12 files changed, 483 insertions(+), 498 deletions(-)

Index: linux-2.6/fs/ext2/file.c
===================================================================
--- linux-2.6.orig/fs/ext2/file.c
+++ linux-2.6/fs/ext2/file.c
@@ -38,6 +38,18 @@ static int ext2_release_file (struct ino
 	return 0;
 }
 
+static struct vm_operations_struct ext2_file_vm_ops = {
+	.fault          = filemap_fault,
+	.page_mkwrite   = ext2_page_mkwrite,
+};
+
+static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	file_accessed(file);
+	vma->vm_ops = &ext2_file_vm_ops;
+	return 0;
+}
+
 /*
  * We have mostly NULL's here: the current defaults are ok for
  * the ext2 filesystem.
@@ -52,7 +64,7 @@ const struct file_operations ext2_file_o
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
-	.mmap		= generic_file_mmap,
+	.mmap		= ext2_file_mmap,
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_sync_file,
@@ -86,5 +98,5 @@ const struct inode_operations ext2_file_
 #endif
 	.setattr	= ext2_setattr,
 	.permission	= ext2_permission,
-	.fiemap		= ext2_fiemap,
+//	.fiemap		= ext2_fiemap,
 };
Index: linux-2.6/fs/ext2/namei.c
===================================================================
--- linux-2.6.orig/fs/ext2/namei.c
+++ linux-2.6/fs/ext2/namei.c
@@ -98,9 +98,6 @@ static int ext2_create (struct inode * d
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
-		} else if (test_opt(inode->i_sb, NOBH)) {
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
 			inode->i_fop = &ext2_file_operations;
@@ -151,10 +148,7 @@ static int ext2_symlink (struct inode *
 	if (l > sizeof (EXT2_I(inode)->i_data)) {
 		/* slow symlink */
 		inode->i_op = &ext2_symlink_inode_operations;
-		if (test_opt(inode->i_sb, NOBH))
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-		else
-			inode->i_mapping->a_ops = &ext2_aops;
+		inode->i_mapping->a_ops = &ext2_aops;
 		err = page_symlink(inode, symname, l);
 		if (err)
 			goto out_fail;
@@ -217,10 +211,7 @@ static int ext2_mkdir(struct inode * dir
 
 	inode->i_op = &ext2_dir_inode_operations;
 	inode->i_fop = &ext2_dir_operations;
-	if (test_opt(inode->i_sb, NOBH))
-		inode->i_mapping->a_ops = &ext2_nobh_aops;
-	else
-		inode->i_mapping->a_ops = &ext2_aops;
+	inode->i_mapping->a_ops = &ext2_aops;
 
 	inode_inc_link_count(inode);
 
Index: linux-2.6/fs/ext2/balloc.c
===================================================================
--- linux-2.6.orig/fs/ext2/balloc.c
+++ linux-2.6/fs/ext2/balloc.c
@@ -14,7 +14,7 @@
 #include "ext2.h"
 #include <linux/quotaops.h>
 #include <linux/sched.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/capability.h>
 
 /*
@@ -37,7 +37,7 @@
 
 struct ext2_group_desc * ext2_get_group_desc(struct super_block * sb,
 					     unsigned int block_group,
-					     struct buffer_head ** bh)
+					     struct fsblock_meta ** mb)
 {
 	unsigned long group_desc;
 	unsigned long offset;
@@ -63,16 +63,16 @@ struct ext2_group_desc * ext2_get_group_
 		return NULL;
 	}
 
-	desc = (struct ext2_group_desc *) sbi->s_group_desc[group_desc]->b_data;
-	if (bh)
-		*bh = sbi->s_group_desc[group_desc];
+	desc = (struct ext2_group_desc *) sbi->s_group_desc[group_desc]->data;
+	if (mb)
+		*mb = sbi->s_group_desc[group_desc];
 	return desc + offset;
 }
 
 static int ext2_valid_block_bitmap(struct super_block *sb,
 					struct ext2_group_desc *desc,
 					unsigned int block_group,
-					struct buffer_head *bh)
+					struct fsblock_meta *mb)
 {
 	ext2_grpblk_t offset;
 	ext2_grpblk_t next_zero_bit;
@@ -84,21 +84,21 @@ static int ext2_valid_block_bitmap(struc
 	/* check whether block bitmap block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_block_bitmap);
 	offset = bitmap_blk - group_first_block;
-	if (!ext2_test_bit(offset, bh->b_data))
+	if (!ext2_test_bit(offset, mb->data))
 		/* bad block bitmap */
 		goto err_out;
 
 	/* check whether the inode bitmap block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_inode_bitmap);
 	offset = bitmap_blk - group_first_block;
-	if (!ext2_test_bit(offset, bh->b_data))
+	if (!ext2_test_bit(offset, mb->data))
 		/* bad block bitmap */
 		goto err_out;
 
 	/* check whether the inode table block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_inode_table);
 	offset = bitmap_blk - group_first_block;
-	next_zero_bit = ext2_find_next_zero_bit(bh->b_data,
+	next_zero_bit = ext2_find_next_zero_bit(mb->data,
 				offset + EXT2_SB(sb)->s_itb_per_group,
 				offset);
 	if (next_zero_bit >= offset + EXT2_SB(sb)->s_itb_per_group)
@@ -117,32 +117,38 @@ err_out:
  * Read the bitmap for a given block_group,and validate the
  * bits for block/inode/inode tables are set in the bitmaps
  *
- * Return buffer_head on success or NULL in case of failure.
+ * Return fsblock_meta on success or NULL in case of failure.
  */
-static struct buffer_head *
+static struct fsblock_meta *
 read_block_bitmap(struct super_block *sb, unsigned int block_group)
 {
 	struct ext2_group_desc * desc;
-	struct buffer_head * bh = NULL;
+	struct fsblock_meta * mb = NULL;
 	ext2_fsblk_t bitmap_blk;
 
 	desc = ext2_get_group_desc(sb, block_group, NULL);
 	if (!desc)
 		return NULL;
 	bitmap_blk = le32_to_cpu(desc->bg_block_bitmap);
-	bh = sb_getblk(sb, bitmap_blk);
-	if (unlikely(!bh)) {
+	mb = sb_find_or_create_mblock(&EXT2_SB(sb)->fsb_sb, bitmap_blk);
+	if (unlikely(!mb)) {
 		ext2_error(sb, __func__,
 			    "Cannot read block bitmap - "
 			    "block_group = %d, block_bitmap = %u",
 			    block_group, le32_to_cpu(desc->bg_block_bitmap));
 		return NULL;
 	}
-	if (likely(bh_uptodate_or_lock(bh)))
-		return bh;
+	if (likely(mb->block.flags & BL_uptodate))
+		return mb;
+	lock_block(mb); /* XXX: may not need to lock */
+	if (likely(mb->block.flags & BL_uptodate)) {
+		unlock_block(mb);
+		return mb;
+	}
 
-	if (bh_submit_read(bh) < 0) {
-		brelse(bh);
+	if (mblock_read_sync(mb) < 0) {
+		unlock_block(mb);
+		block_put(mb);
 		ext2_error(sb, __func__,
 			    "Cannot read block bitmap - "
 			    "block_group = %d, block_bitmap = %u",
@@ -150,12 +156,13 @@ read_block_bitmap(struct super_block *sb
 		return NULL;
 	}
 
-	ext2_valid_block_bitmap(sb, desc, block_group, bh);
+	unlock_block(mb);
+	ext2_valid_block_bitmap(sb, desc, block_group, mb);
 	/*
 	 * file system mounted not to panic on error, continue with corrupt
 	 * bitmap
 	 */
-	return bh;
+	return mb;
 }
 
 static void release_blocks(struct super_block *sb, int count)
@@ -169,7 +176,7 @@ static void release_blocks(struct super_
 }
 
 static void group_adjust_blocks(struct super_block *sb, int group_no,
-	struct ext2_group_desc *desc, struct buffer_head *bh, int count)
+	struct ext2_group_desc *desc, struct fsblock_meta *mb, int count)
 {
 	if (count) {
 		struct ext2_sb_info *sbi = EXT2_SB(sb);
@@ -180,7 +187,7 @@ static void group_adjust_blocks(struct s
 		desc->bg_free_blocks_count = cpu_to_le16(free_blocks + count);
 		spin_unlock(sb_bgl_lock(sbi, group_no));
 		sb->s_dirt = 1;
-		mark_buffer_dirty(bh);
+		mark_mblock_dirty(mb);
 	}
 }
 
@@ -486,8 +493,8 @@ void ext2_discard_reservation(struct ino
 void ext2_free_blocks (struct inode * inode, unsigned long block,
 		       unsigned long count)
 {
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head * bh2;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *mb;
 	unsigned long block_group;
 	unsigned long bit;
 	unsigned long i;
@@ -506,6 +513,8 @@ void ext2_free_blocks (struct inode * in
 			    "block = %lu, count = %lu", block, count);
 		goto error_return;
 	}
+	for (i = 0; i < count; i++)
+		fbd_discard_block(inode->i_mapping, block + i);
 
 	ext2_debug ("freeing block(s) %lu-%lu\n", block, block + count - 1);
 
@@ -523,12 +532,13 @@ do_more:
 		overflow = bit + count - EXT2_BLOCKS_PER_GROUP(sb);
 		count -= overflow;
 	}
-	brelse(bitmap_bh);
-	bitmap_bh = read_block_bitmap(sb, block_group);
-	if (!bitmap_bh)
+	if (bitmap_mb)
+		block_put(bitmap_mb);
+	bitmap_mb = read_block_bitmap(sb, block_group);
+	if (!bitmap_mb)
 		goto error_return;
 
-	desc = ext2_get_group_desc (sb, block_group, &bh2);
+	desc = ext2_get_group_desc (sb, block_group, &mb);
 	if (!desc)
 		goto error_return;
 
@@ -547,7 +557,7 @@ do_more:
 
 	for (i = 0, group_freed = 0; i < count; i++) {
 		if (!ext2_clear_bit_atomic(sb_bgl_lock(sbi, block_group),
-						bit + i, bitmap_bh->b_data)) {
+						bit + i, bitmap_mb->data)) {
 			ext2_error(sb, __func__,
 				"bit already cleared for block %lu", block + i);
 		} else {
@@ -555,11 +565,11 @@ do_more:
 		}
 	}
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 
-	group_adjust_blocks(sb, block_group, desc, bh2, group_freed);
+	group_adjust_blocks(sb, block_group, desc, mb, group_freed);
 	freed += group_freed;
 
 	if (overflow) {
@@ -568,7 +578,8 @@ do_more:
 		goto do_more;
 	}
 error_return:
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	release_blocks(sb, freed);
 	DQUOT_FREE_BLOCK(inode, freed);
 }
@@ -576,19 +587,19 @@ error_return:
 /**
  * bitmap_search_next_usable_block()
  * @start:		the starting block (group relative) of the search
- * @bh:			bufferhead contains the block group bitmap
+ * @mb:			fsblock_meta contains the block group bitmap
  * @maxblocks:		the ending block (group relative) of the reservation
  *
  * The bitmap search --- search forward through the actual bitmap on disk until
  * we find a bit free.
  */
 static ext2_grpblk_t
-bitmap_search_next_usable_block(ext2_grpblk_t start, struct buffer_head *bh,
+bitmap_search_next_usable_block(ext2_grpblk_t start, struct fsblock_meta *mb,
 					ext2_grpblk_t maxblocks)
 {
 	ext2_grpblk_t next;
 
-	next = ext2_find_next_zero_bit(bh->b_data, maxblocks, start);
+	next = ext2_find_next_zero_bit(mb->data, maxblocks, start);
 	if (next >= maxblocks)
 		return -1;
 	return next;
@@ -598,7 +609,7 @@ bitmap_search_next_usable_block(ext2_grp
  * find_next_usable_block()
  * @start:		the starting block (group relative) to find next
  * 			allocatable block in bitmap.
- * @bh:			bufferhead contains the block group bitmap
+ * @mb:			fsblock_meta contains the block group bitmap
  * @maxblocks:		the ending block (group relative) for the search
  *
  * Find an allocatable block in a bitmap.  We perform the "most
@@ -607,7 +618,7 @@ bitmap_search_next_usable_block(ext2_grp
  * then for any free bit in the bitmap.
  */
 static ext2_grpblk_t
-find_next_usable_block(int start, struct buffer_head *bh, int maxblocks)
+find_next_usable_block(int start, struct fsblock_meta *mb, int maxblocks)
 {
 	ext2_grpblk_t here, next;
 	char *p, *r;
@@ -624,7 +635,7 @@ find_next_usable_block(int start, struct
 		ext2_grpblk_t end_goal = (start + 63) & ~63;
 		if (end_goal > maxblocks)
 			end_goal = maxblocks;
-		here = ext2_find_next_zero_bit(bh->b_data, end_goal, start);
+		here = ext2_find_next_zero_bit(mb->data, end_goal, start);
 		if (here < end_goal)
 			return here;
 		ext2_debug("Bit not found near goal\n");
@@ -634,14 +645,14 @@ find_next_usable_block(int start, struct
 	if (here < 0)
 		here = 0;
 
-	p = ((char *)bh->b_data) + (here >> 3);
+	p = ((char *)mb->data) + (here >> 3);
 	r = memscan(p, 0, ((maxblocks + 7) >> 3) - (here >> 3));
-	next = (r - ((char *)bh->b_data)) << 3;
+	next = (r - ((char *)mb->data)) << 3;
 
 	if (next < maxblocks && next >= here)
 		return next;
 
-	here = bitmap_search_next_usable_block(here, bh, maxblocks);
+	here = bitmap_search_next_usable_block(here, mb, maxblocks);
 	return here;
 }
 
@@ -650,7 +661,7 @@ find_next_usable_block(int start, struct
  * @sb:			superblock
  * @handle:		handle to this transaction
  * @group:		given allocation block group
- * @bitmap_bh:		bufferhead holds the block bitmap
+ * @bitmap_mb:		fsblock_meta holds the block bitmap
  * @grp_goal:		given target block within the group
  * @count:		target number of blocks to allocate
  * @my_rsv:		reservation window
@@ -670,7 +681,7 @@ find_next_usable_block(int start, struct
  */
 static int
 ext2_try_to_allocate(struct super_block *sb, int group,
-			struct buffer_head *bitmap_bh, ext2_grpblk_t grp_goal,
+			struct fsblock_meta *bitmap_mb, ext2_grpblk_t grp_goal,
 			unsigned long *count,
 			struct ext2_reserve_window *my_rsv)
 {
@@ -706,7 +717,7 @@ ext2_try_to_allocate(struct super_block
 
 repeat:
 	if (grp_goal < 0) {
-		grp_goal = find_next_usable_block(start, bitmap_bh, end);
+		grp_goal = find_next_usable_block(start, bitmap_mb, end);
 		if (grp_goal < 0)
 			goto fail_access;
 		if (!my_rsv) {
@@ -714,7 +725,7 @@ repeat:
 
 			for (i = 0; i < 7 && grp_goal > start &&
 					!ext2_test_bit(grp_goal - 1,
-					     		bitmap_bh->b_data);
+					     		bitmap_mb->data);
 			     		i++, grp_goal--)
 				;
 		}
@@ -722,7 +733,7 @@ repeat:
 	start = grp_goal;
 
 	if (ext2_set_bit_atomic(sb_bgl_lock(EXT2_SB(sb), group), grp_goal,
-			       				bitmap_bh->b_data)) {
+			       				bitmap_mb->data)) {
 		/*
 		 * The block was allocated by another thread, or it was
 		 * allocated and then freed by another thread
@@ -737,7 +748,7 @@ repeat:
 	grp_goal++;
 	while (num < *count && grp_goal < end
 		&& !ext2_set_bit_atomic(sb_bgl_lock(EXT2_SB(sb), group),
-					grp_goal, bitmap_bh->b_data)) {
+					grp_goal, bitmap_mb->data)) {
 		num++;
 		grp_goal++;
 	}
@@ -900,12 +911,12 @@ static int find_next_reservable_window(
  *
  *	@sb: the super block
  *	@group: the group we are trying to allocate in
- *	@bitmap_bh: the block group block bitmap
+ *	@bitmap_mb: the block group block bitmap
  *
  */
 static int alloc_new_reservation(struct ext2_reserve_window_node *my_rsv,
 		ext2_grpblk_t grp_goal, struct super_block *sb,
-		unsigned int group, struct buffer_head *bitmap_bh)
+		unsigned int group, struct fsblock_meta *bitmap_mb)
 {
 	struct ext2_reserve_window_node *search_head;
 	ext2_fsblk_t group_first_block, group_end_block, start_block;
@@ -996,7 +1007,7 @@ retry:
 	spin_unlock(rsv_lock);
 	first_free_block = bitmap_search_next_usable_block(
 			my_rsv->rsv_start - group_first_block,
-			bitmap_bh, group_end_block - group_first_block + 1);
+			bitmap_mb, group_end_block - group_first_block + 1);
 
 	if (first_free_block < 0) {
 		/*
@@ -1074,7 +1085,7 @@ static void try_to_extend_reservation(st
  * ext2_try_to_allocate_with_rsv()
  * @sb:			superblock
  * @group:		given allocation block group
- * @bitmap_bh:		bufferhead holds the block bitmap
+ * @bitmap_mb:		fsblock_meta holds the block bitmap
  * @grp_goal:		given target block within the group
  * @count:		target number of blocks to allocate
  * @my_rsv:		reservation window
@@ -1098,7 +1109,7 @@ static void try_to_extend_reservation(st
  */
 static ext2_grpblk_t
 ext2_try_to_allocate_with_rsv(struct super_block *sb, unsigned int group,
-			struct buffer_head *bitmap_bh, ext2_grpblk_t grp_goal,
+			struct fsblock_meta *bitmap_mb, ext2_grpblk_t grp_goal,
 			struct ext2_reserve_window_node * my_rsv,
 			unsigned long *count)
 {
@@ -1113,7 +1124,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 	 * or last attempt to allocate a block with reservation turned on failed
 	 */
 	if (my_rsv == NULL) {
-		return ext2_try_to_allocate(sb, group, bitmap_bh,
+		return ext2_try_to_allocate(sb, group, bitmap_mb,
 						grp_goal, count, NULL);
 	}
 	/*
@@ -1147,7 +1158,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 			if (my_rsv->rsv_goal_size < *count)
 				my_rsv->rsv_goal_size = *count;
 			ret = alloc_new_reservation(my_rsv, grp_goal, sb,
-							group, bitmap_bh);
+							group, bitmap_mb);
 			if (ret < 0)
 				break;			/* failed */
 
@@ -1168,7 +1179,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 			rsv_window_dump(&EXT2_SB(sb)->s_rsv_window_root, 1);
 			BUG();
 		}
-		ret = ext2_try_to_allocate(sb, group, bitmap_bh, grp_goal,
+		ret = ext2_try_to_allocate(sb, group, bitmap_mb, grp_goal,
 					   &num, &my_rsv->rsv_window);
 		if (ret >= 0) {
 			my_rsv->rsv_alloc_hit += num;
@@ -1217,8 +1228,8 @@ static int ext2_has_free_blocks(struct e
 ext2_fsblk_t ext2_new_blocks(struct inode *inode, ext2_fsblk_t goal,
 		    unsigned long *count, int *errp)
 {
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head *gdp_bh;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *gdp_mb;
 	int group_no;
 	int goal_group;
 	ext2_grpblk_t grp_target_blk;	/* blockgroup relative goal block */
@@ -1285,7 +1296,7 @@ ext2_fsblk_t ext2_new_blocks(struct inod
 			EXT2_BLOCKS_PER_GROUP(sb);
 	goal_group = group_no;
 retry_alloc:
-	gdp = ext2_get_group_desc(sb, group_no, &gdp_bh);
+	gdp = ext2_get_group_desc(sb, group_no, &gdp_mb);
 	if (!gdp)
 		goto io_error;
 
@@ -1302,11 +1313,11 @@ retry_alloc:
 	if (free_blocks > 0) {
 		grp_target_blk = ((goal - le32_to_cpu(es->s_first_data_block)) %
 				EXT2_BLOCKS_PER_GROUP(sb));
-		bitmap_bh = read_block_bitmap(sb, group_no);
-		if (!bitmap_bh)
+		bitmap_mb = read_block_bitmap(sb, group_no);
+		if (!bitmap_mb)
 			goto io_error;
 		grp_alloc_blk = ext2_try_to_allocate_with_rsv(sb, group_no,
-					bitmap_bh, grp_target_blk,
+					bitmap_mb, grp_target_blk,
 					my_rsv, &num);
 		if (grp_alloc_blk >= 0)
 			goto allocated;
@@ -1323,7 +1334,7 @@ retry_alloc:
 		group_no++;
 		if (group_no >= ngroups)
 			group_no = 0;
-		gdp = ext2_get_group_desc(sb, group_no, &gdp_bh);
+		gdp = ext2_get_group_desc(sb, group_no, &gdp_mb);
 		if (!gdp)
 			goto io_error;
 
@@ -1336,15 +1347,16 @@ retry_alloc:
 		if (my_rsv && (free_blocks <= (windowsz/2)))
 			continue;
 
-		brelse(bitmap_bh);
-		bitmap_bh = read_block_bitmap(sb, group_no);
-		if (!bitmap_bh)
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_block_bitmap(sb, group_no);
+		if (!bitmap_mb)
 			goto io_error;
 		/*
 		 * try to allocate block(s) from this group, without a goal(-1).
 		 */
 		grp_alloc_blk = ext2_try_to_allocate_with_rsv(sb, group_no,
-					bitmap_bh, -1, my_rsv, &num);
+					bitmap_mb, -1, my_rsv, &num);
 		if (grp_alloc_blk >= 0)
 			goto allocated;
 	}
@@ -1400,15 +1412,15 @@ allocated:
 		goto out;
 	}
 
-	group_adjust_blocks(sb, group_no, gdp, gdp_bh, -num);
+	group_adjust_blocks(sb, group_no, gdp, gdp_mb, -num);
 	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 
 	*errp = 0;
-	brelse(bitmap_bh);
+	block_put(bitmap_mb);
 	DQUOT_FREE_BLOCK(inode, *count-num);
 	*count = num;
 	return ret_block;
@@ -1421,7 +1433,8 @@ out:
 	 */
 	if (!performed_allocation)
 		DQUOT_FREE_BLOCK(inode, *count);
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	return 0;
 }
 
@@ -1436,7 +1449,7 @@ ext2_fsblk_t ext2_new_block(struct inode
 
 static const int nibblemap[] = {4, 3, 3, 2, 3, 2, 2, 1, 3, 2, 2, 1, 2, 1, 1, 0};
 
-unsigned long ext2_count_free (struct buffer_head * map, unsigned int numchars)
+unsigned long ext2_count_free (struct fsblock_meta * map, unsigned int numchars)
 {
 	unsigned int i;
 	unsigned long sum = 0;
@@ -1444,8 +1457,8 @@ unsigned long ext2_count_free (struct bu
 	if (!map)
 		return (0);
 	for (i = 0; i < numchars; i++)
-		sum += nibblemap[map->b_data[i] & 0xf] +
-			nibblemap[(map->b_data[i] >> 4) & 0xf];
+		sum += nibblemap[map->data[i] & 0xf] +
+			nibblemap[(map->data[i] >> 4) & 0xf];
 	return (sum);
 }
 
@@ -1465,20 +1478,20 @@ unsigned long ext2_count_free_blocks (st
 	bitmap_count = 0;
 	desc = NULL;
 	for (i = 0; i < EXT2_SB(sb)->s_groups_count; i++) {
-		struct buffer_head *bitmap_bh;
+		struct fsblock_meta *bitmap_mb;
 		desc = ext2_get_group_desc (sb, i, NULL);
 		if (!desc)
 			continue;
 		desc_count += le16_to_cpu(desc->bg_free_blocks_count);
-		bitmap_bh = read_block_bitmap(sb, i);
-		if (!bitmap_bh)
+		bitmap_mb = read_block_bitmap(sb, i);
+		if (!bitmap_mb)
 			continue;
 		
-		x = ext2_count_free(bitmap_bh, sb->s_blocksize);
+		x = ext2_count_free(bitmap_mb, sb->s_blocksize);
 		printk ("group %d: stored = %d, counted = %lu\n",
 			i, le16_to_cpu(desc->bg_free_blocks_count), x);
 		bitmap_count += x;
-		brelse(bitmap_bh);
+		block_put(bitmap_mb);
 	}
 	printk("ext2_count_free_blocks: stored = %lu, computed = %lu, %lu\n",
 		(long)le32_to_cpu(es->s_free_blocks_count),
Index: linux-2.6/fs/ext2/dir.c
===================================================================
--- linux-2.6.orig/fs/ext2/dir.c
+++ linux-2.6/fs/ext2/dir.c
@@ -22,7 +22,7 @@
  */
 
 #include "ext2.h"
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 
@@ -88,7 +88,7 @@ static int ext2_commit_chunk(struct page
 	int err = 0;
 
 	dir->i_version++;
-	block_write_end(NULL, mapping, pos, len, len, page, NULL);
+	__fsblock_write_end(mapping, pos, len, len, page, NULL);
 
 	if (pos+len > dir->i_size) {
 		i_size_write(dir, pos+len);
@@ -201,10 +201,12 @@ static struct page * ext2_get_page(struc
 			ext2_check_page(page, quiet);
 		if (PageError(page))
 			goto fail;
-	}
+	} else
+		printk("ext2_get_page read_mapping_page error\n");
 	return page;
 
 fail:
+	printk("ext2_get_page PageError\n");
 	ext2_put_page(page);
 	return ERR_PTR(-EIO);
 }
Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h
+++ linux-2.6/fs/ext2/ext2.h
@@ -1,5 +1,6 @@
 #include <linux/fs.h>
 #include <linux/ext2_fs.h>
+#include <linux/fsb_extentmap.h>
 
 /*
  * ext2 mount options
@@ -62,6 +63,7 @@ struct ext2_inode_info {
 	struct mutex truncate_mutex;
 	struct inode	vfs_inode;
 	struct list_head i_orphan;	/* unlinked but open inodes */
+	struct fsb_ext_root fsb_ext_root;
 };
 
 /*
@@ -97,7 +99,7 @@ extern unsigned long ext2_count_dirs (st
 extern void ext2_check_blocks_bitmap (struct super_block *);
 extern struct ext2_group_desc * ext2_get_group_desc(struct super_block * sb,
 						    unsigned int block_group,
-						    struct buffer_head ** bh);
+						    struct fsblock_meta ** mb);
 extern void ext2_discard_reservation (struct inode *);
 extern int ext2_should_retry_alloc(struct super_block *sb, int *retries);
 extern void ext2_init_block_alloc_info(struct inode *);
@@ -121,23 +123,24 @@ extern struct inode * ext2_new_inode (st
 extern void ext2_free_inode (struct inode *);
 extern unsigned long ext2_count_free_inodes (struct super_block *);
 extern void ext2_check_inodes_bitmap (struct super_block *);
-extern unsigned long ext2_count_free (struct buffer_head *, unsigned);
+extern unsigned long ext2_count_free (struct fsblock_meta *, unsigned);
 
 /* inode.c */
 extern struct inode *ext2_iget (struct super_block *, unsigned long);
 extern int ext2_write_inode (struct inode *, int);
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
-extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
+extern int ext2_insert_mapping(struct address_space *, loff_t, size_t, int);
 extern void ext2_truncate (struct inode *);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
 extern int ext2_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		       u64 start, u64 len);
-int __ext2_write_begin(struct file *file, struct address_space *mapping,
+extern int __ext2_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata);
+extern int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page);
 
 /* ioctl.c */
 extern long ext2_ioctl(struct file *, unsigned int, unsigned long);
Index: linux-2.6/fs/ext2/fsync.c
===================================================================
--- linux-2.6.orig/fs/ext2/fsync.c
+++ linux-2.6/fs/ext2/fsync.c
@@ -23,7 +23,7 @@
  */
 
 #include "ext2.h"
-#include <linux/buffer_head.h>		/* for sync_mapping_buffers() */
+#include <linux/fsblock.h>		/* for sync_mapping_buffers() */
 
 
 /*
@@ -37,7 +37,7 @@ int ext2_sync_file(struct file *file, st
 	int err;
 	int ret;
 
-	ret = sync_mapping_buffers(inode->i_mapping);
+	ret = fsblock_sync(inode->i_mapping);
 	if (!(inode->i_state & I_DIRTY))
 		return ret;
 	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
Index: linux-2.6/fs/ext2/ialloc.c
===================================================================
--- linux-2.6.orig/fs/ext2/ialloc.c
+++ linux-2.6/fs/ext2/ialloc.c
@@ -15,7 +15,7 @@
 #include <linux/quotaops.h>
 #include <linux/sched.h>
 #include <linux/backing-dev.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/random.h>
 #include "ext2.h"
 #include "xattr.h"
@@ -40,34 +40,34 @@
  * Read the inode allocation bitmap for a given block_group, reading
  * into the specified slot in the superblock's bitmap cache.
  *
- * Return buffer_head of bitmap on success or NULL.
+ * Return fsblock_meta of bitmap on success or NULL.
  */
-static struct buffer_head *
+static struct fsblock_meta *
 read_inode_bitmap(struct super_block * sb, unsigned long block_group)
 {
 	struct ext2_group_desc *desc;
-	struct buffer_head *bh = NULL;
+	struct fsblock_meta *mb = NULL;
 
 	desc = ext2_get_group_desc(sb, block_group, NULL);
 	if (!desc)
 		goto error_out;
 
-	bh = sb_bread(sb, le32_to_cpu(desc->bg_inode_bitmap));
-	if (!bh)
+	mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, le32_to_cpu(desc->bg_inode_bitmap));
+	if (!mb)
 		ext2_error(sb, "read_inode_bitmap",
 			    "Cannot read inode bitmap - "
 			    "block_group = %lu, inode_bitmap = %u",
 			    block_group, le32_to_cpu(desc->bg_inode_bitmap));
 error_out:
-	return bh;
+	return mb;
 }
 
 static void ext2_release_inode(struct super_block *sb, int group, int dir)
 {
 	struct ext2_group_desc * desc;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 
-	desc = ext2_get_group_desc(sb, group, &bh);
+	desc = ext2_get_group_desc(sb, group, &mb);
 	if (!desc) {
 		ext2_error(sb, "ext2_release_inode",
 			"can't get descriptor for group %d", group);
@@ -82,7 +82,7 @@ static void ext2_release_inode(struct su
 	if (dir)
 		percpu_counter_dec(&EXT2_SB(sb)->s_dirs_counter);
 	sb->s_dirt = 1;
-	mark_buffer_dirty(bh);
+	mark_mblock_dirty(mb);
 }
 
 /*
@@ -106,7 +106,7 @@ void ext2_free_inode (struct inode * ino
 	struct super_block * sb = inode->i_sb;
 	int is_directory;
 	unsigned long ino;
-	struct buffer_head *bitmap_bh = NULL;
+	struct fsblock_meta *bitmap_mb = NULL;
 	unsigned long block_group;
 	unsigned long bit;
 	struct ext2_super_block * es;
@@ -139,23 +139,25 @@ void ext2_free_inode (struct inode * ino
 	}
 	block_group = (ino - 1) / EXT2_INODES_PER_GROUP(sb);
 	bit = (ino - 1) % EXT2_INODES_PER_GROUP(sb);
-	brelse(bitmap_bh);
-	bitmap_bh = read_inode_bitmap(sb, block_group);
-	if (!bitmap_bh)
+	if (bitmap_mb)
+		block_put(bitmap_mb);
+	bitmap_mb = read_inode_bitmap(sb, block_group);
+	if (!bitmap_mb)
 		goto error_return;
 
 	/* Ok, now we can actually update the inode bitmaps.. */
 	if (!ext2_clear_bit_atomic(sb_bgl_lock(EXT2_SB(sb), block_group),
-				bit, (void *) bitmap_bh->b_data))
+				bit, (void *) bitmap_mb->data))
 		ext2_error (sb, "ext2_free_inode",
 			      "bit already cleared for inode %lu", ino);
 	else
 		ext2_release_inode(sb, block_group, is_directory);
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 error_return:
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 }
 
 /*
@@ -178,6 +180,8 @@ static void ext2_preread_inode(struct in
 	struct ext2_group_desc * gdp;
 	struct backing_dev_info *bdi;
 
+	return;  /* XXX */
+
 	bdi = inode->i_mapping->backing_dev_info;
 	if (bdi_read_congested(bdi))
 		return;
@@ -196,7 +200,7 @@ static void ext2_preread_inode(struct in
 				EXT2_INODE_SIZE(inode->i_sb);
 	block = le32_to_cpu(gdp->bg_inode_table) +
 				(offset >> EXT2_BLOCK_SIZE_BITS(inode->i_sb));
-	sb_breadahead(inode->i_sb, block);
+//	sb_breadahead(inode->i_sb, block);
 }
 
 /*
@@ -438,8 +442,8 @@ found:
 struct inode *ext2_new_inode(struct inode *dir, int mode)
 {
 	struct super_block *sb;
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head *bh2;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *mb;
 	int group, i;
 	ino_t ino = 0;
 	struct inode * inode;
@@ -471,17 +475,18 @@ struct inode *ext2_new_inode(struct inod
 	}
 
 	for (i = 0; i < sbi->s_groups_count; i++) {
-		gdp = ext2_get_group_desc(sb, group, &bh2);
-		brelse(bitmap_bh);
-		bitmap_bh = read_inode_bitmap(sb, group);
-		if (!bitmap_bh) {
+		gdp = ext2_get_group_desc(sb, group, &mb);
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_inode_bitmap(sb, group);
+		if (!bitmap_mb) {
 			err = -EIO;
 			goto fail;
 		}
 		ino = 0;
 
 repeat_in_this_group:
-		ino = ext2_find_next_zero_bit((unsigned long *)bitmap_bh->b_data,
+		ino = ext2_find_next_zero_bit((unsigned long *)bitmap_mb->data,
 					      EXT2_INODES_PER_GROUP(sb), ino);
 		if (ino >= EXT2_INODES_PER_GROUP(sb)) {
 			/*
@@ -497,7 +502,7 @@ repeat_in_this_group:
 			continue;
 		}
 		if (ext2_set_bit_atomic(sb_bgl_lock(sbi, group),
-						ino, bitmap_bh->b_data)) {
+						ino, bitmap_mb->data)) {
 			/* we lost this inode */
 			if (++ino >= EXT2_INODES_PER_GROUP(sb)) {
 				/* this group is exhausted, try next group */
@@ -517,10 +522,10 @@ repeat_in_this_group:
 	err = -ENOSPC;
 	goto fail;
 got:
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
-	brelse(bitmap_bh);
+		sync_block(bitmap_mb);
+	block_put(bitmap_mb);
 
 	ino += group * EXT2_INODES_PER_GROUP(sb) + 1;
 	if (ino < EXT2_FIRST_INO(sb) || ino > le32_to_cpu(es->s_inodes_count)) {
@@ -549,7 +554,7 @@ got:
 	spin_unlock(sb_bgl_lock(sbi, group));
 
 	sb->s_dirt = 1;
-	mark_buffer_dirty(bh2);
+	mark_mblock_dirty(mb);
 	inode->i_uid = current_fsuid();
 	if (test_opt (sb, GRPID))
 		inode->i_gid = dir->i_gid;
@@ -630,7 +635,7 @@ unsigned long ext2_count_free_inodes (st
 #ifdef EXT2FS_DEBUG
 	struct ext2_super_block *es;
 	unsigned long bitmap_count = 0;
-	struct buffer_head *bitmap_bh = NULL;
+	struct fsblock_meta *bitmap_mb = NULL;
 
 	es = EXT2_SB(sb)->s_es;
 	for (i = 0; i < EXT2_SB(sb)->s_groups_count; i++) {
@@ -640,17 +645,19 @@ unsigned long ext2_count_free_inodes (st
 		if (!desc)
 			continue;
 		desc_count += le16_to_cpu(desc->bg_free_inodes_count);
-		brelse(bitmap_bh);
-		bitmap_bh = read_inode_bitmap(sb, i);
-		if (!bitmap_bh)
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_inode_bitmap(sb, i);
+		if (!bitmap_mb)
 			continue;
 
-		x = ext2_count_free(bitmap_bh, EXT2_INODES_PER_GROUP(sb) / 8);
+		x = ext2_count_free(bitmap_mb, EXT2_INODES_PER_GROUP(sb) / 8);
 		printk("group %d: stored = %d, counted = %u\n",
 			i, le16_to_cpu(desc->bg_free_inodes_count), x);
 		bitmap_count += x;
 	}
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	printk("ext2_count_free_inodes: stored = %lu, computed = %lu, %lu\n",
 		percpu_counter_read(&EXT2_SB(sb)->s_freeinodes_counter),
 		desc_count, bitmap_count);
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -29,7 +29,7 @@
 #include <linux/quotaops.h>
 #include <linux/module.h>
 #include <linux/writeback.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/mpage.h>
 #include <linux/fiemap.h>
 #include <linux/namei.h>
@@ -71,6 +71,7 @@ void ext2_delete_inode (struct inode * i
 	inode->i_size = 0;
 	if (inode->i_blocks)
 		ext2_truncate (inode);
+	fsblock_release(&inode->i_data, 1); /* XXX: just do this at delete time? (but that goes bug in clear_inode mapping has private check) */
 	ext2_free_inode (inode);
 
 	return;
@@ -81,13 +82,13 @@ no_delete:
 typedef struct {
 	__le32	*p;
 	__le32	key;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 } Indirect;
 
-static inline void add_chain(Indirect *p, struct buffer_head *bh, __le32 *v)
+static inline void add_chain(Indirect *p, struct fsblock_meta *mb, __le32 *v)
 {
 	p->key = *(p->p = v);
-	p->bh = bh;
+	p->mb = mb;
 }
 
 static inline int verify_chain(Indirect *from, Indirect *to)
@@ -175,16 +176,16 @@ static int ext2_block_to_path(struct ino
  *	@chain: place to store the result
  *	@err: here we store the error value
  *
- *	Function fills the array of triples <key, p, bh> and returns %NULL
+ *	Function fills the array of triples <key, p, mb> and returns %NULL
  *	if everything went OK or the pointer to the last filled triple
  *	(incomplete one) otherwise. Upon the return chain[i].key contains
  *	the number of (i+1)-th block in the chain (as it is stored in memory,
  *	i.e. little-endian 32-bit), chain[i].p contains the address of that
- *	number (it points into struct inode for i==0 and into the bh->b_data
- *	for i>0) and chain[i].bh points to the buffer_head of i-th indirect
+ *	number (it points into struct inode for i==0 and into the mb->data
+ *	for i>0) and chain[i].mb points to the fsblock_meta of i-th indirect
  *	block for i>0 and NULL for i==0. In other words, it holds the block
  *	numbers of the chain, addresses they were taken from (and where we can
- *	verify that chain did not change) and buffer_heads hosting these
+ *	verify that chain did not change) and fsblock_meta hosting these
  *	numbers.
  *
  *	Function stops when it stumbles upon zero pointer (absent block)
@@ -204,7 +205,7 @@ static Indirect *ext2_get_branch(struct
 {
 	struct super_block *sb = inode->i_sb;
 	Indirect *p = chain;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 
 	*err = 0;
 	/* i_data is not going away, no lock needed */
@@ -212,13 +213,13 @@ static Indirect *ext2_get_branch(struct
 	if (!p->key)
 		goto no_block;
 	while (--depth) {
-		bh = sb_bread(sb, le32_to_cpu(p->key));
-		if (!bh)
+		mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, le32_to_cpu(p->key));
+		if (!mb)
 			goto failure;
 		read_lock(&EXT2_I(inode)->i_meta_lock);
 		if (!verify_chain(chain, p))
 			goto changed;
-		add_chain(++p, bh, (__le32*)bh->b_data + *++offsets);
+		add_chain(++p, mb, (__le32*)mb->data + *++offsets);
 		read_unlock(&EXT2_I(inode)->i_meta_lock);
 		if (!p->key)
 			goto no_block;
@@ -227,7 +228,7 @@ static Indirect *ext2_get_branch(struct
 
 changed:
 	read_unlock(&EXT2_I(inode)->i_meta_lock);
-	brelse(bh);
+	block_put(mb);
 	*err = -EAGAIN;
 	goto no_block;
 failure:
@@ -259,7 +260,7 @@ no_block:
 static ext2_fsblk_t ext2_find_near(struct inode *inode, Indirect *ind)
 {
 	struct ext2_inode_info *ei = EXT2_I(inode);
-	__le32 *start = ind->bh ? (__le32 *) ind->bh->b_data : ei->i_data;
+	__le32 *start = ind->mb ? (__le32 *) ind->mb->data : ei->i_data;
 	__le32 *p;
 	ext2_fsblk_t bg_start;
 	ext2_fsblk_t colour;
@@ -270,8 +271,8 @@ static ext2_fsblk_t ext2_find_near(struc
 			return le32_to_cpu(*p);
 
 	/* No such thing, so let's try location of indirect block */
-	if (ind->bh)
-		return ind->bh->b_blocknr;
+	if (ind->mb)
+		return ind->mb->block.block_nr;
 
 	/*
 	 * It is going to be refered from inode itself? OK, just put it into
@@ -431,19 +432,19 @@ failed_out:
  *	be placed into *branch->p to fill that gap.
  *
  *	If allocation fails we free all blocks we've allocated (and forget
- *	their buffer_heads) and return the error value the from failed
+ *	their fsblock_meta) and return the error value the from failed
  *	ext2_alloc_block() (normally -ENOSPC). Otherwise we set the chain
  *	as described above and return 0.
  */
 
-static int ext2_alloc_branch(struct inode *inode,
+static noinline int ext2_alloc_branch(struct inode *inode,
 			int indirect_blks, int *blks, ext2_fsblk_t goal,
 			int *offsets, Indirect *branch)
 {
 	int blocksize = inode->i_sb->s_blocksize;
 	int i, n = 0;
 	int err = 0;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 	int num;
 	ext2_fsblk_t new_blocks[4];
 	ext2_fsblk_t current_block;
@@ -459,15 +460,19 @@ static int ext2_alloc_branch(struct inod
 	 */
 	for (n = 1; n <= indirect_blks;  n++) {
 		/*
-		 * Get buffer_head for parent block, zero it out
+		 * Get fsblock_meta for parent block, zero it out
 		 * and set the pointer to new one, then send
 		 * parent to disk.
 		 */
-		bh = sb_getblk(inode->i_sb, new_blocks[n-1]);
-		branch[n].bh = bh;
-		lock_buffer(bh);
-		memset(bh->b_data, 0, blocksize);
-		branch[n].p = (__le32 *) bh->b_data + offsets[n];
+		mb = sb_find_or_create_mblock(&EXT2_SB(inode->i_sb)->fsb_sb, new_blocks[n-1]);
+		if (IS_ERR(mb)) {
+			err = PTR_ERR(mb);
+			break; /* XXX: proper error handling */
+		}
+		branch[n].mb = mb;
+		lock_block(mb);
+		memset(mb->data, 0, blocksize);
+		branch[n].p = (__le32 *) mb->data + offsets[n];
 		branch[n].key = cpu_to_le32(new_blocks[n]);
 		*branch[n].p = branch[n].key;
 		if ( n == indirect_blks) {
@@ -480,15 +485,15 @@ static int ext2_alloc_branch(struct inod
 			for (i=1; i < num; i++)
 				*(branch[n].p + i) = cpu_to_le32(++current_block);
 		}
-		set_buffer_uptodate(bh);
-		unlock_buffer(bh);
-		mark_buffer_dirty_inode(bh, inode);
-		/* We used to sync bh here if IS_SYNC(inode).
+		mark_mblock_uptodate(mb);
+		unlock_block(mb);
+		mark_mblock_dirty_inode(mb, inode);
+		/* We used to sync mb here if IS_SYNC(inode).
 		 * But we now rely upon generic_osync_inode()
 		 * and b_inode_buffers.  But not for directories.
 		 */
 		if (S_ISDIR(inode->i_mode) && IS_DIRSYNC(inode))
-			sync_dirty_buffer(bh);
+			sync_block(mb);
 	}
 	*blks = num;
 	return err;
@@ -506,7 +511,7 @@ static int ext2_alloc_branch(struct inod
  * inode (->i_blocks, etc.). In case of success we end up with the full
  * chain to new block and return 0.
  */
-static void ext2_splice_branch(struct inode *inode,
+static noinline void ext2_splice_branch(struct inode *inode,
 			long block, Indirect *where, int num, int blks)
 {
 	int i;
@@ -521,7 +526,7 @@ static void ext2_splice_branch(struct in
 	*where->p = where->key;
 
 	/*
-	 * Update the host buffer_head or inode to point to more just allocated
+	 * Update the host fsblock_meta or inode to point to more just allocated
 	 * direct blocks blocks
 	 */
 	if (num == 0 && blks > 1) {
@@ -544,8 +549,8 @@ static void ext2_splice_branch(struct in
 	/* We are done with atomic stuff, now do the rest of housekeeping */
 
 	/* had we spliced it onto indirect block? */
-	if (where->bh)
-		mark_buffer_dirty_inode(where->bh, inode);
+	if (where->mb)
+		mark_mblock_dirty_inode(where->mb, inode);
 
 	inode->i_ctime = CURRENT_TIME_SEC;
 	mark_inode_dirty(inode);
@@ -569,10 +574,10 @@ static void ext2_splice_branch(struct in
  * return = 0, if plain lookup failed.
  * return < 0, error case.
  */
-static int ext2_get_blocks(struct inode *inode,
-			   sector_t iblock, unsigned long maxblocks,
-			   struct buffer_head *bh_result,
-			   int create)
+static int ext2_get_blocks(struct inode *inode, sector_t blocknr,
+				unsigned long maxblocks, int create,
+				sector_t *offset, sector_t *block,
+				unsigned int *size, unsigned int *flags)
 {
 	int err = -EIO;
 	int offsets[4];
@@ -586,7 +591,11 @@ static int ext2_get_blocks(struct inode
 	int count = 0;
 	ext2_fsblk_t first_block = 0;
 
-	depth = ext2_block_to_path(inode,iblock,offsets,&blocks_to_boundary);
+	FSB_BUG_ON(create == MAP_BLOCK_ALLOCATE);
+
+	*flags = 0;
+
+	depth = ext2_block_to_path(inode, blocknr, offsets,&blocks_to_boundary);
 
 	if (depth == 0)
 		return (err);
@@ -596,7 +605,6 @@ reread:
 	/* Simplest case - block found, no allocation needed */
 	if (!partial) {
 		first_block = le32_to_cpu(chain[depth - 1].key);
-		clear_buffer_new(bh_result); /* What's this do? */
 		count++;
 		/*map more blocks*/
 		while (count < maxblocks && count <= blocks_to_boundary) {
@@ -622,6 +630,11 @@ reread:
 	}
 
 	/* Next simple case - plain lookup or failed read of indirect block */
+	if (!create && err != -EIO) {
+		*size = 1;
+		*offset = blocknr;
+		*flags |= FE_hole;
+	}
 	if (!create || err == -EIO)
 		goto cleanup;
 
@@ -634,7 +647,7 @@ reread:
 	if (S_ISREG(inode->i_mode) && (!ei->i_block_alloc_info))
 		ext2_init_block_alloc_info(inode);
 
-	goal = ext2_find_goal(inode, iblock, partial);
+	goal = ext2_find_goal(inode, blocknr, partial);
 
 	/* the number of blocks need to allocate for [d,t]indirect blocks */
 	indirect_blks = (chain + depth) - partial - 1;
@@ -667,73 +680,117 @@ reread:
 		}
 	}
 
-	ext2_splice_branch(inode, iblock, partial, indirect_blks, count);
+	ext2_splice_branch(inode, blocknr, partial, indirect_blks, count);
 	mutex_unlock(&ei->truncate_mutex);
-	set_buffer_new(bh_result);
+	*flags |= FE_new;
+	*flags &= ~FE_hole;
 got_it:
-	map_bh(bh_result, inode->i_sb, le32_to_cpu(chain[depth-1].key));
-	if (count > blocks_to_boundary)
-		set_buffer_boundary(bh_result);
+	FSB_BUG_ON(*flags & FE_hole);
+	*flags |= FE_mapped;
+	*offset = blocknr;
+	*size = 1;
+	*block = le32_to_cpu(chain[depth-1].key);
+//	if (count > blocks_to_boundary)
+//		set_buffer_boundary(bh_result);
 	err = count;
 	/* Clean up and exit */
 	partial = chain + depth - 1;	/* the whole chain */
 cleanup:
 	while (partial > chain) {
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 	return err;
 changed:
 	while (partial > chain) {
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 	goto reread;
 }
 
-int ext2_get_block(struct inode *inode, sector_t iblock, struct buffer_head *bh_result, int create)
-{
-	unsigned max_blocks = bh_result->b_size >> inode->i_blkbits;
-	int ret = ext2_get_blocks(inode, iblock, max_blocks,
-			      bh_result, create);
-	if (ret > 0) {
-		bh_result->b_size = (ret << inode->i_blkbits);
+#ifdef EXT2_EXTMAP
+static int ext2_map_extent(struct address_space *mapping, loff_t pos, int mode,
+				sector_t *offset, sector_t *block,
+				unsigned int *size, unsigned int *flags)
+{
+	struct inode *inode = mapping->host;
+	sector_t blocknr;
+	int ret;
+
+	blocknr = pos >> inode->i_blkbits;
+
+	ret = ext2_get_blocks(inode, blocknr, 1, mode, offset, block, size, flags);
+	if (ret > 0)
 		ret = 0;
-	}
 	return ret;
-
 }
 
-int ext2_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
-		u64 start, u64 len)
+static int ext2_map_block(struct address_space *mapping,
+			struct fsblock *block, loff_t pos, int mode)
 {
-	return generic_block_fiemap(inode, fieinfo, start, len,
-				    ext2_get_block);
+	FSB_BUG_ON(block->flags & BL_mapped);
+	FSB_BUG_ON(mode == MAP_BLOCK_ALLOCATE);
+
+	return fsb_ext_map_fsblock(mapping, pos, block, mode, &EXT2_I(mapping->host)->fsb_ext_root, ext2_map_extent);
 }
+#else
 
-static int ext2_writepage(struct page *page, struct writeback_control *wbc)
+static int ext2_map_block(struct address_space *mapping,
+			struct fsblock *b, loff_t pos, int mode)
 {
-	return block_write_full_page(page, ext2_get_block, wbc);
+	struct inode *inode = mapping->host;
+	sector_t blocknr;
+	sector_t offset;
+	sector_t block = (sector_t)ULLONG_MAX;
+	unsigned int flags, size;
+	int ret;
+
+	FSB_BUG_ON(b->flags & BL_mapped);
+	FSB_BUG_ON(mode == MAP_BLOCK_ALLOCATE);
+
+	blocknr = pos >> inode->i_blkbits;
+
+	ret = ext2_get_blocks(inode, blocknr, 1, mode, &offset, &block, &size, &flags);
+	if (ret > 0) {
+		ret = 0;
+	}
+	if (!ret) {
+		if (flags & FE_mapped) {
+			spin_lock_block_irq(b);
+			map_fsblock(b, block);
+			if (flags & FE_new) {
+				b->flags |= BL_new;
+				b->flags &= ~BL_hole;
+			}
+			FSB_BUG_ON(b->flags & BL_hole);
+			spin_unlock_block_irq(b);
+		} else if (flags & FE_hole) {
+			spin_lock_block_irq(b);
+			b->flags |= BL_hole;
+			spin_unlock_block_irq(b);
+		}
+	}
+	return ret;
 }
+#endif
 
-static int ext2_readpage(struct file *file, struct page *page)
+static int ext2_writepage(struct page *page, struct writeback_control *wbc)
 {
-	return mpage_readpage(page, ext2_get_block);
+	return fsblock_write_page(page, ext2_map_block, wbc);
 }
 
-static int
-ext2_readpages(struct file *file, struct address_space *mapping,
-		struct list_head *pages, unsigned nr_pages)
+static int ext2_readpage(struct file *file, struct page *page)
 {
-	return mpage_readpages(mapping, pages, nr_pages, ext2_get_block);
+	return fsblock_read_page(page, ext2_map_block);
 }
 
 int __ext2_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
-	return block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
-							ext2_get_block);
+	return fsblock_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+							ext2_map_block);
 }
 
 static int
@@ -745,31 +802,17 @@ ext2_write_begin(struct file *file, stru
 	return __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
 }
 
-static int
-ext2_nobh_write_begin(struct file *file, struct address_space *mapping,
-		loff_t pos, unsigned len, unsigned flags,
-		struct page **pagep, void **fsdata)
-{
-	/*
-	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
-	 * directory handling code to pass around offsets rather than struct
-	 * pages in order to make this work easily.
-	 */
-	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
-							ext2_get_block);
-}
-
-static int ext2_nobh_writepage(struct page *page,
-			struct writeback_control *wbc)
+static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
 {
-	return nobh_writepage(page, ext2_get_block, wbc);
+	return fsblock_bmap(mapping, block, ext2_map_block);
 }
 
-static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
+int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 {
-	return generic_block_bmap(mapping,block,ext2_get_block);
+	return fsblock_page_mkwrite(vma, page, ext2_map_block);
 }
 
+#if 0
 static ssize_t
 ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs)
@@ -786,19 +829,25 @@ ext2_writepages(struct address_space *ma
 {
 	return mpage_writepages(mapping, wbc, ext2_get_block);
 }
+#endif
 
 const struct address_space_operations ext2_aops = {
 	.readpage		= ext2_readpage,
-	.readpages		= ext2_readpages,
+//	.readpages		= ext2_readpages,
 	.writepage		= ext2_writepage,
-	.sync_page		= block_sync_page,
+//	.sync_page		= block_sync_page,
 	.write_begin		= ext2_write_begin,
-	.write_end		= generic_write_end,
+	.write_end		= fsblock_write_end,
 	.bmap			= ext2_bmap,
-	.direct_IO		= ext2_direct_IO,
-	.writepages		= ext2_writepages,
-	.migratepage		= buffer_migrate_page,
-	.is_partially_uptodate	= block_is_partially_uptodate,
+//	.direct_IO		= ext2_direct_IO,
+//	.writepages		= ext2_writepages,
+//	.migratepage		= buffer_migrate_page,
+//	.is_partially_uptodate	= block_is_partially_uptodate,
+	.set_page_dirty		= fsblock_set_page_dirty,
+	.invalidatepage		= fsblock_invalidate_page,
+	.releasepage		= fsblock_releasepage,
+	.release		= fsblock_release,
+	.sync			= fsblock_sync,
 };
 
 const struct address_space_operations ext2_aops_xip = {
@@ -806,19 +855,6 @@ const struct address_space_operations ex
 	.get_xip_mem		= ext2_get_xip_mem,
 };
 
-const struct address_space_operations ext2_nobh_aops = {
-	.readpage		= ext2_readpage,
-	.readpages		= ext2_readpages,
-	.writepage		= ext2_nobh_writepage,
-	.sync_page		= block_sync_page,
-	.write_begin		= ext2_nobh_write_begin,
-	.write_end		= nobh_write_end,
-	.bmap			= ext2_bmap,
-	.direct_IO		= ext2_direct_IO,
-	.writepages		= ext2_writepages,
-	.migratepage		= buffer_migrate_page,
-};
-
 /*
  * Probably it should be a library function... search for first non-zero word
  * or memcmp with zero_page, whatever is better for particular architecture.
@@ -853,7 +889,7 @@ static inline int all_zeroes(__le32 *p,
  *	point might try to populate it.
  *
  *	We atomically detach the top of branch from the tree, store the block
- *	number of its root in *@top, pointers to buffer_heads of partially
+ *	number of its root in *@top, pointers to fsblock_meta of partially
  *	truncated blocks - in @chain[].bh and pointers to their last elements
  *	that should not be removed - in @chain[].p. Return value is the pointer
  *	to last filled element of @chain.
@@ -890,7 +926,7 @@ static Indirect *ext2_find_shared(struct
 		write_unlock(&EXT2_I(inode)->i_meta_lock);
 		goto no_top;
 	}
-	for (p=partial; p>chain && all_zeroes((__le32*)p->bh->b_data,p->p); p--)
+	for (p=partial; p>chain && all_zeroes((__le32*)p->mb->data,p->p); p--)
 		;
 	/*
 	 * OK, we've found the last block that must survive. The rest of our
@@ -908,7 +944,7 @@ static Indirect *ext2_find_shared(struct
 
 	while(partial > p)
 	{
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 no_top:
@@ -967,7 +1003,7 @@ static inline void ext2_free_data(struct
  */
 static void ext2_free_branches(struct inode *inode, __le32 *p, __le32 *q, int depth)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	unsigned long nr;
 
 	if (depth--) {
@@ -977,22 +1013,22 @@ static void ext2_free_branches(struct in
 			if (!nr)
 				continue;
 			*p = 0;
-			bh = sb_bread(inode->i_sb, nr);
+			mb = sb_mbread(&EXT2_SB(inode->i_sb)->fsb_sb, nr);
 			/*
 			 * A read failure? Report error and clear slot
 			 * (should be rare).
 			 */ 
-			if (!bh) {
+			if (!mb) {
 				ext2_error(inode->i_sb, "ext2_free_branches",
 					"Read failure, inode=%ld, block=%ld",
 					inode->i_ino, nr);
 				continue;
 			}
 			ext2_free_branches(inode,
-					   (__le32*)bh->b_data,
-					   (__le32*)bh->b_data + addr_per_block,
+					   (__le32*)mb->data,
+					   (__le32*)mb->data + addr_per_block,
 					   depth);
-			bforget(bh);
+			mbforget(mb);
 			ext2_free_blocks(inode, nr, 1);
 			mark_inode_dirty(inode);
 		}
@@ -1000,7 +1036,7 @@ static void ext2_free_branches(struct in
 		ext2_free_data(inode, p, q);
 }
 
-void ext2_truncate(struct inode *inode)
+noinline void ext2_truncate(struct inode *inode)
 {
 	__le32 *i_data = EXT2_I(inode)->i_data;
 	struct ext2_inode_info *ei = EXT2_I(inode);
@@ -1027,12 +1063,14 @@ void ext2_truncate(struct inode *inode)
 
 	if (mapping_is_xip(inode->i_mapping))
 		xip_truncate_page(inode->i_mapping, inode->i_size);
-	else if (test_opt(inode->i_sb, NOBH))
-		nobh_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
-	else
-		block_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
+	else {
+		/* XXX: error codes? */
+		fsblock_truncate_page(inode->i_mapping,
+				inode->i_size);
+#ifdef EXT2_EXTMAP
+		fsb_ext_unmap_fsblock(inode->i_mapping, inode->i_size, -1, &EXT2_I(inode)->fsb_ext_root);
+#endif
+	}
 
 	n = ext2_block_to_path(inode, iblock, offsets, NULL);
 	if (n == 0)
@@ -1056,17 +1094,17 @@ void ext2_truncate(struct inode *inode)
 		if (partial == chain)
 			mark_inode_dirty(inode);
 		else
-			mark_buffer_dirty_inode(partial->bh, inode);
+			mark_mblock_dirty_inode(partial->mb, inode);
 		ext2_free_branches(inode, &nr, &nr+1, (chain+n-1) - partial);
 	}
 	/* Clear the ends of indirect blocks on the shared branch */
 	while (partial > chain) {
 		ext2_free_branches(inode,
 				   partial->p + 1,
-				   (__le32*)partial->bh->b_data+addr_per_block,
+				   (__le32*)partial->mb->data+addr_per_block,
 				   (chain+n-1) - partial);
-		mark_buffer_dirty_inode(partial->bh, inode);
-		brelse (partial->bh);
+		mark_mblock_dirty_inode(partial->mb, inode);
+		block_put(partial->mb);
 		partial--;
 	}
 do_indirects:
@@ -1102,7 +1140,7 @@ do_indirects:
 	mutex_unlock(&ei->truncate_mutex);
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
 	if (inode_needs_sync(inode)) {
-		sync_mapping_buffers(inode->i_mapping);
+		fsblock_sync(inode->i_mapping);
 		ext2_sync_inode (inode);
 	} else {
 		mark_inode_dirty(inode);
@@ -1110,9 +1148,9 @@ do_indirects:
 }
 
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
-					struct buffer_head **p)
+					struct fsblock_meta **p)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	unsigned long block_group;
 	unsigned long block;
 	unsigned long offset;
@@ -1133,12 +1171,12 @@ static struct ext2_inode *ext2_get_inode
 	offset = ((ino - 1) % EXT2_INODES_PER_GROUP(sb)) * EXT2_INODE_SIZE(sb);
 	block = le32_to_cpu(gdp->bg_inode_table) +
 		(offset >> EXT2_BLOCK_SIZE_BITS(sb));
-	if (!(bh = sb_bread(sb, block)))
+	if (!(mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, block)))
 		goto Eio;
 
-	*p = bh;
+	*p = mb;
 	offset &= (EXT2_BLOCK_SIZE(sb) - 1);
-	return (struct ext2_inode *) (bh->b_data + offset);
+	return (struct ext2_inode *) (mb->data + offset);
 
 Einval:
 	ext2_error(sb, "ext2_get_inode", "bad inode number: %lu",
@@ -1191,7 +1229,7 @@ void ext2_get_inode_flags(struct ext2_in
 struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 {
 	struct ext2_inode_info *ei;
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	struct ext2_inode *raw_inode;
 	struct inode *inode;
 	long ret = -EIO;
@@ -1210,7 +1248,7 @@ struct inode *ext2_iget (struct super_bl
 #endif
 	ei->i_block_alloc_info = NULL;
 
-	raw_inode = ext2_get_inode(inode->i_sb, ino, &bh);
+	raw_inode = ext2_get_inode(inode->i_sb, ino, &mb);
 	if (IS_ERR(raw_inode)) {
 		ret = PTR_ERR(raw_inode);
  		goto bad_inode;
@@ -1237,7 +1275,7 @@ struct inode *ext2_iget (struct super_bl
 	 */
 	if (inode->i_nlink == 0 && (inode->i_mode == 0 || ei->i_dtime)) {
 		/* this inode is deleted */
-		brelse (bh);
+		block_put(mb);
 		ret = -ESTALE;
 		goto bad_inode;
 	}
@@ -1270,9 +1308,6 @@ struct inode *ext2_iget (struct super_bl
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
-		} else if (test_opt(inode->i_sb, NOBH)) {
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
 			inode->i_fop = &ext2_file_operations;
@@ -1280,10 +1315,7 @@ struct inode *ext2_iget (struct super_bl
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &ext2_dir_inode_operations;
 		inode->i_fop = &ext2_dir_operations;
-		if (test_opt(inode->i_sb, NOBH))
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-		else
-			inode->i_mapping->a_ops = &ext2_aops;
+		inode->i_mapping->a_ops = &ext2_aops;
 	} else if (S_ISLNK(inode->i_mode)) {
 		if (ext2_inode_is_fast_symlink(inode)) {
 			inode->i_op = &ext2_fast_symlink_inode_operations;
@@ -1291,10 +1323,7 @@ struct inode *ext2_iget (struct super_bl
 				sizeof(ei->i_data) - 1);
 		} else {
 			inode->i_op = &ext2_symlink_inode_operations;
-			if (test_opt(inode->i_sb, NOBH))
-				inode->i_mapping->a_ops = &ext2_nobh_aops;
-			else
-				inode->i_mapping->a_ops = &ext2_aops;
+			inode->i_mapping->a_ops = &ext2_aops;
 		}
 	} else {
 		inode->i_op = &ext2_special_inode_operations;
@@ -1305,7 +1334,7 @@ struct inode *ext2_iget (struct super_bl
 			init_special_inode(inode, inode->i_mode,
 			   new_decode_dev(le32_to_cpu(raw_inode->i_block[1])));
 	}
-	brelse (bh);
+	block_put(mb);
 	ext2_set_inode_flags(inode);
 	unlock_new_inode(inode);
 	return inode;
@@ -1315,15 +1344,15 @@ bad_inode:
 	return ERR_PTR(ret);
 }
 
-static int ext2_update_inode(struct inode * inode, int do_sync)
+static noinline int ext2_update_inode(struct inode * inode, int do_sync)
 {
 	struct ext2_inode_info *ei = EXT2_I(inode);
 	struct super_block *sb = inode->i_sb;
 	ino_t ino = inode->i_ino;
 	uid_t uid = inode->i_uid;
 	gid_t gid = inode->i_gid;
-	struct buffer_head * bh;
-	struct ext2_inode * raw_inode = ext2_get_inode(sb, ino, &bh);
+	struct fsblock_meta * mb;
+	struct ext2_inode * raw_inode = ext2_get_inode(sb, ino, &mb);
 	int n;
 	int err = 0;
 
@@ -1382,11 +1411,9 @@ static int ext2_update_inode(struct inod
 			       /* If this is the first large file
 				* created, add a flag to the superblock.
 				*/
-				lock_kernel();
 				ext2_update_dynamic_rev(sb);
 				EXT2_SET_RO_COMPAT_FEATURE(sb,
 					EXT2_FEATURE_RO_COMPAT_LARGE_FILE);
-				unlock_kernel();
 				ext2_write_super(sb);
 			}
 		}
@@ -1406,17 +1433,18 @@ static int ext2_update_inode(struct inod
 		}
 	} else for (n = 0; n < EXT2_N_BLOCKS; n++)
 		raw_inode->i_block[n] = ei->i_data[n];
-	mark_buffer_dirty(bh);
+	mark_mblock_dirty(mb);
 	if (do_sync) {
-		sync_dirty_buffer(bh);
-		if (buffer_req(bh) && !buffer_uptodate(bh)) {
+		sync_block(mb);
+//		if (buffer_req(bh) && !buffer_uptodate(bh)) {
+		if (!(mb->block.flags & BL_uptodate)) {
 			printk ("IO error syncing ext2 inode [%s:%08lx]\n",
 				sb->s_id, (unsigned long) ino);
 			err = -EIO;
 		}
 	}
 	ei->i_state &= ~EXT2_STATE_NEW;
-	brelse (bh);
+	block_put(mb);
 	return err;
 }
 
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c
+++ linux-2.6/fs/ext2/super.c
@@ -24,7 +24,7 @@
 #include <linux/blkdev.h>
 #include <linux/parser.h>
 #include <linux/random.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/exportfs.h>
 #include <linux/smp_lock.h>
 #include <linux/vfs.h>
@@ -32,6 +32,7 @@
 #include <linux/mount.h>
 #include <linux/log2.h>
 #include <linux/quotaops.h>
+#include <linux/buffer_head.h>
 #include <asm/uaccess.h>
 #include "ext2.h"
 #include "xattr.h"
@@ -121,16 +122,19 @@ static void ext2_put_super (struct super
 		es->s_state = cpu_to_le16(sbi->s_mount_state);
 		ext2_sync_super(sb, es);
 	}
+
 	db_count = sbi->s_gdb_count;
 	for (i = 0; i < db_count; i++)
 		if (sbi->s_group_desc[i])
-			brelse (sbi->s_group_desc[i]);
+			block_put(sbi->s_group_desc[i]);
 	kfree(sbi->s_group_desc);
 	kfree(sbi->s_debts);
 	percpu_counter_destroy(&sbi->s_freeblocks_counter);
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
-	brelse (sbi->s_sbh);
+	if (sbi->s_smb)
+		block_put(sbi->s_smb);
+	fsblock_unregister_super(sb, &sbi->fsb_sb);
 	sb->s_fs_info = NULL;
 	kfree(sbi->s_blockgroup_lock);
 	kfree(sbi);
@@ -152,11 +156,16 @@ static struct inode *ext2_alloc_inode(st
 #endif
 	ei->i_block_alloc_info = NULL;
 	ei->vfs_inode.i_version = 1;
+	fsb_ext_root_init(&ei->fsb_ext_root);
 	return &ei->vfs_inode;
 }
 
 static void ext2_destroy_inode(struct inode *inode)
 {
+	fsblock_release(&inode->i_data, 1);
+#ifdef EXT2_EXTMAP
+	fsb_ext_release(inode->i_mapping, &EXT2_I(inode)->fsb_ext_root);
+#endif
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
@@ -739,6 +748,7 @@ static unsigned long descriptor_loc(stru
 static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	struct ext2_sb_info * sbi;
 	struct ext2_super_block * es;
 	struct inode *root;
@@ -803,8 +813,10 @@ static int ext2_fill_super(struct super_
 	sbi->s_es = es;
 	sb->s_magic = le16_to_cpu(es->s_magic);
 
-	if (sb->s_magic != EXT2_SUPER_MAGIC)
+	if (sb->s_magic != EXT2_SUPER_MAGIC) {
+		printk("ext2 fill super wrong magic\n");
 		goto cantfind_ext2;
+	}
 
 	/* Set defaults before we parse the mount options */
 	def_mount_opts = le32_to_cpu(es->s_default_mount_opts);
@@ -881,7 +893,7 @@ static int ext2_fill_super(struct super_
 
 	/* If the blocksize doesn't match, re-read the thing.. */
 	if (sb->s_blocksize != blocksize) {
-		brelse(bh);
+		put_bh(bh);
 
 		if (!sb_set_blocksize(sb, blocksize)) {
 			printk(KERN_ERR "EXT2-fs: blocksize too small for device.\n");
@@ -904,6 +916,20 @@ static int ext2_fill_super(struct super_
 		}
 	}
 
+	ret = fsblock_register_super(sb, &sbi->fsb_sb);
+	if (ret)
+		goto failed_fsblock;
+
+	mb = sb_mbread(&sbi->fsb_sb, logic_sb_block);
+	if (!mb) {
+		printk("EXT2-fs: Could not read fsblock metadata block for superblock\n");
+		goto failed_fsblock;
+	}
+
+	put_bh(bh);
+	es = (struct ext2_super_block *) (((char *)mb->data) + offset);
+	sbi->s_es = es;
+
 	sb->s_maxbytes = ext2_max_size(sb->s_blocksize_bits);
 
 	if (le32_to_cpu(es->s_rev_level) == EXT2_GOOD_OLD_REV) {
@@ -940,7 +966,7 @@ static int ext2_fill_super(struct super_
 					sbi->s_inodes_per_block;
 	sbi->s_desc_per_block = sb->s_blocksize /
 					sizeof (struct ext2_group_desc);
-	sbi->s_sbh = bh;
+	sbi->s_smb = mb;
 	sbi->s_mount_state = le16_to_cpu(es->s_state);
 	sbi->s_addr_per_block_bits =
 		ilog2 (EXT2_ADDR_PER_BLOCK(sb));
@@ -950,7 +976,7 @@ static int ext2_fill_super(struct super_
 	if (sb->s_magic != EXT2_SUPER_MAGIC)
 		goto cantfind_ext2;
 
-	if (sb->s_blocksize != bh->b_size) {
+	if (sb->s_blocksize != fsblock_size(mb)) {
 		if (!silent)
 			printk ("VFS: Unsupported blocksize on dev "
 				"%s.\n", sb->s_id);
@@ -986,7 +1012,7 @@ static int ext2_fill_super(struct super_
  					/ EXT2_BLOCKS_PER_GROUP(sb)) + 1;
 	db_count = (sbi->s_groups_count + EXT2_DESC_PER_BLOCK(sb) - 1) /
 		   EXT2_DESC_PER_BLOCK(sb);
-	sbi->s_group_desc = kmalloc (db_count * sizeof (struct buffer_head *), GFP_KERNEL);
+	sbi->s_group_desc = kmalloc (db_count * sizeof (struct fsblock_meta *), GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
 		printk ("EXT2-fs: not enough memory\n");
 		goto failed_mount;
@@ -999,10 +1025,10 @@ static int ext2_fill_super(struct super_
 	}
 	for (i = 0; i < db_count; i++) {
 		block = descriptor_loc(sb, logic_sb_block, i);
-		sbi->s_group_desc[i] = sb_bread(sb, block);
+		sbi->s_group_desc[i] = sb_mbread(&EXT2_SB(sb)->fsb_sb, block);
 		if (!sbi->s_group_desc[i]) {
 			for (j = 0; j < i; j++)
-				brelse (sbi->s_group_desc[j]);
+				block_put(sbi->s_group_desc[j]);
 			printk ("EXT2-fs: unable to read group descriptors\n");
 			goto failed_mount_group_desc;
 		}
@@ -1085,14 +1111,17 @@ failed_mount3:
 	percpu_counter_destroy(&sbi->s_dirs_counter);
 failed_mount2:
 	for (i = 0; i < db_count; i++)
-		brelse(sbi->s_group_desc[i]);
+		block_put(sbi->s_group_desc[i]);
 failed_mount_group_desc:
 	kfree(sbi->s_group_desc);
 	kfree(sbi->s_debts);
 failed_mount:
-	brelse(bh);
+	put_bh(bh);
 failed_sbi:
+	fsblock_unregister_super(sb, &sbi->fsb_sb);
 	sb->s_fs_info = NULL;
+failed_fsblock:
+	block_put(mb);
 	kfree(sbi);
 	return ret;
 }
@@ -1101,7 +1130,7 @@ static void ext2_commit_super (struct su
 			       struct ext2_super_block * es)
 {
 	es->s_wtime = cpu_to_le32(get_seconds());
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
 	sb->s_dirt = 0;
 }
 
@@ -1110,8 +1139,8 @@ static void ext2_sync_super(struct super
 	es->s_free_blocks_count = cpu_to_le32(ext2_count_free_blocks(sb));
 	es->s_free_inodes_count = cpu_to_le32(ext2_count_free_inodes(sb));
 	es->s_wtime = cpu_to_le32(get_seconds());
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
-	sync_dirty_buffer(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
+	sync_block(EXT2_SB(sb)->s_smb);
 	sb->s_dirt = 0;
 }
 
@@ -1129,7 +1158,6 @@ static void ext2_sync_super(struct super
 void ext2_write_super (struct super_block * sb)
 {
 	struct ext2_super_block * es;
-	lock_kernel();
 	if (!(sb->s_flags & MS_RDONLY)) {
 		es = EXT2_SB(sb)->s_es;
 
@@ -1144,7 +1172,6 @@ void ext2_write_super (struct super_bloc
 			ext2_commit_super (sb, es);
 	}
 	sb->s_dirt = 0;
-	unlock_kernel();
 }
 
 static int ext2_remount (struct super_block * sb, int * flags, char * data)
@@ -1304,107 +1331,7 @@ static int ext2_get_sb(struct file_syste
 
 #ifdef CONFIG_QUOTA
 
-/* Read data from quotafile - avoid pagecache and such because we cannot afford
- * acquiring the locks... As quota files are never truncated and quota code
- * itself serializes the operations (and noone else should touch the files)
- * we don't have to be afraid of races */
-static ssize_t ext2_quota_read(struct super_block *sb, int type, char *data,
-			       size_t len, loff_t off)
-{
-	struct inode *inode = sb_dqopt(sb)->files[type];
-	sector_t blk = off >> EXT2_BLOCK_SIZE_BITS(sb);
-	int err = 0;
-	int offset = off & (sb->s_blocksize - 1);
-	int tocopy;
-	size_t toread;
-	struct buffer_head tmp_bh;
-	struct buffer_head *bh;
-	loff_t i_size = i_size_read(inode);
-
-	if (off > i_size)
-		return 0;
-	if (off+len > i_size)
-		len = i_size-off;
-	toread = len;
-	while (toread > 0) {
-		tocopy = sb->s_blocksize - offset < toread ?
-				sb->s_blocksize - offset : toread;
-
-		tmp_bh.b_state = 0;
-		err = ext2_get_block(inode, blk, &tmp_bh, 0);
-		if (err < 0)
-			return err;
-		if (!buffer_mapped(&tmp_bh))	/* A hole? */
-			memset(data, 0, tocopy);
-		else {
-			bh = sb_bread(sb, tmp_bh.b_blocknr);
-			if (!bh)
-				return -EIO;
-			memcpy(data, bh->b_data+offset, tocopy);
-			brelse(bh);
-		}
-		offset = 0;
-		toread -= tocopy;
-		data += tocopy;
-		blk++;
-	}
-	return len;
-}
-
-/* Write to quotafile */
-static ssize_t ext2_quota_write(struct super_block *sb, int type,
-				const char *data, size_t len, loff_t off)
-{
-	struct inode *inode = sb_dqopt(sb)->files[type];
-	sector_t blk = off >> EXT2_BLOCK_SIZE_BITS(sb);
-	int err = 0;
-	int offset = off & (sb->s_blocksize - 1);
-	int tocopy;
-	size_t towrite = len;
-	struct buffer_head tmp_bh;
-	struct buffer_head *bh;
-
-	mutex_lock_nested(&inode->i_mutex, I_MUTEX_QUOTA);
-	while (towrite > 0) {
-		tocopy = sb->s_blocksize - offset < towrite ?
-				sb->s_blocksize - offset : towrite;
-
-		tmp_bh.b_state = 0;
-		err = ext2_get_block(inode, blk, &tmp_bh, 1);
-		if (err < 0)
-			goto out;
-		if (offset || tocopy != EXT2_BLOCK_SIZE(sb))
-			bh = sb_bread(sb, tmp_bh.b_blocknr);
-		else
-			bh = sb_getblk(sb, tmp_bh.b_blocknr);
-		if (!bh) {
-			err = -EIO;
-			goto out;
-		}
-		lock_buffer(bh);
-		memcpy(bh->b_data+offset, data, tocopy);
-		flush_dcache_page(bh->b_page);
-		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
-		unlock_buffer(bh);
-		brelse(bh);
-		offset = 0;
-		towrite -= tocopy;
-		data += tocopy;
-		blk++;
-	}
-out:
-	if (len == towrite)
-		return err;
-	if (inode->i_size < off+len-towrite)
-		i_size_write(inode, off+len-towrite);
-	inode->i_version++;
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-	mark_inode_dirty(inode);
-	mutex_unlock(&inode->i_mutex);
-	return len - towrite;
-}
-
+#error "not yet supported"
 #endif
 
 static struct file_system_type ext2_fs_type = {
Index: linux-2.6/fs/ext2/xattr.c
===================================================================
--- linux-2.6.orig/fs/ext2/xattr.c
+++ linux-2.6/fs/ext2/xattr.c
@@ -53,7 +53,7 @@
  * to avoid deadlocks.
  */
 
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -64,9 +64,9 @@
 #include "xattr.h"
 #include "acl.h"
 
-#define HDR(bh) ((struct ext2_xattr_header *)((bh)->b_data))
+#define HDR(fsb) ((struct ext2_xattr_header *)((fsb)->data))
 #define ENTRY(ptr) ((struct ext2_xattr_entry *)(ptr))
-#define FIRST_ENTRY(bh) ENTRY(HDR(bh)+1)
+#define FIRST_ENTRY(fsb) ENTRY(HDR(fsb)+1)
 #define IS_LAST_ENTRY(entry) (*(__u32 *)(entry) == 0)
 
 #ifdef EXT2_XATTR_DEBUG
@@ -76,11 +76,11 @@
 		printk(f); \
 		printk("\n"); \
 	} while (0)
-# define ea_bdebug(bh, f...) do { \
+# define ea_bdebug(fsb, f...) do { \
 		char b[BDEVNAME_SIZE]; \
-		printk(KERN_DEBUG "block %s:%lu: ", \
-			bdevname(bh->b_bdev, b), \
-			(unsigned long) bh->b_blocknr); \
+		printk(KERN_DEBUG "block %s:%llu: ", \
+			bdevname(fsb->page->mapping->host->i_sb->sb_bdev, b), \
+			(unsigned long long) fsb->blocknr); \
 		printk(f); \
 		printk("\n"); \
 	} while (0)
@@ -89,11 +89,11 @@
 # define ea_bdebug(f...)
 #endif
 
-static int ext2_xattr_set2(struct inode *, struct buffer_head *,
+static int ext2_xattr_set2(struct inode *, struct fsblock *,
 			   struct ext2_xattr_header *);
 
-static int ext2_xattr_cache_insert(struct buffer_head *);
-static struct buffer_head *ext2_xattr_cache_find(struct inode *,
+static int ext2_xattr_cache_insert(struct fsblock *);
+static struct fsblock *ext2_xattr_cache_find(struct inode *,
 						 struct ext2_xattr_header *);
 static void ext2_xattr_rehash(struct ext2_xattr_header *,
 			      struct ext2_xattr_entry *);
@@ -149,7 +149,7 @@ int
 ext2_xattr_get(struct inode *inode, int name_index, const char *name,
 	       void *buffer, size_t buffer_size)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_entry *entry;
 	size_t name_len, size;
 	char *end;
@@ -165,15 +165,15 @@ ext2_xattr_get(struct inode *inode, int
 	if (!EXT2_I(inode)->i_file_acl)
 		goto cleanup;
 	ea_idebug(inode, "reading block %d", EXT2_I(inode)->i_file_acl);
-	bh = sb_bread(inode->i_sb, EXT2_I(inode)->i_file_acl);
+	fsb = sb_mbread(inode->i_sb, EXT2_I(inode)->i_file_acl);
 	error = -EIO;
-	if (!bh)
+	if (!fsb)
 		goto cleanup;
-	ea_bdebug(bh, "b_count=%d, refcount=%d",
-		atomic_read(&(bh->b_count)), le32_to_cpu(HDR(bh)->h_refcount));
-	end = bh->b_data + bh->b_size;
-	if (HDR(bh)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
-	    HDR(bh)->h_blocks != cpu_to_le32(1)) {
+	ea_bdebug(fsb, "count=%d, refcount=%d",
+		atomic_read(&(fsb->count)), le32_to_cpu(HDR(fsb)->h_refcount));
+	end = fsb->data + fsblock_size(fsb);
+	if (HDR(fsb)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
+	    HDR(fsb)->h_blocks != cpu_to_le32(1)) {
 bad_block:	ext2_error(inode->i_sb, "ext2_xattr_get",
 			"inode %ld: bad block %d", inode->i_ino,
 			EXT2_I(inode)->i_file_acl);
@@ -186,7 +186,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	error = -ERANGE;
 	if (name_len > 255)
 		goto cleanup;
-	entry = FIRST_ENTRY(bh);
+	entry = FIRST_ENTRY(fsb);
 	while (!IS_LAST_ENTRY(entry)) {
 		struct ext2_xattr_entry *next =
 			EXT2_XATTR_NEXT(entry);
@@ -206,7 +206,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 			goto bad_block;
 		entry = next;
 	}
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 	error = -ENODATA;
 	goto cleanup;
@@ -219,20 +219,20 @@ found:
 	    le16_to_cpu(entry->e_value_offs) + size > inode->i_sb->s_blocksize)
 		goto bad_block;
 
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 	if (buffer) {
 		error = -ERANGE;
 		if (size > buffer_size)
 			goto cleanup;
 		/* return value of attribute */
-		memcpy(buffer, bh->b_data + le16_to_cpu(entry->e_value_offs),
+		memcpy(buffer, fsb->data + le16_to_cpu(entry->e_value_offs),
 			size);
 	}
 	error = size;
 
 cleanup:
-	brelse(bh);
+	mbrelse(fsb);
 	up_read(&EXT2_I(inode)->xattr_sem);
 
 	return error;
@@ -251,7 +251,7 @@ cleanup:
 static int
 ext2_xattr_list(struct inode *inode, char *buffer, size_t buffer_size)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_entry *entry;
 	char *end;
 	size_t rest = buffer_size;
@@ -265,15 +265,15 @@ ext2_xattr_list(struct inode *inode, cha
 	if (!EXT2_I(inode)->i_file_acl)
 		goto cleanup;
 	ea_idebug(inode, "reading block %d", EXT2_I(inode)->i_file_acl);
-	bh = sb_bread(inode->i_sb, EXT2_I(inode)->i_file_acl);
+	fsb = sb_mbread(inode->i_sb, EXT2_I(inode)->i_file_acl);
 	error = -EIO;
-	if (!bh)
+	if (!fsb)
 		goto cleanup;
-	ea_bdebug(bh, "b_count=%d, refcount=%d",
-		atomic_read(&(bh->b_count)), le32_to_cpu(HDR(bh)->h_refcount));
-	end = bh->b_data + bh->b_size;
-	if (HDR(bh)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
-	    HDR(bh)->h_blocks != cpu_to_le32(1)) {
+	ea_bdebug(fsb, "count=%d, refcount=%d",
+		atomic_read(&(fsb->count)), le32_to_cpu(HDR(bh)->h_refcount));
+	end = fsb->data + fsblock_size(fsb);
+	if (HDR(fsb)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
+	    HDR(fsb)->h_blocks != cpu_to_le32(1)) {
 bad_block:	ext2_error(inode->i_sb, "ext2_xattr_list",
 			"inode %ld: bad block %d", inode->i_ino,
 			EXT2_I(inode)->i_file_acl);
@@ -282,7 +282,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	}
 
 	/* check the on-disk data structure */
-	entry = FIRST_ENTRY(bh);
+	entry = FIRST_ENTRY(fsb);
 	while (!IS_LAST_ENTRY(entry)) {
 		struct ext2_xattr_entry *next = EXT2_XATTR_NEXT(entry);
 
@@ -290,11 +290,11 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 			goto bad_block;
 		entry = next;
 	}
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 
 	/* list the attribute names */
-	for (entry = FIRST_ENTRY(bh); !IS_LAST_ENTRY(entry);
+	for (entry = FIRST_ENTRY(fsb); !IS_LAST_ENTRY(entry);
 	     entry = EXT2_XATTR_NEXT(entry)) {
 		struct xattr_handler *handler =
 			ext2_xattr_handler(entry->e_name_index);
@@ -316,7 +316,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	error = buffer_size - rest;  /* total size */
 
 cleanup:
-	brelse(bh);
+	mbrelse(fsb);
 	up_read(&EXT2_I(inode)->xattr_sem);
 
 	return error;
@@ -344,7 +344,7 @@ static void ext2_xattr_update_super_bloc
 
 	EXT2_SET_COMPAT_FEATURE(sb, EXT2_FEATURE_COMPAT_EXT_ATTR);
 	sb->s_dirt = 1;
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
 }
 
 /*
@@ -364,7 +364,7 @@ ext2_xattr_set(struct inode *inode, int
 	       const void *value, size_t value_len, int flags)
 {
 	struct super_block *sb = inode->i_sb;
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_header *header = NULL;
 	struct ext2_xattr_entry *here, *last;
 	size_t name_len, free, min_offs = sb->s_blocksize;
@@ -372,7 +372,7 @@ ext2_xattr_set(struct inode *inode, int
 	char *end;
 	
 	/*
-	 * header -- Points either into bh, or to a temporarily
+	 * header -- Points either into fsb, or to a temporarily
 	 *           allocated buffer.
 	 * here -- The named entry found, or the place for inserting, within
 	 *         the block pointed to by header.
@@ -396,15 +396,15 @@ ext2_xattr_set(struct inode *inode, int
 	down_write(&EXT2_I(inode)->xattr_sem);
 	if (EXT2_I(inode)->i_file_acl) {
 		/* The inode already has an extended attribute block. */
-		bh = sb_bread(sb, EXT2_I(inode)->i_file_acl);
+		fsb = sb_mbread(sb, EXT2_I(inode)->i_file_acl);
 		error = -EIO;
-		if (!bh)
+		if (!fsb)
 			goto cleanup;
-		ea_bdebug(bh, "b_count=%d, refcount=%d",
-			atomic_read(&(bh->b_count)),
-			le32_to_cpu(HDR(bh)->h_refcount));
-		header = HDR(bh);
-		end = bh->b_data + bh->b_size;
+		ea_bdebug(fsb, "count=%d, refcount=%d",
+			atomic_read(&(fsb->count)),
+			le32_to_cpu(HDR(fsb)->h_refcount));
+		header = HDR(fsb);
+		end = fsb->data + fsblock_size(fsb);
 		if (header->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
 		    header->h_blocks != cpu_to_le32(1)) {
 bad_block:		ext2_error(sb, "ext2_xattr_set",
@@ -414,7 +414,7 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 			goto cleanup;
 		}
 		/* Find the named attribute. */
-		here = FIRST_ENTRY(bh);
+		here = FIRST_ENTRY(fsb);
 		while (!IS_LAST_ENTRY(here)) {
 			struct ext2_xattr_entry *next = EXT2_XATTR_NEXT(here);
 			if ((char *)next >= end)
@@ -488,12 +488,12 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 	if (header) {
 		struct mb_cache_entry *ce;
 
-		/* assert(header == HDR(bh)); */
-		ce = mb_cache_entry_get(ext2_xattr_cache, bh->b_bdev,
-					bh->b_blocknr);
-		lock_buffer(bh);
+		/* assert(header == HDR(fsb)); */
+		ce = mb_cache_entry_get(ext2_xattr_cache, fsb->b_bdev,
+					fsb->blocknr);
+		lock_block(fsb);
 		if (header->h_refcount == cpu_to_le32(1)) {
-			ea_bdebug(bh, "modifying in-place");
+			ea_bdebug(fsb, "modifying in-place");
 			if (ce)
 				mb_cache_entry_free(ce);
 			/* keep the buffer locked while modifying it. */
@@ -502,18 +502,18 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 
 			if (ce)
 				mb_cache_entry_release(ce);
-			unlock_buffer(bh);
-			ea_bdebug(bh, "cloning");
-			header = kmalloc(bh->b_size, GFP_KERNEL);
+			unlock_block(fsb);
+			ea_bdebug(fsb, "cloning");
+			header = kmalloc(fsb->b_size, GFP_KERNEL);
 			error = -ENOMEM;
 			if (header == NULL)
 				goto cleanup;
-			memcpy(header, HDR(bh), bh->b_size);
+			memcpy(header, HDR(fsb), fsb->b_size);
 			header->h_refcount = cpu_to_le32(1);
 
-			offset = (char *)here - bh->b_data;
+			offset = (char *)here - fsb->data;
 			here = ENTRY((char *)header + offset);
-			offset = (char *)last - bh->b_data;
+			offset = (char *)last - fsb->data;
 			last = ENTRY((char *)header + offset);
 		}
 	} else {
@@ -528,7 +528,7 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 		last = here = ENTRY(header+1);
 	}
 
-	/* Iff we are modifying the block in-place, bh is locked here. */
+	/* Iff we are modifying the block in-place, fsb is locked here. */
 
 	if (not_found) {
 		/* Insert the new name. */
@@ -600,19 +600,19 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 skip_replace:
 	if (IS_LAST_ENTRY(ENTRY(header+1))) {
 		/* This block is now empty. */
-		if (bh && header == HDR(bh))
-			unlock_buffer(bh);  /* we were modifying in-place. */
-		error = ext2_xattr_set2(inode, bh, NULL);
+		if (fsb && header == HDR(fsb))
+			unlock_buffer(fsb);  /* we were modifying in-place. */
+		error = ext2_xattr_set2(inode, fsb, NULL);
 	} else {
 		ext2_xattr_rehash(header, here);
-		if (bh && header == HDR(bh))
-			unlock_buffer(bh);  /* we were modifying in-place. */
-		error = ext2_xattr_set2(inode, bh, header);
+		if (fsb && header == HDR(fsb))
+			unlock_buffer(fsb);  /* we were modifying in-place. */
+		error = ext2_xattr_set2(inode, fsb, header);
 	}
 
 cleanup:
-	brelse(bh);
-	if (!(bh && header == HDR(bh)))
+	mbrelse(fsb);
+	if (!(fsb && header == HDR(fsb)))
 		kfree(header);
 	up_write(&EXT2_I(inode)->xattr_sem);
 
@@ -623,11 +623,11 @@ cleanup:
  * Second half of ext2_xattr_set(): Update the file system.
  */
 static int
-ext2_xattr_set2(struct inode *inode, struct buffer_head *old_bh,
+ext2_xattr_set2(struct inode *inode, struct fsblock *old_fsb,
 		struct ext2_xattr_header *header)
 {
 	struct super_block *sb = inode->i_sb;
-	struct buffer_head *new_bh = NULL;
+	struct fsblock *new_fsb = NULL;
 	int error;
 
 	if (header) {
@@ -754,7 +754,7 @@ cleanup:
 void
 ext2_xattr_delete_inode(struct inode *inode)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct mb_cache_entry *ce;
 
 	down_write(&EXT2_I(inode)->xattr_sem);
@@ -824,7 +824,7 @@ ext2_xattr_put_super(struct super_block
  * Returns 0, or a negative error number on failure.
  */
 static int
-ext2_xattr_cache_insert(struct buffer_head *bh)
+ext2_xattr_cache_insert(struct fsblock *fsb)
 {
 	__u32 hash = le32_to_cpu(HDR(bh)->h_hash);
 	struct mb_cache_entry *ce;
@@ -897,7 +897,7 @@ ext2_xattr_cmp(struct ext2_xattr_header
  * Returns a locked buffer head to the block found, or NULL if such
  * a block was not found or an error occurred.
  */
-static struct buffer_head *
+static struct fsblock *
 ext2_xattr_cache_find(struct inode *inode, struct ext2_xattr_header *header)
 {
 	__u32 hash = le32_to_cpu(header->h_hash);
@@ -910,7 +910,7 @@ again:
 	ce = mb_cache_entry_find_first(ext2_xattr_cache, 0,
 				       inode->i_sb->s_bdev, hash);
 	while (ce) {
-		struct buffer_head *bh;
+		struct fsblock *fsb;
 
 		if (IS_ERR(ce)) {
 			if (PTR_ERR(ce) == -EAGAIN)
Index: linux-2.6/fs/ext2/xip.c
===================================================================
--- linux-2.6.orig/fs/ext2/xip.c
+++ linux-2.6/fs/ext2/xip.c
@@ -8,7 +8,7 @@
 #include <linux/mm.h>
 #include <linux/fs.h>
 #include <linux/genhd.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/ext2_fs_sb.h>
 #include <linux/ext2_fs.h>
 #include <linux/blkdev.h>
@@ -33,16 +33,16 @@ static inline int
 __ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 		   sector_t *result)
 {
-	struct buffer_head tmp;
+	struct fsblock tmp;
 	int rc;
 
-	memset(&tmp, 0, sizeof(struct buffer_head));
-	rc = ext2_get_block(inode, pgoff, &tmp, create);
-	*result = tmp.b_blocknr;
+	memset(&tmp, 0, sizeof(struct fsblock));
+	rc = ext2_map_block(inode, pgoff, &tmp, create);
+	*result = tmp.blocknr;
 
 	/* did we get a sparse block (hole in the file)? */
-	if (!tmp.b_blocknr && !rc) {
-		BUG_ON(create);
+	if (!tmp.blocknr && !rc) {
+		WARN_ON(create);
 		rc = -ENODATA;
 	}
 
Index: linux-2.6/include/linux/ext2_fs_sb.h
===================================================================
--- linux-2.6.orig/include/linux/ext2_fs_sb.h
+++ linux-2.6/include/linux/ext2_fs_sb.h
@@ -19,6 +19,7 @@
 #include <linux/blockgroup_lock.h>
 #include <linux/percpu_counter.h>
 #include <linux/rbtree.h>
+#include <linux/fsblock.h>
 
 /* XXX Here for now... not interested in restructing headers JUST now */
 
@@ -81,9 +82,9 @@ struct ext2_sb_info {
 	unsigned long s_groups_count;	/* Number of groups in the fs */
 	unsigned long s_overhead_last;  /* Last calculated overhead */
 	unsigned long s_blocks_last;    /* Last seen block count */
-	struct buffer_head * s_sbh;	/* Buffer containing the super block */
+	struct fsblock_meta * s_smb;	/* Buffer containing the super block */
 	struct ext2_super_block * s_es;	/* Pointer to the super block in the buffer */
-	struct buffer_head ** s_group_desc;
+	struct fsblock_meta ** s_group_desc;
 	unsigned long  s_mount_opt;
 	unsigned long s_sb_block;
 	uid_t s_resuid;
@@ -106,6 +107,7 @@ struct ext2_sb_info {
 	spinlock_t s_rsv_window_lock;
 	struct rb_root s_rsv_window_root;
 	struct ext2_reserve_window_node s_rsv_window_head;
+	struct fsblock_sb fsb_sb;
 };
 
 static inline spinlock_t *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
