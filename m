Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B49512806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:46:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k3so70567336pfc.0
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 05:46:00 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q6si8691249pgn.509.2017.08.22.05.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 05:45:59 -0700 (PDT)
From: =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>
Subject: [PATCH 2/3] mm: Add page colored allocation path
Date: Tue, 22 Aug 2017 14:45:32 +0200
Message-Id: <20170822124533.11692-3-lukasz.daniluk@intel.com>
In-Reply-To: <20170822124533.11692-1-lukasz.daniluk@intel.com>
References: <20170822124533.11692-1-lukasz.daniluk@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com, =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>

Create alternative path when requesting free_list from buddy system
that takes recent allocations or physical page offset into account.

This solution carries a cost of additional, early memory allocations
done by kernel that is dependent on cache size and minimum order to be
colored.

Signed-off-by: A?ukasz Daniluk <lukasz.daniluk@intel.com>
---
 Documentation/admin-guide/kernel-parameters.txt |   8 +
 include/linux/mmzone.h                          |   5 +-
 mm/page_alloc.c                                 | 253 +++++++++++++++++++++---
 3 files changed, 243 insertions(+), 23 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 372cc66bba23..4648f1cc6665 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -455,6 +455,14 @@
 			possible to determine what the correct size should be.
 			This option provides an override for these situations.
 
+	cache_color_size=
+			[KNL] Set cache size for purposes of cache coloring
+			mechanism in buddy allocator.
+
+	cache_color_min_order=
+			[KNL] Set minimal order for which page coloring
+			mechanism will be enabled in buddy allocator.
+
 	ca_keys=	[KEYS] This parameter identifies a specific key(s) on
 			the system trusted keyring to be used for certificate
 			trust validation.
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 04128890a684..d10a5421b18b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -25,7 +25,8 @@
 #else
 #define MAX_ORDER CONFIG_FORCE_MAX_ZONEORDER
 #endif
-#define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
+#define ORDER_NR_PAGES(order) (1 << (order))
+#define MAX_ORDER_NR_PAGES ORDER_NR_PAGES(MAX_ORDER - 1)
 
 /*
  * PAGE_ALLOC_COSTLY_ORDER is the order at which allocations are deemed
@@ -94,6 +95,8 @@ extern int page_group_by_mobility_disabled;
 
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
+	struct list_head	*colored_free_list[MIGRATE_TYPES];
+	unsigned long		next_color[MIGRATE_TYPES];
 	unsigned long		nr_free;
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f7b074fbfdb..3718b49032c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -288,14 +288,129 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-struct list_head *area_get_free_list(struct free_area *area, int order,
-				int migratetype)
+int cache_color_min_order __read_mostly = MAX_ORDER - 1;
+
+
+/*
+ * cache_size - size of cache (in bytes)
+ */
+unsigned long long cache_size __read_mostly;
+
+/*
+ * Returns true if cache color allocations are enabled
+ */
+static inline bool cache_color_used(int order)
+{
+	return cache_size && order >= cache_color_min_order;
+}
+
+/*
+ * Returns number of cache colors in specified order
+ */
+static inline unsigned long cache_colors(int order)
+{
+	unsigned long colors = cache_size / (PAGE_SIZE * ORDER_NR_PAGES(order));
+
+	return colors ? colors : 1;
+}
+
+/*
+ * Returns cache color for page of specified order
+ */
+static inline unsigned long page_cache_color(struct page *page, int order)
+{
+	return (page_to_phys(page) % cache_size)
+		/ (PAGE_SIZE * ORDER_NR_PAGES(order));
+}
+
+/*
+ * Returns color of first non-empty free_list for purpose of cache color
+ * allocations in specified range (start until end-1).
+ */
+static inline unsigned long cache_color_find_nonempty(struct free_area *area,
+			int migratetype, unsigned long start, unsigned long end)
 {
+	unsigned long color;
+
+	for (color = start; color < end; ++color)
+		if (!list_empty(&area->colored_free_list[migratetype][color]))
+			break;
+
+	return color;
+}
+
+/*
+ * Returns free_list for cache color allocation purposes.
+ * In case page is passed, it is assumed that it will be added to free_list, so
+ * return value is based on color of the page.
+ * Otherwise it searches for next color with free pages available.
+ */
+static inline struct list_head *cache_color_area_get_free_list(
+		struct free_area *area, struct page *page, int order,
+		int migratetype)
+{
+	unsigned long color;
+	unsigned long current_color = area->next_color[migratetype];
+
+	if (page) {
+		color = page_cache_color(page, order);
+		return &area->colored_free_list[migratetype][color];
+	}
+
+	color = cache_color_find_nonempty(area, migratetype, current_color,
+					cache_colors(order));
+
+
+	if (color == cache_colors(order))
+		color = cache_color_find_nonempty(area, migratetype, 0,
+						current_color);
+
+	current_color = color + 1;
+	if (current_color >= cache_colors(order))
+		current_color = 0;
+
+	area->next_color[migratetype] = current_color;
+
+	return &area->colored_free_list[migratetype][color];
+}
+
+static inline bool cache_color_area_empty(struct free_area *area, int order,
+					int migratetype)
+{
+	return cache_color_find_nonempty(area, migratetype, 0,
+				cache_colors(order)) == cache_colors(order);
+}
+
+
+static inline unsigned long cache_color_area_free_count(struct free_area *area,
+						int order, int migratetype)
+{
+	unsigned long count = 0;
+	unsigned long color;
+	struct list_head *lh;
+
+	for (color = 0; color < cache_colors(order); ++color)
+		list_for_each(lh, &area->colored_free_list[migratetype][color])
+			++count;
+
+	return count;
+}
+
+struct list_head *area_get_free_list(struct free_area *area, struct page *page,
+					int order, int migratetype)
+{
+	if (cache_color_used(order))
+		return cache_color_area_get_free_list(area, page, order,
+							migratetype);
+
 	return &area->free_list[migratetype];
 }
 
 bool area_empty(struct free_area *area, int order, int migratetype)
 {
+	if (cache_color_used(order))
+		return cache_color_area_empty(area, order, migratetype);
+
 	return list_empty(&area->free_list[migratetype]);
 }
 
