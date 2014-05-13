Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0473C6B0055
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:46:09 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so206722eek.23
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:46:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si12673483eew.138.2014.05.13.02.46.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:46:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/19] mm: page_alloc: Use unsigned int for order in more places
Date: Tue, 13 May 2014 10:45:43 +0100
Message-Id: <1399974350-11089-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

X86 prefers the use of unsigned types for iterators and there is a
tendency to mix whether a signed or unsigned type if used for page
order. This converts a number of sites in mm/page_alloc.c to use
unsigned int for order where possible.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h |  8 ++++----
 mm/page_alloc.c        | 43 +++++++++++++++++++++++--------------------
 2 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd6f504..974a4ef 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -817,10 +817,10 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
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
index fcbf637..a47f1c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -408,7 +408,8 @@ static int destroy_compound_page(struct page *page, unsigned long order)
 	return bad;
 }
 
-static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
+static inline void prep_zero_page(struct page *page, unsigned int order,
+							gfp_t gfp_flags)
 {
 	int i;
 
@@ -452,7 +453,7 @@ static inline void set_page_guard_flag(struct page *page) { }
 static inline void clear_page_guard_flag(struct page *page) { }
 #endif
 
-static inline void set_page_order(struct page *page, int order)
+static inline void set_page_order(struct page *page, unsigned int order)
 {
 	set_page_private(page, order);
 	__SetPageBuddy(page);
@@ -503,7 +504,7 @@ __find_buddy_index(unsigned long page_idx, unsigned int order)
  * For recording page's order, we use page_private(page).
  */
 static inline int page_is_buddy(struct page *page, struct page *buddy,
-								int order)
+							unsigned int order)
 {
 	if (!pfn_valid_within(page_to_pfn(buddy)))
 		return 0;
@@ -725,7 +726,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 static void free_one_page(struct zone *zone,
 				struct page *page, unsigned long pfn,
-				int order,
+				unsigned int order,
 				int migratetype)
 {
 	spin_lock(&zone->lock);
@@ -896,7 +897,7 @@ static inline int check_new_page(struct page *page)
 	return 0;
 }
 
-static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags)
 {
 	int i;
 
@@ -1104,16 +1105,17 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 
 /* Remove an element from the buddy allocator from the fallback list */
 static inline struct page *
-__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
+__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 {
 	struct free_area *area;
-	int current_order;
+	unsigned int current_order;
 	struct page *page;
 	int migratetype, new_type, i;
 
 	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1; current_order >= order;
-						--current_order) {
+	for (current_order = MAX_ORDER-1;
+				current_order >= order && current_order <= MAX_ORDER-1;
+				--current_order) {
 		for (i = 0;; i++) {
 			migratetype = fallbacks[start_migratetype][i];
 
@@ -1341,7 +1343,7 @@ void mark_free_pages(struct zone *zone)
 {
 	unsigned long pfn, max_zone_pfn;
 	unsigned long flags;
-	int order, t;
+	unsigned int order, t;
 	struct list_head *curr;
 
 	if (zone_is_empty(zone))
@@ -1537,8 +1539,8 @@ int split_free_page(struct page *page)
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
@@ -1687,8 +1689,9 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
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
@@ -1722,15 +1725,15 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
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
 
@@ -4123,7 +4126,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 static void __meminit zone_init_free_lists(struct zone *zone)
 {
-	int order, t;
+	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
@@ -6448,7 +6451,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 {
 	struct page *page;
 	struct zone *zone;
-	int order, i;
+	unsigned int order, i;
 	unsigned long pfn;
 	unsigned long flags;
 	/* find the first valid pfn */
@@ -6500,7 +6503,7 @@ bool is_free_buddy_page(struct page *page)
 	struct zone *zone = page_zone(page);
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long flags;
-	int order;
+	unsigned int order;
 
 	spin_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
