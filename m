Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E19916B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 10:23:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v195so63760817qka.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 07:23:26 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 36si21855454qts.101.2017.05.23.07.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 07:23:25 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id y128so23004790qka.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 07:23:25 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH] mm: make kswapd try harder to keep active pages in cache
Date: Tue, 23 May 2017 10:23:23 -0400
Message-Id: <1495549403-3719-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kernel-team@fb.com, riel@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org

When testing a slab heavy workload I noticed that we often would barely
reclaim anything at all from slab when kswapd started doing reclaim.
This is because we use the ratio of nr_scanned / nr_lru to determine how
much of slab we should reclaim.  But in a slab only/mostly workload we
will not have much page cache to reclaim, and thus our ratio will be
really low and not at all related to where the memory on the system is.
Instead we want to use a ratio of the reclaimable slab to the actual
reclaimable space on the system.  That way if we are slab heavy we work
harder to reclaim slab.

The other part of this that hurts is when we are running close to full
memory with our working set.  If we start putting a lot of reclaimable
slab pressure on the system (think find /, or some other silliness), we
will happily evict the active pages over the slab cache.  This is kind
of backwards as we want to do all that we can to keep the active working
set in memory, and instead evict these short lived objects.  The same
thing occurs when say you do a yum update of a few packages while your
working set takes up most of RAM, you end up with inactive lists being
relatively small and so we reclaim active pages even though we could
reclaim these short lived inactive pages.

My approach here is twofold.  First, keep track of the difference in
inactive and slab pages since the last time kswapd ran.  In the first
run this will just be the overall counts of inactive and slab, but for
each subsequent run we'll have a good idea of where the memory pressure
is coming from.  Then we use this information to put pressure on either
the inactive lists or the slab caches, depending on where the pressure
is coming from.

If this optimization does not work, then we fall back to the previous
methods of reclaiming space with a slight adjustment.  Instead of using
the overall scan rate of page cache to determine the scan rate for slab,
we instead use the total usage of slab compared to the reclaimable page
cache on the box.  This will allow us to put an appropriate amount of
pressure on the slab shrinkers if we are a mostly slab workload.

I have two tests I was using to watch either side of this problem.  The
first test kept 2 files that took up 3/4 of the memory, and then started
creating a bunch of empty files.  Without this patch we would have to
re-read both files in their entirety at least 3 times during the run.
With this patch the active pages are never evicted.

The second test was a test that would read and stat all the files in a
directory, which again would take up about 3/4 of the memory with slab
cache.  Then I cat'ed a 100gib file into /dev/null and checked to see if
any of the files were evicted and verified that none of the files were
evicted.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/vmscan.c | 194 +++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 171 insertions(+), 23 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ad39bb..481e14e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -110,11 +110,20 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	/* Only reclaim inactive page cache or slab. */
+	unsigned int inactive_only:1;
+
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
 	/* Number of pages freed so far during a call to shrink_zones() */
 	unsigned long nr_reclaimed;
+
+	/* Number of inactive pages added since last kswapd run. */
+	unsigned long inactive_diff;
+
+	/* Number of slab pages added since last kswapd run. */
+	unsigned long slab_diff;
 };
 
 #ifdef ARCH_HAS_PREFETCH
@@ -308,7 +317,8 @@ EXPORT_SYMBOL(unregister_shrinker);
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker,
 				    unsigned long nr_scanned,
-				    unsigned long nr_eligible)
+				    unsigned long nr_eligible,
+				    unsigned long *slab_scanned)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -409,6 +419,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		next_deferred -= scanned;
 	else
 		next_deferred = 0;
+	if (slab_scanned)
+		(*slab_scanned) += scanned;
+
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
@@ -455,7 +468,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
 				 unsigned long nr_scanned,
-				 unsigned long nr_eligible)
+				 unsigned long nr_eligible,
+				 unsigned long *slab_scanned)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
@@ -463,9 +477,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
-	if (nr_scanned == 0)
-		nr_scanned = SWAP_CLUSTER_MAX;
-
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
 		 * If we would return 0, our callers would understand that we
