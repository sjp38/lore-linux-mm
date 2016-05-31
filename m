Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 083B8828E1
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:15:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e3so43659179wme.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:15:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c18si7139294wmh.93.2016.05.31.06.08.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:37 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 15/18] mm, compaction: use proper alloc_flags in __compaction_suitable()
Date: Tue, 31 May 2016 15:08:15 +0200
Message-Id: <20160531130818.28724-16-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

The __compaction_suitable() function checks the low watermark plus a
compact_gap() gap to decide if there's enough free memory to perform
compaction. This check uses direct compactor's alloc_flags, but that's wrong,
since these flags are not applicable for freepage isolation.

For example, alloc_flags may indicate access to memory reserves, making
compaction proceed, and then fail watermark check during the isolation.

A similar problem exists for ALLOC_CMA, which may be part of alloc_flags, but
not during freepage isolation. In this case however it makes sense to use
ALLOC_CMA both in __compaction_suitable() and __isolate_free_page(), since
there's actually nothing preventing the freepage scanner to isolate from CMA
pageblocks, with the assumption that a page that could be migrated once by
compaction can be migrated also later by CMA allocation. Thus we should count
pages in CMA pageblocks when considering compaction suitability and when
isolating freepages.

To sum up, this patch should remove some false positives from
__compaction_suitable(), and allow compaction to proceed when free pages
required for compaction reside in the CMA pageblocks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 12 ++++++++++--
 mm/page_alloc.c |  2 +-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index bcab680ccb8a..4ffa0870192b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1338,11 +1338,19 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 
 	/*
 	 * Watermarks for order-0 must be met for compaction to be able to
-	 * isolate free pages for migration targets.
+	 * isolate free pages for migration targets. This means that the
+	 * watermark and alloc_flags have to match, or be more pessimistic than
+	 * the check in __isolate_free_page(). We don't use the direct
+	 * compactor's alloc_flags, as they are not relevant for freepage
+	 * isolation. We however do use the direct compactor's classzone_idx to
+	 * skip over zones where lowmem reserves would prevent allocation even
+	 * if compaction succeeds.
+	 * ALLOC_CMA is used, as pages in CMA pageblocks are considered
+	 * suitable migration targets
 	 */
 	watermark = low_wmark_pages(zone) + compact_gap(order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
-				 alloc_flags, wmark_target))
+						ALLOC_CMA, wmark_target))
 		return COMPACT_SKIPPED;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dee486936ccf..09dc9db8a7e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2490,7 +2490,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	if (!is_migrate_isolate(mt)) {
 		/* Obey watermarks as if the page was being allocated */
 		watermark = low_wmark_pages(zone) + (1 << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
 			return 0;
 
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
