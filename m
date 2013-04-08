Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8CE376B00BE
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:01:37 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 13/32] fs: convert inode and dentry shrinking to be node aware
Date: Mon,  8 Apr 2013 18:00:40 +0400
Message-Id: <1365429659-22108-14-git-send-email-glommer@parallels.com>
In-Reply-To: <1365429659-22108-1-git-send-email-glommer@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

Now that the shrinker is passing a nodemask in the scan control
structure, we can pass this to the the generic LRU list code to
isolate reclaim to the lists on matching nodes.

This requires a small amount of refactoring of the LRU list API,
which might be best split out into a separate patch.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c              |  8 +++++---
 fs/inode.c               |  7 ++++---
 fs/internal.h            |  6 ++++--
 fs/super.c               | 22 +++++++++++++---------
 fs/xfs/xfs_super.c       |  6 ++++--
 include/linux/fs.h       |  4 ++--
 include/linux/list_lru.h | 19 ++++++++++++++++---
 lib/list_lru.c           | 18 ++++++++++--------
 8 files changed, 58 insertions(+), 32 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index baef78c..b276bb2 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -895,6 +895,7 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
  * @nr_to_scan : number of entries to try to free
+ * @nodes_to_walk: which nodes to scan for freeable entities
  *
  * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
  * done when we need more memory an called from the superblock shrinker
@@ -903,13 +904,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-long prune_dcache_sb(struct super_block *sb, long nr_to_scan)
+long prune_dcache_sb(struct super_block *sb, long nr_to_scan,
+		     nodemask_t *nodes_to_walk)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk(&sb->s_dentry_lru, dentry_lru_isolate,
-			      &dispose, nr_to_scan);
+	freed = list_lru_walk_nodemask(&sb->s_dentry_lru, dentry_lru_isolate,
+				       &dispose, nr_to_scan, nodes_to_walk);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
diff --git a/fs/inode.c b/fs/inode.c
index 61980f1..1b7a87a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -745,13 +745,14 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * to trim from the LRU. Inodes to be freed are moved to a temporary list and
  * then are freed outside inode_lock by dispose_list().
  */
-long prune_icache_sb(struct super_block *sb, long nr_to_scan)
+long prune_icache_sb(struct super_block *sb, long nr_to_scan,
+		     nodemask_t *nodes_to_walk)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk(&sb->s_inode_lru, inode_lru_isolate,
-						&freeable, nr_to_scan);
+	freed = list_lru_walk_nodemask(&sb->s_inode_lru, inode_lru_isolate,
+				       &freeable, nr_to_scan, nodes_to_walk);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index 5099f87..ed6944e 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -110,7 +110,8 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
-extern long prune_icache_sb(struct super_block *sb, long nr_to_scan);
+extern long prune_icache_sb(struct super_block *sb, long nr_to_scan,
+			    nodemask_t *nodes_to_scan);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -126,4 +127,5 @@ extern int invalidate_inodes(struct super_block *, bool);
  * dcache.c
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
-extern long prune_dcache_sb(struct super_block *sb, long nr_to_scan);
+extern long prune_dcache_sb(struct super_block *sb, long nr_to_scan,
+			    nodemask_t *nodes_to_scan);
diff --git a/fs/super.c b/fs/super.c
index 66f5cde..5c7b879 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -75,10 +75,10 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 		return -1;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		fs_objects = sb->s_op->nr_cached_objects(sb);
+		fs_objects = sb->s_op->nr_cached_objects(sb, &sc->nodes_to_scan);
 
-	inodes = list_lru_count(&sb->s_inode_lru);
-	dentries = list_lru_count(&sb->s_dentry_lru);
+	inodes = list_lru_count_nodemask(&sb->s_inode_lru, &sc->nodes_to_scan);
+	dentries = list_lru_count_nodemask(&sb->s_dentry_lru, &sc->nodes_to_scan);
 	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
@@ -89,13 +89,14 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries);
-	freed += prune_icache_sb(sb, inodes);
+	freed = prune_dcache_sb(sb, dentries, &sc->nodes_to_scan);
+	freed += prune_icache_sb(sb, inodes, &sc->nodes_to_scan);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
 								total_objects);
-		freed += sb->s_op->free_cached_objects(sb, fs_objects);
+		freed += sb->s_op->free_cached_objects(sb, fs_objects,
+						       &sc->nodes_to_scan);
 	}
 
 	drop_super(sb);
@@ -113,10 +114,13 @@ static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc
 		return -1;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		total_objects = sb->s_op->nr_cached_objects(sb);
+		total_objects = sb->s_op->nr_cached_objects(sb,
+						 &sc->nodes_to_scan);
 
