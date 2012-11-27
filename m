Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EA2046B007B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 18:15:14 -0500 (EST)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 16/19] fs: convert fs shrinkers to new scan/count API
Date: Wed, 28 Nov 2012 10:14:43 +1100
Message-Id: <1354058086-27937-17-git-send-email-david@fromorbit.com>
In-Reply-To: <1354058086-27937-1-git-send-email-david@fromorbit.com>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Convert the filesystem shrinkers to use the new API, and standardise
some of the behaviours of the shrinkers at the same time. For
example, nr_to_scan means the number of objects to scan, not the
number of objects to free.

I refactored the CIFS idmap shrinker a little - it really needs to
be broken up into a shrinker per tree and keep an item count with
the tree root so that we don't need to walk the tree every time the
shrinker needs to count the number of objects in the tree (i.e.
all the time under memory pressure).

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/cifs/cifsacl.c |  112 ++++++++++++++++++++++++++++++++---------------------
 fs/gfs2/glock.c   |   23 ++++++-----
 fs/gfs2/main.c    |    3 +-
 fs/gfs2/quota.c   |   12 +++---
 fs/gfs2/quota.h   |    4 +-
 fs/mbcache.c      |   53 ++++++++++++++-----------
 fs/nfs/dir.c      |   21 ++++++++--
 fs/nfs/internal.h |    4 +-
 fs/nfs/super.c    |    3 +-
 fs/quota/dquot.c  |   37 ++++++++----------
 10 files changed, 163 insertions(+), 109 deletions(-)

diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index 0fb15bb..a0e5c22 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -44,66 +44,95 @@ static const struct cifs_sid sid_user = {1, 2 , {0, 0, 0, 0, 0, 5}, {} };
 
 const struct cred *root_cred;
 
-static void
-shrink_idmap_tree(struct rb_root *root, int nr_to_scan, int *nr_rem,
-			int *nr_del)
+static long
+cifs_idmap_tree_scan(
+	struct rb_root	*root,
+	spinlock_t	*tree_lock,
+	long		nr_to_scan)
 {
 	struct rb_node *node;
-	struct rb_node *tmp;
-	struct cifs_sid_id *psidid;
+	long freed = 0;
 
+	spin_lock(tree_lock);
 	node = rb_first(root);
-	while (node) {
+	while (nr_to_scan-- >= 0 && node) {
+		struct cifs_sid_id *psidid;
+		struct rb_node *tmp;
+
 		tmp = node;
 		node = rb_next(tmp);
 		psidid = rb_entry(tmp, struct cifs_sid_id, rbnode);
-		if (nr_to_scan == 0 || *nr_del == nr_to_scan)
-			++(*nr_rem);
-		else {
-			if (time_after(jiffies, psidid->time + SID_MAP_EXPIRE)
-						&& psidid->refcount == 0) {
-				rb_erase(tmp, root);
-				++(*nr_del);
-			} else
-				++(*nr_rem);
+		if (time_after(jiffies, psidid->time + SID_MAP_EXPIRE)
+					&& psidid->refcount == 0) {
+			rb_erase(tmp, root);
+			freed++;
 		}
 	}
+	spin_unlock(tree_lock);
+	return freed;
+}
+
+static long
+cifs_idmap_tree_count(
+	struct rb_root	*root,
+	spinlock_t	*tree_lock)
+{
+	struct rb_node *node;
+	long count = 0;
+
+	spin_lock(tree_lock);
+	node = rb_first(root);
+	while (node) {
+		node = rb_next(node);
+		count++;
+	}
+	spin_unlock(tree_lock);
+	return count;
 }
 
 /*
- * Run idmap cache shrinker.
+ * idmap tree shrinker.
+ *
+ * XXX (dchinner): this should really be 4 separate shrinker instances (one per
+ * tree structure) so that each are shrunk proportionally to their individual
+ * sizes.
  */
-static int
-cifs_idmap_shrinker(struct shrinker *shrink, struct shrink_control *sc)
+static long
+cifs_idmap_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
-	int nr_to_scan = sc->nr_to_scan;
-	int nr_del = 0;
-	int nr_rem = 0;
-	struct rb_root *root;
+	long freed = 0;
 
-	root = &uidtree;
-	spin_lock(&siduidlock);
-	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
-	spin_unlock(&siduidlock);
+	freed += cifs_idmap_tree_scan(&uidtree, &siduidlock, sc->nr_to_scan);
+	freed += cifs_idmap_tree_scan(&gidtree, &sidgidlock, sc->nr_to_scan);
+	freed += cifs_idmap_tree_scan(&siduidtree, &siduidlock, sc->nr_to_scan);
+	freed += cifs_idmap_tree_scan(&sidgidtree, &sidgidlock, sc->nr_to_scan);
 
-	root = &gidtree;
-	spin_lock(&sidgidlock);
-	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
-	spin_unlock(&sidgidlock);
+	return freed;
+}
 
-	root = &siduidtree;
-	spin_lock(&uidsidlock);
-	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
-	spin_unlock(&uidsidlock);
+static long
+cifs_idmap_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	long count = 0;
 
-	root = &sidgidtree;
-	spin_lock(&gidsidlock);
-	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
-	spin_unlock(&gidsidlock);
+	count += cifs_idmap_tree_count(&uidtree, &siduidlock);
+	count += cifs_idmap_tree_count(&gidtree, &sidgidlock);
+	count += cifs_idmap_tree_count(&siduidtree, &siduidlock);
+	count += cifs_idmap_tree_count(&sidgidtree, &sidgidlock);
 
-	return nr_rem;
+	return count;
 }
 
