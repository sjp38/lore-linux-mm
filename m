Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE756B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 13:24:00 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so1595341wgh.26
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 10:23:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h4si4313201wiy.60.2014.11.25.10.23.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Nov 2014 10:23:59 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Date: Tue, 25 Nov 2014 13:23:50 -0500
Message-Id: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slab shrinkers are currently invoked from the zonelist walkers in
kswapd, direct reclaim, and zone reclaim, all of which roughly gauge
the eligible LRU pages and assemble a nodemask to pass to NUMA-aware
shrinkers, which then again have to walk over the nodemask.  This is
redundant code, extra runtime work, and fairly inaccurate when it
comes to the estimation of actually scannable LRU pages.  The code
duplication will only get worse when making the shrinkers cgroup-aware
and requiring them to have out-of-band cgroup hierarchy walks as well.

Instead, invoke the shrinkers from shrink_zone(), which is where all
reclaimers end up, to avoid this duplication.

Take the count for eligible LRU pages out of get_scan_count(), which
considers many more factors than just the availability of swap space,
like zone_reclaimable_pages() currently does.  Accumulate the number
over all visited lruvecs to get the per-zone value.

Some nodes have multiple zones due to memory addressing restrictions.
To avoid putting too much pressure on the shrinkers, only invoke them
once for each such node, using the class zone of the allocation as the
pivot zone.

For now, this integrates the slab shrinking better into the reclaim
logic and gets rid of duplicative invocations from kswapd, direct
reclaim, and zone reclaim.  It also prepares for cgroup-awareness,
allowing memcg-capable shrinkers to be added at the lruvec level
without much duplication of both code and runtime work.

This changes kswapd behavior, which used to invoke the shrinkers for
each zone, but with scan ratios gathered from the entire node,
resulting in meaningless pressure quantities on multi-zone nodes.

