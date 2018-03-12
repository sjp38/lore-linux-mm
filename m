Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE6516B0003
	for <linux-mm@kvack.org>; Sun, 11 Mar 2018 20:00:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id v8so8019007iob.0
        for <linux-mm@kvack.org>; Sun, 11 Mar 2018 17:00:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor1297676ioo.119.2018.03.11.17.00.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Mar 2018 17:00:18 -0700 (PDT)
Date: Sun, 11 Mar 2018 17:00:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, page_alloc: wakeup kcompactd even if kswapd cannot free
 more memory
Message-ID: <alpine.DEB.2.20.1803111659420.209721@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kswapd will not wakeup if per-zone watermarks are not failing or if too
many previous attempts at background reclaim have failed.

This can be true if there is a lot of free memory available.  For high-
order allocations, kswapd is responsible for waking up kcompactd for
background compaction.  If the zone is now below its watermarks or
reclaim has recently failed (lots of free memory, nothing left to
reclaim), kcompactd does not get woken up.

When __GFP_DIRECT_RECLAIM is not allowed, allow kcompactd to still be
woken up even if kswapd will not reclaim.  This allows high-order
allocations, such as thp, to still trigger background compaction even
when the zone has an abundance of free memory.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 .../postprocess/trace-vmscan-postprocess.pl   |  4 +--
 include/linux/mmzone.h                        |  3 +-
 include/trace/events/vmscan.h                 | 17 ++++++----
 mm/page_alloc.c                               | 14 ++++----
 mm/vmscan.c                                   | 32 +++++++++++++------
 5 files changed, 45 insertions(+), 25 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -111,7 +111,7 @@ my $regex_direct_begin_default = 'order=([0-9]*) may_writepage=([0-9]*) gfp_flag
 my $regex_direct_end_default = 'nr_reclaimed=([0-9]*)';
 my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
-my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
+my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*) gfp_flags=([A-Z_|]*)';
 my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) classzone_idx=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_skipped=([0-9]*) nr_taken=([0-9]*) lru=([a-z_]*)';
 my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) nr_dirty=([0-9]*) nr_writeback=([0-9]*) nr_congested=([0-9]*) nr_immediate=([0-9]*) nr_activate=([0-9]*) nr_ref_keep=([0-9]*) nr_unmap_fail=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
@@ -201,7 +201,7 @@ $regex_kswapd_sleep = generate_traceevent_regex(
 $regex_wakeup_kswapd = generate_traceevent_regex(
 			"vmscan/mm_vmscan_wakeup_kswapd",
 			$regex_wakeup_kswapd_default,
-			"nid", "zid", "order");
+			"nid", "zid", "order", "gfp_flags");
 $regex_lru_isolate = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_isolate",
 			$regex_lru_isolate_default,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -775,7 +775,8 @@ static inline bool is_dev_zone(const struct zone *zone)
 #include <linux/memory_hotplug.h>
 
 void build_all_zonelists(pg_data_t *pgdat);
-void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
+void wakeup_kswapd(struct zone *zone, gfp_t gfp_mask, int order,
+		   enum zone_type classzone_idx);
 bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			 int classzone_idx, unsigned int alloc_flags,
 			 long free_pages);
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -78,26 +78,29 @@ TRACE_EVENT(mm_vmscan_kswapd_wake,
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 
-	TP_PROTO(int nid, int zid, int order),
+	TP_PROTO(int nid, int zid, int order, gfp_t gfp_flags),
 
-	TP_ARGS(nid, zid, order),
+	TP_ARGS(nid, zid, order, gfp_flags),
 
 	TP_STRUCT__entry(
-		__field(	int,		nid	)
-		__field(	int,		zid	)
-		__field(	int,		order	)
+		__field(	int,	nid		)
+		__field(	int,	zid		)
+		__field(	int,	order		)
+		__field(	gfp_t,	gfp_flags	)
 	),
 
 	TP_fast_assign(
 		__entry->nid		= nid;
 		__entry->zid		= zid;
 		__entry->order		= order;
+		__entry->gfp_flags	= gfp_flags;
 	),
 
-	TP_printk("nid=%d zid=%d order=%d",
+	TP_printk("nid=%d zid=%d order=%d gfp_flags=%s",
 		__entry->nid,
 		__entry->zid,
-		__entry->order)
+		__entry->order,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3683,16 +3683,18 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
+static void wake_all_kswapds(unsigned int order, gfp_t gfp_mask,
+			     const struct alloc_context *ac)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	pg_data_t *last_pgdat = NULL;
+	enum zone_type high_zoneidx = ac->high_zoneidx;
 
-	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
-					ac->high_zoneidx, ac->nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, high_zoneidx,
+					ac->nodemask) {
 		if (last_pgdat != zone->zone_pgdat)
-			wakeup_kswapd(zone, order, ac->high_zoneidx);
+			wakeup_kswapd(zone, gfp_mask, order, high_zoneidx);
 		last_pgdat = zone->zone_pgdat;
 	}
 }
@@ -3971,7 +3973,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-		wake_all_kswapds(order, ac);
+		wake_all_kswapds(order, gfp_mask, ac);
 
 	/*
 	 * The adjusted alloc_flags might result in immediate success, so try
@@ -4029,7 +4031,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 retry:
 	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-		wake_all_kswapds(order, ac);
+		wake_all_kswapds(order, gfp_mask, ac);
 
 	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
 	if (reserve_flags)
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3546,16 +3546,21 @@ static int kswapd(void *p)
 }
 
 /*
- * A zone is low on free memory, so wake its kswapd task to service it.
+ * A zone is low on free memory or too fragmented for high-order memory.  If
+ * kswapd should reclaim (direct reclaim is deferred), wake it up for the zone's
+ * pgdat.  It will wake up kcompactd after reclaiming memory.  If kswapd reclaim
+ * has failed or is not needed, still wake up kcompactd if only compaction is
+ * needed.
  */
-void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
+void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
+		   enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
 
 	if (!managed_zone(zone))
 		return;
 
-	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
+	if (!cpuset_zone_allowed(zone, gfp_flags))
 		return;
 	pgdat = zone->zone_pgdat;
 	pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat,
@@ -3564,14 +3569,23 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 
-	/* Hopeless node, leave it to direct reclaim */
-	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
-		return;
-
-	if (pgdat_balanced(pgdat, order, classzone_idx))
+	/* Hopeless node, leave it to direct reclaim if possible */
+	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ||
+	    pgdat_balanced(pgdat, order, classzone_idx)) {
+		/*
+		 * There may be plenty of free memory available, but it's too
+		 * fragmented for high-order allocations.  Wake up kcompactd
+		 * and rely on compaction_suitable() to determine if it's
+		 * needed.  If it fails, it will defer subsequent attempts to
+		 * ratelimit its work.
+		 */
+		if (!(gfp_flags & __GFP_DIRECT_RECLAIM))
+			wakeup_kcompactd(pgdat, order, classzone_idx);
 		return;
+	}
 
-	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, classzone_idx, order);
+	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, classzone_idx, order,
+				      gfp_flags);
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