+static struct shrinker cifs_shrinker = {
+	.count_objects = cifs_idmap_shrink_count,
+	.scan_objects = cifs_idmap_shrink_scan,
+	.seeks = DEFAULT_SEEKS,
+};
+
 static void
 sid_rb_insert(struct rb_root *root, unsigned long cid,
 		struct cifs_sid_id **psidid, char *typestr)
@@ -161,11 +190,6 @@ sid_rb_search(struct rb_root *root, unsigned long cid)
 	return NULL;
 }
 
-static struct shrinker cifs_shrinker = {
-	.shrink = cifs_idmap_shrinker,
-	.seeks = DEFAULT_SEEKS,
-};
-
 static int
 cifs_idmap_key_instantiate(struct key *key, struct key_preparsed_payload *prep)
 {
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index e6c2fd5..4be61a22e 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1365,9 +1365,8 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
 		gfs2_glock_put(gl);
 }
 
-
-static int gfs2_shrink_glock_memory(struct shrinker *shrink,
-				    struct shrink_control *sc)
+static long gfs2_glock_shrink_scan(struct shrinker *shrink,
+				   struct shrink_control *sc)
 {
 	struct gfs2_glock *gl;
 	int may_demote;
@@ -1375,15 +1374,13 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 	int nr = sc->nr_to_scan;
 	gfp_t gfp_mask = sc->gfp_mask;
 	LIST_HEAD(skipped);
-
-	if (nr == 0)
-		goto out;
+	long freed = 0;
 
 	if (!(gfp_mask & __GFP_FS))
 		return -1;
 
 	spin_lock(&lru_lock);
-	while(nr && !list_empty(&lru_list)) {
+	while(nr-- >= 0 && !list_empty(&lru_list)) {
 		gl = list_entry(lru_list.next, struct gfs2_glock, gl_lru);
 		list_del_init(&gl->gl_lru);
 		clear_bit(GLF_LRU, &gl->gl_flags);
@@ -1397,7 +1394,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 			may_demote = demote_ok(gl);
 			if (may_demote) {
 				handle_callback(gl, LM_ST_UNLOCKED, 0);
-				nr--;
+				freed++;
 			}
 			clear_bit(GLF_LOCK, &gl->gl_flags);
 			smp_mb__after_clear_bit();
@@ -1414,12 +1411,18 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
 	list_splice(&skipped, &lru_list);
 	atomic_add(nr_skipped, &lru_count);
 	spin_unlock(&lru_lock);
-out:
+	return freed;
+}
+
+static long gfs2_glock_shrink_count(struct shrinker *shrink,
+				    struct shrink_control *sc)
+{
 	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
 }
 
 static struct shrinker glock_shrinker = {
-	.shrink = gfs2_shrink_glock_memory,
+	.count_objects = gfs2_glock_shrink_count,
+	.scan_objects = gfs2_glock_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
diff --git a/fs/gfs2/main.c b/fs/gfs2/main.c
index e04d0e0..a105d84 100644
--- a/fs/gfs2/main.c
+++ b/fs/gfs2/main.c
@@ -32,7 +32,8 @@
 struct workqueue_struct *gfs2_control_wq;
 
 static struct shrinker qd_shrinker = {
-	.shrink = gfs2_shrink_qd_memory,
+	.count_objects = gfs2_qd_shrink_count,
+	.scan_objects = gfs2_qd_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index c5af8e1..f4bf289 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -78,14 +78,12 @@ static LIST_HEAD(qd_lru_list);
 static atomic_t qd_lru_count = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(qd_lru_lock);
 
-int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
+long gfs2_qd_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct gfs2_quota_data *qd;
 	struct gfs2_sbd *sdp;
 	int nr_to_scan = sc->nr_to_scan;
-
-	if (nr_to_scan == 0)
-		goto out;
+	long freed = 0;
 
 	if (!(sc->gfp_mask & __GFP_FS))
 		return -1;
@@ -113,10 +111,14 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
 		kmem_cache_free(gfs2_quotad_cachep, qd);
 		spin_lock(&qd_lru_lock);
 		nr_to_scan--;
+		freed++;
 	}
 	spin_unlock(&qd_lru_lock);
+	return freed;
+}
 
-out:
+long gfs2_qd_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
+{
 	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
 }
 
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index f25d98b..e0bd306 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -52,7 +52,9 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(struct shrinker *shrink,
+extern long gfs2_qd_shrink_count(struct shrinker *shrink,
+				 struct shrink_control *sc);
+extern long gfs2_qd_shrink_scan(struct shrinker *shrink,
 				 struct shrink_control *sc);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 8c32ef3..04bf2fb 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -86,18 +86,6 @@ static LIST_HEAD(mb_cache_list);
 static LIST_HEAD(mb_cache_lru_list);
 static DEFINE_SPINLOCK(mb_cache_spinlock);
 
-/*
- * What the mbcache registers as to get shrunk dynamically.
- */
-
-static int mb_cache_shrink_fn(struct shrinker *shrink,
-			      struct shrink_control *sc);
-
-static struct shrinker mb_cache_shrinker = {
-	.shrink = mb_cache_shrink_fn,
-	.seeks = DEFAULT_SEEKS,
-};
-
 static inline int
 __mb_cache_entry_is_hashed(struct mb_cache_entry *ce)
 {
@@ -151,7 +139,7 @@ forget:
 
 
 /*
- * mb_cache_shrink_fn()  memory pressure callback
+ * mb_cache_shrink_scan()  memory pressure callback
  *
  * This function is called by the kernel memory management when memory
  * gets low.
@@ -159,17 +147,18 @@ forget:
  * @shrink: (ignored)
  * @sc: shrink_control passed from reclaim
  *
- * Returns the number of objects which are present in the cache.
+ * Returns the number of objects freed.
  */
-static int
-mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
+static long
+mb_cache_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
 	LIST_HEAD(free_list);
-	struct mb_cache *cache;
 	struct mb_cache_entry *entry, *tmp;
-	int count = 0;
 	int nr_to_scan = sc->nr_to_scan;
 	gfp_t gfp_mask = sc->gfp_mask;
+	long freed = 0;
 
 	mb_debug("trying to free %d entries", nr_to_scan);
 	spin_lock(&mb_cache_spinlock);
@@ -179,19 +168,39 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
 				   struct mb_cache_entry, e_lru_list);
 		list_move_tail(&ce->e_lru_list, &free_list);
 		__mb_cache_entry_unhash(ce);
+		freed++;
+	}
+	spin_unlock(&mb_cache_spinlock);
+	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
+		__mb_cache_entry_forget(entry, gfp_mask);
 	}
+	return freed;
+}
+
+static long
+mb_cache_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	struct mb_cache *cache;
+	long count = 0;
+
+	spin_lock(&mb_cache_spinlock);
 	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
 		mb_debug("cache %s (%d)", cache->c_name,
 			  atomic_read(&cache->c_entry_count));
 		count += atomic_read(&cache->c_entry_count);
 	}
 	spin_unlock(&mb_cache_spinlock);
