Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7EA6B026D
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:42:24 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so5755713wrk.7
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:42:24 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id m1si1011830wmm.250.2017.12.08.03.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 03:42:23 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH v2] mm: page_alloc: avoid excessive IRQ disabled times in free_unref_page_list
Date: Fri,  8 Dec 2017 12:42:17 +0100
Message-Id: <20171208114217.8491-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, patchwork-lst@pengutronix.de, kernel@pengutronix.de

Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
a list of pages) we see excessive IRQ disabled times of up to 25ms on an
embedded ARM system (tracing overhead included).

This is due to graphics buffers being freed back to the system via
release_pages(). Graphics buffers can be huge, so it's not hard to hit
cases where the list of pages to free has 2048 entries. Disabling IRQs
while freeing all those pages is clearly not a good idea.

Introduce a batch limit, which allows IRQ servicing once every few pages.
The batch count is the same as used in other parts of the MM subsystem
when dealing with IRQ disabled regions.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
---
v2: Try to keep the working set of pages used in the second loop cache
    hot by going through both loops in swathes of SWAP_CLUSTER_MAX
    entries, as suggested by Andrew Morton.

    To avoid the need to replicate the batch counting in both loops
    I introduced a local batched_free_list where pages to be freed
    in the critical section are collected. IMO this makes the code
    easier to follow.
---
 mm/page_alloc.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73f5d4556b3d..522870f1a8f2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2685,23 +2685,37 @@ void free_unref_page_list(struct list_head *list)
 	struct page *page, *next;
 	unsigned long flags, pfn;
 
-	/* Prepare pages for freeing */
-	list_for_each_entry_safe(page, next, list, lru) {
-		pfn = page_to_pfn(page);
-		if (!free_unref_page_prepare(page, pfn))
-			list_del(&page->lru);
-		set_page_private(page, pfn);
-	}
+	while (!list_empty(list)) {
+		LIST_HEAD(batched_free_list);
+		unsigned int batch_count = 0;
 
-	local_irq_save(flags);
-	list_for_each_entry_safe(page, next, list, lru) {
-		unsigned long pfn = page_private(page);
+		/*
+		 * Prepare pages for freeing. Collects at max SWAP_CLUSTER_MAX
+		 * pages for batched free in single IRQs off critical section.
+		 */
+		list_for_each_entry_safe(page, next, list, lru) {
+			pfn = page_to_pfn(page);
+			if (!free_unref_page_prepare(page, pfn)) {
+				list_del(&page->lru);
+			} else {
+				list_move(&page->lru, &batched_free_list);
+				batch_count++;
+			}
+			set_page_private(page, pfn);
+			if (batch_count == SWAP_CLUSTER_MAX)
+				break;
+		}
 
-		set_page_private(page, 0);
-		trace_mm_page_free_batched(page);
-		free_unref_page_commit(page, pfn);
+		local_irq_save(flags);
+		list_for_each_entry_safe(page, next, &batched_free_list, lru) {
+			unsigned long pfn = page_private(page);
+
+			set_page_private(page, 0);
+			trace_mm_page_free_batched(page);
+			free_unref_page_commit(page, pfn);
+		}
+		local_irq_restore(flags);
 	}
-	local_irq_restore(flags);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
