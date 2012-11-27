Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C83236B0099
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:15:27 -0500 (EST)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 13/19] xfs: Node aware direct inode reclaim
Date: Wed, 28 Nov 2012 10:14:40 +1100
Message-Id: <1354058086-27937-14-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

XFS currently only tracks inodes for reclaim via tag bits in the
inode cache radix tree. While this is awesome for background reclaim
because it allows inodes to be reclaimed in ascending disk offset
order, it sucks for direct memory reclaim which really is trying to
free the oldest inodes from memory.

As such, the direct reclaim code is a bit of a mess. It has all
sorts of heuristics code to try to avoid dueling shrinker problems
and to limit each radix tree to a single direct reclaim walker at a
time. We can do better.

Given that at the point in time that we mark an inode as under
reclaim, it has been evicted from the VFS inode cache, we can reuse
the struct inode LRU fields to hold our own reclaim ordered LRU
list. With the generic LRU code, it doesn't impact on scalability,
and the shrinker can walk the LRU lists directly giving us
node-aware inode cache reclaim.

This means that we get the best of both worlds - background reclaim
runs very efficiently in terms of IO for cleaning dirty reclaimable
inodes, while direct reclaim can walk the LRU lists and pick inodes
to reclaim that suit the MM subsystem the best.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_icache.c |   77 ++++++++++++++++++++++++++++++++++++++-------------
 fs/xfs/xfs_icache.h |    4 +--
 fs/xfs/xfs_linux.h  |    1 +
 fs/xfs/xfs_mount.h  |    2 +-
 fs/xfs/xfs_super.c  |    6 ++--
 5 files changed, 65 insertions(+), 25 deletions(-)

diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 2f91e2b..82b053f 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -244,6 +244,8 @@ xfs_iget_cache_hit(
 
 		spin_unlock(&ip->i_flags_lock);
 		spin_unlock(&pag->pag_ici_lock);
+
+		list_lru_del(&mp->m_inode_lru, &VFS_I(ip)->i_lru);
 	} else {
 		/* If the VFS inode is being torn down, pause and try again. */
 		if (!igrab(inode)) {
@@ -990,6 +992,17 @@ reclaim:
 	spin_unlock(&pag->pag_ici_lock);
 
 	/*
+	 * iT is safe to do this unlocked check as we've guaranteed that we have
+	 * exclusive access to this inode via the XFS_IRECLAIM flag. Hence
+	 * concurrent LRU list walks will avoid removing this inode from the
+	 * list. For direct reclaim, we know the inode has already been removed
+	 * from any list it might be on, hence there's no need to traffic the
+	 * LRU code to find that out.
+	 */
+	if (!list_empty(&VFS_I(ip)->i_lru))
+		list_lru_del(&ip->i_mount->m_inode_lru, &VFS_I(ip)->i_lru);
+
+	/*
 	 * Here we do an (almost) spurious inode lock in order to coordinate
 	 * with inode cache radix tree lookups.  This is because the lookup
 	 * can reference the inodes in the cache without taking references.
@@ -1155,6 +1168,32 @@ xfs_reclaim_inodes(
 	return xfs_reclaim_inodes_ag(mp, mode, &nr_to_scan);
 }
 
+static int
+xfs_reclaim_inode_isolate(
+	struct list_head	*item,
+	spinlock_t		*lru_lock,
+	void			*cb_arg)
+{
+	struct inode		*inode = container_of(item, struct inode,
+						      i_lru);
+	struct list_head	*dispose = cb_arg;
+
+	rcu_read_lock();
+	if (xfs_reclaim_inode_grab(XFS_I(inode), SYNC_TRYLOCK)) {
+		/* not a reclaim candiate, skip it */
+		rcu_read_unlock();
+		return 2;
+	}
+	rcu_read_unlock();
+
+	/*
+	 * We have the XFS_IRECLAIM flag set now, so nobody is going to touch
+	 * this inode now except us.
+	 */
+	list_move(item, dispose);
+	return 0;
+}
+
 /*
  * Scan a certain number of inodes for reclaim.
  *
@@ -1167,36 +1206,34 @@ xfs_reclaim_inodes(
 long
 xfs_reclaim_inodes_nr(
 	struct xfs_mount	*mp,
-	long			nr_to_scan)
+	long			nr_to_scan,
+	nodemask_t		*nodes_to_scan)
 {
-	long nr = nr_to_scan;
+	LIST_HEAD(dispose);
+	long freed;
 
 	/* kick background reclaimer and push the AIL */
 	xfs_reclaim_work_queue(mp);
 	xfs_ail_push_all(mp->m_ail);
 
