Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A00456B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 23:16:09 -0400 (EDT)
Message-Id: <20100624030733.676440935@suse.de>
Date: Thu, 24 Jun 2010 13:03:02 +1000
From: npiggin@suse.de
Subject: [patch 50/52] mm: implement per-zone shrinker
References: <20100624030212.676457061@suse.de>
Content-Disposition: inline; filename=mm-zone-shrinker.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Stultz <johnstul@us.ibm.com>, Frank Mayhar <fmayhar@google.com>
List-ID: <linux-mm.kvack.org>

Allow the shrinker to do per-zone shrinking. This means it is called for
each zone scanned. The shrinker is now completely responsible for calculating
and batching (given helpers), which provides better flexibility.

Finding the ratio of objects to scan requires scaling the ratio of pagecache
objects scanned. By passing down both the per-zone and the global reclaimable
pages, per-zone caches and global caches can be calculated correctly.

Finally, add some fixed-point scaling to the ratio, which helps calculations.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/dcache.c        |    2 
 fs/drop_caches.c   |    2 
 fs/inode.c         |    2 
 fs/mbcache.c       |    4 -
 fs/nfs/dir.c       |    2 
 fs/nfs/internal.h  |    2 
 fs/quota/dquot.c   |    2 
 include/linux/mm.h |    6 +-
 mm/vmscan.c        |  131 ++++++++++++++---------------------------------------
 9 files changed, 47 insertions(+), 106 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -999,16 +999,19 @@ static inline void sync_mm_rss(struct ta
  * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrinker {
-	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
-	int seeks;	/* seeks to recreate an obj */
-
+	int (*shrink)(struct zone *zone, unsigned long scanned, unsigned long total,
+					unsigned long global, gfp_t gfp_mask);
 	/* These are for internal use */
 	struct list_head list;
-	long nr;	/* objs pending delete */
 };
-#define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
+#define DEFAULT_SEEKS	(128UL*2) /* A good number if you don't know better. */
+#define SHRINK_BATCH	128	/* A good number if you don't know better */
 extern void register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
+extern void shrinker_add_scan(unsigned long *dst,
+				unsigned long scanned, unsigned long total,
+				unsigned long objects, unsigned int ratio);
+extern unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch);
 
 int vma_wants_writenotify(struct vm_area_struct *vma);
 
