Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 196036B0088
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:44 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 35/35] Allow up to 4MB PCP lists due to compound pages
Date: Mon, 16 Mar 2009 09:46:30 +0000
Message-Id: <1237196790-7268-36-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Compound pages from SLUB on the free lists can occupy a fair percentage of
the 512K that is currently allowed on the PCP lists. This can push out cache
hot order-0 pages even though the compound page may be relatively sparsely
used in the short term. This patch changes pcp->count to count pages (1
per page regardless of order) instead of accounting for the number of base
pages on the list. This keeps cache hot pages on the list at the cost of
the PCP lists being up to 4MB in size instead of 512K.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1ac4c3d..d5161cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -572,11 +572,10 @@ static inline int check_freepage_flags(struct page *page,
 static inline void rmv_pcp_page(struct per_cpu_pages *pcp, struct page *page)
 {
 	int migratetype = page_private(page);
-	int basepage_count = 1 << page->index;
 
 	list_del(&page->lru);
-	pcp->count -= basepage_count;
-	pcp->mocount[migratetype][page->index] -= basepage_count;
+	pcp->count--;
+	pcp->mocount[migratetype][page->index]--;
 }
 
 static inline void add_pcp_page(struct per_cpu_pages *pcp,
@@ -584,22 +583,20 @@ static inline void add_pcp_page(struct per_cpu_pages *pcp,
 					int cold)
 {
 	int migratetype = page_private(page);
-	int basepage_count = 1 << page->index;
 
 	if (cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
 		list_add(&page->lru, &pcp->lists[migratetype]);
-	pcp->count += basepage_count;
-	pcp->mocount[migratetype][page->index] += basepage_count;
+	pcp->count++;
+	pcp->mocount[migratetype][page->index]++;
 }
 
 static inline void bulk_add_pcp_page(struct per_cpu_pages *pcp,
 					int migratetype, int order, int count)
 {
-	int basepage_count = count << order;
-	pcp->count += basepage_count;
-	pcp->mocount[migratetype][order] += basepage_count;
+	pcp->count += count;
+	pcp->mocount[migratetype][order] += count;
 }
 
 /*
@@ -627,9 +624,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 	list = &pcp->lists[migratetype];
 	bulkcount = 1 + (count / (MIGRATE_PCPTYPES * 2));
-	while (freed < count) {
+	while (count--) {
 		struct page *page;
-		int thisfreed;
 
 		/*
 		 * Move to another migratetype if this list is depleted or
@@ -645,9 +641,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		/* Remove from list and update counters */
 		page = list_entry(list->prev, struct page, lru);
 		rmv_pcp_page(pcp, page);
-		thisfreed = 1 << page->index;
-		freed += thisfreed;
-		bulkcount -= thisfreed;
+		freed += 1 << page->index;
+		bulkcount--;
 
 		__free_one_page(page, zone, page->index, migratetype);
 	}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
