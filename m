Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6324E82F66
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:17:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so13296742wmw.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:17:40 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id e81si39059454wme.117.2016.04.15.02.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:17:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 260EA1C1BFC
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:17:39 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 23/27] mm, vmscan: Add classzone information to tracepoints
Date: Fri, 15 Apr 2016 10:13:29 +0100
Message-Id: <1460711613-2761-24-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
References: <1460711613-2761-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is convenient when tracking down why the skip count is high because it'll
show what classzone kswapd woke up at and what zones are being isolated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/trace/events/vmscan.h | 28 ++++++++++++++++++----------
 mm/vmscan.c                   |  4 ++--
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 897f1aa1ee5f..3d242fb8910a 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -55,21 +55,23 @@ TRACE_EVENT(mm_vmscan_kswapd_sleep,
 
 TRACE_EVENT(mm_vmscan_kswapd_wake,
 
-	TP_PROTO(int nid, int order),
+	TP_PROTO(int nid, int zid, int order),
 
-	TP_ARGS(nid, order),
+	TP_ARGS(nid, zid, order),
 
 	TP_STRUCT__entry(
 		__field(	int,	nid	)
+		__field(	int,	zid	)
 		__field(	int,	order	)
 	),
 
 	TP_fast_assign(
 		__entry->nid	= nid;
+		__entry->zid    = zid;
 		__entry->order	= order;
 	),
 
-	TP_printk("nid=%d order=%d", __entry->nid, __entry->order)
+	TP_printk("nid=%d zid=%d order=%d", __entry->nid, __entry->zid, __entry->order)
 );
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
@@ -266,16 +268,18 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
-	TP_PROTO(int order,
+	TP_PROTO(int classzone_idx,
+		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
 
 	TP_STRUCT__entry(
+		__field(int, classzone_idx)
 		__field(int, order)
 		__field(unsigned long, nr_requested)
 		__field(unsigned long, nr_scanned)
@@ -285,6 +289,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 	),
 
 	TP_fast_assign(
+		__entry->classzone_idx = classzone_idx;
 		__entry->order = order;
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
@@ -293,8 +298,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
 		__entry->isolate_mode,
+		__entry->classzone_idx,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
@@ -304,27 +310,29 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 
-	TP_PROTO(int order,
+	TP_PROTO(int classzone_idx,
+		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
 
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 
-	TP_PROTO(int order,
+	TP_PROTO(int classzone_idx,
+		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
 
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dfd8bdfadfe4..e5aa605da6c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1417,7 +1417,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	if (!list_empty(&pages_skipped))
 		list_splice(&pages_skipped, src);
 	*nr_scanned = scan;
-	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
+	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
 	return nr_taken;
 }
@@ -3402,7 +3402,7 @@ static int kswapd(void *p)
 		 * Try reclaim the requested order but if that fails
 		 * then try sleeping on the basis of the order reclaimed.
 		 */
-		trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
+		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx, order);
 		if (balance_pgdat(pgdat, order, classzone_idx) < order)
 			goto kswapd_try_sleep;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