@@ -1422,8 +1425,7 @@ int in_gate_area_no_task(unsigned long a
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+void shrink_all_slab(void);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -160,7 +160,6 @@ static unsigned long zone_nr_lru_pages(s
  */
 void register_shrinker(struct shrinker *shrinker)
 {
-	shrinker->nr = 0;
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
@@ -178,7 +177,38 @@ void unregister_shrinker(struct shrinker
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-#define SHRINK_BATCH 128
+void shrinker_add_scan(unsigned long *dst,
+			unsigned long scanned, unsigned long total,
+			unsigned long objects, unsigned int ratio)
+{
+	unsigned long long delta;
+
+	delta = (unsigned long long)scanned * objects * ratio;
+	do_div(delta, total + 1);
+	delta /= (128ULL / 4ULL);
+
+	/*
+	 * Avoid risking looping forever due to too large nr value:
+	 * never try to free more than twice the estimate number of
+	 * freeable entries.
+	 */
+	*dst += delta;
+
+	if (*dst > objects)
+		*dst = objects;
+}
+EXPORT_SYMBOL(shrinker_add_scan);
+
+unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch)
+{
+	unsigned long nr = ACCESS_ONCE(*dst);
+	if (nr < batch)
+		return 0;
+	*dst = nr - batch;
+	return batch;
+}
+EXPORT_SYMBOL(shrinker_do_scan);
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -198,8 +228,8 @@ EXPORT_SYMBOL(unregister_shrinker);
  *
  * Returns the number of slab objects which we shrunk.
  */
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+static unsigned long shrink_slab(struct zone *zone, unsigned long scanned, unsigned long total,
+			unsigned long global, gfp_t gfp_mask)
 {
 	struct shrinker *shrinker;
 	unsigned long ret = 0;
@@ -211,55 +241,25 @@ unsigned long shrink_slab(unsigned long
 		return 1;	/* Assume we'll be able to shrink next time */
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		unsigned long long delta;
-		unsigned long total_scan;
-		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
-
-		delta = (4 * scanned) / shrinker->seeks;
-		delta *= max_pass;
-		do_div(delta, lru_pages + 1);
-		shrinker->nr += delta;
-		if (shrinker->nr < 0) {
-			printk(KERN_ERR "shrink_slab: %pF negative objects to "
-			       "delete nr=%ld\n",
-			       shrinker->shrink, shrinker->nr);
-			shrinker->nr = max_pass;
-		}
-
-		/*
-		 * Avoid risking looping forever due to too large nr value:
-		 * never try to free more than twice the estimate number of
-		 * freeable entries.
-		 */
-		if (shrinker->nr > max_pass * 2)
-			shrinker->nr = max_pass * 2;
-
-		total_scan = shrinker->nr;
-		shrinker->nr = 0;
-
-		while (total_scan >= SHRINK_BATCH) {
-			long this_scan = SHRINK_BATCH;
-			int shrink_ret;
-			int nr_before;
-
-			nr_before = (*shrinker->shrink)(0, gfp_mask);
-			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
-			if (shrink_ret == -1)
-				break;
-			if (shrink_ret < nr_before)
-				ret += nr_before - shrink_ret;
-			count_vm_events(SLABS_SCANNED, this_scan);
-			total_scan -= this_scan;
-
-			cond_resched();
-		}
-
-		shrinker->nr += total_scan;
+		(*shrinker->shrink)(zone, scanned, total, global, gfp_mask);
 	}
 	up_read(&shrinker_rwsem);
 	return ret;
 }
 
+void shrink_all_slab(void)
+{
+	struct zone *zone;
+	unsigned long nr;
+
+again:
+	nr = 0;
+	for_each_zone(zone)
+		nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
+	if (nr >= 10)
+		goto again;
+}
+
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -1660,18 +1660,23 @@ static void set_lumpy_reclaim_mode(int p
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+		struct scan_control *sc, unsigned long global_lru_pages)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_scanned = sc->nr_scanned;
+	unsigned long lru_pages = 0;
 
 	get_scan_count(zone, sc, nr, priority);
 
 	set_lumpy_reclaim_mode(priority, sc);
 
+	if (scanning_global_lru(sc))
+		lru_pages = zone_reclaimable_pages(zone);
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1696,8 +1701,6 @@ static void shrink_zone(int priority, st
 			break;
 	}
 
-	sc->nr_reclaimed = nr_reclaimed;
-
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
@@ -1705,6 +1708,23 @@ static void shrink_zone(int priority, st
 	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
+	/*
+	 * Don't shrink slabs when reclaiming memory from
+	 * over limit cgroups
+	 */
+	if (scanning_global_lru(sc)) {
+		struct reclaim_state *reclaim_state = current->reclaim_state;
+
+		shrink_slab(zone, sc->nr_scanned - nr_scanned,
+			lru_pages, global_lru_pages, sc->gfp_mask);
+		if (reclaim_state) {
+			nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
+	}
+
+	sc->nr_reclaimed = nr_reclaimed;
+
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
@@ -1725,7 +1745,7 @@ static void shrink_zone(int priority, st
  * scan then give up on it.
  */
 static bool shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+		struct scan_control *sc, unsigned long global_lru_pages)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
@@ -1756,7 +1776,7 @@ static bool shrink_zones(int priority, s
 							priority);
 		}
 
-		shrink_zone(priority, zone, sc);
+		shrink_zone(priority, zone, sc, global_lru_pages);
 		all_unreclaimable = false;
 	}
 	return all_unreclaimable;
@@ -1784,7 +1804,6 @@ static unsigned long do_try_to_free_page
 	int priority;
 	bool all_unreclaimable;
 	unsigned long total_scanned = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
@@ -1796,6 +1815,7 @@ static unsigned long do_try_to_free_page
 
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
+
 	/*
 	 * mem_cgroup will not do shrink_slab.
 	 */
@@ -1813,18 +1833,8 @@ static unsigned long do_try_to_free_page
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		all_unreclaimable = shrink_zones(priority, zonelist, sc);
-		/*
-		 * Don't shrink slabs when reclaiming memory from
-		 * over limit cgroups
-		 */
-		if (scanning_global_lru(sc)) {
-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
-			if (reclaim_state) {
-				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
-		}
+		all_unreclaimable = shrink_zones(priority, zonelist,
+						sc, lru_pages);
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			goto out;
@@ -1930,7 +1940,7 @@ unsigned long mem_cgroup_shrink_node_zon
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone(0, zone, &sc);
+	shrink_zone(0, zone, &sc, zone_reclaimable_pages(zone));
 	return sc.nr_reclaimed;
 }
 
@@ -2012,7 +2022,6 @@ static unsigned long balance_pgdat(pg_da
 	int priority;
 	int i;
 	unsigned long total_scanned;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
@@ -2100,7 +2109,6 @@ loop_again:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab;
 			int nid, zid;
 
 			if (!populated_zone(zone))
@@ -2127,16 +2135,11 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order,
 					8*high_wmark_pages(zone), end_zone, 0))
-				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				shrink_zone(priority, zone, &sc, lru_pages);
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
 				continue;
-			if (nr_slab == 0 &&
-			    zone->pages_scanned >= (zone_reclaimable_pages(zone) * 6))
+			if (zone->pages_scanned >= (zone_reclaimable_pages(zone) * 6))
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and
@@ -2610,34 +2613,15 @@ static int __zone_reclaim(struct zone *z
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
 			note_zone_scanning_priority(zone, priority);
-			shrink_zone(priority, zone, &sc);
+			shrink_zone(priority, zone, &sc,
+					zone_reclaimable_pages(zone));
 			priority--;
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
 	}
 
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	if (slab_reclaimable > zone->min_slab_pages) {
-		/*
-		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we take the current
-		 * number of slab pages and shake the slab until it is reduced
-		 * by the same nr_pages that we used for reclaiming unmapped
-		 * pages.
-		 *
-		 * Note that shrink_slab will free memory on all zones and may
-		 * take a long time.
-		 */
-		while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE) >
-				slab_reclaimable - nr_pages)
-			;
-
-		/*
-		 * Update nr_reclaimed by the number of slab pages we
-		 * reclaimed from this zone.
-		 */
-		sc.nr_reclaimed += slab_reclaimable -
-			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+		/* XXX: don't shrink slab in shrink_zone if we're under this */
 	}
 
 	p->reclaim_state = NULL;
Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c
+++ linux-2.6/fs/dcache.c
@@ -748,20 +748,26 @@ again2:
  *
  * This function may fail to free any resources if all the dentries are in use.
  */
