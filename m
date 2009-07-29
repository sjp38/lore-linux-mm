Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D95986B00A1
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 17:05:54 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/4] tracing, page-allocator: Add trace events for page allocation and page freeing
Date: Wed, 29 Jul 2009 22:05:48 +0100
Message-Id: <1248901551-7072-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1248901551-7072-1-git-send-email-mel@csn.ul.ie>
References: <1248901551-7072-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds trace events for the allocation and freeing of pages,
including the freeing of pagevecs.  Using the events, it will be known what
struct page and pfns are being allocated and freed and what the call site
was in many cases.

The page alloc tracepoints be used as an indicator as to whether the workload
was heavily dependant on the page allocator or not. You can make a guess based
on vmstat but you can't get a per-process breakdown. Depending on the call
path, the call_site for page allocation may be __get_free_pages() instead
of a useful callsite. Instead of passing down a return address similar to
slab debugging, the user should enable the stacktrace and seg-addr options
to get a proper stack trace.

The pagevec free tracepoint has a different usecase. It can be used to get
a idea of how many pages are being dumped off the LRU and whether it is
kswapd doing the work or a process doing direct reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/kmem.h |   86 +++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c             |    6 ++-
 2 files changed, 91 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 1493c54..57bf13c 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -225,6 +225,92 @@ TRACE_EVENT(kmem_cache_free,
 
 	TP_printk("call_site=%lx ptr=%p", __entry->call_site, __entry->ptr)
 );
+
+TRACE_EVENT(mm_page_free_direct,
+
+	TP_PROTO(unsigned long call_site, const void *page, unsigned int order),
+
+	TP_ARGS(call_site, page, order),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	call_site	)
+		__field(	const void *,	page		)
+		__field(	unsigned int,	order		)
+	),
+
+	TP_fast_assign(
+		__entry->call_site	= call_site;
+		__entry->page		= page;
+		__entry->order		= order;
+	),
+
+	TP_printk("call_site=%lx page=%p pfn=%lu order=%d",
+			__entry->call_site,
+			__entry->page,
+			page_to_pfn((struct page *)__entry->page),
+			__entry->order)
+);
+
+TRACE_EVENT(mm_pagevec_free,
+
+	TP_PROTO(unsigned long call_site, const void *page, int order, int cold),
+
+	TP_ARGS(call_site, page, order, cold),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	call_site	)
+		__field(	const void *,	page		)
+		__field(	int,		order		)
+		__field(	int,		cold		)
+	),
+
+	TP_fast_assign(
+		__entry->call_site	= call_site;
+		__entry->page		= page;
+		__entry->order		= order;
+		__entry->cold		= cold;
+	),
+
+	TP_printk("call_site=%lx page=%p pfn=%lu order=%d cold=%d",
+			__entry->call_site,
+			__entry->page,
+			page_to_pfn((struct page *)__entry->page),
+			__entry->order,
+			__entry->cold)
+);
+
+TRACE_EVENT(mm_page_alloc,
+
+	TP_PROTO(unsigned long call_site, const void *page, unsigned int order,
+			gfp_t gfp_flags, int migratetype),
+
+	TP_ARGS(call_site, page, order, gfp_flags, migratetype),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	call_site	)
+		__field(	const void *,	page		)
+		__field(	unsigned int,	order		)
+		__field(	gfp_t,		gfp_flags	)
+		__field(	int,		migratetype	)
+	),
+
+	TP_fast_assign(
+		__entry->call_site	= call_site;
+		__entry->page		= page;
+		__entry->order		= order;
+		__entry->gfp_flags	= gfp_flags;
+		__entry->migratetype	= migratetype;
+	),
+
+	TP_printk("call_site=%lx page=%p pfn=%lu order=%d migratetype=%d gfp_flags=%s",
+		__entry->call_site,
+		__entry->page,
+		page_to_pfn((struct page *)__entry->page),
+		__entry->order,
+		__entry->migratetype,
+		show_gfp_flags(__entry->gfp_flags))
+);
+
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caa9268..6cd8730 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1894,6 +1894,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
 
+	trace_mm_page_alloc(_RET_IP_, page, order, gfp_mask, migratetype);
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
@@ -1934,12 +1935,15 @@ void __pagevec_free(struct pagevec *pvec)
 {
 	int i = pagevec_count(pvec);
 
-	while (--i >= 0)
+	while (--i >= 0) {
+		trace_mm_pagevec_free(_RET_IP_, pvec->pages[i], 0, pvec->cold);
 		free_hot_cold_page(pvec->pages[i], pvec->cold);
+	}
 }
 
 void __free_pages(struct page *page, unsigned int order)
 {
+	trace_mm_page_free_direct(_RET_IP_, page, order);
 	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_page(page);
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
