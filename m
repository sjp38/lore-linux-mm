Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 43D466B0069
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 03:53:06 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so1603689pad.40
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 00:53:05 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id oh14si1681189pdb.35.2014.07.04.00.53.02
        for <linux-mm@kvack.org>;
        Fri, 04 Jul 2014 00:53:05 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 04/10] mm/page_alloc: carefully free the page on isolate pageblock
Date: Fri,  4 Jul 2014 16:57:49 +0900
Message-Id: <1404460675-24456-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We got migratetype without holding the lock so it could be
racy. If some pages go on the isolate migratetype buddy list
by this race, we can't allocate this page anymore until next
isolation attempt on this pageblock. Below is possible
scenario of this race.

pageblock 1 is isolate migratetype.

CPU1					CPU2
- get_pfnblock_migratetype(pageblock 1),
so MIGRATE_ISOLATE is returned
- call free_one_page() with MIGRATE_ISOLATE
					- grab the zone lock
					- unisolate pageblock 1
					- release the zone lock
- grab the zone lock
- call __free_one_page() with MIGRATE_ISOLATE
- free page go into isolate buddy list
and we can't use it anymore

To prevent this possibility, re-check migratetype with holding the lock.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 99c05f7..d8feedc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -743,6 +743,17 @@ static void free_one_page(struct zone *zone,
 	spin_lock(&zone->lock);
 	zone->pages_scanned = 0;
 
+	if (unlikely(is_migrate_isolate(migratetype))) {
+		/*
+		 * We got migratetype without holding the lock so it could be
+		 * racy. If some pages go on the isolate migratetype buddy list
+		 * by this race, we can't allocate this page anymore until next
+		 * isolation attempt on this pageblock. To prevent this
+		 * possibility, re-check migratetype with holding the lock.
+		 */
+		migratetype = get_pfnblock_migratetype(page, pfn);
+	}
+
 	__free_one_page(page, pfn, zone, order, migratetype);
 	if (!is_migrate_isolate(migratetype))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
