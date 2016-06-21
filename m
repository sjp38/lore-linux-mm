Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCCB3828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:20:13 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so14976450lbc.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:20:13 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id s4si26747140wjy.4.2016.06.21.07.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:20:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 3364F1C19C6
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 15:20:12 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 23/27] mm, vmscan: Add classzone information to tracepoints
Date: Tue, 21 Jun 2016 15:16:02 +0100
Message-Id: <1466518566-30034-24-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is convenient when tracking down why the skip count is high because it'll
show what classzone kswapd woke up at and what zones are being isolated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/vmscan.h | 51 ++++++++++++++++++++++++++-----------------
 mm/vmscan.c                   | 14 +++++++-----
 2 files changed, 40 insertions(+), 25 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 897f1aa1ee5f..c88fd0934e7e 100644
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
@@ -98,47 +100,50 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
 
-	TP_ARGS(order, may_writepage, gfp_flags),
+	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx),
 
 	TP_STRUCT__entry(
 		__field(	int,	order		)
 		__field(	int,	may_writepage	)
 		__field(	gfp_t,	gfp_flags	)
+		__field(	int,	classzone_idx	)
 	),
 
 	TP_fast_assign(
 		__entry->order		= order;
 		__entry->may_writepage	= may_writepage;
 		__entry->gfp_flags	= gfp_flags;
+		__entry->classzone_idx	= classzone_idx;
 	),
 
-	TP_printk("order=%d may_writepage=%d gfp_flags=%s",
+	TP_printk("order=%d may_writepage=%d gfp_flags=%s classzone_idx=%d",
 		__entry->order,
 		__entry->may_writepage,
-		show_gfp_flags(__entry->gfp_flags))
+		show_gfp_flags(__entry->gfp_flags),
+		__entry->classzone_idx)
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
 
-	TP_ARGS(order, may_writepage, gfp_flags)
+	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
 
-	TP_ARGS(order, may_writepage, gfp_flags)
+	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
 
-	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags, int classzone_idx),
 
-	TP_ARGS(order, may_writepage, gfp_flags)
+	TP_ARGS(order, may_writepage, gfp_flags, classzone_idx)
 );
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_end_template,
@@ -266,16 +271,18 @@ TRACE_EVENT(mm_shrink_slab_end,
 
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
@@ -285,6 +292,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 	),
 
 	TP_fast_assign(
+		__entry->classzone_idx = classzone_idx;
 		__entry->order = order;
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
@@ -293,8 +301,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
 		__entry->isolate_mode,
+		__entry->classzone_idx,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
@@ -304,27 +313,29 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
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
index 4fa1fee5e486..16ad7b4be1e9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1433,7 +1433,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	if (!list_empty(&pages_skipped))
 		list_splice(&pages_skipped, src);
 	*nr_scanned = scan;
-	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
+	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
 	for (scan = 0; scan < MAX_NR_ZONES; scan++) {
 		nr_pages = nr_zone_taken[scan];
@@ -2893,7 +2893,8 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
-				gfp_mask);
+				gfp_mask,
+				sc.reclaim_idx);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -2924,7 +2925,8 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
 						      sc.may_writepage,
-						      sc.gfp_mask);
+						      sc.gfp_mask,
+						      sc.reclaim_idx);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -2972,7 +2974,8 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
-					    sc.gfp_mask);
+					    sc.gfp_mask,
+					    sc.reclaim_idx);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -3407,7 +3410,8 @@ static int kswapd(void *p)
 		 * but kcompactd is woken to compact for the original
 		 * request (alloc_order).
 		 */
-		trace_mm_vmscan_kswapd_wake(pgdat->node_id, alloc_order);
+		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
+						alloc_order);
 		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
