Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id F3DD76B0075
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:44:14 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id rl12so2771964iec.19
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:44:14 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id rv2si8316049igb.34.2014.12.10.06.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 06:44:13 -0800 (PST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so2762907iec.38
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:44:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5486C591.7030509@suse.cz>
References: <000301d01385$45554a60$cfffdf20$%yang@samsung.com>
	<5486C591.7030509@suse.cz>
Date: Wed, 10 Dec 2014 22:44:13 +0800
Message-ID: <CAL1ERfOZ5eiJTDneh=5HAoOs7z2AhxxrKaLL9sHKtRk0Cfcf6Q@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: page_alloc: remove redundant set_freepage_migratetype()
 calls
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Weijie Yang <weijie.yang@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Dec 9, 2014 at 5:49 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 12/09/2014 08:51 AM, Weijie Yang wrote:
>>
>> The freepage_migratetype is a temporary cached value which represents
>> the free page's pageblock migratetype. Now we use it in two scenarios:
>>
>> 1. Use it as a cached value in page freeing path. This cached value
>> is temporary and non-100% update, which help us decide which pcp
>> freelist and buddy freelist the page should go rather than using
>> get_pfnblock_migratetype() to save some instructions.
>> When there is race between page isolation and free path, we need use
>> additional method to get a accurate value to put the free pages to
>> the correct freelist and get a precise free pages statistics.
>>
>> 2. Use it in page alloc path to update NR_FREE_CMA_PAGES statistics.
>
>
> Maybe add that in this case, the value is only valid between being set by
> __rmqueue_smallest/__rmqueue_fallback and being consumed by rmqueue_bulk or
> buffered_rmqueue for the purposes of statistics.
> Oh, except that in rmqueue_bulk, we are placing it on pcplists, so it's case
> 1. Tricky.

I will add more description and comments in the next version.
Thanks.

> Anyway, the comments for get/set_freepage_migratetype() say:
>
> /* It's valid only if the page is free path or free_list */
>
> And that's not really true. So should it instead say something like "The
> value is only valid when the page is on pcp list, for determining on which
> free list the page should go if the pcp list is flushed. It is also
> temporarily valid during allocation from free list."

I will update the comments. Thanks

>> This patch aims at the scenario 1 and removes two redundant
>> set_freepage_migratetype() calls, which will make sense in the hot path.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>   mm/page_alloc.c |    2 --
>>   1 file changed, 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 616a2c9..99af01a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -775,7 +775,6 @@ static void __free_pages_ok(struct page *page,
>> unsigned int order)
>>         migratetype = get_pfnblock_migratetype(page, pfn);
>>         local_irq_save(flags);
>>         __count_vm_events(PGFREE, 1 << order);
>> -       set_freepage_migratetype(page, migratetype);
>>         free_one_page(page_zone(page), page, pfn, order, migratetype);
>>         local_irq_restore(flags);
>>   }
>> @@ -1024,7 +1023,6 @@ int move_freepages(struct zone *zone,
>>                 order = page_order(page);
>>                 list_move(&page->lru,
>>                           &zone->free_area[order].free_list[migratetype]);
>> -               set_freepage_migratetype(page, migratetype);
>>                 page += 1 << order;
>>                 pages_moved += 1 << order;
>>         }
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
