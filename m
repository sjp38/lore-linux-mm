Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 38CC56B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 12:48:08 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so8370748wgh.18
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 09:48:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si11102045wiw.11.2014.06.30.09.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 09:48:07 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: pagemap: Avoid unnecessary overhead when tracepoints are deactivated
Date: Mon, 30 Jun 2014 17:48:00 +0100
Message-Id: <1404146883-21414-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1404146883-21414-1-git-send-email-mgorman@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

The LRU insertion and activate tracepoints take PFN as a parameter forcing
the overhead to the caller.  Move the overhead to the tracepoint fast-assign
method to ensure the cost is only incurred when the tracepoint is active.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/pagemap.h | 16 +++++++---------
 mm/swap.c                      |  4 ++--
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/trace/events/pagemap.h b/include/trace/events/pagemap.h
index 1c9fabd..ce0803b 100644
--- a/include/trace/events/pagemap.h
+++ b/include/trace/events/pagemap.h
@@ -28,12 +28,10 @@ TRACE_EVENT(mm_lru_insertion,
 
 	TP_PROTO(
 		struct page *page,
-		unsigned long pfn,
-		int lru,
-		unsigned long flags
+		int lru
 	),
 
-	TP_ARGS(page, pfn, lru, flags),
+	TP_ARGS(page, lru),
 
 	TP_STRUCT__entry(
 		__field(struct page *,	page	)
@@ -44,9 +42,9 @@ TRACE_EVENT(mm_lru_insertion,
 
 	TP_fast_assign(
 		__entry->page	= page;
-		__entry->pfn	= pfn;
+		__entry->pfn	= page_to_pfn(page);
 		__entry->lru	= lru;
-		__entry->flags	= flags;
+		__entry->flags	= trace_pagemap_flags(page);
 	),
 
 	/* Flag format is based on page-types.c formatting for pagemap */
@@ -64,9 +62,9 @@ TRACE_EVENT(mm_lru_insertion,
 
 TRACE_EVENT(mm_lru_activate,
 
-	TP_PROTO(struct page *page, unsigned long pfn),
+	TP_PROTO(struct page *page),
 
-	TP_ARGS(page, pfn),
+	TP_ARGS(page),
 
 	TP_STRUCT__entry(
 		__field(struct page *,	page	)
@@ -75,7 +73,7 @@ TRACE_EVENT(mm_lru_activate,
 
 	TP_fast_assign(
 		__entry->page	= page;
-		__entry->pfn	= pfn;
+		__entry->pfn	= page_to_pfn(page);
 	),
 
 	/* Flag format is based on page-types.c formatting for pagemap */
diff --git a/mm/swap.c b/mm/swap.c
index 9e8e347..d10be45 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -501,7 +501,7 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(page, lruvec, lru);
-		trace_mm_lru_activate(page, page_to_pfn(page));
+		trace_mm_lru_activate(page);
 
 		__count_vm_event(PGACTIVATE);
 		update_page_reclaim_stat(lruvec, file, 1);
@@ -996,7 +996,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	SetPageLRU(page);
 	add_page_to_lru_list(page, lruvec, lru);
 	update_page_reclaim_stat(lruvec, file, active);
-	trace_mm_lru_insertion(page, page_to_pfn(page), lru, trace_pagemap_flags(page));
+	trace_mm_lru_insertion(page, lru);
 }
 
 /*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
