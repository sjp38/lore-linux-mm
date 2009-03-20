Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EB0306B004F
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:13 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 17/25] Do not call get_pageblock_migratetype() more than necessary
Date: Fri, 20 Mar 2009 10:03:04 +0000
Message-Id: <1237543392-11797-18-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

get_pageblock_migratetype() is potentially called twice for every page
free. Once, when being freed to the pcp lists and once when being freed
back to buddy. When freeing from the pcp lists, it is known what the
pageblock type was at the time of free so use it rather than rechecking.
In low memory situations under memory pressure, this might skew
anti-fragmentation slightly but the interference is minimal and
decisions that are fragmenting memory are being made anyway.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 mm/page_alloc.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 795cfc5..349c64d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -455,16 +455,18 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  */
 
 static inline void __free_one_page(struct page *page,
-		struct zone *zone, unsigned int order)
+		struct zone *zone, unsigned int order,
+		int migratetype)
 {
 	unsigned long page_idx;
 	int order_size = 1 << order;
-	int migratetype = get_pageblock_migratetype(page);
 
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
 			return;
 
+	VM_BUG_ON(migratetype == -1);
+
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON(page_idx & (order_size - 1));
@@ -533,17 +535,18 @@ static void free_pages_bulk(struct zone *zone, int count,
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_one_page list manipulates */
 		list_del(&page->lru);
-		__free_one_page(page, zone, order);
+		__free_one_page(page, zone, order, page_private(page));
 	}
 	spin_unlock(&zone->lock);
 }
 
-static void free_one_page(struct zone *zone, struct page *page, int order)
+static void free_one_page(struct zone *zone, struct page *page, int order,
+				int migratetype)
 {
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
-	__free_one_page(page, zone, order);
+	__free_one_page(page, zone, order, migratetype);
 	spin_unlock(&zone->lock);
 }
 
@@ -568,7 +571,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	free_one_page(page_zone(page), page, order);
+	free_one_page(page_zone(page), page, order,
+					get_pageblock_migratetype(page));
 	local_irq_restore(flags);
 }
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
