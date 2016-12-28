Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 457AA6B0268
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 10:30:48 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so59176589wms.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:48 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id kn2si54418779wjc.158.2016.12.28.07.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 07:30:46 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id hb5so21632353wjc.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:46 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/7] mm, vmscan: add mm_vmscan_inactive_list_is_low tracepoint
Date: Wed, 28 Dec 2016 16:30:32 +0100
Message-Id: <20161228153032.10821-8-mhocko@kernel.org>
In-Reply-To: <20161228153032.10821-1-mhocko@kernel.org>
References: <20161228153032.10821-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Currently we have tracepoints for both active and inactive LRU lists
reclaim but we do not have any which would tell us why we we decided to
age the active list. Without that it is quite hard to diagnose
active/inactive lists balancing. Add mm_vmscan_inactive_list_is_low
tracepoint to tell us this information.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h | 40 ++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   | 23 ++++++++++++++---------
 2 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index d27606f27af7..02c038c570a9 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -15,6 +15,7 @@
 #define RECLAIM_WB_MIXED	0x0010u
 #define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
+#define RECLAIM_WB_LRU		(RECLAIM_WB_ANON|RECLAIM_WB_FILE)
 
 #define show_reclaim_flags(flags)				\
 	(flags) ? __print_flags(flags, "|",			\
@@ -436,6 +437,45 @@ TRACE_EVENT(mm_vmscan_lru_shrink_active,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
+TRACE_EVENT(mm_vmscan_inactive_list_is_low,
+
+	TP_PROTO(int nid, int reclaim_idx,
+		unsigned long total_inactive, unsigned long inactive,
+		unsigned long total_active, unsigned long active,
+		unsigned long ratio, int file),
+
+	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, ratio, file),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, reclaim_idx)
+		__field(unsigned long, total_inactive)
+		__field(unsigned long, inactive)
+		__field(unsigned long, total_active)
+		__field(unsigned long, active)
+		__field(unsigned long, ratio)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->reclaim_idx = reclaim_idx;
+		__entry->total_inactive = total_inactive;
+		__entry->inactive = inactive;
+		__entry->total_active = total_active;
+		__entry->active = active;
+		__entry->ratio = ratio;
+		__entry->reclaim_flags = trace_shrink_flags(file) & RECLAIM_WB_LRU;
+	),
+
+	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
+		__entry->nid,
+		__entry->reclaim_idx,
+		__entry->total_inactive, __entry->inactive,
+		__entry->total_active, __entry->active,
+		__entry->ratio,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a701bdd6334a..8021401213e0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2041,11 +2041,11 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-						struct scan_control *sc)
+						struct scan_control *sc, bool trace)
 {
 	unsigned long inactive_ratio;
-	unsigned long inactive;
-	unsigned long active;
+	unsigned long total_inactive, inactive;
+	unsigned long total_active, active;
 	unsigned long gb;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	int zid;
@@ -2057,8 +2057,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
+	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
+	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
 
 	/*
 	 * For zone-constrained allocations, it is necessary to check if
@@ -2087,6 +2087,11 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	else
 		inactive_ratio = 1;
 
+	if (trace)
+		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
+				sc->reclaim_idx,
+				total_inactive, inactive,
+				total_active, active, inactive_ratio, file);
 	return inactive * inactive_ratio < active;
 }
 
@@ -2094,7 +2099,7 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2225,7 +2230,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, sc) &&
+	if (!inactive_list_is_low(lruvec, true, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2450,7 +2455,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, sc))
+	if (inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -3100,7 +3105,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, sc))
+		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
