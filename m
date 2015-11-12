Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E27C26B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:55:07 -0500 (EST)
Received: by pasz6 with SMTP id z6so59428693pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:55:07 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ht11si18316052pac.98.2015.11.11.23.55.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 23:55:07 -0800 (PST)
Received: by padhk6 with SMTP id hk6so7472242pad.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:55:07 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] mm: change mm_vmscan_lru_shrink_inactive() proto types
Date: Thu, 12 Nov 2015 15:54:56 +0800
Message-Id: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org, mingo@redhat.com, yalin.wang2010@gmail.com, namhyung@kernel.org, acme@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@parallels.com, vbabka@suse.cz, mgorman@techsingularity.net, bywxiaobai@163.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Move node_id zone_idx shrink flags into trace function,
so thay we don't need caculate these args if the trace is disabled,
and will make this function have less arguments.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 include/trace/events/vmscan.h | 14 +++++++-------
 mm/vmscan.c                   |  7 ++-----
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index dae7836..f8d6b34 100644
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
+		__entry->nid = zone->zone_pgdat->node_id;
+		__entry->zid = zone_idx(zone);
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
 		__entry->priority = priority;
-		__entry->reclaim_flags = reclaim_flags;
+		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
 	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 83cea53..bd2918e 100644
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
