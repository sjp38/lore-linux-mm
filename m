Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2016B0267
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 10:30:47 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id qs7so36453183wjc.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:47 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id c133si50713959wme.54.2016.12.28.07.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 07:30:45 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id kp2so54789377wjc.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:45 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/7] mm, vmscan: enhance mm_vmscan_lru_shrink_inactive tracepoint
Date: Wed, 28 Dec 2016 16:30:31 +0100
Message-Id: <20161228153032.10821-7-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-1-mhocko@kernel.org>
References: <20161228153032.10821-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mm_vmscan_lru_shrink_inactive will currently report the number of
scanned and reclaimed pages. This doesn't give us an idea how the
reclaim went except for the overall effectiveness though. Export
and show other counters which will tell us why we couldn't reclaim
some pages.
	- nr_dirty, nr_writeback, nr_congested and nr_immediate tells
	  us how many pages are blocked due to IO
	- nr_activate tells us how many pages were moved to the active
	  list
	- nr_ref_keep reports how many pages are kept on the LRU due
	  to references (mostly for the file pages which are about to
	  go for another round through the inactive list)
	- nr_unmap_fail - how many pages failed to unmap

All these are rather low level so they might change in future but the
tracepoint is already implementation specific so no tools should be
depending on its stability.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 29 ++++++++++++++++++++++++++---
 mm/vmscan.c                   | 14 ++++++++++++++
 2 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index cc0b4c456c78..d27606f27af7 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -348,14 +348,27 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
 	TP_PROTO(int nid,
 		unsigned long nr_scanned, unsigned long nr_reclaimed,
+		unsigned long nr_dirty, unsigned long nr_writeback,
+		unsigned long nr_congested, unsigned long nr_immediate,
+		unsigned long nr_activate, unsigned long nr_ref_keep,
+		unsigned long nr_unmap_fail,
 		int priority, int file),
 
-	TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, file),
+	TP_ARGS(nid, nr_scanned, nr_reclaimed, nr_dirty, nr_writeback,
+		nr_congested, nr_immediate, nr_activate, nr_ref_keep,
+		nr_unmap_fail, priority, file),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
+		__field(unsigned long, nr_dirty)
+		__field(unsigned long, nr_writeback)
+		__field(unsigned long, nr_congested)
+		__field(unsigned long, nr_immediate)
+		__field(unsigned long, nr_activate)
+		__field(unsigned long, nr_ref_keep)
+		__field(unsigned long, nr_unmap_fail)
 		__field(int, priority)
 		__field(int, reclaim_flags)
 	),
@@ -364,14 +377,24 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nid = nid;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
+		__entry->nr_dirty = nr_dirty;
+		__entry->nr_writeback = nr_writeback;
+		__entry->nr_congested = nr_congested;
+		__entry->nr_immediate = nr_immediate;
+		__entry->nr_activate = nr_activate;
+		__entry->nr_ref_keep = nr_ref_keep;
+		__entry->nr_unmap_fail = nr_unmap_fail;
 		__entry->priority = priority;
 		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
 		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
-		__entry->priority,
+		__entry->nr_dirty, __entry->nr_writeback,
+		__entry->nr_congested, __entry->nr_immediate,
+		__entry->nr_activate, __entry->nr_ref_keep,
+		__entry->nr_unmap_fail, __entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f6f2d828968c..a701bdd6334a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -908,6 +908,9 @@ struct reclaim_stat {
 	unsigned nr_congested;
 	unsigned nr_writeback;
 	unsigned nr_immediate;
+	unsigned nr_activate;
+	unsigned nr_ref_keep;
+	unsigned nr_unmap_fail;
 };
 
 /*
@@ -929,6 +932,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned nr_reclaimed = 0;
 	unsigned nr_writeback = 0;
 	unsigned nr_immediate = 0;
+	unsigned nr_ref_keep = 0;
+	unsigned nr_unmap_fail = 0;
 
 	cond_resched();
 
@@ -1067,6 +1072,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
+			nr_ref_keep++;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1104,6 +1110,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
+				nr_unmap_fail++;
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
@@ -1276,6 +1283,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		stat->nr_unqueued_dirty = nr_unqueued_dirty;
 		stat->nr_writeback = nr_writeback;
 		stat->nr_immediate = nr_immediate;
+		stat->nr_activate = pgactivate;
+		stat->nr_ref_keep = nr_ref_keep;
+		stat->nr_unmap_fail = nr_unmap_fail;
 	}
 	return nr_reclaimed;
 }
@@ -1825,6 +1835,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
 			nr_scanned, nr_reclaimed,
+			stat.nr_dirty,  stat.nr_writeback,
+			stat.nr_congested, stat.nr_immediate,
+			stat.nr_activate, stat.nr_ref_keep,
+			stat.nr_unmap_fail,
 			sc->priority, file);
 	return nr_reclaimed;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
