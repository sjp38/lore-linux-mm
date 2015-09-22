Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD1F36B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 05:32:59 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so14625711wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:32:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ct4si869941wjb.45.2015.09.22.02.32.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 02:32:58 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/3] mm, compaction: disginguish contended status in tracepoints
Date: Tue, 22 Sep 2015 11:32:45 +0200
Message-Id: <1442914365-15949-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1442914365-15949-1-git-send-email-vbabka@suse.cz>
References: <1442914365-15949-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

Compaction returns prematurely with COMPACT_PARTIAL when contended or has fatal
signal pending. This is ok for the callers, but might be misleading in the
traces, as the usual reason to return COMPACT_PARTIAL is that we think the
allocation should succeed. After this patch we distinguish the premature ending
condition in the mm_compaction_finished and mm_compaction_end tracepoints.

The contended status covers the following reasons:
- lock contention or need_resched() detected in async compaction
- fatal signal pending
- too many pages isolated in the zone (only for async compaction)
Further distinguishing the exact reason seems unnecessary for now.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
---
v2: extend to mm_compaction_end (pointed out by Joonsoo)

 include/linux/compaction.h        | 1 +
 include/trace/events/compaction.h | 3 ++-
 mm/compaction.c                   | 9 ++++++---
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index f14ba98..4cd4ddf 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -15,6 +15,7 @@
 /* For more detailed tracepoint output */
 #define COMPACT_NO_SUITABLE_PAGE	5
 #define COMPACT_NOT_SUITABLE_ZONE	6
+#define COMPACT_CONTENDED		7
 /* When adding new states, please adjust include/trace/events/compaction.h */
 
 /* Used to signal whether compaction detected need_sched() or lock contention */
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 8daa8fa..5604994 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -16,7 +16,8 @@
 	EM( COMPACT_PARTIAL,		"partial")		\
 	EM( COMPACT_COMPLETE,		"complete")		\
 	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
-	EMe(COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")
+	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
+	EMe(COMPACT_CONTENDED,		"contended")
 
 #ifdef CONFIG_ZONE_DMA
 #define IFDEF_ZONE_DMA(X) X
diff --git a/mm/compaction.c b/mm/compaction.c
index a5849c4..de3e1e7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1202,7 +1202,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	unsigned long watermark;
 
 	if (cc->contended || fatal_signal_pending(current))
-		return COMPACT_PARTIAL;
+		return COMPACT_CONTENDED;
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (compact_scanners_met(cc)) {
@@ -1393,7 +1393,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
-			ret = COMPACT_PARTIAL;
+			ret = COMPACT_CONTENDED;
 			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
 			goto out;
@@ -1424,7 +1424,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			 * and we want compact_finished() to detect it
 			 */
 			if (err == -ENOMEM && !compact_scanners_met(cc)) {
-				ret = COMPACT_PARTIAL;
+				ret = COMPACT_CONTENDED;
 				goto out;
 			}
 		}
@@ -1477,6 +1477,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
 
+	if (ret == COMPACT_CONTENDED)
+		ret = COMPACT_PARTIAL;
+
 	return ret;
 }
 
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
