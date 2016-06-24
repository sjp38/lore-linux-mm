Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3531C828E1
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 06:03:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so13307583wma.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:03:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xz4si6046400wjb.178.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 13/17] mm, compaction: use correct watermark when checking allocation success
Date: Fri, 24 Jun 2016 11:54:33 +0200
Message-Id: <20160624095437.16385-14-vbabka@suse.cz>
In-Reply-To: <20160624095437.16385-1-vbabka@suse.cz>
References: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

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
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 76897850c3c2..371760a85085 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1320,7 +1320,7 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		return COMPACT_CONTINUE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
 							cc->alloc_flags))
@@ -1385,7 +1385,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	if (is_via_compact_memory(order))
 		return COMPACT_CONTINUE;
 
-	watermark = low_wmark_pages(zone);
+	watermark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 	/*
 	 * If watermarks for high-order allocation are already met, there
 	 * should be no need for compaction at all.
@@ -1399,7 +1399,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 * This is because during migration, copies of pages need to be
 	 * allocated and for a short time, the footprint is higher
 	 */
-	watermark += (2UL << order);
+	watermark = low_wmark_pages(zone) + (2UL << order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
 				 alloc_flags, wmark_target))
 		return COMPACT_SKIPPED;
-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