Zone reclaim behavior also changes.  It used to shrink slabs until the
same amount of pages were shrunk as were reclaimed from the LRUs.  Now
it merely invokes the shrinkers once with the zone's scan ratio, which
makes the shrinkers go easier on caches that implement aging and would
prefer feeding back pressure from recently used slab objects to unused
LRU pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 drivers/staging/android/ashmem.c |   3 +-
 fs/drop_caches.c                 |  11 ++-
 include/linux/mm.h               |   6 +-
 include/linux/shrinker.h         |   2 -
 mm/memory-failure.c              |  11 +--
 mm/page_alloc.c                  |   6 +-
 mm/vmscan.c                      | 208 +++++++++++++++------------------------
 7 files changed, 98 insertions(+), 149 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 27eecfe1c410..8c7852742f4b 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -418,7 +418,7 @@ out:
 }
 
 /*
- * ashmem_shrink - our cache shrinker, called from mm/vmscan.c :: shrink_slab
+ * ashmem_shrink - our cache shrinker, called from mm/vmscan.c
  *
  * 'nr_to_scan' is the number of objects to scan for freeing.
  *
@@ -785,7 +785,6 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				.nr_to_scan = LONG_MAX,
 			};
 			ret = ashmem_shrink_count(&ashmem_shrinker, &sc);
-			nodes_setall(sc.nodes_to_scan);
 			ashmem_shrink_scan(&ashmem_shrinker, &sc);
 		}
 		break;
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 1de7294aad20..2bc2c87f35e7 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -40,13 +40,14 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
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
+		for_each_online_node(nid)
+			nr_objects += shrink_node_slabs(GFP_KERNEL, nid,
+							1000, 1000);
 	} while (nr_objects > 10);
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b922a16c9b5b..f652931aa4bd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2088,9 +2088,9 @@ int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 #endif
 
-unsigned long shrink_slab(struct shrink_control *shrink,
-			  unsigned long nr_pages_scanned,
-			  unsigned long lru_pages);
+unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
+				unsigned long nr_scanned,
+				unsigned long nr_eligible);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
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
index 6b94969d91c5..feb803bf3443 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -239,19 +239,14 @@ void shake_page(struct page *p, int access)
 	}
 
 	/*
-	 * Only call shrink_slab here (which would also shrink other caches) if
-	 * access is not potentially fatal.
+	 * Only call shrink_node_slabs here (which would also shrink
+	 * other caches) if access is not potentially fatal.
 	 */
 	if (access) {
 		int nr;
 		int nid = page_to_nid(p);
 		do {
-			struct shrink_control shrink = {
-				.gfp_mask = GFP_KERNEL,
-			};
-			node_set(nid, shrink.nodes_to_scan);
-
-			nr = shrink_slab(&shrink, 1000, 1000);
+			nr = shrink_node_slabs(GFP_KERNEL, nid, 1000, 1000);
 			if (page_count(p) == 1)
 				break;
 		} while (nr > 10);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b0e6eaba454c..efa4e6fe6a4d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6267,9 +6267,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		if (!PageLRU(page))
 			found++;
 		/*
-		 * If there are RECLAIMABLE pages, we need to check it.
-		 * But now, memory offline itself doesn't call shrink_slab()
-		 * and it still to be fixed.
+		 * If there are RECLAIMABLE pages, we need to check
+		 * it.  But now, memory offline itself doesn't call
+		 * shrink_node_slabs() and it still to be fixed.
 		 */
 		/*
 		 * If the page is not RAM, page_count()should be 0.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a384339bf718..8c2b45bfe610 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -229,9 +229,10 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
-static unsigned long
-shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
-		 unsigned long nr_pages_scanned, unsigned long lru_pages)
+static unsigned long shrink_slabs(struct shrink_control *shrinkctl,
+				  struct shrinker *shrinker,
+				  unsigned long nr_scanned,
+				  unsigned long nr_eligible)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -255,9 +256,9 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	delta = (4 * nr_scanned) / shrinker->seeks;
 	delta *= freeable;
-	do_div(delta, lru_pages + 1);
+	do_div(delta, nr_eligible + 1);
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
@@ -289,8 +290,8 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 		total_scan = freeable * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				nr_pages_scanned, lru_pages,
-				freeable, delta, total_scan);
+				   nr_scanned, nr_eligible,
+				   freeable, delta, total_scan);
 
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
@@ -339,34 +340,37 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	return freed;
 }
 
-/*
- * Call the shrink functions to age shrinkable caches
- *
- * Here we assume it costs one seek to replace a lru page and that it also
- * takes a seek to recreate a cache object.  With this in mind we age equal
- * percentages of the lru and ageable caches.  This should balance the seeks
- * generated by these structures.
+/**
+ * shrink_node_slabs - shrink slab caches of a given node
+ * @gfp_mask: allocation context
+ * @nid: node whose slab caches to target
+ * @nr_scanned: pressure numerator
+ * @nr_eligible: pressure denominator
  *
- * If the vm encountered mapped pages on the LRU it increase the pressure on
- * slab to avoid swapping.
+ * Call the shrink functions to age shrinkable caches.
  *
- * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
+ * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
+ * unaware shrinkers will receive a node id of 0 instead.
  *
- * `lru_pages' represents the number of on-LRU pages in all the zones which
- * are eligible for the caller's allocation attempt.  It is used for balancing
- * slab reclaim versus page reclaim.
+ * @nr_scanned and @nr_eligible form a ratio that indicate how much of
+ * the available objects should be scanned.  Page reclaim for example
+ * passes the number of pages scanned and the number of pages on the
+ * LRU lists that it considered on @nid, plus a bias in @nr_scanned
+ * when it encountered mapped pages.  The ratio is further biased by
+ * the ->seeks setting of the shrink function, which indicates the
+ * cost to recreate an object relative to that of an LRU page.
  *
- * Returns the number of slab objects which we shrunk.
+ * Returns the number of reclaimed slab objects.
  */
-unsigned long shrink_slab(struct shrink_control *shrinkctl,
-			  unsigned long nr_pages_scanned,
-			  unsigned long lru_pages)
+unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
+				unsigned long nr_scanned,
+				unsigned long nr_eligible)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (nr_pages_scanned == 0)
-		nr_pages_scanned = SWAP_CLUSTER_MAX;
+	if (nr_scanned == 0)
+		nr_scanned = SWAP_CLUSTER_MAX;
 
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
@@ -380,20 +384,17 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
-			shrinkctl->nid = 0;
-			freed += shrink_slab_node(shrinkctl, shrinker,
-					nr_pages_scanned, lru_pages);
-			continue;
-		}
+		struct shrink_control sc = {
+			.gfp_mask = gfp_mask,
+			.nid = nid,
+		};
 
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (node_online(shrinkctl->nid))
-				freed += shrink_slab_node(shrinkctl, shrinker,
-						nr_pages_scanned, lru_pages);
+		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
+			sc.nid = 0;
 
-		}
+		freed += shrink_slabs(&sc, shrinker, nr_scanned, nr_eligible);
 	}
