Date: Tue, 6 Mar 2007 13:44:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [3/16] define is_identity_mapped
Message-Id: <20070306134438.4ba6c561.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add is_identity_map() functon and rewrite is_highmem() user to
to use is_identity_map().

(*) prepare for adding extra zone ZONE_MOVABLE.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mmzone.h     |   10 ++++++++++
 include/linux/page-flags.h |    2 +-
 kernel/power/snapshot.c    |   12 ++++++------
 kernel/power/swsusp.c      |    2 +-
 mm/page_alloc.c            |    8 ++++----
 5 files changed, 22 insertions(+), 12 deletions(-)

Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
+++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
@@ -523,6 +523,13 @@ static inline int is_normal_idx(enum zon
 	return (idx == ZONE_NORMAL);
 }
 
+static inline int is_identity_map_idx(enum zone_type idx)
+{
+	if (is_configured_zone(ZONE_HIGHMEM))
+		return (idx < ZONE_HIGHMEM);
+	else
+		return 1;
+}
 /**
  * is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
@@ -549,6 +556,14 @@ static inline int is_dma(struct zone *zo
 	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
 }
 
+static inline int is_identity_map(struct zone *zone)
+{
+	if (is_configured_zone(ZONE_HIGHMEM)
+		return zone_idx(zone) < ZONE_HIGHMEM;
+	else
+		return 1;
+}
+
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
 struct file;
Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -2090,7 +2090,7 @@ void __meminit memmap_init_zone(unsigned
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 		/* The shift won't overflow because ZONE_NORMAL is below 4G. */
-		if (!is_highmem_idx(zone))
+		if (is_identity_map_idx(zone))
 			set_page_address(page, __va(pfn << PAGE_SHIFT));
 #endif
 #ifdef CONFIG_PAGE_OWNER
@@ -2769,7 +2769,7 @@ static void __meminit free_area_init_cor
 					zone_names[0], dma_reserve);
 		}
 
-		if (!is_highmem_idx(j))
+		if (is_identity_map_idx(j))
 			nr_kernel_pages += realsize;
 		nr_all_pages += realsize;
 
@@ -3235,7 +3235,7 @@ void setup_per_zone_pages_min(void)
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
-		if (!is_highmem(zone))
+		if (is_identity_map(zone))
 			lowmem_pages += zone->present_pages;
 	}
 
@@ -3245,7 +3245,7 @@ void setup_per_zone_pages_min(void)
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		tmp = (u64)pages_min * zone->present_pages;
 		do_div(tmp, lowmem_pages);
-		if (is_highmem(zone)) {
+		if (!is_identity_map(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
 			 * need highmem pages, so cap pages_min to a small
Index: devel-tree-2.6.20-mm2/include/linux/page-flags.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/page-flags.h
+++ devel-tree-2.6.20-mm2/include/linux/page-flags.h
@@ -162,7 +162,7 @@ static inline void SetPageUptodate(struc
 #define __ClearPageSlab(page)	__clear_bit(PG_slab, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
-#define PageHighMem(page)	is_highmem(page_zone(page))
+#define PageHighMem(page)	(!is_identitiy_map(page_zone(page)))
 #else
 #define PageHighMem(page)	0 /* needed to optimize away at compile time */
 #endif
Index: devel-tree-2.6.20-mm2/kernel/power/snapshot.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/kernel/power/snapshot.c
+++ devel-tree-2.6.20-mm2/kernel/power/snapshot.c
@@ -590,7 +590,7 @@ static unsigned int count_free_highmem_p
 	unsigned int cnt = 0;
 
 	for_each_zone(zone)
-		if (populated_zone(zone) && is_highmem(zone))
+		if (populated_zone(zone) && !is_identity_map(zone))
 			cnt += zone_page_state(zone, NR_FREE_PAGES);
 
 	return cnt;
@@ -634,7 +634,7 @@ unsigned int count_highmem_pages(void)
 	for_each_zone(zone) {
 		unsigned long pfn, max_zone_pfn;
 
-		if (!is_highmem(zone))
+		if (is_identity_map(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -702,7 +702,7 @@ unsigned int count_data_pages(void)
 	unsigned int n = 0;
 
 	for_each_zone(zone) {
-		if (is_highmem(zone))
+		if (!is_identity_map(zone))
 			continue;
 
 		mark_free_pages(zone);
@@ -729,8 +729,8 @@ static inline void do_copy_page(long *ds
 static inline struct page *
 page_is_saveable(struct zone *zone, unsigned long pfn)
 {
-	return is_highmem(zone) ?
-			saveable_highmem_page(pfn) : saveable_page(pfn);
+	return is_identity_map(zone) ?
+			saveable_page(pfn) : savable_highmem_page(pfn);
 }
 
 static inline void
@@ -868,7 +868,7 @@ static int enough_free_mem(unsigned int 
 
 	for_each_zone(zone) {
 		meta += snapshot_additional_pages(zone);
-		if (!is_highmem(zone))
+		if (is_identity_map(zone))
 			free += zone_page_state(zone, NR_FREE_PAGES);
 	}
 
Index: devel-tree-2.6.20-mm2/kernel/power/swsusp.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/kernel/power/swsusp.c
+++ devel-tree-2.6.20-mm2/kernel/power/swsusp.c
@@ -229,7 +229,7 @@ int swsusp_shrink_memory(void)
 		size += highmem_size;
 		for_each_zone (zone)
 			if (populated_zone(zone)) {
-				if (is_highmem(zone)) {
+				if (!is_identity_map(zone)) {
 					highmem_size -=
 					zone_page_state(zone, NR_FREE_PAGES);
 				} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