@@ -305,12 +420,67 @@ unsigned long area_free_count(struct free_area *area, int order,
 	unsigned long count = 0;
 	struct list_head *lh;
 
+	if (cache_color_used(order))
+		return cache_color_area_free_count(area, order, migratetype);
+
 	list_for_each(lh, &area->free_list[migratetype])
 		++count;
 
 	return count;
 }
 
+/*
+ * Returns pointer to allocated space that will host the array of free_lists
+ * used for cache color allocations.
+ */
+static __ref void *cache_color_alloc_lists(struct zone *zone, int order)
+{
+	const size_t size = sizeof(struct list_head) * cache_colors(order);
+
+	return alloc_bootmem_pages_node(zone->zone_pgdat, size);
+}
+
+static __init int setup_cache_color_size(char *_cache_size)
+{
+	char *retptr;
+
+	cache_size = memparse(_cache_size, &retptr);
+
+	if (retptr == _cache_size) {
+		pr_warn("Invalid cache size requested");
+		cache_size = 0;
+	}
+
+	if (cache_size == 0)
+		pr_info("Cache color pages functionality disabled");
+	else
+		pr_info("Cache size set to %llu bytes", cache_size);
+
+	return 0;
+}
+early_param("cache_color_size", setup_cache_color_size);
+
+static __init int setup_cache_color_min_order(char *_cache_color_min_order)
+{
+	int order;
+
+	if (kstrtoint(_cache_color_min_order, 10, &order) < 0) {
+		pr_warn("Invalid cache color min order requested");
+		order = -1;
+	}
+
+	if (order < 0 || order >= MAX_ORDER) {
+		pr_info("Cache color pages functionality disabled");
+		cache_color_min_order = MAX_ORDER;
+	} else {
+		pr_info("Cache min order set to %d", order);
+		cache_color_min_order = order;
+	}
+
+	return 0;
+}
+early_param("cache_color_min_order", setup_cache_color_min_order);
+
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
@@ -911,13 +1081,13 @@ static inline void __free_one_page(struct page *page,
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
 				area_get_free_list(&zone->free_area[order],
-						order, migratetype));
+						page, order, migratetype));
 			goto out;
 		}
 	}
 
