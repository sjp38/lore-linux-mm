Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F26108D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 06:46:55 -0500 (EST)
Received: by pvc30 with SMTP id 30so254786pvc.14
        for <linux-mm@kvack.org>; Thu, 10 Feb 2011 03:46:53 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
Date: Thu, 10 Feb 2011 20:46:48 +0900
Message-Id: <1297338408-3590-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now I'm seeing that there are some cases to free all pages in a
pcp lists. In that case, just frees all pages in the lists instead
of being bothered with round-robin lists traversal.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/page_alloc.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e8b02771ccea..959c54450ddf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -596,6 +596,28 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
+	/* Simple case: Free all */
+	if (to_free == pcp->count) {
+		LIST_HEAD(freelist);
+
+		for (; migratetype < MIGRATE_PCPTYPES; migratetype++)
+			if (!list_empty(&pcp->lists[migratetype]))
+				list_move(&pcp->lists[migratetype], &freelist);
+
+		while (!list_empty(&freelist)) {
+			struct page *page;
+
+			page = list_first_entry(&freelist, struct page, lru);
+			/* must delete as __free_one_page list manipulates */
+			list_del(&page->lru);
+			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
+			__free_one_page(page, zone, 0, page_private(page));
+			trace_mm_page_pcpu_drain(page, 0, page_private(page));
+			to_free--;
+		}
+		VM_BUG_ON(to_free);
+	}
+
 	while (to_free) {
 		struct page *page;
 		struct list_head *list;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