@@ -496,7 +507,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible,
+					slab_scanned);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -515,7 +527,7 @@ void drop_slab_node(int nid)
 		freed = 0;
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg,
-					     1000, 1000);
+					     1000, 1000, NULL);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
 }
@@ -2102,6 +2114,7 @@ enum scan_balance {
 	SCAN_FRACT,
 	SCAN_ANON,
 	SCAN_FILE,
+	SCAN_INACTIVE,
 };
 
 /*
@@ -2128,6 +2141,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	unsigned long ap, fp;
 	enum lru_list lru;
 
+	if (sc->inactive_only) {
+		scan_balance = SCAN_INACTIVE;
+		goto out;
+	}
+
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
 		scan_balance = SCAN_FILE;
@@ -2292,6 +2310,15 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 				scan = 0;
 			}
 			break;
+		case SCAN_INACTIVE:
+			if (file && !is_active_lru(lru)) {
+				if (scan && size > sc->nr_to_reclaim)
+					scan = sc->nr_to_reclaim;
+			} else {
+				size = 0;
+				scan = 0;
+			}
+			break;
 		default:
 			/* Look ma, no brain */
 			BUG();
@@ -2509,8 +2536,62 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
+	unsigned long nr_reclaim, nr_slab, total_high_wmark = 0, nr_inactive;
+	int z;
 	bool reclaimable = false;
+	bool skip_slab = false;
+
+	nr_slab = sum_zone_node_page_state(pgdat->node_id,
+					   NR_SLAB_RECLAIMABLE);
+	nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+	nr_reclaim = pgdat_reclaimable_pages(pgdat);
+
+	for (z = 0; z < MAX_NR_ZONES; z++) {
+		struct zone *zone = &pgdat->node_zones[z];
+		if (!managed_zone(zone))
+			continue;
+		total_high_wmark += high_wmark_pages(zone);
+	}
+
+	/*
+	 * If we don't have a lot of inactive or slab pages then there's no
+	 * point in trying to free them exclusively, do the normal scan stuff.
+	 */
+	if (nr_inactive < total_high_wmark && nr_slab < total_high_wmark)
+		sc->inactive_only = 0;
 
+	/*
+	 * We don't have historical information, we can't make good decisions
+	 * about ratio's and where we should put pressure, so just apply
+	 * pressure based on overall consumption ratios.
+	 */
+	if (!sc->slab_diff && !sc->inactive_diff)
+		sc->inactive_only = 0;
+
+	/*
+	 * We still want to slightly prefer slab over inactive, so if the
+	 * inactive on this node is large enough and what is pushing us into
+	 * reclaim terretitory then limit our flushing to the inactive list for
+	 * the first go around.
+	 *
+	 * The idea is that with a memcg configured system we will still reclaim
+	 * memcg aware shrinkers, which includes the super block shrinkers.  So
+	 * if our steady state is keeping fs objects in cache for our workload
+	 * we'll still put a certain amount of pressure on them anyway.  To
+	 * avoid evicting things we actually care about we want to skip slab
+	 * reclaim altogether.
+	 *
+	 * However we still want to account for slab and inactive growing at the
+	 * same rate, so if that is the case just carry on shrinking inactive
+	 * and slab together.
+	 */
+	if (nr_inactive > total_high_wmark &&
+	    sc->inactive_diff > sc->slab_diff) {
+		unsigned long tmp = sc->inactive_diff >> 1;
+
+		if (tmp >= sc->slab_diff)
+			skip_slab = true;
+	}
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
@@ -2518,6 +2599,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			.priority = sc->priority,
 		};
 		unsigned long node_lru_pages = 0;
