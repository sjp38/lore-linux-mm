Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98394280725
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:35:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 57so34524286qtu.4
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:35:50 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id n186si14209323qkd.76.2017.08.22.12.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 12:35:49 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id u139so10005995qka.3
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:35:49 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 2/2][v2] mm: make kswapd try harder to keep active pages in cache
Date: Tue, 22 Aug 2017 15:35:39 -0400
Message-Id: <1503430539-2878-2-git-send-email-jbacik@fb.com>
In-Reply-To: <1503430539-2878-1-git-send-email-jbacik@fb.com>
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com, aryabinin@virtuozzo.com
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

While testing slab reclaim I noticed that if we were running a workload
that used most of the system memory for it's working set and we start
putting a lot of reclaimable slab pressure on the system (think find /,
or some other silliness), we will happily evict the active pages over
the slab cache.  This is kind of backwards as we want to do all that we
can to keep the active working set in memory, and instead evict these
short lived objects.  The same thing occurs when say you do a yum
update of a few packages while your working set takes up most of RAM,
you end up with inactive lists being relatively small and so we reclaim
active pages even though we could reclaim these short lived inactive
pages.

My approach here is twofold.  First, keep track of the difference in
inactive and slab pages since the last time kswapd ran.  In the first
run this will just be the overall counts of inactive and slab, but for
each subsequent run we'll have a good idea of where the memory pressure
is coming from.  Then we use this information to put pressure on either
the inactive lists or the slab caches, depending on where the pressure
is coming from.

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
v1->v2:
- fix getting the NR_SLAB_RECLAIMABLE counts.
- fix initialization of the scan_control in __node_reclaim

 mm/vmscan.c | 169 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 155 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 608dfe6..be52b25 100644
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
@@ -306,7 +315,8 @@ EXPORT_SYMBOL(unregister_shrinker);
 #define SHRINK_BATCH 128
 
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
-				    struct shrinker *shrinker, int priority)
+				    struct shrinker *shrinker, int priority,
+				    unsigned long *slab_scanned)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -405,6 +415,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		next_deferred -= scanned;
 	else
 		next_deferred = 0;
+	if (slab_scanned)
+		(*slab_scanned) += scanned;
+
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
@@ -444,7 +457,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  */
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
-				 int priority)
+				 int priority, unsigned long *slab_scanned)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
@@ -482,7 +495,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, priority);
+		freed += do_shrink_slab(&sc, shrinker, priority, slab_scanned);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -500,7 +513,7 @@ void drop_slab_node(int nid)
 
 		freed = 0;
 		do {
-			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
+			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0, NULL);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
 }
@@ -2149,6 +2162,7 @@ enum scan_balance {
 	SCAN_FRACT,
 	SCAN_ANON,
 	SCAN_FILE,
+	SCAN_INACTIVE,
 };
 
 /*
@@ -2175,6 +2189,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
@@ -2348,6 +2367,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 				scan = 0;
 			}
 			break;
+		case SCAN_INACTIVE:
+			if (file && !is_active_lru(lru)) {
+				scan = max(scan, sc->nr_to_reclaim);
+			} else {
+				size = 0;
+				scan = 0;
+			}
+			break;
 		default:
 			/* Look ma, no brain */
 			BUG();
@@ -2565,7 +2592,61 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
+	unsigned long greclaim = 1, gslab = 1, total_high_wmark = 0, nr_inactive;
+	int priority_adj = 1;
 	bool reclaimable = false;
