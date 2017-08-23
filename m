Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5659280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 06:02:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r62so10419139pfj.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:02:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o12si857588plg.134.2017.08.23.03.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 03:02:28 -0700 (PDT)
From: =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>
Subject: [RESEND PATCH 3/3] mm: Add helper rbtree to search for next cache color
Date: Wed, 23 Aug 2017 12:02:05 +0200
Message-Id: <20170823100205.17311-4-lukasz.daniluk@intel.com>
In-Reply-To: <20170823100205.17311-1-lukasz.daniluk@intel.com>
References: <20170823100205.17311-1-lukasz.daniluk@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: dave.hansen@intel.com, lukasz.anaczkowski@intel.com, =?UTF-8?q?=C5=81ukasz=20Daniluk?= <lukasz.daniluk@intel.com>

Before this patch search for next available cache color was done
linearly. This kind of search is problematic if the contents are sparse
or there are no contents at all.

This patch aims to fix this problem by arranging the free_lists that
take part in cache aware allocations in the RB tree structure.

In order for the solution to work properly, space for free_lists and RB
tree nodes has to be allocated. Required space is 5 pointers per color
(struct rb_node, struct list_head).

Cost of the solution with RB tree helpers can be estimated as:
5 * MIGRATE_TYPES * cache_colors(order), per zone per node, for each
order that we wish to be affected. For example 16GB cache with only
order 10 enabled requires 160KB per zone type, migratetype, node; whereas
enabling this feature for order 9 will bump this number up to 480KB per
zone type, migratetype.

Signed-off-by: A?ukasz Daniluk <lukasz.daniluk@intel.com>
---
 include/linux/mmzone.h |   5 +-
 mm/page_alloc.c        | 155 ++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 130 insertions(+), 30 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d10a5421b18b..cda726854078 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -6,6 +6,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/list.h>
+#include <linux/rbtree.h>
 #include <linux/wait.h>
 #include <linux/bitops.h>
 #include <linux/cache.h>
@@ -93,9 +94,11 @@ extern int page_group_by_mobility_disabled;
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
 
+struct cache_color;
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
-	struct list_head	*colored_free_list[MIGRATE_TYPES];
+	struct rb_root		cache_colored_free_lists[MIGRATE_TYPES];
+	struct cache_color	*cache_colors[MIGRATE_TYPES];
 	unsigned long		next_color[MIGRATE_TYPES];
 	unsigned long		nr_free;
 };
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3718b49032c2..da1431c4703c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -290,6 +290,10 @@ int page_group_by_mobility_disabled __read_mostly;
 
 int cache_color_min_order __read_mostly = MAX_ORDER - 1;
 
+struct cache_color {
+	struct list_head	free_list;
+	struct rb_node		rb_tree_node;
+};
 
 /*
  * cache_size - size of cache (in bytes)
@@ -323,18 +327,102 @@ static inline unsigned long page_cache_color(struct page *page, int order)
 		/ (PAGE_SIZE * ORDER_NR_PAGES(order));
 }
 
+static inline unsigned long get_cache_color(struct cache_color *cc,
+				struct free_area *area, int migratetype)
+{
+	return cc - area->cache_colors[migratetype];
+}
+
+/*
+ * Returns pointer to cache_color structure that has first available color
+ * after color passed as argument, or NULL, if no such structure was found.
+ */
+static inline struct cache_color *cache_color_area_find_next(
+					struct free_area *area,
+					int migratetype, unsigned long color)
+{
+	struct rb_root *root = &area->cache_colored_free_lists[migratetype];
+	struct rb_node *node = root->rb_node;
+	struct cache_color *ret = NULL;
+
+	while (node) {
+		struct cache_color *cc =
+			rb_entry(node, struct cache_color, rb_tree_node);
+		unsigned long cc_color =
+			get_cache_color(cc, area, migratetype);
+
+		if (cc_color < color) {
+			node = node->rb_right;
+		} else if (cc_color > color) {
+			ret = cc;
+			node = node->rb_left;
+		} else {
+			return cc;
+		}
+	}
+
+	return ret;
+}
+
+/*
+ * Inserts cache_color structure into RB tree associated with migratetype in
+ * area, in case the color was absent from the tree.
+ */
+static inline void cache_color_area_insert(struct free_area *area,
+					int migratetype, struct cache_color *cc)
+{
+	struct rb_root *root = &area->cache_colored_free_lists[migratetype];
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+	unsigned long cc_color = get_cache_color(cc, area, migratetype);
+
+	while (*new) {
+		struct cache_color *this =
+			rb_entry(*new, struct cache_color, rb_tree_node);
+		unsigned long this_color =
+			get_cache_color(this, area, migratetype);
+
+		parent = *new;
+		if (this_color < cc_color)
+			new = &((*new)->rb_right);
+		else if (this_color > cc_color)
+			new = &((*new)->rb_left);
+		else
+			return;
+	}
+
+	rb_link_node(&cc->rb_tree_node, parent, new);
+	rb_insert_color(&cc->rb_tree_node, root);
+}
+
 /*
  * Returns color of first non-empty free_list for purpose of cache color
  * allocations in specified range (start until end-1).
  */
