Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B18FA90010F
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:26:20 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 42so951630iyh.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:26:19 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [RFC 8/8] compaction: make compaction use in-order putback
Date: Wed, 27 Apr 2011 01:25:25 +0900
Message-Id: <b7bcce639e9b9bf515431cda79b15d482f889ff2.1303833418.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1303833415.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

Compaction is good solution to get contiguos page but it makes
LRU churing which is not good.
This patch makes that compaction code use in-order putback so
after compaction completion, migrated pages are keeping LRU ordering.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a2f6e96..480d2ac 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -211,11 +211,11 @@ static void isolate_freepages(struct zone *zone,
 /* Update the number of anon and file isolated pages in the zone */
 static void acct_isolated(struct zone *zone, struct compact_control *cc)
 {
-	struct page *page;
+	struct pages_lru *pages_lru;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
 
-	list_for_each_entry(page, &cc->migratepages, lru) {
-		int lru = page_lru_base_type(page);
+	list_for_each_entry(pages_lru, &cc->migratepages, lru) {
+		int lru = page_lru_base_type(pages_lru->page);
 		count[lru]++;
 	}
 
@@ -281,6 +281,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
+		struct pages_lru *pages_lru;
 		bool locked = true;
 
 		/* give a chance to irqs before checking need_resched() */
@@ -334,10 +335,16 @@ static unsigned long isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
+		pages_lru = kmalloc(sizeof(struct pages_lru), GFP_ATOMIC);
+		if (pages_lru)
+			continue;
+
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0,
-					!cc->sync, 0, NULL) != 0)
+		if ( __isolate_lru_page(page, ISOLATE_BOTH, 0,
+					!cc->sync, 0, pages_lru) != 0) {
+			kfree(pages_lru);
 			continue;
+		}
 
 		VM_BUG_ON(PageTransCompound(page));
 
@@ -398,8 +405,9 @@ static void update_nr_listpages(struct compact_control *cc)
 	int nr_migratepages = 0;
 	int nr_freepages = 0;
 	struct page *page;
+	struct pages_lru *pages_lru;
 
-	list_for_each_entry(page, &cc->migratepages, lru)
+	list_for_each_entry(pages_lru, &cc->migratepages, lru)
 		nr_migratepages++;
 	list_for_each_entry(page, &cc->freepages, lru)
 		nr_freepages++;
@@ -542,7 +550,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		/* Release LRU pages not migrated */
 		if (err) {
-			putback_lru_pages(&cc->migratepages);
+			putback_pages_lru(&cc->migratepages);
 			cc->nr_migratepages = 0;
 		}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
