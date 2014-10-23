Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 83EE36B0072
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:09:27 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so637807pad.15
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 01:09:27 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id t1si1040317pda.50.2014.10.23.01.09.23
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 01:09:24 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v4 4/4] mm/page_alloc: restrict max order of merging on isolated pageblock
Date: Thu, 23 Oct 2014 17:10:21 +0900
Message-Id: <1414051821-12769-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

Current pageblock isolation logic could isolate each pageblock
individually. This causes freepage accounting problem if freepage with
pageblock order on isolate pageblock is merged with other freepage on
normal pageblock. We can prevent merging by restricting max order of
merging to pageblock order if freepage is on isolate pageblock.

Side-effect of this change is that there could be non-merged buddy
freepage even if finishing pageblock isolation, because undoing pageblock
isolation is just to move freepage from isolate buddy list to normal buddy
list rather than to consider merging. But, I think it doesn't matter
because 1) almost allocation request are for equal or below pageblock
order, 2) caller of pageblock isolation will use this freepage so
freepage will split in any case and 3) merge would happen soon after
some alloc/free on this and buddy pageblock.

Cc: <stable@vger.kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 433f92c..3ec58db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -571,6 +571,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
+	int max_order = MAX_ORDER;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 
@@ -582,18 +583,26 @@ static inline void __free_one_page(struct page *page,
 	if (unlikely(has_isolate_pageblock(zone) ||
 		is_migrate_isolate(migratetype))) {
 		migratetype = get_pfnblock_migratetype(page, pfn);
-		if (is_migrate_isolate(migratetype))
+		if (is_migrate_isolate(migratetype)) {
+			/*
+			 * We restrict max order of merging to prevent merge
+			 * between freepages on isolate pageblock and normal
+			 * pageblock. Without this, pageblock isolation
+			 * could cause incorrect freepage accounting.
+			 */
+			max_order = min(MAX_ORDER, pageblock_order + 1);
 			goto skip_counting;
+		}
 	}
 	__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
 skip_counting:
-	page_idx = pfn & ((1 << MAX_ORDER) - 1);
+	page_idx = pfn & ((1 << max_order) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
-	while (order < MAX_ORDER-1) {
+	while (order < max_order - 1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
