Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5758D2806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:45:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x137so70778260pfd.14
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 05:45:59 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q6si8691249pgn.509.2017.08.22.05.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 05:45:57 -0700 (PDT)
From: =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>
Subject: [PATCH 1/3] mm: move free_list selection to dedicated functions
Date: Tue, 22 Aug 2017 14:45:31 +0200
Message-Id: <20170822124533.11692-2-lukasz.daniluk@intel.com>
In-Reply-To: <20170822124533.11692-1-lukasz.daniluk@intel.com>
References: <20170822124533.11692-1-lukasz.daniluk@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com, =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>

Currently free_list selection from particular free_area was done on
principle that there is only one free_list per order per migratetype.
This patch is preparation for page coloring solution utilising multiple
free_lists.

Signed-off-by: A?ukasz Daniluk <lukasz.daniluk@intel.com>
---
 include/linux/mmzone.h |  4 ++++
 mm/compaction.c        |  4 ++--
 mm/page_alloc.c        | 61 +++++++++++++++++++++++++++++++++++++-------------
 mm/vmstat.c            | 10 +++------
 4 files changed, 55 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b3f6ce..04128890a684 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -910,6 +910,10 @@ extern struct pglist_data contig_page_data;
 
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
+extern bool area_empty(struct free_area *area, int order, int migratetype);
+extern unsigned long area_free_count(struct free_area *area, int order,
+					int migratetype);
+
 extern struct pglist_data *first_online_pgdat(void);
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
 extern struct zone *next_zone(struct zone *zone);
diff --git a/mm/compaction.c b/mm/compaction.c
index fb548e4c7bd4..8f6274c0a04b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1334,13 +1334,13 @@ static enum compact_result __compact_finished(struct zone *zone,
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (!area_empty(area, order, migratetype))
 			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+			!area_empty(area, order, MIGRATE_CMA))
 			return COMPACT_SUCCESS;
 #endif
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 471b0526b876..3f7b074fbfdb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -288,6 +288,29 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
+struct list_head *area_get_free_list(struct free_area *area, int order,
+				int migratetype)
+{
+	return &area->free_list[migratetype];
+}
+
+bool area_empty(struct free_area *area, int order, int migratetype)
+{
+	return list_empty(&area->free_list[migratetype]);
+}
+
+unsigned long area_free_count(struct free_area *area, int order,
+				int migratetype)
+{
+	unsigned long count = 0;
+	struct list_head *lh;
+
+	list_for_each(lh, &area->free_list[migratetype])
+		++count;
+
+	return count;
+}
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
@@ -887,12 +910,14 @@ static inline void __free_one_page(struct page *page,
 		if (pfn_valid_within(buddy_pfn) &&
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
+				area_get_free_list(&zone->free_area[order],
+						order, migratetype));
 			goto out;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+	list_add(&page->lru, area_get_free_list(&zone->free_area[order], order,
+						migratetype));
 out:
 	zone->free_area[order].nr_free++;
 }
@@ -1660,7 +1685,8 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		list_add(&page[size].lru, area_get_free_list(area, high,
+								migratetype));
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1802,8 +1828,9 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
-		page = list_first_entry_or_null(&area->free_list[migratetype],
-							struct page, lru);
+		page = list_first_entry_or_null(
+			area_get_free_list(area, current_order, migratetype),
+			struct page, lru);
 		if (!page)
 			continue;
 		list_del(&page->lru);
@@ -1897,7 +1924,8 @@ static int move_freepages(struct zone *zone,
 
 		order = page_order(page);
 		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+			area_get_free_list(&zone->free_area[order], order,
+					migratetype));
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2046,7 +2074,8 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	list_move(&page->lru, area_get_free_list(area, current_order,
+						start_type));
 }
 
 /*
@@ -2070,7 +2099,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (area_empty(area, order, fallback_mt))
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2158,7 +2187,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 			struct free_area *area = &(zone->free_area[order]);
 
 			page = list_first_entry_or_null(
-					&area->free_list[MIGRATE_HIGHATOMIC],
+					area_get_free_list(area, order,
+							MIGRATE_HIGHATOMIC),
 					struct page, lru);
 			if (!page)
 				continue;
@@ -2272,8 +2302,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	VM_BUG_ON(current_order == MAX_ORDER);
 
 do_steal:
-	page = list_first_entry(&area->free_list[fallback_mt],
-							struct page, lru);
+	page = list_first_entry(area_get_free_list(area, current_order,
+					fallback_mt), struct page, lru);
 
 	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
 
@@ -2562,7 +2592,8 @@ void mark_free_pages(struct zone *zone)
 
 	for_each_migratetype_order(order, t) {
 		list_for_each_entry(page,
-				&zone->free_area[order].free_list[t], lru) {
+				area_get_free_list(&zone->free_area[order],
+						order, t), lru) {
 			unsigned long i;
 
 			pfn = page_to_pfn(page);
@@ -2983,13 +3014,13 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			return true;
 
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
-			if (!list_empty(&area->free_list[mt]))
+			if (!area_empty(area, o, mt))
 				return true;
 		}
 
 #ifdef CONFIG_CMA
 		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		    !area_empty(area, o, MIGRATE_CMA)) {
 			return true;
 		}
 #endif
@@ -4788,7 +4819,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!area_empty(area, order, type))
 					types[order] |= 1 << type;
 			}
 		}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441bbeef2..1ff86656cb2e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1183,14 +1183,10 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 					zone->name,
 					migratetype_names[mtype]);
 		for (order = 0; order < MAX_ORDER; ++order) {
-			unsigned long freecount = 0;
-			struct free_area *area;
-			struct list_head *curr;
+			struct free_area *area = &(zone->free_area[order]);
+			unsigned long freecount =
+				area_free_count(area, order, mtype);
 
-			area = &(zone->free_area[order]);
-
-			list_for_each(curr, &area->free_list[mtype])
-				freecount++;
 			seq_printf(m, "%6lu ", freecount);
 		}
 		seq_putc(m, '\n');
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
