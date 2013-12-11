Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEF46B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:24:53 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so2656937ead.17
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:24:53 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si18356931eeo.116.2013.12.11.02.24.52
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 02:24:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V2 1/6] mm: compaction: trace compaction begin and end
Date: Wed, 11 Dec 2013 11:24:32 +0100
Message-Id: <1386757477-10333-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
References: <1386757477-10333-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

From: Mel Gorman <mgorman@suse.de>

This patch adds two tracepoints for compaction begin and end of a zone. Using
this it is possible to calculate how much time a workload is spending
within compaction and potentially debug problems related to cached pfns
for scanning. In combination with the direct reclaim and slab trace points
it should be possible to estimate most allocation-related overhead for
a workload.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/compaction.h | 42 +++++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |  4 ++++
 2 files changed, 46 insertions(+)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index fde1b3e..06f544e 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -67,6 +67,48 @@ TRACE_EVENT(mm_compaction_migratepages,
 		__entry->nr_failed)
 );
 
+TRACE_EVENT(mm_compaction_begin,
+	TP_PROTO(unsigned long zone_start, unsigned long migrate_start,
+		unsigned long free_start, unsigned long zone_end),
+
+	TP_ARGS(zone_start, migrate_start, free_start, zone_end),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, zone_start)
+		__field(unsigned long, migrate_start)
+		__field(unsigned long, free_start)
+		__field(unsigned long, zone_end)
+	),
+
+	TP_fast_assign(
+		__entry->zone_start = zone_start;
+		__entry->migrate_start = migrate_start;
+		__entry->free_start = free_start;
+		__entry->zone_end = zone_end;
+	),
+
+	TP_printk("zone_start=%lu migrate_start=%lu free_start=%lu zone_end=%lu",
+		__entry->zone_start,
+		__entry->migrate_start,
+		__entry->free_start,
+		__entry->zone_end)
+);
+
+TRACE_EVENT(mm_compaction_end,
+	TP_PROTO(int status),
+
+	TP_ARGS(status),
+
+	TP_STRUCT__entry(
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->status = status;
+	),
+
+	TP_printk("status=%d", __entry->status)
+);
 
 #endif /* _TRACE_COMPACTION_H */
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 805165b..bb50fd3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -966,6 +966,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
 		__reset_isolation_suitable(zone);
 
+	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn, cc->free_pfn, end_pfn);
+
 	migrate_prep_local();
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
@@ -1011,6 +1013,8 @@ out:
 	cc->nr_freepages -= release_freepages(&cc->freepages);
 	VM_BUG_ON(cc->nr_freepages != 0);
 
+	trace_mm_compaction_end(ret);
+
 	return ret;
 }
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
