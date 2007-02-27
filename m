Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1RJYsjt005940
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:34:54 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1RJYrF8500416
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:34:53 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1RJYr7U029221
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:34:53 -0700
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/5] lumpy: isolate_lru_pages wants to specifically take active or inactive pages
References: <exportbomb.1172604830@kernel>
Message-ID: <f2cdac47f652dc10d19f6041997e85b1@kernel>
Date: Tue, 27 Feb 2007 11:34:52 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The caller of isolate_lru_pages specifically knows whether it wants
to take either inactive or active pages.  Currently we take the
state of the LRU page at hand and use that to scan for matching
pages in the order sized block.  If that page is transiting we
can scan for the wrong type.  The caller knows what they want and
should be telling us.  Pass in the required active/inactive state
and match against that.

Note, that now we pass the expected active state when scanning the
active/inactive lists we may find missmatching target pages, pages
which are in the process of changing state.  This is no longer an
error and we should simply ignore them.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f15ffcb..b878d54 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -663,12 +663,13 @@ static int __isolate_lru_page(struct page *page, int active)
  * @dst:	The temp list to put pages on to.
  * @scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
+ * @active:	The caller's trying to obtain active or inactive pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order)
+		unsigned long *scanned, int order, int active)
 {
 	unsigned long nr_taken = 0;
 	unsigned long scan;
@@ -678,7 +679,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long pfn;
 		unsigned long end_pfn;
 		unsigned long page_pfn;
-		int active;
 		int zone_id;
 
 		page = lru_to_page(src);
@@ -686,20 +686,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON(!PageLRU(page));
 
-		active = PageActive(page);
 		switch (__isolate_lru_page(page, active)) {
 		case 0:
 			list_move(&page->lru, dst);
 			nr_taken++;
 			break;
 
-		case -EBUSY:
-			/* else it is being freed elsewhere */
+		default:
+			/* page is being freed, or is a missmatch */
 			list_move(&page->lru, src);
 			continue;
-
-		default:
-			BUG();
 		}
 
 		if (!order)
@@ -768,8 +764,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_freed;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
-					     &zone->inactive_list,
-					     &page_list, &nr_scan, sc->order);
+				     &zone->inactive_list,
+				     &page_list, &nr_scan, sc->order, 0);
 		__mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
 		zone->pages_scanned += nr_scan;
 		zone->total_scanned += nr_scan;
@@ -916,7 +912,7 @@ force_reclaim_mapped:
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-				    &l_hold, &pgscanned, sc->order);
+				    &l_hold, &pgscanned, sc->order, 1);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
