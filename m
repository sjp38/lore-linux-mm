Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4A382905
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:20 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so9606840pac.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:20 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id n4si3885561pdn.170.2015.02.11.23.30.11
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:12 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 07/16] mm/page_isolation: watch out zone range overlap
Date: Thu, 12 Feb 2015 16:32:11 +0900
Message-Id: <1423726340-4084-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, new zone, ZONE_CMA, will be introduced and
it would be overlapped with other zones. Currently, many places
iterating pfn range doesn't consider possibility of zone overlap and
this would cause a problem such as printing wrong statistics information.
To prevent this situation, this patch add some code to consider zone
overlapping before adding ZONE_CMA.

pfn range argument provieded to test_pages_isolated() should be in
a single zone. If not, zone lock doesn't work to protect free state of
buddy freepage.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index c8778f7..883e78d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -210,8 +210,8 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * Returns 1 if all pages in the range are isolated.
  */
 static int
-__test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
-				  bool skip_hwpoisoned_pages)
+__test_page_isolated_in_pageblock(struct zone *zone, unsigned long pfn,
+			unsigned long end_pfn, bool skip_hwpoisoned_pages)
 {
 	struct page *page;
 
@@ -221,6 +221,9 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (page_zone(page) != zone)
+			break;
+
 		if (PageBuddy(page)) {
 			/*
 			 * If race between isolatation and allocation happens,
@@ -281,7 +284,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	/* Check all pages are free or marked as ISOLATED */
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
-	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
+	ret = __test_page_isolated_in_pageblock(zone, start_pfn, end_pfn,
 						skip_hwpoisoned_pages);
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
