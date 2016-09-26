Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCC0D6B0273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 12:20:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so87860328wmf.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 09:20:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j23si9166655wmj.17.2016.09.26.09.20.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 09:20:32 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/4] mm, compaction: ignore fragindex from compaction_zonelist_suitable()
Date: Mon, 26 Sep 2016 18:20:24 +0200
Message-Id: <20160926162025.21555-4-vbabka@suse.cz>
In-Reply-To: <20160926162025.21555-1-vbabka@suse.cz>
References: <20160926162025.21555-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>

The compaction_zonelist_suitable() function tries to determine if compaction
will be able to proceed after sufficient reclaim, i.e. whether there are
enough reclaimable pages to provide enough order-0 freepages for compaction.

This addition of reclaimable pages to the free pages works well for the order-0
watermark check, but in the fragmentation index check we only consider truly
free pages. Thus we can get fragindex value close to 0 which indicates failure
do to lack of memory, and wrongly decide that compaction won't be suitable even
after reclaim.

Instead of trying to somehow adjust fragindex for reclaimable pages, let's just
skip it from compaction_zonelist_suitable().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 86d4d0bbfc7c..5ff7f801c345 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1379,7 +1379,6 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 					int classzone_idx,
 					unsigned long wmark_target)
 {
-	int fragindex;
 	unsigned long watermark;
 
 	if (is_via_compact_memory(order))
@@ -1415,6 +1414,18 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 						ALLOC_CMA, wmark_target))
 		return COMPACT_SKIPPED;
 
+	return COMPACT_CONTINUE;
+}
+
+enum compact_result compaction_suitable(struct zone *zone, int order,
+					unsigned int alloc_flags,
+					int classzone_idx)
+{
+	enum compact_result ret;
+	int fragindex;
+
+	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
+				    zone_page_state(zone, NR_FREE_PAGES));
 	/*
 	 * fragmentation index determines if allocation failures are due to
 	 * low memory or external fragmentation
@@ -1426,21 +1437,12 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 *
 	 * Only compact if a failure would be due to fragmentation.
 	 */
-	fragindex = fragmentation_index(zone, order);
-	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
-		return COMPACT_NOT_SUITABLE_ZONE;
-
-	return COMPACT_CONTINUE;
-}
-
-enum compact_result compaction_suitable(struct zone *zone, int order,
-					unsigned int alloc_flags,
-					int classzone_idx)
-{
-	enum compact_result ret;
+	if (ret == COMPACT_CONTINUE) {
+		fragindex = fragmentation_index(zone, order);
+		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
+			return COMPACT_NOT_SUITABLE_ZONE;
+	}
 
-	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
-				    zone_page_state(zone, NR_FREE_PAGES));
 	trace_mm_compaction_suitable(zone, order, ret);
 	if (ret == COMPACT_NOT_SUITABLE_ZONE)
 		ret = COMPACT_SKIPPED;
@@ -1473,8 +1475,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 		compact_result = __compaction_suitable(zone, order, alloc_flags,
 				ac_classzone_idx(ac), available);
-		if (compact_result != COMPACT_SKIPPED &&
-				compact_result != COMPACT_NOT_SUITABLE_ZONE)
+		if (compact_result != COMPACT_SKIPPED)
 			return true;
 	}
 
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
