Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6349D600365
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:38 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/8] vmscan: tracing: Update trace event to track if page reclaim IO is for anon or file pages
Date: Mon, 19 Jul 2010 14:11:24 +0100
Message-Id: <1279545090-19169-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is useful to distinguish between IO for anon and file pages. This
patch updates
vmscan-tracing-add-trace-event-when-a-page-is-written.patch to include
that information. The patches can be merged together.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |    8 ++++++--
 mm/vmscan.c                   |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f2da66a..110aea2 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -158,23 +158,27 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 TRACE_EVENT(mm_vmscan_writepage,
 
 	TP_PROTO(struct page *page,
+		int file,
 		int sync_io),
 
-	TP_ARGS(page, sync_io),
+	TP_ARGS(page, file, sync_io),
 
 	TP_STRUCT__entry(
 		__field(struct page *, page)
+		__field(int, file)
 		__field(int, sync_io)
 	),
 
 	TP_fast_assign(
 		__entry->page = page;
+		__entry->file = file;
 		__entry->sync_io = sync_io;
 	),
 
-	TP_printk("page=%p pfn=%lu sync_io=%d",
+	TP_printk("page=%p pfn=%lu file=%d sync_io=%d",
 		__entry->page,
 		page_to_pfn(__entry->page),
+		__entry->file,
 		__entry->sync_io)
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e6ddba9..6587155 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -400,6 +400,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page,
+			page_is_file_cache(page),
 			sync_writeback == PAGEOUT_IO_SYNC);
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
