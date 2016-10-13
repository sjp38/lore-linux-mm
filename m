Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 012986B0260
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so68682414pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:17 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id e10si13314343pfk.220.2016.10.13.01.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:17 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so4544109pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:17 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 2/5] mm/page_alloc: use smallest fallback page first in movable allocation
Date: Thu, 13 Oct 2016 17:08:19 +0900
Message-Id: <1476346102-26928-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

When we try to find freepage in fallback buddy list, we always serach
the largest one. This would help for fragmentation if we process
unmovable/reclaimable allocation request because it could cause permanent
fragmentation on movable pageblock and spread out such allocations would
cause more fragmentation. But, movable allocation request is
rather different. It would be simply freed or migrated so it doesn't
contribute to fragmentation on the other pageblock. In this case, it would
be better not to break the precious highest order freepage so we need to
search the smallest freepage first.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c4f7d05..70427bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2121,15 +2121,31 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 	int fallback_mt;
 	bool can_steal;
 
-	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
-				--current_order) {
+	if (start_migratetype == MIGRATE_MOVABLE)
+		current_order = order;
+	else
+		current_order = MAX_ORDER - 1;
+
+	/*
+	 * Find the appropriate block of pages in the other list.
+	 * If start_migratetype is MIGRATE_UNMOVABLE/MIGRATE_RECLAIMABLE,
+	 * it would be better to find largest pageblock since it could cause
+	 * fragmentation. However, in case of MIGRATE_MOVABLE, there is no
+	 * risk about fragmentation so it would be better to use smallest one.
+	 */
+	while (current_order >= order && current_order <= MAX_ORDER - 1) {
+
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
 				start_migratetype, false, &can_steal);
-		if (fallback_mt == -1)
+		if (fallback_mt == -1) {
+			if (start_migratetype == MIGRATE_MOVABLE)
+				current_order++;
+			else
+				current_order--;
+
 			continue;
+		}
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
