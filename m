Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 48AC36B005A
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:11:26 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2924378pab.28
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:11:26 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id df8si56867pdb.197.2014.08.06.00.11.19
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:11:20 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 8/8] mm/isolation: remove useless race handling related to pageblock isolation
Date: Wed,  6 Aug 2014 16:18:37 +0900
Message-Id: <1407309517-3270-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a mistake on moving freepage from normal buddy list to isolate
buddy list. If we move page from normal buddy list to isolate buddy list,
We should subtract freepage count in this case, but, it didn't.

And, previous patches ('mm/isolation: close the two race problems related
to pageblock isolation' and 'mm/isolation: change pageblock isolation logic
to fix freepage counting bugs') solves the race related to pageblock
isolation. So, this misplacement cannot happen and this workaround
aren't needed anymore.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c |   14 --------------
 1 file changed, 14 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 063f1f9..48c8836 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -351,20 +351,6 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 		}
 		page = pfn_to_page(pfn);
 		if (PageBuddy(page)) {
-			/*
-			 * If race between isolatation and allocation happens,
-			 * some free pages could be in MIGRATE_MOVABLE list
-			 * although pageblock's migratation type of the page
-			 * is MIGRATE_ISOLATE. Catch it and move the page into
-			 * MIGRATE_ISOLATE list.
-			 */
-			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
-				struct page *end_page;
-
-				end_page = page + (1 << page_order(page)) - 1;
-				move_freepages(page_zone(page), page, end_page,
-						MIGRATE_ISOLATE);
-			}
 			pfn += 1 << page_order(page);
 		} else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
 			/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
