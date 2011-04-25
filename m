Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AAE4A8D0040
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:22:56 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 2/2] change shrinker API by passing shrink_control struct
Date: Mon, 25 Apr 2011 10:22:14 -0700
Message-Id: <1303752134-4856-3-git-send-email-yinghan@google.com>
In-Reply-To: <1303752134-4856-1-git-send-email-yinghan@google.com>
References: <1303752134-4856-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The patch changes each shrinkers API by consolidating the existing
parameters into shrink_control struct. This will simplify any further
features added w/o touching each file of shrinker.

changelog v2..v1:
1. replace the scan_control to shrink_control, and only pass the set
of values down to the shrinker.

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/kvm/mmu.c                   |    3 ++-
 drivers/gpu/drm/i915/i915_gem.c      |    5 ++---
 drivers/gpu/drm/ttm/ttm_page_alloc.c |    4 +++-
 drivers/staging/zcache/zcache.c      |    5 ++++-
 fs/dcache.c                          |    8 ++++++--
 fs/gfs2/glock.c                      |    5 ++++-
 fs/inode.c                           |    6 +++++-
 fs/mbcache.c                         |   10 ++++++----
 fs/nfs/dir.c                         |    5 ++++-
 fs/nfs/internal.h                    |    2 +-
 fs/quota/dquot.c                     |    5 ++++-
 fs/xfs/linux-2.6/xfs_buf.c           |    4 ++--
 fs/xfs/linux-2.6/xfs_sync.c          |    5 +++--
 fs/xfs/quota/xfs_qm.c                |    7 ++++---
 include/linux/mm.h                   |   15 +++++++++------
 mm/vmscan.c                          |   11 +++++++----
 net/sunrpc/auth.c                    |    4 +++-
 17 files changed, 69 insertions(+), 35 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index b6a9963..e194cb6 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3579,10 +3579,11 @@ static int kvm_mmu_remove_some_alloc_mmu_pages(struct kvm *kvm,
 	return kvm_mmu_prepare_zap_page(kvm, page, invalid_list);
 }
 
-static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct kvm *kvm;
 	struct kvm *kvm_freed = NULL;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
 
 	if (nr_to_scan == 0)
 		goto out;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 4aaf6cd..99afb5b 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4105,9 +4105,7 @@ i915_gpu_is_active(struct drm_device *dev)
 }
 
 static int
