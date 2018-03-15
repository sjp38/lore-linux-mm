Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B65B26B000C
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:45:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id h61-v6so3519371pld.3
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:45:54 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0124.outbound.protection.outlook.com. [104.47.1.124])
        by mx.google.com with ESMTPS id y25si3982197pfe.206.2018.03.15.09.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 09:45:53 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/6] mm/vmscan: replace mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint
Date: Thu, 15 Mar 2018 19:45:50 +0300
Message-Id: <20180315164553.17856-3-aryabinin@virtuozzo.com>
In-Reply-To: <20180315164553.17856-1-aryabinin@virtuozzo.com>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

With upcoming changes keeping the mm_vmscan_lru_shrink_inactive tracepoint
intact would require some additional code churn. In particular
'struct recalim_stat' will gain more wide usage, but we don't need
'nr_activate', 'nr_ref_keep', 'nr_unmap_fail' counters anywhere besides
tracepoint.

Since mm_vmscan_lru_shrink_inactive tracepoint mostly provide
information collected by shrink_page_list(), we can just replace it
by tracepoint in shrink_page_list(). We don't have 'nr_scanned'
and 'file' arguments there, but user could obtain this information
from mm_vmscan_lru_isolate tracepoint.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/trace/events/vmscan.h | 36 +++++++++++++++---------------------
 mm/vmscan.c                   | 18 +++++-------------
 2 files changed, 20 insertions(+), 34 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 6570c5b45ba1..8743a8113b42 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -342,23 +342,21 @@ TRACE_EVENT(mm_vmscan_writepage,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
-TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
+TRACE_EVENT(mm_vmscan_shrink_page_list,
 
 	TP_PROTO(int nid,
-		unsigned long nr_scanned, unsigned long nr_reclaimed,
-		unsigned long nr_dirty, unsigned long nr_writeback,
-		unsigned long nr_congested, unsigned long nr_immediate,
-		unsigned long nr_activate, unsigned long nr_ref_keep,
-		unsigned long nr_unmap_fail,
-		int priority, int file),
-
-	TP_ARGS(nid, nr_scanned, nr_reclaimed, nr_dirty, nr_writeback,
+		unsigned long nr_reclaimed, unsigned long nr_dirty,
+		unsigned long nr_writeback, unsigned long nr_congested,
+		unsigned long nr_immediate, unsigned long nr_activate,
+		unsigned long nr_ref_keep, unsigned long nr_unmap_fail,
+		int priority),
+
+	TP_ARGS(nid, nr_reclaimed, nr_dirty, nr_writeback,
 		nr_congested, nr_immediate, nr_activate, nr_ref_keep,
-		nr_unmap_fail, priority, file),
+		nr_unmap_fail, priority),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
 		__field(unsigned long, nr_dirty)
 		__field(unsigned long, nr_writeback)
@@ -368,12 +366,10 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__field(unsigned long, nr_ref_keep)
 		__field(unsigned long, nr_unmap_fail)
 		__field(int, priority)
-		__field(int, reclaim_flags)
 	),
 
 	TP_fast_assign(
 		__entry->nid = nid;
-		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
 		__entry->nr_dirty = nr_dirty;
 		__entry->nr_writeback = nr_writeback;
@@ -383,17 +379,15 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nr_ref_keep = nr_ref_keep;
 		__entry->nr_unmap_fail = nr_unmap_fail;
 		__entry->priority = priority;
-		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
+	TP_printk("nid=%d nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d",
 		__entry->nid,
-		__entry->nr_scanned, __entry->nr_reclaimed,
-		__entry->nr_dirty, __entry->nr_writeback,
-		__entry->nr_congested, __entry->nr_immediate,
-		__entry->nr_activate, __entry->nr_ref_keep,
-		__entry->nr_unmap_fail, __entry->priority,
-		show_reclaim_flags(__entry->reclaim_flags))
+		__entry->nr_reclaimed, __entry->nr_dirty,
+		__entry->nr_writeback, __entry->nr_congested,
+		__entry->nr_immediate, __entry->nr_activate,
+		__entry->nr_ref_keep, __entry->nr_unmap_fail,
+		__entry->priority)
 );
 
 TRACE_EVENT(mm_vmscan_lru_shrink_active,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d74b12099bd..0d5ab312a7f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -863,9 +863,6 @@ struct reclaim_stat {
 	unsigned nr_congested;
 	unsigned nr_writeback;
 	unsigned nr_immediate;
-	unsigned nr_activate;
-	unsigned nr_ref_keep;
-	unsigned nr_unmap_fail;
 };
 
 /*
@@ -1271,15 +1268,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 
+	trace_mm_vmscan_shrink_page_list(pgdat->node_id,
+			nr_reclaimed, nr_dirty, nr_writeback, nr_congested,
+			nr_immediate, pgactivate, nr_ref_keep, nr_unmap_fail,
+			sc->priority);
+
 	if (stat) {
 		stat->nr_dirty = nr_dirty;
 		stat->nr_congested = nr_congested;
 		stat->nr_unqueued_dirty = nr_unqueued_dirty;
 		stat->nr_writeback = nr_writeback;
 		stat->nr_immediate = nr_immediate;
-		stat->nr_activate = pgactivate;
-		stat->nr_ref_keep = nr_ref_keep;
-		stat->nr_unmap_fail = nr_unmap_fail;
 	}
 	return nr_reclaimed;
 }
@@ -1820,13 +1819,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	    current_may_throttle())
 		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
 
-	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
-			nr_scanned, nr_reclaimed,
-			stat.nr_dirty,  stat.nr_writeback,
-			stat.nr_congested, stat.nr_immediate,
-			stat.nr_activate, stat.nr_ref_keep,
-			stat.nr_unmap_fail,
-			sc->priority, file);
 	return nr_reclaimed;
 }
 
-- 
2.16.1
