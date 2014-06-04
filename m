Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id E196B6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 20:29:57 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rl12so6369233iec.7
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 17:29:57 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id o10si1586913icc.40.2014.06.03.17.29.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 17:29:57 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so425138igb.12
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 17:29:57 -0700 (PDT)
Date: Tue, 3 Jun 2014 17:29:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 1/3] mm: rename allocflags_to_migratetype for clarity
In-Reply-To: <537DE799.3040400@suse.cz>
Message-ID: <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <537DB0E5.40602@suse.cz> <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com>
 <537DE799.3040400@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

The page allocator has gfp flags (like __GFP_WAIT) and alloc flags (like 
ALLOC_CPUSET) that have separate semantics.

The function allocflags_to_migratetype() actually takes gfp flags, not alloc 
flags, and returns a migratetype.  Rename it to gfpflags_to_migratetype().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h | 2 +-
 mm/compaction.c     | 4 ++--
 mm/page_alloc.c     | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
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
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1096,7 +1096,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
 		.order = order,
-		.migratetype = allocflags_to_migratetype(gfp_mask),
+		.migratetype = gfpflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.mode = mode,
 	};
@@ -1145,7 +1145,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	count_compact_event(COMPACTSTALL);
 
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 	/* Compact each zone in the list */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2473,7 +2473,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 	return alloc_flags;
@@ -2716,7 +2716,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct zone *preferred_zone;
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	int migratetype = allocflags_to_migratetype(gfp_mask);
+	int migratetype = gfpflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
@@ -2750,7 +2750,7 @@ retry_cpuset:
 	classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 #ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
+	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
 retry:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
