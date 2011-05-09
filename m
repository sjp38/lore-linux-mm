Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDFE6B0024
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:04:15 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p49Mbun4000322
	for <linux-mm@kvack.org>; Mon, 9 May 2011 18:38:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p49N47241200312
	for <linux-mm@kvack.org>; Mon, 9 May 2011 19:04:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p49N46kv018217
	for <linux-mm@kvack.org>; Mon, 9 May 2011 19:04:07 -0400
Subject: [PATCH 6/7] ext2: Lock buffer_head during metadata update
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Mon, 09 May 2011 16:04:04 -0700
Message-ID: <20110509230404.19566.60575.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

ext2 does not protect memory pages containing metadata against writes during
disk write operations.  To stabilize the page during a write, lock the
buffer_head while updating metadata pages.

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 fs/ext2/balloc.c |    6 ++++++
 fs/ext2/ialloc.c |    7 +++++++
 fs/ext2/inode.c  |    7 +++++++
 fs/ext2/super.c  |    2 ++
 fs/ext2/xattr.c  |    2 ++
 5 files changed, 24 insertions(+), 0 deletions(-)


diff --git a/fs/ext2/balloc.c b/fs/ext2/balloc.c
index 8f44cef..50d7d4c 100644
--- a/fs/ext2/balloc.c
+++ b/fs/ext2/balloc.c
@@ -176,10 +176,12 @@ static void group_adjust_blocks(struct super_block *sb, int group_no,
 		struct ext2_sb_info *sbi = EXT2_SB(sb);
 		unsigned free_blocks;
 
+		lock_buffer(bh);
 		spin_lock(sb_bgl_lock(sbi, group_no));
 		free_blocks = le16_to_cpu(desc->bg_free_blocks_count);
 		desc->bg_free_blocks_count = cpu_to_le16(free_blocks + count);
 		spin_unlock(sb_bgl_lock(sbi, group_no));
+		unlock_buffer(bh);
 		sb->s_dirt = 1;
 		mark_buffer_dirty(bh);
 	}
@@ -546,6 +548,7 @@ do_more:
 		goto error_return;
 	}
 
+	lock_buffer(bitmap_bh);
 	for (i = 0, group_freed = 0; i < count; i++) {
 		if (!ext2_clear_bit_atomic(sb_bgl_lock(sbi, block_group),
 						bit + i, bitmap_bh->b_data)) {
@@ -555,6 +558,7 @@ do_more:
 			group_freed++;
 		}
 	}
+	unlock_buffer(bitmap_bh);
 
 	mark_buffer_dirty(bitmap_bh);
 	if (sb->s_flags & MS_SYNCHRONOUS)
@@ -1351,8 +1355,10 @@ retry_alloc:
 		/*
 		 * try to allocate block(s) from this group, without a goal(-1).
 		 */
+		lock_buffer(bitmap_bh);
 		grp_alloc_blk = ext2_try_to_allocate_with_rsv(sb, group_no,
 					bitmap_bh, -1, my_rsv, &num);
+		unlock_buffer(bitmap_bh);
 		if (grp_alloc_blk >= 0)
 			goto allocated;
 	}
diff --git a/fs/ext2/ialloc.c b/fs/ext2/ialloc.c
index ee9ed31..3bf624f 100644
--- a/fs/ext2/ialloc.c
+++ b/fs/ext2/ialloc.c
@@ -74,11 +74,13 @@ static void ext2_release_inode(struct super_block *sb, int group, int dir)
 		return;
 	}
 
+	lock_buffer(bh);
 	spin_lock(sb_bgl_lock(EXT2_SB(sb), group));
 	le16_add_cpu(&desc->bg_free_inodes_count, 1);
 	if (dir)
 		le16_add_cpu(&desc->bg_used_dirs_count, -1);
 	spin_unlock(sb_bgl_lock(EXT2_SB(sb), group));
+	unlock_buffer(bh);
 	if (dir)
 		percpu_counter_dec(&EXT2_SB(sb)->s_dirs_counter);
 	sb->s_dirt = 1;
@@ -139,12 +141,14 @@ void ext2_free_inode (struct inode * inode)
 		return;
 
 	/* Ok, now we can actually update the inode bitmaps.. */
+	lock_buffer(bitmap_bh);
 	if (!ext2_clear_bit_atomic(sb_bgl_lock(EXT2_SB(sb), block_group),
 				bit, (void *) bitmap_bh->b_data))
 		ext2_error (sb, "ext2_free_inode",
 			      "bit already cleared for inode %lu", ino);
 	else
 		ext2_release_inode(sb, block_group, is_directory);
