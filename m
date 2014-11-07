Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC7C800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:33:56 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so2807846pde.18
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:33:56 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id iu5si8100080pbc.243.2014.11.06.23.33.53
        for <linux-mm@kvack.org>;
        Thu, 06 Nov 2014 23:33:54 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/2] mm/debug-pagealloc: cleanup page guard code
Date: Fri,  7 Nov 2014 16:35:46 +0900
Message-Id: <1415345746-16666-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1415345746-16666-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1415345746-16666-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Page guard is used by debug-pagealloc feature. Currently,
it is open-coded, but, I think that more abstraction of it makes
core page allocator code more readable.

There is no functional difference.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d673f64..c0dbede 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -440,18 +440,29 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 }
 __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
 
-static inline void set_page_guard_flag(struct page *page)
+static inline void set_page_guard(struct zone *zone, struct page *page,
+				unsigned int order, int migratetype)
 {
 	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+	INIT_LIST_HEAD(&page->lru);
+	set_page_private(page, order);
+	/* Guard pages are not available for any usage */
+	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
 }
 
-static inline void clear_page_guard_flag(struct page *page)
+static inline void clear_page_guard(struct zone *zone, struct page *page,
+				unsigned int order, int migratetype)
 {
 	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+	set_page_private(page, 0);
+	if (!is_migrate_isolate(migratetype))
+		__mod_zone_freepage_state(zone, (1 << order), migratetype);
 }
 #else
-static inline void set_page_guard_flag(struct page *page) { }
-static inline void clear_page_guard_flag(struct page *page) { }
+static inline void set_page_guard(struct zone *zone, struct page *page,
+				unsigned int order, int migratetype) {}
+static inline void clear_page_guard(struct zone *zone, struct page *page,
+				unsigned int order, int migratetype) {}
 #endif
 
 static inline void set_page_order(struct page *page, unsigned int order)
@@ -582,12 +593,7 @@ static inline void __free_one_page(struct page *page,
 		 * merge with it and move up one order.
 		 */
 		if (page_is_guard(buddy)) {
-			clear_page_guard_flag(buddy);
-			set_page_private(buddy, 0);
-			if (!is_migrate_isolate(migratetype)) {
-				__mod_zone_freepage_state(zone, 1 << order,
-							  migratetype);
-			}
+			clear_page_guard(zone, buddy, order, migratetype);
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
@@ -862,23 +868,17 @@ static inline void expand(struct zone *zone, struct page *page,
 		size >>= 1;
 		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-		if (high < debug_guardpage_minorder()) {
+		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
+			high < debug_guardpage_minorder()) {
 			/*
 			 * Mark as guard pages (or page), that will allow to
 			 * merge back to allocator when buddy will be freed.
 			 * Corresponding page table entries will not be touched,
 			 * pages will stay not present in virtual address space
 			 */
-			INIT_LIST_HEAD(&page[size].lru);
-			set_page_guard_flag(&page[size]);
-			set_page_private(&page[size], high);
-			/* Guard pages are not available for any usage */
-			__mod_zone_freepage_state(zone, -(1 << high),
-						  migratetype);
+			set_page_guard(zone, &page[size], high, migratetype);
 			continue;
 		}
-#endif
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
