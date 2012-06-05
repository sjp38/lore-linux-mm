Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 629126B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 02:05:24 -0400 (EDT)
Message-ID: <4FCDA1B4.9050301@kernel.org>
Date: Tue, 05 Jun 2012 15:05:40 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206041543.56917.b.zolnierkie@samsung.com> <4FCD18FD.5030307@gmail.com> <4FCD6806.7070609@kernel.org> <4FCD713D.3020100@kernel.org> <4FCD8C99.3010401@gmail.com>
In-Reply-To: <4FCD8C99.3010401@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On 06/05/2012 01:35 PM, KOSAKI Motohiro wrote:

>>>> Minchan, are you interest this patch? If yes, can you please rewrite
>>>> it?
>>>
>>> Can do it but I want to give credit to Bartlomiej.
>>> Bartlomiej, if you like my patch, could you resend it as formal patch
>>> after you do broad testing?
>>>
>>> Frankly speaking, I don't want to merge it without any data which
>>> prove it's really good for real practice.
>>>
>>> When the patch firstly was submitted, it wasn't complicated so I was
>>> okay at that time but it has been complicated
>>> than my expectation. So if Andrew might pass the decision to me, I'm
>>> totally NACK if author doesn't provide
>>> any real data or VOC of some client.
> 
> I agree. And you don't need to bother this patch if you are not interest
> this one. I'm sorry.


Never mind.

> Let's throw it away until the author send us data.
> 

I guess it's hard to make such workload to prove it's useful normally.
But we can't make sure there isn't such workload in the world.
So I hope listen VOC. At least, Mel might require it.

If anyone doesn't support it, I hope let's add some vmstat like stuff for proving
this patch's effect. If we can't see the benefit through vmstat, we can deprecate
it later.

