Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10AAB6B025F
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:16:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so43793234wmf.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:16:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si50583486wjj.94.2016.05.31.06.08.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:37 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 13/18] mm, compaction: use correct watermark when checking allocation success
Date: Tue, 31 May 2016 15:08:13 +0200
Message-Id: <20160531130818.28724-14-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

The __compact_finished() function uses low watermark in a check that has to
pass if the direct compaction is to finish and allocation should succeed. This
is too pessimistic, as the allocation will typically use min watermark. It may
happen that during compaction, we drop below the low watermark (due to parallel
activity), but still form the target high-order page. By checking against low
watermark, we might needlessly continue compaction.

Similarly, __compaction_suitable() uses low watermark in a check whether
allocation can succeed without compaction. Again, this is unnecessarily
pessimistic.

After this patch, these check will use direct compactor's alloc_flags to
determine the watermark, which is effectively the min watermark.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a399e7ca4630..4b21a26694a2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1262,7 +1262,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		return COMPACT_CONTINUE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
 							cc->alloc_flags))
@@ -1327,7 +1327,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	if (is_via_compact_memory(order))
 		return COMPACT_CONTINUE;
 
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 	/*
 	 * If watermarks for high-order allocation are already met, there
 	 * should be no need for compaction at all.
@@ -1341,7 +1341,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 * This is because during migration, copies of pages need to be
 	 * allocated and for a short time, the footprint is higher
 	 */
-	watermark += (2UL << order);
+	watermark = low_wmark_pages(zone) + (2UL << order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
 				 alloc_flags, wmark_target))
 		return COMPACT_SKIPPED;
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
