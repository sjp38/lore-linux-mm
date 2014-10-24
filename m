Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DBCC06B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:37:57 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so912667pab.34
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:37:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qp3si3866524pac.147.2014.10.24.03.37.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:37:56 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 1/9] list_lru: introduce list_lru_shrink_{count,walk}
Date: Fri, 24 Oct 2014 14:37:32 +0400
Message-ID: <71f3f1cd124c69eb2d2494a7aa8c4fbf97c3292b.1414145863.git.vdavydov@parallels.com>
In-Reply-To: <cover.1414145862.git.vdavydov@parallels.com>
References: <cover.1414145862.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

NUMA aware slab shrinkers use the list_lru structure to distribute
objects coming from different NUMA nodes to different lists. Whenever
such a shrinker needs to count or scan objects from a particular node,
it issues commands like this:

        count = list_lru_count_node(lru, sc->nid);
        freed = list_lru_walk_node(lru, sc->nid, isolate_func,
                                   isolate_arg, &sc->nr_to_scan);

where sc is an instance of the shrink_control structure passed to it
from vmscan.

To simplify this, let's add special list_lru functions to be used by
shrinkers, list_lru_shrink_count() and list_lru_shrink_walk(), which
consolidate the nid and nr_to_scan arguments in the shrink_control
structure.

This will also allow us to avoid patching shrinkers that use list_lru
when we make shrink_slab() per-memcg - all we will have to do is extend
the shrink_control structure to include the target memcg and make
list_lru_shrink_{count,walk} handle this appropriately.

Suggested-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/dcache.c              |   14 ++++++--------
 fs/gfs2/quota.c          |    6 +++---
 fs/inode.c               |    7 +++----
 fs/internal.h            |    7 +++----
 fs/super.c               |   24 +++++++++++-------------
 fs/xfs/xfs_buf.c         |    7 +++----
 fs/xfs/xfs_qm.c          |    7 +++----
 include/linux/list_lru.h |   16 ++++++++++++++++
 mm/workingset.c          |    6 +++---
 9 files changed, 51 insertions(+), 43 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index d5a23fd0da90..670c925d7c87 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -930,24 +930,22 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 /**
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
- * @nr_to_scan : number of entries to try to free
- * @nid: which node to scan for freeable entities
+ * @sc: shrink control, passed to list_lru_shrink_walk()
  *
- * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
- * done when we need more memory an called from the superblock shrinker
+ * Attempt to shrink the superblock dcache LRU by @sc->nr_to_scan entries. This
+ * is done when we need more memory and called from the superblock shrinker
  * function.
  *
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_shrink_walk(&sb->s_dentry_lru, sc,
+				     dentry_lru_isolate, &dispose);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 64b29f7f6b4c..6292d79fc340 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -171,8 +171,8 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 	if (!(sc->gfp_mask & __GFP_FS))
 		return SHRINK_STOP;
 
-	freed = list_lru_walk_node(&gfs2_qd_lru, sc->nid, gfs2_qd_isolate,
-				   &dispose, &sc->nr_to_scan);
+	freed = list_lru_shrink_walk(&gfs2_qd_lru, sc,
+				     gfs2_qd_isolate, &dispose);
 
 	gfs2_qd_dispose(&dispose);
 
@@ -182,7 +182,7 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
 static unsigned long gfs2_qd_shrink_count(struct shrinker *shrink,
 					  struct shrink_control *sc)
 {
-	return vfs_pressure_ratio(list_lru_count_node(&gfs2_qd_lru, sc->nid));
+	return vfs_pressure_ratio(list_lru_shrink_count(&gfs2_qd_lru, sc));
 }
 
 struct shrinker gfs2_qd_shrinker = {
diff --git a/fs/inode.c b/fs/inode.c
index 26753ba7b6d6..f08420a3bf50 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -749,14 +749,13 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * to trim from the LRU. Inodes to be freed are moved to a temporary list and
  * then are freed outside inode_lock by dispose_list().
  */
-long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_icache_sb(struct super_block *sb, struct shrink_control *sc)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
-				       &freeable, &nr_to_scan);
+	freed = list_lru_shrink_walk(&sb->s_inode_lru, sc,
+				     inode_lru_isolate, &freeable);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index 9477f8f6aefc..7a6aa641c060 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -14,6 +14,7 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 struct mount;
+struct shrink_control;
 
 /*
  * block_dev.c
@@ -112,8 +113,7 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
-extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_icache_sb(struct super_block *sb, struct shrink_control *sc);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -130,8 +130,7 @@ extern int invalidate_inodes(struct super_block *, bool);
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
 extern int d_set_mounted(struct dentry *dentry);
-extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index eae088f6aaae..4554ac257647 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -77,8 +77,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	if (sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
 
-	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
-	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
+	inodes = list_lru_shrink_count(&sb->s_inode_lru, sc);
+	dentries = list_lru_shrink_count(&sb->s_dentry_lru, sc);
 	total_objects = dentries + inodes + fs_objects + 1;
 	if (!total_objects)
 		total_objects = 1;
@@ -86,20 +86,20 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	/* proportion the scan between the caches */
 	dentries = mult_frac(sc->nr_to_scan, dentries, total_objects);
 	inodes = mult_frac(sc->nr_to_scan, inodes, total_objects);
