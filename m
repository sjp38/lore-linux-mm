Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3972E6B006E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:14:36 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 15/28] xfs: convert dquot cache lru to list_lru
Date: Fri, 29 Mar 2013 13:13:57 +0400
Message-Id: <1364548450-28254-16-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@parallels.com>

From: Dave Chinner <dchinner@redhat.com>

Convert the XFS dquot lru to use the list_lru construct and convert
the shrinker to being node aware.

[ glommer: edited for conflicts ]

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 fs/xfs/xfs_dquot.c |   7 +-
 fs/xfs/xfs_qm.c    | 274 +++++++++++++++++++++++++++--------------------------
 fs/xfs/xfs_qm.h    |   4 +-
 3 files changed, 141 insertions(+), 144 deletions(-)

diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index 8025eb2..c15e7f9 100644
--- a/fs/xfs/xfs_dquot.c
+++ b/fs/xfs/xfs_dquot.c
@@ -837,13 +837,8 @@ xfs_qm_dqput_final(
 
 	trace_xfs_dqput_free(dqp);
 
-	mutex_lock(&qi->qi_lru_lock);
-	if (list_empty(&dqp->q_lru)) {
-		list_add_tail(&dqp->q_lru, &qi->qi_lru_list);
-		qi->qi_lru_count++;
+	if (list_lru_add(&qi->qi_lru, &dqp->q_lru))
 		XFS_STATS_INC(xs_qm_dquot_unused);
-	}
-	mutex_unlock(&qi->qi_lru_lock);
 
 	/*
 	 * If we just added a udquot to the freelist, then we want to release
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 305f4e5..0084362 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -50,8 +50,9 @@
  */
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(struct shrinker *, struct shrink_control *);
 
+
+STATIC void	xfs_qm_dqfree_one(struct xfs_dquot *dqp);
 /*
  * We use the batch lookup interface to iterate over the dquots as it
  * currently is the only interface into the radix tree code that allows
@@ -196,12 +197,9 @@ xfs_qm_dqpurge(
 	 * We move dquots to the freelist as soon as their reference count
 	 * hits zero, so it really should be on the freelist here.
 	 */
-	mutex_lock(&qi->qi_lru_lock);
 	ASSERT(!list_empty(&dqp->q_lru));
-	list_del_init(&dqp->q_lru);
-	qi->qi_lru_count--;
+	list_lru_del(&qi->qi_lru, &dqp->q_lru);
 	XFS_STATS_DEC(xs_qm_dquot_unused);
-	mutex_unlock(&qi->qi_lru_lock);
 
 	xfs_qm_dqdestroy(dqp);
 
@@ -617,6 +615,139 @@ xfs_qm_dqdetach(
 	}
 }
 
