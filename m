Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id F1D346B0068
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:16 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id ep20so1281642lab.34
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si3279661las.69.2013.12.09.00.06.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:16 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 08/16] mm: list_lru: require shrink_control in count, walk functions
Date: Mon, 9 Dec 2013 12:05:49 +0400
Message-ID: <86a461d3615ab4b9a270e754024c7bff99b1f5f0.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>

To enable targeted reclaim, the list_lru structure distributes its
elements among several LRU lists. Currently, there is one LRU per NUMA
node, and the elements from different nodes are placed to different
LRUs. As a result there are two versions of count and walk functions:

 - list_lru_count, list_lru_walk - count, walk items from all nodes;
 - list_lru_count_node, list_lru_walk_node - count, walk items from a
   particular node specified in an additional argument.

We are going to make the list_lru structure per-memcg in addition to
being per-node. This would allow us to reclaim slab not only on global
memory shortage, but also on memcg pressure. If we followed the current
list_lru interface notation, we would have to add a bunch of new
functions taking a memcg and a node in additional arguments, which would
look cumbersome.

To avoid this, we remove the *_node functions and make list_lru_count
and list_lru_walk require a shrink_control argument so that they will
operate only on the NUMA node specified in shrink_control::nid. If the
caller passes NULL instead of a shrink_control object, the functions
will scan all nodes. This looks sane, because targeted list_lru walks are
only used by shrinkers, which always have a shrink_control object.
Furthermore, when we implement targeted memcg shrinking and add the
memcg field to the shrink_control structure, we will not need to change
the existing list_lru interface.

Thanks to David Chinner for the tip.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/dcache.c              |   17 +++++++++--------
 fs/gfs2/quota.c          |    8 ++++----
 fs/inode.c               |    8 ++++----
 fs/internal.h            |    9 +++++----
 fs/super.c               |   14 ++++++--------
 fs/xfs/xfs_buf.c         |   14 ++++++++------
 fs/xfs/xfs_qm.c          |    6 +++---
 include/linux/list_lru.h |   43 ++++++++++---------------------------------
 mm/list_lru.c            |   45 ++++++++++++++++++++++++++++++++++++++++-----
 9 files changed, 89 insertions(+), 75 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4bdb300..aac0e61 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -972,8 +972,8 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 /**
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
- * @nr_to_scan : number of entries to try to free
- * @nid: which node to scan for freeable entities
+ * @sc: shrink control, passed to list_lru_walk()
+ * @nr_to_scan: number of entries to try to free
  *
  * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
  * done when we need more memory an called from the superblock shrinker
@@ -982,14 +982,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc,
+		     unsigned long nr_to_scan)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_walk(&sb->s_dentry_lru, sc, dentry_lru_isolate,
+			      &dispose, &nr_to_scan);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
@@ -1028,9 +1028,10 @@ void shrink_dcache_sb(struct super_block *sb)
 
 	do {
 		LIST_HEAD(dispose);
+		unsigned long nr_to_scan = ULONG_MAX;
 
-		freed = list_lru_walk(&sb->s_dentry_lru,
-			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
+		freed = list_lru_walk(&sb->s_dentry_lru, NULL,
+			dentry_lru_isolate_shrink, &dispose, &nr_to_scan);
 
 		this_cpu_sub(nr_dentry_unused, freed);
 		shrink_dentry_list(&dispose);
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 98236d0..f0435da 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -132,8 +132,8 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 	if (!(sc->gfp_mask & __GFP_FS))
 		return SHRINK_STOP;
 
-	freed = list_lru_walk_node(&gfs2_qd_lru, sc->nid, gfs2_qd_isolate,
-				   &dispose, &sc->nr_to_scan);
+	freed = list_lru_walk(&gfs2_qd_lru, sc, gfs2_qd_isolate,
+			      &dispose, &sc->nr_to_scan);
 
 	gfs2_qd_dispose(&dispose);
 
@@ -143,7 +143,7 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 static unsigned long gfs2_qd_shrink_count(struct shrinker *shrink,
 					  struct shrink_control *sc)
 {
-	return vfs_pressure_ratio(list_lru_count_node(&gfs2_qd_lru, sc->nid));
+	return vfs_pressure_ratio(list_lru_count(&gfs2_qd_lru, sc));
 }
 
 struct shrinker gfs2_qd_shrinker = {
@@ -1504,7 +1504,7 @@ static int gfs2_quota_get_xstate(struct super_block *sb,
 	}
 	fqs->qs_uquota.qfs_nextents = 1; /* unsupported */
 	fqs->qs_gquota = fqs->qs_uquota; /* its the same inode in both cases */
