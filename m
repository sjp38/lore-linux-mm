Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ECFEC6B0023
	for <linux-mm@kvack.org>; Fri, 20 May 2011 08:31:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 917423EE0BC
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:30:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B3E445DF56
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:30:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F3B45DF54
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:30:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 458E21DB803E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:30:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 004471DB8038
	for <linux-mm@kvack.org>; Fri, 20 May 2011 21:30:58 +0900 (JST)
Message-ID: <4DD65EF8.3050401@jp.fujitsu.com>
Date: Fri, 20 May 2011 21:30:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] change shrinker API by passing shrink_control
 struct
References: <4DD5D92B.8030209@jp.fujitsu.com> <BANLkTik3cC9f5M6xB4zpVPpRg8Y_+MtTaw@mail.gmail.com>
In-Reply-To: <BANLkTik3cC9f5M6xB4zpVPpRg8Y_+MtTaw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghan@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

(2011/05/20 12:23), Ying Han wrote:
> On Thu, May 19, 2011 at 7:59 PM, KOSAKI Motohiro<
> kosaki.motohiro@jp.fujitsu.com>  wrote:
>
>>> Hmm, got Nick's email wrong.
>>>
>>> --Ying
>>
>> Ping.
>> Can you please explain current status? When I can see your answer?
>>
>
> The patch has been merged into mmotm-04-29-16-25. Sorry if there is a
> question that I missed ?

I know. I know you haven't fix my pointed issue and you haven't answer
my question over two week. :-/

As far as I can remember now, at least I pointed out

  - nr_slab_to_reclaim is wrong name.
    you misunderstand shrinker->shrink() interface.
  - least-recently-us is typo
  - don't exporse both nr_scanned and nr_slab_to_reclaim.
    Instead, calculate proper argument in shrink_slab.


Andrew, I've fixed it. please apply.


 From 104ad1af66b57e4030b2b3bce5e35d2d3ec29e41 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 20 May 2011 20:54:01 +0900
Subject: [PATCH] vmscan: fix up new shrinker API

Current new shrinker API submission has some easy mistake. Fix it up.

- remove nr_scanned field from shrink_control.
   we don't have to expose vmscan internal to shrinkers.
- rename nr_slab_to_reclaim to nr_to_scan.
   to_reclaim is very wrong name. shrinker API allow shrinker
   don't reclaim an slab object if they were recently accessed.
- typo: least-recently-us

This patch also make do_shrinker_shrink() helper function. It
increase code readability a bit.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
  arch/x86/kvm/mmu.c                   |    2 +-
  drivers/gpu/drm/i915/i915_gem.c      |    2 +-
  drivers/gpu/drm/ttm/ttm_page_alloc.c |    2 +-
  drivers/staging/zcache/zcache.c      |    2 +-
  fs/dcache.c                          |    2 +-
  fs/drop_caches.c                     |    7 ++---
  fs/gfs2/glock.c                      |    2 +-
  fs/inode.c                           |    2 +-
  fs/mbcache.c                         |    2 +-
  fs/nfs/dir.c                         |    2 +-
  fs/quota/dquot.c                     |    2 +-
  fs/xfs/linux-2.6/xfs_buf.c           |    2 +-
  fs/xfs/linux-2.6/xfs_sync.c          |    2 +-
  fs/xfs/quota/xfs_qm.c                |    2 +-
  include/linux/mm.h                   |   12 +++++-----
  mm/memory-failure.c                  |    3 +-
  mm/vmscan.c                          |   36 +++++++++++++++++----------------
  17 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 4cf6c15..bd14bb4 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3549,7 +3549,7 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
  {
  	struct kvm *kvm;
  	struct kvm *kvm_freed = NULL;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;

  	if (nr_to_scan == 0)
  		goto out;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index e4f3f6c..ec3d98c 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4100,7 +4100,7 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
  			     mm.inactive_shrinker);
  	struct drm_device *dev = dev_priv->dev;
  	struct drm_i915_gem_object *obj, *next;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	int cnt;

  	if (!mutex_trylock(&dev->struct_mutex))
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index 02ccf6f..d948575 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -402,7 +402,7 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink,
  	unsigned i;
  	unsigned pool_offset = atomic_add_return(1, &start_pool);
  	struct ttm_page_pool *pool;
-	int shrink_pages = sc->nr_slab_to_reclaim;
+	int shrink_pages = sc->nr_to_scan;

  	pool_offset = pool_offset % NUM_POOLS;
  	/* select start pool in round robin fashion */
diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcache.c
index 135851a..77ac2d4 100644
--- a/drivers/staging/zcache/zcache.c
+++ b/drivers/staging/zcache/zcache.c
@@ -1185,7 +1185,7 @@ static int shrink_zcache_memory(struct shrinker *shrink,
  				struct shrink_control *sc)
  {
  	int ret = -1;
-	int nr = sc->nr_slab_to_reclaim;
+	int nr = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	if (nr >= 0) {
diff --git a/fs/dcache.c b/fs/dcache.c
index f70abf2..8926cd8 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1234,7 +1234,7 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  static int shrink_dcache_memory(struct shrinker *shrink,
  				struct shrink_control *sc)
  {
-	int nr = sc->nr_slab_to_reclaim;
+	int nr = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	if (nr) {
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 440999c..e0a2906 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -42,12 +42,11 @@ static void drop_slab(void)
  	int nr_objects;
  	struct shrink_control shrink = {
  		.gfp_mask = GFP_KERNEL,
-		.nr_scanned = 1000,
  	};

-	do {
-		nr_objects = shrink_slab(&shrink, 1000);
-	} while (nr_objects > 10);
+	do
+		nr_objects = shrink_slab(&shrink, 1000, 1000);
+	while (nr_objects > 10);
  }

  int drop_caches_sysctl_handler(ctl_table *table, int write,
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index f3c9b17..2792a79 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1352,7 +1352,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
  	struct gfs2_glock *gl;
  	int may_demote;
  	int nr_skipped = 0;
-	int nr = sc->nr_slab_to_reclaim;
+	int nr = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;
  	LIST_HEAD(skipped);

diff --git a/fs/inode.c b/fs/inode.c
index ce61a1b..fadba5a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -752,7 +752,7 @@ static void prune_icache(int nr_to_scan)
  static int shrink_icache_memory(struct shrinker *shrink,
  				struct shrink_control *sc)
  {
-	int nr = sc->nr_slab_to_reclaim;
+	int nr = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	if (nr) {
diff --git a/fs/mbcache.c b/fs/mbcache.c
index 19a2666..8c32ef3 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -168,7 +168,7 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
  	struct mb_cache *cache;
  	struct mb_cache_entry *entry, *tmp;
  	int count = 0;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	mb_debug("trying to free %d entries", nr_to_scan);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9dee703..424e477 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2048,7 +2048,7 @@ int nfs_access_cache_shrinker(struct shrinker *shrink,
  	LIST_HEAD(head);
  	struct nfs_inode *nfsi, *next;
  	struct nfs_access_entry *cache;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index b780ee0..5b572c8 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -694,7 +694,7 @@ static void prune_dqcache(int count)
  static int shrink_dqcache_memory(struct shrinker *shrink,
  				 struct shrink_control *sc)
  {
-	int nr = sc->nr_slab_to_reclaim;
+	int nr = sc->nr_to_scan;

  	if (nr) {
  		spin_lock(&dq_list_lock);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 04b9558..ddac2ec 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -1406,7 +1406,7 @@ xfs_buftarg_shrink(
  	struct xfs_buftarg	*btp = container_of(shrink,
  					struct xfs_buftarg, bt_shrinker);
  	struct xfs_buf		*bp;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	LIST_HEAD(dispose);

  	if (!nr_to_scan)
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 3fa9aae..2460114 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -1028,7 +1028,7 @@ xfs_reclaim_inode_shrink(
  	struct xfs_perag *pag;
  	xfs_agnumber_t	ag;
  	int		reclaimable;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
index 2954330..c31a7ae 100644
--- a/fs/xfs/quota/xfs_qm.c
+++ b/fs/xfs/quota/xfs_qm.c
@@ -2012,7 +2012,7 @@ xfs_qm_shake(
  	struct shrink_control *sc)
  {
  	int	ndqused, nfree, n;
-	int nr_to_scan = sc->nr_slab_to_reclaim;
+	int nr_to_scan = sc->nr_to_scan;
  	gfp_t gfp_mask = sc->gfp_mask;

  	if (!kmem_shake_allow(gfp_mask))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72ba1f5..02be595 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1134,19 +1134,18 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
   * We consolidate the values for easier extention later.
   */
  struct shrink_control {
-	unsigned long nr_scanned;
  	gfp_t gfp_mask;

-	/* How many slab objects shrinker() should reclaim */
-	unsigned long nr_slab_to_reclaim;
+	/* How many slab objects shrinker() should scan and try to reclaim */
+	unsigned long nr_to_scan;
  };

  /*
   * A callback you can register to apply pressure to ageable caches.
   *
- * 'sc' is passed shrink_control which includes a count 'nr_slab_to_reclaim'
- * and a 'gfpmask'.  It should look through the least-recently-us
- * 'nr_slab_to_reclaim' entries and attempt to free them up.  It should return
+ * 'sc' is passed shrink_control which includes a count 'nr_to_scan'
+ * and a 'gfpmask'.  It should look through the least-recently-used
+ * 'nr_to_scan' entries and attempt to free them up.  It should return
   * the number of objects which remain in the cache.  If it returns -1, it means
   * it cannot do any scanning at this time (eg. there is a risk of deadlock).
   *
@@ -1613,6 +1612,7 @@ int in_gate_area_no_mm(unsigned long addr);
  int drop_caches_sysctl_handler(struct ctl_table *, int,
  					void __user *, size_t *, loff_t *);
  unsigned long shrink_slab(struct shrink_control *shrink,
+			  unsigned long nr_pages_scanned,
  				unsigned long lru_pages);

  #ifndef CONFIG_MMU
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 341341b..5c8f7e0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -241,10 +241,9 @@ void shake_page(struct page *p, int access)
  		do {
  			struct shrink_control shrink = {
  				.gfp_mask = GFP_KERNEL,
-				.nr_scanned = 1000,
  			};

-			nr = shrink_slab(&shrink, 1000);
+			nr = shrink_slab(&shrink, 1000, 1000);
  			if (page_count(p) == 1)
  				break;
  		} while (nr > 10);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..89e24f7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -201,6 +201,14 @@ void unregister_shrinker(struct shrinker *shrinker)
  }
  EXPORT_SYMBOL(unregister_shrinker);

+static inline int do_shrinker_shrink(struct shrinker *shrinker,
+				     struct shrink_control *sc,
+				     unsigned long nr_to_scan)
+{
+	sc->nr_to_scan = nr_to_scan;
+	return (*shrinker->shrink)(shrinker, sc);
+}
+
  #define SHRINK_BATCH 128
  /*
   * Call the shrink functions to age shrinkable caches
@@ -222,14 +230,14 @@ EXPORT_SYMBOL(unregister_shrinker);
   * Returns the number of slab objects which we shrunk.
   */
  unsigned long shrink_slab(struct shrink_control *shrink,
+			  unsigned long nr_pages_scanned,
  			  unsigned long lru_pages)
  {
  	struct shrinker *shrinker;
  	unsigned long ret = 0;
-	unsigned long scanned = shrink->nr_scanned;

-	if (scanned == 0)
-		scanned = SWAP_CLUSTER_MAX;
+	if (nr_pages_scanned == 0)
+		nr_pages_scanned = SWAP_CLUSTER_MAX;

  	if (!down_read_trylock(&shrinker_rwsem))
  		return 1;	/* Assume we'll be able to shrink next time */
@@ -239,9 +247,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
  		unsigned long total_scan;
  		unsigned long max_pass;

-		shrink->nr_slab_to_reclaim = 0;
-		max_pass = (*shrinker->shrink)(shrinker, shrink);
-		delta = (4 * scanned) / shrinker->seeks;
+		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
+		delta = (4 * nr_pages_scanned) / shrinker->seeks;
  		delta *= max_pass;
  		do_div(delta, lru_pages + 1);
  		shrinker->nr += delta;
@@ -268,11 +275,9 @@ unsigned long shrink_slab(struct shrink_control *shrink,
  			int shrink_ret;
  			int nr_before;

-			shrink->nr_slab_to_reclaim = 0;
-			nr_before = (*shrinker->shrink)(shrinker, shrink);
-			shrink->nr_slab_to_reclaim = this_scan;
-			shrink_ret = (*shrinker->shrink)(shrinker, shrink);
-
+			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
+			shrink_ret = do_shrinker_shrink(shrinker, shrink,
+							this_scan);
  			if (shrink_ret == -1)
  				break;
  			if (shrink_ret < nr_before)
@@ -2086,8 +2091,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
  				lru_pages += zone_reclaimable_pages(zone);
  			}

-			shrink->nr_scanned = sc->nr_scanned;
-			shrink_slab(shrink, lru_pages);
+			shrink_slab(shrink, sc->nr_scanned, lru_pages);
  			if (reclaim_state) {
  				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
  				reclaim_state->reclaimed_slab = 0;
@@ -2488,8 +2492,7 @@ loop_again:
  					end_zone, 0))
  				shrink_zone(priority, zone, &sc);
  			reclaim_state->reclaimed_slab = 0;
-			shrink.nr_scanned = sc.nr_scanned;
-			nr_slab = shrink_slab(&shrink, lru_pages);
+			nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
  			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
  			total_scanned += sc.nr_scanned;

@@ -3057,7 +3060,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
  	}

  	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	shrink.nr_scanned = sc.nr_scanned;
  	if (nr_slab_pages0 > zone->min_slab_pages) {
  		/*
  		 * shrink_slab() does not currently allow us to determine how
@@ -3073,7 +3075,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
  			unsigned long lru_pages = zone_reclaimable_pages(zone);

  			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(&shrink, lru_pages))
+			if (!shrink_slab(&shrink, sc.nr_scanned, lru_pages))
  				break;

  			/* Freed enough memory */
-- 
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
