Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 36D576B006E
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 04:46:39 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id va8so2334874obc.3
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 01:46:38 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id ou20si806534oeb.83.2015.01.07.01.46.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 01:46:37 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so2304978obb.9
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 01:46:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54ACF21B.5000801@suse.cz>
References: <1419934645-20106-1-git-send-email-zhuhui@xiaomi.com> <54ACF21B.5000801@suse.cz>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 7 Jan 2015 17:45:56 +0800
Message-ID: <CANFwon0Gac8hhUoV9-6r+9z3x2Ngm0qWqmXDobPzDEEu8tfYZw@mail.gmail.com>
Subject: Re: [PATCH] CMA: Fix CMA's page number is substructed twice in __zone_watermark_ok
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, iamjoonsoo.kim@lge.com
Cc: Hui Zhu <zhuhui@xiaomi.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, hannes@cmpxchg.org, Rik van Riel <riel@redhat.com>, isimatu.yasuaki@jp.fujitsu.com, rientjes@google.com, sasha.levin@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Weixing Liu <liuweixing@xiaomi.com>

On Wed, Jan 7, 2015 at 4:45 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 12/30/2014 11:17 AM, Hui Zhu wrote:
>> The original of this patch [1] is used to fix the issue in Joonsoo's CMA patch
>> "CMA: always treat free cma pages as non-free on watermark checking" [2].
>>
>> Joonsoo reminded me that this issue affect current kernel too.  So made a new
>> one for upstream.
>>
>> Function __zone_watermark_ok substruct CMA pages number from free_pages
>> if system allocation can't use CMA areas:
>>       /* If allocation can't use CMA areas don't use free CMA pages */
>>       if (!(alloc_flags & ALLOC_CMA))
>>               free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
>>
>> But after this part of code
>>       for (o = 0; o < order; o++) {
>>               /* At the next order, this order's pages become unavailable */
>>               free_pages -= z->free_area[o].nr_free << o;
>> CMA memory in each order is part of z->free_area[o].nr_free, then the CMA
>> page number of this order is substructed twice.  This bug will make
>> __zone_watermark_ok return more false.
>>
>> This patch add cma_free_area to struct free_area that just record the number
>> of CMA pages.  And add it back in the order loop to handle the substruct
>> twice issue.
>
> Le sigh.
>
> I now dub CMA "Contagious Memory Allocator".
> One can't even take a Christmas vacation without this blight to spread :(
>
> Seriously, with so much special casing everywhere in fast paths, Minchan's
> (IIRC) proposal of a special CMA zone has some appeal.
>
> But it seems to me that the bug you are fixing doesn't exist as you describe it?
> free_cma is only used here:
>
>         if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
>                 return false;
>
> So it's subtracted from free_pages just temporarily for the basic order-0 check.
> In the higher-order magic loop, it's not used at all?
>

I am so sorry  that I made a mistake when I split this patch from the
patch series.

The original of this patch is to fix the issue around Joonsoo's update
of __zone_watermark_ok:
if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages)
free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);

if (free_pages <= min + z->lowmem_reserve[classzone_idx])
return false;

Joonsoo, what about submit this change to upstream first?

Thanks,
Hui


