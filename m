Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8B466B02A8
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:20 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p204so3143431iod.16
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o67si5874203itb.7.2017.12.15.14.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 73/78] xfs: Convert xfs dquot to XArray
Date: Fri, 15 Dec 2017 14:04:45 -0800
Message-Id: <20171215220450.7899-74-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a pretty straight-forward conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/xfs/xfs_dquot.c | 38 +++++++++++++++++++++-----------------
 fs/xfs/xfs_qm.c    | 32 ++++++++++++++++----------------
 fs/xfs/xfs_qm.h    | 18 +++++++++---------
 3 files changed, 46 insertions(+), 42 deletions(-)

diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index e2a466df5dd1..c6832db23ca8 100644
--- a/fs/xfs/xfs_dquot.c
+++ b/fs/xfs/xfs_dquot.c
@@ -44,7 +44,7 @@
  * Lock order:
  *
  * ip->i_lock
- *   qi->qi_tree_lock
+ *   qi->qi_xa_lock
  *     dquot->q_qlock (xfs_dqlock() and friends)
  *       dquot->q_flush (xfs_dqflock() and friends)
  *       qi->qi_lru_lock
@@ -752,8 +752,8 @@ xfs_qm_dqget(
 	xfs_dquot_t	**O_dqpp) /* OUT : locked incore dquot */
 {
 	struct xfs_quotainfo	*qi = mp->m_quotainfo;
-	struct radix_tree_root *tree = xfs_dquot_tree(qi, type);
-	struct xfs_dquot	*dqp;
+	struct xarray		*xa = xfs_dquot_xa(qi, type);
+	struct xfs_dquot	*dqp, *duplicate;
 	int			error;
 
 	ASSERT(XFS_IS_QUOTA_RUNNING(mp));
@@ -772,23 +772,24 @@ xfs_qm_dqget(
 	}
 
 restart:
-	mutex_lock(&qi->qi_tree_lock);
-	dqp = radix_tree_lookup(tree, id);
+	mutex_lock(&qi->qi_xa_lock);
+	dqp = xa_load(xa, id);
+found:
 	if (dqp) {
 		xfs_dqlock(dqp);
 		if (dqp->dq_flags & XFS_DQ_FREEING) {
 			xfs_dqunlock(dqp);
-			mutex_unlock(&qi->qi_tree_lock);
+			mutex_unlock(&qi->qi_xa_lock);
 			trace_xfs_dqget_freeing(dqp);
 			delay(1);
 			goto restart;
 		}
 
-		/* uninit / unused quota found in radix tree, keep looking  */
+		/* uninit / unused quota found, keep looking  */
 		if (flags & XFS_QMOPT_DQNEXT) {
 			if (XFS_IS_DQUOT_UNINITIALIZED(dqp)) {
 				xfs_dqunlock(dqp);
-				mutex_unlock(&qi->qi_tree_lock);
+				mutex_unlock(&qi->qi_xa_lock);
 				error = xfs_dq_get_next_id(mp, type, &id);
 				if (error)
 					return error;
@@ -797,14 +798,14 @@ xfs_qm_dqget(
 		}
 
 		dqp->q_nrefs++;
-		mutex_unlock(&qi->qi_tree_lock);
+		mutex_unlock(&qi->qi_xa_lock);
 
 		trace_xfs_dqget_hit(dqp);
 		XFS_STATS_INC(mp, xs_qm_dqcachehits);
 		*O_dqpp = dqp;
 		return 0;
 	}
-	mutex_unlock(&qi->qi_tree_lock);
+	mutex_unlock(&qi->qi_xa_lock);
 	XFS_STATS_INC(mp, xs_qm_dqcachemisses);
 
 	/*
@@ -854,20 +855,23 @@ xfs_qm_dqget(
 		}
 	}
 
-	mutex_lock(&qi->qi_tree_lock);
-	error = radix_tree_insert(tree, id, dqp);
-	if (unlikely(error)) {
-		WARN_ON(error != -EEXIST);
+	mutex_lock(&qi->qi_xa_lock);
+	duplicate = xa_cmpxchg(xa, id, NULL, dqp, GFP_NOFS);
+	if (unlikely(duplicate)) {
+		if (xa_is_err(duplicate)) {
+			mutex_unlock(&qi->qi_xa_lock);
+			return xa_err(duplicate);
+		}
 
 		/*
 		 * Duplicate found. Just throw away the new dquot and start
 		 * over.
 		 */
-		mutex_unlock(&qi->qi_tree_lock);
 		trace_xfs_dqget_dup(dqp);
 		xfs_qm_dqdestroy(dqp);
 		XFS_STATS_INC(mp, xs_qm_dquot_dups);
-		goto restart;
+		dqp = duplicate;
+		goto found;
 	}
 
 	/*
@@ -877,7 +881,7 @@ xfs_qm_dqget(
 	dqp->q_nrefs = 1;
 
 	qi->qi_dquots++;
-	mutex_unlock(&qi->qi_tree_lock);
+	mutex_unlock(&qi->qi_xa_lock);
 
 	/* If we are asked to find next active id, keep looking */
 	if (flags & XFS_QMOPT_DQNEXT) {
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index ec952dfad359..c8bc3be157e0 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -67,7 +67,7 @@ xfs_qm_dquot_walk(
 	void			*data)
 {
 	struct xfs_quotainfo	*qi = mp->m_quotainfo;
-	struct radix_tree_root	*tree = xfs_dquot_tree(qi, type);
+	struct xarray		*xa = xfs_dquot_xa(qi, type);
 	uint32_t		next_index;
 	int			last_error = 0;
 	int			skipped;
@@ -83,11 +83,11 @@ xfs_qm_dquot_walk(
 		int		error = 0;
 		int		i;
 
-		mutex_lock(&qi->qi_tree_lock);
-		nr_found = radix_tree_gang_lookup(tree, (void **)batch,
-					next_index, XFS_DQ_LOOKUP_BATCH);
+		mutex_lock(&qi->qi_xa_lock);
+		nr_found = xa_get_entries(xa, (void **)batch, next_index,
+					ULONG_MAX, XFS_DQ_LOOKUP_BATCH);
 		if (!nr_found) {
-			mutex_unlock(&qi->qi_tree_lock);
+			mutex_unlock(&qi->qi_xa_lock);
 			break;
 		}
 
@@ -105,7 +105,7 @@ xfs_qm_dquot_walk(
 				last_error = error;
 		}
 
-		mutex_unlock(&qi->qi_tree_lock);
+		mutex_unlock(&qi->qi_xa_lock);
 
 		/* bail out if the filesystem is corrupted.  */
 		if (last_error == -EFSCORRUPTED) {
@@ -178,8 +178,8 @@ xfs_qm_dqpurge(
 	xfs_dqfunlock(dqp);
 	xfs_dqunlock(dqp);
 
-	radix_tree_delete(xfs_dquot_tree(qi, dqp->q_core.d_flags),
-			  be32_to_cpu(dqp->q_core.d_id));
+	xa_store(xfs_dquot_xa(qi, dqp->q_core.d_flags),
+			  be32_to_cpu(dqp->q_core.d_id), NULL, GFP_NOWAIT);
 	qi->qi_dquots--;
 
 	/*
@@ -623,10 +623,10 @@ xfs_qm_init_quotainfo(
 	if (error)
 		goto out_free_lru;
 
-	INIT_RADIX_TREE(&qinf->qi_uquota_tree, GFP_NOFS);
-	INIT_RADIX_TREE(&qinf->qi_gquota_tree, GFP_NOFS);
-	INIT_RADIX_TREE(&qinf->qi_pquota_tree, GFP_NOFS);
-	mutex_init(&qinf->qi_tree_lock);
+	xa_init(&qinf->qi_uquota_xa);
+	xa_init(&qinf->qi_gquota_xa);
+	xa_init(&qinf->qi_pquota_xa);
+	mutex_init(&qinf->qi_xa_lock);
 
 	/* mutex used to serialize quotaoffs */
 	mutex_init(&qinf->qi_quotaofflock);
@@ -1606,12 +1606,12 @@ xfs_qm_dqfree_one(
 	struct xfs_mount	*mp = dqp->q_mount;
 	struct xfs_quotainfo	*qi = mp->m_quotainfo;
 
-	mutex_lock(&qi->qi_tree_lock);
-	radix_tree_delete(xfs_dquot_tree(qi, dqp->q_core.d_flags),
-			  be32_to_cpu(dqp->q_core.d_id));
+	mutex_lock(&qi->qi_xa_lock);
+	xa_store(xfs_dquot_xa(qi, dqp->q_core.d_flags),
+			  be32_to_cpu(dqp->q_core.d_id), NULL, GFP_NOWAIT);
 
 	qi->qi_dquots--;
-	mutex_unlock(&qi->qi_tree_lock);
+	mutex_unlock(&qi->qi_xa_lock);
 
 	xfs_qm_dqdestroy(dqp);
 }
diff --git a/fs/xfs/xfs_qm.h b/fs/xfs/xfs_qm.h
index 2975a822e9f0..946f929f7bfb 100644
--- a/fs/xfs/xfs_qm.h
+++ b/fs/xfs/xfs_qm.h
@@ -67,10 +67,10 @@ struct xfs_def_quota {
  * The mount structure keeps a pointer to this.
  */
 typedef struct xfs_quotainfo {
-	struct radix_tree_root qi_uquota_tree;
-	struct radix_tree_root qi_gquota_tree;
-	struct radix_tree_root qi_pquota_tree;
-	struct mutex qi_tree_lock;
+	struct xarray	qi_uquota_xa;
+	struct xarray	qi_gquota_xa;
+	struct xarray	qi_pquota_xa;
+	struct mutex	qi_xa_lock;
 	struct xfs_inode	*qi_uquotaip;	/* user quota inode */
 	struct xfs_inode	*qi_gquotaip;	/* group quota inode */
 	struct xfs_inode	*qi_pquotaip;	/* project quota inode */
@@ -91,18 +91,18 @@ typedef struct xfs_quotainfo {
 	struct shrinker  qi_shrinker;
 } xfs_quotainfo_t;
 
-static inline struct radix_tree_root *
-xfs_dquot_tree(
+static inline struct xarray *
+xfs_dquot_xa(
 	struct xfs_quotainfo	*qi,
 	int			type)
 {
 	switch (type) {
 	case XFS_DQ_USER:
-		return &qi->qi_uquota_tree;
+		return &qi->qi_uquota_xa;
 	case XFS_DQ_GROUP:
-		return &qi->qi_gquota_tree;
+		return &qi->qi_gquota_xa;
 	case XFS_DQ_PROJ:
-		return &qi->qi_pquota_tree;
+		return &qi->qi_pquota_xa;
 	default:
 		ASSERT(0);
 	}
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