+	unlock_buffer(bitmap_bh);
 	mark_buffer_dirty(bitmap_bh);
 	if (sb->s_flags & MS_SYNCHRONOUS)
 		sync_dirty_buffer(bitmap_bh);
@@ -491,8 +495,10 @@ repeat_in_this_group:
 				group = 0;
 			continue;
 		}
+		lock_buffer(bitmap_bh);
 		if (ext2_set_bit_atomic(sb_bgl_lock(sbi, group),
 						ino, bitmap_bh->b_data)) {
+			unlock_buffer(bitmap_bh);
 			/* we lost this inode */
 			if (++ino >= EXT2_INODES_PER_GROUP(sb)) {
 				/* this group is exhausted, try next group */
@@ -503,6 +509,7 @@ repeat_in_this_group:
 			/* try to find free inode in the same group */
 			goto repeat_in_this_group;
 		}
+		unlock_buffer(bitmap_bh);
 		goto got;
 	}
 
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 788e09a..f102b82 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -557,11 +557,15 @@ static void ext2_splice_branch(struct inode *inode,
 	 * Update the host buffer_head or inode to point to more just allocated
 	 * direct blocks blocks
 	 */
+	if (where->bh)
+		lock_buffer(where->bh);
 	if (num == 0 && blks > 1) {
 		current_block = le32_to_cpu(where->key) + 1;
 		for (i = 1; i < blks; i++)
 			*(where->p + i ) = cpu_to_le32(current_block++);
 	}
+	if (where->bh)
+		unlock_buffer(where->bh);
 
 	/*
 	 * update the most recently allocated logical & physical block
@@ -1426,6 +1430,7 @@ static int __ext2_write_inode(struct inode *inode, int do_sync)
 	if (IS_ERR(raw_inode))
  		return -EIO;
 
+	lock_buffer(bh);
 	/* For fields not not tracking in the in-memory inode,
 	 * initialise them to zero for new inodes. */
 	if (ei->i_state & EXT2_STATE_NEW)
@@ -1502,6 +1507,8 @@ static int __ext2_write_inode(struct inode *inode, int do_sync)
 		}
 	} else for (n = 0; n < EXT2_N_BLOCKS; n++)
 		raw_inode->i_block[n] = ei->i_data[n];
+	unlock_buffer(bh);
+
 	mark_buffer_dirty(bh);
 	if (do_sync) {
 		sync_dirty_buffer(bh);
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 0a78dae..be2c9ca 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1152,12 +1152,14 @@ static void ext2_sync_super(struct super_block *sb, struct ext2_super_block *es,
 			    int wait)
 {
 	ext2_clear_super_error(sb);
+	lock_buffer(EXT2_SB(sb)->s_sbh);
 	spin_lock(&EXT2_SB(sb)->s_lock);
 	es->s_free_blocks_count = cpu_to_le32(ext2_count_free_blocks(sb));
 	es->s_free_inodes_count = cpu_to_le32(ext2_count_free_inodes(sb));
 	es->s_wtime = cpu_to_le32(get_seconds());
 	/* unlock before we do IO */
 	spin_unlock(&EXT2_SB(sb)->s_lock);
+	unlock_buffer(EXT2_SB(sb)->s_sbh);
 	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
 	if (wait)
 		sync_dirty_buffer(EXT2_SB(sb)->s_sbh);
diff --git a/fs/ext2/xattr.c b/fs/ext2/xattr.c
index 5299706..2e0652d 100644
--- a/fs/ext2/xattr.c
+++ b/fs/ext2/xattr.c
@@ -337,9 +337,11 @@ static void ext2_xattr_update_super_block(struct super_block *sb)
 	if (EXT2_HAS_COMPAT_FEATURE(sb, EXT2_FEATURE_COMPAT_EXT_ATTR))
 		return;
 
+	lock_buffer(EXT2_SB(sb)->s_sbh);
 	spin_lock(&EXT2_SB(sb)->s_lock);
 	EXT2_SET_COMPAT_FEATURE(sb, EXT2_FEATURE_COMPAT_EXT_ATTR);
 	spin_unlock(&EXT2_SB(sb)->s_lock);
+	unlock_buffer(EXT2_SB(sb)->s_sbh);
 	sb->s_dirt = 1;
 	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
