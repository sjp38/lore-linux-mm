Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3FEF36B00B0
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 07:32:59 -0500 (EST)
Date: Tue, 9 Nov 2010 23:32:46 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101109123246.GA11477@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'm doing some works that require per-zone shrinkers, I'd like to get
the vmscan part signed off and merged by interested mm people, please.

[And before anybody else kindly suggests per-node shrinkers, please go
back and read all the discussion about this first.]

Patches against Linus's current tree.

--
Allow the shrinker to do per-zone shrinking. This requires adding a zone
argument to the shrinker callback and calling shrinkers for each zone
scanned. The logic somewhat in vmscan code gets simpler: the shrinkers are
invoked for each zone, around the same time as the pagecache scanner.
Zone reclaim needed a bit of surgery to cope with the change, but the
idea is the same.

But all shrinkers are currently global-based, so they need a way to
convert per-zone ratios into global scan ratios. So seeing as we are
changing the shrinker API anyway, let's reorganise it to make it saner.

So the shrinker callback is passed:
- the number of pagecache pages scanned in this zone
- the number of pagecache pages in this zone
- the total number of pagecache pages in all zones to be scanned

The shrinker is now completely responsible for calculating and batching
(given helpers), which provides better flexibility. vmscan helper functions
are provided to accumulate these ratios, and help with batching.

Finally, add some fixed-point scaling to the ratio, which helps rounding.

The old shrinker API remains for unconverted code. There is no urgency
to convert them at once.

Signed-off-by: Nick Piggin <npiggin@kernel.dk>

---
 fs/drop_caches.c    |    6 
 include/linux/mm.h  |   47 ++++++-
 mm/memory-failure.c |   10 -
 mm/vmscan.c         |  341 +++++++++++++++++++++++++++++++++++++---------------
 4 files changed, 297 insertions(+), 107 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2010-11-09 22:11:03.000000000 +1100
+++ linux-2.6/include/linux/mm.h	2010-11-09 22:11:10.000000000 +1100
@@ -1008,6 +1008,10 @@ static inline void sync_mm_rss(struct ta
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
+ * 'shrink_zone' is the new shrinker API. It is to be used in preference
+ * to 'shrink'. One must point to a shrinker function, the other must
+ * be NULL. See 'shrink_slab' for details about the shrink_zone API.
+ *
  * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
  * look through the least-recently-used 'nr_to_scan' entries and
  * attempt to free them up.  It should return the number of objects
@@ -1024,13 +1028,53 @@ struct shrinker {
 	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
 	int seeks;	/* seeks to recreate an obj */
 
+	/*
+	 * shrink_zone - slab shrinker callback for reclaimable objects
+	 * @shrink: this struct shrinker
+	 * @zone: zone to scan
+	 * @scanned: pagecache lru pages scanned in zone
+	 * @total: total pagecache lru pages in zone
+	 * @global: global pagecache lru pages (for zone-unaware shrinkers)
+	 * @flags: shrinker flags
+	 * @gfp_mask: gfp context we are operating within
+	 *
+	 * The shrinkers are responsible for calculating the appropriate
+	 * pressure to apply, batching up scanning (and cond_resched,
+	 * cond_resched_lock etc), and updating events counters including
+	 * count_vm_event(SLABS_SCANNED, nr).
+	 *
+	 * This approach gives flexibility to the shrinkers. They know best how
+	 * to do batching, how much time between cond_resched is appropriate,
+	 * what statistics to increment, etc.
+	 */
+	void (*shrink_zone)(struct shrinker *shrink,
+		struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global,
+		unsigned long flags, gfp_t gfp_mask);
+
 	/* These are for internal use */
 	struct list_head list;
 	long nr;	/* objs pending delete */
 };
+
+/* Constants for use by old shrinker API */
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
+
+/* Constants for use by new shrinker API */
+/*
+ * SHRINK_DEFAULT_SEEKS is shifted by 4 to match an arbitrary constant
+ * in the old shrinker code.
+ */
+#define SHRINK_FACTOR	(128UL) /* Fixed point shift */
+#define SHRINK_DEFAULT_SEEKS	(SHRINK_FACTOR*DEFAULT_SEEKS/4)
+#define SHRINK_BATCH	128	/* A good number if you don't know better */
+
 extern void register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
+extern void shrinker_add_scan(unsigned long *dst,
+				unsigned long scanned, unsigned long total,
+				unsigned long objects, unsigned int ratio);
+extern unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch);
 
 int vma_wants_writenotify(struct vm_area_struct *vma);
 
