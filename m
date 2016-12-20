Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A56606B02F7
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:01:46 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so53345323wjb.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:46 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id qh8si22621949wjb.6.2016.12.20.05.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:01:45 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so27616396wjc.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:44 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] oom, trace: Add oom detection tracepoints
Date: Tue, 20 Dec 2016 14:01:34 +0100
Message-Id: <20161220130135.15719-3-mhocko@kernel.org>
In-Reply-To: <20161220130135.15719-1-mhocko@kernel.org>
References: <20161220130135.15719-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

should_reclaim_retry is the central decision point for declaring the
OOM. It might be really useful to expose data used for this decision
making when debugging an unexpected oom situations.

Say we have an OOM report:
[   52.264001] mem_eater invoked oom-killer: gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=0, order=0, oom_score_adj=0
[   52.267549] CPU: 3 PID: 3148 Comm: mem_eater Tainted: G        W       4.8.0-oomtrace3-00006-gb21338b386d2 #1024

Now we can check the tracepoint data to see how we have ended up in this
situation:
       mem_eater-3148  [003] ....    52.432801: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11134 min_wmark=11084 no_progress_loops=1 wmark_check=1
       mem_eater-3148  [003] ....    52.433269: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11103 min_wmark=11084 no_progress_loops=1 wmark_check=1
       mem_eater-3148  [003] ....    52.433712: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11100 min_wmark=11084 no_progress_loops=2 wmark_check=1
       mem_eater-3148  [003] ....    52.434067: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11097 min_wmark=11084 no_progress_loops=3 wmark_check=1
       mem_eater-3148  [003] ....    52.434414: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11094 min_wmark=11084 no_progress_loops=4 wmark_check=1
       mem_eater-3148  [003] ....    52.434761: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11091 min_wmark=11084 no_progress_loops=5 wmark_check=1
       mem_eater-3148  [003] ....    52.435108: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11087 min_wmark=11084 no_progress_loops=6 wmark_check=1
       mem_eater-3148  [003] ....    52.435478: reclaim_retry_zone: node=0 zone=DMA32 order=0 reclaimable=51 available=11084 min_wmark=11084 no_progress_loops=7 wmark_check=0
       mem_eater-3148  [003] ....    52.435478: reclaim_retry_zone: node=0 zone=DMA order=0 reclaimable=0 available=1126 min_wmark=179 no_progress_loops=7 wmark_check=0

>From the above we can quickly deduce that the reclaim stopped making
any progress (see no_progress_loops increased in each round) and while
there were still some 51 reclaimable pages they couldn't be dropped
for some reason (vmscan trace points would tell us more about that
part). available will represent reclaimable + free_pages scaled down per
no_progress_loops factor. This is essentially an optimistic estimate of
how much memory we would have when reclaiming everything.  This can be
compared to min_wmark to get a rought idea but the wmark_check tells the
result of the watermark check which is more precise (includes lowmem
reserves, considers the order etc.). As we can see no zone is eligible
in the end and that is why we have triggered the oom in this situation.

Please note that higher order requests might fail on the wmark_check even
when there is much more memory available than min_wmark - e.g. when the
memory is fragmented. A follow up tracepoint will help to debug those
situations.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/oom.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            | 10 ++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
index 1e974983757e..9160da7a26a0 100644
--- a/include/trace/events/oom.h
+++ b/include/trace/events/oom.h
@@ -4,6 +4,7 @@
 #if !defined(_TRACE_OOM_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_OOM_H
 #include <linux/tracepoint.h>
+#include <trace/events/mmflags.h>
 
 TRACE_EVENT(oom_score_adj_update,
 
@@ -27,6 +28,47 @@ TRACE_EVENT(oom_score_adj_update,
 		__entry->pid, __entry->comm, __entry->oom_score_adj)
 );
 
+TRACE_EVENT(reclaim_retry_zone,
+
+	TP_PROTO(struct zoneref *zoneref,
+		int order,
+		unsigned long reclaimable,
+		unsigned long available,
+		unsigned long min_wmark,
+		int no_progress_loops,
+		bool wmark_check),
+
+	TP_ARGS(zoneref, order, reclaimable, available, min_wmark, no_progress_loops, wmark_check),
+
+	TP_STRUCT__entry(
+		__field(	int, node)
+		__field(	int, zone_idx)
+		__field(	int,	order)
+		__field(	unsigned long,	reclaimable)
+		__field(	unsigned long,	available)
+		__field(	unsigned long,	min_wmark)
+		__field(	int,	no_progress_loops)
+		__field(	bool,	wmark_check)
+	),
+
+	TP_fast_assign(
+		__entry->node = zone_to_nid(zoneref->zone);
+		__entry->zone_idx = zoneref->zone_idx;
+		__entry->order = order;
+		__entry->reclaimable = reclaimable;
+		__entry->available = available;
+		__entry->min_wmark = min_wmark;
+		__entry->no_progress_loops = no_progress_loops;
+		__entry->wmark_check = wmark_check;
+	),
+
+	TP_printk("node=%d zone=%-8s order=%d reclaimable=%lu available=%lu min_wmark=%lu no_progress_loops=%d wmark_check=%d",
+			__entry->node, __print_symbolic(__entry->zone_idx, ZONE_TYPE),
+			__entry->order,
+			__entry->reclaimable, __entry->available, __entry->min_wmark,
+			__entry->no_progress_loops,
+			__entry->wmark_check)
+);
 #endif
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1c24112308d6..7d11eccd78d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -55,6 +55,7 @@
 #include <linux/kmemleak.h>
 #include <linux/compaction.h>
 #include <trace/events/kmem.h>
+#include <trace/events/oom.h>
 #include <linux/prefetch.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
@@ -3479,6 +3480,8 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 					ac->nodemask) {
 		unsigned long available;
 		unsigned long reclaimable;
+		unsigned long min_wmark = min_wmark_pages(zone);
+		bool wmark;
 
 		available = reclaimable = zone_reclaimable_pages(zone);
 		available -= DIV_ROUND_UP((*no_progress_loops) * available,
@@ -3489,8 +3492,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		 * Would the allocation succeed if we reclaimed the whole
 		 * available?
 		 */
-		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
-				ac_classzone_idx(ac), alloc_flags, available)) {
+		wmark = __zone_watermark_ok(zone, order, min_wmark,
+				ac_classzone_idx(ac), alloc_flags, available);
+		trace_reclaim_retry_zone(z, order, reclaimable,
+				available, min_wmark, *no_progress_loops, wmark);
+		if (wmark) {
 			/*
 			 * If we didn't make any progress and have a lot of
 			 * dirty + writeback pages then we should wait for
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
