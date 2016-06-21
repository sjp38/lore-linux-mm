Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2C4828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:18:41 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id js8so14947006lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:18:41 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id mx3si36510660wjb.10.2016.06.21.07.18.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 07:18:40 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 04BF198AB6
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:18:40 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/27] mm, workingset: Make working set detection node-aware
Date: Tue, 21 Jun 2016 15:15:53 +0100
Message-Id: <1466518566-30034-15-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Working set and refault detection is still zone-based, fix it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  6 +++---
 include/linux/vmstat.h |  1 -
 mm/vmstat.c            | 20 +++-----------------
 mm/workingset.c        | 43 ++++++++++++++++++++-----------------------
 4 files changed, 26 insertions(+), 44 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6991eded0ffd..60a1becfd256 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -145,9 +145,6 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
-	WORKINGSET_REFAULT,
-	WORKINGSET_ACTIVATE,
-	WORKINGSET_NODERECLAIM,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
@@ -162,6 +159,9 @@ enum node_stat_item {
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
+	WORKINGSET_REFAULT,
+	WORKINGSET_ACTIVATE,
+	WORKINGSET_NODERECLAIM,
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9d3a404136dd..c31f8dc6121c 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -233,7 +233,6 @@ void mod_node_page_state(struct pglist_data *, enum node_stat_item, long);
 void inc_node_page_state(struct page *, enum node_stat_item);
 void dec_node_page_state(struct page *, enum node_stat_item);
 
-extern void inc_zone_state(struct zone *, enum zone_stat_item);
 extern void inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void __inc_node_state(struct pglist_data *, enum node_stat_item);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 37442f5be39a..81da18616ce6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -445,11 +445,6 @@ void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(mod_zone_page_state);
 
-void inc_zone_state(struct zone *zone, enum zone_stat_item item)
-{
-	mod_zone_state(zone, item, 1, 1);
-}
-
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	mod_zone_state(page_zone(page), item, 1, 1);
@@ -538,15 +533,6 @@ void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 }
 EXPORT_SYMBOL(mod_zone_page_state);
 
-void inc_zone_state(struct zone *zone, enum zone_stat_item item)
-{
-	unsigned long flags;
-
-	local_irq_save(flags);
-	__inc_zone_state(zone, item);
-	local_irq_restore(flags);
-}
-
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
@@ -966,9 +952,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"workingset_refault",
-	"workingset_activate",
-	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 
@@ -981,6 +964,9 @@ const char * const vmstat_text[] = {
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_pages_scanned",
+	"workingset_refault",
+	"workingset_activate",
+	"workingset_nodereclaim",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
index 5b479890cc18..236493eaf480 100644
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
@@ -141,11 +141,11 @@
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
@@ -153,7 +153,7 @@
  */
 
 #define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
-			 ZONES_SHIFT + NODES_SHIFT +	\
+			 NODES_SHIFT +	\
 			 MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
 
@@ -167,33 +167,30 @@
  */
 static unsigned int bucket_order __read_mostly;
 
-static void *pack_shadow(int memcgid, struct zone *zone, unsigned long eviction)
+static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
 {
 	eviction >>= bucket_order;
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
-	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
-	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
+	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
 
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
-static void unpack_shadow(void *shadow, int *memcgidp, struct zone **zonep,
+static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
 			  unsigned long *evictionp)
 {
 	unsigned long entry = (unsigned long)shadow;
-	int memcgid, nid, zid;
+	int memcgid, nid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
-	zid = entry & ((1UL << ZONES_SHIFT) - 1);
-	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
 	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
 	entry >>= MEM_CGROUP_ID_SHIFT;
 
 	*memcgidp = memcgid;
-	*zonep = NODE_DATA(nid)->node_zones + zid;
+	*pgdat = NODE_DATA(nid);
 	*evictionp = entry << bucket_order;
 }
 
@@ -208,7 +205,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, struct zone **zonep,
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
 	struct mem_cgroup *memcg = page_memcg(page);
-	struct zone *zone = page_zone(page);
+	struct pglist_data *pgdat = page_pgdat(page);
 	int memcgid = mem_cgroup_id(memcg);
 	unsigned long eviction;
 	struct lruvec *lruvec;
@@ -218,9 +215,9 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	VM_BUG_ON_PAGE(page_count(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, memcg);
+	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	eviction = atomic_long_inc_return(&lruvec->inactive_age);
-	return pack_shadow(memcgid, zone, eviction);
+	return pack_shadow(memcgid, pgdat, eviction);
 }
 
 /**
@@ -228,7 +225,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
  * @shadow: shadow entry of the evicted page
  *
  * Calculates and evaluates the refault distance of the previously
- * evicted page in the context of the zone it was allocated in.
+ * evicted page in the context of the node it was allocated in.
  *
  * Returns %true if the page should be activated, %false otherwise.
  */
@@ -240,10 +237,10 @@ bool workingset_refault(void *shadow)
 	unsigned long eviction;
 	struct lruvec *lruvec;
 	unsigned long refault;
-	struct zone *zone;
+	struct pglist_data *pgdat;
 	int memcgid;
 
-	unpack_shadow(shadow, &memcgid, &zone, &eviction);
+	unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
 
 	rcu_read_lock();
 	/*
@@ -267,7 +264,7 @@ bool workingset_refault(void *shadow)
 		rcu_read_unlock();
 		return false;
 	}
-	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, memcg);
+	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
 	rcu_read_unlock();
@@ -290,10 +287,10 @@ bool workingset_refault(void *shadow)
 	 */
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
-	inc_zone_state(zone, WORKINGSET_REFAULT);
+	inc_node_state(pgdat, WORKINGSET_REFAULT);
 
 	if (refault_distance <= active_file) {
-		inc_zone_state(zone, WORKINGSET_ACTIVATE);
+		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
 		return true;
 	}
 	return false;
@@ -434,7 +431,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		}
 	}
 	BUG_ON(node->count);
-	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
+	inc_node_state(page_zone(virt_to_page(node))->zone_pgdat, WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