-	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
-		__mb_cache_entry_forget(entry, gfp_mask);
-	}
-	return (count / 100) * sysctl_vfs_cache_pressure;
+	return count;
 }
 
+static struct shrinker mb_cache_shrinker = {
+	.count_objects = mb_cache_shrink_count,
+	.scan_objects = mb_cache_shrink_scan,
+	.seeks = DEFAULT_SEEKS,
+};
+
 
 /*
  * mb_cache_create()  create a new cache
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce8cb92..15f6fbb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1909,17 +1909,20 @@ static void nfs_access_free_list(struct list_head *head)
 	}
 }
 
-int nfs_access_cache_shrinker(struct shrinker *shrink,
-			      struct shrink_control *sc)
+long
+nfs_access_cache_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi, *next;
 	struct nfs_access_entry *cache;
 	int nr_to_scan = sc->nr_to_scan;
 	gfp_t gfp_mask = sc->gfp_mask;
+	long freed = 0;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+		return -1;
 
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry_safe(nfsi, next, &nfs_access_lru_list, access_cache_inode_lru) {
@@ -1935,6 +1938,7 @@ int nfs_access_cache_shrinker(struct shrinker *shrink,
 				struct nfs_access_entry, lru);
 		list_move(&cache->lru, &head);
 		rb_erase(&cache->rb_node, &nfsi->access_cache);
+		freed++;
 		if (!list_empty(&nfsi->access_cache_entry_lru))
 			list_move_tail(&nfsi->access_cache_inode_lru,
 					&nfs_access_lru_list);
@@ -1949,7 +1953,16 @@ remove_lru_entry:
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
+	return freed;
+}
+
+long
+nfs_access_cache_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
+	return (atomic_long_read(&nfs_access_nr_entries) / 100) *
+						sysctl_vfs_cache_pressure;
 }
 
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 05521ca..6b9c45b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -285,7 +285,9 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const char *ip_addr, rpc_authflavor_t authflavour);
 
 /* dir.c */
