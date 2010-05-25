Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 27AF76008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 04:53:36 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 5/5] xfs: make use of new shrinker callout
Date: Tue, 25 May 2010 18:53:08 +1000
Message-Id: <1274777588-21494-6-git-send-email-david@fromorbit.com>
In-Reply-To: <1274777588-21494-1-git-send-email-david@fromorbit.com>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Convert the inode reclaim shrinker to use the new per-sb shrinker
operations.  This fixes a bunch of lockdep warnings about the
xfs_mount_list_lock being taken in different reclaim contexts by
removing it, and allows the reclaim to be proportioned across
filesystems with no extra code.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_super.c   |   23 ++++++--
 fs/xfs/linux-2.6/xfs_sync.c    |  124 +++++++++++-----------------------------
 fs/xfs/linux-2.6/xfs_sync.h    |   16 +++--
 fs/xfs/quota/xfs_qm_syscalls.c |    2 +-
 fs/xfs/xfs_mount.h             |    1 -
 5 files changed, 61 insertions(+), 105 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
index f24dbe5..b59886a 100644
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -1212,7 +1212,6 @@ xfs_fs_put_super(
 
 	xfs_unmountfs(mp);
 	xfs_freesb(mp);
-	xfs_inode_shrinker_unregister(mp);
 	xfs_icsb_destroy_counters(mp);
 	xfs_close_devices(mp);
 	xfs_dmops_put(mp);
@@ -1626,8 +1625,6 @@ xfs_fs_fill_super(
 	if (error)
 		goto fail_vnrele;
 
-	xfs_inode_shrinker_register(mp);
-
 	kfree(mtpt);
 	return 0;
 
@@ -1681,6 +1678,22 @@ xfs_fs_get_sb(
 			   mnt);
 }
 
+static int
+xfs_fs_nr_cached_objects(
+	struct super_block	*sb)
+{
+	return xfs_reclaim_inodes_count(XFS_M(sb));
+}
+
+static int
+xfs_fs_free_cached_objects(
+	struct super_block	*sb,
+	int			nr_to_scan)
+{
+	xfs_reclaim_inodes_nr(XFS_M(sb), 0, nr_to_scan);
+	return 0;
+}
+
 static const struct super_operations xfs_super_operations = {
 	.alloc_inode		= xfs_fs_alloc_inode,
 	.destroy_inode		= xfs_fs_destroy_inode,
@@ -1694,6 +1707,8 @@ static const struct super_operations xfs_super_operations = {
 	.statfs			= xfs_fs_statfs,
 	.remount_fs		= xfs_fs_remount,
 	.show_options		= xfs_fs_show_options,
+	.nr_cached_objects	= xfs_fs_nr_cached_objects,
+	.free_cached_objects	= xfs_fs_free_cached_objects,
 };
 
 static struct file_system_type xfs_fs_type = {
@@ -1873,7 +1888,6 @@ init_xfs_fs(void)
 		goto out_cleanup_procfs;
 
 	vfs_initquota();
-	xfs_inode_shrinker_init();
 
 	error = register_filesystem(&xfs_fs_type);
 	if (error)
@@ -1901,7 +1915,6 @@ exit_xfs_fs(void)
 {
 	vfs_exitquota();
 	unregister_filesystem(&xfs_fs_type);
-	xfs_inode_shrinker_destroy();
 	xfs_sysctl_unregister();
 	xfs_cleanup_procfs();
 	xfs_buf_terminate();
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index c881a0c..6d74a0d 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -137,7 +137,7 @@ restart:
 
 	} while ((*nr_to_scan)--);
 
-	if (skipped) {
+	if (skipped && *nr_to_scan > 0) {
 		delay(1);
 		goto restart;
 	}
@@ -152,14 +152,14 @@ xfs_inode_ag_iterator(
 	int			flags,
 	int			tag,
 	int			exclusive,
-	int			*nr_to_scan)
+	int			nr_to_scan)
 {
 	int			error = 0;
 	int			last_error = 0;
 	xfs_agnumber_t		ag;
-	int			nr;
 
-	nr = nr_to_scan ? *nr_to_scan : INT_MAX;
+	if (nr_to_scan <= 0)
+		nr_to_scan = INT_MAX;
 	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
 		struct xfs_perag	*pag;
 
@@ -169,18 +169,16 @@ xfs_inode_ag_iterator(
 			continue;
 		}
 		error = xfs_inode_ag_walk(mp, pag, execute, flags, tag,
-						exclusive, &nr);
+						exclusive, &nr_to_scan);
 		xfs_perag_put(pag);
 		if (error) {
 			last_error = error;
 			if (error == EFSCORRUPTED)
 				break;
 		}
-		if (nr <= 0)
+		if (nr_to_scan <= 0)
 			break;
 	}
-	if (nr_to_scan)
-		*nr_to_scan = nr;
 	return XFS_ERROR(last_error);
 }
 
@@ -299,7 +297,7 @@ xfs_sync_data(
 	ASSERT((flags & ~(SYNC_TRYLOCK|SYNC_WAIT)) == 0);
 
 	error = xfs_inode_ag_iterator(mp, xfs_sync_inode_data, flags,
-				      XFS_ICI_NO_TAG, 0, NULL);
+				      XFS_ICI_NO_TAG, 0, 0);
 	if (error)
 		return XFS_ERROR(error);
 
@@ -318,7 +316,7 @@ xfs_sync_attr(
 	ASSERT((flags & ~SYNC_WAIT) == 0);
 
 	return xfs_inode_ag_iterator(mp, xfs_sync_inode_attr, flags,
-				     XFS_ICI_NO_TAG, 0, NULL);
+				     XFS_ICI_NO_TAG, 0, 0);
 }
 
 STATIC int