-static void prune_dcache(int count)
+static void prune_dcache(struct zone *zone, unsigned long scanned,
+			unsigned long total, gfp_t gfp_mask)
+
 {
+	unsigned long nr_to_scan;
 	struct super_block *sb, *n;
 	int w_count;
-	int unused = dentry_stat.nr_unused;
 	int prune_ratio;
-	int pruned;
+	int count, pruned;
 
-	if (unused == 0 || count == 0)
+	shrinker_add_scan(&nr_to_scan, scanned, total, dentry_stat.nr_unused,
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
+done:
+	count = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (dentry_stat.nr_unused == 0 || count == 0)
 		return;
-	if (count >= unused)
+	if (count >= dentry_stat.nr_unused)
 		prune_ratio = 1;
 	else
-		prune_ratio = unused / count;
+		prune_ratio = dentry_stat.nr_unused / count;
 	spin_lock(&sb_lock);
 	list_for_each_entry_safe(sb, n, &super_blocks, s_list) {
 		if (list_empty(&sb->s_instances))
@@ -810,6 +816,10 @@ static void prune_dcache(int count)
 			break;
 	}
 	spin_unlock(&sb_lock);
+	if (count <= 0) {
+		cond_resched();
+		goto done;
+	}
 }
 
 /**
@@ -1176,19 +1186,15 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dcache_memory(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
-	if (nr) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-		prune_dcache(nr);
-	}
-	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
+	prune_dcache(zone, scanned, global, gfp_mask);
+	return 0;
 }
 
 static struct shrinker dcache_shrinker = {
 	.shrink = shrink_dcache_memory,
-	.seeks = DEFAULT_SEEKS,
 };
 
 /**
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -527,7 +527,7 @@ EXPORT_SYMBOL(invalidate_inodes);
  * If the inode has metadata buffers attached to mapping->private_list then
  * try to remove them.
  */
-static void prune_icache(int nr_to_scan)
+static void prune_icache(struct zone *zone, unsigned long nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	unsigned long reap = 0;
@@ -597,24 +597,28 @@ again:
  * This function is passed the number of inodes to scan, and it returns the
  * total number of remaining possibly-reclaimable inodes.
  */
-static int shrink_icache_memory(int nr, gfp_t gfp_mask)
+static int shrink_icache_memory(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
-	if (nr) {
-		/*
-		 * Nasty deadlock avoidance.  We may hold various FS locks,
-		 * and we don't want to recurse into the FS that called us
-		 * in clear_inode() and friends..
-		 */
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-		prune_icache(nr);
+	static unsigned long nr_to_scan;
+	unsigned long nr;
+
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			inodes_stat.nr_unused,
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
+	if (!(gfp_mask & __GFP_FS))
+	       return 0;
+
+	while ((nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH))) {
+		prune_icache(zone, nr);
+		cond_resched();
 	}
-	return inodes_stat.nr_unused / 100 * sysctl_vfs_cache_pressure;
+
+	return 0;
 }
 
 static struct shrinker icache_shrinker = {
 	.shrink = shrink_icache_memory,
-	.seeks = DEFAULT_SEEKS,
 };
 
 static void __wait_on_freeing_inode(struct inode *inode);
Index: linux-2.6/fs/mbcache.c
===================================================================
--- linux-2.6.orig/fs/mbcache.c
+++ linux-2.6/fs/mbcache.c
@@ -115,11 +115,12 @@ mb_cache_indexes(struct mb_cache *cache)
  * What the mbcache registers as to get shrunk dynamically.
  */
 
-static int mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask);
+static int
+mb_cache_shrink_fn(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask);
 
 static struct shrinker mb_cache_shrinker = {
 	.shrink = mb_cache_shrink_fn,
-	.seeks = DEFAULT_SEEKS,
 };
 
 static inline int
@@ -197,11 +198,14 @@ forget:
  * Returns the number of objects which are present in the cache.
  */
 static int
-mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
+mb_cache_shrink_fn(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
 	LIST_HEAD(free_list);
 	struct list_head *l, *ltmp;
-	int count = 0;
+	unsigned long count = 0;
+	unsigned long nr;
 
 	spin_lock(&mb_cache_spinlock);
 	list_for_each(l, &mb_cache_list) {
@@ -211,28 +215,38 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t
 			  atomic_read(&cache->c_entry_count));
 		count += atomic_read(&cache->c_entry_count);
 	}
+	shrinker_add_scan(&nr_to_scan, scanned, global, count,
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
 	mb_debug("trying to free %d entries", nr_to_scan);
-	if (nr_to_scan == 0) {
+
+again:
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr) {
 		spin_unlock(&mb_cache_spinlock);
-		goto out;
+		return 0;
 	}
-	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
+	while (!list_empty(&mb_cache_lru_list)) {
 		struct mb_cache_entry *ce =
 			list_entry(mb_cache_lru_list.next,
 				   struct mb_cache_entry, e_lru_list);
 		list_move_tail(&ce->e_lru_list, &free_list);
 		__mb_cache_entry_unhash(ce);
+		cond_resched_lock(&mb_cache_spinlock);
+		if (!--nr)
+			break;
 	}
 	spin_unlock(&mb_cache_spinlock);
 	list_for_each_safe(l, ltmp, &free_list) {
 		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
 						   e_lru_list), gfp_mask);
 	}
-out:
-	return (count / 100) * sysctl_vfs_cache_pressure;
+	if (!nr) {
+		spin_lock(&mb_cache_spinlock);
+		goto again;
+	}
+	return 0;
 }
 
