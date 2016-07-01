Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35EA6828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:40:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so21791955wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:40:22 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id nj9si3991484wjb.213.2016.07.01.08.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:40:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 9B2E51C221C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:40:20 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 14/31] mm, workingset: make working set detection node-aware
Date: Fri,  1 Jul 2016 16:37:29 +0100
Message-Id: <1467387466-10022-15-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Working set and refault detection is still zone-based, fix it.

Link: http://lkml.kernel.org/r/1466518566-30034-15-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mmzone.h |  6 +++---
 include/linux/vmstat.h |  1 -
 mm/vmstat.c            | 20 +++-----------------
 mm/workingset.c        | 43 ++++++++++++++++++++-----------------------
 4 files changed, 26 insertions(+), 44 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f88cbbb476c8..08e0dc9cd7cd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -145,9 +145,6 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
-	WORKINGSET_REFAULT,
-	WORKINGSET_ACTIVATE,
-	WORKINGSET_NODERECLAIM,
 	NR_ANON_THPS,
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
@@ -164,6 +161,9 @@ enum node_stat_item {
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
+	WORKINGSET_REFAULT,
+	WORKINGSET_ACTIVATE,
+	WORKINGSET_NODERECLAIM,
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index ced0c3e9da88..552d0db4fca2 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -227,7 +227,6 @@ void mod_node_page_state(struct pglist_data *, enum node_stat_item, long);
 void inc_node_page_state(struct page *, enum node_stat_item);
 void dec_node_page_state(struct page *, enum node_stat_item);
 
-extern void inc_zone_state(struct zone *, enum zone_stat_item);
 extern void inc_node_state(struct pglist_data *, enum node_stat_item);
 extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void __inc_node_state(struct pglist_data *, enum node_stat_item);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2eab7903c5c2..89426c250a9a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -433,11 +433,6 @@ void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
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
@@ -526,15 +521,6 @@ void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
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
@@ -954,9 +940,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"workingset_refault",
-	"workingset_activate",
-	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
@@ -971,6 +954,9 @@ const char * const vmstat_text[] = {
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"nr_pages_scanned",
+	"workingset_refault",
+	"workingset_activate",
+	"workingset_nodereclaim",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
index 9a1016f5d500..56334e7d6924 100644
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
@@ -436,7 +433,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 		}
 	}
 	BUG_ON(node->count);
-	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
+	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
