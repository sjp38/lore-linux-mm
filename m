Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9BADE6B0071
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:56:48 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so126986708pab.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:56:48 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id p6si29571704pdm.195.2015.04.27.04.56.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 04:56:44 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNG00FYYRUG9570@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Apr 2015 12:56:40 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC v2 3/4] ext4: Add support for generic FS events
Date: Mon, 27 Apr 2015 13:51:43 +0200
Message-id: <1430135504-24334-4-git-send-email-b.michalska@samsung.com>
In-reply-to: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Add support for generic FS events including threshold
notifications, ENOSPC and remount as read-only warnings,
along with generic internal warnings/errors.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 fs/ext4/balloc.c  |   10 ++++++++--
 fs/ext4/ext4.h    |    1 +
 fs/ext4/inode.c   |    2 +-
 fs/ext4/mballoc.c |    6 +++++-
 fs/ext4/resize.c  |    1 +
 fs/ext4/super.c   |   39 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index e95b27a..a48450f 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -569,6 +569,7 @@ int ext4_claim_free_clusters(struct ext4_sb_info *sbi,
 {
 	if (ext4_has_free_clusters(sbi, nclusters, flags)) {
 		percpu_counter_add(&sbi->s_dirtyclusters_counter, nclusters);
+		fs_event_alloc_space(sbi->s_sb, EXT4_C2B(sbi, nclusters));
 		return 0;
 	} else
 		return -ENOSPC;
@@ -590,9 +591,10 @@ int ext4_should_retry_alloc(struct super_block *sb, int *retries)
 {
 	if (!ext4_has_free_clusters(EXT4_SB(sb), 1, 0) ||
 	    (*retries)++ > 3 ||
-	    !EXT4_SB(sb)->s_journal)
+	    !EXT4_SB(sb)->s_journal) {
+		fs_event_notify(sb, FS_WARN_ENOSPC);
 		return 0;
-
+	}
 	jbd_debug(1, "%s: retrying operation after ENOSPC\n", sb->s_id);
 
 	return jbd2_journal_force_commit_nested(EXT4_SB(sb)->s_journal);
@@ -637,6 +639,10 @@ ext4_fsblk_t ext4_new_meta_blocks(handle_t *handle, struct inode *inode,
 		dquot_alloc_block_nofail(inode,
 				EXT4_C2B(EXT4_SB(inode->i_sb), ar.len));
 	}
+
+	if (*errp == -ENOSPC)
+		fs_event_notify(inode->i_sb, FS_WARN_ENOSPC_META);
+
 	return ret;
 }
 
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 163afe2..7d75ff9 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2542,6 +2542,7 @@ void ext4_mark_group_corrupted(struct ext4_sb_info *sbi,
 	if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
 		percpu_counter_sub(&sbi->s_freeclusters_counter, grp->bb_free);
 	set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
+	fs_event_alloc_space(sbi->s_sb, EXT4_C2B(sbi, grp->bb_free));
 }
 
 /*
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5cb9a21..2a7af0f 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1238,7 +1238,7 @@ static void ext4_da_release_space(struct inode *inode, int to_free)
 	percpu_counter_sub(&sbi->s_dirtyclusters_counter, to_free);
 
 	spin_unlock(&EXT4_I(inode)->i_block_reservation_lock);
-
+	fs_event_free_space(sbi->s_sb, to_free);
 	dquot_release_reservation_block(inode, EXT4_C2B(sbi, to_free));
 }
 
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 24a4b6d..c2df6f0 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -4511,6 +4511,9 @@ out:
 		kmem_cache_free(ext4_ac_cachep, ac);
 	if (inquota && ar->len < inquota)
 		dquot_free_block(ar->inode, EXT4_C2B(sbi, inquota - ar->len));
+	if (reserv_clstrs && ar->len < reserv_clstrs)
+		fs_event_free_space(sbi->s_sb,
+			EXT4_C2B(sbi, reserv_clstrs - ar->len));
 	if (!ar->len) {
 		if ((ar->flags & EXT4_MB_DELALLOC_RESERVED) == 0)
 			/* release all the reserved blocks if non delalloc */
@@ -4848,7 +4851,7 @@ do_more:
 	if (!(flags & EXT4_FREE_BLOCKS_NO_QUOT_UPDATE))
 		dquot_free_block(inode, EXT4_C2B(sbi, count_clusters));
 	percpu_counter_add(&sbi->s_freeclusters_counter, count_clusters);
-
+	fs_event_free_space(sb, EXT4_C2B(sbi, count_clusters));
 	ext4_mb_unload_buddy(&e4b);
 
 	/* We dirtied the bitmap block */
@@ -4982,6 +4985,7 @@ int ext4_group_add_blocks(handle_t *handle, struct super_block *sb,
 	ext4_unlock_group(sb, block_group);
 	percpu_counter_add(&sbi->s_freeclusters_counter,
 			   EXT4_NUM_B2C(sbi, blocks_freed));
+	fs_event_free_space(sb, blocks_freed);
 
 	if (sbi->s_log_groups_per_flex) {
 		ext4_group_t flex_group = ext4_flex_group(sbi, block_group);
diff --git a/fs/ext4/resize.c b/fs/ext4/resize.c
index 8a8ec62..dbf08d6 100644
--- a/fs/ext4/resize.c
+++ b/fs/ext4/resize.c
@@ -1378,6 +1378,7 @@ static void ext4_update_super(struct super_block *sb,
 			   EXT4_NUM_B2C(sbi, free_blocks));
 	percpu_counter_add(&sbi->s_freeinodes_counter,
 			   EXT4_INODES_PER_GROUP(sb) * flex_gd->count);
+	fs_event_free_space(sb, free_blocks - reserved_blocks);
 
 	ext4_debug("free blocks count %llu",
 		   percpu_counter_read(&sbi->s_freeclusters_counter));
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index e061e66..108b667 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -585,6 +585,8 @@ void __ext4_abort(struct super_block *sb, const char *function,
 		if (EXT4_SB(sb)->s_journal)
 			jbd2_journal_abort(EXT4_SB(sb)->s_journal, -EIO);
 		save_error_info(sb, function, line);
+		fs_event_notify(sb, FS_ERR_REMOUNT_RO);
+
 	}
 	if (test_opt(sb, ERRORS_PANIC))
 		panic("EXT4-fs panic from previous error\n");
@@ -1083,6 +1085,12 @@ static const struct quotactl_ops ext4_qctl_operations = {
 };
 #endif
 
+static void ext4_trace_query(struct super_block *sb, u64 *ncount);
+
+static const struct fs_trace_operations ext4_trace_ops = {
+	.query	= ext4_trace_query,
+};
+
 static const struct super_operations ext4_sops = {
 	.alloc_inode	= ext4_alloc_inode,
 	.destroy_inode	= ext4_destroy_inode,
@@ -3398,11 +3406,20 @@ static int ext4_reserve_clusters(struct ext4_sb_info *sbi, ext4_fsblk_t count)
 {
 	ext4_fsblk_t clusters = ext4_blocks_count(sbi->s_es) >>
 				sbi->s_cluster_bits;
+	ext4_fsblk_t current_resv;
 
 	if (count >= clusters)
 		return -EINVAL;
 
+	current_resv = atomic64_read(&sbi->s_resv_clusters);
 	atomic64_set(&sbi->s_resv_clusters, count);
+
+	if (count > current_resv)
+		fs_event_alloc_space(sbi->s_sb,
+			EXT4_C2B(sbi, count - current_resv));
+	else
+		fs_event_free_space(sbi->s_sb,
+			EXT4_C2B(sbi, current_resv - count));
 	return 0;
 }
 
@@ -3966,6 +3983,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		sb->s_qcop = &ext4_qctl_operations;
 	sb->s_quota_types = QTYPE_MASK_USR | QTYPE_MASK_GRP;
 #endif
+	sb->s_etrace.ops = &ext4_trace_ops;
+	sb->s_etrace.events_cap_mask = FS_EVENTS_ALL;
+
 	memcpy(sb->s_uuid, es->s_uuid, sizeof(es->s_uuid));
 
 	INIT_LIST_HEAD(&sbi->s_orphan); /* unlinked but open files */
@@ -5438,6 +5458,25 @@ out:
 
 #endif
 
+static void ext4_trace_query(struct super_block *sb, u64 *ncount)
+{
+	struct ext4_sb_info *sbi = EXT4_SB(sb);
+	struct ext4_super_block *es = sbi->s_es;
+	ext4_fsblk_t rsv_blocks;
+	ext4_fsblk_t nblocks;
+
+	nblocks = percpu_counter_sum_positive(&sbi->s_freeclusters_counter) -
+		percpu_counter_sum_positive(&sbi->s_dirtyclusters_counter);
+	nblocks = EXT4_C2B(sbi, nblocks);
+	rsv_blocks = ext4_r_blocks_count(es) +
+		     EXT4_C2B(sbi, atomic64_read(&sbi->s_resv_clusters));
+	if (nblocks < rsv_blocks)
+		nblocks = 0;
+	else
+		nblocks -= rsv_blocks;
+	*ncount = nblocks;
+}
+
 static struct dentry *ext4_mount(struct file_system_type *fs_type, int flags,
 		       const char *dev_name, void *data)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
