Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA9E6B003C
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:41 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kl14so2897635pab.41
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:40 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id sj5si2938579pab.342.2014.01.08.23.04.37
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:40 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 7/7] mm/page_alloc: don't merge MIGRATE_(CMA|ISOLATE) pages on buddy
Date: Thu,  9 Jan 2014 16:04:47 +0900
Message-Id: <1389251087-10224-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If (MAX_ORDER-1) is greater than pageblock order, there is a possibility
to merge different migratetype pages and to be linked in unintended
freelist.

While I test CMA, CMA pages are merged and linked into MOVABLE freelist
by above issue and then, the pages change their migratetype to UNMOVABLE by
try_to_steal_freepages(). After that, CMA to this region always fail.

To prevent this, we should not merge the page on MIGRATE_(CMA|ISOLATE)
freelist.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2548b42..ea99cee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -581,6 +581,15 @@ static inline void __free_one_page(struct page *page,
 			__mod_zone_freepage_state(zone, 1 << order,
 						  migratetype);
 		} else {
+			int buddy_mt = get_buddy_migratetype(buddy);
+
+			/* We don't want to merge cma, isolate pages */
+			if (unlikely(order >= pageblock_order) &&
+				migratetype != buddy_mt &&
+				(migratetype >= MIGRATE_PCPTYPES ||
+				buddy_mt >= MIGRATE_PCPTYPES)) {
+				break;
+			}
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
 			rmv_page_order(buddy);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
