Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC3F6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 23:35:27 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] Pass priority to shrink_slab
Date: Wed, 17 Nov 2010 20:34:51 -0800
Message-Id: <1290054891-6097-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pass the reclaim priority down to the shrink_slab() which passes to the
shrink_icache_memory() for inode cache. It helps the situation when
shrink_slab() is being too agressive, it removes the inode as well as all
the pages associated with the inode. Especially when single inode has lots
of pages points to it. The application encounters performance hit when
that happens.

The problem was observed on some workload we run, where it has small number
of large files. Page reclaim won't blow away the inode which is pinned by
dentry which in turn is pinned by open file descriptor. But if the application
is openning and closing the fds, it has the chance to trigger the issue.

I have a script which reproduce the issue. The test is creating 1500 empty
files and one big file in a cgroup. Then it starts adding memory pressure
in the cgroup. Both before/after the patch we see the slab drops (inode) in
slabinfo but the big file clean pages being preserves only after the change.
---
 arch/x86/kvm/mmu.c              |    3 ++-
 drivers/gpu/drm/i915/i915_gem.c |    3 ++-
 fs/dcache.c                     |    3 ++-
 fs/drop_caches.c                |    2 +-
 fs/gfs2/glock.c                 |    3 ++-
 fs/gfs2/quota.c                 |    3 ++-
 fs/gfs2/quota.h                 |    3 ++-
 fs/inode.c                      |   22 +++++++++++++++++++---
 fs/mbcache.c                    |    7 +++++--
 fs/nfs/dir.c                    |    3 ++-
 fs/nfs/internal.h               |    3 ++-
 fs/quota/dquot.c                |    3 ++-
 fs/ubifs/shrinker.c             |    3 ++-
 fs/ubifs/ubifs.h                |    3 ++-
 fs/xfs/linux-2.6/xfs_buf.c      |    7 ++++---
 fs/xfs/linux-2.6/xfs_sync.c     |    3 ++-
 fs/xfs/quota/xfs_qm.c           |    5 +++--
 include/linux/mm.h              |    5 +++--
 mm/vmscan.c                     |   21 ++++++++++++++-------
 net/sunrpc/auth.c               |    3 ++-
 20 files changed, 75 insertions(+), 33 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 311f6da..ef76e13 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3108,7 +3108,8 @@ static int kvm_mmu_remove_some_alloc_mmu_pages(struct kvm *kvm,
 	return kvm_mmu_prepare_zap_page(kvm, page, invalid_list);
 }
 
-static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask,
+			int priority)
 {
 	struct kvm *kvm;
 	struct kvm *kvm_freed = NULL;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 90b1d67..e449b07 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4900,7 +4900,8 @@ i915_gpu_is_active(struct drm_device *dev)
 }
 
 static int
-i915_gem_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+i915_gem_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask,
+		int priority)
 {
 	drm_i915_private_t *dev_priv, *next_dev;
 	struct drm_i915_gem_object *obj_priv, *next_obj;
diff --git a/fs/dcache.c b/fs/dcache.c
index 83293be..370620c 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -898,7 +898,8 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask,
+				int priority)
 {
 	if (nr) {
 		if (!(gfp_mask & __GFP_FS))
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 2195c21..4302fb9 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -38,7 +38,7 @@ static void drop_slab(void)
 	int nr_objects;
 
 	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
+		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000, 0);
 	} while (nr_objects > 10);
 }
 
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 9adf8f9..44733be 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1381,7 +1381,8 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
 }
 
 
-static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr,
+					gfp_t gfp_mask, int priority)
 {
 	struct gfs2_glock *gl;
 	int may_demote;
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 1bc6b56..2e43a58 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -77,7 +77,8 @@ static LIST_HEAD(qd_lru_list);
 static atomic_t qd_lru_count = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(qd_lru_lock);
 
-int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask,
+			  int priority)
 {
 	struct gfs2_quota_data *qd;
 	struct gfs2_sbd *sdp;
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index e7d236c..85f1049 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -51,7 +51,8 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask);
+extern int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr,
+				gfp_t gfp_mask, int priority);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
 #endif /* __QUOTA_DOT_H__ */
