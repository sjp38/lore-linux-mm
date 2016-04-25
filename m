Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2846B0260
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 01:21:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so238093075pfy.2
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 22:21:27 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id c64si4518128pfa.69.2016.04.24.22.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 22:21:26 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id y69so42328371pfb.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 22:21:26 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 4/6] mm/cma: remove ALLOC_CMA
Date: Mon, 25 Apr 2016 14:21:08 +0900
Message-Id: <1461561670-28012-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_CMA
and it only serves for GFP_HIGHUSER_MOVABLE. Therefore, we don't need to
consider ALLOC_CMA at all.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/internal.h   |  3 +--
 mm/page_alloc.c | 18 ++----------------
 2 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 64e3131..a25d45b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -478,8 +478,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
+#define ALLOC_FAIR		0x80 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a6a195..69546b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2582,12 +2582,6 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	else
 		min -= min / 4;
 
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
-
 	/*
 	 * Check watermarks for an order-0 allocation request. If these
 	 * are not met, then a high-order request also cannot go ahead
@@ -2617,10 +2611,8 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 		}
 
 #ifdef CONFIG_CMA
-		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		if (!list_empty(&area->free_list[MIGRATE_CMA]))
 			return true;
-		}
 #endif
 	}
 	return false;
@@ -3217,10 +3209,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
+
 	return alloc_flags;
 }
 
@@ -3573,9 +3562,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
