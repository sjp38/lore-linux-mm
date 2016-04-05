Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABF16B026C
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 07:26:04 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id 20so17188192wmh.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 04:26:04 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a145si14721895wmd.61.2016.04.05.04.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 04:25:51 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 20so3339019wmh.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 04:25:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 09/11] mm, compaction: Abstract compaction feedback to helpers
Date: Tue,  5 Apr 2016 13:25:31 +0200
Message-Id: <1459855533-4600-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 74 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            | 25 ++++------------
 2 files changed, 80 insertions(+), 19 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a7b9091ff349..512db9c3f0ed 100644
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
@@ -114,6 +178,16 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static inline bool compaction_made_progress(enum compact_result result)
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c37e6d1ad643..c05de84c8157 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3362,25 +3362,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
-	/* Checks for THP-specific high-order allocations */
-	if (is_thp_gfp_mask(gfp_mask)) {
-		/*
-		 * If compaction is deferred for high-order allocations, it is
-		 * because sync compaction recently failed. If this is the case
-		 * and the caller requested a THP allocation, we do not want
-		 * to heavily disrupt the system, so we fail the allocation
-		 * instead of entering direct reclaim.
-		 */
-		if (compact_result == COMPACT_DEFERRED)
-			goto nopage;
-
-		/*
-		 * Compaction is contended so rather back off than cause
-		 * excessive stalls.
-		 */
-		if(compact_result == COMPACT_CONTENDED)
-			goto nopage;
-	}
+	/*
+	 * Checks for THP-specific high-order allocations and back off
+	 * if the the compaction backed off
+	 */
+	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
+		goto nopage;
 
 	/*
 	 * It can become very expensive to allocate transparent hugepages at
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