diff --git a/fs/inode.c b/fs/inode.c
index 8646433..22a81a2 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -445,7 +445,7 @@ static int can_unuse(struct inode *inode)
  * If the inode has metadata buffers attached to mapping->private_list then
  * try to remove them.
  */
-static void prune_icache(int nr_to_scan)
+static void prune_icache(int nr_to_scan, int priority)
 {
 	LIST_HEAD(freeable);
 	int nr_pruned = 0;
@@ -466,6 +466,21 @@ static void prune_icache(int nr_to_scan)
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
+
+		/*
+		 * Removing an inode with pages in its mapping can
+		 * inadvertantly remove large amounts of page cache,
+		 * possibly belonging to a node not in nodemask, but
+		 * may be necessary in order to free up memory in the
+		 * inode's node.
+		 *
+		 * Only do this when priority hits 0.
+		 */
+		if (priority > 0 && inode->i_data.nrpages) {
+			list_move(&inode->i_list, &inode_unused);
+			continue;
+		}
+
 		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
 			__iget(inode);
 			spin_unlock(&inode_lock);
@@ -506,7 +521,8 @@ static void prune_icache(int nr_to_scan)
  * This function is passed the number of inodes to scan, and it returns the
  * total number of remaining possibly-reclaimable inodes.
  */
-static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask,
+				int priority)
 {
 	if (nr) {
 		/*
@@ -516,7 +532,7 @@ static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 		 */
 		if (!(gfp_mask & __GFP_FS))
 			return -1;
-		prune_icache(nr);
+		prune_icache(nr, priority);
 	}
 	return (inodes_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 9344474..eec98c6 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -102,7 +102,8 @@ static DEFINE_SPINLOCK(mb_cache_spinlock);
  * What the mbcache registers as to get shrunk dynamically.
  */
 
-static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask);
+static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan,
+				gfp_t gfp_mask, int priority);
 
 static struct shrinker mb_cache_shrinker = {
 	.shrink = mb_cache_shrink_fn,
@@ -170,11 +171,13 @@ forget:
  * @shrink: (ignored)
  * @nr_to_scan: Number of objects to scan
  * @gfp_mask: (ignored)
+ * @priority: (ignored)
  *
  * Returns the number of objects which are present in the cache.
  */
 static int
-mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan,
+			gfp_t gfp_mask, int priority)
 {
 	LIST_HEAD(free_list);
 	struct mb_cache *cache;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e257172..f59b6e7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1708,7 +1708,8 @@ static void nfs_access_free_list(struct list_head *head)
 	}
 }
 
-int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan,
+				gfp_t gfp_mask, int priority)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c961bc9..ad2656f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -206,7 +206,8 @@ void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
-					int nr_to_scan, gfp_t gfp_mask);
+					int nr_to_scan, gfp_t gfp_mask,
+					int priority);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index aad1316..77fb00f 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -692,7 +692,8 @@ static void prune_dqcache(int count)
  * This is called from kswapd when we think we need some
  * more memory
  */
