Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 427026B025E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:05:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so3880085wme.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 14:05:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u126si759678wmd.6.2016.09.29.14.05.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 14:05:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/4] mm, page_alloc: disallow migratetype fallback in fastpath
Date: Thu, 29 Sep 2016 23:05:48 +0200
Message-Id: <20160929210548.26196-5-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

The previous patch has adjusted async compaction so that it helps against
longterm fragmentation when compacting for a non-MOVABLE high-order allocation.
The goal of this patch is to force such allocations go through compaction
once before being allowed to fallback to a pageblock of different migratetype
(e.g. MOVABLE). In contexts where compaction is not allowed (and for order-0
allocations), this delayed fallback possibility can still help by trying a
different zone where fallback might not be needed and potentially waking up
kswapd earlier.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/internal.h   |  1 +
 mm/page_alloc.c | 14 ++++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 1fee63010dcc..a46eab383e8d 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -466,6 +466,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
+#define ALLOC_FALLBACK		0x100 /* allow fallback of migratetype */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c00beec9336..8a8ef9ebeb4d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2163,7 +2163,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
-				int migratetype)
+				int migratetype, bool allow_fallback)
 {
 	struct page *page;
 
@@ -2172,7 +2172,7 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
-		if (!page)
+		if (!page && allow_fallback)
 			page = __rmqueue_fallback(zone, order, migratetype);
 	}
 
@@ -2193,7 +2193,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		struct page *page = __rmqueue(zone, order, migratetype, true);
 		if (unlikely(page == NULL))
 			break;
 
@@ -2626,7 +2626,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 					trace_mm_page_alloc_zone_locked(page, order, migratetype);
 			}
 			if (!page)
-				page = __rmqueue(zone, order, migratetype);
+				page = __rmqueue(zone, order, migratetype,
+						alloc_flags &
+						(ALLOC_FALLBACK |
+						 ALLOC_NO_WATERMARKS));
 		} while (page && check_new_pages(page, order));
 		spin_unlock(&zone->lock);
 		if (!page)
@@ -3583,6 +3586,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		}
 	}
 
+	/* async direct compaction didn't help, now allow fallback */
+	alloc_flags |= ALLOC_FALLBACK;
+
 retry:
 	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
