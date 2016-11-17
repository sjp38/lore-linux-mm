Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 614446B035E
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:47:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so59622161wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:47:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bz3si4645072wjc.141.2016.11.17.13.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 13:47:11 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: workingset: update shadow limit to reflect bigger active list
Date: Thu, 17 Nov 2016 16:47:01 -0500
Message-Id: <20161117214701.29000-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Since 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list")
the size of the active file list is no longer limited to half of
memory. Increase the shadow node limit accordingly to avoid throwing
out shadow entries that might still result in eligible refaults.

The exact size of the active list now depends on the overall size of
the page cache, but converges toward taking up most of the space:

>From mm/vmscan.c::inactive_list_is_low(),

 * total     target    max
 * memory    ratio     inactive
 * -------------------------------------
 *   10MB       1         5MB
 *  100MB       1        50MB
 *    1GB       3       250MB
 *   10GB      10       0.9GB
 *  100GB      31         3GB
 *    1TB     101        10GB
 *   10TB     320        32GB

It would be possible to apply the same precise ratios when determining
the limit for radix tree nodes containing shadow entries, but since it
is merely an approximation of the oldest refault distances in the wild
and the code also makes assumptions about the node population density,
keep it simple and always target the full cache size.

While at it, clarify the comment and the formula for memory footprint.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 44 +++++++++++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 19 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 111e06559892..02ab8746abde 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -369,40 +369,46 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 {
 	unsigned long max_nodes;
 	unsigned long nodes;
-	unsigned long pages;
+	unsigned long cache;
 
 	/* list_lru lock nests inside IRQ-safe mapping->tree_lock */
 	local_irq_disable();
 	nodes = list_lru_shrink_count(&shadow_nodes, sc);
 	local_irq_enable();
 
-	if (memcg_kmem_enabled()) {
-		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
-						     LRU_ALL_FILE);
-	} else {
-		pages = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
-			node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
-	}
-
 	/*
-	 * Active cache pages are limited to 50% of memory, and shadow
-	 * entries that represent a refault distance bigger than that
-	 * do not have any effect.  Limit the number of shadow nodes
-	 * such that shadow entries do not exceed the number of active
-	 * cache pages, assuming a worst-case node population density
-	 * of 1/8th on average.
+	 * Approximate a reasonable limit for the radix tree nodes
+	 * containing shadow entries. We don't need to keep more
+	 * shadow entries than possible pages on the active list,
+	 * since refault distances bigger than that are dismissed.
+	 *
+	 * The size of the active list converges toward 100% of
+	 * overall page cache as memory grows, with only a tiny
+	 * inactive list. Assume the total cache size for that.
+	 *
+	 * Nodes might be sparsely populated, with only one shadow
+	 * entry in the extreme case. Obviously, we cannot keep one
+	 * node for every eligible shadow entry, so compromise on a
+	 * worst-case density of 1/8th. Below that, not all eligible
+	 * refaults can be detected anymore.
 	 *
 	 * On 64-bit with 7 radix_tree_nodes per page and 64 slots
 	 * each, this will reclaim shadow entries when they consume
-	 * ~2% of available memory:
+	 * ~1.8% of available memory:
 	 *
-	 * PAGE_SIZE / radix_tree_nodes / node_entries / PAGE_SIZE
+	 * PAGE_SIZE / radix_tree_nodes / node_entries * 8 / PAGE_SIZE
 	 */
-	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
+	if (memcg_kmem_enabled()) {
+		cache = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
+						     LRU_ALL_FILE);
+	} else {
+		cache = node_page_state(NODE_DATA(sc->nid), NR_ACTIVE_FILE) +
+			node_page_state(NODE_DATA(sc->nid), NR_INACTIVE_FILE);
+	}
+	max_nodes = cache >> (RADIX_TREE_MAP_SHIFT - 3);
 
 	if (nodes <= max_nodes)
 		return 0;
-
 	return nodes - max_nodes;
 }
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
