Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA24F6B0283
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:32 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w17so15483319qkb.19
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 6si6741663qtx.305.2018.04.04.12.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:29 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 70/79] mm: add struct address_space to mark_buffer_dirty()
Date: Wed,  4 Apr 2018 15:18:22 -0400
Message-Id: <20180404191831.5378-33-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct address_space to mark_buffer_dirty() arguments.

<---------------------------------------------------------------------
@@
identifier I1;
type T1;
@@
void
-mark_buffer_dirty(T1 I1)
+mark_buffer_dirty(struct address_space *_mapping, T1 I1)
{...}

@@
type T1;
@@
void
-mark_buffer_dirty(T1)
+mark_buffer_dirty(struct address_space *, T1)
;

@@
identifier I1;
type T1;
@@
void
-mark_buffer_dirty(T1 I1)
+mark_buffer_dirty(struct address_space *, T1)
;

@@
expression E1;
@@
-mark_buffer_dirty(E1)
+mark_buffer_dirty(NULL, E1)
--------------------------------------------------------------------->

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/adfs/dir_f.c             |  2 +-
 fs/affs/bitmap.c            |  6 +++---
 fs/affs/super.c             |  2 +-
 fs/bfs/file.c               |  2 +-
 fs/bfs/inode.c              |  4 ++--
 fs/buffer.c                 | 12 ++++++------
 fs/ext2/balloc.c            |  6 +++---
 fs/ext2/ialloc.c            |  8 ++++----
 fs/ext2/inode.c             |  2 +-
 fs/ext2/super.c             |  4 ++--
 fs/ext2/xattr.c             |  8 ++++----
 fs/ext4/ext4_jbd2.c         |  4 ++--
 fs/ext4/inode.c             |  4 ++--
 fs/ext4/mmp.c               |  2 +-
 fs/ext4/resize.c            |  2 +-
 fs/ext4/super.c             |  2 +-
 fs/fat/inode.c              |  4 ++--
 fs/fat/misc.c               |  2 +-
 fs/gfs2/bmap.c              |  4 ++--
 fs/gfs2/lops.c              |  6 +++---
 fs/hfs/mdb.c                | 10 +++++-----
 fs/hpfs/anode.c             | 34 +++++++++++++++++-----------------
 fs/hpfs/buffer.c            |  8 ++++----
 fs/hpfs/dnode.c             |  4 ++--
 fs/hpfs/ea.c                |  4 ++--
 fs/hpfs/inode.c             |  2 +-
 fs/hpfs/namei.c             | 10 +++++-----
 fs/hpfs/super.c             |  6 +++---
 fs/jbd2/recovery.c          |  2 +-
 fs/jbd2/transaction.c       |  2 +-
 fs/jfs/jfs_imap.c           |  2 +-
 fs/jfs/jfs_mount.c          |  2 +-
 fs/jfs/resize.c             |  6 +++---
 fs/jfs/super.c              |  2 +-
 fs/minix/bitmap.c           | 10 +++++-----
 fs/minix/inode.c            | 12 ++++++------
 fs/nilfs2/alloc.c           | 12 ++++++------
 fs/nilfs2/btnode.c          |  4 ++--
 fs/nilfs2/btree.c           | 38 +++++++++++++++++++-------------------
 fs/nilfs2/cpfile.c          | 24 ++++++++++++------------
 fs/nilfs2/dat.c             |  4 ++--
 fs/nilfs2/gcinode.c         |  2 +-
 fs/nilfs2/ifile.c           |  4 ++--
 fs/nilfs2/inode.c           |  2 +-
 fs/nilfs2/ioctl.c           |  2 +-
 fs/nilfs2/mdt.c             |  2 +-
 fs/nilfs2/segment.c         |  4 ++--
 fs/nilfs2/sufile.c          | 26 +++++++++++++-------------
 fs/ntfs/file.c              |  8 ++++----
 fs/ntfs/super.c             |  2 +-
 fs/ocfs2/alloc.c            |  2 +-
 fs/ocfs2/aops.c             |  4 ++--
 fs/ocfs2/inode.c            |  2 +-
 fs/omfs/bitmap.c            |  6 +++---
 fs/omfs/dir.c               |  8 ++++----
 fs/omfs/file.c              |  4 ++--
 fs/omfs/inode.c             |  4 ++--
 fs/reiserfs/file.c          |  2 +-
 fs/reiserfs/inode.c         |  4 ++--
 fs/reiserfs/journal.c       | 10 +++++-----
 fs/reiserfs/resize.c        |  2 +-
 fs/sysv/balloc.c            |  2 +-
 fs/sysv/ialloc.c            |  2 +-
 fs/sysv/inode.c             |  8 ++++----
 fs/sysv/sysv.h              |  4 ++--
 fs/udf/balloc.c             |  6 +++---
 fs/udf/inode.c              |  2 +-
 fs/udf/partition.c          |  4 ++--
 fs/udf/super.c              |  8 ++++----
 fs/ufs/balloc.c             |  4 ++--
 fs/ufs/ialloc.c             |  4 ++--
 fs/ufs/inode.c              |  8 ++++----
 fs/ufs/util.c               |  2 +-
 include/linux/buffer_head.h |  2 +-
 74 files changed, 220 insertions(+), 220 deletions(-)

diff --git a/fs/adfs/dir_f.c b/fs/adfs/dir_f.c
index 0fbfd0b04ae0..3d92f8d187bc 100644
--- a/fs/adfs/dir_f.c
+++ b/fs/adfs/dir_f.c
@@ -434,7 +434,7 @@ adfs_f_update(struct adfs_dir *dir, struct object_info *obj)
 	}
 #endif
 	for (i = dir->nr_buffers - 1; i >= 0; i--)
-		mark_buffer_dirty(dir->bh[i]);
+		mark_buffer_dirty(NULL, dir->bh[i]);
 
 	ret = 0;
 out:
diff --git a/fs/affs/bitmap.c b/fs/affs/bitmap.c
index 5ba9ef2742f6..59b352075505 100644
--- a/fs/affs/bitmap.c
+++ b/fs/affs/bitmap.c
@@ -79,7 +79,7 @@ affs_free_block(struct super_block *sb, u32 block)
 	tmp = be32_to_cpu(*(__be32 *)bh->b_data);
 	*(__be32 *)bh->b_data = cpu_to_be32(tmp - mask);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	affs_mark_sb_dirty(sb);
 	bm->bm_free++;
 
@@ -223,7 +223,7 @@ affs_alloc_block(struct inode *inode, u32 goal)
 	tmp = be32_to_cpu(*(__be32 *)bh->b_data);
 	*(__be32 *)bh->b_data = cpu_to_be32(tmp + mask);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	affs_mark_sb_dirty(sb);
 
 	mutex_unlock(&sbi->s_bmlock);
@@ -338,7 +338,7 @@ int affs_init_bitmap(struct super_block *sb, int *flags)
 		((__be32 *)bh->b_data)[offset] = 0;
 	((__be32 *)bh->b_data)[0] = 0;
 	((__be32 *)bh->b_data)[0] = cpu_to_be32(-affs_checksum_block(sb, bh));
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 
 	/* recalculate bitmap count for last block */
 	bm--;
diff --git a/fs/affs/super.c b/fs/affs/super.c
index e602619aed9d..515388985607 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -40,7 +40,7 @@ affs_commit_super(struct super_block *sb, int wait)
 	affs_fix_checksum(sb, bh);
 	unlock_buffer(bh);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (wait)
 		sync_dirty_buffer(bh);
 }
diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index 6d66cc137bc3..e74e1b72df80 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -40,7 +40,7 @@ static int bfs_move_block(unsigned long from, unsigned long to,
 		return -EIO;
 	new = sb_getblk(sb, to);
 	memcpy(new->b_data, bh->b_data, bh->b_size);
-	mark_buffer_dirty(new);
+	mark_buffer_dirty(NULL, new);
 	bforget(sb, bh);
 	brelse(new);
 	return 0;
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 9a69392f1fb3..a41edad61187 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -149,7 +149,7 @@ static int bfs_write_inode(struct inode *inode, struct writeback_control *wbc)
 	di->i_eblock = cpu_to_le32(BFS_I(inode)->i_eblock);
 	di->i_eoffset = cpu_to_le32(i_sblock * BFS_BSIZE + inode->i_size - 1);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (wbc->sync_mode == WB_SYNC_ALL) {
 		sync_dirty_buffer(bh);
 		if (buffer_req(bh) && !buffer_uptodate(bh))
@@ -185,7 +185,7 @@ static void bfs_evict_inode(struct inode *inode)
 	mutex_lock(&info->bfs_lock);
 	/* clear on-disk inode */
 	memset(di, 0, sizeof(struct bfs_inode));
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 
         if (bi->i_dsk_ino) {
diff --git a/fs/buffer.c b/fs/buffer.c
index 27b19c629308..24872b077269 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -574,7 +574,7 @@ void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode)
 
 	buffer_mapping = fs_page_mapping_get_with_bh(bh->b_page, bh);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (!mapping->private_data) {
 		mapping->private_data = buffer_mapping;
 	} else {
@@ -1102,7 +1102,7 @@ __getblk_slow(struct block_device *bdev, sector_t block,
  * mark_buffer_dirty() is atomic.  It takes bh->b_page->mapping->private_lock,
  * mapping->tree_lock and mapping->host->i_lock.
  */
-void mark_buffer_dirty(struct buffer_head *bh)
+void mark_buffer_dirty(struct address_space *_mapping, struct buffer_head *bh)
 {
 	WARN_ON_ONCE(!buffer_uptodate(bh));
 
@@ -1891,7 +1891,7 @@ void page_zero_new_buffers(struct address_space *buffer, struct page *page,
 				}
 
 				clear_buffer_new(bh);
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 			}
 		}
 
@@ -2006,7 +2006,7 @@ int __block_write_begin_int(struct address_space *mapping, struct page *page,
 				if (PageUptodate(page)) {
 					clear_buffer_new(bh);
 					set_buffer_uptodate(bh);
-					mark_buffer_dirty(bh);
+					mark_buffer_dirty(NULL, bh);
 					continue;
 				}
 				if (block_end > to || block_start < from)
@@ -2068,7 +2068,7 @@ static int __block_commit_write(struct inode *inode, struct page *page,
 				partial = 1;
 		} else {
 			set_buffer_uptodate(bh);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		}
 		clear_buffer_new(bh);
 
@@ -2937,7 +2937,7 @@ int block_truncate_page(struct address_space *mapping,
 	}
 
 	zero_user(page, offset, length);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	err = 0;
 
 unlock:
diff --git a/fs/ext2/balloc.c b/fs/ext2/balloc.c
index 33db13365c5e..e9e4a9f477fe 100644
--- a/fs/ext2/balloc.c
+++ b/fs/ext2/balloc.c
@@ -172,7 +172,7 @@ static void group_adjust_blocks(struct super_block *sb, int group_no,
 		free_blocks = le16_to_cpu(desc->bg_free_blocks_count);
 		desc->bg_free_blocks_count = cpu_to_le16(free_blocks + count);
 		spin_unlock(sb_bgl_lock(sbi, group_no));
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	}
 }
 
@@ -547,7 +547,7 @@ void ext2_free_blocks (struct inode * inode, unsigned long block,
 		}
 	}
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_buffer_dirty(NULL, bitmap_bh);
 	if (sb->s_flags & SB_SYNCHRONOUS)
 		sync_dirty_buffer(bitmap_bh);
 
@@ -1423,7 +1423,7 @@ ext2_fsblk_t ext2_new_blocks(struct inode *inode, ext2_fsblk_t goal,
 	group_adjust_blocks(sb, group_no, gdp, gdp_bh, -num);
 	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_buffer_dirty(NULL, bitmap_bh);
 	if (sb->s_flags & SB_SYNCHRONOUS)
 		sync_dirty_buffer(bitmap_bh);
 
diff --git a/fs/ext2/ialloc.c b/fs/ext2/ialloc.c
index 6484199b35d1..c444c3c1ebcb 100644
--- a/fs/ext2/ialloc.c
+++ b/fs/ext2/ialloc.c
@@ -82,7 +82,7 @@ static void ext2_release_inode(struct super_block *sb, int group, int dir)
 	spin_unlock(sb_bgl_lock(EXT2_SB(sb), group));
 	if (dir)
 		percpu_counter_dec(&EXT2_SB(sb)->s_dirs_counter);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 }
 
 /*
@@ -144,7 +144,7 @@ void ext2_free_inode (struct inode * inode)
 			      "bit already cleared for inode %lu", ino);
 	else
 		ext2_release_inode(sb, block_group, is_directory);
-	mark_buffer_dirty(bitmap_bh);
+	mark_buffer_dirty(NULL, bitmap_bh);
 	if (sb->s_flags & SB_SYNCHRONOUS)
 		sync_dirty_buffer(bitmap_bh);
 
@@ -516,7 +516,7 @@ struct inode *ext2_new_inode(struct inode *dir, umode_t mode,
 	err = -ENOSPC;
 	goto fail;
 got:
-	mark_buffer_dirty(bitmap_bh);
+	mark_buffer_dirty(NULL, bitmap_bh);
 	if (sb->s_flags & SB_SYNCHRONOUS)
 		sync_dirty_buffer(bitmap_bh);
 	brelse(bitmap_bh);
@@ -547,7 +547,7 @@ struct inode *ext2_new_inode(struct inode *dir, umode_t mode,
 	}
 	spin_unlock(sb_bgl_lock(sbi, group));
 
-	mark_buffer_dirty(bh2);
+	mark_buffer_dirty(NULL, bh2);
 	if (test_opt(sb, GRPID)) {
 		inode->i_mode = mode;
 		inode->i_uid = current_fsuid();
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index bc12273e393a..4c1782d0d0c0 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1621,7 +1621,7 @@ static int __ext2_write_inode(struct inode *inode, int do_sync)
 		}
 	} else for (n = 0; n < EXT2_N_BLOCKS; n++)
 		raw_inode->i_block[n] = ei->i_data[n];
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (do_sync) {
 		sync_dirty_buffer(bh);
 		if (buffer_req(bh) && !buffer_uptodate(bh)) {
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 7666c065b96f..62cab57b448f 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -1247,7 +1247,7 @@ void ext2_sync_super(struct super_block *sb, struct ext2_super_block *es,
 	es->s_wtime = cpu_to_le32(get_seconds());
 	/* unlock before we do IO */
 	spin_unlock(&EXT2_SB(sb)->s_lock);
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_buffer_dirty(NULL, EXT2_SB(sb)->s_sbh);
 	if (wait)
 		sync_dirty_buffer(EXT2_SB(sb)->s_sbh);
 }
@@ -1562,7 +1562,7 @@ static ssize_t ext2_quota_write(struct super_block *sb, int type,
 		memcpy(bh->b_data+offset, data, tocopy);
 		flush_dcache_page(bh->b_page);
 		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		unlock_buffer(bh);
 		brelse(bh);
 		offset = 0;
diff --git a/fs/ext2/xattr.c b/fs/ext2/xattr.c
index c77edf9afbce..8f3b1950248b 100644
--- a/fs/ext2/xattr.c
+++ b/fs/ext2/xattr.c
@@ -344,7 +344,7 @@ static void ext2_xattr_update_super_block(struct super_block *sb)
 	spin_lock(&EXT2_SB(sb)->s_lock);
 	EXT2_SET_COMPAT_FEATURE(sb, EXT2_FEATURE_COMPAT_EXT_ATTR);
 	spin_unlock(&EXT2_SB(sb)->s_lock);
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_buffer_dirty(NULL, EXT2_SB(sb)->s_sbh);
 }
 
 /*
@@ -683,7 +683,7 @@ ext2_xattr_set2(struct inode *inode, struct buffer_head *old_bh,
 			
 			ext2_xattr_update_super_block(sb);
 		}
-		mark_buffer_dirty(new_bh);
+		mark_buffer_dirty(NULL, new_bh);
 		if (IS_SYNC(inode)) {
 			sync_dirty_buffer(new_bh);
 			error = -EIO;
@@ -739,7 +739,7 @@ ext2_xattr_set2(struct inode *inode, struct buffer_head *old_bh,
 			le32_add_cpu(&HDR(old_bh)->h_refcount, -1);
 			dquot_free_block_nodirty(inode, 1);
 			mark_inode_dirty(inode);
-			mark_buffer_dirty(old_bh);
+			mark_buffer_dirty(NULL, old_bh);
 			ea_bdebug(old_bh, "refcount now=%d",
 				le32_to_cpu(HDR(old_bh)->h_refcount));
 		}
@@ -809,7 +809,7 @@ ext2_xattr_delete_inode(struct inode *inode)
 		ea_bdebug(bh, "refcount now=%d",
 			le32_to_cpu(HDR(bh)->h_refcount));
 		unlock_buffer(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		if (IS_SYNC(inode))
 			sync_dirty_buffer(bh);
 		dquot_free_block_nodirty(inode, 1);
diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 60fbf5336059..72209e854a19 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -302,7 +302,7 @@ int __ext4_handle_dirty_metadata(const char *where, unsigned int line,
 		if (inode)
 			mark_buffer_dirty_inode(bh, inode);
 		else
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		if (inode && inode_needs_sync(inode)) {
 			sync_dirty_buffer(bh);
 			if (buffer_req(bh) && !buffer_uptodate(bh)) {
@@ -334,6 +334,6 @@ int __ext4_handle_dirty_super(const char *where, unsigned int line,
 			ext4_journal_abort_handle(where, line, __func__,
 						  bh, handle, err);
 	} else
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	return err;
 }
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ef53a57d9768..c0ae0dc7af58 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1202,7 +1202,7 @@ static int ext4_block_write_begin(struct address_space *mapping,
 				if (PageUptodate(page)) {
 					clear_buffer_new(bh);
 					set_buffer_uptodate(bh);
-					mark_buffer_dirty(bh);
+					mark_buffer_dirty(NULL, bh);
 					continue;
 				}
 				if (block_end > to || block_start < from)
@@ -4070,7 +4070,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		err = ext4_handle_dirty_metadata(handle, inode, bh);
 	} else {
 		err = 0;
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		if (ext4_should_order_data(inode))
 			err = ext4_jbd2_inode_add_write(handle, inode);
 	}
diff --git a/fs/ext4/mmp.c b/fs/ext4/mmp.c
index 27b9a76a0dfa..6fcd8d624ef7 100644
--- a/fs/ext4/mmp.c
+++ b/fs/ext4/mmp.c
@@ -49,7 +49,7 @@ static int write_mmp_block(struct super_block *sb, struct buffer_head *bh)
 	 */
 	sb_start_write(sb);
 	ext4_mmp_csum_set(sb, mmp);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	lock_buffer(bh);
 	bh->b_end_io = end_buffer_write_sync;
 	get_bh(bh);
diff --git a/fs/ext4/resize.c b/fs/ext4/resize.c
index b6bec270a8e4..398cd8c7dd40 100644
--- a/fs/ext4/resize.c
+++ b/fs/ext4/resize.c
@@ -1160,7 +1160,7 @@ static void update_backups(struct super_block *sb, sector_t blk_off, char *data,
 			     "forcing fsck on next reboot", group, err);
 		sbi->s_mount_state &= ~EXT4_VALID_FS;
 		sbi->s_es->s_state &= cpu_to_le16(~EXT4_VALID_FS);
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_buffer_dirty(NULL, sbi->s_sbh);
 	}
 }
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index cf2b74137fb2..ebef69e45f74 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4738,7 +4738,7 @@ static int ext4_commit_super(struct super_block *sb, int sync)
 		clear_buffer_write_io_error(sbh);
 		set_buffer_uptodate(sbh);
 	}
-	mark_buffer_dirty(sbh);
+	mark_buffer_dirty(NULL, sbh);
 	if (sync) {
 		unlock_buffer(sbh);
 		error = __sync_dirty_buffer(sbh,
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 9e6bc6364468..a5cac466caf2 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -695,7 +695,7 @@ static void fat_set_state(struct super_block *sb,
 			b->fat16.state &= ~FAT_STATE_DIRTY;
 	}
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	sync_dirty_buffer(bh);
 	brelse(bh);
 }
@@ -875,7 +875,7 @@ static int __fat_write_inode(struct inode *inode, int wait)
 				  &raw_entry->adate, NULL);
 	}
 	spin_unlock(&sbi->inode_hash_lock);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	err = 0;
 	if (wait)
 		err = sync_dirty_buffer(bh);
