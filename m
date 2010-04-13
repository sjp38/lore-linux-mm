Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 27A256B01F7
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:20:47 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 2/2] xfs: add a shrinker to background inode reclaim
Date: Tue, 13 Apr 2010 10:24:15 +1000
Message-Id: <1271118255-21070-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1271118255-21070-1-git-send-email-david@fromorbit.com>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

On low memory boxes or those with highmem, kernel can OOM when the application
scans large numbers of inodes. In this case, the XFS background inode reclaim
scan run by xfssyncd does not run soon enough to free clean, reclaimable
inodes. Add a per-filesystem shrinker to XFS to run inode reclaim so that it is
expedited when memory is low and hence prevent OOM conditions from being hit.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/linux-2.6/xfs_super.c   |    3 ++
 fs/xfs/linux-2.6/xfs_sync.c    |   71 ++++++++++++++++++++++++++++++++++++----
 fs/xfs/linux-2.6/xfs_sync.h    |    5 ++-
 fs/xfs/quota/xfs_qm_syscalls.c |    3 +-
 fs/xfs/xfs_ag.h                |    1 +
 fs/xfs/xfs_mount.h             |    1 +
 6 files changed, 75 insertions(+), 9 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
index 52e06b4..855ba45 100644
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -1209,6 +1209,7 @@ xfs_fs_put_super(
 
 	xfs_unmountfs(mp);
 	xfs_freesb(mp);
+	xfs_inode_shrinker_unregister(mp);
 	xfs_icsb_destroy_counters(mp);
 	xfs_close_devices(mp);
 	xfs_dmops_put(mp);
@@ -1622,6 +1623,8 @@ xfs_fs_fill_super(
 	if (error)
 		goto fail_vnrele;
 
+	xfs_inode_shrinker_register(mp);
+
 	kfree(mtpt);
 	return 0;
 
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 05cd853..774c5c0 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -95,7 +95,8 @@ xfs_inode_ag_walk(
 					   struct xfs_perag *pag, int flags),
 	int			flags,
 	int			tag,
-	int			exclusive)
+	int			exclusive,
+	int			*nr_to_scan)
 {
 	uint32_t		first_index;
 	int			last_error = 0;
@@ -134,7 +135,7 @@ restart:
 		if (error == EFSCORRUPTED)
 			break;
 
-	} while (1);
+	} while ((*nr_to_scan)--);
 
 	if (skipped) {
 		delay(1);
@@ -150,11 +151,16 @@ xfs_inode_ag_iterator(
 					   struct xfs_perag *pag, int flags),
 	int			flags,
 	int			tag,
-	int			exclusive)
+	int			exclusive,
+	int			nr_to_scan)
 {
 	int			error = 0;
 	int			last_error = 0;
 	xfs_agnumber_t		ag;
+	int			nr = nr_to_scan;
+
+	if (!nr)
+		nr = INT_MAX;
 
 	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
 		struct xfs_perag	*pag;
@@ -165,7 +171,7 @@ xfs_inode_ag_iterator(
 			continue;
 		}
 		error = xfs_inode_ag_walk(mp, pag, execute, flags, tag,
-						exclusive);
+						exclusive, &nr);
 		xfs_perag_put(pag);
 		if (error) {
 			last_error = error;
@@ -291,7 +297,7 @@ xfs_sync_data(
 	ASSERT((flags & ~(SYNC_TRYLOCK|SYNC_WAIT)) == 0);
 
 	error = xfs_inode_ag_iterator(mp, xfs_sync_inode_data, flags,
-				      XFS_ICI_NO_TAG, 0);
+				      XFS_ICI_NO_TAG, 0, 0);
 	if (error)
 		return XFS_ERROR(error);
 
@@ -310,7 +316,7 @@ xfs_sync_attr(
 	ASSERT((flags & ~SYNC_WAIT) == 0);
 
 	return xfs_inode_ag_iterator(mp, xfs_sync_inode_attr, flags,
-				     XFS_ICI_NO_TAG, 0);
+				     XFS_ICI_NO_TAG, 0, 0);
 }
 
 STATIC int
@@ -673,6 +679,7 @@ __xfs_inode_set_reclaim_tag(
 	radix_tree_tag_set(&pag->pag_ici_root,
 			   XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino),
 			   XFS_ICI_RECLAIM_TAG);