@@ -1464,8 +1508,7 @@ int in_gate_area_no_task(unsigned long a
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages);
+void shrink_all_slab(struct zone *zone);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-11-09 22:11:03.000000000 +1100
+++ linux-2.6/mm/vmscan.c	2010-11-09 22:11:10.000000000 +1100
@@ -80,6 +80,9 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	int may_swap;
 
+	/* Can slab pages be reclaimed? */
+	int may_reclaim_slab;
+
 	int swappiness;
 
 	int order;
@@ -169,6 +172,8 @@ static unsigned long zone_nr_lru_pages(s
  */
 void register_shrinker(struct shrinker *shrinker)
 {
+	BUG_ON(shrinker->shrink && shrinker->shrink_zone);
+	BUG_ON(!shrinker->shrink && !shrinker->shrink_zone);
 	shrinker->nr = 0;
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
@@ -187,43 +192,101 @@ void unregister_shrinker(struct shrinker
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-#define SHRINK_BATCH 128
 /*
- * Call the shrink functions to age shrinkable caches
+ * shrinker_add_scan - accumulate shrinker scan
+ * @dst: scan counter variable
+ * @scanned: pagecache pages scanned
+ * @total: total pagecache objects
+ * @tot: total objects in this cache
+ * @ratio: ratio of pagecache value to object value
  *
- * Here we assume it costs one seek to replace a lru page and that it also
- * takes a seek to recreate a cache object.  With this in mind we age equal
- * percentages of the lru and ageable caches.  This should balance the seeks
- * generated by these structures.
+ * shrinker_add_scan accumulates a number of objects to scan into @dst,
+ * based on the following ratio:
  *
- * If the vm encountered mapped pages on the LRU it increase the pressure on
- * slab to avoid swapping.
+ * proportion = scanned / total        // proportion of pagecache scanned
+ * obj_prop   = objects * proportion   // same proportion of objects
+ * to_scan    = obj_prop / ratio       // modify by ratio
+ * *dst += (total / scanned)           // accumulate to dst
  *
- * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
+ * The ratio is a fixed point integer with a factor SHRINK_FACTOR.
+ * Higher ratios give objects higher value.
  *
- * `lru_pages' represents the number of on-LRU pages in all the zones which
- * are eligible for the caller's allocation attempt.  It is used for balancing
- * slab reclaim versus page reclaim.
+ * @dst is also fixed point, so cannot be used as a simple count.
+ * shrinker_do_scan will take care of that for us.
  *
- * Returns the number of slab objects which we shrunk.
+ * There is no synchronisation here, which is fine really. A rare lost
+ * update is no huge deal in reclaim code.
  */
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
-			unsigned long lru_pages)
+void shrinker_add_scan(unsigned long *dst,
+			unsigned long scanned, unsigned long total,
+			unsigned long objects, unsigned int ratio)
 {
-	struct shrinker *shrinker;
-	unsigned long ret = 0;
+	unsigned long long delta;
 
-	if (scanned == 0)
-		scanned = SWAP_CLUSTER_MAX;
+	delta = (unsigned long long)scanned * objects;
+	delta *= SHRINK_FACTOR;
+	do_div(delta, total + 1);
+	delta *= SHRINK_FACTOR; /* ratio is also in SHRINK_FACTOR units */
+	do_div(delta, ratio + 1);
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		return 1;	/* Assume we'll be able to shrink next time */
+	/*
+	 * Avoid risking looping forever due to too large nr value:
+	 * never try to free more than twice the estimate number of
+	 * freeable entries.
+	 */
+	*dst += delta;
+
+	if (*dst / SHRINK_FACTOR > objects)
+		*dst = objects * SHRINK_FACTOR;
+}
+EXPORT_SYMBOL(shrinker_add_scan);
+
+/*
+ * shrinker_do_scan - scan a batch of objects
+ * @dst: scan counter
+ * @batch: number of objects to scan in this batch
+ * @Returns: number of objects to scan
+ *
+ * shrinker_do_scan takes the scan counter accumulated by shrinker_add_scan,
+ * and decrements it by @batch if it is greater than batch and returns batch.
+ * Otherwise returns 0. The caller should use the return value as the number
+ * of objects to scan next.
+ *
+ * Between shrinker_do_scan calls, the caller should drop locks if possible
+ * and call cond_resched.
+ *
+ * Note, @dst is a fixed point scaled integer. See shrinker_add_scan.
+ *
+ * Like shrinker_add_scan, shrinker_do_scan is not SMP safe, but it doesn't
+ * really need to be.
+ */
+unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch)
+{
+	unsigned long nr = ACCESS_ONCE(*dst);
+	if (nr < batch * SHRINK_FACTOR)
+		return 0;
+	*dst = nr - batch * SHRINK_FACTOR;
+	return batch;
+}
+EXPORT_SYMBOL(shrinker_do_scan);
+
+#define SHRINK_BATCH 128
+/*
+ * Scan the deprecated shrinkers. This will go away soon in favour of
+ * converting everybody to new shrinker API.
+ */
+static void shrink_slab_old(unsigned long scanned, gfp_t gfp_mask,
+			unsigned long lru_pages)
+{
+	struct shrinker *shrinker;
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 		unsigned long total_scan;
 		unsigned long max_pass;
 
+		if (!shrinker->shrink)
+			continue;
 		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
@@ -250,15 +313,11 @@ unsigned long shrink_slab(unsigned long
 		while (total_scan >= SHRINK_BATCH) {
 			long this_scan = SHRINK_BATCH;
 			int shrink_ret;
-			int nr_before;
 
-			nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
 			shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
 								gfp_mask);
 			if (shrink_ret == -1)
 				break;
-			if (shrink_ret < nr_before)
-				ret += nr_before - shrink_ret;
 			count_vm_events(SLABS_SCANNED, this_scan);
 			total_scan -= this_scan;
 
@@ -267,8 +326,86 @@ unsigned long shrink_slab(unsigned long
 
 		shrinker->nr += total_scan;
 	}
+}
+/*
+ * shrink_slab - Call the shrink functions to age shrinkable caches
+ * @zone: the zone we are currently reclaiming from
+ * @scanned: how many pagecache pages were scanned in this zone
+ * @total: total number of reclaimable pagecache pages in this zone
+ * @global: total number of reclaimable pagecache pages in the system
+ * @gfp_mask: gfp context that we are in
+ *
+ * Slab shrinkers should scan their objects in a proportion to the ratio of
+ * scanned to total pagecache pages in this zone, modified by a "cost"
+ * constant.
+ *
+ * For example, we have a slab cache with 100 reclaimable objects in a
+ * particular zone, and the cost of reclaiming an object is determined to be
+ * twice as expensive as reclaiming a pagecache page (due to likelihood and
+ * cost of reconstruction). If we have 200 reclaimable pagecache pages in that
+ * zone particular zone, and scan 20 of them (10%), we should scan 5% (5) of
+ * the objects in our slab cache.
+ *
+ * If we have a single global list of objects and no per-zone lists, the
+ * global count of objects can be used to find the correct ratio to scan.
+ *
+ * See shrinker_add_scan and shrinker_do_scan for helper functions and
+ * details on how to calculate these numbers.
+ */
+static void shrink_slab(struct zone *zone, unsigned long scanned,
+			unsigned long total, unsigned long global,
+			gfp_t gfp_mask)
+{
+	struct shrinker *shrinker;
+
+	if (scanned == 0)
+		scanned = SWAP_CLUSTER_MAX;
+
+	if (!down_read_trylock(&shrinker_rwsem))
+		return;
+
+	/* do a global shrink with the old shrinker API */
+	shrink_slab_old(scanned, gfp_mask, global);
+
+	list_for_each_entry(shrinker, &shrinker_list, list) {
+		if (!shrinker->shrink_zone)
+			continue;
+		(*shrinker->shrink_zone)(shrinker, zone, scanned,
+					total, global, 0, gfp_mask);
+	}
 	up_read(&shrinker_rwsem);
-	return ret;
+}
+
+/**
+ * shrink_all_slab - shrinks slabs in a given zone or system wide
+ * @zone: NULL to shrink slab from all zones, or non-NULL to shrink from a particular zone
+ *
+ * shrink_all_slab is a bit of a big hammer, and it's not really well defined what it should
+ * do (how much, how hard to shrink, etc), and it will throw out the reclaim balance. So it
+ * must only be used very carefully (drop_caches and hardware memory error handler are good
+ * examples).
+ */
+void shrink_all_slab(struct zone *zone)
+{
+	struct reclaim_state reclaim_state;
+
+	current->reclaim_state = &reclaim_state;
+	do {
+		reclaim_state.reclaimed_slab = 0;
+		/*
+		 * Use "100" for "scanned", "total", and "global", so
+		 * that shrinkers scan a large proportion of their
+		 * objects. 100 rather than 1 in order to reduce rounding
+		 * errors.
+		 */
+		if (!zone) {
+			for_each_populated_zone(zone)
+				shrink_slab(zone, 100, 100, 100, GFP_KERNEL);
+		} else
+			shrink_slab(zone, 100, 100, 100, GFP_KERNEL);
+	} while (reclaim_state.reclaimed_slab);
+
+	current->reclaim_state = NULL;
 }
 
 static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
@@ -1801,16 +1938,22 @@ static void get_scan_count(struct zone *
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+			struct scan_control *sc, unsigned long global_lru_pages)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_scanned = sc->nr_scanned;
+	unsigned long lru_pages = 0;
 
 	get_scan_count(zone, sc, nr, priority);
 
+	/* Used by slab shrinking, below */
+	if (sc->may_reclaim_slab)
+		lru_pages = zone_reclaimable_pages(zone);
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1835,8 +1978,6 @@ static void shrink_zone(int priority, st
 			break;
 	}
 
-	sc->nr_reclaimed = nr_reclaimed;
-
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
@@ -1844,6 +1985,23 @@ static void shrink_zone(int priority, st
 	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
+	/*
+	 * Don't shrink slabs when reclaiming memory from
+	 * over limit cgroups
+	 */
+	if (sc->may_reclaim_slab) {
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
 
@@ -1864,7 +2022,7 @@ static void shrink_zone(int priority, st
  * scan then give up on it.
  */
 static void shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+		struct scan_control *sc, unsigned long global_lru_pages)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -1884,7 +2042,7 @@ static void shrink_zones(int priority, s
 				continue;	/* Let kswapd poll it */
 		}
 
-		shrink_zone(priority, zone, sc);
+		shrink_zone(priority, zone, sc, global_lru_pages);
 	}
 }
 
@@ -1941,7 +2099,6 @@ static unsigned long do_try_to_free_page
 {
 	int priority;
 	unsigned long total_scanned = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
@@ -1953,30 +2110,20 @@ static unsigned long do_try_to_free_page
 		count_vm_event(ALLOCSTALL);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc->nr_scanned = 0;
-		if (!priority)
-			disable_swap_token();
-		shrink_zones(priority, zonelist, sc);
-		/*
-		 * Don't shrink slabs when reclaiming memory from
-		 * over limit cgroups
-		 */
-		if (scanning_global_lru(sc)) {
-			unsigned long lru_pages = 0;
-			for_each_zone_zonelist(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask)) {
-				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-					continue;
+		unsigned long lru_pages = 0;
 
-				lru_pages += zone_reclaimable_pages(zone);
-			}
+		for_each_zone_zonelist(zone, z, zonelist,
+				gfp_zone(sc->gfp_mask)) {
+			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+				continue;
 
-			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
-			if (reclaim_state) {
-				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
+			lru_pages += zone_reclaimable_pages(zone);
 		}
+
+		sc->nr_scanned = 0;
+		if (!priority)
+			disable_swap_token();
+		shrink_zones(priority, zonelist, sc, lru_pages);
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			goto out;
@@ -2029,6 +2176,7 @@ unsigned long try_to_free_pages(struct z
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.may_reclaim_slab = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -2058,6 +2206,7 @@ unsigned long mem_cgroup_shrink_node_zon
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
+		.may_reclaim_slab = 0,
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
@@ -2076,7 +2225,7 @@ unsigned long mem_cgroup_shrink_node_zon
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone(0, zone, &sc);
+	shrink_zone(0, zone, &sc, zone_reclaimable_pages(zone));
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2094,6 +2243,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
+		.may_reclaim_slab = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -2171,11 +2321,11 @@ static unsigned long balance_pgdat(pg_da
 	int priority;
 	int i;
 	unsigned long total_scanned;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.may_reclaim_slab = 1,
 		/*
 		 * kswapd doesn't want to be bailed out while reclaim. because
 		 * we want to put equal scanning pressure on each zone.
@@ -2249,7 +2399,6 @@ static unsigned long balance_pgdat(pg_da
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab;
 
 			if (!populated_zone(zone))
 				continue;
@@ -2271,15 +2420,11 @@ static unsigned long balance_pgdat(pg_da
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
-			if (nr_slab == 0 && !zone_reclaimable(zone))
+			if (!zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and
@@ -2545,6 +2690,7 @@ unsigned long shrink_all_memory(unsigned
 		.may_swap = 1,
 		.may_unmap = 1,
 		.may_writepage = 1,
+		.may_reclaim_slab = 1,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
 		.swappiness = vm_swappiness,
@@ -2728,13 +2874,14 @@ static int __zone_reclaim(struct zone *z
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
+		.may_reclaim_slab = 0,
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 		.order = order,
 	};
-	unsigned long nr_slab_pages0, nr_slab_pages1;
+	unsigned long lru_pages, slab_pages;
 
 	cond_resched();
 	/*
@@ -2747,51 +2894,61 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
+	lru_pages = zone_reclaimable_pages(zone);
+	slab_pages = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
+		if (slab_pages > zone->min_slab_pages)
+			sc.may_reclaim_slab = 1;
 		/*
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
 		 */
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			shrink_zone(priority, zone, &sc);
+			shrink_zone(priority, zone, &sc, lru_pages);
 			priority--;
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
-	}
 
-	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (nr_slab_pages0 > zone->min_slab_pages) {
+	} else if (slab_pages > zone->min_slab_pages) {
 		/*
-		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we take the current
-		 * number of slab pages and shake the slab until it is reduced
-		 * by the same nr_pages that we used for reclaiming unmapped
-		 * pages.
-		 *
-		 * Note that shrink_slab will free memory on all zones and may
-		 * take a long time.
+		 * Scanning slab without pagecache, have to open code
+		 * call to shrink_slab (shirnk_zone drives slab reclaim via
+		 * pagecache scanning, so it isn't set up to shrink slab
+		 * without scanning pagecache.
 		 */
-		for (;;) {
-			unsigned long lru_pages = zone_reclaimable_pages(zone);
-
-			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(sc.nr_scanned, gfp_mask, lru_pages))
-				break;
 
-			/* Freed enough memory */
-			nr_slab_pages1 = zone_page_state(zone,
-							NR_SLAB_RECLAIMABLE);
-			if (nr_slab_pages1 + nr_pages <= nr_slab_pages0)
-				break;
-		}
+		/*
+		 * lru_pages / 10  -- put a 10% pressure on the slab
+		 * which roughly corresponds to ZONE_RECLAIM_PRIORITY
+		 * scanning 1/16th of pagecache.
+		 *
+		 * Global slabs will be shrink at a relatively more
+		 * aggressive rate because we don't calculate the
+		 * global lru size for speed. But they really should
+		 * be converted to per zone slabs if they are important
+		 */
+		shrink_slab(zone, lru_pages / 10, lru_pages, lru_pages,
+				gfp_mask);
 
 		/*
-		 * Update nr_reclaimed by the number of slab pages we
-		 * reclaimed from this zone.
+		 * Although we have a zone based slab shrinker API, some slabs
+		 * are still scanned globally. This means we can't quite
+		 * determine how many pages were freed in this zone by
+		 * checking reclaimed_slab. However the regular shrink_zone
+		 * paths have exactly the same problem that they largely
+		 * ignore. So don't be different.
+		 *
+		 * The situation will improve dramatically as important slabs
+		 * are switched over to using reclaimed_slab after the
+		 * important slabs are converted to using per zone shrinkers.
+		 *
+		 * Note that shrink_slab may free memory on all zones and may
+		 * take a long time, but again switching important slabs to
+		 * zone based shrinkers will solve this problem.
 		 */
-		nr_slab_pages1 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-		if (nr_slab_pages1 < nr_slab_pages0)
-			sc.nr_reclaimed += nr_slab_pages0 - nr_slab_pages1;
+		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		reclaim_state.reclaimed_slab = 0;
 	}
 
 	p->reclaim_state = NULL;
Index: linux-2.6/fs/drop_caches.c
===================================================================
--- linux-2.6.orig/fs/drop_caches.c	2010-11-09 22:11:03.000000000 +1100
+++ linux-2.6/fs/drop_caches.c	2010-11-09 22:11:10.000000000 +1100
@@ -35,11 +35,7 @@ static void drop_pagecache_sb(struct sup
 
 static void drop_slab(void)
 {
-	int nr_objects;
-
-	do {
-		nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
-	} while (nr_objects > 10);
+	shrink_all_slab(NULL); /* NULL - all zones */
 }
 
 int drop_caches_sysctl_handler(ctl_table *table, int write,
Index: linux-2.6/mm/memory-failure.c
===================================================================
--- linux-2.6.orig/mm/memory-failure.c	2010-11-09 22:11:03.000000000 +1100
+++ linux-2.6/mm/memory-failure.c	2010-11-09 22:11:10.000000000 +1100
@@ -235,14 +235,8 @@ void shake_page(struct page *p, int acce
 	 * Only all shrink_slab here (which would also
 	 * shrink other caches) if access is not potentially fatal.
 	 */
-	if (access) {
-		int nr;
-		do {
-			nr = shrink_slab(1000, GFP_KERNEL, 1000);
-			if (page_count(p) == 1)
-				break;
-		} while (nr > 10);
-	}
+	if (access)
+		shrink_all_slab(page_zone(p));
 }
 EXPORT_SYMBOL_GPL(shake_page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
