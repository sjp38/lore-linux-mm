Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFCB6B01B9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:02:31 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/6] tracing, vmscan: Add trace events for LRU page isolation
Date: Tue,  8 Jun 2010 10:02:21 +0100
Message-Id: <1275987745-21708-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds an event for when pages are isolated en-masse from the
LRU lists. This event augments the information available on LRU traffic
and can be used to evaluate lumpy reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/trace/events/vmscan.h |   46 +++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   |   14 ++++++++++++
 2 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f76521f..a331454 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -109,6 +109,52 @@ TRACE_EVENT(mm_vmscan_direct_reclaim_end,
 	TP_printk("nr_reclaimed=%lu", __entry->nr_reclaimed)
 );
 
+TRACE_EVENT(mm_vmscan_lru_isolate,
+
+	TP_PROTO(int order,
+		unsigned long nr_requested,
+		unsigned long nr_scanned,
+		unsigned long nr_taken,
+		unsigned long nr_lumpy_taken,
+		unsigned long nr_lumpy_dirty,
+		unsigned long nr_lumpy_failed,
+		int isolate_mode),
+
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
+
+	TP_STRUCT__entry(
+		__field(int, order)
+		__field(unsigned long, nr_requested)
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_taken)
+		__field(unsigned long, nr_lumpy_taken)
+		__field(unsigned long, nr_lumpy_dirty)
+		__field(unsigned long, nr_lumpy_failed)
+		__field(int, isolate_mode)
+	),
+
+	TP_fast_assign(
+		__entry->order = order;
+		__entry->nr_requested = nr_requested;
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_taken = nr_taken;
+		__entry->nr_lumpy_taken = nr_lumpy_taken;
+		__entry->nr_lumpy_dirty = nr_lumpy_dirty;
+		__entry->nr_lumpy_failed = nr_lumpy_failed;
+		__entry->isolate_mode = isolate_mode;
+	),
+
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu",
+		__entry->isolate_mode,
+		__entry->order,
+		__entry->nr_requested,
+		__entry->nr_scanned,
+		__entry->nr_taken,
+		__entry->nr_lumpy_taken,
+		__entry->nr_lumpy_dirty,
+		__entry->nr_lumpy_failed)
+);
+		
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6bfb579..25bf05a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -917,6 +917,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long *scanned, int order, int mode, int file)
 {
 	unsigned long nr_taken = 0;
+	unsigned long nr_lumpy_taken = 0, nr_lumpy_dirty = 0, nr_lumpy_failed = 0;
 	unsigned long scan;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
@@ -994,12 +995,25 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
 				nr_taken++;
+				nr_lumpy_taken++;
+				if (PageDirty(cursor_page))
+					nr_lumpy_dirty++;
 				scan++;
+			} else {
+				if (mode == ISOLATE_BOTH &&
+						page_count(cursor_page))
+					nr_lumpy_failed++;
 			}
 		}
 	}
 
 	*scanned = scan;
+
+	trace_mm_vmscan_lru_isolate(order, 
+			nr_to_scan, scan,
+			nr_taken,
+			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
+			mode);
 	return nr_taken;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
