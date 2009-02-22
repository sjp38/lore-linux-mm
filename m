Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 607976B0062
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:31 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 14/20] Do not call get_pageblock_migratetype() more than necessary
Date: Sun, 22 Feb 2009 23:17:23 +0000
Message-Id: <1235344649-18265-15-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

get_pageblock_migratetype() is potentially called twice for every page
free. Once, when being freed to the pcp lists and once when being freed
back to buddy. When freeing from the pcp lists, it is known what the
pageblock type was at the time of free so use it rather than rechecking.
In low memory situations under memory pressure, this might skew
anti-fragmentation slightly but the interference is minimal and
decisions that are fragmenting memory are being made anyway.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2383147..a9e9466 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -77,7 +77,8 @@ int percpu_pagelist_fraction;
 int pageblock_order __read_mostly;
 #endif
 
-static void __free_pages_ok(struct page *page, unsigned int order);
+static void __free_pages_ok(struct page *page, unsigned int order,
+					int migratetype);
 
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
@@ -283,7 +284,7 @@ out:
 
 static void free_compound_page(struct page *page)
 {
-	__free_pages_ok(page, compound_order(page));
+	__free_pages_ok(page, compound_order(page), -1);
 }
 
 void prep_compound_page(struct page *page, unsigned long order)
@@ -456,16 +457,19 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
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
 
+	if (migratetype == -1)
+		migratetype = get_pageblock_migratetype(page);
+
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON(page_idx & (order_size - 1));
@@ -534,21 +538,23 @@ static void free_pages_bulk(struct zone *zone, int count,
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
 
-static void __free_pages_ok(struct page *page, unsigned int order)
+static void __free_pages_ok(struct page *page, unsigned int order,
+				int migratetype)
 {
 	unsigned long flags;
 	int i;
@@ -569,7 +575,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	free_one_page(page_zone(page), page, order);
+	free_one_page(page_zone(page), page, order, migratetype);
 	local_irq_restore(flags);
 }
 
@@ -1864,7 +1870,7 @@ void __free_pages(struct page *page, unsigned int order)
 		if (order == 0)
 			free_hot_page(page);
 		else
-			__free_pages_ok(page, order);
+			__free_pages_ok(page, order, -1);
 	}
 }
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
