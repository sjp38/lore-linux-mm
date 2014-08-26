Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF0F6B0039
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 04:08:19 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so14295584qge.32
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 01:08:19 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id w8si2891555qas.110.2014.08.26.01.08.17
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 01:08:18 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH v3 3/4] mm/page_alloc: move migratetype recheck logic to __free_one_page()
Date: Tue, 26 Aug 2014 17:08:17 +0900
Message-Id: <1409040498-10148-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1409040498-10148-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

All the caller of __free_one_page() has same migratetype recheck logic,
so we can move it to __free_one_page(). This reduce line of code and help
future maintenance. This is also preparation step for "mm/page_alloc:
restrict max order of merging on isolated pageblock" which fix the
freepage accouting problem on freepage with more than pageblock order.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6c952b6..809bfd3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -578,7 +578,14 @@ static inline void __free_one_page(struct page *page,
 			return;
 
 	VM_BUG_ON(migratetype == -1);
+	if (unlikely(has_isolate_pageblock(zone))) {
+		migratetype = get_pfnblock_migratetype(page, pfn);
+		if (is_migrate_isolate(migratetype))
+			goto skip_counting;
+	}
+	__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
+skip_counting:
 	page_idx = pfn & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
@@ -716,14 +723,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
@@ -743,14 +743,6 @@ static void free_one_page(struct zone *zone,
 	if (nr_scanned)
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
-	if (unlikely(has_isolate_pageblock(zone))) {
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
