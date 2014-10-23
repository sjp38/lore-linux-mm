Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CC2F26B0071
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:09:26 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so913047pdb.2
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 01:09:26 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ah2si918564pbd.191.2014.10.23.01.09.23
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 01:09:24 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v4 3/4] mm/page_alloc: move migratetype recheck logic to __free_one_page()
Date: Thu, 23 Oct 2014 17:10:20 +0900
Message-Id: <1414051821-12769-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

All the caller of __free_one_page() has similar migratetype recheck logic,
so we can move it to __free_one_page(). This reduce line of code and help
future maintenance. This is also preparation step for "mm/page_alloc:
restrict max order of merging on isolated pageblock" which fix the
freepage accouting problem on freepage with more than pageblock order.

Cc: <stable@vger.kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5d2f807..433f92c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -579,7 +579,15 @@ static inline void __free_one_page(struct page *page,
 			return;
 
 	VM_BUG_ON(migratetype == -1);
+	if (unlikely(has_isolate_pageblock(zone) ||
+		is_migrate_isolate(migratetype))) {
+		migratetype = get_pfnblock_migratetype(page, pfn);
+		if (is_migrate_isolate(migratetype))
+			goto skip_counting;
+	}
+	__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
+skip_counting:
 	page_idx = pfn & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
@@ -725,14 +733,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 			mt = get_freepage_migratetype(page);
-			if (unlikely(has_isolate_pageblock(zone))) {
-				mt = get_pageblock_migratetype(page);
-				if (is_migrate_isolate(mt))
-					goto skip_counting;
-			}
-			__mod_zone_freepage_state(zone, 1, mt);
 
-skip_counting:
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
@@ -752,15 +753,6 @@ static void free_one_page(struct zone *zone,
 	if (nr_scanned)
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
-	if (unlikely(has_isolate_pageblock(zone) ||
-		is_migrate_isolate(migratetype))) {
-		migratetype = get_pfnblock_migratetype(page, pfn);
-		if (is_migrate_isolate(migratetype))
-			goto skip_counting;
-	}
-	__mod_zone_freepage_state(zone, 1 << order, migratetype);
-
-skip_counting:
 	__free_one_page(page, pfn, zone, order, migratetype);
 	spin_unlock(&zone->lock);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
