Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 5C5236B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 04:37:37 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 mmotm 1/3] mm, page_alloc: add unlikely macro to help compiler optimization
Date: Tue,  6 Aug 2013 17:37:33 +0900
Message-Id: <1375778255-31398-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
in slow path. For helping compiler optimization, add unlikely macro to
ALLOC_NO_WATERMARKS checking.

This patch doesn't have any effect now, because gcc already optimize
this properly. But we cannot assume that gcc always does right and nobody
re-evaluate if gcc do proper optimization with their change, for example,
it is not optimized properly on v3.10. So adding compiler hint here
is reasonable.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5c549c..04bec49 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1901,7 +1901,7 @@ zonelist_scan:
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				continue;
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-		if (alloc_flags & ALLOC_NO_WATERMARKS)
+		if (unlikely(alloc_flags & ALLOC_NO_WATERMARKS))
 			goto try_this_zone;
 		/*
 		 * Distribute pages in proportion to the individual
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
