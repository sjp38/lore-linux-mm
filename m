Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8816E6B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 15:19:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m57so15878106qta.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 12:19:11 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id n19si6300613qta.256.2017.06.08.12.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 12:19:08 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id s33so10385636qtg.3
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 12:19:08 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 1/2] mm: use slab size in the slab shrinking ratio calculation
Date: Thu,  8 Jun 2017 15:19:05 -0400
Message-Id: <1496949546-2223-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

When testing a slab heavy workload I noticed that we often would barely
reclaim anything at all from slab when kswapd started doing reclaim.
This is because we use the ratio of nr_scanned / nr_lru to determine how
much of slab we should reclaim.  But in a slab only/mostly workload we
will not have much page cache to reclaim, and thus our ratio will be
really low and not at all related to where the memory on the system is.
Instead we want to use a ratio of the reclaimable slab to the actual
reclaimable space on the system.  That way if we are slab heavy we work
harder to reclaim slab.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/vmscan.c | 71 +++++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 43 insertions(+), 28 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f84cdd3..16add44 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -307,8 +307,8 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker,
-				    unsigned long nr_scanned,
-				    unsigned long nr_eligible)
+				    unsigned long numerator,
+				    unsigned long denominator)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -333,9 +333,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = (4 * nr_scanned) / shrinker->seeks;
+	delta = (4 * numerator) / shrinker->seeks;
 	delta *= freeable;
-	do_div(delta, nr_eligible + 1);
+	do_div(delta, denominator + 1);
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
@@ -369,7 +369,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		total_scan = freeable * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				   nr_scanned, nr_eligible,
+				   numerator, denominator,
 				   freeable, delta, total_scan);
 
 	/*
@@ -429,8 +429,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * @gfp_mask: allocation context
  * @nid: node whose slab caches to target
  * @memcg: memory cgroup whose slab caches to target
- * @nr_scanned: pressure numerator
- * @nr_eligible: pressure denominator
+ * @numerator: pressure numerator
+ * @denominator: pressure denominator
  *
  * Call the shrink functions to age shrinkable caches.
  *
@@ -442,20 +442,16 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
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
+ * @numerator and @denominator form a ratio that indicate how much of
+ * the available objects should be scanned.  Global reclaim for example will do
+ * the ratio of reclaimable slab to the lru sizes.
  *
  * Returns the number of reclaimed slab objects.
  */
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
-				 unsigned long nr_scanned,
-				 unsigned long nr_eligible)
+				 unsigned long numerator,
+				 unsigned long denominator)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
@@ -463,9 +459,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
-	if (nr_scanned == 0)
-		nr_scanned = SWAP_CLUSTER_MAX;
-
 	if (!down_read_trylock(&shrinker_rwsem)) {
 		/*
 		 * If we would return 0, our callers would understand that we
@@ -496,7 +489,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(&sc, shrinker, numerator, denominator);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -2558,12 +2551,34 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	return true;
 }
 
+static unsigned long lruvec_reclaimable_pages(struct lruvec *lruvec)
+{
+	unsigned long nr;
+
+	nr = lruvec_page_state(lruvec, NR_ACTIVE_FILE) +
+	     lruvec_page_state(lruvec, NR_INACTIVE_FILE) +
+	     lruvec_page_state(lruvec, NR_ISOLATED_FILE);
+
+	if (get_nr_swap_pages() > 0)
+		nr += lruvec_page_state(lruvec, NR_ACTIVE_ANON) +
+		      lruvec_page_state(lruvec, NR_INACTIVE_ANON) +
+		      lruvec_page_state(lruvec, NR_ISOLATED_ANON);
+
+	return nr;
+}
+
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
+	unsigned long greclaim = 1, gslab = 1;
 	bool reclaimable = false;
 
+	if (global_reclaim(sc)) {
+		gslab = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
+		greclaim = pgdat_reclaimable_pages(pgdat);
+	}
+
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
@@ -2578,6 +2593,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
+			struct lruvec *lruvec = mem_cgroup_lruvec(pgdat,
+								  memcg);
+			unsigned long nr_slab, nr_reclaim;
 			unsigned long lru_pages;
 			unsigned long reclaimed;
 			unsigned long scanned;
@@ -2592,14 +2610,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
+			nr_slab = lruvec_page_state(lruvec,
+						    NR_SLAB_RECLAIMABLE);
+			nr_reclaim = lruvec_reclaimable_pages(lruvec);
 
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
 			if (memcg)
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+					    memcg, nr_slab, nr_reclaim);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2623,14 +2643,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
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
+				    gslab, greclaim);
 
 		/*
 		 * Record the subtree's reclaim efficiency. The reclaimed
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
