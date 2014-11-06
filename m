Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA9E6B00DA
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 18:50:44 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id b13so2417586wgh.26
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 15:50:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ap4si12027776wjc.164.2014.11.06.15.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 15:50:43 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Date: Thu,  6 Nov 2014 18:50:28 -0500
Message-Id: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slab shrinkers currently rely on the reclaim code providing an
ad-hoc concept of NUMA nodes that doesn't really exist: for all
scanned zones and lruvecs, the nodes and available LRU pages are
summed up, only to have the shrinkers then again walk that nodemask
when scanning slab caches.  This duplication will only get worse and
more expensive once the shrinkers become aware of cgroups.

Instead, invoke the shrinkers for each lruvec scanned - which is
either the zone level, or in case of cgroups, the subset of a zone's
pages that is charged to the scanned memcg.  The number of eligible
LRU pages is naturally available at that level - it is even more
accurate than simply looking at the global state and the number of
available swap pages, as get_scan_count() considers many other factors
when deciding which LRU pages to consider.

This invokes the shrinkers more often and with smaller page and scan
counts, but the ratios remain the same, and the shrinkers themselves
do not add significantly to the existing per-lruvec cost.

This integrates the slab shrinking nicely into the reclaim logic.  Not
just conceptually, but it also allows kswapd, the direct reclaim code,
and zone reclaim to get rid of their ad-hoc custom slab shrinking.

Lastly, this facilitates making the shrinkers cgroup-aware without a
fantastic amount code and runtime work duplication, and consolidation
will make hierarchy walk optimizations easier later on.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 drivers/staging/android/ashmem.c |   1 -
 fs/drop_caches.c                 |  15 ++--
 include/linux/shrinker.h         |   2 -
 mm/memory-failure.c              |   3 +-
 mm/vmscan.c                      | 164 +++++++++++++--------------------------
 5 files changed, 63 insertions(+), 122 deletions(-)

I put this together as a result of the discussion with Vladimir about
memcg-aware slab shrinkers this morning.

This might need some tuning, but it definitely looks like the right
thing to do conceptually.  I'm currently playing with various slab-
and memcg-heavy workloads (many numa nodes + many cgroups = many
shrinker invocations) but so far the numbers look okay.

It would be great if other people could weigh in, and possibly also
expose it to their favorite filesystem and reclaim stress tests.

Thanks

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index ad4f5790a76f..776fba626278 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -785,7 +785,6 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				.nr_to_scan = LONG_MAX,
 			};
 			ret = ashmem_shrink_count(&ashmem_shrinker, &sc);
-			nodes_setall(sc.nodes_to_scan);
 			ashmem_shrink_scan(&ashmem_shrinker, &sc);
 		}
 		break;
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 1de7294aad20..ca602bf7d97a 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -40,13 +40,18 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 static void drop_slab(void)
 {
 	int nr_objects;
-	struct shrink_control shrink = {
-		.gfp_mask = GFP_KERNEL,
-	};
 
-	nodes_setall(shrink.nodes_to_scan);
 	do {
-		nr_objects = shrink_slab(&shrink, 1000, 1000);
+		int nid;
+
+		nr_objects = 0;
+		for_each_online_node(nid) {
+			struct shrink_control shrink = {
+				.gfp_mask = GFP_KERNEL,
+				.nid = nid,
+			};
+			nr_objects += shrink_slab(&shrink, 1000, 1000);
+		}
 	} while (nr_objects > 10);
 }
 
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 68c097077ef0..f4aee75f00b1 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -18,8 +18,6 @@ struct shrink_control {
 	 */
 	unsigned long nr_to_scan;
 
-	/* shrink from these nodes */
-	nodemask_t nodes_to_scan;
 	/* current node being shrunk (for NUMA aware shrinkers) */
 	int nid;
 };
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e619625489c2..93ee9739f7fd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -248,9 +248,8 @@ void shake_page(struct page *p, int access)
 		do {
 			struct shrink_control shrink = {
 				.gfp_mask = GFP_KERNEL,
+				.nid = nid,
 			};
-			node_set(nid, shrink.nodes_to_scan);
-
 			nr = shrink_slab(&shrink, 1000, 1000);
 			if (page_count(p) == 1)
 				break;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a384339bf718..6a9ab5adf118 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -229,9 +229,10 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
-static unsigned long
-shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
-		 unsigned long nr_pages_scanned, unsigned long lru_pages)
+static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
+				    struct shrinker *shrinker,
+				    unsigned long nr_pages_scanned,
+				    unsigned long lru_pages)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -239,10 +240,15 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	long freeable;
 	long nr;
 	long new_nr;