-	xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr);
-	return nr_to_scan - nr;
-}
+	freed = list_lru_walk_nodemask(&mp->m_inode_lru,
+				       xfs_reclaim_inode_isolate, &dispose,
+				       nr_to_scan, nodes_to_scan);
 
-/*
- * Return the number of reclaimable inodes in the filesystem for
- * the shrinker to determine how much to reclaim.
- */
-long
-xfs_reclaim_inodes_count(
-	struct xfs_mount	*mp)
-{
-	struct xfs_perag	*pag;
-	xfs_agnumber_t		ag = 0;
-	long			reclaimable = 0;
+	while (!list_empty(&dispose)) {
+		struct xfs_perag *pag;
+		struct inode	*inode;
 
-	while ((pag = xfs_perag_get_tag(mp, ag, XFS_ICI_RECLAIM_TAG))) {
-		ag = pag->pag_agno + 1;
-		reclaimable += pag->pag_ici_reclaimable;
+		inode = list_first_entry(&dispose, struct inode, i_lru);
+		list_del_init(&inode->i_lru);
+
+		pag = xfs_perag_get(mp,
+				    XFS_INO_TO_AGNO(mp, XFS_I(inode)->i_ino));
+		xfs_reclaim_inode(XFS_I(inode), pag, SYNC_WAIT);
 		xfs_perag_put(pag);
 	}
-	return reclaimable;
+
+	return freed;
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index c860d07..4214518 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -30,8 +30,8 @@ int xfs_iget(struct xfs_mount *mp, struct xfs_trans *tp, xfs_ino_t ino,
 void xfs_reclaim_worker(struct work_struct *work);
 
 int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
-long xfs_reclaim_inodes_count(struct xfs_mount *mp);
-long xfs_reclaim_inodes_nr(struct xfs_mount *mp, long nr_to_scan);
+long xfs_reclaim_inodes_nr(struct xfs_mount *mp, long nr_to_scan,
+			   nodemask_t *nodes_to_scan);
 
 void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
 
diff --git a/fs/xfs/xfs_linux.h b/fs/xfs/xfs_linux.h
index fe7e4df..40cc5d1 100644
--- a/fs/xfs/xfs_linux.h
+++ b/fs/xfs/xfs_linux.h
@@ -72,6 +72,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/list_sort.h>
+#include <linux/list_lru.h>
 
 #include <asm/page.h>
 #include <asm/div64.h>
diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
index bab8314..859fd5d 100644
--- a/fs/xfs/xfs_mount.h
+++ b/fs/xfs/xfs_mount.h
@@ -200,9 +200,9 @@ typedef struct xfs_mount {
 						     trimming */
 	__int64_t		m_update_flags;	/* sb flags we need to update
 						   on the next remount,rw */
-	struct shrinker		m_inode_shrink;	/* inode reclaim shrinker */
 	int64_t			m_low_space[XFS_LOWSP_MAX];
 						/* low free space thresholds */
+	struct list_lru		m_inode_lru;	/* direct inode reclaim list */
 
 	struct workqueue_struct	*m_data_workqueue;
 	struct workqueue_struct	*m_unwritten_workqueue;
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 33d67d5..814e07a 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -968,6 +968,7 @@ xfs_fs_destroy_inode(
 	 * reclaim tear down all inodes.
 	 */
 out_reclaim:
+	list_lru_add(&ip->i_mount->m_inode_lru, &inode->i_lru);
 	xfs_inode_set_reclaim_tag(ip);
 }
 
@@ -1402,6 +1403,7 @@ xfs_fs_fill_super(
 	atomic_set(&mp->m_active_trans, 0);
 	INIT_DELAYED_WORK(&mp->m_reclaim_work, xfs_reclaim_worker);
 	INIT_DELAYED_WORK(&mp->m_eofblocks_work, xfs_eofblocks_worker);
+	list_lru_init(&mp->m_inode_lru);
 
 	mp->m_super = sb;
 	sb->s_fs_info = mp;
@@ -1519,7 +1521,7 @@ xfs_fs_nr_cached_objects(
 	struct super_block	*sb,
 	nodemask_t		*nodes_to_count)
 {
-	return xfs_reclaim_inodes_count(XFS_M(sb));
+	return list_lru_count_nodemask(&XFS_M(sb)->m_inode_lru, nodes_to_count);
 }
 
 static long
@@ -1528,7 +1530,7 @@ xfs_fs_free_cached_objects(
 	long			nr_to_scan,
 	nodemask_t		*nodes_to_scan)
 {
-	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
+	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan, nodes_to_scan);
 }
 
 static const struct super_operations xfs_super_operations = {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
