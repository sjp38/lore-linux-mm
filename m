Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l1RJYthT031389
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 14:34:55 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1RJZsxq499680
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:35:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1RJZs6T026733
	for <linux-mm@kvack.org>; Tue, 27 Feb 2007 12:35:54 -0700
From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/5] lumpy: update commentry on subtle comparisons and rounding assumptions
References: <exportbomb.1172604830@kernel>
Message-ID: <809581470a06dbac8c3e709828bf7e72@kernel>
Date: Tue, 27 Feb 2007 11:35:53 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

We have a number of subtle comparisons when scanning a block, and
we make use of a lot of buddy mem_map guarentees.  Add commentary about
each.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2bfad79..bef7e92 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -709,7 +709,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		/*
 		 * Attempt to take all pages in the order aligned region
 		 * surrounding the tag page.  Only take those pages of
-		 * the same active state as that tag page.
+		 * the same active state as that tag page.  We may safely
+		 * round the target page pfn down to the requested order
+		 * as the mem_map is guarenteed valid out to MAX_ORDER,
+		 * where that page is in a different zone we will detect
+		 * it from its zone id and abort this block scan.
 		 */
 		zone_id = page_zone_id(page);
 		page_pfn = page_to_pfn(page);
@@ -718,12 +722,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		for (; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
 
+			/* The target page is in the block, ignore it. */
 			if (unlikely(pfn == page_pfn))
 				continue;
+			/* Avoid holes within the zone. */
 			if (unlikely(!pfn_valid(pfn)))
 				break;
 
 			cursor_page = pfn_to_page(pfn);
+			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
 			scan++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
