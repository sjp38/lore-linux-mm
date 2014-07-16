Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id BB5CE6B009E
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:06 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id w61so962190wes.23
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yu4si24040056wjc.111.2014.07.16.06.48.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:48:59 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 12/15] mm: rename allocflags_to_migratetype for clarity
Date: Wed, 16 Jul 2014 15:48:20 +0200
Message-Id: <1405518503-27687-13-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

From: David Rientjes <rientjes@google.com>

The page allocator has gfp flags (like __GFP_WAIT) and alloc flags (like
ALLOC_CPUSET) that have separate semantics.

The function allocflags_to_migratetype() actually takes gfp flags, not alloc
flags, and returns a migratetype.  Rename it to gfpflags_to_migratetype().

Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/gfp.h | 2 +-
 mm/compaction.c     | 4 ++--
 mm/page_alloc.c     | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5e7219d..41b30fd 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -156,7 +156,7 @@ struct vm_area_struct;
 #define GFP_DMA32	__GFP_DMA32
 
 /* Convert GFP flags to their corresponding migrate type */
-static inline int allocflags_to_migratetype(gfp_t gfp_flags)
+static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 {
 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 3cfc3a9..523c7bd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1238,7 +1238,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
 		.order = order,
-		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.migratetype = gfpflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.mode = mode,
 	};
@@ -1290,7 +1290,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		return rc;
 
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 	/* Compact each zone in the list */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fb2988d..6f1c6e6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2496,7 +2496,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 	return alloc_flags;
@@ -2760,7 +2760,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zone *preferred_zone;
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	int migratetype = allocflags_to_migratetype(gfp_mask);
+	int migratetype = gfpflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
@@ -2794,7 +2794,7 @@ retry_cpuset:
 	classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 retry:
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