diff --git a/fs/fat/misc.c b/fs/fat/misc.c
index f9bdc1e01c98..2f1a027684c4 100644
--- a/fs/fat/misc.c
+++ b/fs/fat/misc.c
@@ -85,7 +85,7 @@ int fat_clusters_flush(struct super_block *sb)
 			fsinfo->free_clusters = cpu_to_le32(sbi->free_clusters);
 		if (sbi->prev_free != -1)
 			fsinfo->next_cluster = cpu_to_le32(sbi->prev_free);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	}
 	brelse(bh);
 
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 12e10758b0f2..32028225306a 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -90,7 +90,7 @@ static int gfs2_unstuffer_page(struct gfs2_inode *ip, struct buffer_head *dibh,
 
 	set_buffer_uptodate(bh);
 	if (!gfs2_is_jdata(ip))
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	if (!gfs2_is_writeback(ip))
 		gfs2_trans_add_data(ip->i_gl, bh);
 
@@ -955,7 +955,7 @@ static int gfs2_block_zero_range(struct inode *inode, loff_t from,
 		gfs2_trans_add_data(ip->i_gl, bh);
 
 	zero_user(page, offset, length);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 unlock:
 	unlock_page(page);
 	put_page(page);
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 3b672378d358..1c7dbf3b1227 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -105,7 +105,7 @@ static void gfs2_unpin(struct gfs2_sbd *sdp, struct buffer_head *bh,
 	BUG_ON(!buffer_pinned(bh));
 
 	lock_buffer(bh);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	clear_buffer_pinned(bh);
 
 	if (buffer_is_rgrp(bd))
@@ -558,7 +558,7 @@ static int buf_lo_scan_elements(struct gfs2_jdesc *jd, unsigned int start,
 		if (gfs2_meta_check(sdp, bh_ip))
 			error = -EIO;
 		else
-			mark_buffer_dirty(bh_ip);
+			mark_buffer_dirty(NULL, bh_ip);
 
 		brelse(bh_log);
 		brelse(bh_ip);
@@ -797,7 +797,7 @@ static int databuf_lo_scan_elements(struct gfs2_jdesc *jd, unsigned int start,
 			__be32 *eptr = (__be32 *)bh_ip->b_data;
 			*eptr = cpu_to_be32(GFS2_MAGIC);
 		}
-		mark_buffer_dirty(bh_ip);
+		mark_buffer_dirty(NULL, bh_ip);
 
 		brelse(bh_log);
 		brelse(bh_ip);
diff --git a/fs/hfs/mdb.c b/fs/hfs/mdb.c
index 460281b1299e..6be25d949b5d 100644
--- a/fs/hfs/mdb.c
+++ b/fs/hfs/mdb.c
@@ -218,7 +218,7 @@ int hfs_mdb_get(struct super_block *sb)
 		be32_add_cpu(&mdb->drWrCnt, 1);
 		mdb->drLsMod = hfs_mtime();
 
-		mark_buffer_dirty(HFS_SB(sb)->mdb_bh);
+		mark_buffer_dirty(NULL, HFS_SB(sb)->mdb_bh);
 		sync_dirty_buffer(HFS_SB(sb)->mdb_bh);
 	}
 
@@ -274,7 +274,7 @@ void hfs_mdb_commit(struct super_block *sb)
 		mdb->drDirCnt = cpu_to_be32(HFS_SB(sb)->folder_count);
 
 		/* write MDB to disk */
-		mark_buffer_dirty(HFS_SB(sb)->mdb_bh);
+		mark_buffer_dirty(NULL, HFS_SB(sb)->mdb_bh);
 	}
 
 	/* write the backup MDB, not returning until it is written.
@@ -293,7 +293,7 @@ void hfs_mdb_commit(struct super_block *sb)
 		HFS_SB(sb)->alt_mdb->drAtrb &= cpu_to_be16(~HFS_SB_ATTRIB_INCNSTNT);
 		unlock_buffer(HFS_SB(sb)->alt_mdb_bh);
 
-		mark_buffer_dirty(HFS_SB(sb)->alt_mdb_bh);
+		mark_buffer_dirty(NULL, HFS_SB(sb)->alt_mdb_bh);
 		sync_dirty_buffer(HFS_SB(sb)->alt_mdb_bh);
 	}
 
@@ -320,7 +320,7 @@ void hfs_mdb_commit(struct super_block *sb)
 			memcpy(bh->b_data + off, ptr, len);
 			unlock_buffer(bh);
 
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			brelse(bh);
 			block++;
 			off = 0;
@@ -338,7 +338,7 @@ void hfs_mdb_close(struct super_block *sb)
 		return;
 	HFS_SB(sb)->mdb->drAtrb |= cpu_to_be16(HFS_SB_ATTRIB_UNMNT);
 	HFS_SB(sb)->mdb->drAtrb &= cpu_to_be16(~HFS_SB_ATTRIB_INCNSTNT);
-	mark_buffer_dirty(HFS_SB(sb)->mdb_bh);
+	mark_buffer_dirty(NULL, HFS_SB(sb)->mdb_bh);
 }
 
 /*
diff --git a/fs/hpfs/anode.c b/fs/hpfs/anode.c
index c14c9a035ee0..38944a8cc677 100644
--- a/fs/hpfs/anode.c
+++ b/fs/hpfs/anode.c
@@ -86,7 +86,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 	if (bp_internal(btree)) {
 		a = le32_to_cpu(btree->u.internal[n].down);
 		btree->u.internal[n].file_secno = cpu_to_le32(-1);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 		if (hpfs_sb(s)->sb_chk)
 			if (hpfs_stop_cycles(s, a, &c1, &c2, "hpfs_add_sector_to_btree #1")) return -1;
@@ -104,7 +104,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 		}
 		if (hpfs_alloc_if_possible(s, se = le32_to_cpu(btree->u.external[n].disk_secno) + le32_to_cpu(btree->u.external[n].length))) {
 			le32_add_cpu(&btree->u.external[n].length, 1);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			brelse(bh);
 			return se;
 		}
@@ -141,7 +141,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 			btree->first_free = cpu_to_le16((char *)&(btree->u.internal[1]) - (char *)btree);
 			btree->u.internal[0].file_secno = cpu_to_le32(-1);
 			btree->u.internal[0].down = cpu_to_le32(na);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		} else if (!(ranode = hpfs_alloc_anode(s, /*a*/0, &ra, &bh2))) {
 			brelse(bh);
 			brelse(bh1);
@@ -158,7 +158,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 	btree->u.external[n].disk_secno = cpu_to_le32(se);
 	btree->u.external[n].file_secno = cpu_to_le32(fs);
 	btree->u.external[n].length = cpu_to_le32(1);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	if ((a == node && fnod) || na == -1) return se;
 	c2 = 0;
@@ -179,7 +179,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 			btree->u.internal[n].file_secno = cpu_to_le32(-1);
 			btree->u.internal[n].down = cpu_to_le32(na);
 			btree->u.internal[n-1].file_secno = cpu_to_le32(fs);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			brelse(bh);
 			brelse(bh2);
 			hpfs_free_sectors(s, ra, 1);
@@ -189,14 +189,14 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 					anode->btree.flags |= BP_fnode_parent;
 				else
 					anode->btree.flags &= ~BP_fnode_parent;
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 				brelse(bh);
 			}
 			return se;
 		}
 		up = up != node ? le32_to_cpu(anode->up) : -1;
 		btree->u.internal[btree->n_used_nodes - 1].file_secno = cpu_to_le32(/*fs*/-1);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 		a = na;
 		if ((new_anode = hpfs_alloc_anode(s, a, &na, &bh))) {
@@ -208,11 +208,11 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 			anode->btree.first_free = cpu_to_le16(16);
 			anode->btree.u.internal[0].down = cpu_to_le32(a);
 			anode->btree.u.internal[0].file_secno = cpu_to_le32(-1);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			brelse(bh);
 			if ((anode = hpfs_map_anode(s, a, &bh))) {
 				anode->up = cpu_to_le32(na);
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 				brelse(bh);
 			}
 		} else na = a;
@@ -221,7 +221,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 		anode->up = cpu_to_le32(node);
 		if (fnod)
 			anode->btree.flags |= BP_fnode_parent;
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 	}
 	if (!fnod) {
@@ -247,7 +247,7 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 		if ((unode = hpfs_map_anode(s, le32_to_cpu(ranode->u.internal[n].down), &bh1))) {
 			unode->up = cpu_to_le32(ra);
 			unode->btree.flags &= ~BP_fnode_parent;
-			mark_buffer_dirty(bh1);
+			mark_buffer_dirty(NULL, bh1);
 			brelse(bh1);
 		}
 	}
@@ -259,9 +259,9 @@ secno hpfs_add_sector_to_btree(struct super_block *s, secno node, int fnod, unsi
 	btree->u.internal[0].down = cpu_to_le32(ra);
 	btree->u.internal[1].file_secno = cpu_to_le32(-1);
 	btree->u.internal[1].down = cpu_to_le32(na);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
-	mark_buffer_dirty(bh2);
+	mark_buffer_dirty(NULL, bh2);
 	brelse(bh2);
 	return se;
 }
@@ -375,7 +375,7 @@ int hpfs_ea_write(struct super_block *s, secno a, int ano, unsigned pos,
 			return -1;
 		l = 0x200 - (pos & 0x1ff); if (l > len) l = len;
 		memcpy(data + (pos & 0x1ff), buf, l);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 		buf += l; pos += l; len -= l;
 	}
@@ -419,7 +419,7 @@ void hpfs_truncate_btree(struct super_block *s, secno f, int fno, unsigned secs)
 			btree->n_used_nodes = 0;
 			btree->first_free = cpu_to_le16(8);
 			btree->flags &= ~BP_internal;
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		} else hpfs_free_sectors(s, f, 1);
 		brelse(bh);
 		return;
@@ -437,7 +437,7 @@ void hpfs_truncate_btree(struct super_block *s, secno f, int fno, unsigned secs)
 		btree->n_used_nodes = i + 1;
 		btree->n_free_nodes = nodes - btree->n_used_nodes;
 		btree->first_free = cpu_to_le16(8 + 8 * btree->n_used_nodes);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		if (btree->u.internal[i].file_secno == cpu_to_le32(secs)) {
 			brelse(bh);
 			return;
@@ -471,7 +471,7 @@ void hpfs_truncate_btree(struct super_block *s, secno f, int fno, unsigned secs)
 	btree->n_used_nodes = i + 1;
 	btree->n_free_nodes = nodes - btree->n_used_nodes;
 	btree->first_free = cpu_to_le16(8 + 12 * btree->n_used_nodes);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 }
 
diff --git a/fs/hpfs/buffer.c b/fs/hpfs/buffer.c
index e285d6b3bba4..dbb0a4d72bc8 100644
--- a/fs/hpfs/buffer.c
+++ b/fs/hpfs/buffer.c
@@ -225,8 +225,8 @@ void hpfs_mark_4buffers_dirty(struct quad_buffer_head *qbh)
 		memcpy(qbh->bh[2]->b_data, qbh->data + 2 * 512, 512);
 		memcpy(qbh->bh[3]->b_data, qbh->data + 3 * 512, 512);
 	}
-	mark_buffer_dirty(qbh->bh[0]);
-	mark_buffer_dirty(qbh->bh[1]);
-	mark_buffer_dirty(qbh->bh[2]);
-	mark_buffer_dirty(qbh->bh[3]);
+	mark_buffer_dirty(NULL, qbh->bh[0]);
+	mark_buffer_dirty(NULL, qbh->bh[1]);
+	mark_buffer_dirty(NULL, qbh->bh[2]);
+	mark_buffer_dirty(NULL, qbh->bh[3]);
 }
diff --git a/fs/hpfs/dnode.c b/fs/hpfs/dnode.c
index a4ad18afbdec..6bc5449d0fd1 100644
--- a/fs/hpfs/dnode.c
+++ b/fs/hpfs/dnode.c
@@ -359,7 +359,7 @@ static int hpfs_add_to_dnode(struct inode *i, dnode_secno dno,
 		return 1;
 	}
 	fnode->u.external[0].disk_secno = cpu_to_le32(rdno);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	hpfs_i(i)->i_dno = rdno;
 	d->up = ad->up = cpu_to_le32(rdno);
@@ -562,7 +562,7 @@ static void delete_empty_dnode(struct inode *i, dnode_secno dno)
 			}
 			if ((fnode = hpfs_map_fnode(i->i_sb, up, &bh))) {
 				fnode->u.external[0].disk_secno = cpu_to_le32(down);
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 				brelse(bh);
 			}
 			hpfs_inode->i_dno = down;
diff --git a/fs/hpfs/ea.c b/fs/hpfs/ea.c
index 102ba18e561f..a600bac34172 100644
--- a/fs/hpfs/ea.c
+++ b/fs/hpfs/ea.c
@@ -278,7 +278,7 @@ void hpfs_set_ea(struct inode *inode, struct fnode *fnode, const char *key,
 		fnode->ea_size_s = cpu_to_le16(0);
 		fnode->ea_secno = cpu_to_le32(n);
 		fnode->flags &= ~FNODE_anode;
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 	}
 	pos = le32_to_cpu(fnode->ea_size_l) + 5 + strlen(key) + size;
@@ -331,7 +331,7 @@ void hpfs_set_ea(struct inode *inode, struct fnode *fnode, const char *key,
 					}
 					memcpy(b2, b1, 512);
 					brelse(bh1);
-					mark_buffer_dirty(bh2);
+					mark_buffer_dirty(NULL, bh2);
 					brelse(bh2);
 				}
 				hpfs_free_sectors(s, le32_to_cpu(fnode->ea_secno), len);
diff --git a/fs/hpfs/inode.c b/fs/hpfs/inode.c
index eb8b4baf0f2e..134313fa85fe 100644
--- a/fs/hpfs/inode.c
+++ b/fs/hpfs/inode.c
@@ -253,7 +253,7 @@ void hpfs_write_inode_nolock(struct inode *i)
 				"directory %08lx doesn't have '.' entry",
 				(unsigned long)i->i_ino);
 	}
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 }
 
