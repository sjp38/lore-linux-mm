Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 21E29280028
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:24:11 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so6700693pdj.5
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:24:10 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id nc10si8550455pbc.138.2014.10.31.00.24.08
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 00:24:09 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v5 2/4] mm/page_alloc: add freepage on isolate pageblock to correct buddy list
Date: Fri, 31 Oct 2014 16:25:28 +0900
Message-Id: <1414740330-4086-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414740330-4086-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

In free_pcppages_bulk(), we use cached migratetype of freepage
to determine type of buddy list where freepage will be added.
This information is stored when freepage is added to pcp list, so
if isolation of pageblock of this freepage begins after storing,
this cached information could be stale. In other words, it has
original migratetype rather than MIGRATE_ISOLATE.

There are two problems caused by this stale information. One is that
we can't keep these freepages from being allocated. Although this
pageblock is isolated, freepage will be added to normal buddy list
so that it could be allocated without any restriction. And the other
problem is incorrect freepage accounting. Freepages on isolate pageblock
should not be counted for number of freepage.

Following is the code snippet in free_pcppages_bulk().

/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
__free_one_page(page, page_to_pfn(page), zone, 0, mt);
trace_mm_page_pcpu_drain(page, 0, mt);
if (likely(!is_migrate_isolate_page(page))) {
	__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
	if (is_migrate_cma(mt))
		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
}

As you can see above snippet, current code already handle second problem,
incorrect freepage accounting, by re-fetching pageblock migratetype
through is_migrate_isolate_page(page). But, because this re-fetched
information isn't used for __free_one_page(), first problem would not be
solved. This patch try to solve this situation to re-fetch pageblock
migratetype before __free_one_page() and to use it for __free_one_page().

In addition to move up position of this re-fetch, this patch use
optimization technique, re-fetching migratetype only if there is
isolate pageblock. Pageblock isolation is rare event, so we can
avoid re-fetching in common case with this optimization.

This patch also correct migratetype of the tracepoint output.

Cc: <stable@vger.kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f7a867e..6df23fe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -725,14 +725,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 			mt = get_freepage_migratetype(page);
+			if (unlikely(has_isolate_pageblock(zone))) {
+				mt = get_pageblock_migratetype(page);
+				if (is_migrate_isolate(mt))
+					goto skip_counting;
+			}
+			__mod_zone_freepage_state(zone, 1, mt);
+
+skip_counting:
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(!is_migrate_isolate_page(page))) {
-				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
-				if (is_migrate_cma(mt))
-					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
-			}
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
