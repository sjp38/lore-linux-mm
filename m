From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070524190526.31911.56425.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
References: <20070524190505.31911.42785.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/5] Fix calculation in move_freepages_block for counting pages
Date: Thu, 24 May 2007 20:05:26 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

move_freepages_block() returns the number of blocks moved. This value is
used to determine if a block of pages should be stolen for the exclusive
use of a migrate type or not. However, the value returned is being used
correctly. This patch fixes the calculation to return the number of base
pages that have been moved.

This should be considered a fix to the patch move-free-pages-between-lists-on-steal.patch

Credit to Andy Whitcroft for spotting the problem.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page_alloc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-clean/mm/page_alloc.c linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/page_alloc.c
--- linux-2.6.22-rc2-mm1-clean/mm/page_alloc.c	2007-05-24 10:13:34.000000000 +0100
+++ linux-2.6.22-rc2-mm1-001_fix_movefreepages/mm/page_alloc.c	2007-05-24 16:37:27.000000000 +0100
@@ -728,7 +728,7 @@ int move_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long order;
-	int blocks_moved = 0;
+	int pages_moved = 0;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -757,10 +757,10 @@ int move_freepages(struct zone *zone,
 		list_add(&page->lru,
 			&zone->free_area[order].free_list[migratetype]);
 		page += 1 << order;
-		blocks_moved++;
+		pages_moved += 1 << order;
 	}
 
-	return blocks_moved;
+	return pages_moved;
 }
 
 int move_freepages_block(struct zone *zone, struct page *page, int migratetype)
@@ -843,7 +843,7 @@ static struct page *__rmqueue_fallback(s
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if ((pages << current_order) >= (1 << (MAX_ORDER-2)))
+				if (pages >= (1 << (MAX_ORDER-2)))
 					set_pageblock_migratetype(page,
 								start_migratetype);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
