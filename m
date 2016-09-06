Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0323C6B025E
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 09:53:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u132so83609898lff.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 06:53:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si23526715wmg.37.2016.09.06.06.53.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 06:53:16 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] Revert "mm, oom: prevent premature OOM killer invocation for high order request"
Date: Tue,  6 Sep 2016 15:52:55 +0200
Message-Id: <20160906135258.18335-2-vbabka@suse.cz>
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>

Commit 6b4e3181d7bd ("mm, oom: prevent premature OOM killer invocation for high
order request") was intended as a quick fix of OOM regressions for 4.8 and
stable 4.7.x kernels. For a better long-term solution, we still want to
consider compaction feedback, which should be possible after some more
improvements in the following patches.

This reverts commit 6b4e3181d7bd5ca5ab6f45929e4a5ffa7ab4ab7f.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 49 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee3997859f14..1df7694f4ec7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3158,6 +3158,54 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	return NULL;
 }
 
+static inline bool
+should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
+		     enum compact_result compact_result,
+		     enum compact_priority *compact_priority,
+		     int compaction_retries)
+{
+	int max_retries = MAX_COMPACT_RETRIES;
+
+	if (!order)
+		return false;
+
+	/*
+	 * compaction considers all the zone as desperately out of memory
+	 * so it doesn't really make much sense to retry except when the
+	 * failure could be caused by insufficient priority
+	 */
+	if (compaction_failed(compact_result)) {
+		if (*compact_priority > MIN_COMPACT_PRIORITY) {
+			(*compact_priority)--;
+			return true;
+		}
+		return false;
+	}
+
+	/*
+	 * make sure the compaction wasn't deferred or didn't bail out early
+	 * due to locks contention before we declare that we should give up.
+	 * But do not retry if the given zonelist is not suitable for
+	 * compaction.
+	 */
+	if (compaction_withdrawn(compact_result))
+		return compaction_zonelist_suitable(ac, order, alloc_flags);
+
+	/*
+	 * !costly requests are much more important than __GFP_REPEAT
+	 * costly ones because they are de facto nofail and invoke OOM
+	 * killer to move on while costly can fail and users are ready
+	 * to cope with that. 1/4 retries is rather arbitrary but we
+	 * would need much more detailed feedback from compaction to
+	 * make a better decision.
+	 */
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		max_retries /= 4;
+	if (compaction_retries <= max_retries)
+		return true;
+
+	return false;
+}
 #else
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
@@ -3168,8 +3216,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	return NULL;
 }
 
-#endif /* CONFIG_COMPACTION */
-
 static inline bool
 should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
 		     enum compact_result compact_result,
@@ -3196,6 +3242,7 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 	}
 	return false;
 }
+#endif /* CONFIG_COMPACTION */
 
 /* Perform direct synchronous page reclaim */
 static int
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