-extern int nfs_access_cache_shrinker(struct shrinker *shrink,
+extern long nfs_access_cache_count(struct shrinker *shrink,
+					struct shrink_control *sc);
+extern long nfs_access_cache_scan(struct shrinker *shrink,
 					struct shrink_control *sc);
 struct dentry *nfs_lookup(struct inode *, struct dentry *, unsigned int);
 int nfs_create(struct inode *, struct dentry *, umode_t, bool);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 652d3f7..e7dd232 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -354,7 +354,8 @@ static void unregister_nfs4_fs(void)
 #endif
 
 static struct shrinker acl_shrinker = {
-	.shrink		= nfs_access_cache_shrinker,
+	.count_objects	= nfs_access_cache_count,
+	.scan_objects	= nfs_access_cache_scan,
 	.seeks		= DEFAULT_SEEKS,
 };
 
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 05ae3c9..544bd65 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -687,45 +687,42 @@ int dquot_quota_sync(struct super_block *sb, int type)
 }
 EXPORT_SYMBOL(dquot_quota_sync);
 
-/* Free unused dquots from cache */
-static void prune_dqcache(int count)
+static long
+dqcache_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
 	struct list_head *head;
 	struct dquot *dquot;
+	long freed = 0;
 
 	head = free_dquots.prev;
-	while (head != &free_dquots && count) {
+	while (head != &free_dquots && sc->nr_to_scan) {
 		dquot = list_entry(head, struct dquot, dq_free);
 		remove_dquot_hash(dquot);
 		remove_free_dquot(dquot);
 		remove_inuse(dquot);
 		do_destroy_dquot(dquot);
-		count--;
+		sc->nr_to_scan--;
+		freed++;
 		head = free_dquots.prev;
 	}
+	return freed;
 }
 
-/*
- * This is called from kswapd when we think we need some
- * more memory
- */
-static int shrink_dqcache_memory(struct shrinker *shrink,
-				 struct shrink_control *sc)
+static long
+dqcache_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
-	int nr = sc->nr_to_scan;
-
-	if (nr) {
-		spin_lock(&dq_list_lock);
-		prune_dqcache(nr);
-		spin_unlock(&dq_list_lock);
-	}
-	return ((unsigned)
+	return ((long)
 		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
-		/100) * sysctl_vfs_cache_pressure;
+		/ 100) * sysctl_vfs_cache_pressure;
 }
 
 static struct shrinker dqcache_shrinker = {
-	.shrink = shrink_dqcache_memory,
+	.count_objects = dqcache_shrink_count,
+	.scan_objects = dqcache_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
