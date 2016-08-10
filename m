Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5D97828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:13:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so52624951wme.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:13:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u62si7104620wmd.129.2016.08.10.02.12.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 10/11] mm, compaction: require only min watermarks for non-costly orders
Date: Wed, 10 Aug 2016 11:12:25 +0200
Message-Id: <20160810091226.6709-11-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The __compaction_suitable() function checks the low watermark plus a
compact_gap() gap to decide if there's enough free memory to perform
compaction. Then __isolate_free_page uses low watermark check to decide if
particular free page can be isolated. In the latter case, using low watermark
is needlessly pessimistic, as the free page isolations are only temporary. For
__compaction_suitable() the higher watermark makes sense for high-order
allocations where more freepages increase the chance of success, and we can
typically fail with some order-0 fallback when the system is struggling to
reach that watermark. But for low-order allocation, forming the page should not
be that hard. So using low watermark here might just prevent compaction from
even trying, and eventually lead to OOM killer even if we are above min
watermarks.

So after this patch, we use min watermark for non-costly orders in
__compaction_suitable(), and for all orders in __isolate_free_page().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/compaction.c | 6 +++++-
 mm/page_alloc.c | 2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 80eaf9fff114..0bba270f97ad 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1399,10 +1399,14 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 * isolation. We however do use the direct compactor's classzone_idx to
 	 * skip over zones where lowmem reserves would prevent allocation even
 	 * if compaction succeeds.
+	 * For costly orders, we require low watermark instead of min for
+	 * compaction to proceed to increase its chances.
 	 * ALLOC_CMA is used, as pages in CMA pageblocks are considered
 	 * suitable migration targets
 	 */
-	watermark = low_wmark_pages(zone) + compact_gap(order);
+	watermark = (order > PAGE_ALLOC_COSTLY_ORDER) ?
+				low_wmark_pages(zone) : min_wmark_pages(zone);
+	watermark += compact_gap(order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
 						ALLOC_CMA, wmark_target))
 		return COMPACT_SKIPPED;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 621e4211ce16..a5c0f914ec00 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2492,7 +2492,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	if (!is_migrate_isolate(mt)) {
 		/* Obey watermarks as if the page was being allocated */
-		watermark = low_wmark_pages(zone) + (1 << order);
+		watermark = min_wmark_pages(zone) + (1UL << order);
 		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
 			return 0;
 
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
