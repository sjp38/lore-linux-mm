Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 73BC26B0071
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:25 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 19/25] fs: convert fs shrinkers to new scan/count API
Date: Fri,  7 Jun 2013 00:34:52 +0400
Message-Id: <1370550898-26711-20-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Adrian Hunter <adrian.hunter@intel.com>

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

[ v11: fix coding style ]
[ glommer: fixes for ext4, ubifs, nfs, cifs and glock. Fixes are
  needed mainly due to new code merged in the tree ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Artem Bityutskiy <artem.bityutskiy@linux.intel.com>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
CC: Adrian Hunter <adrian.hunter@intel.com>
---
 fs/ext4/extents_status.c | 30 ++++++++++++++++++------------
 fs/gfs2/glock.c          | 28 +++++++++++++++++-----------
 fs/gfs2/main.c           |  3 ++-
 fs/gfs2/quota.c          | 14 ++++++++------
 fs/gfs2/quota.h          |  4 +++-
 fs/mbcache.c             | 47 ++++++++++++++++++++++++++---------------------
 fs/nfs/dir.c             | 14 +++++++++++---
 fs/nfs/internal.h        |  4 +++-
 fs/nfs/super.c           |  3 ++-
 fs/nfsd/nfscache.c       | 31 ++++++++++++++++++++++---------
 fs/quota/dquot.c         | 29 +++++++++++------------------
 fs/ubifs/shrinker.c      | 22 +++++++++++++---------
 fs/ubifs/super.c         |  3 ++-
 fs/ubifs/ubifs.h         |  3 ++-
 14 files changed, 140 insertions(+), 95 deletions(-)

diff --git a/fs/ext4/extents_status.c b/fs/ext4/extents_status.c
index e6941e6..4bce4f0 100644
--- a/fs/ext4/extents_status.c
+++ b/fs/ext4/extents_status.c
@@ -878,20 +878,26 @@ int ext4_es_zeroout(struct inode *inode, struct ext4_extent *ex)
 				     EXTENT_STATUS_WRITTEN);
 }
 
-static int ext4_es_shrink(struct shrinker *shrink, struct shrink_control *sc)
+
+static long ext4_es_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	long nr;
+	struct ext4_sb_info *sbi = container_of(shrink,
+					struct ext4_sb_info, s_es_shrinker);
+
+	nr = percpu_counter_read_positive(&sbi->s_extent_cache_cnt);
+	trace_ext4_es_shrink_enter(sbi->s_sb, sc->nr_to_scan, nr);
+	return nr;
+}
+
+static long ext4_es_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct ext4_sb_info *sbi = container_of(shrink,
 					struct ext4_sb_info, s_es_shrinker);
 	struct ext4_inode_info *ei;
 	struct list_head *cur, *tmp, scanned;
 	int nr_to_scan = sc->nr_to_scan;
-	int ret, nr_shrunk = 0;
-
-	ret = percpu_counter_read_positive(&sbi->s_extent_cache_cnt);
-	trace_ext4_es_shrink_enter(sbi->s_sb, nr_to_scan, ret);
-
-	if (!nr_to_scan)
-		return ret;
+	int ret = 0, nr_shrunk = 0;
 
 	INIT_LIST_HEAD(&scanned);
 
@@ -920,9 +926,8 @@ static int ext4_es_shrink(struct shrinker *shrink, struct shrink_control *sc)
 	list_splice_tail(&scanned, &sbi->s_es_lru);
 	spin_unlock(&sbi->s_es_lru_lock);
 
-	ret = percpu_counter_read_positive(&sbi->s_extent_cache_cnt);
 	trace_ext4_es_shrink_exit(sbi->s_sb, nr_shrunk, ret);
-	return ret;
+	return nr_shrunk;
 }
 
 void ext4_es_register_shrinker(struct super_block *sb)
@@ -932,7 +937,8 @@ void ext4_es_register_shrinker(struct super_block *sb)
 	sbi = EXT4_SB(sb);
 	INIT_LIST_HEAD(&sbi->s_es_lru);
 	spin_lock_init(&sbi->s_es_lru_lock);
