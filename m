Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD6F060071F
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:34:55 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/14] tracing, vmscan: Add trace event when a page is written
Date: Tue, 29 Jun 2010 12:34:38 +0100
Message-Id: <1277811288-5195-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds a trace event for when page reclaim queues a page for IO and
records whether it is synchronous or asynchronous. Excessive synchronous
IO for a process can result in noticeable stalls during direct reclaim.
Excessive IO from page reclaim may indicate that the system is seriously
under provisioned for the amount of dirty pages that exist.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Larry Woodman <lwoodman@redhat.com>
---
 include/trace/events/vmscan.h |   23 +++++++++++++++++++++++
 mm/vmscan.c                   |    2 ++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a331454..b26daa9 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -154,6 +154,29 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__entry->nr_lumpy_dirty,
 		__entry->nr_lumpy_failed)
 );
+
+TRACE_EVENT(mm_vmscan_writepage,
+
+	TP_PROTO(struct page *page,
+		int sync_io),
+
+	TP_ARGS(page, sync_io),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(int, sync_io)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->sync_io = sync_io;
+	),
+
+	TP_printk("page=%p pfn=%lu sync_io=%d",
+		__entry->page,
+		page_to_pfn(__entry->page),
+		__entry->sync_io)
+);
 		
 #endif /* _TRACE_VMSCAN_H */
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 095c66c..20160c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -399,6 +399,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
 		}
+		trace_mm_vmscan_writepage(page,
+			sync_writeback == PAGEOUT_IO_SYNC);
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
