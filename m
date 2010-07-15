Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 12DB9620202
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 07:47:47 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 2/3] xfs: convert inode shrinker to per-filesystem contexts
Date: Thu, 15 Jul 2010 21:46:57 +1000
Message-Id: <1279194418-16119-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1279194418-16119-1-git-send-email-david@fromorbit.com>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: xfs@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Now the shrinker passes us a context, wire up a shrinker context per
filesystem. This allows us to remove the global mount list and the
locking problems that introduced. It also means that a shrinker call
does not need to traverse clean filesystems before finding a
filesystem with reclaimable inodes.  This significantly reduces
scanning overhead when lots of filesystems are present.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_super.c |    2 -
 fs/xfs/linux-2.6/xfs_sync.c  |   62 +++++++++--------------------------------
 fs/xfs/linux-2.6/xfs_sync.h  |    2 -
 fs/xfs/xfs_mount.h           |    2 +-
 4 files changed, 15 insertions(+), 53 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
index f2d1718..80938c7 100644
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -1883,7 +1883,6 @@ init_xfs_fs(void)
 		goto out_cleanup_procfs;
 
 	vfs_initquota();
-	xfs_inode_shrinker_init();
 
 	error = register_filesystem(&xfs_fs_type);
 	if (error)
@@ -1911,7 +1910,6 @@ exit_xfs_fs(void)
 {
 	vfs_exitquota();
 	unregister_filesystem(&xfs_fs_type);
-	xfs_inode_shrinker_destroy();
 	xfs_sysctl_unregister();
 	xfs_cleanup_procfs();
 	xfs_buf_terminate();
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index be37582..f433819 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -828,14 +828,7 @@ xfs_reclaim_inodes(
 
 /*
  * Shrinker infrastructure.
- *
- * This is all far more complex than it needs to be. It adds a global list of
- * mounts because the shrinkers can only call a global context. We need to make
- * the shrinkers pass a context to avoid the need for global state.
  */
-static LIST_HEAD(xfs_mount_list);
-static struct rw_semaphore xfs_mount_list_lock;
-
 static int
 xfs_reclaim_inode_shrink(
 	struct shrinker	*shrink,
@@ -847,65 +840,38 @@ xfs_reclaim_inode_shrink(
 	xfs_agnumber_t	ag;
 	int		reclaimable = 0;
 
+	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
 	if (nr_to_scan) {
 		if (!(gfp_mask & __GFP_FS))
 			return -1;
 
-		down_read(&xfs_mount_list_lock);
-		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
-			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
+		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
 					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
-			if (nr_to_scan <= 0)
-				break;
-		}
-		up_read(&xfs_mount_list_lock);
-	}
+		/* if we don't exhaust the scan, don't bother coming back */
+		if (nr_to_scan > 0)
+			return -1;
+       }
 
-	down_read(&xfs_mount_list_lock);
-	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
-		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
-			pag = xfs_perag_get(mp, ag);
-			reclaimable += pag->pag_ici_reclaimable;
-			xfs_perag_put(pag);
-		}
+	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
+		pag = xfs_perag_get(mp, ag);
+		reclaimable += pag->pag_ici_reclaimable;
+		xfs_perag_put(pag);
 	}
-	up_read(&xfs_mount_list_lock);
 	return reclaimable;
 }
 
-static struct shrinker xfs_inode_shrinker = {
-	.shrink = xfs_reclaim_inode_shrink,
-	.seeks = DEFAULT_SEEKS,
-};
-
-void __init
-xfs_inode_shrinker_init(void)
-{
-	init_rwsem(&xfs_mount_list_lock);
-	register_shrinker(&xfs_inode_shrinker);
-}
-
-void
-xfs_inode_shrinker_destroy(void)
-{
-	ASSERT(list_empty(&xfs_mount_list));
-	unregister_shrinker(&xfs_inode_shrinker);
-}
-
 void
 xfs_inode_shrinker_register(
 	struct xfs_mount	*mp)
 {
-	down_write(&xfs_mount_list_lock);
-	list_add_tail(&mp->m_mplist, &xfs_mount_list);
-	up_write(&xfs_mount_list_lock);
+	mp->m_inode_shrink.shrink = xfs_reclaim_inode_shrink;
+	mp->m_inode_shrink.seeks = DEFAULT_SEEKS;
+	register_shrinker(&mp->m_inode_shrink);
 }
 
 void
 xfs_inode_shrinker_unregister(
 	struct xfs_mount	*mp)
 {
-	down_write(&xfs_mount_list_lock);
-	list_del(&mp->m_mplist);
-	up_write(&xfs_mount_list_lock);
+	unregister_shrinker(&mp->m_inode_shrink);
 }
diff --git a/fs/xfs/linux-2.6/xfs_sync.h b/fs/xfs/linux-2.6/xfs_sync.h
index cdcbaac..e28139a 100644
--- a/fs/xfs/linux-2.6/xfs_sync.h
+++ b/fs/xfs/linux-2.6/xfs_sync.h
@@ -55,8 +55,6 @@ int xfs_inode_ag_iterator(struct xfs_mount *mp,
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag, int flags),
 	int flags, int tag, int write_lock, int *nr_to_scan);
 
-void xfs_inode_shrinker_init(void);
-void xfs_inode_shrinker_destroy(void);
 void xfs_inode_shrinker_register(struct xfs_mount *mp);
 void xfs_inode_shrinker_unregister(struct xfs_mount *mp);
 
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 1d2c7ee..5761087 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -259,7 +259,7 @@ typedef struct xfs_mount {
 	wait_queue_head_t	m_wait_single_sync_task;
 	__int64_t		m_update_flags;	/* sb flags we need to update
 						   on the next remount,rw */
-	struct list_head	m_mplist;	/* inode shrinker mount list */
+	struct shrinker		m_inode_shrink;	/* inode reclaim shrinker */
 } xfs_mount_t;
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
