Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 229136B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 22:27:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e3-v6so7193356pld.13
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 19:27:26 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k5-v6si3407780pgr.511.2018.10.03.19.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 19:27:24 -0700 (PDT)
Subject: [PATCH v2 2/3] mm: Move buddy list manipulations into helpers
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Oct 2018 19:15:29 -0700
Message-ID: <153861932911.2863953.7518554698135022474.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, keescook@chromium.org

In preparation for runtime randomization of the zone lists, take all
(well, most of) the list_*() functions in the buddy allocator and put
them in helper functions. Provide a common control point for injecting
additional behavior when freeing pages.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h       |    3 --
 include/linux/mm_types.h |    3 ++
 include/linux/mmzone.h   |   51 ++++++++++++++++++++++++++++++++++
 mm/compaction.c          |    4 +--
 mm/page_alloc.c          |   70 ++++++++++++++++++----------------------------
 5 files changed, 84 insertions(+), 47 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ca1581814fe2..1d19ec6a2b81 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -473,9 +473,6 @@ static inline void vma_set_anonymous(struct vm_area_struct *vma)
 struct mmu_gather;
 struct inode;
 
-#define page_private(page)		((page)->private)
-#define set_page_private(page, v)	((page)->private = (v))
-
 #if !defined(__HAVE_ARCH_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline int pmd_devmap(pmd_t pmd)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cd2bc939efd0..191610be62bd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -209,6 +209,9 @@ struct page {
 #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
 #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
 
+#define page_private(page)		((page)->private)
+#define set_page_private(page, v)	((page)->private = (v))
+
 struct page_frag_cache {
 	void * va;
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8f8fc7dab5cb..adf9b3a7440d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -18,6 +18,8 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -98,6 +100,55 @@ struct free_area {
 	unsigned long		nr_free;
 };
 
+/* Used for pages not on another list */
+static inline void add_to_free_area(struct page *page, struct free_area *area,
+			     int migratetype)
+{
+	list_add(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages not on another list */
+static inline void add_to_free_area_tail(struct page *page, struct free_area *area,
+				  int migratetype)
+{
+	list_add_tail(&page->lru, &area->free_list[migratetype]);
+	area->nr_free++;
+}
+
+/* Used for pages which are on another list */
+static inline void move_to_free_area(struct page *page, struct free_area *area,
+			     int migratetype)
+{
+	list_move(&page->lru, &area->free_list[migratetype]);
+}
+
+static inline struct page *get_page_from_free_area(struct free_area *area,
+					    int migratetype)
+{
+	return list_first_entry_or_null(&area->free_list[migratetype],
+					struct page, lru);
+}
+
+static inline void rmv_page_order(struct page *page)
+{
+	__ClearPageBuddy(page);
+	set_page_private(page, 0);
+}
+
+static inline void del_page_from_free_area(struct page *page,
+		struct free_area *area, int migratetype)
+{
+	list_del(&page->lru);
+	rmv_page_order(page);
+	area->nr_free--;
+}
+
+static inline bool free_area_empty(struct free_area *area, int migratetype)
+{
+	return list_empty(&area->free_list[migratetype]);
+}
+
 struct pglist_data;
 
 /*
diff --git a/mm/compaction.c b/mm/compaction.c
index faca45ebe62d..48736044f682 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1358,13 +1358,13 @@ static enum compact_result __compact_finished(struct zone *zone,
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (!free_area_empty(area, migratetype))
 			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+			!free_area_empty(area, MIGRATE_CMA))
 			return COMPACT_SUCCESS;
 #endif
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9a1d97655c19..b4a1598fcab5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -705,12 +705,6 @@ static inline void set_page_order(struct page *page, unsigned int order)
 	__SetPageBuddy(page);
 }
 
-static inline void rmv_page_order(struct page *page)
-{
-	__ClearPageBuddy(page);
-	set_page_private(page, 0);
-}
-
 /*
  * This function checks whether a page is free && is the buddy
  * we can coalesce a page and its buddy if
@@ -811,13 +805,11 @@ static inline void __free_one_page(struct page *page,
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
 		 */
-		if (page_is_guard(buddy)) {
+		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
-		} else {
-			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
-			rmv_page_order(buddy);
-		}
+		else
+			del_page_from_free_area(buddy, &zone->free_area[order],
+					migratetype);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -867,15 +859,13 @@ static inline void __free_one_page(struct page *page,
 		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (pfn_valid_within(buddy_pfn) &&
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
-			goto out;
+			add_to_free_area_tail(page, &zone->free_area[order],
+					      migratetype);
+			return;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
-out:
-	zone->free_area[order].nr_free++;
+	add_to_free_area(page, &zone->free_area[order], migratetype);
 }
 
 /*
@@ -1977,7 +1967,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		add_to_free_area(&page[size], area, migratetype);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -2119,13 +2109,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
-		page = list_first_entry_or_null(&area->free_list[migratetype],
-							struct page, lru);
+		page = get_page_from_free_area(area, migratetype);
 		if (!page)
 			continue;
-		list_del(&page->lru);
-		rmv_page_order(page);
-		area->nr_free--;
+		del_page_from_free_area(page, area, migratetype);
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -2215,8 +2202,7 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+		move_to_free_area(page, &zone->free_area[order], migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2365,7 +2351,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	move_to_free_area(page, area, start_type);
 }
 
 /*
@@ -2389,7 +2375,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (free_area_empty(area, fallback_mt))
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2476,9 +2462,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &(zone->free_area[order]);
 
-			page = list_first_entry_or_null(
-					&area->free_list[MIGRATE_HIGHATOMIC],
-					struct page, lru);
+			page = get_page_from_free_area(area, MIGRATE_HIGHATOMIC);
 			if (!page)
 				continue;
 
@@ -2591,8 +2575,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	VM_BUG_ON(current_order == MAX_ORDER);
 
 do_steal:
-	page = list_first_entry(&area->free_list[fallback_mt],
-							struct page, lru);
+	page = get_page_from_free_area(area, fallback_mt);
 
 	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
 
@@ -3019,6 +3002,7 @@ EXPORT_SYMBOL_GPL(split_page);
 
 int __isolate_free_page(struct page *page, unsigned int order)
 {
+	struct free_area *area = &page_zone(page)->free_area[order];
 	unsigned long watermark;
 	struct zone *zone;
 	int mt;
@@ -3043,9 +3027,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
-	rmv_page_order(page);
+
+	del_page_from_free_area(page, area, mt);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -3339,13 +3322,13 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			continue;
 
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
-			if (!list_empty(&area->free_list[mt]))
+			if (!free_area_empty(area, mt))
 				return true;
 		}
 
 #ifdef CONFIG_CMA
 		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		    !free_area_empty(area, MIGRATE_CMA)) {
 			return true;
 		}
 #endif
@@ -5191,7 +5174,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!free_area_empty(area, type))
 					types[order] |= 1 << type;
 			}
 		}
@@ -8220,6 +8203,9 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
+		struct free_area *area;
+		int mt;
+
 		if (!pfn_valid(pfn)) {
 			pfn++;
 			continue;
@@ -8238,13 +8224,13 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		BUG_ON(page_count(page));
 		BUG_ON(!PageBuddy(page));
 		order = page_order(page);
+		area = &zone->free_area[order];
 #ifdef CONFIG_DEBUG_VM
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
-		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
+		mt = get_pageblock_migratetype(page);
+		del_page_from_free_area(page, area, mt);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