-static int shrink_dqcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static int shrink_dqcache_memory(struct shrinker *shrink, int nr,
+				gfp_t gfp_mask, int priority)
 {
 	if (nr) {
 		spin_lock(&dq_list_lock);
diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 0b20111..dbd0128 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -277,7 +277,8 @@ static int kick_a_thread(void)
 	return 0;
 }
 
-int ubifs_shrinker(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+int ubifs_shrinker(struct shrinker *shrink, int nr, gfp_t gfp_mask,
+			int priority)
 {
 	int freed, contention = 0;
 	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 0c9876b..a2dbb42 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1575,7 +1575,8 @@ int ubifs_tnc_start_commit(struct ubifs_info *c, struct ubifs_zbranch *zroot);
 int ubifs_tnc_end_commit(struct ubifs_info *c);
 
 /* shrinker.c */
-int ubifs_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask);
+int ubifs_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask,
+		   int priority);
 
 /* commit.c */
 int ubifs_bg_thread(void *info);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 286e36e..5ff5f91 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -44,7 +44,7 @@
 
 static kmem_zone_t *xfs_buf_zone;
 STATIC int xfsbufd(void *);
-STATIC int xfsbufd_wakeup(struct shrinker *, int, gfp_t);
+STATIC int xfsbufd_wakeup(struct shrinker *, int, gfp_t, int);
 STATIC void xfs_buf_delwri_queue(xfs_buf_t *, int);
 static struct shrinker xfs_buf_shake = {
 	.shrink = xfsbufd_wakeup,
@@ -339,7 +339,7 @@ _xfs_buf_lookup_pages(
 					__func__, gfp_mask);
 
 			XFS_STATS_INC(xb_page_retries);
-			xfsbufd_wakeup(NULL, 0, gfp_mask);
+			xfsbufd_wakeup(NULL, 0, gfp_mask, 0);
 			congestion_wait(BLK_RW_ASYNC, HZ/50);
 			goto retry;
 		}
@@ -1734,7 +1734,8 @@ STATIC int
 xfsbufd_wakeup(
 	struct shrinker		*shrink,
 	int			priority,
-	gfp_t			mask)
+	gfp_t			mask,
+	int			priority)
 {
 	xfs_buftarg_t		*btp;
 
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 81976ff..9abb769 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -884,7 +884,8 @@ static int
 xfs_reclaim_inode_shrink(
 	struct shrinker	*shrink,
 	int		nr_to_scan,
-	gfp_t		gfp_mask)
+	gfp_t		gfp_mask,
+	int		priority)
 {
 	struct xfs_mount *mp;
 	struct xfs_perag *pag;
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
index 9a92407..19028ad 100644
--- a/fs/xfs/quota/xfs_qm.c
+++ b/fs/xfs/quota/xfs_qm.c
@@ -62,7 +62,7 @@ STATIC void	xfs_qm_list_destroy(xfs_dqlist_t *);
 
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(struct shrinker *, int, gfp_t);
+STATIC int	xfs_qm_shake(struct shrinker *, int, gfp_t, int);
 
 static struct shrinker xfs_qm_shaker = {
 	.shrink = xfs_qm_shake,
@@ -2115,7 +2115,8 @@ STATIC int
 xfs_qm_shake(
 	struct shrinker	*shrink,
 	int		nr_to_scan,
-	gfp_t		gfp_mask)
+	gfp_t		gfp_mask,
+	int		priority)
 {
 	int	ndqused, nfree, n;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..6e5b649 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1010,7 +1010,8 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
  * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrinker {
-	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
+	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask,
+			int priority);
 	int seeks;	/* seeks to recreate an obj */
 
 	/* These are for internal use */
@@ -1444,7 +1445,7 @@ int in_gate_area_no_task(unsigned long addr);
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+			unsigned long lru_pages, int priority);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5dfabf..e5ddc28 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -202,7 +202,7 @@ EXPORT_SYMBOL(unregister_shrinker);
  * Returns the number of slab objects which we shrunk.
  */
 unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+			unsigned long lru_pages, int priority)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
@@ -218,7 +218,7 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 		unsigned long total_scan;
 		unsigned long max_pass;
 
-		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
+		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask, priority);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
@@ -246,9 +246,10 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			int shrink_ret;
 			int nr_before;
 
-			nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
+			nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask,
+							priority);
 			shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
-								gfp_mask);
+							gfp_mask, priority);
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
@@ -1912,7 +1913,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				lru_pages += zone_reclaimable_pages(zone);
 			}
 
-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
+			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages,
+					priority);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
@@ -2220,7 +2222,7 @@ loop_again:
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
+						lru_pages, priority);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
@@ -2708,11 +2710,13 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Note that shrink_slab will free memory on all zones and may
 		 * take a long time.
 		 */
+		priority = ZONE_RECLAIM_PRIORITY;
 		for (;;) {
 			unsigned long lru_pages = zone_reclaimable_pages(zone);
 
 			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
+			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages,
+					priority))
 				break;
 
 			/* Freed enough memory */
@@ -2720,6 +2724,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 							NR_SLAB_RECLAIMABLE);
 			if (nr_slab_pages1 + nr_pages <= nr_slab_pages0)
 				break;
+
+			if (priority > 0)
+				priority--;
 		}
 
 		/*
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index e9eaaf7..cb11c69 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -326,7 +326,8 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
  * Run memory cache shrinker.
  */
 static int
-rpcauth_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
+rpcauth_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask,
+			int priority)
 {
 	LIST_HEAD(free);
 	int res;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