-
 /*
  * mb_cache_create()  create a new cache
  *
Index: linux-2.6/fs/nfs/dir.c
===================================================================
--- linux-2.6.orig/fs/nfs/dir.c
+++ linux-2.6/fs/nfs/dir.c
@@ -1709,21 +1709,31 @@ static void nfs_access_free_list(struct
 	}
 }
 
-int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
+int nfs_access_cache_shrinker(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
 	LIST_HEAD(head);
-	struct nfs_inode *nfsi;
 	struct nfs_access_entry *cache;
-
-	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+	unsigned long nr;
 
 	spin_lock(&nfs_access_lru_lock);
-	list_for_each_entry(nfsi, &nfs_access_lru_list, access_cache_inode_lru) {
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			atomic_long_read(&nfs_access_nr_entries),
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
+	if (!(gfp_mask & __GFP_FS) || nr_to_scan < SHRINK_BATCH) {
+		spin_unlock(&nfs_access_lru_lock);
+		return 0;
+	}
+	nr = ACCESS_ONCE(nr_to_scan);
+	nr_to_scan = 0;
+
+	while (nr-- && !list_empty(&nfs_access_lru_list)) {
+		struct nfs_inode *nfsi;
 		struct inode *inode;
 
-		if (nr_to_scan-- == 0)
-			break;
+		nfsi = list_entry(nfs_access_lru_list.next,
+				struct nfs_inode, access_cache_inode_lru);
 		inode = &nfsi->vfs_inode;
 		spin_lock(&inode->i_lock);
 		if (list_empty(&nfsi->access_cache_entry_lru))
@@ -1743,10 +1753,11 @@ remove_lru_entry:
 			smp_mb__after_clear_bit();
 		}
 		spin_unlock(&inode->i_lock);
+		cond_resched_lock(&nfs_access_lru_lock);
 	}
 	spin_unlock(&nfs_access_lru_lock);
 	nfs_access_free_list(&head);
-	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
+	return 0;
 }
 
 static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
Index: linux-2.6/fs/nfs/internal.h
===================================================================
--- linux-2.6.orig/fs/nfs/internal.h
+++ linux-2.6/fs/nfs/internal.h
@@ -205,7 +205,8 @@ extern struct rpc_procinfo nfs4_procedur
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
 /* dir.c */
-extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
+extern int nfs_access_cache_shrinker(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
Index: linux-2.6/fs/quota/dquot.c
===================================================================
--- linux-2.6.orig/fs/quota/dquot.c
+++ linux-2.6/fs/quota/dquot.c
@@ -655,7 +655,7 @@ int dquot_quota_sync(struct super_block
 EXPORT_SYMBOL(dquot_quota_sync);
 
 /* Free unused dquots from cache */
-static void prune_dqcache(int count)
+static void prune_dqcache(unsigned long count)
 {
 	struct list_head *head;
 	struct dquot *dquot;
@@ -676,21 +676,28 @@ static void prune_dqcache(int count)
  * This is called from kswapd when we think we need some
  * more memory
  */
-static int shrink_dqcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dqcache_memory(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
-	if (nr) {
+	static unsigned long nr_to_scan;
+	unsigned long nr;
+
+	shrinker_add_scan(&nr_to_scan, scanned, total,
+	       percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS]),
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
+
+	while ((nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH))) {
 		spin_lock(&dq_list_lock);
 		prune_dqcache(nr);
 		spin_unlock(&dq_list_lock);
+		cond_resched();
 	}
-	return ((unsigned)
-		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
-		/100) * sysctl_vfs_cache_pressure;
+
+	return 0;
 }
 
 static struct shrinker dqcache_shrinker = {
 	.shrink = shrink_dqcache_memory,
-	.seeks = DEFAULT_SEEKS,
 };
 
 /*
Index: linux-2.6/fs/drop_caches.c
===================================================================
--- linux-2.6.orig/fs/drop_caches.c
+++ linux-2.6/fs/drop_caches.c
@@ -38,11 +38,7 @@ static void drop_pagecache_sb(struct sup
 
 static void drop_slab(void)
 {
-	int nr_objects;
-
-	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
-	} while (nr_objects > 10);
+	shrink_all_slab();
 }
 
 int drop_caches_sysctl_handler(ctl_table *table, int write,
Index: linux-2.6/mm/memory-failure.c
===================================================================
--- linux-2.6.orig/mm/memory-failure.c
+++ linux-2.6/mm/memory-failure.c
@@ -229,14 +229,8 @@ void shake_page(struct page *p, int acce
 	 * Only all shrink_slab here (which would also
 	 * shrink other caches) if access is not potentially fatal.
 	 */
-	if (access) {
-		int nr;
-		do {
-			nr = shrink_slab(1000, GFP_KERNEL, 1000);
-			if (page_count(p) == 0)
-				break;
-		} while (nr > 10);
-	}
+	if (access)
+		shrink_all_slab();
 }
 EXPORT_SYMBOL_GPL(shake_page);
 
Index: linux-2.6/arch/x86/kvm/mmu.c
===================================================================
--- linux-2.6.orig/arch/x86/kvm/mmu.c
+++ linux-2.6/arch/x86/kvm/mmu.c
@@ -2924,14 +2924,29 @@ static int kvm_mmu_remove_some_alloc_mmu
 	return kvm_mmu_zap_page(kvm, page) + 1;
 }
 
