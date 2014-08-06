Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 884726B003B
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:11:22 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2941641pad.27
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:11:22 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ra8si119783pbb.56.2014.08.06.00.11.18
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:11:19 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/8] mm/isolation: remove unstable check for isolated page
Date: Wed,  6 Aug 2014 16:18:29 +0900
Message-Id: <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The check '!PageBuddy(page) && page_count(page) == 0 &&
migratetype == MIGRATE_ISOLATE' would mean the page on free processing.
Although it could go into buddy allocator within a short time,
futher operation such as isolate_freepages_range() in CMA, called after
test_page_isolated_in_pageblock(), could be failed due to this unstability
since it requires that the page is on buddy. I think that removing
this unstability is good thing.

And, following patch makes isolated freepage has new status matched with
this condition and this check is the obstacle to that change. So remove
it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..3100f98 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -198,11 +198,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 						MIGRATE_ISOLATE);
 			}
 			pfn += 1 << page_order(page);
-		}
-		else if (page_count(page) == 0 &&
-			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
-			pfn += 1;
-		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
+		} else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
 			/*
 			 * The HWPoisoned page may be not in buddy
 			 * system, and page_count() is not 0.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
