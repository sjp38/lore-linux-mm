Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018706B0275
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 12:20:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so88964013wmc.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 09:20:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si9150563wmf.80.2016.09.26.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 09:20:32 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/4] mm, compaction: more reliably increase direct compaction priority-fix
Date: Mon, 26 Sep 2016 18:20:22 +0200
Message-Id: <20160926162025.21555-2-vbabka@suse.cz>
In-Reply-To: <20160926162025.21555-1-vbabka@suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>

When increasing the compaction priority, also reset retries. Otherwise we can
consume all retries on the lower priorities. Also pull the retries increment
into should_compact_retry() so it counts only the rounds where we actually
rely on it.

Suggested-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 Please squash into
 mm-compaction-more-reliably-increase-direct-compaction-priority.patch

 mm/page_alloc.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5155485057cb..0fd29731ab35 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3162,7 +3162,7 @@ static inline bool
 should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 		     enum compact_result compact_result,
 		     enum compact_priority *compact_priority,
-		     int compaction_retries)
+		     int *compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
 	int min_priority;
@@ -3170,6 +3170,9 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (!order)
 		return false;
 
+	if (compaction_made_progress(compact_result))
+		(*compaction_retries)++;
+
 	/*
 	 * compaction considers all the zone as desperately out of memory
 	 * so it doesn't really make much sense to retry except when the
@@ -3197,18 +3200,19 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 */
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		max_retries /= 4;
-	if (compaction_retries <= max_retries)
+	if (*compaction_retries <= max_retries)
 		return true;
 
 	/*
-	 * Make sure there is at least one attempt at the highest priority
-	 * if we exhausted all retries at the lower priorities
+	 * Make sure there are attempts at the highest priority if we exhausted
+	 * all retries or failed at the lower priorities.
 	 */
 check_priority:
 	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
 			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
 	if (*compact_priority > min_priority) {
 		(*compact_priority)--;
+		*compaction_retries = 0;
 		return true;
 	}
 	return false;
@@ -3227,7 +3231,7 @@ static inline bool
 should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
 		     enum compact_result compact_result,
 		     enum compact_priority *compact_priority,
-		     int compaction_retries)
+		     int *compaction_retries)
 {
 	struct zone *zone;
 	struct zoneref *z;
@@ -3635,9 +3639,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 
-	if (order && compaction_made_progress(compact_result))
-		compaction_retries++;
-
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		goto nopage;
@@ -3672,7 +3673,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (did_some_progress > 0 &&
 			should_compact_retry(ac, order, alloc_flags,
 				compact_result, &compact_priority,
-				compaction_retries))
+				&compaction_retries))
 		goto retry;
 
 	/* Reclaim has failed us, start killing things */
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