+	fs_objects = mult_frac(sc->nr_to_scan, fs_objects, total_objects);
 
 	/*
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries, sc->nid);
-	freed += prune_icache_sb(sb, inodes, sc->nid);
+	sc->nr_to_scan = dentries;
+	freed = prune_dcache_sb(sb, sc);
+	sc->nr_to_scan = inodes;
+	freed += prune_icache_sb(sb, sc);
 
-	if (fs_objects) {
-		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
-								total_objects);
+	if (fs_objects)
 		freed += sb->s_op->free_cached_objects(sb, fs_objects,
 						       sc->nid);
-	}
 
 	drop_super(sb);
 	return freed;
@@ -118,17 +118,15 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	 * scalability bottleneck. The counts could get updated
 	 * between super_cache_count and super_cache_scan anyway.
 	 * Call to super_cache_count with shrinker_rwsem held
-	 * ensures the safety of call to list_lru_count_node() and
+	 * ensures the safety of call to list_lru_shrink_count() and
 	 * s_op->nr_cached_objects().
 	 */
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		total_objects = sb->s_op->nr_cached_objects(sb,
 						 sc->nid);
 
-	total_objects += list_lru_count_node(&sb->s_dentry_lru,
-						 sc->nid);
-	total_objects += list_lru_count_node(&sb->s_inode_lru,
-						 sc->nid);
+	total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
+	total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	return total_objects;
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 24b4ebea0d4d..38f6671f75a3 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1578,10 +1578,9 @@ xfs_buftarg_shrink_scan(
 					struct xfs_buftarg, bt_shrinker);
 	LIST_HEAD(dispose);
 	unsigned long		freed;
-	unsigned long		nr_to_scan = sc->nr_to_scan;
 
-	freed = list_lru_walk_node(&btp->bt_lru, sc->nid, xfs_buftarg_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_shrink_walk(&btp->bt_lru, sc,
+				     xfs_buftarg_isolate, &dispose);
 
 	while (!list_empty(&dispose)) {
 		struct xfs_buf *bp;
@@ -1600,7 +1599,7 @@ xfs_buftarg_shrink_count(
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
-	return list_lru_count_node(&btp->bt_lru, sc->nid);
+	return list_lru_shrink_count(&btp->bt_lru, sc);
 }
 
 void
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index d68f23021af3..ec92f6b2e0f2 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -525,7 +525,6 @@ xfs_qm_shrink_scan(
 	struct xfs_qm_isolate	isol;
 	unsigned long		freed;
 	int			error;
-	unsigned long		nr_to_scan = sc->nr_to_scan;
 
 	if ((sc->gfp_mask & (__GFP_FS|__GFP_WAIT)) != (__GFP_FS|__GFP_WAIT))
 		return 0;
@@ -533,8 +532,8 @@ xfs_qm_shrink_scan(
 	INIT_LIST_HEAD(&isol.buffers);
 	INIT_LIST_HEAD(&isol.dispose);
 
-	freed = list_lru_walk_node(&qi->qi_lru, sc->nid, xfs_qm_dquot_isolate, &isol,
-					&nr_to_scan);
+	freed = list_lru_shrink_walk(&qi->qi_lru, sc,
+				     xfs_qm_dquot_isolate, &isol);
 
 	error = xfs_buf_delwri_submit(&isol.buffers);
 	if (error)
@@ -559,7 +558,7 @@ xfs_qm_shrink_count(
 	struct xfs_quotainfo	*qi = container_of(shrink,
 					struct xfs_quotainfo, qi_shrinker);
 
-	return list_lru_count_node(&qi->qi_lru, sc->nid);
+	return list_lru_shrink_count(&qi->qi_lru, sc);
 }
 
 /*
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index f3434533fbf8..f500a2e39b13 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -9,6 +9,7 @@
 
 #include <linux/list.h>
 #include <linux/nodemask.h>
+#include <linux/shrinker.h>
 
 /* list_lru_walk_cb has to always return one of those */
 enum lru_status {
@@ -81,6 +82,13 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item);
  * Callers that want such a guarantee need to provide an outer lock.
  */
 unsigned long list_lru_count_node(struct list_lru *lru, int nid);
+
+static inline unsigned long list_lru_shrink_count(struct list_lru *lru,
+						  struct shrink_control *sc)
+{
+	return list_lru_count_node(lru, sc->nid);
+}
+
 static inline unsigned long list_lru_count(struct list_lru *lru)
 {
 	long count = 0;
@@ -120,6 +128,14 @@ unsigned long list_lru_walk_node(struct list_lru *lru, int nid,
 				 unsigned long *nr_to_walk);
 
 static inline unsigned long
+list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
+		     list_lru_walk_cb isolate, void *cb_arg)
+{
+	return list_lru_walk_node(lru, sc->nid, isolate, cb_arg,
+				  &sc->nr_to_scan);
+}
+
+static inline unsigned long
 list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	      void *cb_arg, unsigned long nr_to_walk)
 {
diff --git a/mm/workingset.c b/mm/workingset.c
index f7216fa7da27..d4fa7fb10a52 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -275,7 +275,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 
 	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
-	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
+	shadow_nodes = list_lru_shrink_count(&workingset_shadow_nodes, sc);
 	local_irq_enable();
 
 	pages = node_present_pages(sc->nid);
@@ -376,8 +376,8 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 
 	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
-	ret =  list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
-				  shadow_lru_isolate, NULL, &sc->nr_to_scan);
+	ret =  list_lru_shrink_walk(&workingset_shadow_nodes, sc,
+				    shadow_lru_isolate, NULL);
 	local_irq_enable();
 	return ret;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
