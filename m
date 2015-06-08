Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7AB900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:02 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so87297533wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si1314946wix.79.2015.06.08.06.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:55 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/25] mm, workingset: Make working set detection node-aware
Date: Mon,  8 Jun 2015 14:56:17 +0100
Message-Id: <1433771791-30567-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Working set and refault detection is still zone-based, fix it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  6 +++---
 mm/vmstat.c            |  6 +++---
 mm/workingset.c        | 47 +++++++++++++++++++++--------------------------
 3 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1830c2180555..4c761809d151 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -143,9 +143,6 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
-	WORKINGSET_REFAULT,
-	WORKINGSET_ACTIVATE,
-	WORKINGSET_NODERECLAIM,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
@@ -160,6 +157,9 @@ enum node_stat_item {
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
+	WORKINGSET_REFAULT,
+	WORKINGSET_ACTIVATE,
+	WORKINGSET_NODERECLAIM,
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 36897da22792..054ee50974c9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,9 +921,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"workingset_refault",
-	"workingset_activate",
-	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 
@@ -936,6 +933,9 @@ const char * const vmstat_text[] = {
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_pages_scanned",
+	"workingset_refault",
+	"workingset_activate",
+	"workingset_nodereclaim",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
index ca080cc11797..1cc71f1ca7fc 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -16,7 +16,7 @@
 /*
  *		Double CLOCK lists
  *
- * Per zone, two clock lists are maintained for file pages: the
+ * Per node, two clock lists are maintained for file pages: the
  * inactive and the active list.  Freshly faulted pages start out at
  * the head of the inactive list and page reclaim scans pages from the
  * tail.  Pages that are accessed multiple times on the inactive list
@@ -141,48 +141,43 @@
  *
  *		Implementation
  *
- * For each zone's file LRU lists, a counter for inactive evictions
- * and activations is maintained (zone->inactive_age).
+ * For each node's file LRU lists, a counter for inactive evictions
+ * and activations is maintained (node->inactive_age).
  *
  * On eviction, a snapshot of this counter (along with some bits to
- * identify the zone) is stored in the now empty page cache radix tree
+ * identify the node) is stored in the now empty page cache radix tree
  * slot of the evicted page.  This is called a shadow entry.
  *
  * On cache misses for which there are shadow entries, an eligible
  * refault distance will immediately activate the refaulting page.
  */
 
-static void *pack_shadow(unsigned long eviction, struct zone *zone)
+static void *pack_shadow(unsigned long eviction, struct pglist_data *pgdat)
 {
-	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
-	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
+	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
 
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
 static void unpack_shadow(void *shadow,
-			  struct zone **zone,
+			  struct pglist_data **pgdat,
 			  unsigned long *distance)
 {
 	unsigned long entry = (unsigned long)shadow;
 	unsigned long eviction;
 	unsigned long refault;
 	unsigned long mask;
-	int zid, nid;
+	int nid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
-	zid = entry & ((1UL << ZONES_SHIFT) - 1);
-	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
 	eviction = entry;
 
-	*zone = NODE_DATA(nid)->node_zones + zid;
-
-	refault = atomic_long_read(&(*zone)->zone_pgdat->inactive_age);
-	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
-			RADIX_TREE_EXCEPTIONAL_SHIFT);
+	*pgdat = NODE_DATA(nid);
+	refault = atomic_long_read(&(*pgdat)->inactive_age);
+	mask = ~0UL >> (NODES_SHIFT + RADIX_TREE_EXCEPTIONAL_SHIFT);
 	/*
 	 * The unsigned subtraction here gives an accurate distance
 	 * across inactive_age overflows in most cases.
@@ -212,11 +207,11 @@ static void unpack_shadow(void *shadow,
  */
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct pglist_data *pgdat = page_zone(page)->zone_pgdat;
 	unsigned long eviction;
 
-	eviction = atomic_long_inc_return(&zone->zone_pgdat->inactive_age);
-	return pack_shadow(eviction, zone);
+	eviction = atomic_long_inc_return(&pgdat->inactive_age);
+	return pack_shadow(eviction, pgdat);
 }
 
 /**
@@ -224,20 +219,20 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
  * @shadow: shadow entry of the evicted page
  *
  * Calculates and evaluates the refault distance of the previously
- * evicted page in the context of the zone it was allocated in.
+ * evicted page in the context of the node it was allocated in.
  *
  * Returns %true if the page should be activated, %false otherwise.
  */
 bool workingset_refault(void *shadow)
 {
 	unsigned long refault_distance;
-	struct zone *zone;
+	struct pglist_data *pgdat;
 
-	unpack_shadow(shadow, &zone, &refault_distance);
-	inc_zone_state(zone, WORKINGSET_REFAULT);
+	unpack_shadow(shadow, &pgdat, &refault_distance);
+	inc_node_state(pgdat, WORKINGSET_REFAULT);
 
-	if (refault_distance <= node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE)) {
-		inc_zone_state(zone, WORKINGSET_ACTIVATE);
+	if (refault_distance <= node_page_state(pgdat, NR_ACTIVE_FILE)) {
+		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
 		return true;
 	}
 	return false;
@@ -356,7 +351,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		}
 	}
 	BUG_ON(node->count);
-	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
+	inc_node_state(page_zone(virt_to_page(node))->zone_pgdat, WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
 
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
