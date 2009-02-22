Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45F4B6B0083
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:35 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 19/20] Batch free pages from migratetype per-cpu lists
Date: Sun, 22 Feb 2009 23:17:28 +0000
Message-Id: <1235344649-18265-20-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

When the PCP lists are too large, a number of pages are freed in bulk.
Currently the free lists are examined in a round-robin fashion but it's
not unusual for only pages of the one type to be in the PCP lists so
quite an amount of time is spent checking empty lists. This patch still
frees pages in a round-robin fashion but multiple pages are freed for
each migratetype at a time.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   36 ++++++++++++++++++++++++------------
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 50e2fdc..627837c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -532,22 +532,34 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	spin_lock(&zone->lock);
 	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
 	zone->pages_scanned = 0;
-	while (count--) {
+
+	/* Remove pages from lists in a semi-round-robin fashion */
+	while (count) {
 		struct page *page;
 		struct list_head *list;
+		int batch;
 
-		/* Remove pages from lists in a round-robin fashion */
-		do {
-			if (migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
-			list = &pcp->lists[migratetype];
-			migratetype++;
-		} while (list_empty(list));
+		if (++migratetype == MIGRATE_PCPTYPES)
+			migratetype = 0;
+		list = &pcp->lists[migratetype];
 		
-		page = list_entry(list->prev, struct page, lru);
-		/* have to delete it as __free_one_page list manipulates */
-		list_del(&page->lru);
-		__free_one_page(page, zone, 0, page_private(page));
+		/*
+		 * Free from the lists in batches of 8. Batching avoids
+		 * the case where the pcp lists contain mainly pages of
+		 * one type and constantly cycling around checking empty
+		 * lists. The choice of 8 is somewhat arbitrary but based
+		 * on the expected maximum size of the PCP lists
+		 */
+		for (batch = 0; batch < 8 && count; batch++) {
+			if (list_empty(list))
+				break;
+			page = list_entry(list->prev, struct page, lru);
+
+			/* have to delete as __free_one_page list manipulates */
+			list_del(&page->lru);
+			__free_one_page(page, zone, 0, page_private(page));
+			count--;
+		}
 	}
 	spin_unlock(&zone->lock);
 }
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
