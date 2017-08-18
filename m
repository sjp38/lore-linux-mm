Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F1CDB6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:28:51 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k67so47364191qkh.2
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:28:51 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id u125si5181602qkc.97.2017.08.18.07.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 07:28:50 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id x77so8854473qka.4
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:28:50 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 1/2][RESEND] mm: use sc->priority for slab shrink targets
Date: Fri, 18 Aug 2017 10:28:47 -0400
Message-Id: <1503066528-1833-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Previously we were using the ratio of the number of lru pages scanned to
the number of eligible lru pages to determine the number of slab objects
to scan.  The problem with this is that these two things have nothing to
do with each other, so in slab heavy work loads where there is little to
no page cache we can end up with the pages scanned being a very low
number.  This means that we reclaim next to no slab pages and waste a
lot of time reclaiming small amounts of space.

Instead use sc->priority in the same way we use it to determine scan
amounts for the lru's.  This generally equates to pages.  Consider the
following

slab_pages = (nr_objects * object_size) / PAGE_SIZE

What we would like to do is

scan = slab_pages >> sc->priority

but we don't know the number of slab pages each shrinker controls, only
the objects.  However say that theoretically we knew how many pages a
shrinker controlled, we'd still have to convert this to objects, which
would look like the following

scan = shrinker_pages >> sc->priority
scan_objects = (PAGE_SIZE / object_size) * scan

or written another way

scan_objects = (shrinker_pages >> sc->priority) *
		(PAGE_SIZE / object_size)

which can thus be written

scan_objects = ((shrinker_pages * PAGE_SIZE) / object_size) >>
		sc->priority

which is just

scan_objects = nr_objects >> sc->priority

We don't need to know exactly how many pages each shrinker represents,
it's objects are all the information we need.  Making this change allows
us to place an appropriate amount of pressure on the shrinker pools for
their relative size.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/trace/events/vmscan.h | 23 ++++++++++------------
 mm/vmscan.c                   | 46 +++++++++++--------------------------------
 2 files changed, 22 insertions(+), 47 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 27e8a5c..8c5a00a 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -187,12 +187,12 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
 
 TRACE_EVENT(mm_shrink_slab_start,
 	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
-		long nr_objects_to_shrink, unsigned long pgs_scanned,
-		unsigned long lru_pgs, unsigned long cache_items,
-		unsigned long long delta, unsigned long total_scan),
+		long nr_objects_to_shrink, unsigned long cache_items,
+		unsigned long long delta, unsigned long total_scan,
+		int priority),
 
-	TP_ARGS(shr, sc, nr_objects_to_shrink, pgs_scanned, lru_pgs,
-		cache_items, delta, total_scan),
+	TP_ARGS(shr, sc, nr_objects_to_shrink, cache_items, delta, total_scan,
+		priority),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
@@ -200,11 +200,10 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__field(int, nid)
 		__field(long, nr_objects_to_shrink)
 		__field(gfp_t, gfp_flags)
-		__field(unsigned long, pgs_scanned)
-		__field(unsigned long, lru_pgs)
 		__field(unsigned long, cache_items)
 		__field(unsigned long long, delta)
 		__field(unsigned long, total_scan)
+		__field(int, priority)
 	),
 
 	TP_fast_assign(
@@ -213,24 +212,22 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->nid = sc->nid;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
-		__entry->pgs_scanned = pgs_scanned;
-		__entry->lru_pgs = lru_pgs;
 		__entry->cache_items = cache_items;
 		__entry->delta = delta;
 		__entry->total_scan = total_scan;
+		__entry->priority = priority;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
 		__entry->nr_objects_to_shrink,
 		show_gfp_flags(__entry->gfp_flags),
-		__entry->pgs_scanned,
-		__entry->lru_pgs,
 		__entry->cache_items,
 		__entry->delta,
-		__entry->total_scan)
+		__entry->total_scan,
+		__entry->priority)
 );
 
 TRACE_EVENT(mm_shrink_slab_end,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 734e8d3..608dfe6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -306,9 +306,7 @@ EXPORT_SYMBOL(unregister_shrinker);
 #define SHRINK_BATCH 128
 
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
-				    struct shrinker *shrinker,
-				    unsigned long nr_scanned,
-				    unsigned long nr_eligible)
+				    struct shrinker *shrinker, int priority)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -333,9 +331,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = (4 * nr_scanned) / shrinker->seeks;
-	delta *= freeable;
-	do_div(delta, nr_eligible + 1);
+	delta = freeable >> priority;
+	delta = (4 * freeable) / shrinker->seeks;
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
@@ -369,8 +366,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		total_scan = freeable * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				   nr_scanned, nr_eligible,
-				   freeable, delta, total_scan);
+				   freeable, delta, total_scan, priority);
 
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
@@ -429,8 +425,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * @gfp_mask: allocation context
  * @nid: node whose slab caches to target
  * @memcg: memory cgroup whose slab caches to target
- * @nr_scanned: pressure numerator
- * @nr_eligible: pressure denominator
+ * @priority: the reclaim priority
  *
  * Call the shrink functions to age shrinkable caches.
  *
@@ -442,20 +437,14 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * objects from the memory cgroup specified. Otherwise, only unaware
  * shrinkers are called.
  *
- * @nr_scanned and @nr_eligible form a ratio that indicate how much of
- * the available objects should be scanned.  Page reclaim for example
- * passes the number of pages scanned and the number of pages on the
- * LRU lists that it considered on @nid, plus a bias in @nr_scanned
- * when it encountered mapped pages.  The ratio is further biased by
- * the ->seeks setting of the shrink function, which indicates the
- * cost to recreate an object relative to that of an LRU page.
+ * @priority is sc->priority, we take the number of objects and >> by priority
+ * in order to get the scan target.
  *
  * Returns the number of reclaimed slab objects.
  */
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
-				 unsigned long nr_scanned,
-				 unsigned long nr_eligible)
+				 int priority)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
@@ -463,9 +452,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
-	if (nr_scanned == 0)
-		nr_scanned = SWAP_CLUSTER_MAX;
-
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
 		 * If we would return 0, our callers would understand that we
@@ -496,7 +482,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(&sc, shrinker, priority);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -514,8 +500,7 @@ void drop_slab_node(int nid)
 
 		freed = 0;
 		do {
-			freed += shrink_slab(GFP_KERNEL, nid, memcg,
-					     1000, 1000);
+			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
 }
@@ -2610,14 +2595,12 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
-
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
 			if (memcg)
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+					    memcg, sc->priority);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2641,14 +2624,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		/*
-		 * Shrink the slab caches in the same proportion that
-		 * the eligible LRU pages were scanned.
-		 */
 		if (global_reclaim(sc))
 			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->nr_scanned - nr_scanned,
-				    node_lru_pages);
+				    sc->priority);
 
 		/*
 		 * Record the subtree's reclaim efficiency. The reclaimed
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
