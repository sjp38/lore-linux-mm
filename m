From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/3] lumpy: only count taken pages as scanned
References: <exportbomb.1173723760@pinky>
Message-ID: <f1e5ef335bb5a202c7b18faaa0e97b83@pinky>
Date: Mon, 12 Mar 2007 18:24:18 +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When scanning the order sized area around the tag page we pull all
pages of the matching active state; the non-matching pages are not
otherwise affected.  We currently count these as scanned increasing
the apparent scan rates.  Previously we would only count a page
scanned if it was actually removed from the LRU, either then being
reclaimed or rotated back onto the head of the LRU.

The effect of this is to cause reclaim to terminate artificially
early when the scan count is reached, reducing effectivness.  Move to
counting only those pages we actually remove from the LRU as scanned.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d7a0860..c3dc544 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -732,11 +732,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			scan++;
 			switch (__isolate_lru_page(cursor_page, active)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
+				scan++;
 				break;
 
 			case -EBUSY:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