+	bool skip_slab = false;
+
+	if (global_reclaim(sc)) {
+		int z;
+		for (z = 0; z < MAX_NR_ZONES; z++) {
+			struct zone *zone = &pgdat->node_zones[z];
+			if (!managed_zone(zone))
+				continue;
+			total_high_wmark += high_wmark_pages(zone);
+		}
+		nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+		gslab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
+		greclaim = pgdat_reclaimable_pages(pgdat);
+	} else {
+		struct lruvec *lruvec =
+			mem_cgroup_lruvec(pgdat, sc->target_mem_cgroup);
+		total_high_wmark = sc->nr_to_reclaim;
+		nr_inactive = lruvec_page_state(lruvec, NR_INACTIVE_FILE);
+		gslab = lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
+	}
+
+	/*
+	 * If we don't have a lot of inactive or slab pages then there's no
+	 * point in trying to free them exclusively, do the normal scan stuff.
+	 */
+	if (nr_inactive + gslab < total_high_wmark)
+		sc->inactive_only = 0;
+
+	/*
+	 * We still want to slightly prefer slab over inactive, so if the
+	 * inactive on this node is large enough and what is pushing us into
+	 * reclaim territory then limit our flushing to the inactive list for
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
@@ -2574,6 +2655,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			.priority = sc->priority,
 		};
 		unsigned long node_lru_pages = 0;
+		unsigned long slab_reclaimed = 0;
+		unsigned long slab_scanned = 0;
 		struct mem_cgroup *memcg;
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2598,9 +2681,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->priority);
+			if (memcg && !skip_slab) {
+				int priority = sc->priority;
+				if (sc->inactive_only)
+					priority -= priority_adj;
+				priority = max(0, priority);
+				slab_reclaimed +=
+					shrink_slab(sc->gfp_mask,
+						    pgdat->node_id, memcg,
+						    priority, &slab_scanned);
+			}
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2624,9 +2714,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->priority);
+		if (!skip_slab && global_reclaim(sc)) {
+			int priority = sc->priority;
+			if (sc->inactive_only)
+				priority -= priority_adj;
+			priority = max(0, priority);
+			slab_reclaimed +=
+				shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
+					    priority, &slab_scanned);
+		}
+
 
 		/*
 		 * Record the subtree's reclaim efficiency. The reclaimed
@@ -2645,9 +2742,28 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			reclaim_state->reclaimed_slab = 0;
 		}
 
-		if (sc->nr_reclaimed - nr_reclaimed)
+		if (sc->nr_reclaimed - nr_reclaimed) {
 			reclaimable = true;
+		} else if (sc->inactive_only && !skip_slab) {
+			unsigned long percent = 0;
 
+			/*
+			 * We didn't reclaim anything this go around, so the
+			 * inactive list is likely spent.  If we're reclaiming
+			 * less than half of the objects in slab that we're
+			 * scanning then just stop doing the inactive only scan.
+			 * Otherwise ramp up the pressure on the slab caches
+			 * hoping that eventually we'll start freeing enough
+			 * objects to reclaim space.
+			 */
+			if (slab_scanned)
+				percent = slab_reclaimed * 100 / slab_scanned;
+			if (percent < 50)
+				sc->inactive_only = 0;
+			else
+				priority_adj++;
+		}
+		skip_slab = false;
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
@@ -3290,7 +3406,8 @@ static bool kswapd_shrink_node(pg_data_t *pgdat,
  * or lower is eligible for reclaim until at least one usable zone is
  * balanced.
  */
-static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
+static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx,
+			 unsigned long inactive_diff, unsigned long slab_diff)
 {
 	int i;
 	unsigned long nr_soft_reclaimed;
@@ -3303,6 +3420,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.inactive_only = 1,
+		.inactive_diff = inactive_diff,
+		.slab_diff = slab_diff,
 	};
 	count_vm_event(PAGEOUTRUN);
 
@@ -3522,7 +3642,7 @@ static int kswapd(void *p)
 	unsigned int classzone_idx = MAX_NR_ZONES - 1;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
+	unsigned long nr_slab = 0, nr_inactive = 0;
 	struct reclaim_state reclaim_state = {
 		.reclaimed_slab = 0,
 	};
@@ -3552,6 +3672,7 @@ static int kswapd(void *p)
 	pgdat->kswapd_order = 0;
 	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
+		unsigned long slab_diff, inactive_diff;
 		bool ret;
 
 		alloc_order = reclaim_order = pgdat->kswapd_order;
@@ -3579,6 +3700,22 @@ static int kswapd(void *p)
 			continue;
 
 		/*
+		 * We want to know where we're adding pages so we can make
+		 * smarter decisions about where we're going to put pressure
+		 * when shrinking.
+		 */
+		slab_diff = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
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
@@ -3588,7 +3725,10 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
-		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx,
+					      inactive_diff, slab_diff);
+		nr_inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
+		nr_slab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
 	}
@@ -3840,6 +3980,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
 		.reclaim_idx = gfp_zone(gfp_mask),
+		.inactive_only = 1,
 	};
 
 	cond_resched();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