-	list_add(&page->lru, area_get_free_list(&zone->free_area[order], order,
-						migratetype));
+	list_add(&page->lru, area_get_free_list(&zone->free_area[order], page,
+						order, migratetype));
 out:
 	zone->free_area[order].nr_free++;
 }
@@ -1685,8 +1855,8 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, area_get_free_list(area, high,
-								migratetype));
+		list_add(&page[size].lru, area_get_free_list(area, &page[size],
+							high, migratetype));
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1829,7 +1999,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
 		page = list_first_entry_or_null(
-			area_get_free_list(area, current_order, migratetype),
+			area_get_free_list(area, NULL, current_order,
+					migratetype),
 			struct page, lru);
 		if (!page)
 			continue;
@@ -1924,8 +2095,8 @@ static int move_freepages(struct zone *zone,
 
 		order = page_order(page);
 		list_move(&page->lru,
-			area_get_free_list(&zone->free_area[order], order,
-					migratetype));
+			  area_get_free_list(&zone->free_area[order], page,
+						order, migratetype));
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2074,7 +2245,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, area_get_free_list(area, current_order,
+	list_move(&page->lru, area_get_free_list(area, page, current_order,
 						start_type));
 }
 
@@ -2187,7 +2358,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
 			struct free_area *area = &(zone->free_area[order]);
 
 			page = list_first_entry_or_null(
-					area_get_free_list(area, order,
+					area_get_free_list(area, NULL, order,
 							MIGRATE_HIGHATOMIC),
 					struct page, lru);
 			if (!page)
@@ -2302,7 +2473,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 	VM_BUG_ON(current_order == MAX_ORDER);
 
 do_steal:
-	page = list_first_entry(area_get_free_list(area, current_order,
+	page = list_first_entry(area_get_free_list(area, NULL, current_order,
 					fallback_mt), struct page, lru);
 
 	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
@@ -2566,6 +2737,16 @@ void drain_all_pages(struct zone *zone)
 
 #ifdef CONFIG_HIBERNATION
 
+static inline void mark_free_page(struct page *page, int order)
+{
+	unsigned long i, pfn;
+
+	pfn = page_to_pfn(page);
+
+	for (i = 0; i < (1UL << order); ++i)
+		swsusp_set_page_free(pfn_to_page(pfn + i));
+}
+
 void mark_free_pages(struct zone *zone)
 {
 	unsigned long pfn, max_zone_pfn;
@@ -2591,14 +2772,20 @@ void mark_free_pages(struct zone *zone)
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each_entry(page,
-				area_get_free_list(&zone->free_area[order],
-						order, t), lru) {
-			unsigned long i;
+		struct free_area *area = &zone->free_area[order];
+
+		if (cache_color_used(order)) {
+			unsigned long color;
+			struct list_head *colored_lists =
+					area->colored_free_list[t];
 
-			pfn = page_to_pfn(page);
-			for (i = 0; i < (1UL << order); i++)
-				swsusp_set_page_free(pfn_to_page(pfn + i));
+			for (color = 0; color < cache_colors(order); ++color)
+				list_for_each_entry(page,
+						&colored_lists[color], lru)
+					mark_free_page(page, order);
+		} else {
+			list_for_each_entry(page, &area->free_list[t], lru)
+				mark_free_page(page, order);
 		}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -5490,12 +5677,34 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	}
 }
 
+static void __meminit zone_init_cache_color(struct zone *zone, int order,
+						int migratetype)
+{
+	unsigned long c;
+	struct free_area *area = &zone->free_area[order];
+
+	if (!cache_color_used(order))
+		return;
+
+	area->next_color[migratetype] = 0;
+	area->colored_free_list[migratetype] =
+		cache_color_alloc_lists(zone, order);
+
+	for (c = 0; c < cache_colors(order); ++c)
+		INIT_LIST_HEAD(&area->colored_free_list[migratetype][c]);
+}
+
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
-		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
-		zone->free_area[order].nr_free = 0;
+		struct free_area *area = &zone->free_area[order];
+
+		INIT_LIST_HEAD(&area->free_list[t]);
+		area->nr_free = 0;
+
+		if (cache_color_used(order))
+			zone_init_cache_color(zone, order, t);
 	}
 }
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
