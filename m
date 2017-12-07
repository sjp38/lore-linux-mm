Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F09B6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 12:03:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so3700120wmd.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 09:03:20 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id q18si4344695wrc.24.2017.12.07.09.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 09:03:18 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] mm: page_alloc: avoid excessive IRQ disabled times in free_unref_page_list
Date: Thu,  7 Dec 2017 18:03:14 +0100
Message-Id: <20171207170314.4419-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

Since 9cca35d42eb6 (mm, page_alloc: enable/disable IRQs once when freeing
a list of pages) we see excessive IRQ disabled times of up to 250ms on an
embedded ARM system (tracing overhead included).

This is due to graphics buffers being freed back to the system via
release_pages(). Graphics buffers can be huge, so it's not hard to hit
cases where the list of pages to free has 2048 entries. Disabling IRQs
while freeing all those pages is clearly not a good idea.

Introduce a batch limit, which allows IRQ servicing once every few pages.
The batch count is the same as used in other parts of the MM subsystem
when dealing with IRQ disabled regions.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 mm/page_alloc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73f5d4556b3d..7e5e775e97f4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2684,6 +2684,7 @@ void free_unref_page_list(struct list_head *list)
 {
 	struct page *page, *next;
 	unsigned long flags, pfn;
+	int batch_count = 0;
 
 	/* Prepare pages for freeing */
 	list_for_each_entry_safe(page, next, list, lru) {
@@ -2700,6 +2701,16 @@ void free_unref_page_list(struct list_head *list)
 		set_page_private(page, 0);
 		trace_mm_page_free_batched(page);
 		free_unref_page_commit(page, pfn);
+
+		/*
+		 * Guard against excessive IRQ disabled times when we get
+		 * a large list of pages to free.
+		 */
+		if (++batch_count == SWAP_CLUSTER_MAX) {
+			local_irq_restore(flags);
+			batch_count = 0;
+			local_irq_save(flags);
+		}
 	}
 	local_irq_restore(flags);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