+	pag->pag_ici_reclaimable++;
 }
 
 /*
@@ -705,6 +712,7 @@ __xfs_inode_clear_reclaim_tag(
 {
 	radix_tree_tag_clear(&pag->pag_ici_root,
 			XFS_INO_TO_AGINO(mp, ip->i_ino), XFS_ICI_RECLAIM_TAG);
+	pag->pag_ici_reclaimable--;
 }
 
 /*
@@ -854,5 +862,54 @@ xfs_reclaim_inodes(
 	int		mode)
 {
 	return xfs_inode_ag_iterator(mp, xfs_reclaim_inode, mode,
-					XFS_ICI_RECLAIM_TAG, 1);
+					XFS_ICI_RECLAIM_TAG, 1, 0);
+}
+
+static int
+xfs_reclaim_inode_shrink(
+	void	*ctx,
+	int	nr_to_scan,
+	gfp_t	gfp_mask)
+{
+	struct xfs_mount *mp = ctx;
+	xfs_agnumber_t	ag;
+	int		reclaimable = 0;
+
+	if (nr_to_scan) {
+		if (!(gfp_mask & __GFP_FS))
+			return -1;
+
+		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
+					XFS_ICI_RECLAIM_TAG, 1, nr_to_scan);
+	}
+
+	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
+		struct xfs_perag	*pag;
+
+		pag = xfs_perag_get(mp, ag);
+		if (!pag->pag_ici_init) {
+			xfs_perag_put(pag);
+			continue;
+		}
+		reclaimable += pag->pag_ici_reclaimable;
+		xfs_perag_put(pag);
+	}
+	return reclaimable;
+}
+
+void
+xfs_inode_shrinker_register(
+	struct xfs_mount	*mp)
+{
+	mp->m_inode_shrink.shrink = xfs_reclaim_inode_shrink;
+	mp->m_inode_shrink.ctx = mp;
+	mp->m_inode_shrink.seeks = DEFAULT_SEEKS;
+	register_shrinker(&mp->m_inode_shrink);
+}
+
+void
+xfs_inode_shrinker_unregister(
+	struct xfs_mount	*mp)
+{
+	unregister_shrinker(&mp->m_inode_shrink);
 }
diff --git a/fs/xfs/linux-2.6/xfs_sync.h b/fs/xfs/linux-2.6/xfs_sync.h
index d480c34..e6c631b 100644
--- a/fs/xfs/linux-2.6/xfs_sync.h
+++ b/fs/xfs/linux-2.6/xfs_sync.h
@@ -53,6 +53,9 @@ void __xfs_inode_clear_reclaim_tag(struct xfs_mount *mp, struct xfs_perag *pag,
 int xfs_sync_inode_valid(struct xfs_inode *ip, struct xfs_perag *pag);
 int xfs_inode_ag_iterator(struct xfs_mount *mp,
 	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag, int flags),
-	int flags, int tag, int write_lock);
+	int flags, int tag, int write_lock, int nr_to_scan);
+
+void xfs_inode_shrinker_register(struct xfs_mount *mp);
+void xfs_inode_shrinker_unregister(struct xfs_mount *mp);
 
 #endif
diff --git a/fs/xfs/quota/xfs_qm_syscalls.c b/fs/xfs/quota/xfs_qm_syscalls.c
index 5d0ee8d..94c0cac 100644
--- a/fs/xfs/quota/xfs_qm_syscalls.c
+++ b/fs/xfs/quota/xfs_qm_syscalls.c
@@ -891,7 +891,8 @@ xfs_qm_dqrele_all_inodes(
 	uint		 flags)
 {
 	ASSERT(mp->m_quotainfo);
-	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags, XFS_ICI_NO_TAG, 0);
+	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags,
+				XFS_ICI_NO_TAG, 0, 0);
 }
 
 /*------------------------------------------------------------------------*/
diff --git a/fs/xfs/xfs_ag.h b/fs/xfs/xfs_ag.h
index b1a5a1f..abb8222 100644
--- a/fs/xfs/xfs_ag.h
+++ b/fs/xfs/xfs_ag.h
@@ -223,6 +223,7 @@ typedef struct xfs_perag {
 	int		pag_ici_init;	/* incore inode cache initialised */
 	rwlock_t	pag_ici_lock;	/* incore inode lock */
 	struct radix_tree_root pag_ici_root;	/* incore inode cache root */
+	int		pag_ici_reclaimable;	/* reclaimable inodes */
 #endif
 	int		pagb_count;	/* pagb slots in use */
 	xfs_perag_busy_t pagb_list[XFS_PAGB_NUM_SLOTS];	/* unstable blocks */
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index 4fa0bc7..1fe7662 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -259,6 +259,7 @@ typedef struct xfs_mount {
 	wait_queue_head_t	m_wait_single_sync_task;
 	__int64_t		m_update_flags;	/* sb flags we need to update
 						   on the next remount,rw */
+	struct shrinker		m_inode_shrink;	/* inode reclaim shrinker */
 } xfs_mount_t;
 
 /*
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
