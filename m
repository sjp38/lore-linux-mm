From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070410160304.10742.57011.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
References: <20070410160244.10742.42187.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/4] Remove unnecessary check for MIGRATE_RESERVE during boot
Date: Tue, 10 Apr 2007 17:03:04 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At boot time, a number of MAX_ORDER_NR_PAGES get marked MIGRATE_RESERVE and
the remainder get marked MIGRATE_MOVABLE. The blocks are marked MOVABLE in
memmap_init_zone() before any blocks are marked reserve. A check is made in
memmap_init_zone() for (get_pageblock_migratetype(page) != MIGRATE_RESERVE)
which is a waste of time because the reserve has not been set yet. This
oversight was because an early version of the MIGRATE_RESERVE patch set
blocks MIGRATE_RESERVE earlier. This patch gets rid of the redundant check.

This should be considered a fix for
bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc6-mm1-clean/mm/page_alloc.c linux-2.6.21-rc6-mm1-001_remove_unnecessary_check/mm/page_alloc.c
--- linux-2.6.21-rc6-mm1-clean/mm/page_alloc.c	2007-04-09 23:26:16.000000000 +0100
+++ linux-2.6.21-rc6-mm1-001_remove_unnecessary_check/mm/page_alloc.c	2007-04-09 23:27:58.000000000 +0100
@@ -2468,8 +2468,7 @@ void __meminit memmap_init_zone(unsigned
 		 * the start are marked MIGRATE_RESERVE by
 		 * setup_zone_migrate_reserve()
 		 */
-		if ((pfn & (MAX_ORDER_NR_PAGES-1)) == 0 &&
-				get_pageblock_migratetype(page) != MIGRATE_RESERVE)
+		if ((pfn & (MAX_ORDER_NR_PAGES-1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
