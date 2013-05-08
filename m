Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 9C9EE6B012A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:12 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/22] mm: page allocator: Use unsigned int for order in more places
Date: Wed,  8 May 2013 17:02:48 +0100
Message-Id: <1368028987-8369-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

X86 prefers the use of unsigned types for iterators and there is a
tendency to mix whether a signed or unsigned type if used for page
order. This converts a number of sites in mm/page_alloc.c to use
unsigned int for order where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  8 ++++----
 mm/page_alloc.c        | 35 +++++++++++++++++++----------------
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c74092e..e71e3a6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -773,10 +773,10 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
-bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		int classzone_idx, int alloc_flags);
-bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
-		int classzone_idx, int alloc_flags);
+bool zone_watermark_ok(struct zone *z, unsigned int order,
+		unsigned long mark, int classzone_idx, int alloc_flags);
+bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
+		unsigned long mark, int classzone_idx, int alloc_flags);
 enum memmap_context {
 	MEMMAP_EARLY,
 	MEMMAP_HOTPLUG,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 50c9315..4a07771 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -392,7 +392,8 @@ static int destroy_compound_page(struct page *page, unsigned long order)
 	return bad;
 }
 
-static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
+static inline void prep_zero_page(struct page *page, unsigned int order,
+							gfp_t gfp_flags)
 {
 	int i;
 
@@ -436,7 +437,7 @@ static inline void set_page_guard_flag(struct page *page) { }
 static inline void clear_page_guard_flag(struct page *page) { }
 #endif
 
-static inline void set_page_order(struct page *page, int order)
+static inline void set_page_order(struct page *page, unsigned int order)
 {
 	set_page_private(page, order);
 	__SetPageBuddy(page);
@@ -485,7 +486,7 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
  * For recording page's order, we use page_private(page).
  */
 static inline int page_is_buddy(struct page *page, struct page *buddy,
-								int order)
+							unsigned int order)
 {
 	if (!pfn_valid_within(page_to_pfn(buddy)))
 		return 0;
@@ -683,7 +684,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	spin_unlock(&zone->lock);
 }
 
-static void free_one_page(struct zone *zone, struct page *page, int order,
+static void free_one_page(struct zone *zone, struct page *page,
+				unsigned int order,
 				int migratetype)
 {
 	unsigned long flags;
@@ -853,7 +855,7 @@ static inline int check_new_page(struct page *page)
 	return 0;
 }
 
-static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 {
 	int i;
 
@@ -1278,7 +1280,7 @@ void mark_free_pages(struct zone *zone)
 {
 	unsigned long pfn, max_zone_pfn;
 	unsigned long flags;
-	int order, t;
+	unsigned int order, t;
 	struct list_head *curr;
 
 	if (!zone->spanned_pages)
@@ -1471,8 +1473,8 @@ int split_free_page(struct page *page)
  */
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
-			struct zone *zone, int order, gfp_t gfp_flags,
-			int migratetype)
+			struct zone *zone, unsigned int order,
+			gfp_t gfp_flags, int migratetype)
 {
 	unsigned long flags;
 	struct page *page;
@@ -1619,8 +1621,9 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
  * Return true if free pages are above 'mark'. This takes into account the order
  * of the allocation.
  */
-static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags, long free_pages)
+static bool __zone_watermark_ok(struct zone *z, unsigned int order,
+			unsigned long mark, int classzone_idx, int alloc_flags,
+			long free_pages)
 {
 	/* free_pages my go negative - that's OK */
 	long min = mark;
@@ -1652,15 +1655,15 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	return true;
 }
 
-bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
+bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
 					zone_page_state(z, NR_FREE_PAGES));
 }
 
-bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
-		      int classzone_idx, int alloc_flags)
+bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
+			unsigned long mark, int classzone_idx, int alloc_flags)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
 
@@ -3942,7 +3945,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
-	int order, t;
+	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
@@ -6038,7 +6041,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
 	struct zone *zone;
-	int order, i;
+	unsigned int order, i;
 	unsigned long pfn;
 	unsigned long flags;
 	/* find the first valid pfn */
@@ -6090,7 +6093,7 @@ bool is_free_buddy_page(struct page *page)
 	struct zone *zone = page_zone(page);
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long flags;
-	int order;
+	unsigned int order;
 
 	spin_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
