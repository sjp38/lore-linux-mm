Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32F5B6B006A
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 13:40:21 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/6] tracing, page-allocator: Add trace events for anti-fragmentation falling back to other migratetypes
Date: Fri,  7 Aug 2009 18:40:11 +0100
Message-Id: <1249666815-28784-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1249666815-28784-1-git-send-email-mel@csn.ul.ie>
References: <1249666815-28784-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Fragmentation avoidance depends on being able to use free pages from
lists of the appropriate migrate type. In the event this is not
possible, __rmqueue_fallback() selects a different list and in some
circumstances change the migratetype of the pageblock. Simplistically,
the more times this event occurs, the more likely that fragmentation
will be a problem later for hugepage allocation at least but there are
other considerations such as the order of page being split to satisfy
the allocation.

This patch adds a trace event for __rmqueue_fallback() that reports what
page is being used for the fallback, the orders of relevant pages, the
desired migratetype and the migratetype of the lists being used, whether
the pageblock changed type and whether this event is important with
respect to fragmentation avoidance or not. This information can be used
to help analyse fragmentation avoidance and help decide whether
min_free_kbytes should be increased or not.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/trace/events/kmem.h |   38 ++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c             |    4 ++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 0d358a0..aae16ee 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -299,6 +299,44 @@ TRACE_EVENT(mm_page_alloc,
 		show_gfp_flags(__entry->gfp_flags))
 );
 
+TRACE_EVENT(mm_page_alloc_extfrag,
+
+	TP_PROTO(struct page *page,
+			int alloc_order, int fallback_order,
+			int alloc_migratetype, int fallback_migratetype),
+
+	TP_ARGS(page,
+		alloc_order, fallback_order,
+		alloc_migratetype, fallback_migratetype),
+
+	TP_STRUCT__entry(
+		__field(	struct page *,	page			)
+		__field(	int,		alloc_order		)
+		__field(	int,		fallback_order		)
+		__field(	int,		alloc_migratetype	)
+		__field(	int,		fallback_migratetype	)
+	),
+
+	TP_fast_assign(
+		__entry->page			= page;
+		__entry->alloc_order		= alloc_order;
+		__entry->fallback_order		= fallback_order;
+		__entry->alloc_migratetype	= alloc_migratetype;
+		__entry->fallback_migratetype	= fallback_migratetype;
+	),
+
+	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
+		__entry->page,
+		page_to_pfn(__entry->page),
+		__entry->alloc_order,
+		__entry->fallback_order,
+		pageblock_order,
+		__entry->alloc_migratetype,
+		__entry->fallback_migratetype,
+		__entry->fallback_order < pageblock_order,
+		__entry->alloc_migratetype == __entry->fallback_migratetype)
+);
+
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 440c439..4c20bfa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -839,6 +839,10 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 							start_migratetype);
 
 			expand(zone, page, order, current_order, area, migratetype);
+
+			trace_mm_page_alloc_extfrag(page, order, current_order,
+				start_migratetype, migratetype);
+
 			return page;
 		}
 	}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
