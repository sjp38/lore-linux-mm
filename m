Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD5E6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 13:43:08 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/4] tracing, page-allocator: Add trace event for page traffic related to the buddy lists
Date: Tue,  4 Aug 2009 19:12:25 +0100
Message-Id: <1249409546-6343-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The page allocation trace event reports that a page was successfully allocated
but it does not specify where it came from. When analysing performance,
it can be important to distinguish between pages coming from the per-cpu
allocator and pages coming from the buddy lists as the latter requires the
zone lock to the taken and more data structures to be examined.

This patch adds a trace event for __rmqueue reporting when a page is being
allocated from the buddy lists. It distinguishes between being called
to refill the per-cpu lists or whether it is a high-order allocation.
Similarly, this patch adds an event to catch when the PCP lists are being
drained a little and pages are going back to the buddy lists.

This is trickier to draw conclusions from but high activity on those
events could explain why there were a large number of cache misses on a
page-allocator-intensive workload. The coalescing and splitting of buddies
involves a lot of writing of page metadata and cache line bounces not to
mention the acquisition of an interrupt-safe lock necessary to enter this
path.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/trace/events/kmem.h |   54 +++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c             |    2 +
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 0b4002e..3be3df3 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -311,6 +311,60 @@ TRACE_EVENT(mm_page_alloc,
 		show_gfp_flags(__entry->gfp_flags))
 );
 
+TRACE_EVENT(mm_page_alloc_zone_locked,
+
+	TP_PROTO(const void *page, unsigned int order,
+				int migratetype, int percpu_refill),
+
+	TP_ARGS(page, order, migratetype, percpu_refill),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	page		)
+		__field(	unsigned int,	order		)
+		__field(	int,		migratetype	)
+		__field(	int,		percpu_refill	)
+	),
+
+	TP_fast_assign(
+		__entry->page		= page;
+		__entry->order		= order;
+		__entry->migratetype	= migratetype;
+		__entry->percpu_refill	= percpu_refill;
+	),
+
+	TP_printk("page=%p pfn=%lu order=%u migratetype=%d percpu_refill=%d",
+		__entry->page,
+		page_to_pfn((struct page *)__entry->page),
+		__entry->order,
+		__entry->migratetype,
+		__entry->percpu_refill)
+);
+
+TRACE_EVENT(mm_page_pcpu_drain,
+
+	TP_PROTO(const void *page, int order, int migratetype),
+
+	TP_ARGS(page, order, migratetype),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	page		)
+		__field(	int,		order		)
+		__field(	int,		migratetype	)
+	),
+
+	TP_fast_assign(
+		__entry->page		= page;
+		__entry->order		= order;
+		__entry->migratetype	= migratetype;
+	),
+
+	TP_printk("page=%p pfn=%lu order=%d migratetype=%d",
+		__entry->page,
+		page_to_pfn((struct page *)__entry->page),
+		__entry->order,
+		__entry->migratetype)
+);
+
 TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(const void *page,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c2c90cd..35b92a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -535,6 +535,7 @@ static void free_pages_bulk(struct zone *zone, int count,
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_one_page list manipulates */
 		list_del(&page->lru);
+		trace_mm_page_pcpu_drain(page, order, page_private(page));
 		__free_one_page(page, zone, order, page_private(page));
 	}
 	spin_unlock(&zone->lock);
@@ -878,6 +879,7 @@ retry_reserve:
 		}
 	}
 
+	trace_mm_page_alloc_zone_locked(page, order, migratetype, order == 0);
 	return page;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
