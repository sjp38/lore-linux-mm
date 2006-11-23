Date: Thu, 23 Nov 2006 16:50:10 +0000
Subject: [PATCH 3/4] lumpy ensure we respect zone boundaries
Message-ID: <bf938e31d7fe72a5128a5bd22bb70480@pinky>
References: <exportbomb.1164300519@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When scanning an aligned order N area ensure we only pull out pages
in the same zone as our tag page, else we will manipulate those
pages' LRU under the wrong zone lru_lock.  Bad.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3b6ef79..e3be888 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -663,6 +663,7 @@ static unsigned long isolate_lru_pages(u
 	struct page *page, *tmp;
 	unsigned long scan, pfn, end_pfn, page_pfn;
 	int active;
+	int zone_id;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		page = lru_to_page(src);
@@ -694,6 +695,7 @@ static unsigned long isolate_lru_pages(u
 		 * surrounding the tag page.  Only take those pages of
 		 * the same active state as that tag page.
 		 */
+		zone_id = page_zone_id(page);
 		page_pfn = __page_to_pfn(page);
 		pfn = page_pfn & ~((1 << order) - 1);
 		end_pfn = pfn + (1 << order);
@@ -703,8 +705,10 @@ static unsigned long isolate_lru_pages(u
 			if (unlikely(!pfn_valid(pfn)))
 				break;
 
-			scan++;
 			tmp = __pfn_to_page(pfn);
+			if (unlikely(page_zone_id(tmp) != zone_id))
+				continue;
+			scan++;
 			switch (__isolate_lru_page(tmp, active)) {
 			case 0:
 				list_move(&tmp->lru, dst);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
