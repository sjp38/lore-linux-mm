Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E78176B02B4
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 11:33:08 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o142so93209906qke.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 08:33:08 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id g35si15235387qtf.380.2017.07.03.08.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 08:33:08 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id c20so23817399qte.0
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 08:33:08 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 2/4] vmscan: bailout of slab reclaim once we reach our target
Date: Mon,  3 Jul 2017 11:33:02 -0400
Message-Id: <1499095984-1942-2-git-send-email-jbacik@fb.com>
In-Reply-To: <1499095984-1942-1-git-send-email-jbacik@fb.com>
References: <1499095984-1942-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, kernel-team@fb.com, akpm@linux-foundation.org, minchan@kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

Following patches will greatly increase our aggressiveness in slab
reclaim, so we need checks in place to make sure we stop trying to
reclaim slab once we've hit our reclaim target.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 mm/vmscan.c | 35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cf23de9..77a887a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -305,11 +305,13 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
-static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
+static unsigned long do_shrink_slab(struct scan_control *sc,
+				    struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker,
 				    unsigned long nr_scanned,
 				    unsigned long nr_eligible)
 {
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long freed = 0;
 	unsigned long long delta;
 	long total_scan;
@@ -394,14 +396,18 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 		shrinkctl->nr_to_scan = nr_to_scan;
 		ret = shrinker->scan_objects(shrinker, shrinkctl);
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
 		if (ret == SHRINK_STOP)
 			break;
 		freed += ret;
-
 		count_vm_events(SLABS_SCANNED, nr_to_scan);
 		total_scan -= nr_to_scan;
 		scanned += nr_to_scan;
-
+		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
+			break;
 		cond_resched();
 	}
 
@@ -452,7 +458,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  *
  * Returns the number of reclaimed slab objects.
  */
-static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
+static unsigned long shrink_slab(struct scan_control *sc, int nid,
 				 struct mem_cgroup *memcg,
 				 unsigned long nr_scanned,
 				 unsigned long nr_eligible)
@@ -478,8 +484,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		struct shrink_control sc = {
-			.gfp_mask = gfp_mask,
+		struct shrink_control shrinkctl = {
+			.gfp_mask = sc->gfp_mask,
 			.nid = nid,
 			.memcg = memcg,
 		};
@@ -494,9 +500,12 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			continue;
 
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
-			sc.nid = 0;
+			shrinkctl.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(sc, &shrinkctl, shrinker, nr_scanned,
+					nr_eligible);
+		if (sc->nr_to_reclaim <= sc->nr_reclaimed)
+			break;
 	}
 
 	up_read(&shrinker_rwsem);
@@ -510,11 +519,15 @@ void drop_slab_node(int nid)
 	unsigned long freed;
 
 	do {
+		struct scan_control sc = {
+			.nr_to_reclaim = -1UL,
+			.gfp_mask = GFP_KERNEL,
+		};
 		struct mem_cgroup *memcg = NULL;
 
 		freed = 0;
 		do {
-			freed += shrink_slab(GFP_KERNEL, nid, memcg,
+			freed += shrink_slab(&sc, nid, memcg,
 					     1000, 1000);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
 	} while (freed > 10);
@@ -2600,7 +2613,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			node_lru_pages += lru_pages;
 
 			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
+				shrink_slab(sc, pgdat->node_id,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
@@ -2631,7 +2644,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		 * the eligible LRU pages were scanned.
 		 */
 		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
+			shrink_slab(sc, pgdat->node_id, NULL,
 				    sc->nr_scanned - nr_scanned,
 				    node_lru_pages);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