> Vlastimil
>
>
>> [1] https://lkml.org/lkml/2014/12/25/43
>> [2] https://lkml.org/lkml/2014/5/28/110
>>
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>> Signed-off-by: Weixing Liu <liuweixing@xiaomi.com>
>> ---
>>  include/linux/mmzone.h |  3 +++
>>  mm/page_alloc.c        | 22 ++++++++++++++++++++++
>>  2 files changed, 25 insertions(+)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 2f0856d..094476b 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -92,6 +92,9 @@ static inline int get_pfnblock_migratetype(struct page *page, unsigned long pfn)
>>  struct free_area {
>>       struct list_head        free_list[MIGRATE_TYPES];
>>       unsigned long           nr_free;
>> +#ifdef CONFIG_CMA
>> +     unsigned long           cma_nr_free;
>> +#endif
>>  };
>>
>>  struct pglist_data;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 7633c50..026cf27 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -650,6 +650,8 @@ static inline void __free_one_page(struct page *page,
>>               } else {
>>                       list_del(&buddy->lru);
>>                       zone->free_area[order].nr_free--;
>> +                     if (is_migrate_cma(migratetype))
>> +                             zone->free_area[order].cma_nr_free--;
>>                       rmv_page_order(buddy);
>>               }
>>               combined_idx = buddy_idx & page_idx;
>> @@ -683,6 +685,8 @@ static inline void __free_one_page(struct page *page,
>>       list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>>  out:
>>       zone->free_area[order].nr_free++;
>> +     if (is_migrate_cma(migratetype))
>> +             zone->free_area[order].cma_nr_free++;
>>  }
>>
>>  static inline int free_pages_check(struct page *page)
>> @@ -937,6 +941,8 @@ static inline void expand(struct zone *zone, struct page *page,
>>               }
>>               list_add(&page[size].lru, &area->free_list[migratetype]);
>>               area->nr_free++;
>> +             if (is_migrate_cma(migratetype))
>> +                     area->cma_nr_free++;
>>               set_page_order(&page[size], high);
>>       }
>>  }
>> @@ -1020,6 +1026,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>>               list_del(&page->lru);
>>               rmv_page_order(page);
>>               area->nr_free--;
>> +             if (is_migrate_cma(migratetype))
>> +                     area->cma_nr_free--;
>>               expand(zone, page, order, current_order, area, migratetype);
>>               set_freepage_migratetype(page, migratetype);
>>               return page;
>> @@ -1208,6 +1216,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>>                       page = list_entry(area->free_list[migratetype].next,
>>                                       struct page, lru);
>>                       area->nr_free--;
>> +                     if (is_migrate_cma(migratetype))
>> +                             area->cma_nr_free--;
>>
>>                       new_type = try_to_steal_freepages(zone, page,
>>                                                         start_migratetype,
>> @@ -1597,6 +1607,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
>>       /* Remove page from free list */
>>       list_del(&page->lru);
>>       zone->free_area[order].nr_free--;
>> +     if (is_migrate_cma(mt))
>> +             zone->free_area[order].cma_nr_free--;
>>       rmv_page_order(page);
>>
>>       /* Set the pageblock if the isolated page is at least a pageblock */
>> @@ -1827,6 +1839,13 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
>>               /* At the next order, this order's pages become unavailable */
>>               free_pages -= z->free_area[o].nr_free << o;
>>
>> +             /* If CMA's page number of this order was substructed as part
>> +                of "zone_page_state(z, NR_FREE_CMA_PAGES)", subtracting
>> +                "z->free_area[o].nr_free << o" substructed CMA's page
>> +                number of this order again.  So add it back.  */
>> +             if (IS_ENABLED(CONFIG_CMA) && free_cma)
>> +                     free_pages += z->free_area[o].cma_nr_free << o;
>> +
>>               /* Require fewer higher order pages to be free */
>>               min >>= 1;
>>
>> @@ -4238,6 +4257,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
>>       for_each_migratetype_order(order, t) {
>>               INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
>>               zone->free_area[order].nr_free = 0;
>> +             zone->free_area[order].cma_nr_free = 0;
>>       }
>>  }
>>
>> @@ -6610,6 +6630,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>               list_del(&page->lru);
>>               rmv_page_order(page);
>>               zone->free_area[order].nr_free--;
>> +             if (is_migrate_cma(get_pageblock_migratetype(page)))
>> +                     zone->free_area[order].cma_nr_free--;
>>               for (i = 0; i < (1 << order); i++)
>>                       SetPageReserved((page+i));
>>               pfn += (1 << order);
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
