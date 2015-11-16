Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 185786B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 21:37:59 -0500 (EST)
Received: by pacej9 with SMTP id ej9so52145367pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 18:37:58 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id hm2si42772786pac.186.2015.11.15.18.37.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 18:37:58 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so22267420pab.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 18:37:57 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH V2] mm: change mm_vmscan_lru_shrink_inactive() proto types
Date: Mon, 16 Nov 2015 10:37:45 +0800
Message-Id: <1447641465-1582-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org, mingo@redhat.com, yalin.wang2010@gmail.com, acme@redhat.com, namhyung@kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Move node_id zone_idx shrink flags into trace function,
so thay we don't need caculate these args if the trace is disabled,
and will make this function have less arguments.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 include/trace/events/vmscan.h | 14 +++++++-------
 mm/vmscan.c                   |  7 ++-----
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index dae7836..31763dd 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -352,11 +352,11 @@ TRACE_EVENT(mm_vmscan_writepage,
 
 TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
-	TP_PROTO(int nid, int zid,
-			unsigned long nr_scanned, unsigned long nr_reclaimed,
-			int priority, int reclaim_flags),
+	TP_PROTO(struct zone *zone,
+		unsigned long nr_scanned, unsigned long nr_reclaimed,
+		int priority, int file),
 
-	TP_ARGS(nid, zid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
+	TP_ARGS(zone, nr_scanned, nr_reclaimed, priority, file),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
@@ -368,12 +368,12 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 	),
 
 	TP_fast_assign(
-		__entry->nid = nid;
-		__entry->zid = zid;
+		__entry->nid = zone_to_nid(zone);
+		__entry->zid = zone_idx(zone);
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
 		__entry->priority = priority;
-		__entry->reclaim_flags = reclaim_flags;
+		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
 	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 69ca1f5..f8fc8c1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1691,11 +1691,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	    current_may_throttle())
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 
-	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
-		zone_idx(zone),
-		nr_scanned, nr_reclaimed,
-		sc->priority,
-		trace_shrink_flags(file));
+	trace_mm_vmscan_lru_shrink_inactive(zone, nr_scanned, nr_reclaimed,
+			sc->priority, file);
 	return nr_reclaimed;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
