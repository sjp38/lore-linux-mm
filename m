Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0DD096B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 22:18:31 -0400 (EDT)
From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] mm: kill one if in loop of __free_pages_bootmem
Date: Mon, 22 Jul 2013 19:17:42 -0700
Message-Id: <1374545862-17741-1-git-send-email-yinghai@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>

We should not check loop+1 with loop end in loop body.
Just duplicate two lines code to avoid it.

That will help a bit when we have huge amount of pages on
system with 16TiB memory.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>

---
 mm/page_alloc.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -750,19 +750,19 @@ static void __free_pages_ok(struct page
 void __init __free_pages_bootmem(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
+	struct page *p = page;
 	unsigned int loop;
 
-	prefetchw(page);
-	for (loop = 0; loop < nr_pages; loop++) {
-		struct page *p = &page[loop];
-
-		if (loop + 1 < nr_pages)
-			prefetchw(p + 1);
+	prefetchw(p);
+	for (loop = 0; loop < (nr_pages - 1); loop++, p++) {
+		prefetchw(p + 1);
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
 	}
+	__ClearPageReserved(p);
+	set_page_count(p, 0);
 
-	page_zone(page)->managed_pages += 1 << order;
+	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
