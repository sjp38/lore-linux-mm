Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2FF6B0073
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:53:15 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so1576922pdj.19
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:53:15 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id t8si1682358pdl.272.2014.07.04.00.53.10
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:53:14 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 09/10] mm/page_alloc: fix possible wrongly calculated freepage counter
Date: Fri,  4 Jul 2014 16:57:54 +0900
Message-Id: <1404460675-24456-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When isolating/unisolating some pageblock, we add/sub number of
pages returend by move_freepages_block() to calculate number of freepage.
But, this value is invalid for calculation, because it means number of
pages in buddy list of that migratetype rather than number of *moved*
pages. So number of freepage could be incorrect more and more whenever
calling these functions.

And, there is one more counting problem on
__test_page_isolated_in_pageblock(). move_freepages() is called, but missed
to fixup number of freepage. I think that counting should be done in
move_freepages(), otherwise, another future user to this function also
missed to fixup number of freepage again.

Now, we have proper infrastructure, get_onbuddy_migratetype(), which can
be used to get current migratetype of buddy list. So fix this situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c     |   37 ++++++++++++++++++++++++++++++++++---
 mm/page_isolation.c |   12 +++---------
 2 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d9fb8bb..80c9bd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -465,6 +465,33 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype) {}
 #endif
 
+static inline void count_freepage_nr(struct page *page, int order,
+				int *nr_isolate, int *nr_cma, int *nr_others)
+{
+	int nr = 1 << order;
+	int migratetype = get_onbuddy_migratetype(page);
+
+	if (is_migrate_isolate(migratetype))
+		*nr_isolate += nr;
+	else if (is_migrate_cma(migratetype))
+		*nr_cma += nr;
+	else
+		*nr_others += nr;
+}
+
+static void fixup_freepage_nr(struct zone *zone, int migratetype,
+				int nr_isolate, int nr_cma, int nr_others)
+{
+	int nr_free = nr_cma + nr_others;
+
+	if (is_migrate_isolate(migratetype)) {
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_free);
+		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, -nr_cma);
+	} else {
+		__mod_zone_freepage_state(zone, nr_isolate, migratetype);
+	}
+}
+
 static inline void set_page_order(struct page *page, unsigned int order,
 							int migratetype)
 {
@@ -619,6 +646,7 @@ static inline void __free_one_page(struct page *page,
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
 			break;
+
 		/*
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
@@ -1062,7 +1090,7 @@ int move_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long order;
-	int pages_moved = 0;
+	int nr_pages = 0, nr_isolate = 0, nr_cma = 0, nr_others = 0;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -1090,14 +1118,17 @@ int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
+		count_freepage_nr(page, order,
+			&nr_isolate, &nr_cma, &nr_others);
 		list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
 		set_onbuddy_migratetype(page, migratetype);
 		page += 1 << order;
-		pages_moved += 1 << order;
+		nr_pages += 1 << order;
 	}
 
-	return pages_moved;
+	fixup_freepage_nr(zone, migratetype, nr_isolate, nr_cma, nr_others);
+	return nr_pages;
 }
 
 int move_freepages_block(struct zone *zone, struct page *page,
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 6e4e86b..62676de 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -56,14 +56,9 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 
 out:
 	if (!ret) {
-		unsigned long nr_pages;
-		int migratetype = get_pageblock_migratetype(page);
-
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
-		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
-
-		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
+		move_freepages_block(zone, page, MIGRATE_ISOLATE);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -75,14 +70,13 @@ out:
 void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
-	unsigned long flags, nr_pages;
+	unsigned long flags;
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	nr_pages = move_freepages_block(zone, page, migratetype);
-	__mod_zone_freepage_state(zone, nr_pages, migratetype);
+	move_freepages_block(zone, page, migratetype);
 	set_pageblock_migratetype(page, migratetype);
 	zone->nr_isolate_pageblock--;
 out:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