-static inline unsigned long cache_color_find_nonempty(struct free_area *area,
-			int migratetype, unsigned long start, unsigned long end)
-{
-	unsigned long color;
-
-	for (color = start; color < end; ++color)
-		if (!list_empty(&area->colored_free_list[migratetype][color]))
-			break;
+static inline unsigned long cache_color_find_nonempty(
+		struct free_area *area, int migratetype,
+		unsigned long start, unsigned long end, bool delete_empty)
+{
+	unsigned long color = start;
+	struct cache_color *cc;
+
+	while (color < end) {
+		struct rb_root *root =
+			&area->cache_colored_free_lists[migratetype];
+		unsigned long cc_color;
+
+		cc = cache_color_area_find_next(area, migratetype, color);
+		if (!cc)
+			return end;
+
+		cc_color = get_cache_color(cc, area, migratetype);
+		if (list_empty(&cc->free_list)) {
+			if (delete_empty)
+				rb_erase(&cc->rb_tree_node, root);
+			color = cc_color + 1;
+		} else {
+			return cc_color;
+		}
+	}
 
 	return color;
 }
@@ -353,17 +441,23 @@ static inline struct list_head *cache_color_area_get_free_list(
 	unsigned long current_color = area->next_color[migratetype];
 
 	if (page) {
+		struct cache_color *cc;
+
 		color = page_cache_color(page, order);
-		return &area->colored_free_list[migratetype][color];
+		cc = &area->cache_colors[migratetype][color];
+
+		if (list_empty(&cc->free_list))
+			cache_color_area_insert(area, migratetype, cc);
+
+		return &cc->free_list;
 	}
 
 	color = cache_color_find_nonempty(area, migratetype, current_color,
-					cache_colors(order));
-
+					cache_colors(order), true);
 
 	if (color == cache_colors(order))
 		color = cache_color_find_nonempty(area, migratetype, 0,
-						current_color);
+						current_color, true);
 
 	current_color = color + 1;
 	if (current_color >= cache_colors(order))
@@ -371,14 +465,14 @@ static inline struct list_head *cache_color_area_get_free_list(
 
 	area->next_color[migratetype] = current_color;
 
-	return &area->colored_free_list[migratetype][color];
+	return &area->cache_colors[migratetype][color].free_list;
 }
 
 static inline bool cache_color_area_empty(struct free_area *area, int order,
 					int migratetype)
 {
 	return cache_color_find_nonempty(area, migratetype, 0,
-				cache_colors(order)) == cache_colors(order);
+			cache_colors(order), false) == cache_colors(order);
 }
 
 
@@ -386,12 +480,17 @@ static inline unsigned long cache_color_area_free_count(struct free_area *area,
 						int order, int migratetype)
 {
 	unsigned long count = 0;
-	unsigned long color;
 	struct list_head *lh;
+	struct rb_node *node;
 
-	for (color = 0; color < cache_colors(order); ++color)
-		list_for_each(lh, &area->colored_free_list[migratetype][color])
+	for (node = rb_first(&area->cache_colored_free_lists[migratetype]);
+			node; node = rb_next(node)) {
+		struct cache_color *cc =
+			rb_entry(node, struct cache_color, rb_tree_node);
+
+		list_for_each(lh, &cc->free_list)
 			++count;
+	}
 
 	return count;
 }
@@ -435,7 +534,7 @@ unsigned long area_free_count(struct free_area *area, int order,
  */
 static __ref void *cache_color_alloc_lists(struct zone *zone, int order)
 {
-	const size_t size = sizeof(struct list_head) * cache_colors(order);
+	const size_t size = sizeof(struct cache_color) * cache_colors(order);
 
 	return alloc_bootmem_pages_node(zone->zone_pgdat, size);
 }
@@ -2776,12 +2875,11 @@ void mark_free_pages(struct zone *zone)
 
 		if (cache_color_used(order)) {
 			unsigned long color;
-			struct list_head *colored_lists =
-					area->colored_free_list[t];
+			struct cache_color *ccs = area->cache_colors[t];
 
 			for (color = 0; color < cache_colors(order); ++color)
 				list_for_each_entry(page,
-						&colored_lists[color], lru)
+						&ccs[color].free_list, lru)
 					mark_free_page(page, order);
 		} else {
 			list_for_each_entry(page, &area->free_list[t], lru)
@@ -5680,18 +5778,17 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 static void __meminit zone_init_cache_color(struct zone *zone, int order,
 						int migratetype)
 {
-	unsigned long c;
+	unsigned long color;
 	struct free_area *area = &zone->free_area[order];
-
-	if (!cache_color_used(order))
-		return;
+	struct cache_color **ccs = &area->cache_colors[migratetype];
 
 	area->next_color[migratetype] = 0;
-	area->colored_free_list[migratetype] =
-		cache_color_alloc_lists(zone, order);
+	area->cache_colored_free_lists[migratetype] = RB_ROOT;
 
-	for (c = 0; c < cache_colors(order); ++c)
-		INIT_LIST_HEAD(&area->colored_free_list[migratetype][c]);
+	*ccs = cache_color_alloc_lists(zone, order);
+
+	for (color = 0; color < cache_colors(order); ++color)
+		INIT_LIST_HEAD(&(*ccs)[color].free_list);
 }
 
 static void __meminit zone_init_free_lists(struct zone *zone)
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
