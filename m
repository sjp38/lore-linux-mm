From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/3] mm, compaction: disginguish contended status in tracepoint
Date: Thu, 27 Aug 2015 17:24:04 +0200
Message-ID: <1440689044-2922-3-git-send-email-vbabka@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>
List-Id: linux-mm.kvack.org

Compaction returns prematurely with COMPACT_PARTIAL when contended or has fatal
signal pending. This is ok for the callers, but might be misleading in the
traces, as the usual reason to return COMPACT_PARTIAL is that we think the
allocation should succeed. This patch distinguishes the premature ending
condition. Further distinguishing the exact reason seems unnecessary for now.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/compaction.h        | 1 +
 include/trace/events/compaction.h | 3 ++-
 mm/compaction.c                   | 4 +++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index aa8f61c..50c9580 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -15,6 +15,7 @@
 /* For more detailed tracepoint output */
 #define COMPACT_NO_SUITABLE_PAGE	5
 #define COMPACT_NOT_SUITABLE_ZONE	6
+#define COMPACT_CONTENDED		7
 /* When adding new state, please change compaction_status_string, too */
 
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
index 7d6ef6e..75a0aca 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1133,7 +1133,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 	unsigned long watermark;
 
 	if (cc->contended || fatal_signal_pending(current))
-		return COMPACT_PARTIAL;
+		return COMPACT_CONTENDED;
 
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn) {
@@ -1204,6 +1204,8 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 	trace_mm_compaction_finished(zone, cc->order, ret);
 	if (ret == COMPACT_NO_SUITABLE_PAGE)
 		ret = COMPACT_CONTINUE;
+	else if (ret == COMPACT_CONTENDED)
+		ret = COMPACT_PARTIAL;
 
 	return ret;
 }
-- 
2.5.0