-	sbi->s_es_shrinker.shrink = ext4_es_shrink;
+	sbi->s_es_shrinker.scan_objects = ext4_es_scan;
+	sbi->s_es_shrinker.count_objects = ext4_es_count;
 	sbi->s_es_shrinker.seeks = DEFAULT_SEEKS;
 	register_shrinker(&sbi->s_es_shrinker);
 }
@@ -973,7 +979,7 @@ static int __es_try_to_reclaim_extents(struct ext4_inode_info *ei,
 	struct ext4_es_tree *tree = &ei->i_es_tree;
 	struct rb_node *node;
 	struct extent_status *es;
-	int nr_shrunk = 0;
+	long nr_shrunk = 0;
 
 	if (ei->i_es_lru_nr == 0)
 		return 0;
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 3bd2748..a7060a0 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1428,21 +1428,22 @@ __acquires(&lru_lock)
  * gfs2_dispose_glock_lru() above.
  */
 
-static void gfs2_scan_glock_lru(int nr)
+static long gfs2_scan_glock_lru(int nr)
 {
 	struct gfs2_glock *gl;
 	LIST_HEAD(skipped);
 	LIST_HEAD(dispose);
+	long freed = 0;
 
 	spin_lock(&lru_lock);
-	while(nr && !list_empty(&lru_list)) {
+	while ((nr-- >= 0) && !list_empty(&lru_list)) {
 		gl = list_entry(lru_list.next, struct gfs2_glock, gl_lru);
 
 		/* Test for being demotable */
 		if (!test_and_set_bit(GLF_LOCK, &gl->gl_flags)) {
 			list_move(&gl->gl_lru, &dispose);
 			atomic_dec(&lru_count);
-			nr--;
+			freed++;
 			continue;
 		}
 
@@ -1452,23 +1453,28 @@ static void gfs2_scan_glock_lru(int nr)
 	if (!list_empty(&dispose))
 		gfs2_dispose_glock_lru(&dispose);
 	spin_unlock(&lru_lock);
+
+	return freed;
 }
 
-static int gfs2_shrink_glock_memory(struct shrinker *shrink,
-				    struct shrink_control *sc)
+static long gfs2_glock_shrink_scan(struct shrinker *shrink,
+				   struct shrink_control *sc)
 {
-	if (sc->nr_to_scan) {
-		if (!(sc->gfp_mask & __GFP_FS))
-			return -1;
-		gfs2_scan_glock_lru(sc->nr_to_scan);
-	}
+	if (!(sc->gfp_mask & __GFP_FS))
+		return SHRINK_STOP;
+	return gfs2_scan_glock_lru(sc->nr_to_scan);
+}
 
+static long gfs2_glock_shrink_count(struct shrinker *shrink,
+				    struct shrink_control *sc)
+{
 	return vfs_pressure_ratio(atomic_read(&lru_count));
 }
 
 static struct shrinker glock_shrinker = {
-	.shrink = gfs2_shrink_glock_memory,
 	.seeks = DEFAULT_SEEKS,
+	.count_objects = gfs2_glock_shrink_count,
+	.scan_objects = gfs2_glock_shrink_scan,
 };
 
 /**
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
index d550a5d..bb83036 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -75,17 +75,15 @@ static LIST_HEAD(qd_lru_list);
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
-		return -1;
+		return SHRINK_STOP;
 
 	spin_lock(&qd_lru_lock);
 	while (nr_to_scan && !list_empty(&qd_lru_list)) {
@@ -110,10 +108,14 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
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
 	return vfs_pressure_ratio(atomic_read(&qd_lru_count));
 }
 
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index 4f5e6e4..4f61708 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -53,7 +53,9 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(struct shrinker *shrink,
+extern long gfs2_qd_shrink_count(struct shrinker *shrink,
+				 struct shrink_control *sc);
+extern long gfs2_qd_shrink_scan(struct shrinker *shrink,
 				 struct shrink_control *sc);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 5eb0476..dbb9e54 100644
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
@@ -159,17 +147,16 @@ forget:
  * @shrink: (ignored)
  * @sc: shrink_control passed from reclaim
  *
- * Returns the number of objects which are present in the cache.
+ * Returns the number of objects freed.
  */
-static int
-mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
+static long
+mb_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
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
@@ -179,19 +166,37 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
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
+mb_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
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
+
 	return vfs_pressure_ratio(count);
 }
 
+static struct shrinker mb_cache_shrinker = {
+	.count_objects = mb_cache_shrink_count,
+	.scan_objects = mb_cache_shrink_scan,
+	.seeks = DEFAULT_SEEKS,
+};
 
 /*
  * mb_cache_create()  create a new cache
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0d2cdad..b769a06 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1964,17 +1964,18 @@ static void nfs_access_free_list(struct list_head *head)
 	}
 }
 
-int nfs_access_cache_shrinker(struct shrinker *shrink,
-			      struct shrink_control *sc)
+long
+nfs_access_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi, *next;
 	struct nfs_access_entry *cache;
 	int nr_to_scan = sc->nr_to_scan;
 	gfp_t gfp_mask = sc->gfp_mask;
+	long freed = 0;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+		return SHRINK_STOP;
 
 	spin_lock(&nfs_access_lru_lock);
 	list_for_each_entry_safe(nfsi, next, &nfs_access_lru_list, access_cache_inode_lru) {
@@ -1990,6 +1991,7 @@ int nfs_access_cache_shrinker(struct shrinker *shrink,
 				struct nfs_access_entry, lru);
 		list_move(&cache->lru, &head);
 		rb_erase(&cache->rb_node, &nfsi->access_cache);
+		freed++;
 		if (!list_empty(&nfsi->access_cache_entry_lru))
 			list_move_tail(&nfsi->access_cache_inode_lru,
 					&nfs_access_lru_list);
@@ -2004,6 +2006,12 @@ remove_lru_entry:
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
+	return freed;
+}
+
+long
+nfs_access_cache_count(struct shrinker *shrink, struct shrink_control *sc)
+{
 	return vfs_pressure_ratio(atomic_long_read(&nfs_access_nr_entries));
 }
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 91e59a3..9651e20 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -269,7 +269,9 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
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
index 4336d03..06c3d1c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -360,7 +360,8 @@ static void unregister_nfs4_fs(void)
 #endif
 
 static struct shrinker acl_shrinker = {
-	.shrink		= nfs_access_cache_shrinker,
+	.count_objects	= nfs_access_cache_count,
+	.scan_objects	= nfs_access_cache_scan,
 	.seeks		= DEFAULT_SEEKS,
 };
 
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index e76244e..5564c38 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -59,11 +59,14 @@ static unsigned int		longest_chain_cachesize;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 static void	cache_cleaner_func(struct work_struct *unused);
-static int 	nfsd_reply_cache_shrink(struct shrinker *shrink,
-					struct shrink_control *sc);
+static long	nfsd_reply_cache_count(struct shrinker *shrink,
+				       struct shrink_control *sc);
+static long	nfsd_reply_cache_scan(struct shrinker *shrink,
+				      struct shrink_control *sc);
 
 static struct shrinker nfsd_reply_cache_shrinker = {
-	.shrink	= nfsd_reply_cache_shrink,
+	.scan_objects = nfsd_reply_cache_scan,
+	.count_objects = nfsd_reply_cache_count,
 	.seeks	= 1,
 };
 
@@ -232,16 +235,18 @@ nfsd_cache_entry_expired(struct svc_cacherep *rp)
  * Walk the LRU list and prune off entries that are older than RC_EXPIRE.
  * Also prune the oldest ones when the total exceeds the max number of entries.
  */
-static void
+static long
 prune_cache_entries(void)
 {
 	struct svc_cacherep *rp, *tmp;
+	long freed = 0;
 
 	list_for_each_entry_safe(rp, tmp, &lru_head, c_lru) {
 		if (!nfsd_cache_entry_expired(rp) &&
 		    num_drc_entries <= max_drc_entries)
 			break;
 		nfsd_reply_cache_free_locked(rp);
+		freed++;
 	}
 
 	/*
@@ -254,6 +259,7 @@ prune_cache_entries(void)
 		cancel_delayed_work(&cache_cleaner);
 	else
 		mod_delayed_work(system_wq, &cache_cleaner, RC_EXPIRE);
+	return freed;
 }
 
 static void
@@ -264,20 +270,27 @@ cache_cleaner_func(struct work_struct *unused)
 	spin_unlock(&cache_lock);
 }
 
-static int
-nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
+static long
+nfsd_reply_cache_count(struct shrinker *shrink, struct shrink_control *sc)
 {
-	unsigned int num;
+	long num;
 
 	spin_lock(&cache_lock);
-	if (sc->nr_to_scan)
-		prune_cache_entries();
 	num = num_drc_entries;
 	spin_unlock(&cache_lock);
 
 	return num;
 }
 
+static long
+nfsd_reply_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
+{
+	long freed;
+	spin_lock(&cache_lock);
+	freed = prune_cache_entries();
+	spin_unlock(&cache_lock);
+	return freed;
+}
 /*
  * Walk an xdr_buf and get a CRC for at most the first RC_CSUMLEN bytes
  */
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 762b09c..930a1b7 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -687,44 +687,37 @@ int dquot_quota_sync(struct super_block *sb, int type)
 }
 EXPORT_SYMBOL(dquot_quota_sync);
 
-/* Free unused dquots from cache */
-static void prune_dqcache(int count)
+static long
+dqcache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
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
+dqcache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 {
-	int nr = sc->nr_to_scan;
-
-	if (nr) {
-		spin_lock(&dq_list_lock);
-		prune_dqcache(nr);
-		spin_unlock(&dq_list_lock);
-	}
 	return vfs_pressure_ratio(
 	percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]));
 }
 
 static struct shrinker dqcache_shrinker = {
-	.shrink = shrink_dqcache_memory,
+	.count_objects = dqcache_shrink_count,
+	.scan_objects = dqcache_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 9e1d056..e2cf4cb 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -277,19 +277,23 @@ static int kick_a_thread(void)
 	return 0;
 }
 