-i915_gem_inactive_shrink(struct shrinker *shrinker,
-			 int nr_to_scan,
-			 gfp_t gfp_mask)
+i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
 {
 	struct drm_i915_private *dev_priv =
 		container_of(shrinker,
@@ -4115,6 +4113,7 @@ i915_gem_inactive_shrink(struct shrinker *shrinker,
 			     mm.inactive_shrinker);
 	struct drm_device *dev = dev_priv->dev;
 	struct drm_i915_gem_object *obj, *next;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
 	int cnt;
 
 	if (!mutex_trylock(&dev->struct_mutex))
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index 737a2a2..2f2376b 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -395,12 +395,14 @@ static int ttm_pool_get_num_unused_pages(void)
 /**
  * Callback for mm to request pool to reduce number of page held.
  */
-static int ttm_pool_mm_shrink(struct shrinker *shrink, int shrink_pages, gfp_t gfp_mask)
+static int ttm_pool_mm_shrink(struct shrinker *shrink,
+			      struct shrink_control *sc)
 {
 	static atomic_t start_pool = ATOMIC_INIT(0);
 	unsigned i;
 	unsigned pool_offset = atomic_add_return(1, &start_pool);
 	struct ttm_page_pool *pool;
+	int shrink_pages = sc->nr_slab_to_reclaim;
 
 	pool_offset = pool_offset % NUM_POOLS;
 	/* select start pool in round robin fashion */
diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcache.c
index b8a2b30..135851a 100644
--- a/drivers/staging/zcache/zcache.c
+++ b/drivers/staging/zcache/zcache.c
@@ -1181,9 +1181,12 @@ static bool zcache_freeze;
 /*
  * zcache shrinker interface (only useful for ephemeral pages, so zbud only)
  */
-static int shrink_zcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_zcache_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
 {
 	int ret = -1;
+	int nr = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	if (nr >= 0) {
 		if (!(gfp_mask & __GFP_FS))
diff --git a/fs/dcache.c b/fs/dcache.c
index 2f65679..47566ab 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1237,7 +1237,7 @@ void shrink_dcache_parent(struct dentry * parent)
 EXPORT_SYMBOL(shrink_dcache_parent);
 
 /*
- * Scan `nr' dentries and return the number which remain.
+ * Scan `sc->nr_slab_to_reclaim' dentries and return the number which remain.
  *
  * We need to avoid reentering the filesystem if the caller is performing a
  * GFP_NOFS allocation attempt.  One example deadlock is:
@@ -1248,8 +1248,12 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_dcache_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
 {
+	int nr = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
+
 	if (nr) {
 		if (!(gfp_mask & __GFP_FS))
 			return -1;
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index bc36aef..e196ece 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1348,11 +1348,14 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
 }
 
 
-static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int gfs2_shrink_glock_memory(struct shrinker *shrink,
+				    struct shrink_control *sc)
 {
 	struct gfs2_glock *gl;
 	int may_demote;
 	int nr_skipped = 0;
+	int nr = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 	LIST_HEAD(skipped);
 
 	if (nr == 0)
diff --git a/fs/inode.c b/fs/inode.c
index f4018ab..e65d00a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -703,8 +703,12 @@ static void prune_icache(int nr_to_scan)
  * This function is passed the number of inodes to scan, and it returns the
  * total number of remaining possibly-reclaimable inodes.
  */
-static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_icache_memory(struct shrinker *shrink,
+				struct shrink_control *sc)
 {
+	int nr = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
+
 	if (nr) {
 		/*
 		 * Nasty deadlock avoidance.  We may hold various FS locks,
diff --git a/fs/mbcache.c b/fs/mbcache.c
index a25444ab..3ba68e4 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -90,7 +90,8 @@ static DEFINE_SPINLOCK(mb_cache_spinlock);
  * What the mbcache registers as to get shrunk dynamically.
  */
 
-static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask);
+static int mb_cache_shrink_fn(struct shrinker *shrink,
+			      struct shrink_control *sc);
 
 static struct shrinker mb_cache_shrinker = {
 	.shrink = mb_cache_shrink_fn,
@@ -156,18 +157,19 @@ forget:
  * gets low.
  *
  * @shrink: (ignored)
- * @nr_to_scan: Number of objects to scan
- * @gfp_mask: (ignored)
+ * @sc: shrink_control passed from reclaim
  *
  * Returns the number of objects which are present in the cache.
  */
 static int
-mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
 {
 	LIST_HEAD(free_list);
 	struct mb_cache *cache;
 	struct mb_cache_entry *entry, *tmp;
 	int count = 0;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	mb_debug("trying to free %d entries", nr_to_scan);
 	spin_lock(&mb_cache_spinlock);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2c3eb33..27aa4a4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1962,11 +1962,14 @@ static void nfs_access_free_list(struct list_head *head)
 	}
 }
 
-int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+int nfs_access_cache_shrinker(struct shrinker *shrink,
+			      struct shrink_control *sc)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi, *next;
 	struct nfs_access_entry *cache;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
 		return (nr_to_scan == 0) ? 0 : -1;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cf9fdbd..fabb489 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -218,7 +218,7 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
-					int nr_to_scan, gfp_t gfp_mask);
+					struct shrink_control *sc);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index a2a622e..09d8750 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -696,8 +696,11 @@ static void prune_dqcache(int count)
  * This is called from kswapd when we think we need some
  * more memory
  */
-static int shrink_dqcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_dqcache_memory(struct shrinker *shrink,
+				 struct shrink_control *sc)
 {
+	int nr = sc->nr_slab_to_reclaim;
+
 	if (nr) {
 		spin_lock(&dq_list_lock);
 		prune_dqcache(nr);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 5cb230f..a1d6e62 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -1542,12 +1542,12 @@ restart:
 int
 xfs_buftarg_shrink(
 	struct shrinker		*shrink,
-	int			nr_to_scan,
-	gfp_t			mask)
+	struct shrink_control	*sc)
 {
 	struct xfs_buftarg	*btp = container_of(shrink,
 					struct xfs_buftarg, bt_shrinker);
 	struct xfs_buf		*bp;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
 	LIST_HEAD(dispose);
 
 	if (!nr_to_scan)
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 6c10f1d..6749bd3 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -998,13 +998,14 @@ xfs_reclaim_inodes(
 static int
 xfs_reclaim_inode_shrink(
 	struct shrinker	*shrink,
-	int		nr_to_scan,
-	gfp_t		gfp_mask)
+	struct shrink_control *sc)
 {
 	struct xfs_mount *mp;
 	struct xfs_perag *pag;
 	xfs_agnumber_t	ag;
 	int		reclaimable;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
 	if (nr_to_scan) {
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
index 254ee06..8e7991c 100644
--- a/fs/xfs/quota/xfs_qm.c
+++ b/fs/xfs/quota/xfs_qm.c
@@ -60,7 +60,7 @@ STATIC void	xfs_qm_list_destroy(xfs_dqlist_t *);
 
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(struct shrinker *, int, gfp_t);
+STATIC int	xfs_qm_shake(struct shrinker *, struct shrink_control *);
 
 static struct shrinker xfs_qm_shaker = {
 	.shrink = xfs_qm_shake,
@@ -2016,10 +2016,11 @@ xfs_qm_shake_freelist(
 STATIC int
 xfs_qm_shake(
 	struct shrinker	*shrink,
-	int		nr_to_scan,
-	gfp_t		gfp_mask)
+	struct shrink_control *sc)
 {
 	int	ndqused, nfree, n;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	if (!kmem_shake_allow(gfp_mask))
 		return 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7a2f657..abc13ea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1137,16 +1137,19 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 struct shrink_control {
 	unsigned long nr_scanned;
 	gfp_t gfp_mask;
+
+	/* How many slab objects shrinker() should reclaim */
+	unsigned long nr_slab_to_reclaim;
 };
 
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
- * look through the least-recently-used 'nr_to_scan' entries and
- * attempt to free them up.  It should return the number of objects
- * which remain in the cache.  If it returns -1, it means it cannot do
- * any scanning at this time (eg. there is a risk of deadlock).
+ * 'sc' is passed shrink_control which includes a count 'nr_slab_to_reclaim'
+ * and a 'gfpmask'.  It should look through the least-recently-us
+ * 'nr_slab_to_reclaim' entries and attempt to free them up.  It should return
+ * the number of objects which remain in the cache.  If it returns -1, it means
+ * it cannot do any scanning at this time (eg. there is a risk of deadlock).
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
@@ -1155,7 +1158,7 @@ struct shrink_control {
  * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
+	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	int seeks;	/* seeks to recreate an obj */
 
 	/* These are for internal use */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 40edf73..1241e87 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -239,7 +239,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		unsigned long total_scan;
 		unsigned long max_pass;
 
-		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
+		shrink->nr_slab_to_reclaim = 0;
+		max_pass = (*shrinker->shrink)(shrinker, shrink);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
@@ -267,9 +268,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			int shrink_ret;
 			int nr_before;
 
-			nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
-			shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
-								gfp_mask);
+			shrink->nr_slab_to_reclaim = 0;
+			nr_before = (*shrinker->shrink)(shrinker, shrink);
+			shrink->nr_slab_to_reclaim = this_scan;
+			shrink_ret = (*shrinker->shrink)(shrinker, shrink);
+
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 67e3127..287dd25 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -326,10 +326,12 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
  * Run memory cache shrinker.
  */
 static int
-rpcauth_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
 {
 	LIST_HEAD(free);
 	int res;
+	int nr_to_scan = sc->nr_slab_to_reclaim;
+	gfp_t gfp_mask = sc->gfp_mask;
 
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
 		return (nr_to_scan == 0) ? 0 : -1;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