>>> 1) Any comment?
>>>
>>> Anyway, I fixed some bugs and clean up something I found during review.
>>>
>>> Minor thing.
>>> 1. change smt_result naming - I never like such long non-consistent
>>> naming. How about this?
>>> 2. fix can_rescue_unmovable_pageblock
>>>     2.1 pfn valid check for page_zone
>>>
>>> Major thing.
>>>
>>>     2.2 add lru_lock for stablizing PageLRU
>>>         If we don't hold lru_lock, there is possibility that
>>> unmovable(non-LRU) page can put in movable pageblock.
>>>         It can make compaction/CMA's regression. But there is a
>>> concern about deadlock between lru_lock and lock.
>>>         As I look the code, I can't find allocation trial with
>>> holding lru_lock so it might be safe(but not sure,
>>>         I didn't test it. It need more careful review/testing) but it
>>> makes new locking dependency(not sure, too.
>>>         We already made such rule but I didn't know that until now
>>> ;-) ) Why I thought so is we can allocate
>>>         GFP_ATOMIC with holding lru_lock, logically which might be
>>> crazy idea.
>>>
>>>     2.3 remove zone->lock in first phase.
>>>         We do rescue unmovable pageblock by 2-phase. In first-phase,
>>> we just peek pages so we don't need locking.
>>>         If we see non-stablizing value, it would be caught by 2-phase
>>> with needed lock or
>>>         can_rescue_unmovable_pageblock can return out of loop by
>>> stale page_order(cursor_page).
>>>         It couldn't make unmovable pageblock to movable but we can do
>>> it next time, again.
>>>         It's not critical.
>>>
>>> 2) Any comment?
>>>
>>> Now I can't inline the code so sorry but attach patch.
>>> It's not a formal patch/never tested.
>>>
>>
>>
>> Attached patch has a BUG in can_rescue_unmovable_pageblock.
>> Resend. I hope it is fixed.
>>
>>
>>
>>
>>
>> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
>> index 51a90b7..e988037 100644
>> --- a/include/linux/compaction.h
>> +++ b/include/linux/compaction.h
>> @@ -1,6 +1,8 @@
>>  #ifndef _LINUX_COMPACTION_H
>>  #define _LINUX_COMPACTION_H
>>
>> +#include <linux/node.h>
>> +
>>  /* Return values for compact_zone() and try_to_compact_pages() */
>>  /* compaction didn't start as it was not possible or direct reclaim
>> was more suitable */
>>  #define COMPACT_SKIPPED        0
>> @@ -11,6 +13,23 @@
>>  /* The full zone was compacted */
>>  #define COMPACT_COMPLETE    3
>>
>> +/*
>> + * compaction supports three modes
>> + *
>> + * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
>> + *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
>> + * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
>> + *    MIGRATE_MOVABLE pageblocks as migration sources.
>> + *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
>> + *    targets and convers them to MIGRATE_MOVABLE if possible
>> + * COMPACT_SYNC uses synchronous migration and scans all pageblocks
>> + */
>> +enum compact_mode {
>> +    COMPACT_ASYNC_MOVABLE,
>> +    COMPACT_ASYNC_UNMOVABLE,
>> +    COMPACT_SYNC,
>> +};
>> +
>>  #ifdef CONFIG_COMPACTION
>>  extern int sysctl_compact_memory;
>>  extern int sysctl_compaction_handler(struct ctl_table *table, int write,
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 7ea259d..dd02f25 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -236,7 +236,7 @@ isolate_migratepages_range(struct zone *zone,
>> struct compact_control *cc,
>>       */
>>      while (unlikely(too_many_isolated(zone))) {
>>          /* async migration should just abort */
>> -        if (!cc->sync)
>> +        if (cc->mode != COMPACT_SYNC)
>>              return 0;
>>
>>          congestion_wait(BLK_RW_ASYNC, HZ/10);
>> @@ -304,7 +304,8 @@ isolate_migratepages_range(struct zone *zone,
>> struct compact_control *cc,
>>           * satisfies the allocation
>>           */
>>          pageblock_nr = low_pfn >> pageblock_order;
>> -        if (!cc->sync && last_pageblock_nr != pageblock_nr &&
>> +        if (cc->mode != COMPACT_SYNC &&
>> +            last_pageblock_nr != pageblock_nr &&
>>              !migrate_async_suitable(get_pageblock_migratetype(page))) {
>>              low_pfn += pageblock_nr_pages;
>>              low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
>> @@ -325,7 +326,7 @@ isolate_migratepages_range(struct zone *zone,
>> struct compact_control *cc,
>>              continue;
>>          }
>>
>> -        if (!cc->sync)
>> +        if (cc->mode != COMPACT_SYNC)
>>              mode |= ISOLATE_ASYNC_MIGRATE;
>>
>>          lruvec = mem_cgroup_page_lruvec(page, zone);
>> @@ -360,27 +361,121 @@ isolate_migratepages_range(struct zone *zone,
>> struct compact_control *cc,
>>
>>  #endif /* CONFIG_COMPACTION || CONFIG_CMA */
>>  #ifdef CONFIG_COMPACTION
>> +/*
>> + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
>> + * converted to MIGRATE_MOVABLE type, false otherwise.
>> + */
>> +static bool can_rescue_unmovable_pageblock(struct page *page, bool
>> need_lrulock)
>> +{
>> +    struct zone *zone;
>> +    unsigned long pfn, start_pfn, end_pfn;
>> +    struct page *start_page, *end_page, *cursor_page;
>> +    bool lru_locked = false;
>> +
>> +    zone = page_zone(page);
>> +    pfn = page_to_pfn(page);
>> +    start_pfn = pfn & ~(pageblock_nr_pages - 1);
>> +    end_pfn = start_pfn + pageblock_nr_pages - 1;
>> +
>> +    start_page = pfn_to_page(start_pfn);
>> +    end_page = pfn_to_page(end_pfn);
>> +
>> +    for (cursor_page = start_page, pfn = start_pfn; cursor_page <=
>> end_page;
>> +        pfn++, cursor_page++) {
>>
>> -/* Returns true if the page is within a block suitable for migration
>> to */
>> -static bool suitable_migration_target(struct page *page)
>> +        if (!pfn_valid_within(pfn))
>> +            continue;
>> +
>> +        /* Do not deal with pageblocks that overlap zones */
>> +        if (page_zone(cursor_page) != zone)
>> +            goto out;
>> +
>> +        if (PageBuddy(cursor_page)) {
>> +            unsigned long order = page_order(cursor_page);
>> +
>> +            pfn += (1 << order) - 1;
>> +            cursor_page += (1 << order) - 1;
>> +            continue;
>> +        } else if (page_count(cursor_page) == 0) {
>> +            continue;
> 
> Can we assume freed tail page always have page_count()==0? if yes, why
> do we
> need dangerous PageBuddy(cursor_page) check? ok, but this may be harmless.
> 


page_count check is for pcp pages.
Am I missing your point?

> But if no, this code is seriously dangerous. think following scenario,
> 
> 1) cursor page points free page
> 
>     +----------------+------------------+
>     | free (order-1) |  used (order-1)  |
>     +----------------+------------------+
>     |
>    cursor
> 
> 2) moved cursor
> 
>     +----------------+------------------+
>     | free (order-1) |  used (order-1)  |
>     +----------------+------------------+
>                      |
>                      cursor
> 
> 3) neighbor block was freed
> 
> 
>     +----------------+------------------+
>     | free (order-2)                    |
>     +----------------+------------------+
>                      |
>                      cursor
> 
> now, cursor points to middle of free block.
> 

> 

> Anyway, I recommend to avoid dangerous no zone->lock game and change
> can_rescue_unmovable_pageblock() is only called w/ zone->lock. I have



I can't understand your point.
If the page is middle of free block, what's the problem in can_rescue_unmovable_pageblock
at first trial of can_rescue_xxx?
I think we can stabilize it in second trial of can_rescue_unmovable_pageblock with zone->lock.

> no seen any worth to include this high complex for mere minor optimization.

> 

> 
>> +        } else if (PageLRU(cursor_page)) {
>> +            if (!need_lrulock)
>> +                continue;
>> +            else if (lru_locked)
>> +                continue;
>> +            else {
>> +                spin_lock(&zone->lru_lock);
> 
> Hmm...
> I don't like to take lru_lock. 1) Until now, we carefully avoid to take
> both zone->lock and zone->lru_lock. they are both performance critical
> lock. And I think pageblock migratetype don't need strictly correct. It
> is only optimization of anti fragmentation. Why do we need take it?
> 


movable_block has unmovable page can make regression of anti-fragmentation.
So I did it. I agree it's a sort of optimization.
If others don't want it at the cost of regression anti-fragmentation, we can remove the lock.

> 
> 
>> +                lru_locked = true;
>> +                if (PageLRU(page))
>> +                    continue;
>> +            }
>> +        }
>> +
>> +        goto out;
>> +    }
>> +
> 
> Why don't we need to release lru_lock when returning true.


Because my brain has gone. :(

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
