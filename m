Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4096D6B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 04:19:40 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MF7009S3Z8QD2X0@mailout2.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Dec 2012 18:19:38 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MF7009M8Z8O5O40@mmp2.samsung.com> for linux-mm@kvack.org;
 Tue, 18 Dec 2012 18:19:38 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: fix zone_watermark_ok_safe() accounting of isolated pages
Date: Tue, 18 Dec 2012 10:18:41 +0100
MIME-version: 1.0
Message-id: <201212181018.41753.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Hugh Dickins <hughd@google.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] mm: fix zone_watermark_ok_safe() accounting of isolated pages

In kernel v3.6 commit 702d1a6e0766d45642c934444fd41f658d251305
("memory-hotplug: fix kswapd looping forever problem") added
isolated pageblocks counter (nr_pageblock_isolate in struct zone)
and used it to adjust free pages counter in zone_watermark_ok_safe()
to prevent kswapd looping forever problem.  In kernel v3.7 commit
2139cbe627b8910ded55148f87ee10f7485408ed ("cma: fix counting of
isolated pages") fixed accounting of isolated pages in global free
pages counter.  It made previous zone_watermark_ok_safe() fix
unnecessary and potentially harmful (cause now isolated pages may
be accounted twice making free pages counter incorrect).  This
patch removes special isolated pageblocks counter altogether which
fixes zone_watermark_ok_safe() free pages check.

Reported-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/mmzone.h |    8 --------
 mm/page_alloc.c        |   27 ---------------------------
 mm/page_isolation.c    |   26 ++------------------------
 3 files changed, 2 insertions(+), 59 deletions(-)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2012-12-17 11:49:25.067058393 +0100
+++ b/include/linux/mmzone.h	2012-12-17 11:49:34.507058390 +0100
@@ -503,14 +503,6 @@ struct zone {
 	 * rarely used fields:
 	 */
 	const char		*name;
-#ifdef CONFIG_MEMORY_ISOLATION
-	/*
-	 * the number of MIGRATE_ISOLATE *pageblock*.
-	 * We need this for free page counting. Look at zone_watermark_ok_safe.
-	 * It's protected by zone->lock
-	 */
-	int		nr_pageblock_isolate;
-#endif
 } ____cacheline_internodealigned_in_smp;
 
 typedef enum {
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2012-12-17 11:45:13.019058423 +0100
+++ b/mm/page_alloc.c	2012-12-17 11:46:48.663058410 +0100
@@ -221,11 +221,6 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-/*
- * NOTE:
- * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) directly.
- * Instead, use {un}set_pageblock_isolate.
- */
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
@@ -1654,20 +1649,6 @@ static bool __zone_watermark_ok(struct z
 	return true;
 }
 
-#ifdef CONFIG_MEMORY_ISOLATION
-static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
-{
-	if (unlikely(zone->nr_pageblock_isolate))
-		return zone->nr_pageblock_isolate * pageblock_nr_pages;
-	return 0;
-}
-#else
-static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
-{
-	return 0;
-}
-#endif
-
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
@@ -1683,14 +1664,6 @@ bool zone_watermark_ok_safe(struct zone 
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
 
-	/*
-	 * If the zone has MIGRATE_ISOLATE type free pages, we should consider
-	 * it.  nr_zone_isolate_freepages is never accurate so kswapd might not
-	 * sleep although it could do so.  But this is more desirable for memory
-	 * hotplug than sleeping which can cause a livelock in the direct
-	 * reclaim path.
-	 */
-	free_pages -= nr_zone_isolate_freepages(z);
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
 								free_pages);
 }
Index: b/mm/page_isolation.c
===================================================================
--- a/mm/page_isolation.c	2012-12-17 11:43:41.135058434 +0100
+++ b/mm/page_isolation.c	2012-12-17 11:45:00.995058424 +0100
@@ -8,28 +8,6 @@
 #include <linux/memory.h>
 #include "internal.h"
 
-/* called while holding zone->lock */
-static void set_pageblock_isolate(struct page *page)
-{
-	if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
-		return;
-
-	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-	page_zone(page)->nr_pageblock_isolate++;
-}
-
-/* called while holding zone->lock */
-static void restore_pageblock_isolate(struct page *page, int migratetype)
-{
-	struct zone *zone = page_zone(page);
-	if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE))
-		return;
-
-	BUG_ON(zone->nr_pageblock_isolate <= 0);
-	set_pageblock_migratetype(page, migratetype);
-	zone->nr_pageblock_isolate--;
-}
-
 int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 {
 	struct zone *zone;
@@ -80,7 +58,7 @@ out:
 		unsigned long nr_pages;
 		int migratetype = get_pageblock_migratetype(page);
 
-		set_pageblock_isolate(page);
+		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
 
 		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
@@ -103,7 +81,7 @@ void unset_migratetype_isolate(struct pa
 		goto out;
 	nr_pages = move_freepages_block(zone, page, migratetype);
 	__mod_zone_freepage_state(zone, nr_pages, migratetype);
-	restore_pageblock_isolate(page, migratetype);
+	set_pageblock_migratetype(page, migratetype);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
