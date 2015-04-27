Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D47ED6B0073
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:56:52 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so126144352pdb.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 04:56:52 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id z5si24336745pdk.254.2015.04.27.04.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 04:56:45 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNG00B13RUG9580@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Apr 2015 12:56:41 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC v2 4/4] shmem: Add support for generic FS events
Date: Mon, 27 Apr 2015 13:51:44 +0200
Message-id: <1430135504-24334-5-git-send-email-b.michalska@samsung.com>
In-reply-to: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org
Cc: jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Add support for the generic FS events interface
covering threshold notifiactions and the ENOSPC
warning.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 mm/shmem.c |   33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index cf2d0ca..a044d12 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -201,6 +201,7 @@ static int shmem_reserve_inode(struct super_block *sb)
 		spin_lock(&sbinfo->stat_lock);
 		if (!sbinfo->free_inodes) {
 			spin_unlock(&sbinfo->stat_lock);
+			fs_event_notify(sb, FS_WARN_ENOSPC);
 			return -ENOSPC;
 		}
 		sbinfo->free_inodes--;
@@ -239,8 +240,10 @@ static void shmem_recalc_inode(struct inode *inode)
 	freed = info->alloced - info->swapped - inode->i_mapping->nrpages;
 	if (freed > 0) {
 		struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
-		if (sbinfo->max_blocks)
+		if (sbinfo->max_blocks) {
 			percpu_counter_add(&sbinfo->used_blocks, -freed);
+			fs_event_free_space(inode->i_sb, freed);
+		}
 		info->alloced -= freed;
 		inode->i_blocks -= freed * BLOCKS_PER_PAGE;
 		shmem_unacct_blocks(info->flags, freed);
@@ -1164,6 +1167,7 @@ repeat:
 				goto unacct;
 			}
 			percpu_counter_inc(&sbinfo->used_blocks);
+			fs_event_alloc_space(inode->i_sb, 1);
 		}
 
 		page = shmem_alloc_page(gfp, info, index);
@@ -1245,8 +1249,10 @@ trunc:
 	spin_unlock(&info->lock);
 decused:
 	sbinfo = SHMEM_SB(inode->i_sb);
-	if (sbinfo->max_blocks)
+	if (sbinfo->max_blocks) {
 		percpu_counter_add(&sbinfo->used_blocks, -1);
+		fs_event_free_space(inode->i_sb, 1);
+	}
 unacct:
 	shmem_unacct_blocks(info->flags, 1);
 failed:
@@ -1258,12 +1264,16 @@ unlock:
 		unlock_page(page);
 		page_cache_release(page);
 	}
-	if (error == -ENOSPC && !once++) {
+	if (error == -ENOSPC) {
+		if (!once++) {
 		info = SHMEM_I(inode);
 		spin_lock(&info->lock);
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
 		goto repeat;
+		} else {
+			fs_event_notify(inode->i_sb, FS_WARN_ENOSPC);
+		}
 	}
 	if (error == -EEXIST)	/* from above or from radix_tree_insert */
 		goto repeat;
@@ -2729,12 +2739,26 @@ static int shmem_encode_fh(struct inode *inode, __u32 *fh, int *len,
 	return 1;
 }
 
+static void shmem_trace_query(struct super_block *sb, u64 *ncount)
+{
+	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
+
+	if (sbinfo->max_blocks)
+		*ncount = sbinfo->max_blocks -
+			percpu_counter_sum(&sbinfo->used_blocks);
+
+}
+
 static const struct export_operations shmem_export_ops = {
 	.get_parent     = shmem_get_parent,
 	.encode_fh      = shmem_encode_fh,
 	.fh_to_dentry	= shmem_fh_to_dentry,
 };
 
+static const struct fs_trace_operations shmem_trace_ops = {
+	.query	= shmem_trace_query,
+};
+
 static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			       bool remount)
 {
@@ -3020,6 +3044,9 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 		sb->s_flags |= MS_NOUSER;
 	}
 	sb->s_export_op = &shmem_export_ops;
+	sb->s_etrace.ops = &shmem_trace_ops;
+	sb->s_etrace.events_cap_mask = FS_EVENTS_ALL;
+
 	sb->s_flags |= MS_NOSEC;
 #else
 	sb->s_flags |= MS_NOUSER;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
