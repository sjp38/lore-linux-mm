Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0916B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:40:34 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id p65so225472714wmp.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 02:40:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u81si2672121wmg.59.2016.03.23.02.40.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 02:40:32 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm/page_alloc: prevent merging between isolated and other pageblocks
Date: Wed, 23 Mar 2016 10:40:23 +0100
Message-Id: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leizhen <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, Lucas Stach <l.stach@pengutronix.de>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hanjun Guo <guohanjun@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Laura Abbott <labbott@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, stable@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hanjun Guo has reported that a CMA stress test causes broken accounting of
CMA and free pages:

> Before the test, I got:
> -bash-4.3# cat /proc/meminfo | grep Cma
> CmaTotal:         204800 kB
> CmaFree:          195044 kB
>
>
> After running the test:
> -bash-4.3# cat /proc/meminfo | grep Cma
> CmaTotal:         204800 kB
> CmaFree:         6602584 kB
>
> So the freed CMA memory is more than total..
>
> Also the the MemFree is more than mem total:
>
> -bash-4.3# cat /proc/meminfo
> MemTotal:       16342016 kB
> MemFree:        22367268 kB
> MemAvailable:   22370528 kB

Laura Abbott has confirmed the issue and suspected the freepage accounting
rewrite around 3.18/4.0 by Joonsoo Kim. Joonsoo had a theory that this is
caused by unexpected merging between MIGRATE_ISOLATE and MIGRATE_CMA
pageblocks:

> CMA isolates MAX_ORDER aligned blocks, but, during the process,
> partialy isolated block exists. If MAX_ORDER is 11 and
> pageblock_order is 9, two pageblocks make up MAX_ORDER
> aligned block and I can think following scenario because pageblock
> (un)isolation would be done one by one.
>
> (each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
> MIGRATE_ISOLATE, respectively.
>
> CC -> IC -> II (Isolation)
> II -> CI -> CC (Un-isolation)
>
> If some pages are freed at this intermediate state such as IC or CI,
> that page could be merged to the other page that is resident on
> different type of pageblock and it will cause wrong freepage count.

This was supposed to be prevented by CMA operating on MAX_ORDER blocks, but
since it doesn't hold the zone->lock between pageblocks, a race window does
exist.

It's also likely that unexpected merging can occur between MIGRATE_ISOLATE
and non-CMA pageblocks. This should be prevented in __free_one_page() since
commit 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated
pageblock"). However, we only check the migratetype of the pageblock where
buddy merging has been initiated, not the migratetype of the buddy pageblock
(or group of pageblocks) which can be MIGRATE_ISOLATE.

Joonsoo has suggested checking for buddy migratetype as part of
page_is_buddy(), but that would add extra checks in allocator hotpath and
bloat-o-meter has shown significant code bloat (the function is inline).

This patch reduces the bloat at some expense of more complicated code. The
buddy-merging while-loop in __free_one_page() is initially bounded to
pageblock_border and without any migratetype checks. The checks are placed
outside, bumping the max_order if merging is allowed, and returning to the
while-loop with a statement which can't be possibly considered harmful.

This fixes the accounting bug and also removes the arguably weird state in the
original commit 3c605096d315 where buddies could be left unmerged.

Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
Link: https://lkml.org/lkml/2016/3/2/280
Reported-by: Hanjun Guo <guohanjun@huawei.com>
Debugged-by: Laura Abbott <labbott@redhat.com>
Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: <stable@vger.kernel.org> # v3.18+
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c46b75d14b6f..b9785af4fae2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -683,34 +683,28 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
-	unsigned int max_order = MAX_ORDER;
+	unsigned int max_order;
+
+	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
 	VM_BUG_ON(migratetype == -1);
-	if (is_migrate_isolate(migratetype)) {
-		/*
-		 * We restrict max order of merging to prevent merge
-		 * between freepages on isolate pageblock and normal
-		 * pageblock. Without this, pageblock isolation
-		 * could cause incorrect freepage accounting.
-		 */
-		max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
-	} else {
+	if (likely(!is_migrate_isolate(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
-	}
 
-	page_idx = pfn & ((1 << max_order) - 1);
+	page_idx = pfn & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
+continue_merging:
 	while (order < max_order - 1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
-			break;
+			goto done_merging;
 		/*
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
@@ -727,6 +721,32 @@ static inline void __free_one_page(struct page *page,
 		page_idx = combined_idx;
 		order++;
 	}
+	if (max_order < MAX_ORDER) {
+		/* If we are here, it means order is >= pageblock_order.
+		 * We want to prevent merge between freepages on isolate
+		 * pageblock and normal pageblock. Without this, pageblock
+		 * isolation could cause incorrect freepage or CMA accounting.
+		 *
+		 * We don't want to hit this code for the more frequent
+		 * low-order merging.
+		 */
+		if (unlikely(has_isolate_pageblock(zone))) {
+			int buddy_mt;
+
+			buddy_idx = __find_buddy_index(page_idx, order);
+			buddy = page + (buddy_idx - page_idx);
+			buddy_mt = get_pageblock_migratetype(buddy);
+
+			if (migratetype != buddy_mt
+					&& (is_migrate_isolate(migratetype) ||
+						is_migrate_isolate(buddy_mt)))
+				goto done_merging;
+		}
+		max_order++;
+		goto continue_merging;
+	}
+
+done_merging:
 	set_page_order(page, order);
 
 	/*
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