+
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
@@ -1876,7 +1877,8 @@ enum scan_balance {
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
 static void get_scan_count(struct lruvec *lruvec, int swappiness,
-			   struct scan_control *sc, unsigned long *nr)
+			   struct scan_control *sc, unsigned long *nr,
+			   unsigned long *lru_pages)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -2022,6 +2024,7 @@ out:
 	some_scanned = false;
 	/* Only use force_scan on second pass. */
 	for (pass = 0; !some_scanned && pass < 2; pass++) {
+		*lru_pages = 0;
 		for_each_evictable_lru(lru) {
 			int file = is_file_lru(lru);
 			unsigned long size;
@@ -2048,14 +2051,19 @@ out:
 			case SCAN_FILE:
 			case SCAN_ANON:
 				/* Scan one type exclusively */
-				if ((scan_balance == SCAN_FILE) != file)
+				if ((scan_balance == SCAN_FILE) != file) {
+					size = 0;
 					scan = 0;
+				}
 				break;
 			default:
 				/* Look ma, no brain */
 				BUG();
 			}
+
+			*lru_pages += size;
 			nr[lru] = scan;
+
 			/*
 			 * Skip the second pass and don't force_scan,
 			 * if we found something to scan.
@@ -2069,7 +2077,7 @@ out:
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
-			  struct scan_control *sc)
+			  struct scan_control *sc, unsigned long *lru_pages)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
@@ -2080,7 +2088,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, swappiness, sc, nr);
+	get_scan_count(lruvec, swappiness, sc, nr, lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2258,7 +2266,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static bool shrink_zone(struct zone *zone, struct scan_control *sc)
+static bool shrink_zone(struct zone *zone, struct scan_control *sc,
+			bool is_classzone)
 {
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
@@ -2269,6 +2278,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 			.zone = zone,
 			.priority = sc->priority,
 		};
+		unsigned long zone_lru_pages = 0;
 		struct mem_cgroup *memcg;
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2276,13 +2286,15 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
+			unsigned long lru_pages;
 			struct lruvec *lruvec;
 			int swappiness;
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
 
-			shrink_lruvec(lruvec, swappiness, sc);
+			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
+			zone_lru_pages += lru_pages;
 
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
@@ -2302,6 +2314,25 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 			memcg = mem_cgroup_iter(root, memcg, &reclaim);
 		} while (memcg);
 
+		/*
+		 * Shrink the slab caches in the same proportion that
+		 * the eligible LRU pages were scanned.
+		 */
+		if (global_reclaim(sc) && is_classzone) {
+			struct reclaim_state *reclaim_state;
+
+			shrink_node_slabs(sc->gfp_mask, zone_to_nid(zone),
+					  sc->nr_scanned - nr_scanned,
+					  zone_lru_pages);
+
+			reclaim_state = current->reclaim_state;
+			if (reclaim_state) {
+				sc->nr_reclaimed +=
+					reclaim_state->reclaimed_slab;
+				reclaim_state->reclaimed_slab = 0;
+			}
+		}
+
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
@@ -2376,12 +2407,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
 
@@ -2394,10 +2420,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	if (buffer_heads_over_limit)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
-	nodes_clear(shrink.nodes_to_scan);
-
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask), sc->nodemask) {
+					requested_highidx, sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -2409,9 +2433,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						 GFP_KERNEL | __GFP_HARDWALL))
 				continue;
 
-			lru_pages += zone_reclaimable_pages(zone);
-			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
 				continue;	/* Let kswapd poll it */
@@ -2450,7 +2471,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		if (shrink_zone(zone, sc))
+		if (shrink_zone(zone, sc, zone_idx(zone) == requested_highidx))
 			reclaimable = true;
 
 		if (global_reclaim(sc) &&
@@ -2459,20 +2480,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
@@ -2736,6 +2743,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	};
 	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 	int swappiness = mem_cgroup_swappiness(memcg);
+	unsigned long lru_pages;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2751,7 +2759,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_lruvec(lruvec, swappiness, &sc);
+	shrink_lruvec(lruvec, swappiness, &sc, &lru_pages);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2932,15 +2940,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
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
@@ -2975,13 +2978,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 						balance_gap, classzone_idx))
 		return true;
 
-	shrink_zone(zone, sc);
-	nodes_clear(shrink.nodes_to_scan);
-	node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-
-	reclaim_state->reclaimed_slab = 0;
-	shrink_slab(&shrink, sc->nr_scanned, lru_pages);
-	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
 
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
@@ -3042,7 +3039,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	count_vm_event(PAGEOUTRUN);
 
 	do {
-		unsigned long lru_pages = 0;
 		unsigned long nr_attempted = 0;
 		bool raise_priority = true;
 		bool pgdat_needs_compaction = (order > 0);
@@ -3102,8 +3098,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			if (!populated_zone(zone))
 				continue;
 
-			lru_pages += zone_reclaimable_pages(zone);
-
 			/*
 			 * If any zone is currently balanced then kswapd will
 			 * not call compaction as it is expected that the
@@ -3159,8 +3153,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 * that that high watermark would be met at 100%
 			 * efficiency.
 			 */
-			if (kswapd_shrink_zone(zone, end_zone, &sc,
-					lru_pages, &nr_attempted))
+			if (kswapd_shrink_zone(zone, end_zone,
+					       &sc, &nr_attempted))
 				raise_priority = false;
 		}
 
@@ -3612,10 +3606,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
-	unsigned long nr_slab_pages0, nr_slab_pages1;
 
 	cond_resched();
 	/*
@@ -3634,44 +3624,10 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_zone(zone, &sc);
+			shrink_zone(zone, &sc, true);
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