-static int mmu_shrink(int nr_to_scan, gfp_t gfp_mask)
+static int mmu_shrink(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
 	struct kvm *kvm;
 	struct kvm *kvm_freed = NULL;
-	int cache_count = 0;
+	unsigned long cache_count = 0;
 
 	spin_lock(&kvm_lock);
+	list_for_each_entry(kvm, &vm_list, vm_list) {
+		cache_count += kvm->arch.n_alloc_mmu_pages -
+			 kvm->arch.n_free_mmu_pages;
+	}
 
+	shrinker_add_scan(&nr_to_scan, scanned, global, cache_count,
+			DEFAULT_SEEKS*10);
+
+done:
+	cache_count = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!cache_count) {
+		spin_unlock(&kvm_lock);
+		return 0;
+	}
 	list_for_each_entry(kvm, &vm_list, vm_list) {
 		int npages, idx, freed_pages;
 
@@ -2939,28 +2954,24 @@ static int mmu_shrink(int nr_to_scan, gf
 		spin_lock(&kvm->mmu_lock);
 		npages = kvm->arch.n_alloc_mmu_pages -
 			 kvm->arch.n_free_mmu_pages;
-		cache_count += npages;
-		if (!kvm_freed && nr_to_scan > 0 && npages > 0) {
+		if (!kvm_freed && npages > 0) {
 			freed_pages = kvm_mmu_remove_some_alloc_mmu_pages(kvm);
-			cache_count -= freed_pages;
 			kvm_freed = kvm;
 		}
-		nr_to_scan--;
-
 		spin_unlock(&kvm->mmu_lock);
 		srcu_read_unlock(&kvm->srcu, idx);
+
+		if (!--cache_count)
+			break;
 	}
 	if (kvm_freed)
 		list_move_tail(&kvm_freed->vm_list, &vm_list);
-
-	spin_unlock(&kvm_lock);
-
-	return cache_count;
+	cond_resched_lock(&kvm_lock);
+	goto done;
 }
 
 static struct shrinker mmu_shrinker = {
 	.shrink = mmu_shrink,
-	.seeks = DEFAULT_SEEKS * 10,
 };
 
 static void mmu_destroy_caches(void)
Index: linux-2.6/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_gem.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_gem.c
@@ -4977,41 +4977,46 @@ i915_gpu_is_active(struct drm_device *de
 }
 
 static int
-i915_gem_shrink(int nr_to_scan, gfp_t gfp_mask)
+i915_gem_shrink(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	unsigned long cnt = 0;
 	drm_i915_private_t *dev_priv, *next_dev;
 	struct drm_i915_gem_object *obj_priv, *next_obj;
-	int cnt = 0;
 	int would_deadlock = 1;
 
 	/* "fast-path" to count number of available objects */
-	if (nr_to_scan == 0) {
-		spin_lock(&shrink_list_lock);
-		list_for_each_entry(dev_priv, &shrink_list, mm.shrink_list) {
-			struct drm_device *dev = dev_priv->dev;
+	spin_lock(&shrink_list_lock);
+	list_for_each_entry(dev_priv, &shrink_list, mm.shrink_list) {
+		struct drm_device *dev = dev_priv->dev;
 
-			if (mutex_trylock(&dev->struct_mutex)) {
-				list_for_each_entry(obj_priv,
-						    &dev_priv->mm.inactive_list,
-						    list)
-					cnt++;
-				mutex_unlock(&dev->struct_mutex);
-			}
+		if (mutex_trylock(&dev->struct_mutex)) {
+			list_for_each_entry(obj_priv,
+					    &dev_priv->mm.inactive_list,
+					    list)
+				cnt++;
+			mutex_unlock(&dev->struct_mutex);
 		}
-		spin_unlock(&shrink_list_lock);
-
-		return (cnt / 100) * sysctl_vfs_cache_pressure;
 	}
+	shrinker_add_scan(&nr_to_scan, scanned, global, cnt,
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
 
-	spin_lock(&shrink_list_lock);
-
+done:
+	cnt = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
 rescan:
+	if (!cnt) {
+		spin_unlock(&shrink_list_lock);
+		return 0;
+	}
+
 	/* first scan for clean buffers */
+	/* XXX: this probably needs list_safe_reset_next */
 	list_for_each_entry_safe(dev_priv, next_dev,
 				 &shrink_list, mm.shrink_list) {
 		struct drm_device *dev = dev_priv->dev;
 
-		if (! mutex_trylock(&dev->struct_mutex))
+		if (!mutex_trylock(&dev->struct_mutex))
 			continue;
 
 		spin_unlock(&shrink_list_lock);
@@ -5025,8 +5030,8 @@ rescan:
 					 list) {
 			if (i915_gem_object_is_purgeable(obj_priv)) {
 				i915_gem_object_unbind(&obj_priv->base);
-				if (--nr_to_scan <= 0)
-					break;
+				if (!--cnt)
+					goto done;
 			}
 		}
 
@@ -5034,9 +5039,6 @@ rescan:
 		mutex_unlock(&dev->struct_mutex);
 
 		would_deadlock = 0;
-
-		if (nr_to_scan <= 0)
-			break;
 	}
 
 	/* second pass, evict/count anything still on the inactive list */
@@ -5052,11 +5054,9 @@ rescan:
 		list_for_each_entry_safe(obj_priv, next_obj,
 					 &dev_priv->mm.inactive_list,
 					 list) {
-			if (nr_to_scan > 0) {
-				i915_gem_object_unbind(&obj_priv->base);
-				nr_to_scan--;
-			} else
-				cnt++;
+			i915_gem_object_unbind(&obj_priv->base);
+			if (!--cnt)
+				goto done;
 		}
 
 		spin_lock(&shrink_list_lock);
@@ -5065,7 +5065,7 @@ rescan:
 		would_deadlock = 0;
 	}
 
-	if (nr_to_scan) {
+	if (cnt) {
 		int active = 0;
 
 		/*
@@ -5096,18 +5096,11 @@ rescan:
 	}
 
 	spin_unlock(&shrink_list_lock);
-
-	if (would_deadlock)
-		return -1;
-	else if (cnt > 0)
-		return (cnt / 100) * sysctl_vfs_cache_pressure;
-	else
-		return 0;
+	return 0;
 }
 
 static struct shrinker shrinker = {
 	.shrink = i915_gem_shrink,
-	.seeks = DEFAULT_SEEKS,
 };
 
 __init void
Index: linux-2.6/drivers/gpu/drm/ttm/ttm_page_alloc.c
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ linux-2.6/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -395,30 +395,38 @@ static int ttm_pool_get_num_unused_pages
 /**
  * Callback for mm to request pool to reduce number of page held.
  */
-static int ttm_pool_mm_shrink(int shrink_pages, gfp_t gfp_mask)
+static int ttm_pool_mm_shrink(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
-	static atomic_t start_pool = ATOMIC_INIT(0);
-	unsigned i;
-	unsigned pool_offset = atomic_add_return(1, &start_pool);
-	struct ttm_page_pool *pool;
+	static unsigned long nr_to_scan;
+	unsigned long shrink_pages;
 
-	pool_offset = pool_offset % NUM_POOLS;
-	/* select start pool in round robin fashion */
-	for (i = 0; i < NUM_POOLS; ++i) {
-		unsigned nr_free = shrink_pages;
-		if (shrink_pages == 0)
-			break;
-		pool = &_manager.pools[(i + pool_offset)%NUM_POOLS];
-		shrink_pages = ttm_page_pool_free(pool, nr_free);
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			ttm_pool_get_num_unused_pages(),
+			SHRINK_FIXED);
+
+	while ((shrink_pages = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH))) {
+		static atomic_t start_pool = ATOMIC_INIT(0);
+		unsigned pool_offset = atomic_add_return(1, &start_pool);
+		struct ttm_page_pool *pool;
+		unsigned i;
+
+		pool_offset = pool_offset % NUM_POOLS;
+		/* select start pool in round robin fashion */
+		for (i = 0; i < NUM_POOLS; ++i) {
+			unsigned nr_free = shrink_pages;
+			if (shrink_pages == 0)
+				break;
+			pool = &_manager.pools[(i + pool_offset)%NUM_POOLS];
+			shrink_pages = ttm_page_pool_free(pool, nr_free);
+		}
 	}
-	/* return estimated number of unused pages in pool */
-	return ttm_pool_get_num_unused_pages();
+	return 0;
 }
 
 static void ttm_pool_mm_shrink_init(struct ttm_pool_manager *manager)
 {
 	manager->mm_shrink.shrink = &ttm_pool_mm_shrink;
-	manager->mm_shrink.seeks = 1;
 	register_shrinker(&manager->mm_shrink);
 }
 
Index: linux-2.6/fs/gfs2/glock.c
===================================================================
--- linux-2.6.orig/fs/gfs2/glock.c
+++ linux-2.6/fs/gfs2/glock.c
@@ -1349,18 +1349,27 @@ void gfs2_glock_complete(struct gfs2_glo
 }
 
 
-static int gfs2_shrink_glock_memory(int nr, gfp_t gfp_mask)
+static int gfs2_shrink_glock_memory(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	unsigned long nr;
 	struct gfs2_glock *gl;
 	int may_demote;
 	int nr_skipped = 0;
 	LIST_HEAD(skipped);
 
-	if (nr == 0)
-		goto out;
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			atomic_read(&lru_count),
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
 
 	if (!(gfp_mask & __GFP_FS))
-		return -1;
+		return 0;
+
+done:
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr)
+		return 0;
 
 	spin_lock(&lru_lock);
 	while(nr && !list_empty(&lru_list)) {
@@ -1392,13 +1401,13 @@ static int gfs2_shrink_glock_memory(int
 	list_splice(&skipped, &lru_list);
 	atomic_add(nr_skipped, &lru_count);
 	spin_unlock(&lru_lock);
-out:
-	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
+	if (!nr)
+		goto done;
+	return 0;
 }
 
 static struct shrinker glock_shrinker = {
 	.shrink = gfs2_shrink_glock_memory,
-	.seeks = DEFAULT_SEEKS,
 };
 
 /**
Index: linux-2.6/fs/gfs2/main.c
===================================================================
--- linux-2.6.orig/fs/gfs2/main.c
+++ linux-2.6/fs/gfs2/main.c
@@ -27,7 +27,6 @@
 
 static struct shrinker qd_shrinker = {
 	.shrink = gfs2_shrink_qd_memory,
-	.seeks = DEFAULT_SEEKS,
 };
 
 static void gfs2_init_inode_once(void *foo)
Index: linux-2.6/fs/gfs2/quota.c
===================================================================
--- linux-2.6.orig/fs/gfs2/quota.c
+++ linux-2.6/fs/gfs2/quota.c
@@ -43,6 +43,7 @@
 #include <linux/buffer_head.h>
 #include <linux/sort.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
 #include <linux/bio.h>
 #include <linux/gfs2_ondisk.h>
 #include <linux/kthread.h>
@@ -77,16 +78,25 @@ static LIST_HEAD(qd_lru_list);
 static atomic_t qd_lru_count = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(qd_lru_lock);
 
-int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask)
+int gfs2_shrink_qd_memory(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	unsigned long nr;
 	struct gfs2_quota_data *qd;
 	struct gfs2_sbd *sdp;
 
-	if (nr == 0)
-		goto out;
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			atomic_read(&qd_lru_count),
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
 
 	if (!(gfp_mask & __GFP_FS))
-		return -1;
+		return 0;
+
+done:
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr)
+		return 0;
 
 	spin_lock(&qd_lru_lock);
 	while (nr && !list_empty(&qd_lru_list)) {
@@ -113,9 +123,9 @@ int gfs2_shrink_qd_memory(int nr, gfp_t
 		nr--;
 	}
 	spin_unlock(&qd_lru_lock);
-
-out:
-	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
+	if (!nr)
+		goto done;
+	return 0;
 }
 
 static u64 qd2offset(struct gfs2_quota_data *qd)
Index: linux-2.6/fs/gfs2/quota.h
===================================================================
--- linux-2.6.orig/fs/gfs2/quota.h
+++ linux-2.6/fs/gfs2/quota.h
@@ -51,7 +51,8 @@ static inline int gfs2_quota_lock_check(
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask);
+extern int gfs2_shrink_qd_memory(struct zone *zone, unsigned long scanned,
+                unsigned long total, unsigned long global, gfp_t gfp_mask);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
 #endif /* __QUOTA_DOT_H__ */
Index: linux-2.6/fs/nfs/super.c
===================================================================
--- linux-2.6.orig/fs/nfs/super.c
+++ linux-2.6/fs/nfs/super.c
@@ -350,7 +350,6 @@ static const struct super_operations nfs
 
 static struct shrinker acl_shrinker = {
 	.shrink		= nfs_access_cache_shrinker,
-	.seeks		= DEFAULT_SEEKS,
 };
 
 /*
Index: linux-2.6/fs/ubifs/shrinker.c
===================================================================
--- linux-2.6.orig/fs/ubifs/shrinker.c
+++ linux-2.6/fs/ubifs/shrinker.c
@@ -277,13 +277,16 @@ static int kick_a_thread(void)
 	return 0;
 }
 
-int ubifs_shrinker(int nr, gfp_t gfp_mask)
+int ubifs_shrinker(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	unsigned long nr;
 	int freed, contention = 0;
 	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
 
-	if (nr == 0)
-		return clean_zn_cnt;
+	shrinker_add_scan(&nr_to_scan, scanned, global, clean_zn_cnt,
+			DEFAULT_SEEKS);
 
 	if (!clean_zn_cnt) {
 		/*
@@ -297,24 +300,28 @@ int ubifs_shrinker(int nr, gfp_t gfp_mas
 		return kick_a_thread();
 	}
 
+done:
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr)
+		return 0;
+
 	freed = shrink_tnc_trees(nr, OLD_ZNODE_AGE, &contention);
 	if (freed >= nr)
-		goto out;
+		goto done;
 
 	dbg_tnc("not enough old znodes, try to free young ones");
 	freed += shrink_tnc_trees(nr - freed, YOUNG_ZNODE_AGE, &contention);
 	if (freed >= nr)
-		goto out;
+		goto done;
 
 	dbg_tnc("not enough young znodes, free all");
 	freed += shrink_tnc_trees(nr - freed, 0, &contention);
+	if (freed >= nr)
+		goto done;
 
-	if (!freed && contention) {
-		dbg_tnc("freed nothing, but contention");
-		return -1;
-	}
+	if (!freed && contention)
+		nr_to_scan += nr;
 
-out:
-	dbg_tnc("%d znodes were freed, requested %d", freed, nr);
+	dbg_tnc("%d znodes were freed, requested %lu", freed, nr);
 	return freed;
 }
Index: linux-2.6/fs/ubifs/super.c
===================================================================
--- linux-2.6.orig/fs/ubifs/super.c
+++ linux-2.6/fs/ubifs/super.c
@@ -50,7 +50,6 @@ struct kmem_cache *ubifs_inode_slab;
 /* UBIFS TNC shrinker description */
 static struct shrinker ubifs_shrinker_info = {
 	.shrink = ubifs_shrinker,
-	.seeks = DEFAULT_SEEKS,
 };
 
 /**
Index: linux-2.6/fs/ubifs/ubifs.h
===================================================================
--- linux-2.6.orig/fs/ubifs/ubifs.h
+++ linux-2.6/fs/ubifs/ubifs.h
@@ -1575,7 +1575,8 @@ int ubifs_tnc_start_commit(struct ubifs_
 int ubifs_tnc_end_commit(struct ubifs_info *c);
 
 /* shrinker.c */
-int ubifs_shrinker(int nr_to_scan, gfp_t gfp_mask);
+int ubifs_shrinker(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask);
 
 /* commit.c */
 int ubifs_bg_thread(void *info);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_buf.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_buf.c
@@ -45,11 +45,11 @@
 
 static kmem_zone_t *xfs_buf_zone;
 STATIC int xfsbufd(void *);
-STATIC int xfsbufd_wakeup(int, gfp_t);
+STATIC int xfsbufd_wakeup(struct zone *,
+		unsigned long, unsigned long, unsigned long, gfp_t);
 STATIC void xfs_buf_delwri_queue(xfs_buf_t *, int);
 static struct shrinker xfs_buf_shake = {
 	.shrink = xfsbufd_wakeup,
-	.seeks = DEFAULT_SEEKS,
 };
 
 static struct workqueue_struct *xfslogd_workqueue;
@@ -340,7 +340,7 @@ _xfs_buf_lookup_pages(
 					__func__, gfp_mask);
 
 			XFS_STATS_INC(xb_page_retries);
-			xfsbufd_wakeup(0, gfp_mask);
+			xfsbufd_wakeup(NULL, 0, 0, 0, gfp_mask);
 			congestion_wait(BLK_RW_ASYNC, HZ/50);
 			goto retry;
 		}
@@ -1762,8 +1762,11 @@ xfs_buf_runall_queues(
 
 STATIC int
 xfsbufd_wakeup(
-	int			priority,
-	gfp_t			mask)
+	struct zone		*zone,
+	unsigned long		scanned,
+	unsigned long		total,
+	unsigned long		global,
+	gfp_t			gfp_mask)
 {
 	xfs_buftarg_t		*btp;
 
Index: linux-2.6/fs/xfs/linux-2.6/xfs_sync.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_sync.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_sync.c
@@ -838,43 +838,52 @@ static struct rw_semaphore xfs_mount_lis
 
 static int
 xfs_reclaim_inode_shrink(
-	int		nr_to_scan,
+	struct zone	*zone,
+	unsigned long	scanned,
+	unsigned long	total,
+	unsigned long	global,
 	gfp_t		gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	int		nr;
 	struct xfs_mount *mp;
 	struct xfs_perag *pag;
 	xfs_agnumber_t	ag;
-	int		reclaimable = 0;
-
-	if (nr_to_scan) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-
-		down_read(&xfs_mount_list_lock);
-		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
-			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
-					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
-			if (nr_to_scan <= 0)
-				break;
-		}
-		up_read(&xfs_mount_list_lock);
-	}
+	unsigned long	nr_reclaimable = 0;
 
 	down_read(&xfs_mount_list_lock);
 	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
 		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
 			pag = xfs_perag_get(mp, ag);
-			reclaimable += pag->pag_ici_reclaimable;
+			nr_reclaimable += pag->pag_ici_reclaimable;
 			xfs_perag_put(pag);
 		}
 	}
+	shrinker_add_scan(&nr_to_scan, scanned, global, nr_reclaimable,
+				DEFAULT_SEEKS);
+	if (!(gfp_mask & __GFP_FS)) {
+		up_read(&xfs_mount_list_lock);
+		return 0;
+	}
+
+done:
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr) {
+		up_read(&xfs_mount_list_lock);
+		return 0;
+	}
+	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
+		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
+				XFS_ICI_RECLAIM_TAG, 1, &nr);
+		if (nr <= 0)
+			goto done;
+	}
 	up_read(&xfs_mount_list_lock);
