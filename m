Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 103356B01DB
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:23:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 08/12] vmscan: Setup pagevec as late as possible in shrink_inactive_list()
Date: Mon, 14 Jun 2010 12:17:49 +0100
Message-Id: <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
uses significant amounts of stack doing this. This patch splits
shrink_inactive_list() to take the stack usage out of the main path so
that callers to writepage() do not contain an unused pagevec on the
stack.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   95 +++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 54 insertions(+), 41 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 246e084..34c5c87 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1129,19 +1129,65 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 /*
+ * TODO: Try merging with migrations version of putback_lru_pages
+ */
+static noinline_for_stack void putback_lru_pages(struct zone *zone,
+				struct zone_reclaim_stat *reclaim_stat,
+				unsigned long nr_anon, unsigned long nr_file,
+ 				struct list_head *page_list)
+{
+	struct page *page;
+	struct pagevec pvec;
+
+	pagevec_init(&pvec, 1);
+
+	/*
+	 * Put back any unfreeable pages.
+	 */
+	spin_lock(&zone->lru_lock);
+	while (!list_empty(page_list)) {
+		int lru;
+		page = lru_to_page(page_list);
+		VM_BUG_ON(PageLRU(page));
+		list_del(&page->lru);
+		if (unlikely(!page_evictable(page, NULL))) {
+			spin_unlock_irq(&zone->lru_lock);
+			putback_lru_page(page);
+			spin_lock_irq(&zone->lru_lock);
+			continue;
+		}
+		SetPageLRU(page);
+		lru = page_lru(page);
+		add_page_to_lru_list(zone, page, lru);
+		if (is_active_lru(lru)) {
+			int file = is_file_lru(lru);
+			reclaim_stat->recent_rotated[file]++;
+		}
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+
+	spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
+
+/*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
-static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
+static noinline_for_stack unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 			struct zone *zone, struct scan_control *sc,
 			int priority, int file)
 {
 	LIST_HEAD(page_list);
-	struct pagevec pvec;
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	struct page *page;
 	unsigned long nr_taken;
 	unsigned long nr_active;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
@@ -1157,8 +1203,6 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 	}
 
 
-	pagevec_init(&pvec, 1);
-
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1186,8 +1230,10 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 		 */
 	}
 
-	if (nr_taken == 0)
-		goto done;
+	if (nr_taken == 0) {
+		spin_unlock_irq(&zone->lru_lock);
+		return 0;
+	}
 
 	nr_active = clear_active_flags(&page_list, count);
 	__count_vm_events(PGDEACTIVATE, nr_active);
@@ -1237,40 +1283,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-	spin_lock(&zone->lru_lock);
-	/*
-	 * Put back any unfreeable pages.
-	 */
-	while (!list_empty(&page_list)) {
-		int lru;
-		page = lru_to_page(&page_list);
-		VM_BUG_ON(PageLRU(page));
-		list_del(&page->lru);
-		if (unlikely(!page_evictable(page, NULL))) {
-			spin_unlock_irq(&zone->lru_lock);
-			putback_lru_page(page);
-			spin_lock_irq(&zone->lru_lock);
-			continue;
-		}
-		SetPageLRU(page);
-		lru = page_lru(page);
-		add_page_to_lru_list(zone, page, lru);
-		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
-			reclaim_stat->recent_rotated[file]++;
-		}
-		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
-
-done:
-	spin_unlock_irq(&zone->lru_lock);
-	pagevec_release(&pvec);
+	putback_lru_pages(zone, reclaim_stat, nr_anon, nr_file, &page_list);
 	return nr_reclaimed;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
