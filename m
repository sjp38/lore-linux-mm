Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 11AD2828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 10:10:15 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so70657274wml.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 07:10:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w142si8799844wmw.28.2016.03.18.07.10.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 07:10:13 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com> <56EAD0B4.2060807@suse.cz>
 <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56EC0C41.70503@suse.cz>
Date: Fri, 18 Mar 2016 15:10:09 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4MNdFHSSTpCfWqy7oDtkR_Hfu2dZa_LW97W8J5vr5m4tg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lucas Stach <l.stach@pengutronix.de>

On 03/17/2016 04:52 PM, Joonsoo Kim wrote:
> 2016-03-18 0:43 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>>>>>>
>>>>>> Okay. I used following slightly optimized version and I need to
>>>>>> add 'max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1)'
>>>>>> to yours. Please consider it, too.
>>>>>
>>>>> Hmm, this one is not work, I still can see the bug is there after
>>>>> applying
>>>>> this patch, did I miss something?
>>>>
>>>> I may find that there is a bug which was introduced by me some time
>>>> ago. Could you test following change in __free_one_page() on top of
>>>> Vlastimil's patch?
>>>>
>>>> -page_idx = pfn & ((1 << max_order) - 1);
>>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
>>>
>>>
>>> I tested Vlastimil's patch + your change with stress for more than half
>>> hour, the bug
>>> I reported is gone :)
>>
>>
>> Oh, ok, will try to send proper patch, once I figure out what to write in
>> the changelog :)
> 
> Thanks in advance!
> 

OK, here it is. Hanjun can you please retest this, as I'm not sure if you had
the same code due to the followup one-liner patches in the thread. Lucas, see if
it helps with your issue as well. Laura and Joonsoo, please also test and review
and check changelog if my perception of the problem is accurate :)

Thanks

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 18 Mar 2016 14:22:31 +0100
Subject: [PATCH] mm/page_alloc: prevent merging between isolated and other
 pageblocks

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
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org> # 3.18+
---
 mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c46b75d14b6f..112a5d5cec51 100644
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
2.7.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
