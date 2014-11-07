Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8045A800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:33:55 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kx10so3004323pab.20
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:33:55 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id n7si8287513pdp.72.2014.11.06.23.33.52
        for <linux-mm@kvack.org>;
        Thu, 06 Nov 2014 23:33:54 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/2] mm/debug-pagealloc: correct freepage accounting and order resetting
Date: Fri,  7 Nov 2014 16:35:45 +0900
Message-Id: <1415345746-16666-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

One thing, I did in this patch, is fixing freepage accounting.
If we clear guard page and link it onto isolate buddy list, we should
not increase freepage count. This patch adds conditional branch to
skip counting in this case. Without this patch, this overcounting
happens frequently if guard order is set and CMA is used.

Another thing fixed in this patch is the target to reset order. In
__free_one_page(), we check the buddy page whether it is a guard page or
not. And, if so, we should clear guard attribute on the buddy page and
reset order of it to 0. But, current code resets original page's order
rather than buddy one's. Maybe, this doesn't have any problem, because
whole merged page's order will be re-assigned soon. But, it is better
to correct code.

Changes from v2:
Rename subject from
"mm/page_alloc: correct to clear guard attribute in DEBUG_PAGEALLOC"
to
"mm/debug-pagealloc: correct freepage accounting and order resetting".
Separate fix and clean-up part.

Cc: <stable@vger.kernel.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e78e3c8..d673f64 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -583,9 +583,11 @@ static inline void __free_one_page(struct page *page,
 		 */
 		if (page_is_guard(buddy)) {
 			clear_page_guard_flag(buddy);
-			set_page_private(page, 0);
-			__mod_zone_freepage_state(zone, 1 << order,
-						  migratetype);
+			set_page_private(buddy, 0);
+			if (!is_migrate_isolate(migratetype)) {
+				__mod_zone_freepage_state(zone, 1 << order,
+							  migratetype);
+			}
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