-	fqs->qs_incoredqs = list_lru_count(&gfs2_qd_lru);
+	fqs->qs_incoredqs = list_lru_count(&gfs2_qd_lru, NULL);
 	return 0;
 }
 
diff --git a/fs/inode.c b/fs/inode.c
index 4bcdad3..7c6eda2 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -748,14 +748,14 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * to trim from the LRU. Inodes to be freed are moved to a temporary list and
  * then are freed outside inode_lock by dispose_list().
  */
-long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_icache_sb(struct super_block *sb, struct shrink_control *sc,
+		     unsigned long nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
-				       &freeable, &nr_to_scan);
+	freed = list_lru_walk(&sb->s_inode_lru, sc, inode_lru_isolate,
+			      &freeable, &nr_to_scan);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index 4657424..a6a9627 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -14,6 +14,7 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 struct mount;
+struct shrink_control;
 
 /*
  * block_dev.c
@@ -107,8 +108,8 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
-extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_icache_sb(struct super_block *sb, struct shrink_control *sc,
+			    unsigned long nr_to_scan);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -125,8 +126,8 @@ extern int invalidate_inodes(struct super_block *, bool);
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
 extern int d_set_mounted(struct dentry *dentry);
-extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc,
+			    unsigned long nr_to_scan);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index e5f6c2c..a039dba 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -78,8 +78,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	if (sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
 
-	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
-	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
+	inodes = list_lru_count(&sb->s_inode_lru, sc);
+	dentries = list_lru_count(&sb->s_dentry_lru, sc);
 	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
@@ -90,8 +90,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries, sc->nid);
-	freed += prune_icache_sb(sb, inodes, sc->nid);
+	freed = prune_dcache_sb(sb, sc, dentries);
+	freed += prune_icache_sb(sb, sc, inodes);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
@@ -119,10 +119,8 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 		total_objects = sb->s_op->nr_cached_objects(sb,
 						 sc->nid);
 
-	total_objects += list_lru_count_node(&sb->s_dentry_lru,
-						 sc->nid);
-	total_objects += list_lru_count_node(&sb->s_inode_lru,
-						 sc->nid);
+	total_objects += list_lru_count(&sb->s_dentry_lru, sc);
+	total_objects += list_lru_count(&sb->s_inode_lru, sc);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index c7f0b77..5b2a49c 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1508,9 +1508,11 @@ xfs_wait_buftarg(
 	int loop = 0;
 
 	/* loop until there is nothing left on the lru list. */
