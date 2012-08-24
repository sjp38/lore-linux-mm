Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 86F9C6B005D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 06:45:37 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M9900KSU9UQ0N00@mailout3.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Aug 2012 19:45:36 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M990073E9VOI960@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 24 Aug 2012 19:45:35 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 1/4] cma: fix counting of isolated pages
Date: Fri, 24 Aug 2012 12:45:17 +0200
Message-id: <1345805120-797-2-git-send-email-b.zolnierkie@samsung.com>
In-reply-to: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com>
References: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Isolated free pages shouldn't be accounted to NR_FREE_PAGES counter.
Fix it by properly decreasing/increasing NR_FREE_PAGES counter in
set_migratetype_isolate()/unset_migratetype_isolate() and removing
counter adjustment for isolated pages from free_one_page() and
split_free_page().

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/page_alloc.c     |  7 +++++--
 mm/page_isolation.c | 13 ++++++++++---
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b94429e..e9bbd7c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -688,7 +688,8 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->pages_scanned = 0;
 
 	__free_one_page(page, zone, order, migratetype);
-	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	spin_unlock(&zone->lock);
 }
 
@@ -1412,7 +1413,9 @@ int split_free_page(struct page *page, bool check_wmark)
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 
 	/* Split into individual pages */
 	set_page_refcounted(page);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 247d1f1..d210cc8 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -76,8 +76,12 @@ int set_migratetype_isolate(struct page *page)
 
 out:
 	if (!ret) {
+		unsigned long nr_pages;
+
 		set_pageblock_isolate(page);
-		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -89,12 +93,15 @@ out:
 void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
-	unsigned long flags;
+	unsigned long flags, nr_pages;
+
 	zone = page_zone(page);
+
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	move_freepages_block(zone, page, migratetype);
+	nr_pages = move_freepages_block(zone, page, migratetype);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
 	restore_pageblock_isolate(page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
-- 
1.7.11.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
