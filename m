Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 850746B00EA
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:51 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 12/12] xfs: make use of new shrinker callout for the inode cache
Date: Thu,  2 Jun 2011 17:01:07 +1000
Message-Id: <1306998067-27659-13-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Convert the inode reclaim shrinker to use the new per-sb shrinker
operations. This allows much bigger reclaim batches to be used, and
allows the XFS inode cache to be shrunk in proportion with the VFS
dentry and inode caches. This avoids the problem of the VFS caches
being shrunk significantly before the XFS inode cache is shrunk
resulting in imbalances in the caches during reclaim.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_super.c |   26 ++++++++++-----
 fs/xfs/linux-2.6/xfs_sync.c  |   71 ++++++++++++++++--------------------------
 fs/xfs/linux-2.6/xfs_sync.h  |    5 +--
 3 files changed, 46 insertions(+), 56 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
index 1e3a7ce..b133b69 100644
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -1087,11 +1087,6 @@ xfs_fs_put_super(
 {
 	struct xfs_mount	*mp = XFS_M(sb);
 
-	/*
-	 * Unregister the memory shrinker before we tear down the mount
-	 * structure so we don't have memory reclaim racing with us here.
-	 */
-	xfs_inode_shrinker_unregister(mp);
 	xfs_syncd_stop(mp);
 
 	/*
@@ -1491,8 +1486,6 @@ xfs_fs_fill_super(
 	if (error)
 		goto out_filestream_unmount;
 
-	xfs_inode_shrinker_register(mp);
-
 	error = xfs_mountfs(mp);
 	if (error)
 		goto out_syncd_stop;
@@ -1515,7 +1508,6 @@ xfs_fs_fill_super(
 	return 0;
 
  out_syncd_stop:
-	xfs_inode_shrinker_unregister(mp);
 	xfs_syncd_stop(mp);
  out_filestream_unmount:
 	xfs_filestream_unmount(mp);
@@ -1540,7 +1532,6 @@ xfs_fs_fill_super(
 	}
 
  fail_unmount:
-	xfs_inode_shrinker_unregister(mp);
 	xfs_syncd_stop(mp);
 
 	/*
@@ -1566,6 +1557,21 @@ xfs_fs_mount(
 	return mount_bdev(fs_type, flags, dev_name, data, xfs_fs_fill_super);
 }
 
+static int
+xfs_fs_nr_cached_objects(
+	struct super_block	*sb)
+{
+	return xfs_reclaim_inodes_count(XFS_M(sb));
+}
+
+static void
+xfs_fs_free_cached_objects(
+	struct super_block	*sb,
+	int			nr_to_scan)
+{
+	xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
+}
+
 static const struct super_operations xfs_super_operations = {
 	.alloc_inode		= xfs_fs_alloc_inode,
 	.destroy_inode		= xfs_fs_destroy_inode,
@@ -1579,6 +1585,8 @@ static const struct super_operations xfs_super_operations = {
 	.statfs			= xfs_fs_statfs,
 	.remount_fs		= xfs_fs_remount,
 	.show_options		= xfs_fs_show_options,
+	.nr_cached_objects	= xfs_fs_nr_cached_objects,
+	.free_cached_objects	= xfs_fs_free_cached_objects,
 };
 
 static struct file_system_type xfs_fs_type = {
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 8ecad5f..9bd7e89 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -179,6 +179,8 @@ restart:
 		if (error == EFSCORRUPTED)
 			break;
 
+		cond_resched();
+
 	} while (nr_found && !done);
 
 	if (skipped) {
@@ -986,6 +988,8 @@ restart:
 
 			*nr_to_scan -= XFS_LOOKUP_BATCH;
 
+			cond_resched();
+
 		} while (nr_found && !done && *nr_to_scan > 0);
 
 		if (trylock && !done)
@@ -1003,7 +1007,7 @@ restart:
 	 * ensure that when we get more reclaimers than AGs we block rather
 	 * than spin trying to execute reclaim.
 	 */
-	if (trylock && skipped && *nr_to_scan > 0) {
+	if (skipped && (flags & SYNC_WAIT) && *nr_to_scan > 0) {
 		trylock = 0;
 		goto restart;
 	}
@@ -1021,44 +1025,38 @@ xfs_reclaim_inodes(
 }
 
 /*
- * Inode cache shrinker.
+ * Scan a certain number of inodes for reclaim.
  *
  * When called we make sure that there is a background (fast) inode reclaim in
- * progress, while we will throttle the speed of reclaim via doiing synchronous
+ * progress, while we will throttle the speed of reclaim via doing synchronous
  * reclaim of inodes. That means if we come across dirty inodes, we wait for
  * them to be cleaned, which we hope will not be very long due to the
  * background walker having already kicked the IO off on those dirty inodes.
  */
-static int
-xfs_reclaim_inode_shrink(
-	struct shrinker	*shrink,
-	struct shrink_control *sc)
+void
+xfs_reclaim_inodes_nr(
+	struct xfs_mount	*mp,
+	int			nr_to_scan)
 {
-	struct xfs_mount *mp;
-	struct xfs_perag *pag;
-	xfs_agnumber_t	ag;
-	int		reclaimable;
-	int nr_to_scan = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
-
-	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
-	if (nr_to_scan) {
-		/* kick background reclaimer and push the AIL */
-		xfs_syncd_queue_reclaim(mp);
-		xfs_ail_push_all(mp->m_ail);
+	/* kick background reclaimer and push the AIL */
+	xfs_syncd_queue_reclaim(mp);
+	xfs_ail_push_all(mp->m_ail);
 
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
+	xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
+}
 
-		xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT,
-					&nr_to_scan);
-		/* terminate if we don't exhaust the scan */
-		if (nr_to_scan > 0)
-			return -1;
-       }
+/*
+ * Return the number of reclaimable inodes in the filesystem for
+ * the shrinker to determine how much to reclaim.
+ */
+int
+xfs_reclaim_inodes_count(
+	struct xfs_mount	*mp)
+{
+	struct xfs_perag	*pag;
+	xfs_agnumber_t		ag = 0;
+	int			reclaimable = 0;
 
-	reclaimable = 0;
-	ag = 0;
 	while ((pag = xfs_perag_get_tag(mp, ag, XFS_ICI_RECLAIM_TAG))) {
 		ag = pag->pag_agno + 1;
 		reclaimable += pag->pag_ici_reclaimable;
@@ -1067,18 +1065,3 @@ xfs_reclaim_inode_shrink(
 	return reclaimable;
 }
 
-void
-xfs_inode_shrinker_register(
-	struct xfs_mount	*mp)
-{
-	mp->m_inode_shrink.shrink = xfs_reclaim_inode_shrink;
-	mp->m_inode_shrink.seeks = DEFAULT_SEEKS;
-	register_shrinker(&mp->m_inode_shrink);
-}
-
-void
-xfs_inode_shrinker_unregister(
-	struct xfs_mount	*mp)
-{
-	unregister_shrinker(&mp->m_inode_shrink);
-}
diff --git a/fs/xfs/linux-2.6/xfs_sync.h b/fs/xfs/linux-2.6/xfs_sync.h
index e3a6ad2..2e15685 100644
--- a/fs/xfs/linux-2.6/xfs_sync.h
+++ b/fs/xfs/linux-2.6/xfs_sync.h
@@ -43,6 +43,8 @@ void xfs_quiesce_attr(struct xfs_mount *mp);
 void xfs_flush_inodes(struct xfs_inode *ip);
 
 int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
+int xfs_reclaim_inodes_count(struct xfs_mount *mp);
+void xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
 
 void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
 void __xfs_inode_set_reclaim_tag(struct xfs_perag *pag, struct xfs_inode *ip);
@@ -54,7 +56,4 @@ int xfs_inode_ag_iterator(struct xfs_mount *mp,
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag, int flags),
 	int flags);
 
-void xfs_inode_shrinker_register(struct xfs_mount *mp);
-void xfs_inode_shrinker_unregister(struct xfs_mount *mp);
-
 #endif
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
