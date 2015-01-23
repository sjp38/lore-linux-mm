Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1886B006C
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:15:23 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id a1so7446858wgh.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 05:15:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cr7si3054221wjc.35.2015.01.23.05.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 05:15:20 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 3/3] mm: more aggressive page stealing for UNMOVABLE allocations
Date: Fri, 23 Jan 2015 14:15:06 +0100
Message-Id: <1422018906-8880-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1422018906-8880-1-git-send-email-vbabka@suse.cz>
References: <1422018906-8880-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>

When allocation falls back to stealing free pages of another migratetype,
it can decide to steal extra pages, or even the whole pageblock in order to
reduce fragmentation, which could happen if further allocation fallbacks
pick a different pageblock. In try_to_steal_freepages(), one of the situations
where extra pages are stolen happens when we are trying to allocate a
MIGRATE_RECLAIMABLE page.

However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
spreading such allocation over multiple fallback pageblocks is arguably even
worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
should minimize the number of such fallbacks, and thus steal as much as is
possible from each fallback pageblock.

Note that in theory this might put more pressure on movable pageblocks and
cause movable allocations to steal back from unmovable pageblocks. However,
movable allocations are not as aggressive with stealing, and do not cause
permanent fragmentation, so the tradeoff is reasonable, and evaluation seems
to support the change.

This patch thus adds a check for MIGRATE_UNMOVABLE to the decision to steal
extra free pages. When evaluating with stress-highalloc from mmtests, this has
reduced the number of MIGRATE_UNMOVABLE fallbacks to roughly 1/6. The number
of these fallbacks stealing from MIGRATE_MOVABLE block is reduced to 1/3.
There was no observation of growing number of unmovable pageblocks over time,
and also not of increased movable allocation fallbacks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 87ebc95..dd1ea6f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1130,10 +1130,19 @@ static void change_pageblock_range(struct page *pageblock_page,
 }
 
 /*
- * If breaking a large block of pages, move all free pages to the preferred
- * allocation list. If falling back for a reclaimable kernel allocation, be
- * more aggressive about taking ownership of free pages. If we claim more than
- * half of the pageblock, change pageblock's migratetype as well.
+ * When we are falling back to another migratetype during allocation, try to
+ * steal extra free pages from the same pageblocks to satisfy further
+ * allocations, instead of polluting multiple pageblocks.
+ *
+ * If we are stealing a relatively large buddy page, it is likely there will
+ * be more free pages in the pageblock, so try to steal them all. For
+ * reclaimable and unmovable allocations, we steal regardless of page size,
+ * as fragmentation caused by those allocations polluting movable pageblocks
+ * is worse than movable allocations stealing from unmovable and reclaimable
+ * pageblocks.
+ *
+ * If we claim more than half of the pageblock, change pageblock's migratetype
+ * as well.
  */
 static void try_to_steal_freepages(struct zone *zone, struct page *page,
 				  int start_type, int fallback_type)
@@ -1148,6 +1157,7 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
 
 	if (current_order >= pageblock_order / 2 ||
 	    start_type == MIGRATE_RECLAIMABLE ||
+	    start_type == MIGRATE_UNMOVABLE ||
 	    page_group_by_mobility_disabled) {
 		int pages;
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
