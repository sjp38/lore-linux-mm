Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 03E266B003A
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:52:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so1616293pad.27
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:52:51 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id qi1si34793635pbb.6.2014.07.04.00.52.48
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:52:49 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 03/10] mm/page_alloc: handle page on pcp correctly if it's pageblock is isolated
Date: Fri,  4 Jul 2014 16:57:48 +0900
Message-Id: <1404460675-24456-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If pageblock of page on pcp are isolated now, we should free it to isolate
buddy list to prevent future allocation on it. But current code doesn't
do this.

Moreover, there is a freepage counting problem on current code. Although
pageblock of page on pcp are isolated now, it could go normal buddy list,
because get_onpcp_migratetype() will return non-isolate migratetype.
In this case, we should do either adding freepage count or changing
migratetype to MIGRATE_ISOLATE, but, current code do neither.

This patch fixes these two problems by handling pageblock migratetype
before calling __free_one_page(). And, if we find the page on isolated
pageblock, change migratetype to MIGRATE_ISOLATE to prevent future
allocation of this page and freepage counting problem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aeb51d1..99c05f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -719,15 +719,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			mt = get_freepage_migratetype(page);
+
+			if (unlikely(is_migrate_isolate_page(page))) {
+				mt = MIGRATE_ISOLATE;
+			} else {
+				mt = get_freepage_migratetype(page);
+				__mod_zone_freepage_state(zone, 1, mt);
+			}
+
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