+		unsigned long slab_reclaimed = 0;
+		unsigned long slab_scanned = 0;
 		struct mem_cgroup *memcg;
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2543,10 +2626,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+			/*
+			 * We don't want to put a lot of pressure on all of the
+			 * slabs if a memcg is mostly full, so use the ratio of
+			 * the lru size to the total reclaimable space on the
+			 * system.  If we have sc->inactive_only set then we
+			 * want to use the ratio of the difference between the
+			 * two since the last kswapd run so we apply pressure to
+			 * the consumer appropriately.
+			 */
+			if (memcg && !skip_slab) {
+				unsigned long numerator = lru_pages;
+				unsigned long denominator = nr_reclaim;
+				if (sc->inactive_only) {
+					numerator = sc->slab_diff;
+					denominator = sc->inactive_diff;
+				}
+				slab_reclaimed +=
+					shrink_slab(sc->gfp_mask, pgdat->node_id,
+						    memcg, numerator, denominator,
+						    &slab_scanned);
+			}
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2570,14 +2670,18 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		/*
-		 * Shrink the slab caches in the same proportion that
-		 * the eligible LRU pages were scanned.
-		 */
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->nr_scanned - nr_scanned,
-				    node_lru_pages);
+		if (!skip_slab && global_reclaim(sc)) {
+			unsigned long numerator = nr_slab;
+			unsigned long denominator = nr_reclaim;
+			if (sc->inactive_only) {
+				numerator = sc->slab_diff;
+				denominator = sc->inactive_diff;
+			}
+			slab_reclaimed += shrink_slab(sc->gfp_mask,
+						      pgdat->node_id, NULL,
+						      numerator, denominator,
+						      &slab_scanned);
+		}
 
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2589,9 +2693,27 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
-		if (sc->nr_reclaimed - nr_reclaimed)
+		if (sc->nr_reclaimed - nr_reclaimed) {
 			reclaimable = true;
+		} else if (sc->inactive_only && !skip_slab) {
+			unsigned long percent;
 
+			/*
+			 * We didn't reclaim anything this go around, so the
+			 * inactive list is likely spent.  If we're reclaiming
+			 * less than half of the objects in slab that we're
+			 * scanning then just stop doing the inactive only scan.
+			 * Otherwise ramp up the pressure on the slab caches
+			 * hoping that eventually we'll start freeing enough
+			 * objects to reclaim space.
+			 */
+			percent = (slab_reclaimed * 100 / slab_scanned);
+			if (percent < 50)
+				sc->inactive_only = 0;
+			else
+				nr_slab <<= 1;
+		}
+		skip_slab = false;
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
@@ -3234,7 +3356,8 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
  * or lower is eligible for reclaim until at least one usable zone is
  * balanced.
  */
-static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
+static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx,
+			 unsigned long inactive_diff, unsigned long slab_diff)
 {
 	int i;
 	unsigned long nr_soft_reclaimed;
@@ -3247,6 +3370,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.inactive_only = 1,
+		.inactive_diff = inactive_diff,
+		.slab_diff = slab_diff,
 	};
 	count_vm_event(PAGEOUTRUN);
 
@@ -3466,7 +3592,7 @@ static int kswapd(void *p)
 	unsigned int classzone_idx = MAX_NR_ZONES - 1;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
+	unsigned long nr_slab = 0, nr_inactive = 0;
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
@@ -3496,6 +3622,7 @@ static int kswapd(void *p)
 	pgdat->kswapd_order = 0;
 	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
+		unsigned long slab_diff, inactive_diff;
 		bool ret;
 
 		alloc_order = reclaim_order = pgdat->kswapd_order;
@@ -3523,6 +3650,23 @@ static int kswapd(void *p)
 			continue;
 
 		/*
+		 * We want to know where we're adding pages so we can make
+		 * smarter decisions about where we're going to put pressure
+		 * when shrinking.
+		 */
+		slab_diff = sum_zone_node_page_state(pgdat->node_id,
+						     NR_SLAB_RECLAIMABLE);
+		inactive_diff = node_page_state(pgdat, NR_INACTIVE_FILE);
+		if (nr_slab > slab_diff)
+			slab_diff = 0;
+		else
+			slab_diff -= nr_slab;
+		if (inactive_diff < nr_inactive)
+			inactive_diff = 0;
+		else
+			inactive_diff -= nr_inactive;
+
+		/*
 		 * Reclaim begins at the requested order but if a high-order
 		 * reclaim fails then kswapd falls back to reclaiming for
 		 * order-0. If that happens, kswapd will consider sleeping
@@ -3532,7 +3676,11 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
-		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx,
+					      inactive_diff, slab_diff);
+		nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+		nr_slab = sum_zone_node_page_state(pgdat->node_id,
+						   NR_SLAB_RECLAIMABLE);
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
