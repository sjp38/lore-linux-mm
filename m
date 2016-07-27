Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22DE56B0260
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:52:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so4357686pfx.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:52:31 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id w10si6753148pag.138.2016.07.27.07.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 07:52:30 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i6so1985030pfe.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:52:30 -0700 (PDT)
Date: Wed, 27 Jul 2016 10:51:03 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 2/2] mm: compaction.c: Add/Modify direct compaction
 tracepoints
Message-ID: <7d2c2beef96e76cb01a21eee85ba5611bceb4307.1469629027.git.janani.rvchndrn@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1469629027.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org

Add zone information to an existing tracepoint in compact_zone(). Also,
add a new tracepoint at the end of the compaction code so that latency 
information can be derived.

Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
---
 include/trace/events/compaction.h | 38 +++++++++++++++++++++++++++++++++-----
 mm/compaction.c                   |  6 ++++--
 2 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 36e2d6f..4d86769 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -158,12 +158,15 @@ TRACE_EVENT(mm_compaction_migratepages,
 );
 
 TRACE_EVENT(mm_compaction_begin,
-	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
-		unsigned long free_pfn, unsigned long zone_end, bool sync),
+	TP_PROTO(struct zone *zone, unsigned long zone_start,
+		unsigned long migrate_pfn, unsigned long free_pfn,
+		unsigned long zone_end, bool sync),
 
-	TP_ARGS(zone_start, migrate_pfn, free_pfn, zone_end, sync),
+	TP_ARGS(zone, zone_start, migrate_pfn, free_pfn, zone_end, sync),
 
 	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, zid)
 		__field(unsigned long, zone_start)
 		__field(unsigned long, migrate_pfn)
 		__field(unsigned long, free_pfn)
@@ -172,6 +175,8 @@ TRACE_EVENT(mm_compaction_begin,
 	),
 
 	TP_fast_assign(
+		__entry->nid = zone_to_nid(zone);
+		__entry->zid = zone_idx(zone);
 		__entry->zone_start = zone_start;
 		__entry->migrate_pfn = migrate_pfn;
 		__entry->free_pfn = free_pfn;
@@ -179,7 +184,9 @@ TRACE_EVENT(mm_compaction_begin,
 		__entry->sync = sync;
 	),
 
-	TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s",
+	TP_printk("nid=%d zid=%d zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s",
+		__entry->nid,
+		__entry->zid,
 		__entry->zone_start,
 		__entry->migrate_pfn,
 		__entry->free_pfn,
@@ -221,7 +228,7 @@ TRACE_EVENT(mm_compaction_end,
 		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
 
-TRACE_EVENT(mm_compaction_try_to_compact_pages,
+TRACE_EVENT(mm_compaction_try_to_compact_pages_begin,
 
 	TP_PROTO(
 		int order,
@@ -248,6 +255,27 @@ TRACE_EVENT(mm_compaction_try_to_compact_pages,
 		(int)__entry->mode)
 );
 
+TRACE_EVENT(mm_compaction_try_to_compact_pages_end,
+
+	TP_PROTO(int rc, int contended),
+
+	TP_ARGS(rc, contended),
+
+	TP_STRUCT__entry(
+		__field(int, rc)
+		__field(int, contended)
+	),
+
+	TP_fast_assign(
+		__entry->rc = rc;
+		__entry->contended = contended;
+	),
+
+	TP_printk("rc=%s contended=%d",
+		__print_symbolic(__entry->rc, COMPACTION_STATUS),
+		__entry->contended)
+);
+
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
diff --git a/mm/compaction.c b/mm/compaction.c
index 7bc0477..dddd7c7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1453,7 +1453,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 
 	cc->last_migrated_pfn = 0;
 
-	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
+	trace_mm_compaction_begin(zone, start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync);
 
 	migrate_prep_local();
@@ -1625,7 +1625,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
-	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
+	trace_mm_compaction_try_to_compact_pages_begin(order, gfp_mask, mode);
 
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
@@ -1711,6 +1711,8 @@ break_loop:
 	if (rc > COMPACT_INACTIVE && all_zones_contended)
 		*contended = COMPACT_CONTENDED_LOCK;
 
+	trace_mm_compaction_try_to_compact_pages_end(rc, *contended);
+
 	return rc;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