-	return reclaimable;
+	return 0;
 }
 
 static struct shrinker xfs_inode_shrinker = {
 	.shrink = xfs_reclaim_inode_shrink,
-	.seeks = DEFAULT_SEEKS,
 };
 
 void __init
Index: linux-2.6/fs/xfs/quota/xfs_qm.c
===================================================================
--- linux-2.6.orig/fs/xfs/quota/xfs_qm.c
+++ linux-2.6/fs/xfs/quota/xfs_qm.c
@@ -69,11 +69,11 @@ STATIC void	xfs_qm_list_destroy(xfs_dqli
 
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(int, gfp_t);
+STATIC int	xfs_qm_shake(struct zone *, unsigned long, unsigned long,
+			unsigned long, gfp_t);
 
 static struct shrinker xfs_qm_shaker = {
 	.shrink = xfs_qm_shake,
-	.seeks = DEFAULT_SEEKS,
 };
 
 #ifdef DEBUG
@@ -2119,7 +2119,12 @@ xfs_qm_shake_freelist(
  */
 /* ARGSUSED */
 STATIC int
-xfs_qm_shake(int nr_to_scan, gfp_t gfp_mask)
+xfs_qm_shake(
+	struct zone	*zone,
+	unsigned long	scanned,
+	unsigned long	total,
+	unsigned long	global,
+	gfp_t		gfp_mask)
 {
 	int	ndqused, nfree, n;
 
@@ -2140,7 +2145,9 @@ xfs_qm_shake(int nr_to_scan, gfp_t gfp_m
 	ndqused *= xfs_Gqm->qm_dqfree_ratio;	/* target # of free dquots */
 	n = nfree - ndqused - ndquot;		/* # over target */
 
-	return xfs_qm_shake_freelist(MAX(nfree, n));
+	xfs_qm_shake_freelist(MAX(nfree, n));
+
+	return 0;
 }
 
 
Index: linux-2.6/net/sunrpc/auth.c
===================================================================
--- linux-2.6.orig/net/sunrpc/auth.c
+++ linux-2.6/net/sunrpc/auth.c
@@ -227,8 +227,8 @@ EXPORT_SYMBOL_GPL(rpcauth_destroy_credca
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
  */
-static int
-rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
+static void
+rpcauth_prune_expired(struct list_head *free, unsigned long nr_to_scan)
 {
 	spinlock_t *cache_lock;
 	struct rpc_cred *cred, *next;
@@ -244,7 +244,7 @@ rpcauth_prune_expired(struct list_head *
 		 */
 		if (time_in_range(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
-			return 0;
+			break;
 
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
@@ -260,27 +260,36 @@ rpcauth_prune_expired(struct list_head *
 		}
 		spin_unlock(cache_lock);
 	}
-	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 /*
  * Run memory cache shrinker.
  */
 static int
-rpcauth_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
+rpcauth_cache_shrinker(struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global, gfp_t gfp_mask)
 {
+	static unsigned long nr_to_scan;
+	unsigned long nr;
 	LIST_HEAD(free);
-	int res;
 
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			number_cred_unused,
+			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
 	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+		return 0;
+again:
 	if (list_empty(&cred_unused))
 		return 0;
+	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
+	if (!nr)
+       		return 0;
 	spin_lock(&rpc_credcache_lock);
-	res = rpcauth_prune_expired(&free, nr_to_scan);
+	rpcauth_prune_expired(&free, nr);
 	spin_unlock(&rpc_credcache_lock);
 	rpcauth_destroy_credlist(&free);
-	return res;
+	cond_resched();
+	goto again;
 }
 
 /*
@@ -584,7 +593,6 @@ rpcauth_uptodatecred(struct rpc_task *ta
 
 static struct shrinker rpc_cred_shrinker = {
 	.shrink = rpcauth_cache_shrinker,
-	.seeks = DEFAULT_SEEKS,
 };
 
 void __init rpcauth_init_module(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
