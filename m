Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DFDE96B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:24:31 -0500 (EST)
Received: by padhx2 with SMTP id hx2so182018016pad.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:31 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ks4si20626521pbc.15.2015.11.08.23.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 23:24:31 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so166232219pac.3
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:31 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/3] mm/page_isolation: return last tested pfn rather than failure indicator
Date: Mon,  9 Nov 2015 16:24:19 +0900
Message-Id: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This is preparation step to report test failed pfn in new tracepoint
to analyze cma allocation failure problem. There is no functional change
in this patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4568fd5..6f5ae96 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -212,7 +212,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  *
  * Returns 1 if all pages in the range are isolated.
  */
-static int
+static unsigned long
 __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 				  bool skip_hwpoisoned_pages)
 {
@@ -237,9 +237,8 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 		else
 			break;
 	}
-	if (pfn < end_pfn)
-		return 0;
-	return 1;
+
+	return pfn;
 }
 
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
@@ -248,7 +247,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn, flags;
 	struct page *page;
 	struct zone *zone;
-	int ret;
 
 	/*
 	 * Note: pageblock_nr_pages != MAX_ORDER. Then, chunks of free pages
@@ -266,10 +264,11 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	/* Check all pages are free or marked as ISOLATED */
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
-	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
+	pfn = __test_page_isolated_in_pageblock(start_pfn, end_pfn,
 						skip_hwpoisoned_pages);
 	spin_unlock_irqrestore(&zone->lock, flags);
-	return ret ? 0 : -EBUSY;
+
+	return (pfn < end_pfn) ? -EBUSY : 0;
 }
 
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