-int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc)
+long ubifs_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
+
+	/*
+	 * Due to the way UBIFS updates the clean znode counter it may
+	 * temporarily be negative.
+	 */
+	return clean_zn_cnt >= 0 ? clean_zn_cnt : 1;
+}
+
+long ubifs_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	int nr = sc->nr_to_scan;
 	int freed, contention = 0;
 	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
 
-	if (nr == 0)
-		/*
-		 * Due to the way UBIFS updates the clean znode counter it may
-		 * temporarily be negative.
-		 */
-		return clean_zn_cnt >= 0 ? clean_zn_cnt : 1;
-
 	if (!clean_zn_cnt) {
 		/*
 		 * No clean znodes, nothing to reap. All we can do in this case
@@ -316,7 +320,7 @@ int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc)
 
 	if (!freed && contention) {
 		dbg_tnc("freed nothing, but contention");
-		return -1;
+		return SHRINK_STOP;
 	}
 
 out:
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index f21acf0..ff357e0 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -49,7 +49,8 @@ struct kmem_cache *ubifs_inode_slab;
 
 /* UBIFS TNC shrinker description */
 static struct shrinker ubifs_shrinker_info = {
-	.shrink = ubifs_shrinker,
+	.scan_objects = ubifs_shrink_scan,
+	.count_objects = ubifs_shrink_count,
 	.seeks = DEFAULT_SEEKS,
 };
 
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index b2babce..bcdafcc 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1624,7 +1624,8 @@ int ubifs_tnc_start_commit(struct ubifs_info *c, struct ubifs_zbranch *zroot);
 int ubifs_tnc_end_commit(struct ubifs_info *c);
 
 /* shrinker.c */
-int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc);
+long ubifs_shrink_scan(struct shrinker *shrink, struct shrink_control *sc);
+long ubifs_shrink_count(struct shrinker *shrink, struct shrink_control *sc);
 
 /* commit.c */
 int ubifs_bg_thread(void *info);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
