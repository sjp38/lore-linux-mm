Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA9226B0261
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i23so15474646qke.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s184si6104879qkc.130.2018.04.04.12.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:19 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 36/79] fs/buffer: add struct super_block to bforget() arguments
Date: Wed,  4 Apr 2018 15:18:10 -0400
Message-Id: <20180404191831.5378-21-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct super_block to bforget() arguments.

spatch --sp-file zemantic-012a.spatch --in-place --dir fs/
----------------------------------------------------------------------
@exists@
expression E1;
identifier I;
@@
struct super_block *I;
...
-bforget(E1)
+bforget(I, E1)

@exists@
expression E1;
identifier F, I;
@@
F(..., struct super_block *I, ...) {
...
-bforget(E1)
+bforget(I, E1)
...
}

@exists@
expression E1;
identifier I;
@@
struct inode *I;
...
-bforget(E1)
+bforget(I->i_sb, E1)

@exists@
expression E1;
identifier F, I;
@@
F(..., struct inode *I, ...) {
...
-bforget(E1)
+bforget(I->i_sb, E1)
...
}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/bfs/file.c               | 2 +-
 fs/ext2/inode.c             | 4 ++--
 fs/ext2/xattr.c             | 4 ++--
 fs/ext4/ext4_jbd2.c         | 2 +-
 fs/fat/dir.c                | 4 ++--
 fs/jfs/resize.c             | 2 +-
 fs/minix/itree_common.c     | 6 +++---
 fs/reiserfs/journal.c       | 2 +-
 fs/reiserfs/resize.c        | 2 +-
 fs/sysv/itree.c             | 6 +++---
 fs/ufs/util.c               | 2 +-
 include/linux/buffer_head.h | 2 +-
 12 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index b1255ee4cd75..6d66cc137bc3 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -41,7 +41,7 @@ static int bfs_move_block(unsigned long from, unsigned long to,
 	new = sb_getblk(sb, to);
 	memcpy(new->b_data, bh->b_data, bh->b_size);
 	mark_buffer_dirty(new);
-	bforget(bh);
+	bforget(sb, bh);
 	brelse(new);
 	return 0;
 }
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 33873c0a4c14..83ea6ad2cefa 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -536,7 +536,7 @@ static int ext2_alloc_branch(struct inode *inode,
 
 failed:
 	for (i = 1; i < n; i++)
-		bforget(branch[i].bh);
+		bforget(inode->i_sb, branch[i].bh);
 	for (i = 0; i < indirect_blks; i++)
 		ext2_free_blocks(inode, new_blocks[i], 1);
 	ext2_free_blocks(inode, new_blocks[i], num);
@@ -1167,7 +1167,7 @@ static void ext2_free_branches(struct inode *inode, __le32 *p, __le32 *q, int de
 					   (__le32*)bh->b_data,
 					   (__le32*)bh->b_data + addr_per_block,
 					   depth);
-			bforget(bh);
+			bforget(inode->i_sb, bh);
 			ext2_free_blocks(inode, nr, 1);
 			mark_inode_dirty(inode);
 		}
diff --git a/fs/ext2/xattr.c b/fs/ext2/xattr.c
index 62d9a659a8ff..c77edf9afbce 100644
--- a/fs/ext2/xattr.c
+++ b/fs/ext2/xattr.c
@@ -733,7 +733,7 @@ ext2_xattr_set2(struct inode *inode, struct buffer_head *old_bh,
 			/* We let our caller release old_bh, so we
 			 * need to duplicate the buffer before. */
 			get_bh(old_bh);
-			bforget(old_bh);
+			bforget(sb, old_bh);
 		} else {
 			/* Decrement the refcount only. */
 			le32_add_cpu(&HDR(old_bh)->h_refcount, -1);
@@ -802,7 +802,7 @@ ext2_xattr_delete_inode(struct inode *inode)
 				      bh->b_blocknr);
 		ext2_free_blocks(inode, EXT2_I(inode)->i_file_acl, 1);
 		get_bh(bh);
