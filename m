Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 267746B0093
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:15:25 -0500 (EST)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 14/19] xfs: use generic AG walk for background inode reclaim
Date: Wed, 28 Nov 2012 10:14:41 +1100
Message-Id: <1354058086-27937-15-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

The per-ag inode cache radix trees are not walked by the shrinkers
any more, so there is no need for a special walker that contained
heurisitcs to prevent multiple shrinker instances from colliding
with each other. Hence we can just remote that and convert the code
to use the generic walker.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_ag.h          |    2 -
 fs/xfs/xfs_icache.c      |  217 +++++++++++-----------------------------------
 fs/xfs/xfs_icache.h      |    4 +-
 fs/xfs/xfs_mount.c       |    1 -
 fs/xfs/xfs_qm_syscalls.c |    2 +-
 5 files changed, 55 insertions(+), 171 deletions(-)

diff --git a/fs/xfs/xfs_ag.h b/fs/xfs/xfs_ag.h
index f2aeedb..40a7df9 100644
--- a/fs/xfs/xfs_ag.h
+++ b/fs/xfs/xfs_ag.h
@@ -218,8 +218,6 @@ typedef struct xfs_perag {
 	spinlock_t	pag_ici_lock;	/* incore inode cache lock */
 	struct radix_tree_root pag_ici_root;	/* incore inode cache root */
 	int		pag_ici_reclaimable;	/* reclaimable inodes */
-	struct mutex	pag_ici_reclaim_lock;	/* serialisation point */
-	unsigned long	pag_ici_reclaim_cursor;	/* reclaim restart point */
 
 	/* buffer cache index */
 	spinlock_t	pag_buf_lock;	/* lock for pag_buf_tree */
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 82b053f..5cfc2eb 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -468,7 +468,8 @@ out_error_or_again:
 
 STATIC int
 xfs_inode_ag_walk_grab(
-	struct xfs_inode	*ip)
+	struct xfs_inode	*ip,
+	int			flags)
 {
 	struct inode		*inode = VFS_I(ip);
 
@@ -517,6 +518,7 @@ STATIC int
 xfs_inode_ag_walk(
 	struct xfs_mount	*mp,
 	struct xfs_perag	*pag,
+	int			(*grab)(struct xfs_inode *ip, int flags),
 	int			(*execute)(struct xfs_inode *ip,
 					   struct xfs_perag *pag, int flags,
 					   void *args),
@@ -530,6 +532,9 @@ xfs_inode_ag_walk(
 	int			done;
 	int			nr_found;
 
+	if (!grab)
+		grab = xfs_inode_ag_walk_grab;
+
 restart:
 	done = 0;
 	skipped = 0;
@@ -564,7 +569,7 @@ restart:
 		for (i = 0; i < nr_found; i++) {
 			struct xfs_inode *ip = batch[i];
 
-			if (done || xfs_inode_ag_walk_grab(ip))
+			if (done || grab(ip, flags))
 				batch[i] = NULL;
 
 			/*
@@ -593,7 +598,8 @@ restart:
 			if (!batch[i])
 				continue;
 			error = execute(batch[i], pag, flags, args);
-			IRELE(batch[i]);
+			if (grab == xfs_inode_ag_walk_grab)
+				IRELE(batch[i]);
 			if (error == EAGAIN) {
 				skipped++;
 				continue;
@@ -617,35 +623,10 @@ restart:
 	return last_error;
 }
 
-/*
- * Background scanning to trim post-EOF preallocated space. This is queued
- * based on the 'background_prealloc_discard_period' tunable (5m by default).
- */
-STATIC void
-xfs_queue_eofblocks(
-	struct xfs_mount *mp)
-{
-	rcu_read_lock();
-	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_EOFBLOCKS_TAG))
-		queue_delayed_work(mp->m_eofblocks_workqueue,
-				   &mp->m_eofblocks_work,
-				   msecs_to_jiffies(xfs_eofb_secs * 1000));
-	rcu_read_unlock();
-}
-
-void
-xfs_eofblocks_worker(
-	struct work_struct *work)
-{
-	struct xfs_mount *mp = container_of(to_delayed_work(work),
-				struct xfs_mount, m_eofblocks_work);
-	xfs_icache_free_eofblocks(mp, NULL);
-	xfs_queue_eofblocks(mp);
-}
-
 int
 xfs_inode_ag_iterator(
 	struct xfs_mount	*mp,
+	int			(*grab)(struct xfs_inode *ip, int flags),
 	int			(*execute)(struct xfs_inode *ip,
 					   struct xfs_perag *pag, int flags,
 					   void *args),
@@ -660,7 +641,8 @@ xfs_inode_ag_iterator(
 	ag = 0;
 	while ((pag = xfs_perag_get(mp, ag))) {
 		ag = pag->pag_agno + 1;
-		error = xfs_inode_ag_walk(mp, pag, execute, flags, args, -1);
+		error = xfs_inode_ag_walk(mp, pag, grab, execute,
+					  flags, args, -1);
 		xfs_perag_put(pag);
 		if (error) {
 			last_error = error;
@@ -674,6 +656,7 @@ xfs_inode_ag_iterator(
 int
 xfs_inode_ag_iterator_tag(
 	struct xfs_mount	*mp,
+	int			(*grab)(struct xfs_inode *ip, int flags),
 	int			(*execute)(struct xfs_inode *ip,
 					   struct xfs_perag *pag, int flags,
 					   void *args),
@@ -689,7 +672,8 @@ xfs_inode_ag_iterator_tag(
 	ag = 0;
 	while ((pag = xfs_perag_get_tag(mp, ag, tag))) {
 		ag = pag->pag_agno + 1;
-		error = xfs_inode_ag_walk(mp, pag, execute, flags, args, tag);
+		error = xfs_inode_ag_walk(mp, pag, grab, execute,
+					  flags, args, tag);
 		xfs_perag_put(pag);
 		if (error) {
 			last_error = error;
@@ -904,7 +888,8 @@ STATIC int
 xfs_reclaim_inode(
 	struct xfs_inode	*ip,
 	struct xfs_perag	*pag,
-	int			sync_mode)
+	int			sync_mode,
+	void			*args)
 {
 	struct xfs_buf		*bp = NULL;
 	int			error;
@@ -1032,140 +1017,14 @@ out:
 	return 0;
 }
 
-/*
- * Walk the AGs and reclaim the inodes in them. Even if the filesystem is
- * corrupted, we still want to try to reclaim all the inodes. If we don't,
- * then a shut down during filesystem unmount reclaim walk leak all the
- * unreclaimed inodes.
- */
-STATIC int
-xfs_reclaim_inodes_ag(
-	struct xfs_mount	*mp,
-	int			flags,
-	long			*nr_to_scan)
-{
-	struct xfs_perag	*pag;
-	int			error = 0;
-	int			last_error = 0;
-	xfs_agnumber_t		ag;
-	int			trylock = flags & SYNC_TRYLOCK;
-	int			skipped;
-
-restart:
-	ag = 0;
-	skipped = 0;
-	while ((pag = xfs_perag_get_tag(mp, ag, XFS_ICI_RECLAIM_TAG))) {
-		unsigned long	first_index = 0;
-		int		done = 0;
-		int		nr_found = 0;
-
-		ag = pag->pag_agno + 1;
-
-		if (trylock) {
-			if (!mutex_trylock(&pag->pag_ici_reclaim_lock)) {
-				skipped++;
-				xfs_perag_put(pag);
-				continue;
-			}
-			first_index = pag->pag_ici_reclaim_cursor;
-		} else
-			mutex_lock(&pag->pag_ici_reclaim_lock);
-
-		do {
-			struct xfs_inode *batch[XFS_LOOKUP_BATCH];
-			int	i;
-
-			rcu_read_lock();
-			nr_found = radix_tree_gang_lookup_tag(
-					&pag->pag_ici_root,
-					(void **)batch, first_index,
-					XFS_LOOKUP_BATCH,
-					XFS_ICI_RECLAIM_TAG);
-			if (!nr_found) {
-				done = 1;
-				rcu_read_unlock();
-				break;
-			}
-
-			/*
-			 * Grab the inodes before we drop the lock. if we found
-			 * nothing, nr == 0 and the loop will be skipped.
-			 */
-			for (i = 0; i < nr_found; i++) {
-				struct xfs_inode *ip = batch[i];
-
-				if (done || xfs_reclaim_inode_grab(ip, flags))
-					batch[i] = NULL;
-
-				/*
-				 * Update the index for the next lookup. Catch
-				 * overflows into the next AG range which can
-				 * occur if we have inodes in the last block of
-				 * the AG and we are currently pointing to the
-				 * last inode.
-				 *
-				 * Because we may see inodes that are from the
-				 * wrong AG due to RCU freeing and
-				 * reallocation, only update the index if it
-				 * lies in this AG. It was a race that lead us
-				 * to see this inode, so another lookup from
-				 * the same index will not find it again.
-				 */
-				if (XFS_INO_TO_AGNO(mp, ip->i_ino) !=
-								pag->pag_agno)
-					continue;
-				first_index = XFS_INO_TO_AGINO(mp, ip->i_ino + 1);
-				if (first_index < XFS_INO_TO_AGINO(mp, ip->i_ino))
-					done = 1;
-			}
-
-			/* unlock now we've grabbed the inodes. */
-			rcu_read_unlock();
-
-			for (i = 0; i < nr_found; i++) {
-				if (!batch[i])
-					continue;
-				error = xfs_reclaim_inode(batch[i], pag, flags);
-				if (error && last_error != EFSCORRUPTED)
-					last_error = error;
-			}
-
-			*nr_to_scan -= XFS_LOOKUP_BATCH;
-
-			cond_resched();
-
-		} while (nr_found && !done && *nr_to_scan > 0);
-
-		if (trylock && !done)
-			pag->pag_ici_reclaim_cursor = first_index;
-		else
-			pag->pag_ici_reclaim_cursor = 0;
-		mutex_unlock(&pag->pag_ici_reclaim_lock);
-		xfs_perag_put(pag);
-	}
-
-	/*
-	 * if we skipped any AG, and we still have scan count remaining, do
-	 * another pass this time using blocking reclaim semantics (i.e
-	 * waiting on the reclaim locks and ignoring the reclaim cursors). This
-	 * ensure that when we get more reclaimers than AGs we block rather
-	 * than spin trying to execute reclaim.
-	 */
-	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
-		trylock = 0;
-		goto restart;
-	}
-	return XFS_ERROR(last_error);
-}
-
 int
 xfs_reclaim_inodes(
-	xfs_mount_t	*mp,
-	int		mode)
+	struct xfs_mount	*mp,
+	int			flags)
 {
-	long		nr_to_scan = LONG_MAX;
-
-	return xfs_reclaim_inodes_ag(mp, mode, &nr_to_scan);
+	return xfs_inode_ag_iterator_tag(mp, xfs_reclaim_inode_grab,
+					 xfs_reclaim_inode, flags,
+					 NULL, XFS_ICI_RECLAIM_TAG);
 }
 
 static int
@@ -1229,13 +1088,39 @@ xfs_reclaim_inodes_nr(
 
 		pag = xfs_perag_get(mp,
 				    XFS_INO_TO_AGNO(mp, XFS_I(inode)->i_ino));
-		xfs_reclaim_inode(XFS_I(inode), pag, SYNC_WAIT);
+		xfs_reclaim_inode(XFS_I(inode), pag, SYNC_WAIT, NULL);
 		xfs_perag_put(pag);
 	}
 
 	return freed;
 }
 
+/*
+ * Background scanning to trim post-EOF preallocated space. This is queued
+ * based on the 'background_prealloc_discard_period' tunable (5m by default).
+ */
+STATIC void
+xfs_queue_eofblocks(
+	struct xfs_mount *mp)
+{
+	rcu_read_lock();
+	if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_EOFBLOCKS_TAG))
+		queue_delayed_work(mp->m_eofblocks_workqueue,
+				   &mp->m_eofblocks_work,
+				   msecs_to_jiffies(xfs_eofb_secs * 1000));
+	rcu_read_unlock();
+}
+
+void
+xfs_eofblocks_worker(
+	struct work_struct *work)
+{
+	struct xfs_mount *mp = container_of(to_delayed_work(work),
+				struct xfs_mount, m_eofblocks_work);
+	xfs_icache_free_eofblocks(mp, NULL);
+	xfs_queue_eofblocks(mp);
+}
+
 STATIC int
 xfs_inode_match_id(
 	struct xfs_inode	*ip,
@@ -1310,8 +1195,8 @@ xfs_icache_free_eofblocks(
 	if (eofb && (eofb->eof_flags & XFS_EOF_FLAGS_SYNC))
 		flags = SYNC_WAIT;
 
-	return xfs_inode_ag_iterator_tag(mp, xfs_inode_free_eofblocks, flags,
-					 eofb, XFS_ICI_EOFBLOCKS_TAG);
+	return xfs_inode_ag_iterator_tag(mp, NULL, xfs_inode_free_eofblocks,
+					 flags, eofb, XFS_ICI_EOFBLOCKS_TAG);
 }
 
 void
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index 4214518..a3380bf 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -29,7 +29,7 @@ int xfs_iget(struct xfs_mount *mp, struct xfs_trans *tp, xfs_ino_t ino,
 
 void xfs_reclaim_worker(struct work_struct *work);
 
-int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
+int xfs_reclaim_inodes(struct xfs_mount *mp, int flags);
 long xfs_reclaim_inodes_nr(struct xfs_mount *mp, long nr_to_scan,
 			   nodemask_t *nodes_to_scan);
 
@@ -42,10 +42,12 @@ void xfs_eofblocks_worker(struct work_struct *);
 
 int xfs_sync_inode_grab(struct xfs_inode *ip);
 int xfs_inode_ag_iterator(struct xfs_mount *mp,
+	int (*grab)(struct xfs_inode *ip, int flags),
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag,
 		int flags, void *args),
 	int flags, void *args);
 int xfs_inode_ag_iterator_tag(struct xfs_mount *mp,
+	int (*grab)(struct xfs_inode *ip, int flags),
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag,
 		int flags, void *args),
 	int flags, void *args, int tag);
diff --git a/fs/xfs/xfs_mount.c b/fs/xfs/xfs_mount.c
index da50846..6985a32 100644
--- a/fs/xfs/xfs_mount.c
+++ b/fs/xfs/xfs_mount.c
@@ -456,7 +456,6 @@ xfs_initialize_perag(
 		pag->pag_agno = index;
 		pag->pag_mount = mp;
 		spin_lock_init(&pag->pag_ici_lock);
-		mutex_init(&pag->pag_ici_reclaim_lock);
 		INIT_RADIX_TREE(&pag->pag_ici_root, GFP_ATOMIC);
 		spin_lock_init(&pag->pag_buf_lock);
 		pag->pag_buf_tree = RB_ROOT;
diff --git a/fs/xfs/xfs_qm_syscalls.c b/fs/xfs/xfs_qm_syscalls.c
index 5f53e75..85294a6 100644
--- a/fs/xfs/xfs_qm_syscalls.c
+++ b/fs/xfs/xfs_qm_syscalls.c
@@ -883,5 +883,5 @@ xfs_qm_dqrele_all_inodes(
 	uint		 flags)
 {
 	ASSERT(mp->m_quotainfo);
-	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags, NULL);
+	xfs_inode_ag_iterator(mp, NULL, xfs_dqrele_inode, flags, NULL);
 }
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