diff --git a/fs/hpfs/namei.c b/fs/hpfs/namei.c
index e79bd8760f3f..75e2b5597bd6 100644
--- a/fs/hpfs/namei.c
+++ b/fs/hpfs/namei.c
@@ -96,7 +96,7 @@ static int hpfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	de->first = de->directory = 1;
 	/*de->hidden = de->system = 0;*/
 	de->fnode = cpu_to_le32(fno);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	hpfs_mark_4buffers_dirty(&qbh0);
 	hpfs_brelse4(&qbh0);
@@ -187,7 +187,7 @@ static int hpfs_create(struct inode *dir, struct dentry *dentry, umode_t mode, b
 	fnode->len = len;
 	memcpy(fnode->name, name, len > 15 ? 15 : len);
 	fnode->up = cpu_to_le32(dir->i_ino);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 
 	insert_inode_hash(result);
@@ -269,7 +269,7 @@ static int hpfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, de
 	fnode->len = len;
 	memcpy(fnode->name, name, len > 15 ? 15 : len);
 	fnode->up = cpu_to_le32(dir->i_ino);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 
 	insert_inode_hash(result);
 
@@ -348,7 +348,7 @@ static int hpfs_symlink(struct inode *dir, struct dentry *dentry, const char *sy
 	memcpy(fnode->name, name, len > 15 ? 15 : len);
 	fnode->up = cpu_to_le32(dir->i_ino);
 	hpfs_set_ea(result, fnode, "SYMLINK", symlink, strlen(symlink));
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 
 	insert_inode_hash(result);
@@ -604,7 +604,7 @@ static int hpfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		fnode->len = new_len;
 		memcpy(fnode->name, new_name, new_len>15?15:new_len);
 		if (new_len < 15) memset(&fnode->name[new_len], 0, 15 - new_len);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 	}
 end1:
diff --git a/fs/hpfs/super.c b/fs/hpfs/super.c
index f2c3ebcd309c..93b9908f300f 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -27,7 +27,7 @@ static void mark_dirty(struct super_block *s, int remount)
 		if ((sb = hpfs_map_sector(s, 17, &bh, 0))) {
 			sb->dirty = 1;
 			sb->old_wrote = 0;
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			sync_dirty_buffer(bh);
 			brelse(bh);
 		}
@@ -46,7 +46,7 @@ static void unmark_dirty(struct super_block *s)
 	if ((sb = hpfs_map_sector(s, 17, &bh, 0))) {
 		sb->dirty = hpfs_sb(s)->sb_chkdsk > 1 - hpfs_sb(s)->sb_was_error;
 		sb->old_wrote = hpfs_sb(s)->sb_chkdsk >= 2 && !hpfs_sb(s)->sb_was_error;
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		sync_dirty_buffer(bh);
 		brelse(bh);
 	}
@@ -667,7 +667,7 @@ static int hpfs_fill_super(struct super_block *s, void *options, int silent)
 	if (!sb_rdonly(s)) {
 		spareblock->dirty = 1;
 		spareblock->old_wrote = 0;
-		mark_buffer_dirty(bh2);
+		mark_buffer_dirty(NULL, bh2);
 	}
 
 	if (le32_to_cpu(spareblock->n_dnode_spares) != le32_to_cpu(spareblock->n_dnode_spares_free)) {
diff --git a/fs/jbd2/recovery.c b/fs/jbd2/recovery.c
index f99910b69c78..936d74bf4c40 100644
--- a/fs/jbd2/recovery.c
+++ b/fs/jbd2/recovery.c
@@ -631,7 +631,7 @@ static int do_one_pass(journal_t *journal,
 
 					BUFFER_TRACE(nbh, "marking dirty");
 					set_buffer_uptodate(nbh);
-					mark_buffer_dirty(nbh);
+					mark_buffer_dirty(NULL, nbh);
 					BUFFER_TRACE(nbh, "marking uptodate");
 					++info->nr_replays;
 					/* ll_rw_block(WRITE, 1, &nbh); */
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 6899e7b4036d..01c31d021b47 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -1885,7 +1885,7 @@ static void __jbd2_journal_temp_unlink_buffer(struct journal_head *jh)
 	if (transaction && is_journal_aborted(transaction->t_journal))
 		clear_buffer_jbddirty(bh);
 	else if (test_clear_buffer_jbddirty(bh))
-		mark_buffer_dirty(bh);	/* Expose it to the VM */
+		mark_buffer_dirty(NULL, bh);	/* Expose it to the VM */
 }
 
 /*
diff --git a/fs/jfs/jfs_imap.c b/fs/jfs/jfs_imap.c
index f36ef68905a7..69a10c8d9605 100644
--- a/fs/jfs/jfs_imap.c
+++ b/fs/jfs/jfs_imap.c
@@ -3009,7 +3009,7 @@ static void duplicateIXtree(struct super_block *sb, s64 blkno,
 		j_sb = (struct jfs_superblock *)bh->b_data;
 		j_sb->s_flag |= cpu_to_le32(JFS_BAD_SAIT);
 
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		sync_dirty_buffer(bh);
 		brelse(bh);
 		return;
diff --git a/fs/jfs/jfs_mount.c b/fs/jfs/jfs_mount.c
index d8658607bf46..3cf9d794d08a 100644
--- a/fs/jfs/jfs_mount.c
+++ b/fs/jfs/jfs_mount.c
@@ -448,7 +448,7 @@ int updateSuper(struct super_block *sb, uint state)
 			j_sb->s_flag |= cpu_to_le32(JFS_DASD_PRIME);
 	}
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	sync_dirty_buffer(bh);
 	brelse(bh);
 
diff --git a/fs/jfs/resize.c b/fs/jfs/resize.c
index c1f417b94fe6..7d800d80a9d1 100644
--- a/fs/jfs/resize.c
+++ b/fs/jfs/resize.c
@@ -247,7 +247,7 @@ int jfs_extendfs(struct super_block *sb, s64 newLVSize, int newLogSize)
 		PXDlength(&j_sb->s_xlogpxd, newLogSize);
 
 		/* synchronously update superblock */
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		sync_dirty_buffer(bh);
 		brelse(bh);
 
@@ -523,13 +523,13 @@ int jfs_extendfs(struct super_block *sb, s64 newLVSize, int newLogSize)
 		j_sb2 = (struct jfs_superblock *)bh2->b_data;
 		memcpy(j_sb2, j_sb, sizeof (struct jfs_superblock));
 
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		sync_dirty_buffer(bh2);
 		brelse(bh2);
 	}
 
 	/* write primary superblock */
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	sync_dirty_buffer(bh);
 	brelse(bh);
 
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 1b9264fd54b6..96cc8c79f0d7 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -838,7 +838,7 @@ static ssize_t jfs_quota_write(struct super_block *sb, int type,
 		memcpy(bh->b_data+offset, data, tocopy);
 		flush_dcache_page(bh->b_page);
 		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		unlock_buffer(bh);
 		brelse(bh);
 		offset = 0;
diff --git a/fs/minix/bitmap.c b/fs/minix/bitmap.c
index f4e5e5181a14..61c7f0d4d00a 100644
--- a/fs/minix/bitmap.c
+++ b/fs/minix/bitmap.c
@@ -64,7 +64,7 @@ void minix_free_block(struct inode *inode, unsigned long block)
 		printk("minix_free_block (%s:%lu): bit already cleared\n",
 		       sb->s_id, block);
 	spin_unlock(&bitmap_lock);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	return;
 }
 
@@ -83,7 +83,7 @@ int minix_new_block(struct inode * inode)
 		if (j < bits_per_zone) {
 			minix_set_bit(j, bh->b_data);
 			spin_unlock(&bitmap_lock);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			j += i * bits_per_zone + sbi->s_firstdatazone-1;
 			if (j < sbi->s_firstdatazone || j >= sbi->s_nzones)
 				break;
@@ -175,7 +175,7 @@ static void minix_clear_inode(struct inode *inode)
 		}
 	}
 	if (bh) {
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse (bh);
 	}
 }
@@ -207,7 +207,7 @@ void minix_free_inode(struct inode * inode)
 	if (!minix_test_and_clear_bit(bit, bh->b_data))
 		printk("minix_free_inode: bit %lu already cleared\n", bit);
 	spin_unlock(&bitmap_lock);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 }
 
 struct inode *minix_new_inode(const struct inode *dir, umode_t mode, int *error)