+struct xfs_qm_isolate {
+	struct list_head	buffers;
+	struct list_head	dispose;
+};
+
+static int
+xfs_qm_dquot_isolate(
+	struct list_head	*item,
+	spinlock_t		*lru_lock,
+	void			*arg)
+{
+	struct xfs_dquot	*dqp = container_of(item,
+						struct xfs_dquot, q_lru);
+	struct xfs_qm_isolate	*isol = arg;
+
+	if (!xfs_dqlock_nowait(dqp))
+		goto out_miss_busy;
+
+	/*
+	 * This dquot has acquired a reference in the meantime remove it from
+	 * the freelist and try again.
+	 */
+	if (dqp->q_nrefs) {
+		xfs_dqunlock(dqp);
+		XFS_STATS_INC(xs_qm_dqwants);
+
+		trace_xfs_dqreclaim_want(dqp);
+		list_del_init(&dqp->q_lru);
+		XFS_STATS_DEC(xs_qm_dquot_unused);
+		return 0;
+	}
+
+	/*
+	 * If the dquot is dirty, flush it. If it's already being flushed, just
+	 * skip it so there is time for the IO to complete before we try to
+	 * reclaim it again on the next LRU pass.
+	 */
+	if (!xfs_dqflock_nowait(dqp))
+		xfs_dqunlock(dqp);
+		goto out_miss_busy;
+
+	if (XFS_DQ_IS_DIRTY(dqp)) {
+		struct xfs_buf	*bp = NULL;
+		int		error;
+
+		trace_xfs_dqreclaim_dirty(dqp);
+
+		/* we have to drop the LRU lock to flush the dquot */
+		spin_unlock(lru_lock);
+
+		error = xfs_qm_dqflush(dqp, &bp);
+		if (error) {
+			xfs_warn(dqp->q_mount, "%s: dquot %p flush failed",
+				 __func__, dqp);
+			goto out_unlock_dirty;
+		}
+
+		xfs_buf_delwri_queue(bp, &isol->buffers);
+		xfs_buf_relse(bp);
+		goto out_unlock_dirty;
+	}
+	xfs_dqfunlock(dqp);
+
+	/*
+	 * Prevent lookups now that we are past the point of no return.
+	 */
+	dqp->dq_flags |= XFS_DQ_FREEING;
+	xfs_dqunlock(dqp);
+
+	ASSERT(dqp->q_nrefs == 0);
+	list_move_tail(&dqp->q_lru, &isol->dispose);
+	XFS_STATS_DEC(xs_qm_dquot_unused);
+	trace_xfs_dqreclaim_done(dqp);
+	XFS_STATS_INC(xs_qm_dqreclaims);
+	return 0;
+
+out_miss_busy:
+	trace_xfs_dqreclaim_busy(dqp);
+	XFS_STATS_INC(xs_qm_dqreclaim_misses);
+	return 2;
+
+out_unlock_dirty:
+	trace_xfs_dqreclaim_busy(dqp);
+	XFS_STATS_INC(xs_qm_dqreclaim_misses);
+	return 3;
+}
+
+static long
+xfs_qm_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	struct xfs_quotainfo	*qi = container_of(shrink,
+					struct xfs_quotainfo, qi_shrinker);
+	struct xfs_qm_isolate	isol;
+	long			freed;
+	int			error;
+
+	if ((sc->gfp_mask & (__GFP_FS|__GFP_WAIT)) != (__GFP_FS|__GFP_WAIT))
+		return 0;
+
+	INIT_LIST_HEAD(&isol.buffers);
+	INIT_LIST_HEAD(&isol.dispose);
+
+	freed = list_lru_walk_nodemask(&qi->qi_lru, xfs_qm_dquot_isolate, &isol,
+					sc->nr_to_scan, &sc->nodes_to_scan);
+
+	error = xfs_buf_delwri_submit(&isol.buffers);
+	if (error)
+		xfs_warn(NULL, "%s: dquot reclaim failed", __func__);
+
+	while (!list_empty(&isol.dispose)) {
+		struct xfs_dquot	*dqp;
+
+		dqp = list_first_entry(&isol.dispose, struct xfs_dquot, q_lru);
+		list_del_init(&dqp->q_lru);
+		xfs_qm_dqfree_one(dqp);
+	}
+
+	return freed;
+}
+
+static long
+xfs_qm_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	struct xfs_quotainfo	*qi = container_of(shrink,
+					struct xfs_quotainfo, qi_shrinker);
+
+	return list_lru_count_nodemask(&qi->qi_lru, &sc->nodes_to_scan);
+}
+
 /*
  * This initializes all the quota information that's kept in the
  * mount structure
@@ -647,9 +778,7 @@ xfs_qm_init_quotainfo(
 	INIT_RADIX_TREE(&qinf->qi_gquota_tree, GFP_NOFS);
 	mutex_init(&qinf->qi_tree_lock);
 
-	INIT_LIST_HEAD(&qinf->qi_lru_list);
-	qinf->qi_lru_count = 0;
-	mutex_init(&qinf->qi_lru_lock);
+	list_lru_init(&qinf->qi_lru);
 
 	/* mutex used to serialize quotaoffs */
 	mutex_init(&qinf->qi_quotaofflock);
@@ -716,7 +845,8 @@ xfs_qm_init_quotainfo(
 		qinf->qi_rtbwarnlimit = XFS_QM_RTBWARNLIMIT;
 	}
 
-	qinf->qi_shrinker.shrink = xfs_qm_shake;
+	qinf->qi_shrinker.count_objects = xfs_qm_shrink_count;
+	qinf->qi_shrinker.scan_objects = xfs_qm_shrink_scan;
 	qinf->qi_shrinker.seeks = DEFAULT_SEEKS;
 	register_shrinker(&qinf->qi_shrinker);
 	return 0;
@@ -1445,132 +1575,6 @@ xfs_qm_dqfree_one(
 	xfs_qm_dqdestroy(dqp);
 }
 
