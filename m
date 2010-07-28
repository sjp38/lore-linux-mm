Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C655F6B02A9
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:27:28 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/9] vmscan: tracing: Update trace event to track if page reclaim IO is for anon or file pages
Date: Wed, 28 Jul 2010 11:27:16 +0100
Message-Id: <1280312843-11789-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is useful to distinguish between IO for anon and file pages. This
patch updates
vmscan-tracing-add-trace-event-when-a-page-is-written.patch to include
that information. The patches can be merged together.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |   30 ++++++++++++++++++++++++------
 mm/vmscan.c                   |    2 +-
 2 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f2da66a..69789dc 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -8,6 +8,24 @@
 #include <linux/tracepoint.h>
 #include "gfpflags.h"
 
+#define RECLAIM_WB_ANON		0x0001u
+#define RECLAIM_WB_FILE		0x0002u
+#define RECLAIM_WB_SYNC		0x0004u
+#define RECLAIM_WB_ASYNC	0x0008u
+
+#define show_reclaim_flags(flags)				\
+	(flags) ? __print_flags(flags, "|",			\
+		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
+		{RECLAIM_WB_FILE,	"RECLAIM_WB_FILE"},	\
+		{RECLAIM_WB_SYNC,	"RECLAIM_WB_SYNC"},	\
+		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
+		) : "RECLAIM_WB_NONE"
+
+#define trace_reclaim_flags(page, sync) ( \
+	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
+	)
+
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
 
 	TP_PROTO(int nid),
@@ -158,24 +176,24 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 TRACE_EVENT(mm_vmscan_writepage,
 
 	TP_PROTO(struct page *page,
-		int sync_io),
+		int reclaim_flags),
 
-	TP_ARGS(page, sync_io),
+	TP_ARGS(page, reclaim_flags),
 
 	TP_STRUCT__entry(
 		__field(struct page *, page)
-		__field(int, sync_io)
+		__field(int, reclaim_flags)
 	),
 
 	TP_fast_assign(
 		__entry->page = page;
-		__entry->sync_io = sync_io;
+		__entry->reclaim_flags = reclaim_flags;
 	),
 
-	TP_printk("page=%p pfn=%lu sync_io=%d",
+	TP_printk("page=%p pfn=%lu flags=%s",
 		__entry->page,
 		page_to_pfn(__entry->page),
-		__entry->sync_io)
+		show_reclaim_flags(__entry->reclaim_flags))
 );
 
 #endif /* _TRACE_VMSCAN_H */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 63447ff..d83812a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -402,7 +402,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page,
-			sync_writeback == PAGEOUT_IO_SYNC);
+			trace_reclaim_flags(page, sync_writeback));
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