-	int nid = shrinkctl->nid;
+	int nid;
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
 
+	if (shrinker->flags & SHRINKER_NUMA_AWARE)
+		nid = shrinkctl->nid;
+	else
+		nid = 0;
+
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0)
 		return 0;
@@ -380,19 +386,9 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
-			shrinkctl->nid = 0;
-			freed += shrink_slab_node(shrinkctl, shrinker,
+		freed += do_shrink_slab(shrinkctl, shrinker,
 					nr_pages_scanned, lru_pages);
-			continue;
-		}
-
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (node_online(shrinkctl->nid))
-				freed += shrink_slab_node(shrinkctl, shrinker,
-						nr_pages_scanned, lru_pages);
 
-		}
 	}
 	up_read(&shrinker_rwsem);
 out:
@@ -1876,7 +1872,8 @@ enum scan_balance {
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
 static void get_scan_count(struct lruvec *lruvec, int swappiness,
-			   struct scan_control *sc, unsigned long *nr)
+			   struct scan_control *sc, unsigned long *nr,
+			   unsigned long *lru_pages)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -2022,39 +2019,34 @@ out:
 	some_scanned = false;
 	/* Only use force_scan on second pass. */
 	for (pass = 0; !some_scanned && pass < 2; pass++) {
+		*lru_pages = 0;
 		for_each_evictable_lru(lru) {
 			int file = is_file_lru(lru);
 			unsigned long size;
 			unsigned long scan;
 
+			/* Scan one type exclusively */
+			if ((scan_balance == SCAN_FILE) != file) {
+				nr[lru] = 0;
+				continue;
+			}
+
 			size = get_lru_size(lruvec, lru);
-			scan = size >> sc->priority;
+			*lru_pages += size;
 
+			scan = size >> sc->priority;
 			if (!scan && pass && force_scan)
 				scan = min(size, SWAP_CLUSTER_MAX);
 
-			switch (scan_balance) {
-			case SCAN_EQUAL:
-				/* Scan lists relative to size */
-				break;
-			case SCAN_FRACT:
+			if (scan_balance == SCAN_FRACT) {
 				/*
 				 * Scan types proportional to swappiness and
 				 * their relative recent reclaim efficiency.
 				 */
 				scan = div64_u64(scan * fraction[file],
-							denominator);
-				break;
-			case SCAN_FILE:
-			case SCAN_ANON:
-				/* Scan one type exclusively */
-				if ((scan_balance == SCAN_FILE) != file)
-					scan = 0;
-				break;
-			default:
-				/* Look ma, no brain */
-				BUG();
+						 denominator);
 			}
+
 			nr[lru] = scan;
 			/*
 			 * Skip the second pass and don't force_scan,
@@ -2077,10 +2069,17 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_scanned = sc->nr_scanned;
+	unsigned long lru_pages;
 	struct blk_plug plug;
 	bool scan_adjusted;
+	struct shrink_control shrink = {
+		.gfp_mask = sc->gfp_mask,
+		.nid = zone_to_nid(lruvec_zone(lruvec)),
+	};
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 
-	get_scan_count(lruvec, swappiness, sc, nr);
+	get_scan_count(lruvec, swappiness, sc, nr, &lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2173,6 +2172,23 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	sc->nr_reclaimed += nr_reclaimed;
 
 	/*
+	 * Shrink slab caches in the same proportion that the eligible
+	 * LRU pages were scanned.
+	 *
+	 * XXX: Skip memcg limit reclaim, as the slab shrinkers are
+	 * not cgroup-aware yet and we can't know if the objects in
+	 * the global lists contribute to the memcg limit.
+	 */
+	if (global_reclaim(sc) && lru_pages) {
+		nr_scanned = sc->nr_scanned - nr_scanned;
+		shrink_slab(&shrink, nr_scanned, lru_pages);
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
+	}
+
+	/*
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
@@ -2376,12 +2392,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	struct zone *zone;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
-	unsigned long lru_pages = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	gfp_t orig_mask;
-	struct shrink_control shrink = {
-		.gfp_mask = sc->gfp_mask,
-	};
 	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 	bool reclaimable = false;
 
@@ -2394,8 +2405,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	if (buffer_heads_over_limit)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
-	nodes_clear(shrink.nodes_to_scan);
-
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
@@ -2409,9 +2418,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
-			lru_pages += zone_reclaimable_pages(zone);
-			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
 				continue;	/* Let kswapd poll it */
@@ -2459,20 +2465,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	}
 
 	/*
-	 * Don't shrink slabs when reclaiming memory from over limit cgroups
-	 * but do shrink slab at least once when aborting reclaim for
-	 * compaction to avoid unevenly scanning file/anon LRU pages over slab
-	 * pages.
-	 */
-	if (global_reclaim(sc)) {
-		shrink_slab(&shrink, sc->nr_scanned, lru_pages);
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
-	}
-
-	/*
 	 * Restore to original mask to avoid the impact on the caller if we
 	 * promoted it to __GFP_HIGHMEM.
 	 */
@@ -2932,15 +2924,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 static bool kswapd_shrink_zone(struct zone *zone,
 			       int classzone_idx,
 			       struct scan_control *sc,
-			       unsigned long lru_pages,
 			       unsigned long *nr_attempted)
 {
 	int testorder = sc->order;
 	unsigned long balance_gap;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct shrink_control shrink = {
-		.gfp_mask = sc->gfp_mask,
-	};
 	bool lowmem_pressure;
 
 	/* Reclaim above the high watermark. */
@@ -2976,12 +2963,6 @@ static bool kswapd_shrink_zone(struct zone *zone,
 		return true;
 
 	shrink_zone(zone, sc);
-	nodes_clear(shrink.nodes_to_scan);
-	node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-
-	reclaim_state->reclaimed_slab = 0;
-	shrink_slab(&shrink, sc->nr_scanned, lru_pages);
-	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
@@ -3042,7 +3023,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	count_vm_event(PAGEOUTRUN);
 
 	do {
-		unsigned long lru_pages = 0;
 		unsigned long nr_attempted = 0;
 		bool raise_priority = true;
 		bool pgdat_needs_compaction = (order > 0);
@@ -3102,8 +3082,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			if (!populated_zone(zone))
 				continue;
 
-			lru_pages += zone_reclaimable_pages(zone);
-
 			/*
 			 * If any zone is currently balanced then kswapd will
 			 * not call compaction as it is expected that the
@@ -3159,8 +3137,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * that that high watermark would be met at 100%
 			 * efficiency.
 			 */
-			if (kswapd_shrink_zone(zone, end_zone, &sc,
-					lru_pages, &nr_attempted))
+			if (kswapd_shrink_zone(zone, end_zone,
+					       &sc, &nr_attempted))
 				raise_priority = false;
 		}
 
@@ -3612,10 +3590,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
-	unsigned long nr_slab_pages0, nr_slab_pages1;
 
 	cond_resched();
 	/*
@@ -3638,40 +3612,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (nr_slab_pages0 > zone->min_slab_pages) {
-		/*
-		 * shrink_slab() does not currently allow us to determine how
-		 * many pages were freed in this zone. So we take the current
-		 * number of slab pages and shake the slab until it is reduced
-		 * by the same nr_pages that we used for reclaiming unmapped
-		 * pages.
-		 */
-		nodes_clear(shrink.nodes_to_scan);
-		node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-		for (;;) {
-			unsigned long lru_pages = zone_reclaimable_pages(zone);
-
-			/* No reclaimable slab or very low memory pressure */
-			if (!shrink_slab(&shrink, sc.nr_scanned, lru_pages))
-				break;
-
-			/* Freed enough memory */
-			nr_slab_pages1 = zone_page_state(zone,
-							NR_SLAB_RECLAIMABLE);
-			if (nr_slab_pages1 + nr_pages <= nr_slab_pages0)
-				break;
-		}
-
-		/*
-		 * Update nr_reclaimed by the number of slab pages we
-		 * reclaimed from this zone.
-		 */
-		nr_slab_pages1 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-		if (nr_slab_pages1 < nr_slab_pages0)
-			sc.nr_reclaimed += nr_slab_pages0 - nr_slab_pages1;
-	}
-
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_clear_current_reclaim_state();
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
