Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCEDE280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:12:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so1516542wmd.13
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 01:12:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p80si942801wmf.208.2017.08.23.01.12.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 01:12:16 -0700 (PDT)
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
 <20170821141014.GC1371@cmpxchg.org>
 <20170823053612.GA19689@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <502d438b-7167-5b78-c66c-0e1b47ba2434@suse.cz>
Date: Wed, 23 Aug 2017 10:12:14 +0200
MIME-Version: 1.0
In-Reply-To: <20170823053612.GA19689@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On 08/23/2017 07:36 AM, Joonsoo Kim wrote:
> On Mon, Aug 21, 2017 at 10:10:14AM -0400, Johannes Weiner wrote:
>> On Wed, Aug 09, 2017 at 01:58:42PM -0700, David Rientjes wrote:
>>> On Thu, 27 Jul 2017, Vlastimil Babka wrote:
>>>
>>>> As we discussed at last LSF/MM [1], the goal here is to shift more compaction
>>>> work to kcompactd, which currently just makes a single high-order page
>>>> available and then goes to sleep. The last patch, evolved from the initial RFC
>>>> [2] does this by recording for each order > 0 how many allocations would have
>>>> potentially be able to skip direct compaction, if the memory wasn't fragmented.
>>>> Kcompactd then tries to compact as long as it takes to make that many
>>>> allocations satisfiable. This approach avoids any hooks in allocator fast
>>>> paths. There are more details to this, see the last patch.
>>>>
>>>
>>> I think I would have liked to have seen "less proactive" :)
>>>
>>> Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
>>> continues until it can defragment memory.  On a host with 128GB of memory 
>>> and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
>>> wakeups for order-2 memory allocation.  The stats are pretty bad:
>>>
>>> compact_migrate_scanned 2931254031294 
>>> compact_free_scanned    102707804816705 
>>> compact_isolated        1309145254 
>>>
>>> 0.0012% of memory scanned is ever actually isolated.  We constantly see 
>>> very high cpu for compaction_alloc() because kcompactd is almost always 
>>> running in the background and iterating most memory completely needlessly 
>>> (define needless as 0.0012% of memory scanned being isolated).
>>
>> The free page scanner will inevitably wade through mostly used memory,
>> but 0.0012% is lower than what systems usually have free. I'm guessing
>> this is because of concurrent allocation & free cycles racing with the
>> scanner? There could also be an issue with how we do partial scans.
>>
>> Anyway, we've also noticed scalability issues with the current scanner
>> on 128G and 256G machines. Even with a better efficiency - finding the
>> 1% of free memory, that's still a ton of linear search space.
>>
>> I've been toying around with the below patch. It adds a free page
>> bitmap, allowing the free scanner to quickly skip over the vast areas
>> of used memory. I don't have good data on skip-efficiency at higher
>> uptimes and the resulting fragmentation yet. The overhead added to the
>> page allocator is concerning, but I cannot think of a better way to
>> make the search more efficient. What do you guys think?
> 
> Hello, Johannes.
> 
> I think that the best solution is that the compaction doesn't do linear
> scan completely. Vlastimil already have suggested that idea.

I was going to bring this up here, thanks :)

> mm, compaction: direct freepage allocation for async direct
> compaction
> 
> lkml.kernel.org/r/<1459414236-9219-5-git-send-email-vbabka@suse.cz>
> 
> It uses the buddy allocator to get a freepage so there is no linear
> scan. It would completely remove scalability issue.

Another big advantage is that migration scanner would get to see the
whole zone, and not be biased towards the first 1/3 until it meets the
free scanner. And another advantage is that we wouldn't be splitting
free pages needlessly.

> Unfortunately, he applied this idea only to async compaction since
> changing the other compaction mode will probably cause long term
> fragmentation. And, I disagreed with that idea at that time since
> different compaction logic for different compaction mode would make
> the system more unpredicatable.
> 
> I doubt long term fragmentation is a real issue in practice. We loses
> too much things to prevent long term fragmentation. I think that it's
> the time to fix up the real issue (yours and David's) by giving up the
> solution for long term fragmentation.

I'm now also more convinced that this direction should be pursued, and
wanted to get to it after the proactive kcompactd part. My biggest
concern is that freelists can give us the pages from the same block that
we (or somebody else) is trying to compact (migrate away). Isolating
(i.e. MIGRATE_ISOLATE) the block first would work, but the overhead of
the isolation could be significant. But I have some alternative ideas
that could be tried.

> If someone doesn't agree with above solution, your approach looks the
> second best to me. Though, there is something to optimize.
> 
> I think that we don't need to be precise to track the pageblock's
> freepage state. Compaction is a far rare event compared to page
> allocation so compaction could be tolerate with false positive.
> 
> So, my suggestion is:
> 
> 1) Use 1 bit for the pageblock. Reusing PB_migrate_skip looks the best
> to me.

Wouldn't the reusing cripple the original use for the migration scanner?

> 2) Mark PB_migrate_skip only in free path and only when needed.
> Unmark it in compaction if freepage scan fails in that pageblock.
> In compaction, skip the pageblock if PB_migrate_skip is set. It means
> that there is no freepage in the pageblock.
> 
> Following is some code about my suggestion.

Otherwise is sounds like it could work until the direct allocation
approach is fully developed (or turns out to be infeasible).

Thanks.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 90b1996..c292ad2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -798,12 +798,17 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>  static inline void __free_one_page(struct page *page,
>                 unsigned long pfn,
>                 struct zone *zone, unsigned int order,
> -               int migratetype)
> +               int pageblock_flag)
>  {
>         unsigned long combined_pfn;
>         unsigned long uninitialized_var(buddy_pfn);
>         struct page *buddy;
>         unsigned int max_order;
> +       int migratetype = pageblock_flag & MT_MASK;
> +       int need_set_skip = !(pageblock_flag & SKIP_MASK);
> +
> +       if (unlikely(need_set_skip))
> +               set_pageblock_skip(page);
>  
>         max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>  
> @@ -1155,7 +1160,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  static void free_one_page(struct zone *zone,
>                                 struct page *page, unsigned long pfn,
>                                 unsigned int order,
> -                               int migratetype)
> +                               int pageblock_flag)
>  {
>         spin_lock(&zone->lock);
>         if (unlikely(has_isolate_pageblock(zone) ||
> @@ -1248,10 +1253,10 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>         if (!free_pages_prepare(page, order, true))
>                 return;
>  
> -       migratetype = get_pfnblock_migratetype(page, pfn);
> +       pageblock_flage = get_pfnblock_flag(page, pfn);
>         local_irq_save(flags);
>         __count_vm_events(PGFREE, 1 << order);
> -       free_one_page(page_zone(page), page, pfn, order, migratetype);
> +       free_one_page(page_zone(page), page, pfn, order, pageblock_flag);
>         local_irq_restore(flags);
>  }
> 
> We already access the pageblock flag for migratetype. Reusing it would
> reduce cache-line overhead. And, updating bit only happens when first
> freepage in the pageblock is freed. We don't need to modify allocation
> path since we don't track the freepage state precisly. I guess that
> this solution has almost no overhead in allocation/free path.
> 
> If allocation happens after free, compaction would see false-positive
> so it would scan the pageblock uselessly. But, as mentioned above,
> compaction is a far rare event so doing more thing in the compaction
> with reducing the overhead on allocation/free path seems better to me.
> 
> Johannes, what do you think about it?
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
