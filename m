Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id BCDF26B0071
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:16:08 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so40796339pab.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 00:16:08 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id kz11si5607924pab.98.2015.04.15.00.16.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 00:16:02 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMU005R271D4W20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Apr 2015 08:20:01 +0100 (BST)
From: Beata Michalska <b.michalska@samsung.com>
Subject: [RFC 4/4] shmem: Add support for generic FS events
Date: Wed, 15 Apr 2015 09:15:47 +0200
Message-id: <1429082147-4151-5-git-send-email-b.michalska@samsung.com>
In-reply-to: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Add support for the generic FS events interface
covering threshold notifiactions and the ENOSPC
warning.

Signed-off-by: Beata Michalska <b.michalska@samsung.com>
---
 mm/shmem.c |   39 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index cf2d0ca..bb261ac 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -201,6 +201,7 @@ static int shmem_reserve_inode(struct super_block *sb)
 		spin_lock(&sbinfo->stat_lock);
 		if (!sbinfo->free_inodes) {
 			spin_unlock(&sbinfo->stat_lock);
+			fs_event_notify(sb, FS_EVENT_WARN, FS_WARN_ENOSPC);
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
@@ -1258,12 +1264,17 @@ unlock:
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
+			fs_event_notify(inode->i_sb, FS_EVENT_WARN,
+					FS_WARN_ENOSPC);
+		}
 	}
 	if (error == -EEXIST)	/* from above or from radix_tree_insert */
 		goto repeat;
@@ -2729,12 +2740,33 @@ static int shmem_encode_fh(struct inode *inode, __u32 *fh, int *len,
 	return 1;
 }
 
+static int shmem_trace_query(struct super_block *sb,
+				struct fs_trace_sdata *data)
+{
+	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
+
+	if (!sb || !data)
+		return -EINVAL;
+
+	data->events_cap_mask = FS_EVENT_WARN;
+	if (sbinfo->max_blocks) {
+		data->available_blks = sbinfo->max_blocks -
+			percpu_counter_sum(&sbinfo->used_blocks);
+		data->events_cap_mask |= FS_EVENT_THRESH;
+	}
+	return 0;
+}
+
 static const struct export_operations shmem_export_ops = {
 	.get_parent     = shmem_get_parent,
 	.encode_fh      = shmem_encode_fh,
 	.fh_to_dentry	= shmem_fh_to_dentry,
 };
 
+static const struct fs_trace_operations shmem_trace_ops = {
+	.fs_trace_query	= shmem_trace_query,
+};
+
 static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			       bool remount)
 {
@@ -3020,6 +3052,7 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 		sb->s_flags |= MS_NOUSER;
 	}
 	sb->s_export_op = &shmem_export_ops;
+	sb->s_trace_ops = &shmem_trace_ops;
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