@@ -821,100 +819,44 @@ reclaim:
 
 }
 
+/*
+ * Scan a certain number of inodes for reclaim. nr_to_scan <= 0 means reclaim
+ * every inode that has the reclaim tag set.
+ */
 int
-xfs_reclaim_inodes(
+xfs_reclaim_inodes_nr(
 	xfs_mount_t	*mp,
-	int		mode)
+	int		mode,
+	int		nr_to_scan)
 {
 	return xfs_inode_ag_iterator(mp, xfs_reclaim_inode, mode,
-					XFS_ICI_RECLAIM_TAG, 1, NULL);
+					XFS_ICI_RECLAIM_TAG, 1, nr_to_scan);
 }
 
 /*
- * Shrinker infrastructure.
+ * Return the number of reclaimable inodes in the filesystem for
+ * the shrinker to determine how much to reclaim.
  *
- * This is all far more complex than it needs to be. It adds a global list of
- * mounts because the shrinkers can only call a global context. We need to make
- * the shrinkers pass a context to avoid the need for global state.
+ * Because the inode cache may not have any reclaimable inodes in it, but will
+ * be populated as part of the higher level cleaning, we need to count all
+ * those inodes as reclaimable here as well.
  */
-static LIST_HEAD(xfs_mount_list);
-static struct rw_semaphore xfs_mount_list_lock;
-
-static int
-xfs_reclaim_inode_shrink(
-	struct shrinker	*shrink,
-	int		nr_to_scan,
-	gfp_t		gfp_mask)
+int
+xfs_reclaim_inodes_count(
+	xfs_mount_t	*mp)
 {
-	struct xfs_mount *mp;
-	struct xfs_perag *pag;
-	xfs_agnumber_t	ag;
-	int		reclaimable = 0;
-
-	if (nr_to_scan) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-
-		down_read(&xfs_mount_list_lock);
-		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
-			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
-					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
-			if (nr_to_scan <= 0)
-				break;
-		}
-		up_read(&xfs_mount_list_lock);
-	}
-
-	down_read(&xfs_mount_list_lock);
-	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
-		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
+	xfs_agnumber_t		ag;
+	int			reclaimable = 0;
 