-	total_objects += list_lru_count(&sb->s_dentry_lru);
-	total_objects += list_lru_count(&sb->s_inode_lru);
+	total_objects += list_lru_count_nodemask(&sb->s_dentry_lru,
+						 &sc->nodes_to_scan);
+	total_objects += list_lru_count_nodemask(&sb->s_inode_lru,
+						 &sc->nodes_to_scan);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 1ff991b..7fa6021 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1525,7 +1525,8 @@ xfs_fs_mount(
 
 static long
 xfs_fs_nr_cached_objects(
-	struct super_block	*sb)
+	struct super_block	*sb,
+	nodemask_t		*nodes_to_count)
 {
 	return xfs_reclaim_inodes_count(XFS_M(sb));
 }
@@ -1533,7 +1534,8 @@ xfs_fs_nr_cached_objects(
 static long
 xfs_fs_free_cached_objects(
 	struct super_block	*sb,
-	long			nr_to_scan)
+	long			nr_to_scan,
+	nodemask_t		*nodes_to_scan)
 {
 	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8b25de0..306c83e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1607,8 +1607,8 @@ struct super_operations {
 	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
-	long (*nr_cached_objects)(struct super_block *);
-	long (*free_cached_objects)(struct super_block *, long);
+	long (*nr_cached_objects)(struct super_block *, nodemask_t *);
+	long (*free_cached_objects)(struct super_block *, long, nodemask_t *);
 };
 
 /*
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 9073f97..8f4db8e 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -31,15 +31,28 @@ struct list_lru {
 int list_lru_init(struct list_lru *lru);
 int list_lru_add(struct list_lru *lru, struct list_head *item);
 int list_lru_del(struct list_lru *lru, struct list_head *item);
-long list_lru_count(struct list_lru *lru);
+long list_lru_count_nodemask(struct list_lru *lru, nodemask_t *nodes_to_count);
+
+static inline long list_lru_count(struct list_lru *lru)
+{
+	return list_lru_count_nodemask(lru, &lru->active_nodes);
+}
+
 
 typedef enum lru_status
 (*list_lru_walk_cb)(struct list_head *item, spinlock_t *lock, void *cb_arg);
 
 typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
 
-long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
-		   void *cb_arg, long nr_to_walk);
+long list_lru_walk_nodemask(struct list_lru *lru, list_lru_walk_cb isolate,
+		   void *cb_arg, long nr_to_walk, nodemask_t *nodes_to_walk);
+
+static inline long list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
+				 void *cb_arg, long nr_to_walk)
+{
+	return list_lru_walk_nodemask(lru, isolate, cb_arg, nr_to_walk,
+				      &lru->active_nodes);
+}
 
 long list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
 
diff --git a/lib/list_lru.c b/lib/list_lru.c
index 0119af8..6c88dc5 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -54,13 +54,14 @@ list_lru_del(
 EXPORT_SYMBOL_GPL(list_lru_del);
 
 long
-list_lru_count(
-	struct list_lru *lru)
+list_lru_count_nodemask(
+	struct list_lru *lru,
+	nodemask_t	*nodes_to_count)
 {
 	long count = 0;
 	int nid;
 
-	for_each_node_mask(nid, lru->active_nodes) {
+	for_each_node_mask(nid, *nodes_to_count) {
 		struct list_lru_node *nlru = &lru->node[nid];
 
 		spin_lock(&nlru->lock);
@@ -71,7 +72,7 @@ list_lru_count(
 
 	return count;
 }
-EXPORT_SYMBOL_GPL(list_lru_count);
+EXPORT_SYMBOL_GPL(list_lru_count_nodemask);
 
 static long
 list_lru_walk_node(
@@ -116,16 +117,17 @@ restart:
 }
 
 long
-list_lru_walk(
+list_lru_walk_nodemask(
 	struct list_lru	*lru,
 	list_lru_walk_cb isolate,
 	void		*cb_arg,
-	long		nr_to_walk)
+	long		nr_to_walk,
+	nodemask_t	*nodes_to_walk)
 {
 	long isolated = 0;
 	int nid;
 
-	for_each_node_mask(nid, lru->active_nodes) {
+	for_each_node_mask(nid, *nodes_to_walk) {
 		isolated += list_lru_walk_node(lru, nid, isolate,
 					       cb_arg, &nr_to_walk);
 		if (nr_to_walk <= 0)
@@ -133,7 +135,7 @@ list_lru_walk(
 	}
 	return isolated;
 }
-EXPORT_SYMBOL_GPL(list_lru_walk);
+EXPORT_SYMBOL_GPL(list_lru_walk_nodemask);
 
 static long
 list_lru_dispose_all_node(
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