@@ -246,7 +246,7 @@ struct inode *minix_new_inode(const struct inode *dir, umode_t mode, int *error)
 		return NULL;
 	}
 	spin_unlock(&bitmap_lock);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	j += i * bits_per_zone;
 	if (!j || j > sbi->s_ninodes) {
 		iput(inode);
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 450aa4e87cd9..e8550a58fe83 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -45,7 +45,7 @@ static void minix_put_super(struct super_block *sb)
 	if (!sb_rdonly(sb)) {
 		if (sbi->s_version != MINIX_V3)	 /* s_state is now out from V3 sb */
 			sbi->s_ms->s_state = sbi->s_mount_state;
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_buffer_dirty(NULL, sbi->s_sbh);
 	}
 	for (i = 0; i < sbi->s_imap_blocks; i++)
 		brelse(sbi->s_imap[i]);
@@ -134,7 +134,7 @@ static int minix_remount (struct super_block * sb, int * flags, char * data)
 		/* Mounting a rw partition read-only. */
 		if (sbi->s_version != MINIX_V3)
 			ms->s_state = sbi->s_mount_state;
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_buffer_dirty(NULL, sbi->s_sbh);
 	} else {
 	  	/* Mount a partition which is read-only, read-write. */
 		if (sbi->s_version != MINIX_V3) {
@@ -143,7 +143,7 @@ static int minix_remount (struct super_block * sb, int * flags, char * data)
 		} else {
 			sbi->s_mount_state = MINIX_VALID_FS;
 		}
-		mark_buffer_dirty(sbi->s_sbh);
+		mark_buffer_dirty(NULL, sbi->s_sbh);
 
 		if (!(sbi->s_mount_state & MINIX_VALID_FS))
 			printk("MINIX-fs warning: remounting unchecked fs, "
@@ -296,7 +296,7 @@ static int minix_fill_super(struct super_block *s, void *data, int silent)
 	if (!sb_rdonly(s)) {
 		if (sbi->s_version != MINIX_V3) /* s_state is now out from V3 sb */
 			ms->s_state &= ~MINIX_VALID_FS;
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	}
 	if (!(sbi->s_mount_state & MINIX_VALID_FS))
 		printk("MINIX-fs: mounting unchecked file system, "
@@ -570,7 +570,7 @@ static struct buffer_head * V1_minix_update_inode(struct inode * inode)
 		raw_inode->i_zone[0] = old_encode_dev(inode->i_rdev);
 	else for (i = 0; i < 9; i++)
 		raw_inode->i_zone[i] = minix_inode->u.i1_data[i];
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	return bh;
 }
 
@@ -599,7 +599,7 @@ static struct buffer_head * V2_minix_update_inode(struct inode * inode)
 		raw_inode->i_zone[0] = old_encode_dev(inode->i_rdev);
 	else for (i = 0; i < 10; i++)
 		raw_inode->i_zone[i] = minix_inode->u.i2_data[i];
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	return bh;
 }
 
diff --git a/fs/nilfs2/alloc.c b/fs/nilfs2/alloc.c
index 03b8ba933eb2..7e3d3a8dc3f9 100644
--- a/fs/nilfs2/alloc.c
+++ b/fs/nilfs2/alloc.c
@@ -591,8 +591,8 @@ int nilfs_palloc_prepare_alloc_entry(struct inode *inode,
 void nilfs_palloc_commit_alloc_entry(struct inode *inode,
 				     struct nilfs_palloc_req *req)
 {
-	mark_buffer_dirty(req->pr_bitmap_bh);
-	mark_buffer_dirty(req->pr_desc_bh);
+	mark_buffer_dirty(NULL, req->pr_bitmap_bh);
+	mark_buffer_dirty(NULL, req->pr_desc_bh);
 	nilfs_mdt_mark_dirty(inode);
 
 	brelse(req->pr_bitmap_bh);
@@ -632,8 +632,8 @@ void nilfs_palloc_commit_free_entry(struct inode *inode,
 	kunmap(req->pr_bitmap_bh->b_page);
 	kunmap(req->pr_desc_bh->b_page);
 
-	mark_buffer_dirty(req->pr_desc_bh);
-	mark_buffer_dirty(req->pr_bitmap_bh);
+	mark_buffer_dirty(NULL, req->pr_desc_bh);
+	mark_buffer_dirty(NULL, req->pr_bitmap_bh);
 	nilfs_mdt_mark_dirty(inode);
 
 	brelse(req->pr_bitmap_bh);
@@ -810,7 +810,7 @@ int nilfs_palloc_freev(struct inode *inode, __u64 *entry_nrs, size_t nitems)
 		} while (true);
 
 		kunmap(bitmap_bh->b_page);
-		mark_buffer_dirty(bitmap_bh);
+		mark_buffer_dirty(NULL, bitmap_bh);
 		brelse(bitmap_bh);
 
 		for (k = 0; k < nempties; k++) {
@@ -828,7 +828,7 @@ int nilfs_palloc_freev(struct inode *inode, __u64 *entry_nrs, size_t nitems)
 			inode, group, desc_bh, desc_kaddr);
 		nfree = nilfs_palloc_group_desc_add_entries(desc, lock, n);
 		kunmap_atomic(desc_kaddr);
-		mark_buffer_dirty(desc_bh);
+		mark_buffer_dirty(NULL, desc_bh);
 		nilfs_mdt_mark_dirty(inode);
 		brelse(desc_bh);
 
diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
index c21e0b4454a6..a2d7844b1ff4 100644
--- a/fs/nilfs2/btnode.c
+++ b/fs/nilfs2/btnode.c
@@ -249,7 +249,7 @@ void nilfs_btnode_commit_change_key(struct address_space *btnc,
 				       "invalid oldkey %lld (newkey=%lld)",
 				       (unsigned long long)oldkey,
 				       (unsigned long long)newkey);
-		mark_buffer_dirty(obh);
+		mark_buffer_dirty(NULL, obh);
 
 		spin_lock_irq(&btnc->tree_lock);
 		radix_tree_delete(&btnc->page_tree, oldkey);
@@ -261,7 +261,7 @@ void nilfs_btnode_commit_change_key(struct address_space *btnc,
 		unlock_page(opage);
 	} else {
 		nilfs_copy_buffer(nbh, obh);
-		mark_buffer_dirty(nbh);
+		mark_buffer_dirty(NULL, nbh);
 
 		nbh->b_blocknr = newkey;
 		ctxt->bh = nbh;
diff --git a/fs/nilfs2/btree.c b/fs/nilfs2/btree.c
index 16a7a67a11c9..39edf8a267d7 100644
--- a/fs/nilfs2/btree.c
+++ b/fs/nilfs2/btree.c
@@ -792,7 +792,7 @@ static void nilfs_btree_promote_key(struct nilfs_bmap *btree,
 				nilfs_btree_get_nonroot_node(path, level),
 				path[level].bp_index, key);
 			if (!buffer_dirty(path[level].bp_bh))
-				mark_buffer_dirty(path[level].bp_bh);
+				mark_buffer_dirty(NULL, path[level].bp_bh);
 		} while ((path[level].bp_index == 0) &&
 			 (++level < nilfs_btree_height(btree) - 1));
 	}
@@ -817,7 +817,7 @@ static void nilfs_btree_do_insert(struct nilfs_bmap *btree,
 		nilfs_btree_node_insert(node, path[level].bp_index,
 					*keyp, *ptrp, ncblk);
 		if (!buffer_dirty(path[level].bp_bh))
-			mark_buffer_dirty(path[level].bp_bh);
+			mark_buffer_dirty(NULL, path[level].bp_bh);
 
 		if (path[level].bp_index == 0)
 			nilfs_btree_promote_key(btree, path, level + 1,
@@ -855,9 +855,9 @@ static void nilfs_btree_carry_left(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_left(left, node, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	nilfs_btree_promote_key(btree, path, level + 1,
 				nilfs_btree_node_get_key(node, 0));
@@ -901,9 +901,9 @@ static void nilfs_btree_carry_right(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_right(node, right, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	path[level + 1].bp_index++;
 	nilfs_btree_promote_key(btree, path, level + 1,
@@ -946,9 +946,9 @@ static void nilfs_btree_split(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_right(node, right, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	if (move) {
 		path[level].bp_index -= nilfs_btree_node_get_nchildren(node);
@@ -992,7 +992,7 @@ static void nilfs_btree_grow(struct nilfs_bmap *btree,
 	nilfs_btree_node_set_level(root, level + 1);
 
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	path[level].bp_bh = path[level].bp_sib_bh;
 	path[level].bp_sib_bh = NULL;
@@ -1267,7 +1267,7 @@ static void nilfs_btree_do_delete(struct nilfs_bmap *btree,
 		nilfs_btree_node_delete(node, path[level].bp_index,
 					keyp, ptrp, ncblk);
 		if (!buffer_dirty(path[level].bp_bh))
-			mark_buffer_dirty(path[level].bp_bh);
+			mark_buffer_dirty(NULL, path[level].bp_bh);
 		if (path[level].bp_index == 0)
 			nilfs_btree_promote_key(btree, path, level + 1,
 				nilfs_btree_node_get_key(node, 0));
@@ -1299,9 +1299,9 @@ static void nilfs_btree_borrow_left(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_right(left, node, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	nilfs_btree_promote_key(btree, path, level + 1,
 				nilfs_btree_node_get_key(node, 0));
@@ -1331,9 +1331,9 @@ static void nilfs_btree_borrow_right(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_left(node, right, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	path[level + 1].bp_index++;
 	nilfs_btree_promote_key(btree, path, level + 1,
@@ -1362,7 +1362,7 @@ static void nilfs_btree_concat_left(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_left(left, node, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_sib_bh))
-		mark_buffer_dirty(path[level].bp_sib_bh);
+		mark_buffer_dirty(NULL, path[level].bp_sib_bh);
 
 	nilfs_btnode_delete(path[level].bp_bh);
 	path[level].bp_bh = path[level].bp_sib_bh;
@@ -1388,7 +1388,7 @@ static void nilfs_btree_concat_right(struct nilfs_bmap *btree,
 	nilfs_btree_node_move_left(node, right, n, ncblk, ncblk);
 
 	if (!buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 
 	nilfs_btnode_delete(path[level].bp_sib_bh);
 	path[level].bp_sib_bh = NULL;
@@ -1818,7 +1818,7 @@ nilfs_btree_commit_convert_and_insert(struct nilfs_bmap *btree,
 		nilfs_btree_node_init(node, 0, 1, n, ncblk, keys, ptrs);
 		nilfs_btree_node_insert(node, n, key, dreq->bpr_ptr, ncblk);
 		if (!buffer_dirty(bh))
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		if (!nilfs_bmap_dirty(btree))
 			nilfs_bmap_set_dirty(btree);
 
@@ -1896,7 +1896,7 @@ static int nilfs_btree_propagate_p(struct nilfs_bmap *btree,
 {
 	while ((++level < nilfs_btree_height(btree) - 1) &&
 	       !buffer_dirty(path[level].bp_bh))
-		mark_buffer_dirty(path[level].bp_bh);
+		mark_buffer_dirty(NULL, path[level].bp_bh);
 
 	return 0;
 }
@@ -2339,7 +2339,7 @@ static int nilfs_btree_mark(struct nilfs_bmap *btree, __u64 key, int level)
 	}
 
 	if (!buffer_dirty(bh))
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	if (!nilfs_bmap_dirty(btree))
 		nilfs_bmap_set_dirty(btree);
diff --git a/fs/nilfs2/cpfile.c b/fs/nilfs2/cpfile.c
index a15a1601e931..9e4558a8e4da 100644
--- a/fs/nilfs2/cpfile.c
+++ b/fs/nilfs2/cpfile.c
@@ -258,14 +258,14 @@ int nilfs_cpfile_get_checkpoint(struct inode *cpfile,
 		if (!nilfs_cpfile_is_in_first(cpfile, cno))
 			nilfs_cpfile_block_add_valid_checkpoints(cpfile, cp_bh,
 								 kaddr, 1);
-		mark_buffer_dirty(cp_bh);
+		mark_buffer_dirty(NULL, cp_bh);
 
 		kaddr = kmap_atomic(header_bh->b_page);
 		header = nilfs_cpfile_block_get_header(cpfile, header_bh,
 						       kaddr);
 		le64_add_cpu(&header->ch_ncheckpoints, 1);
 		kunmap_atomic(kaddr);
-		mark_buffer_dirty(header_bh);
+		mark_buffer_dirty(NULL, header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
 	}
 
@@ -370,7 +370,7 @@ int nilfs_cpfile_delete_checkpoints(struct inode *cpfile,
 		}
 		if (nicps > 0) {
 			tnicps += nicps;
-			mark_buffer_dirty(cp_bh);
+			mark_buffer_dirty(NULL, cp_bh);
 			nilfs_mdt_mark_dirty(cpfile);
 			if (!nilfs_cpfile_is_in_first(cpfile, cno)) {
 				count =
@@ -402,7 +402,7 @@ int nilfs_cpfile_delete_checkpoints(struct inode *cpfile,
 		header = nilfs_cpfile_block_get_header(cpfile, header_bh,
 						       kaddr);
 		le64_add_cpu(&header->ch_ncheckpoints, -(u64)tnicps);
-		mark_buffer_dirty(header_bh);
+		mark_buffer_dirty(NULL, header_bh);
 		nilfs_mdt_mark_dirty(cpfile);
 		kunmap_atomic(kaddr);
 	}
@@ -720,10 +720,10 @@ static int nilfs_cpfile_set_snapshot(struct inode *cpfile, __u64 cno)
 	le64_add_cpu(&header->ch_nsnapshots, 1);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(prev_bh);
-	mark_buffer_dirty(curr_bh);
-	mark_buffer_dirty(cp_bh);
-	mark_buffer_dirty(header_bh);
+	mark_buffer_dirty(NULL, prev_bh);
+	mark_buffer_dirty(NULL, curr_bh);
+	mark_buffer_dirty(NULL, cp_bh);
+	mark_buffer_dirty(NULL, header_bh);
 	nilfs_mdt_mark_dirty(cpfile);
 
 	brelse(prev_bh);
@@ -823,10 +823,10 @@ static int nilfs_cpfile_clear_snapshot(struct inode *cpfile, __u64 cno)
 	le64_add_cpu(&header->ch_nsnapshots, -1);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(next_bh);
-	mark_buffer_dirty(prev_bh);
-	mark_buffer_dirty(cp_bh);
-	mark_buffer_dirty(header_bh);
+	mark_buffer_dirty(NULL, next_bh);
+	mark_buffer_dirty(NULL, prev_bh);
+	mark_buffer_dirty(NULL, cp_bh);
+	mark_buffer_dirty(NULL, header_bh);
 	nilfs_mdt_mark_dirty(cpfile);
 
 	brelse(prev_bh);
diff --git a/fs/nilfs2/dat.c b/fs/nilfs2/dat.c
index dffedb2f8817..8db180ed9812 100644
--- a/fs/nilfs2/dat.c
+++ b/fs/nilfs2/dat.c
@@ -56,7 +56,7 @@ static int nilfs_dat_prepare_entry(struct inode *dat,
 static void nilfs_dat_commit_entry(struct inode *dat,
 				   struct nilfs_palloc_req *req)
 {
-	mark_buffer_dirty(req->pr_entry_bh);
+	mark_buffer_dirty(NULL, req->pr_entry_bh);
 	nilfs_mdt_mark_dirty(dat);
 	brelse(req->pr_entry_bh);
 }
@@ -362,7 +362,7 @@ int nilfs_dat_move(struct inode *dat, __u64 vblocknr, sector_t blocknr)
 	entry->de_blocknr = cpu_to_le64(blocknr);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(entry_bh);
+	mark_buffer_dirty(NULL, entry_bh);
 	nilfs_mdt_mark_dirty(dat);
 
 	brelse(entry_bh);
diff --git a/fs/nilfs2/gcinode.c b/fs/nilfs2/gcinode.c
index 853a831dcde0..ba2af926b39a 100644
--- a/fs/nilfs2/gcinode.c
+++ b/fs/nilfs2/gcinode.c
@@ -164,7 +164,7 @@ int nilfs_gccache_wait_and_mark_dirty(struct buffer_head *bh)
 		clear_buffer_uptodate(bh);
 		return -EIO;
 	}
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	return 0;
 }
 
diff --git a/fs/nilfs2/ifile.c b/fs/nilfs2/ifile.c
index b8fa45c20c63..11262c2f46f4 100644
--- a/fs/nilfs2/ifile.c
+++ b/fs/nilfs2/ifile.c
@@ -82,7 +82,7 @@ int nilfs_ifile_create_inode(struct inode *ifile, ino_t *out_ino,
 		return ret;
 	}
 	nilfs_palloc_commit_alloc_entry(ifile, &req);
-	mark_buffer_dirty(req.pr_entry_bh);
+	mark_buffer_dirty(NULL, req.pr_entry_bh);
 	nilfs_mdt_mark_dirty(ifile);
 	*out_ino = (ino_t)req.pr_entry_nr;
 	*out_bh = req.pr_entry_bh;
@@ -130,7 +130,7 @@ int nilfs_ifile_delete_inode(struct inode *ifile, ino_t ino)
 	raw_inode->i_flags = 0;
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(req.pr_entry_bh);
+	mark_buffer_dirty(NULL, req.pr_entry_bh);
 	brelse(req.pr_entry_bh);
 
 	nilfs_palloc_commit_free_entry(ifile, &req);
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 7cc0268d68ce..811e4d952511 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -968,7 +968,7 @@ int __nilfs_mark_inode_dirty(struct inode *inode, int flags)
 		return err;
 	}
 	nilfs_update_inode(inode, ibh, flags);
-	mark_buffer_dirty(ibh);
+	mark_buffer_dirty(NULL, ibh);
 	nilfs_mdt_mark_dirty(NILFS_I(inode)->i_root->ifile);
 	brelse(ibh);
 	return 0;
diff --git a/fs/nilfs2/ioctl.c b/fs/nilfs2/ioctl.c
index 1d2c3d7711fe..18b550252ff2 100644
--- a/fs/nilfs2/ioctl.c
+++ b/fs/nilfs2/ioctl.c
@@ -801,7 +801,7 @@ static int nilfs_ioctl_mark_blocks_dirty(struct the_nilfs *nilfs,
 				WARN_ON(ret == -ENOENT);
 				return ret;
 			}
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			nilfs_mdt_mark_dirty(nilfs->ns_dat);
 			put_bh(bh);
 		} else {
diff --git a/fs/nilfs2/mdt.c b/fs/nilfs2/mdt.c
index ca7bc0fba624..ad41b67eb25f 100644
--- a/fs/nilfs2/mdt.c
+++ b/fs/nilfs2/mdt.c
@@ -64,7 +64,7 @@ nilfs_mdt_insert_new_block(struct inode *inode, unsigned long block,
 	kunmap_atomic(kaddr);
 
 	set_buffer_uptodate(bh);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	nilfs_mdt_mark_dirty(inode);
 
 	trace_nilfs2_mdt_insert_new_block(inode, inode->i_ino, block);
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 0952d0acab4a..8dc544e3fe6a 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -883,7 +883,7 @@ static int nilfs_segctor_create_checkpoint(struct nilfs_sc_info *sci)
 		 * needed to collect the checkpoint even if it was not newly
 		 * created.
 		 */
-		mark_buffer_dirty(bh_cp);
+		mark_buffer_dirty(NULL, bh_cp);
 		nilfs_mdt_mark_dirty(nilfs->ns_cpfile);
 		nilfs_cpfile_put_checkpoint(
 			nilfs->ns_cpfile, nilfs->ns_cno, bh_cp);
@@ -1964,7 +1964,7 @@ static int nilfs_segctor_collect_dirty_files(struct nilfs_sc_info *sci,
 		}
 
 		// Always redirty the buffer to avoid race condition
-		mark_buffer_dirty(ii->i_bh);
+		mark_buffer_dirty(NULL, ii->i_bh);
 		nilfs_mdt_mark_dirty(ifile);
 
 		clear_bit(NILFS_I_QUEUED, &ii->i_state);
diff --git a/fs/nilfs2/sufile.c b/fs/nilfs2/sufile.c
index c7fa139d50e8..707f2231d348 100644
--- a/fs/nilfs2/sufile.c
+++ b/fs/nilfs2/sufile.c
@@ -122,7 +122,7 @@ static void nilfs_sufile_mod_counter(struct buffer_head *header_bh,
 	le64_add_cpu(&header->sh_ndirtysegs, ndirtyadd);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(header_bh);
+	mark_buffer_dirty(NULL, header_bh);
 }
 
 /**
@@ -383,8 +383,8 @@ int nilfs_sufile_alloc(struct inode *sufile, __u64 *segnump)
 			kunmap_atomic(kaddr);
 
 			sui->ncleansegs--;
-			mark_buffer_dirty(header_bh);
-			mark_buffer_dirty(su_bh);
+			mark_buffer_dirty(NULL, header_bh);
+			mark_buffer_dirty(NULL, su_bh);
 			nilfs_mdt_mark_dirty(sufile);
 			brelse(su_bh);
 			*segnump = segnum;
@@ -431,7 +431,7 @@ void nilfs_sufile_do_cancel_free(struct inode *sufile, __u64 segnum,
 	nilfs_sufile_mod_counter(header_bh, -1, 1);
 	NILFS_SUI(sufile)->ncleansegs--;
 
-	mark_buffer_dirty(su_bh);
+	mark_buffer_dirty(NULL, su_bh);
 	nilfs_mdt_mark_dirty(sufile);
 }
 
@@ -462,7 +462,7 @@ void nilfs_sufile_do_scrap(struct inode *sufile, __u64 segnum,
 	nilfs_sufile_mod_counter(header_bh, clean ? (u64)-1 : 0, dirty ? 0 : 1);
 	NILFS_SUI(sufile)->ncleansegs -= clean;
 
-	mark_buffer_dirty(su_bh);
+	mark_buffer_dirty(NULL, su_bh);
 	nilfs_mdt_mark_dirty(sufile);
 }
 
@@ -489,7 +489,7 @@ void nilfs_sufile_do_free(struct inode *sufile, __u64 segnum,
 	sudirty = nilfs_segment_usage_dirty(su);
 	nilfs_segment_usage_set_clean(su);
 	kunmap_atomic(kaddr);
-	mark_buffer_dirty(su_bh);
+	mark_buffer_dirty(NULL, su_bh);
 
 	nilfs_sufile_mod_counter(header_bh, 1, sudirty ? (u64)-1 : 0);
 	NILFS_SUI(sufile)->ncleansegs++;
@@ -511,7 +511,7 @@ int nilfs_sufile_mark_dirty(struct inode *sufile, __u64 segnum)
 
 	ret = nilfs_sufile_get_segment_usage_block(sufile, segnum, 0, &bh);
 	if (!ret) {
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		nilfs_mdt_mark_dirty(sufile);
 		brelse(bh);
 	}
@@ -546,7 +546,7 @@ int nilfs_sufile_set_segment_usage(struct inode *sufile, __u64 segnum,
 	su->su_nblocks = cpu_to_le32(nblocks);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	nilfs_mdt_mark_dirty(sufile);
 	brelse(bh);
 
@@ -625,7 +625,7 @@ void nilfs_sufile_do_set_error(struct inode *sufile, __u64 segnum,
 		nilfs_sufile_mod_counter(header_bh, -1, 0);
 		NILFS_SUI(sufile)->ncleansegs--;
 	}
-	mark_buffer_dirty(su_bh);
+	mark_buffer_dirty(NULL, su_bh);
 	nilfs_mdt_mark_dirty(sufile);
 }
 
@@ -711,7 +711,7 @@ static int nilfs_sufile_truncate_range(struct inode *sufile,
 		}
 		kunmap_atomic(kaddr);
 		if (nc > 0) {
-			mark_buffer_dirty(su_bh);
+			mark_buffer_dirty(NULL, su_bh);
 			ncleaned += nc;
 		}
 		brelse(su_bh);
@@ -790,7 +790,7 @@ int nilfs_sufile_resize(struct inode *sufile, __u64 newnsegs)
 	header->sh_ncleansegs = cpu_to_le64(sui->ncleansegs);
 	kunmap_atomic(kaddr);
 
-	mark_buffer_dirty(header_bh);
+	mark_buffer_dirty(NULL, header_bh);
 	nilfs_mdt_mark_dirty(sufile);
 	nilfs_set_nsegments(nilfs, newnsegs);
 
@@ -984,13 +984,13 @@ ssize_t nilfs_sufile_set_suinfo(struct inode *sufile, void *buf,
 			continue;
 
 		/* get different block */
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		put_bh(bh);
 		ret = nilfs_mdt_get_block(sufile, blkoff, 1, NULL, &bh);
 		if (unlikely(ret < 0))
 			goto out_mark;
 	}
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	put_bh(bh);
 
  out_mark:
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 860b3b2ff47d..bf07c0ca127e 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -743,7 +743,7 @@ static int ntfs_prepare_pages_for_non_resident_write(struct page **pages,
 					/* We allocated the buffer. */
 					clean_bdev_bh_alias(bh);
 					if (bh_end <= pos || bh_pos >= end)
-						mark_buffer_dirty(bh);
+						mark_buffer_dirty(NULL, bh);
 					else
 						set_buffer_new(bh);
 				}
@@ -799,7 +799,7 @@ static int ntfs_prepare_pages_for_non_resident_write(struct page **pages,
 							blocksize);
 					set_buffer_uptodate(bh);
 				}
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 				continue;
 			}
 			set_buffer_new(bh);
@@ -1365,7 +1365,7 @@ static int ntfs_prepare_pages_for_non_resident_write(struct page **pages,
 					set_buffer_uptodate(bh);
 				}
 			}
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		} while ((bh = bh->b_this_page) != head);
 	} while (++u <= nr_pages);
 	ntfs_error(vol->sb, "Failed.  Returning error code %i.", err);
@@ -1434,7 +1434,7 @@ static inline int ntfs_commit_pages_after_non_resident_write(
 					partial = true;
 			} else {
 				set_buffer_uptodate(bh);
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 			}
 		} while (bh_pos += blocksize, (bh = bh->b_this_page) != head);
 		/*
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index bb7159f697f2..0d21744db6ba 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -737,7 +737,7 @@ static struct buffer_head *read_ntfs_boot_sector(struct super_block *sb,
 					"boot sector from backup copy.");
 			memcpy(bh_primary->b_data, bh_backup->b_data,
 					NTFS_BLOCK_SIZE);
-			mark_buffer_dirty(bh_primary);
+			mark_buffer_dirty(NULL, bh_primary);
 			sync_dirty_buffer(bh_primary);
 			if (buffer_uptodate(bh_primary)) {
 				brelse(bh_backup);
diff --git a/fs/ocfs2/alloc.c b/fs/ocfs2/alloc.c
index 9a876bb07cac..7ab61d67e89e 100644
--- a/fs/ocfs2/alloc.c
+++ b/fs/ocfs2/alloc.c
@@ -6815,7 +6815,7 @@ static int ocfs2_cache_extent_block_free(struct ocfs2_cached_dealloc_ctxt *ctxt,
 static int ocfs2_zero_func(handle_t *handle, struct buffer_head *bh)
 {
 	set_buffer_uptodate(bh);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	return 0;
 }
 
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index 515e0a00839b..64002c13bdd1 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -701,7 +701,7 @@ int ocfs2_map_page_blocks(struct page *page, u64 *p_blkno,
 
 		zero_user(page, block_start, bh->b_size);
 		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 
 next_bh:
 		block_start = block_end;
@@ -930,7 +930,7 @@ static void ocfs2_zero_new_buffers(struct page *page, unsigned from, unsigned to
 				}
 
 				clear_buffer_new(bh);
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 			}
 		}
 
diff --git a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
index d51b80edd972..7a4e5e9db53d 100644
--- a/fs/ocfs2/inode.c
+++ b/fs/ocfs2/inode.c
@@ -1568,7 +1568,7 @@ static int ocfs2_filecheck_repair_inode_block(struct super_block *sb,
 
 	if (changed || ocfs2_validate_meta_ecc(sb, bh->b_data, &di->i_check)) {
 		ocfs2_compute_meta_ecc(sb, bh->b_data, &di->i_check);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		mlog(ML_ERROR,
 		     "Filecheck: reset dinode #%llu: compute meta ecc\n",
 		     (unsigned long long)bh->b_blocknr);
diff --git a/fs/omfs/bitmap.c b/fs/omfs/bitmap.c
index 7147ba6a6afc..0a4a756e2865 100644
--- a/fs/omfs/bitmap.c
+++ b/fs/omfs/bitmap.c
@@ -63,7 +63,7 @@ static int set_run(struct super_block *sb, int map,
 			bit = 0;
 			map++;
 
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			brelse(bh);
 			bh = sb_bread(sb,
 				clus_to_blk(sbi, sbi->s_bitmap_ino) + map);
@@ -78,7 +78,7 @@ static int set_run(struct super_block *sb, int map,
 			clear_bit(bit, (unsigned long *)bh->b_data);
 		}
 	}
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	err = 0;
 out:
@@ -111,7 +111,7 @@ int omfs_allocate_block(struct super_block *sb, u64 block)
 			goto out;
 
 		set_bit(bit, (unsigned long *)bh->b_data);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 	}
 	ret = 1;
diff --git a/fs/omfs/dir.c b/fs/omfs/dir.c
index b7146526afff..a5c6f506a0a0 100644
--- a/fs/omfs/dir.c
+++ b/fs/omfs/dir.c
@@ -103,7 +103,7 @@ int omfs_make_empty(struct inode *inode, struct super_block *sb)
 	oi->i_head.h_self = cpu_to_be64(inode->i_ino);
 	oi->i_sibling = ~cpu_to_be64(0ULL);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 	return 0;
 }
@@ -127,7 +127,7 @@ static int omfs_add_link(struct dentry *dentry, struct inode *inode)
 	entry = (__be64 *) &bh->b_data[ofs];
 	block = be64_to_cpu(*entry);
 	*entry = cpu_to_be64(inode->i_ino);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 
 	/* now set the sibling and parent pointers on the new inode */
@@ -140,7 +140,7 @@ static int omfs_add_link(struct dentry *dentry, struct inode *inode)
 	memset(oi->i_name + namelen, 0, OMFS_NAMELEN - namelen);
 	oi->i_sibling = cpu_to_be64(block);
 	oi->i_parent = cpu_to_be64(dir->i_ino);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	brelse(bh);
 
 	dir->i_ctime = current_time(dir);
@@ -196,7 +196,7 @@ static int omfs_delete_entry(struct dentry *dentry)
 	}
 
 	*entry = next;
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 
 	if (prev != ~0) {
 		dirty = omfs_iget(dir->i_sb, prev);
diff --git a/fs/omfs/file.c b/fs/omfs/file.c
index ac27a4b2186a..4dbfb35b1a40 100644
--- a/fs/omfs/file.c
+++ b/fs/omfs/file.c
@@ -80,7 +80,7 @@ int omfs_shrink_inode(struct inode *inode)
 			entry++;
 		}
 		omfs_make_empty_table(bh, (char *) oe - bh->b_data);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		brelse(bh);
 
 		if (last != inode->i_ino)
@@ -272,7 +272,7 @@ static int omfs_get_block(struct inode *inode, sector_t block,
 	if (create) {
 		ret = omfs_grow_extent(inode, oe, &new_block);
 		if (ret == 0) {
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			mark_inode_dirty(inode);
 			map_bh(bh_result, inode->i_sb,
 					clus_to_blk(sbi, new_block));
diff --git a/fs/omfs/inode.c b/fs/omfs/inode.c
index ee14af9e26f2..4213ef2cd088 100644
--- a/fs/omfs/inode.c
+++ b/fs/omfs/inode.c
@@ -140,7 +140,7 @@ static int __omfs_write_inode(struct inode *inode, int wait)
 
 	omfs_update_checksums(oi);
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (wait) {
 		sync_dirty_buffer(bh);
 		if (buffer_req(bh) && !buffer_uptodate(bh))
@@ -154,7 +154,7 @@ static int __omfs_write_inode(struct inode *inode, int wait)
 			goto out_brelse;
 
 		memcpy(bh2->b_data, bh->b_data, bh->b_size);
-		mark_buffer_dirty(bh2);
+		mark_buffer_dirty(NULL, bh2);
 		if (wait) {
 			sync_dirty_buffer(bh2);
 			if (buffer_req(bh2) && !buffer_uptodate(bh2))
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 843aadcc123c..804b13c45f53 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -214,7 +214,7 @@ int reiserfs_commit_page(struct inode *inode, struct page *page,
 				reiserfs_prepare_for_journal(s, bh, 1);
 				journal_mark_dirty(&th, bh);
 			} else if (!buffer_dirty(bh)) {
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 				/*
 				 * do data=ordered on any page past the end
 				 * of file and any buffer marked BH_New.
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index bc64ca190848..e438aed1b622 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -999,7 +999,7 @@ int reiserfs_get_block(struct inode *inode, sector_t block,
 				 * VM (which was also the case with
 				 * __mark_buffer_dirty())
 				 */
-				mark_buffer_dirty(unbh);
+				mark_buffer_dirty(NULL, unbh);
 			}
 		} else {
 			/*
@@ -2336,7 +2336,7 @@ int reiserfs_truncate_file(struct inode *inode, int update_timestamps)
 			length = blocksize - length;
 			zero_user(page, offset, length);
 			if (buffer_mapped(bh) && bh->b_blocknr != 0) {
-				mark_buffer_dirty(bh);
+				mark_buffer_dirty(NULL, bh);
 			}
 		}
 		unlock_page(page);
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index ee74c6cddbbe..68cbaba7b2e6 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -1111,7 +1111,7 @@ static int flush_commit_list(struct super_block *s,
 	if (likely(!retval && !reiserfs_is_journal_aborted (journal))) {
 		if (buffer_dirty(jl->j_commit_bh))
 			BUG();
-		mark_buffer_dirty(jl->j_commit_bh) ;
+		mark_buffer_dirty(NULL, jl->j_commit_bh);
 		depth = reiserfs_write_unlock_nested(s);
 		if (reiserfs_barrier_flush(s))
 			__sync_dirty_buffer(jl->j_commit_bh,
@@ -1712,7 +1712,7 @@ static int dirty_one_transaction(struct super_block *s,
 				set_buffer_journal_restore_dirty(cn->bh);
 			} else {
 				set_buffer_journal_test(cn->bh);
-				mark_buffer_dirty(cn->bh);
+				mark_buffer_dirty(NULL, cn->bh);
 			}
 		}
 		cn = cn->next;
@@ -3935,7 +3935,7 @@ void reiserfs_restore_prepared_buffer(struct super_block *sb,
 					  bh->b_blocknr);
 		if (cn && can_dirty(cn)) {
 			set_buffer_journal_test(bh);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 		}
 		reiserfs_write_unlock(sb);
 	}
@@ -4183,7 +4183,7 @@ static int do_journal_end(struct reiserfs_transaction_handle *th, int flags)
 	 * dirty now too.  Don't mark the commit block dirty until all the
 	 * others are on disk
 	 */
-	mark_buffer_dirty(d_bh);
+	mark_buffer_dirty(NULL, d_bh);
 
 	/*
 	 * first data block is j_start + 1, so add one to
@@ -4212,7 +4212,7 @@ static int do_journal_end(struct reiserfs_transaction_handle *th, int flags)
 			       addr + offset_in_page(cn->bh->b_data),
 			       cn->bh->b_size);
 			kunmap(page);
-			mark_buffer_dirty(tmp_bh);
+			mark_buffer_dirty(NULL, tmp_bh);
 			jindex++;
 			set_buffer_journal_dirty(cn->bh);
 			clear_buffer_journaled(cn->bh);
diff --git a/fs/reiserfs/resize.c b/fs/reiserfs/resize.c
index 2196afda6e28..f80e8a7e7ac4 100644
--- a/fs/reiserfs/resize.c
+++ b/fs/reiserfs/resize.c
@@ -156,7 +156,7 @@ int reiserfs_resize(struct super_block *s, unsigned long block_count_new)
 			reiserfs_cache_bitmap_metadata(s, bh, bitmap + i);
 
 			set_buffer_uptodate(bh);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			depth = reiserfs_write_unlock_nested(s);
 			sync_dirty_buffer(bh);
 			reiserfs_write_lock_nested(s, depth);
diff --git a/fs/sysv/balloc.c b/fs/sysv/balloc.c
index 0e69dbdf7277..bfee0260f869 100644
--- a/fs/sysv/balloc.c
+++ b/fs/sysv/balloc.c
@@ -84,7 +84,7 @@ void sysv_free_block(struct super_block * sb, sysv_zone_t nr)
 		memset(bh->b_data, 0, sb->s_blocksize);
 		*(__fs16*)bh->b_data = cpu_to_fs16(sbi, count);
 		memcpy(get_chunk(sb,bh), blocks, count * sizeof(sysv_zone_t));
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		set_buffer_uptodate(bh);
 		brelse(bh);
 		count = 0;
diff --git a/fs/sysv/ialloc.c b/fs/sysv/ialloc.c
index 6c9801986af6..c3f09d9761a8 100644
--- a/fs/sysv/ialloc.c
+++ b/fs/sysv/ialloc.c
@@ -128,7 +128,7 @@ void sysv_free_inode(struct inode * inode)
 	fs16_add(sbi, sbi->s_sb_total_free_inodes, 1);
 	dirty_sb(sb);
 	memset(raw_inode, 0, sizeof(struct sysv_inode));
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	mutex_unlock(&sbi->s_lock);
 	brelse(bh);
 }
diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index bec9f79adb25..d7494995157a 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -49,7 +49,7 @@ static int sysv_sync_fs(struct super_block *sb, int wait)
 		if (*sbi->s_sb_state == cpu_to_fs32(sbi, 0x7c269d38 - old_time))
 			*sbi->s_sb_state = cpu_to_fs32(sbi, 0x7c269d38 - time);
 		*sbi->s_sb_time = cpu_to_fs32(sbi, time);
-		mark_buffer_dirty(sbi->s_bh2);
+		mark_buffer_dirty(NULL, sbi->s_bh2);
 	}
 
 	mutex_unlock(&sbi->s_lock);
@@ -73,9 +73,9 @@ static void sysv_put_super(struct super_block *sb)
 
 	if (!sb_rdonly(sb)) {
 		/* XXX ext2 also updates the state here */
-		mark_buffer_dirty(sbi->s_bh1);
+		mark_buffer_dirty(NULL, sbi->s_bh1);
 		if (sbi->s_bh1 != sbi->s_bh2)
-			mark_buffer_dirty(sbi->s_bh2);
+			mark_buffer_dirty(NULL, sbi->s_bh2);
 	}
 
 	brelse(sbi->s_bh1);
@@ -265,7 +265,7 @@ static int __sysv_write_inode(struct inode *inode, int wait)
 	for (block = 0; block < 10+1+1+1; block++)
 		write3byte(sbi, (u8 *)&si->i_data[block],
 			&raw_inode->i_data[3*block]);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (wait) {
                 sync_dirty_buffer(bh);
                 if (buffer_req(bh) && !buffer_uptodate(bh)) {
diff --git a/fs/sysv/sysv.h b/fs/sysv/sysv.h
index e913698779c0..3a3b5c16095a 100644
--- a/fs/sysv/sysv.h
+++ b/fs/sysv/sysv.h
@@ -116,9 +116,9 @@ static inline void dirty_sb(struct super_block *sb)
 {
 	struct sysv_sb_info *sbi = SYSV_SB(sb);
 
-	mark_buffer_dirty(sbi->s_bh1);
+	mark_buffer_dirty(NULL, sbi->s_bh1);
 	if (sbi->s_bh1 != sbi->s_bh2)
-		mark_buffer_dirty(sbi->s_bh2);
+		mark_buffer_dirty(NULL, sbi->s_bh2);
 }
 
 
diff --git a/fs/udf/balloc.c b/fs/udf/balloc.c
index 1b961b1d9699..9fa31c59835f 100644
--- a/fs/udf/balloc.c
+++ b/fs/udf/balloc.c
@@ -157,7 +157,7 @@ static void udf_bitmap_free_blocks(struct super_block *sb,
 			}
 		}
 		udf_add_free_space(sb, sbi->s_partition, count);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		if (overflow) {
 			block += count;
 			count = overflow;
@@ -209,7 +209,7 @@ static int udf_bitmap_prealloc_blocks(struct super_block *sb,
 			bit++;
 			block++;
 		}
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 	} while (block_count > 0);
 
 out:
@@ -332,7 +332,7 @@ static udf_pblk_t udf_bitmap_new_block(struct super_block *sb,
 		goto repeat;
 	}
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 
 	udf_add_free_space(sb, partition, -1);
 	mutex_unlock(&sbi->s_alloc_mutex);
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index 56cf8e70d298..6194f4c4bf12 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -1817,7 +1817,7 @@ static int udf_update_inode(struct inode *inode, int do_sync)
 	unlock_buffer(bh);
 
 	/* write the data blocks */
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (do_sync) {
 		sync_dirty_buffer(bh);
 		if (buffer_write_io_error(bh)) {
diff --git a/fs/udf/partition.c b/fs/udf/partition.c
index 090baff83990..0e4e05a41bee 100644
--- a/fs/udf/partition.c
+++ b/fs/udf/partition.c
@@ -204,7 +204,7 @@ int udf_relocate_blocks(struct super_block *sb, long old_block, long *new_block)
 						  reallocationTableLen *
 						  sizeof(struct sparingEntry);
 						udf_update_tag((char *)st, len);
-						mark_buffer_dirty(bh);
+						mark_buffer_dirty(NULL, bh);
 					}
 					*new_block = le32_to_cpu(
 							entry->mappedLocation) +
@@ -250,7 +250,7 @@ int udf_relocate_blocks(struct super_block *sb, long old_block, long *new_block)
 						sizeof(struct sparingTable) +
 						reallocationTableLen *
 						sizeof(struct sparingEntry));
-					mark_buffer_dirty(bh);
+					mark_buffer_dirty(NULL, bh);
 				}
 				*new_block =
 					le32_to_cpu(
diff --git a/fs/udf/super.c b/fs/udf/super.c
index f73239a9a97d..79c2bfd32986 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -2001,7 +2001,7 @@ static void udf_open_lvid(struct super_block *sb)
 			le16_to_cpu(lvid->descTag.descCRCLength)));
 
 	lvid->descTag.tagChecksum = udf_tag_checksum(&lvid->descTag);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	sbi->s_lvid_dirty = 0;
 	mutex_unlock(&sbi->s_alloc_mutex);
 	/* Make opening of filesystem visible on the media immediately */
@@ -2047,7 +2047,7 @@ static void udf_close_lvid(struct super_block *sb)
 	 * the buffer as !uptodate
 	 */
 	set_buffer_uptodate(bh);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	sbi->s_lvid_dirty = 0;
 	mutex_unlock(&sbi->s_alloc_mutex);
 	/* Make closing of filesystem visible on the media immediately */
@@ -2076,7 +2076,7 @@ u64 lvid_get_unique_id(struct super_block *sb)
 		uniqueID += 16;
 	lvhd->uniqueID = cpu_to_le64(uniqueID);
 	mutex_unlock(&sbi->s_alloc_mutex);
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 
 	return ret;
 }
@@ -2351,7 +2351,7 @@ static int udf_sync_fs(struct super_block *sb, int wait)
 		 * Blockdevice will be synced later so we don't have to submit
 		 * the buffer for IO
 		 */
-		mark_buffer_dirty(sbi->s_lvid_bh);
+		mark_buffer_dirty(NULL, sbi->s_lvid_bh);
 		sbi->s_lvid_dirty = 0;
 	}
 	mutex_unlock(&sbi->s_alloc_mutex);
diff --git a/fs/ufs/balloc.c b/fs/ufs/balloc.c
index e727ee07dbe4..3648422218dc 100644
--- a/fs/ufs/balloc.c
+++ b/fs/ufs/balloc.c
@@ -311,7 +311,7 @@ static void ufs_change_blocknr(struct inode *inode, sector_t beg,
 
 			bh->b_blocknr = newb + pos;
 			clean_bdev_bh_alias(bh);
-			mark_buffer_dirty(bh);
+			mark_buffer_dirty(NULL, bh);
 			++j;
 			bh = bh->b_this_page;
 		} while (bh != head);
@@ -333,7 +333,7 @@ static void ufs_clear_frags(struct inode *inode, sector_t beg, unsigned int n,
 		lock_buffer(bh);
 		memset(bh->b_data, 0, inode->i_sb->s_blocksize);
 		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		unlock_buffer(bh);
 		if (IS_SYNC(inode) || sync)
 			sync_dirty_buffer(bh);
diff --git a/fs/ufs/ialloc.c b/fs/ufs/ialloc.c
index e1ef0f0a1353..3a6dd9eea6a9 100644
--- a/fs/ufs/ialloc.c
+++ b/fs/ufs/ialloc.c
@@ -144,7 +144,7 @@ static void ufs2_init_inodes_chunk(struct super_block *sb,
 		lock_buffer(bh);
 		memset(bh->b_data, 0, sb->s_blocksize);
 		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		unlock_buffer(bh);
 		if (sb->s_flags & SB_SYNCHRONOUS)
 			sync_dirty_buffer(bh);
@@ -328,7 +328,7 @@ struct inode *ufs_new_inode(struct inode *dir, umode_t mode)
 		ktime_get_real_ts64(&ts);
 		ufs2_inode->ui_birthtime = cpu_to_fs64(sb, ts.tv_sec);
 		ufs2_inode->ui_birthnsec = cpu_to_fs32(sb, ts.tv_nsec);
-		mark_buffer_dirty(bh);
+		mark_buffer_dirty(NULL, bh);
 		unlock_buffer(bh);
 		if (sb->s_flags & SB_SYNCHRONOUS)
 			sync_dirty_buffer(bh);
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index fcaa60bfad49..c96630059d9e 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -375,7 +375,7 @@ ufs_inode_getblock(struct inode *inode, u64 ind_block,
 	if (new)
 		*new = 1;
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (IS_SYNC(inode))
 		sync_dirty_buffer(bh);
 	inode->i_ctime = current_time(inode);
@@ -829,7 +829,7 @@ static int ufs_update_inode(struct inode * inode, int do_sync)
 		ufs1_update_inode(inode, ufs_inode + ufs_inotofsbo(inode->i_ino));
 	}
 
-	mark_buffer_dirty(bh);
+	mark_buffer_dirty(NULL, bh);
 	if (do_sync)
 		sync_dirty_buffer(bh);
 	brelse (bh);
@@ -1095,7 +1095,7 @@ static int ufs_alloc_lastblock(struct inode *inode, loff_t size)
 		* if it maped to hole, it already contains zeroes
 		*/
 	       set_buffer_uptodate(bh);
-	       mark_buffer_dirty(bh);
+	       mark_buffer_dirty(NULL, bh);
 	       set_page_dirty(lastpage);
        }
 
@@ -1107,7 +1107,7 @@ static int ufs_alloc_lastblock(struct inode *inode, loff_t size)
 		       lock_buffer(bh);
 		       memset(bh->b_data, 0, sb->s_blocksize);
 		       set_buffer_uptodate(bh);
-		       mark_buffer_dirty(bh);
+		       mark_buffer_dirty(NULL, bh);
 		       unlock_buffer(bh);
 		       sync_dirty_buffer(bh);
 		       brelse(bh);
diff --git a/fs/ufs/util.c b/fs/ufs/util.c
index e8b3d6b70ca9..131f6ad2311f 100644
--- a/fs/ufs/util.c
+++ b/fs/ufs/util.c
@@ -96,7 +96,7 @@ void ubh_mark_buffer_dirty (struct ufs_buffer_head * ubh)
 	if (!ubh)
 		return;
 	for ( i = 0; i < ubh->count; i++ )
-		mark_buffer_dirty (ubh->bh[i]);
+		mark_buffer_dirty(NULL, ubh->bh[i]);
 }
 
 void ubh_mark_buffer_uptodate (struct ufs_buffer_head * ubh, int flag)
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 6c355f43b46b..5e77654f8e81 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -175,7 +175,7 @@ void buffer_check_dirty_writeback(struct page *page,
  * Declarations
  */
 
-void mark_buffer_dirty(struct buffer_head *bh);
+void mark_buffer_dirty(struct address_space *, struct buffer_head *);
 void mark_buffer_write_io_error(struct address_space *mapping,
 		struct page *page, struct buffer_head *bh);
 void touch_buffer(struct buffer_head *bh);
-- 
2.14.3
