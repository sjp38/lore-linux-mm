Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85C5D828E8
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 15:47:55 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xm6so36748790pab.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:55 -0700 (PDT)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com. [209.85.220.42])
        by mx.google.com with ESMTPS id z73si1184190pfa.225.2016.04.20.12.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 12:47:54 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id er2so20774061pad.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/14] mm, compaction: Abstract compaction feedback to helpers
Date: Wed, 20 Apr 2016 15:47:21 -0400
Message-Id: <1461181647-8039-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Compaction can provide a wild variation of feedback to the caller. Many
of them are implementation specific and the caller of the compaction
(especially the page allocator) shouldn't be bound to specifics of the
current implementation.

This patch abstracts the feedback into three basic types:
	- compaction_made_progress - compaction was active and made some
	  progress.
	- compaction_failed - compaction failed and further attempts to
	  invoke it would most probably fail and therefore it is not
	  worth retrying
	- compaction_withdrawn - compaction wasn't invoked for an
          implementation specific reasons. In the current implementation
          it means that the compaction was deferred, contended or the
          page scanners met too early without any progress. Retrying is
          still worthwhile.

[vbabka@suse.cz: do not change thp back off behavior]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 79 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a7b9091ff349..a002ca55c513 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -78,6 +78,70 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
+/* Compaction has made some progress and retrying makes sense */
+static inline bool compaction_made_progress(enum compact_result result)
+{
+	/*
+	 * Even though this might sound confusing this in fact tells us
+	 * that the compaction successfully isolated and migrated some
+	 * pageblocks.
+	 */
+	if (result == COMPACT_PARTIAL)
+		return true;
+
+	return false;
+}
+
+/* Compaction has failed and it doesn't make much sense to keep retrying. */
+static inline bool compaction_failed(enum compact_result result)
+{
+	/* All zones where scanned completely and still not result. */
+	if (result == COMPACT_COMPLETE)
+		return true;
+
+	return false;
+}
+
+/*
+ * Compaction  has backed off for some reason. It might be throttling or
+ * lock contention. Retrying is still worthwhile.
+ */
+static inline bool compaction_withdrawn(enum compact_result result)
+{
+	/*
+	 * Compaction backed off due to watermark checks for order-0
+	 * so the regular reclaim has to try harder and reclaim something.
+	 */
+	if (result == COMPACT_SKIPPED)
+		return true;
+
+	/*
+	 * If compaction is deferred for high-order allocations, it is
+	 * because sync compaction recently failed. If this is the case
+	 * and the caller requested a THP allocation, we do not want
+	 * to heavily disrupt the system, so we fail the allocation
+	 * instead of entering direct reclaim.
+	 */
+	if (result == COMPACT_DEFERRED)
+		return true;
+
+	/*
+	 * If compaction in async mode encounters contention or blocks higher
+	 * priority task we back off early rather than cause stalls.
+	 */
+	if (result == COMPACT_CONTENDED)
+		return true;
+
+	/*
+	 * Page scanners have met but we haven't scanned full zones so this
+	 * is a back off in fact.
+	 */
+	if (result == COMPACT_PARTIAL_SKIPPED)
+		return true;
+
+	return false;
+}
+
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
@@ -114,6 +178,21 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static inline bool compaction_made_progress(enum compact_result result)
+{
+	return false;
+}
+
+static inline bool compaction_failed(enum compact_result result)
+{
+	return false;
+}
+
+static inline bool compaction_withdrawn(enum compact_result result)
+{
+	return true;
+}
+
 static inline int kcompactd_run(int nid)
 {
 	return 0;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
