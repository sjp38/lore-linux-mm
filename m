Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D070E6B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:16:00 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so41880294pdb.2
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 00:16:00 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id jm12si5534634pbd.250.2015.04.15.00.15.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 00:15:59 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMU00L99713FP30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Apr 2015 08:19:51 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC 2/4] ext4: Add helper function to mark group as corrupted
Date: Wed, 15 Apr 2015 09:15:45 +0200
Message-id: <1429082147-4151-3-git-send-email-b.michalska@samsung.com>
In-reply-to: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Add ext4_mark_group_corrupted helper function to
simplify the code and to keep the logic in one place.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 fs/ext4/balloc.c  |   15 +++------------
 fs/ext4/ext4.h    |    9 +++++++++
 fs/ext4/ialloc.c  |    5 +----
 fs/ext4/mballoc.c |   11 ++---------
 4 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index 83a6f49..e95b27a 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -193,10 +193,7 @@ static int ext4_init_block_bitmap(struct super_block *sb,
 	 * essentially implementing a per-group read-only flag. */
 	if (!ext4_group_desc_csum_verify(sb, block_group, gdp)) {
 		grp = ext4_get_group_info(sb, block_group);
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   grp->bb_free);
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+		ext4_mark_group_corrupted(sbi, grp);
 		if (!EXT4_MB_GRP_IBITMAP_CORRUPT(grp)) {
 			int count;
 			count = ext4_free_inodes_count(sb, gdp);
@@ -379,20 +376,14 @@ static void ext4_validate_block_bitmap(struct super_block *sb,
 		ext4_unlock_group(sb, block_group);
 		ext4_error(sb, "bg %u: block %llu: invalid block bitmap",
 			   block_group, blk);
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   grp->bb_free);
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+		ext4_mark_group_corrupted(sbi, grp);
 		return;
 	}
 	if (unlikely(!ext4_block_bitmap_csum_verify(sb, block_group,
 			desc, bh))) {
 		ext4_unlock_group(sb, block_group);
 		ext4_error(sb, "bg %u: bad block bitmap checksum", block_group);
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   grp->bb_free);
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+		ext4_mark_group_corrupted(sbi, grp);
 		return;
 	}
 	set_buffer_verified(bh);
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index f63c3d5..163afe2 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2535,6 +2535,15 @@ static inline spinlock_t *ext4_group_lock_ptr(struct super_block *sb,
 	return bgl_lock_ptr(EXT4_SB(sb)->s_blockgroup_lock, group);
 }
 
+static inline
+void ext4_mark_group_corrupted(struct ext4_sb_info *sbi,
+				struct ext4_group_info *grp)
+{
+	if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
+		percpu_counter_sub(&sbi->s_freeclusters_counter, grp->bb_free);
+	set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+}
+
 /*
  * Returns true if the filesystem is busy enough that attempts to
  * access the block group locks has run into contention.
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index ac644c3..ebe0499 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -79,10 +79,7 @@ static unsigned ext4_init_inode_bitmap(struct super_block *sb,
 	if (!ext4_group_desc_csum_verify(sb, block_group, gdp)) {
 		ext4_error(sb, "Checksum bad for group %u", block_group);
 		grp = ext4_get_group_info(sb, block_group);
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   grp->bb_free);
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+		ext4_mark_group_corrupted(sbi, grp);
 		if (!EXT4_MB_GRP_IBITMAP_CORRUPT(grp)) {
 			int count;
 			count = ext4_free_inodes_count(sb, gdp);
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 8d1e602..24a4b6d 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -760,10 +760,7 @@ void ext4_mb_generate_buddy(struct super_block *sb,
 		 * corrupt and update bb_free using bitmap value
 		 */
 		grp->bb_free = free;
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   grp->bb_free);
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+		ext4_mark_group_corrupted(sbi, grp);
 	}
 	mb_set_largest_free_order(sb, grp);
 
@@ -1448,12 +1445,8 @@ static void mb_free_blocks(struct inode *inode, struct ext4_buddy *e4b,
 				      "freeing already freed block "
 				      "(bit %u); block bitmap corrupt.",
 				      block);
-		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(e4b->bd_info))
-			percpu_counter_sub(&sbi->s_freeclusters_counter,
-					   e4b->bd_info->bb_free);
 		/* Mark the block group as corrupt. */
-		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT,
-			&e4b->bd_info->bb_state);
+		ext4_mark_group_corrupted(sbi, e4b->bd_info);
 		mb_regenerate_buddy(e4b);
 		goto done;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