-STATIC void
-xfs_qm_dqreclaim_one(
-	struct xfs_dquot	*dqp,
-	struct list_head	*buffer_list,
-	struct list_head	*dispose_list)
-{
-	struct xfs_mount	*mp = dqp->q_mount;
-	struct xfs_quotainfo	*qi = mp->m_quotainfo;
-	int			error;
-
-	if (!xfs_dqlock_nowait(dqp))
-		goto out_move_tail;
-
-	/*
-	 * This dquot has acquired a reference in the meantime remove it from
-	 * the freelist and try again.
-	 */
-	if (dqp->q_nrefs) {
-		xfs_dqunlock(dqp);
-
-		trace_xfs_dqreclaim_want(dqp);
-		XFS_STATS_INC(xs_qm_dqwants);
-
-		list_del_init(&dqp->q_lru);
-		qi->qi_lru_count--;
-		XFS_STATS_DEC(xs_qm_dquot_unused);
-		return;
-	}
-
-	/*
-	 * Try to grab the flush lock. If this dquot is in the process of
-	 * getting flushed to disk, we don't want to reclaim it.
-	 */
-	if (!xfs_dqflock_nowait(dqp))
-		goto out_unlock_move_tail;
-
-	if (XFS_DQ_IS_DIRTY(dqp)) {
-		struct xfs_buf	*bp = NULL;
-
-		trace_xfs_dqreclaim_dirty(dqp);
-
-		error = xfs_qm_dqflush(dqp, &bp);
-		if (error) {
-			xfs_warn(mp, "%s: dquot %p flush failed",
-				 __func__, dqp);
-			goto out_unlock_move_tail;
-		}
-
-		xfs_buf_delwri_queue(bp, buffer_list);
-		xfs_buf_relse(bp);
-		/*
-		 * Give the dquot another try on the freelist, as the
-		 * flushing will take some time.
-		 */
-		goto out_unlock_move_tail;
-	}
-	xfs_dqfunlock(dqp);
-
-	/*
-	 * Prevent lookups now that we are past the point of no return.
-	 */
-	dqp->dq_flags |= XFS_DQ_FREEING;
-	xfs_dqunlock(dqp);
-
-	ASSERT(dqp->q_nrefs == 0);
-	list_move_tail(&dqp->q_lru, dispose_list);
-	qi->qi_lru_count--;
-	XFS_STATS_DEC(xs_qm_dquot_unused);
-
-	trace_xfs_dqreclaim_done(dqp);
-	XFS_STATS_INC(xs_qm_dqreclaims);
-	return;
-
-	/*
-	 * Move the dquot to the tail of the list so that we don't spin on it.
-	 */
-out_unlock_move_tail:
-	xfs_dqunlock(dqp);
-out_move_tail:
-	list_move_tail(&dqp->q_lru, &qi->qi_lru_list);
-	trace_xfs_dqreclaim_busy(dqp);
-	XFS_STATS_INC(xs_qm_dqreclaim_misses);
-}
-
-STATIC int
-xfs_qm_shake(
-	struct shrinker		*shrink,
-	struct shrink_control	*sc)
-{
-	struct xfs_quotainfo	*qi =
-		container_of(shrink, struct xfs_quotainfo, qi_shrinker);
-	int			nr_to_scan = sc->nr_to_scan;
-	LIST_HEAD		(buffer_list);
-	LIST_HEAD		(dispose_list);
-	struct xfs_dquot	*dqp;
-	int			error;
-
-	if ((sc->gfp_mask & (__GFP_FS|__GFP_WAIT)) != (__GFP_FS|__GFP_WAIT))
-		return 0;
-	if (!nr_to_scan)
-		goto out;
-
-	mutex_lock(&qi->qi_lru_lock);
-	while (!list_empty(&qi->qi_lru_list)) {
-		if (nr_to_scan-- <= 0)
-			break;
-		dqp = list_first_entry(&qi->qi_lru_list, struct xfs_dquot,
-				       q_lru);
-		xfs_qm_dqreclaim_one(dqp, &buffer_list, &dispose_list);
-	}
-	mutex_unlock(&qi->qi_lru_lock);
-
-	error = xfs_buf_delwri_submit(&buffer_list);
-	if (error)
-		xfs_warn(NULL, "%s: dquot reclaim failed", __func__);
-
-	while (!list_empty(&dispose_list)) {
-		dqp = list_first_entry(&dispose_list, struct xfs_dquot, q_lru);
-		list_del_init(&dqp->q_lru);
-		xfs_qm_dqfree_one(dqp);
-	}
-
-out:
-	return vfs_pressure_ratio(qi->qi_lru_count);
-}
-
 /*
  * Start a transaction and write the incore superblock changes to
  * disk. flags parameter indicates which fields have changed.
diff --git a/fs/xfs/xfs_qm.h b/fs/xfs/xfs_qm.h
index 44b858b..d08b72d 100644
--- a/fs/xfs/xfs_qm.h
+++ b/fs/xfs/xfs_qm.h
@@ -47,9 +47,7 @@ typedef struct xfs_quotainfo {
 	struct mutex qi_tree_lock;
 	xfs_inode_t	*qi_uquotaip;	 /* user quota inode */
 	xfs_inode_t	*qi_gquotaip;	 /* group quota inode */
-	struct list_head qi_lru_list;
-	struct mutex	 qi_lru_lock;
-	int		 qi_lru_count;
+	struct list_lru	 qi_lru;
 	int		 qi_dquots;
 	time_t		 qi_btimelimit;	 /* limit for blks timer */
 	time_t		 qi_itimelimit;	 /* limit for inodes timer */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