-		bforget(bh);
+		bforget(inode->i_sb, bh);
 		unlock_buffer(bh);
 	} else {
 		le32_add_cpu(&HDR(bh)->h_refcount, -1);
diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 5529badca994..60fbf5336059 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -211,7 +211,7 @@ int __ext4_forget(const char *where, unsigned int line, handle_t *handle,
 
 	/* In the no journal case, we can just do a bforget and return */
 	if (!ext4_handle_valid(handle)) {
-		bforget(bh);
+		bforget(inode->i_sb, bh);
 		return 0;
 	}
 
diff --git a/fs/fat/dir.c b/fs/fat/dir.c
index 8e100c3bf72c..b801f3d0220b 100644
--- a/fs/fat/dir.c
+++ b/fs/fat/dir.c
@@ -1126,7 +1126,7 @@ static int fat_zeroed_cluster(struct inode *dir, sector_t blknr, int nr_used,
 
 error:
 	for (i = 0; i < n; i++)
-		bforget(bhs[i]);
+		bforget(sb, bhs[i]);
 	return err;
 }
 
@@ -1266,7 +1266,7 @@ static int fat_add_new_entries(struct inode *dir, void *slots, int nr_slots,
 	n = 0;
 error_nomem:
 	for (i = 0; i < n; i++)
-		bforget(bhs[i]);
+		bforget(sb, bhs[i]);
 	fat_free_clusters(dir, cluster[0]);
 error:
 	return err;
diff --git a/fs/jfs/resize.c b/fs/jfs/resize.c
index 7ddcb445a3d9..c1f417b94fe6 100644
--- a/fs/jfs/resize.c
+++ b/fs/jfs/resize.c
@@ -114,7 +114,7 @@ int jfs_extendfs(struct super_block *sb, s64 newLVSize, int newLogSize)
 			rc = -EINVAL;
 			goto out;
 		}
-		bforget(bh);
+		bforget(sb, bh);
 	}
 
 	/* Can't extend write-protected drive */
diff --git a/fs/minix/itree_common.c b/fs/minix/itree_common.c
index 043c3fdbc8e7..86a3c3a4e767 100644
--- a/fs/minix/itree_common.c
+++ b/fs/minix/itree_common.c
@@ -100,7 +100,7 @@ static int alloc_branch(struct inode *inode,
 
 	/* Allocation failed, free what we already allocated */
 	for (i = 1; i < n; i++)
-		bforget(branch[i].bh);
+		bforget(inode->i_sb, branch[i].bh);
 	for (i = 0; i < n; i++)
 		minix_free_block(inode, block_to_cpu(branch[i].key));
 	return -ENOSPC;
@@ -137,7 +137,7 @@ static inline int splice_branch(struct inode *inode,
 changed:
 	write_unlock(&pointers_lock);
 	for (i = 1; i < num; i++)
-		bforget(where[i].bh);
+		bforget(inode->i_sb, where[i].bh);
 	for (i = 0; i < num; i++)
 		minix_free_block(inode, block_to_cpu(where[i].key));
 	return -EAGAIN;
@@ -283,7 +283,7 @@ static void free_branches(struct inode *inode, block_t *p, block_t *q, int depth
 				continue;
 			free_branches(inode, (block_t*)bh->b_data,
 				      block_end(bh), depth);
-			bforget(bh);
+			bforget(inode->i_sb, bh);
 			minix_free_block(inode, nr);
 			mark_inode_dirty(inode);
 		}
diff --git a/fs/reiserfs/journal.c b/fs/reiserfs/journal.c
index 230cb2a2309a..ee5b1d1b3a3d 100644
--- a/fs/reiserfs/journal.c
+++ b/fs/reiserfs/journal.c
@@ -1132,7 +1132,7 @@ static int flush_commit_list(struct super_block *s,
 #endif
 		retval = -EIO;
 	}
-	bforget(jl->j_commit_bh);
+	bforget(s, jl->j_commit_bh);
 	if (journal->j_last_commit_id != 0 &&
 	    (jl->j_trans_id - journal->j_last_commit_id) != 1) {
 		reiserfs_warning(s, "clm-2200", "last commit %lu, current %lu",
diff --git a/fs/reiserfs/resize.c b/fs/reiserfs/resize.c
index 6052d323bc9a..2196afda6e28 100644
--- a/fs/reiserfs/resize.c
+++ b/fs/reiserfs/resize.c
@@ -51,7 +51,7 @@ int reiserfs_resize(struct super_block *s, unsigned long block_count_new)
 		printk("reiserfs_resize: can\'t read last block\n");
 		return -EINVAL;
 	}
-	bforget(bh);
+	bforget(s, bh);
 
 	/*
 	 * old disk layout detection; those partitions can be mounted, but
diff --git a/fs/sysv/itree.c b/fs/sysv/itree.c
index 3b7d27e07e31..61a2a0deba75 100644
--- a/fs/sysv/itree.c
+++ b/fs/sysv/itree.c
@@ -159,7 +159,7 @@ static int alloc_branch(struct inode *inode,
 
 	/* Allocation failed, free what we already allocated */
 	for (i = 1; i < n; i++)
-		bforget(branch[i].bh);
+		bforget(inode->i_sb, branch[i].bh);
 	for (i = 0; i < n; i++)
 		sysv_free_block(inode->i_sb, branch[i].key);
 	return -ENOSPC;
@@ -194,7 +194,7 @@ static inline int splice_branch(struct inode *inode,
 changed:
 	write_unlock(&pointers_lock);
 	for (i = 1; i < num; i++)
-		bforget(where[i].bh);
+		bforget(inode->i_sb, where[i].bh);
 	for (i = 0; i < num; i++)
 		sysv_free_block(inode->i_sb, where[i].key);
 	return -EAGAIN;
@@ -353,7 +353,7 @@ static void free_branches(struct inode *inode, sysv_zone_t *p, sysv_zone_t *q, i
 				continue;
 			free_branches(inode, (sysv_zone_t*)bh->b_data,
 					block_end(bh), depth);
-			bforget(bh);
+			bforget(sb, bh);
 			sysv_free_block(sb, nr);
 			mark_inode_dirty(inode);
 		}
diff --git a/fs/ufs/util.c b/fs/ufs/util.c
index 596f576b2061..7b599af21858 100644
--- a/fs/ufs/util.c
+++ b/fs/ufs/util.c
@@ -132,7 +132,7 @@ void ubh_bforget (struct super_block *sb, struct ufs_buffer_head * ubh)
 	if (!ubh) 
 		return;
 	for ( i = 0; i < ubh->count; i++ ) if ( ubh->bh[i] ) 
-		bforget (ubh->bh[i]);
+		bforget(sb, ubh->bh[i]);
 }
  
 int ubh_buffer_dirty (struct ufs_buffer_head * ubh)
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 61db6d5e7d85..82faae102ba2 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -303,7 +303,7 @@ static inline void brelse(struct buffer_head *bh)
 		__brelse(bh);
 }
 
-static inline void bforget(struct buffer_head *bh)
+static inline void bforget(struct super_block *sb, struct buffer_head *bh)
 {
 	if (bh)
 		__bforget(bh);
-- 
2.14.3