-	while (list_lru_count(&btp->bt_lru)) {
-		list_lru_walk(&btp->bt_lru, xfs_buftarg_wait_rele,
-			      &dispose, LONG_MAX);
+	while (list_lru_count(&btp->bt_lru, NULL)) {
+		unsigned long nr_to_scan = ULONG_MAX;
+
+		list_lru_walk(&btp->bt_lru, NULL, xfs_buftarg_wait_rele,
+			      &dispose, &nr_to_scan);
 
 		while (!list_empty(&dispose)) {
 			struct xfs_buf *bp;
@@ -1565,8 +1567,8 @@ xfs_buftarg_shrink_scan(
 	unsigned long		freed;
 	unsigned long		nr_to_scan = sc->nr_to_scan;
 
-	freed = list_lru_walk_node(&btp->bt_lru, sc->nid, xfs_buftarg_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_walk(&btp->bt_lru, sc, xfs_buftarg_isolate,
+			      &dispose, &nr_to_scan);
 
 	while (!list_empty(&dispose)) {
 		struct xfs_buf *bp;
@@ -1585,7 +1587,7 @@ xfs_buftarg_shrink_count(
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
-	return list_lru_count_node(&btp->bt_lru, sc->nid);
+	return list_lru_count(&btp->bt_lru, sc);
 }
 
 void
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 14a4996..aaacf8f 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -769,8 +769,8 @@ xfs_qm_shrink_scan(
 	INIT_LIST_HEAD(&isol.buffers);
 	INIT_LIST_HEAD(&isol.dispose);
 
-	freed = list_lru_walk_node(&qi->qi_lru, sc->nid, xfs_qm_dquot_isolate, &isol,
-					&nr_to_scan);
+	freed = list_lru_walk(&qi->qi_lru, sc, xfs_qm_dquot_isolate, &isol,
+			      &nr_to_scan);
 
 	error = xfs_buf_delwri_submit(&isol.buffers);
 	if (error)
@@ -795,7 +795,7 @@ xfs_qm_shrink_count(
 	struct xfs_quotainfo	*qi = container_of(shrink,
 					struct xfs_quotainfo, qi_shrinker);
 
-	return list_lru_count_node(&qi->qi_lru, sc->nid);
+	return list_lru_count(&qi->qi_lru, sc);
 }
 
 /*
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..34e57af 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -10,6 +10,8 @@
 #include <linux/list.h>
 #include <linux/nodemask.h>
 
+struct shrink_control;
+
 /* list_lru_walk_cb has to always return one of those */
 enum lru_status {
 	LRU_REMOVED,		/* item removed from list */
@@ -66,32 +68,22 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
- * list_lru_count_node: return the number of objects currently held by @lru
+ * list_lru_count: return the number of objects currently held by @lru
  * @lru: the lru pointer.
- * @nid: the node id to count from.
+ * @sc: if not NULL, count only from node @sc->nid.
  *
  * Always return a non-negative number, 0 for empty lists. There is no
  * guarantee that the list is not updated while the count is being computed.
  * Callers that want such a guarantee need to provide an outer lock.
  */
-unsigned long list_lru_count_node(struct list_lru *lru, int nid);
-static inline unsigned long list_lru_count(struct list_lru *lru)
-{
-	long count = 0;
-	int nid;
-
-	for_each_node_mask(nid, lru->active_nodes)
-		count += list_lru_count_node(lru, nid);
-
-	return count;
-}
+unsigned long list_lru_count(struct list_lru *lru, struct shrink_control *sc);
 
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
 /**
- * list_lru_walk_node: walk a list_lru, isolating and disposing freeable items.
+ * list_lru_walk: walk a list_lru, isolating and disposing freeable items.
  * @lru: the lru pointer.
- * @nid: the node id to scan from.
+ * @sc: if not NULL, scan only from node @sc->nid.
  * @isolate: callback function that is resposible for deciding what to do with
  *  the item currently being scanned
  * @cb_arg: opaque type that will be passed to @isolate
@@ -109,23 +101,8 @@ typedef enum lru_status
  *
  * Return value: the number of objects effectively removed from the LRU.
  */
-unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
-				 list_lru_walk_cb isolate, void *cb_arg,
-				 unsigned long *nr_to_walk);
-
-static inline unsigned long
-list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-	      void *cb_arg, unsigned long nr_to_walk)
-{
-	long isolated = 0;
-	int nid;
+unsigned long list_lru_walk(struct list_lru *lru, struct shrink_control *sc,
+			    list_lru_walk_cb isolate, void *cb_arg,
+			    unsigned long *nr_to_walk);
 
-	for_each_node_mask(nid, lru->active_nodes) {
-		isolated += list_lru_walk_node(lru, nid, isolate,
-					       cb_arg, &nr_to_walk);
-		if (nr_to_walk <= 0)
-			break;
-	}
-	return isolated;
-}
 #endif /* _LRU_LIST_H */
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 72f9dec..7d4a9c2 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -7,8 +7,9 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mm.h>
-#include <linux/list_lru.h>
 #include <linux/slab.h>
+#include <linux/shrinker.h>
+#include <linux/list_lru.h>
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -48,7 +49,7 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
-unsigned long
+static unsigned long
 list_lru_count_node(struct list_lru *lru, int nid)
 {
 	unsigned long count = 0;
@@ -61,9 +62,23 @@ list_lru_count_node(struct list_lru *lru, int nid)
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count_node);
 
-unsigned long
+unsigned long list_lru_count(struct list_lru *lru, struct shrink_control *sc)
+{
+	long count = 0;
+	int nid;
+
+	if (sc)
+		return list_lru_count_node(lru, sc->nid);
+
+	for_each_node_mask(nid, lru->active_nodes)
+		count += list_lru_count_node(lru, nid);
+
+	return count;
+}
+EXPORT_SYMBOL_GPL(list_lru_count);
+
+static unsigned long
 list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
 		   void *cb_arg, unsigned long *nr_to_walk)
 {
@@ -112,7 +127,27 @@ restart:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk_node);
+
+unsigned long list_lru_walk(struct list_lru *lru, struct shrink_control *sc,
+			    list_lru_walk_cb isolate, void *cb_arg,
+			    unsigned long *nr_to_walk)
+{
+	long isolated = 0;
+	int nid;
+
+	if (sc)
+		return list_lru_walk_node(lru, sc->nid, isolate,
+					  cb_arg, nr_to_walk);
+
+	for_each_node_mask(nid, lru->active_nodes) {
+		isolated += list_lru_walk_node(lru, nid, isolate,
+					       cb_arg, nr_to_walk);
+		if (*nr_to_walk <= 0)
+			break;
+	}
+	return isolated;
+}
+EXPORT_SYMBOL_GPL(list_lru_walk);
 
 int list_lru_init(struct list_lru *lru)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