-			pag = xfs_perag_get(mp, ag);
-			if (!pag->pag_ici_init) {
-				xfs_perag_put(pag);
-				continue;
-			}
-			reclaimable += pag->pag_ici_reclaimable;
+	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
+		struct xfs_perag *pag = xfs_perag_get(mp, ag);
+		if (!pag->pag_ici_init) {
 			xfs_perag_put(pag);
+			continue;
 		}
+		reclaimable += pag->pag_ici_reclaimable;
+		xfs_perag_put(pag);
 	}
-	up_read(&xfs_mount_list_lock);
-	return reclaimable;
-}
-
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
-void
-xfs_inode_shrinker_register(
-	struct xfs_mount	*mp)
-{
-	down_write(&xfs_mount_list_lock);
-	list_add_tail(&mp->m_mplist, &xfs_mount_list);
-	up_write(&xfs_mount_list_lock);
+	return reclaimable + mp->m_super->s_nr_inodes_unused;
 }
 
-void
-xfs_inode_shrinker_unregister(
-	struct xfs_mount	*mp)
-{
-	down_write(&xfs_mount_list_lock);
-	list_del(&mp->m_mplist);
-	up_write(&xfs_mount_list_lock);
-}
diff --git a/fs/xfs/linux-2.6/xfs_sync.h b/fs/xfs/linux-2.6/xfs_sync.h
index cdcbaac..c55f645 100644
--- a/fs/xfs/linux-2.6/xfs_sync.h
+++ b/fs/xfs/linux-2.6/xfs_sync.h
@@ -43,7 +43,14 @@ void xfs_quiesce_attr(struct xfs_mount *mp);
 
 void xfs_flush_inodes(struct xfs_inode *ip);
 
-int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
+int xfs_reclaim_inodes_count(struct xfs_mount *mp);
+int xfs_reclaim_inodes_nr(struct xfs_mount *mp, int mode, int nr_to_scan);
+
+static inline int
+xfs_reclaim_inodes(struct xfs_mount *mp, int mode)
+{
+	return xfs_reclaim_inodes_nr(mp, mode, 0);
+}
 
 void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
 void __xfs_inode_set_reclaim_tag(struct xfs_perag *pag, struct xfs_inode *ip);
@@ -53,11 +60,6 @@ void __xfs_inode_clear_reclaim_tag(struct xfs_mount *mp, struct xfs_perag *pag,
 int xfs_sync_inode_valid(struct xfs_inode *ip, struct xfs_perag *pag);
 int xfs_inode_ag_iterator(struct xfs_mount *mp,
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag, int flags),
-	int flags, int tag, int write_lock, int *nr_to_scan);
-
-void xfs_inode_shrinker_init(void);
-void xfs_inode_shrinker_destroy(void);
-void xfs_inode_shrinker_register(struct xfs_mount *mp);
-void xfs_inode_shrinker_unregister(struct xfs_mount *mp);
+	int flags, int tag, int write_lock, int nr_to_scan);
 
 #endif
diff --git a/fs/xfs/quota/xfs_qm_syscalls.c b/fs/xfs/quota/xfs_qm_syscalls.c
index 92b002f..f5b0e4e 100644
--- a/fs/xfs/quota/xfs_qm_syscalls.c
+++ b/fs/xfs/quota/xfs_qm_syscalls.c
@@ -894,7 +894,7 @@ xfs_qm_dqrele_all_inodes(
 {
 	ASSERT(mp->m_quotainfo);
 	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags,
-				XFS_ICI_NO_TAG, 0, NULL);
+				XFS_ICI_NO_TAG, 0, 0);
 }
 
 /*------------------------------------------------------------------------*/
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 9ff48a1..4fa0bc7 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -259,7 +259,6 @@ typedef struct xfs_mount {
 	wait_queue_head_t	m_wait_single_sync_task;
 	__int64_t		m_update_flags;	/* sb flags we need to update
 						   on the next remount,rw */
-	struct list_head	m_mplist;	/* inode shrinker mount list */
 } xfs_mount_t;
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
