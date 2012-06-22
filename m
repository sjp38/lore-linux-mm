Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id C6B176B0131
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 21:20:17 -0400 (EDT)
Message-ID: <4FE3C860.4000401@kernel.org>
Date: Fri, 22 Jun 2012 10:20:32 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org> <CAEtiSavHF5Z6Ex25TnZv+tTdwSfUOCFtAeOZ_f+=5cuC8QRTBw@mail.gmail.com>
In-Reply-To: <CAEtiSavHF5Z6Ex25TnZv+tTdwSfUOCFtAeOZ_f+=5cuC8QRTBw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

Hi Aaditya,

On 06/21/2012 08:02 PM, Aaditya Kumar wrote:

> On Thu, Jun 21, 2012 at 10:25 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On 06/21/2012 11:45 AM, KOSAKI Motohiro wrote:
>>
>>> On Wed, Jun 20, 2012 at 9:55 PM, Minchan Kim <minchan@kernel.org> wrote:
>>>> On 06/21/2012 10:39 AM, KOSAKI Motohiro wrote:
>>>>
>>>>>>> number of isolate page block is almost always 0. then if we have such counter,
>>>>>>> we almost always can avoid zone->lock. Just idea.
>>>>>>
>>>>>> Yeb. I thought about it but unfortunately we can't have a counter for MIGRATE_ISOLATE.
>>>>>> Because we have to tweak in page free path for pages which are going to free later after we
>>>>>> mark pageblock type to MIGRATE_ISOLATE.
>>>>>
>>>>> I mean,
>>>>>
>>>>> if (nr_isolate_pageblock != 0)
>>>>>    free_pages -= nr_isolated_free_pages(); // your counting logic
>>>>>
>>>>> return __zone_watermark_ok(z, alloc_order, mark,
>>>>>                               classzone_idx, alloc_flags, free_pages);
>>>>>
>>>>>
>>>>> I don't think this logic affect your race. zone_watermark_ok() is already
>>>>> racy. then new little race is no big matter.
>>>>
>>>>
>>>> It seems my explanation wasn't enough. :(
>>>> I already understand your intention but we can't make nr_isolate_pageblock.
>>>> Because we should count two type of free pages.
>>>
>>> I mean, move_freepages_block increment number of page *block*, not pages.
>>> number of free *pages* are counted by zone_watermark_ok_safe().
>>>
>>>
>>>> 1. Already freed page so they are already in buddy list.
>>>>   Of course, we can count it with return value of move_freepages_block(zone, page, MIGRATE_ISOLATE) easily.
>>>>
>>>> 2. Will be FREEed page by do_migrate_range.
>>>>   It's a _PROBLEM_. For it, we should tweak free path. No?
>>>
>>> No.
>>>
>>>
>>>> If All of pages are PageLRU when hot-plug happens(ie, 2), nr_isolate_pagblock is zero and
>>>> zone_watermk_ok_safe can't do his role.
>>>
>>> number of isolate pageblock don't depend on number of free pages. It's
>>> a concept of
>>> an attribute of PFN range.
>>
>>
>> It seems you mean is_migrate_isolate as a just flag, NOT nr_isolate_pageblock.
>> So do you mean this?
>>
>> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
>> index 3bdcab3..7f4d19c 100644
>> --- a/include/linux/page-isolation.h
>> +++ b/include/linux/page-isolation.h
>> @@ -1,6 +1,7 @@
>>  #ifndef __LINUX_PAGEISOLATION_H
>>  #define __LINUX_PAGEISOLATION_H
>>
>> +extern bool is_migrate_isolate;
>>  /*
>>  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
>>  * If specified range includes migrate types other than MOVABLE or CMA,
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d2a515d..b997cb3 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1756,6 +1756,27 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long ma
>>        if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>>                free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>>
>> +#if defined CONFIG_CMA || CONFIG_MEMORY_HOTPLUG
>> +       if (unlikely(is_migrate_isolate)) {
>> +               unsigned long flags;
>> +               spin_lock_irqsave(&z->lock, flags);
>> +               for (order = MAX_ORDER - 1; order >= 0; order--) {
>> +                       struct free_area *area = &z->free_area[order];
>> +                       long count = 0;
>> +                       struct list_head *curr;
>> +
>> +                       list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
>> +                               count++;
>> +
>> +                       free_pages -= (count << order);
>> +                       if (free_pages < 0) {
>> +                               free_pages = 0;
>> +                               break;
>> +                       }
>> +               }
>> +               spin_unlock_irqrestore(&z->lock, flags);
>> +       }
>> +#endif
>>        return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>>                                                                free_pages);
>>  }
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index c9f0477..212e526 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -19,6 +19,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>>        return pfn_to_page(pfn + i);
>>  }
>>
>> +bool is_migrate_isolate = false;
>> +
>>  /*
>>  * start_isolate_page_range() -- make page-allocation-type of range of pages
>>  * to be MIGRATE_ISOLATE.
>> @@ -43,6 +45,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>>        BUG_ON((start_pfn) & (pageblock_nr_pages - 1));
>>        BUG_ON((end_pfn) & (pageblock_nr_pages - 1));
>>
>> +       is_migrate_isolate = true;
>> +
>>        for (pfn = start_pfn;
>>             pfn < end_pfn;
>>             pfn += pageblock_nr_pages) {
>> @@ -59,6 +63,7 @@ undo:
>>             pfn += pageblock_nr_pages)
>>                unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
>>
>> +       is_migrate_isolate = false;
>>        return -EBUSY;
>>  }
>>
>> @@ -80,6 +85,9 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>>                        continue;
>>                unset_migratetype_isolate(page, migratetype);
>>        }
>> +
>> +       is_migrate_isolate = false;
>> +
>>        return 0;
>>  }
>>  /*
>>
> 
> Hello Minchan,
> 
> Sorry for delayed response.
> 
> Instead of above how about something like this:
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 3bdcab3..fe9215f 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -34,4 +34,6 @@ extern int set_migratetype_isolate(struct page *page);
>  extern void unset_migratetype_isolate(struct page *page, unsigned migratetype);
> 
> 
> +extern atomic_t is_migrate_isolated;

> +

>  #endif
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index ab1e714..e076fa2 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1381,6 +1381,7 @@ static int get_any_page(struct page *p, unsigned
> long pfn, int flags)
>  	 * Isolate the page, so that it doesn't get reallocated if it
>  	 * was free.
>  	 */
> +	atomic_inc(&is_migrate_isolated);


I didn't take a detail look in your patch yet.

Yes. In my patch, I missed several caller.
It was just a patch for showing my intention, NOT formal patch.
But I admit I didn't consider nesting case. brain-dead  :(
Technically other problem about this is atomic doesn't imply memory barrier so
we need barrier.

But the concern about this approach is following as
Copy/Paste from my reply of Kame.

***
But the concern about second approach is how to make sure matched count increase/decrease of nr_isolated_areas.
I mean how to make sure nr_isolated_areas would be zero when isolation is done.
Of course, we can investigate all of current caller and make sure they don't make mistake
now. But it's very error-prone if we consider future's user.
So we might need test_set_pageblock_migratetype(page, MIGRATE_ISOLATE);
	
IMHO, ideal solution is that we remove MIGRATE_ISOLATE type totally in buddy.
...
...
***

Of course, We can choose this approach as interim.
What do you think about it, Fujitsu guys?


>  	set_migratetype_isolate(p);
>  	/*
>  	 * When the target page is a free hugepage, just remove it
> @@ -1406,6 +1407,7 @@ static int get_any_page(struct page *p, unsigned
> long pfn, int flags)
>  	}
>  	unset_migratetype_isolate(p, MIGRATE_MOVABLE);
>  	unlock_memory_hotplug();
> +	atomic_dec(&is_migrate_isolated);
>  	return ret;
>  }
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0d7e3ec..cd7805c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -892,6 +892,7 @@ static int __ref offline_pages(unsigned long start_pfn,
>  	nr_pages = end_pfn - start_pfn;
> 
>  	/* set above range as isolated */
> +	atomic_inc(&is_migrate_isolated);
>  	ret = start_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	if (ret)
>  		goto out;
> @@ -958,6 +959,7 @@ repeat:
>  	offline_isolated_pages(start_pfn, end_pfn);
>  	/* reset pagetype flags and makes migrate type to be MOVABLE */
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +	atomic_dec(&is_migrate_isolated);
>  	/* removal success */
>  	zone->present_pages -= offlined_pages;
>  	zone->zone_pgdat->node_present_pages -= offlined_pages;
> @@ -986,6 +988,7 @@ failed_removal:
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> 
>  out:
> +	atomic_dec(&is_migrate_isolated);
>  	unlock_memory_hotplug();
>  	return ret;
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..f549361 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1632,6 +1632,28 @@ bool zone_watermark_ok_safe(struct zone *z, int
> order, unsigned long mark,
>  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
> 
> +#if defined CONFIG_CMA || CONFIG_MEMORY_HOTPLUG
> +       if (unlikely(atomic_read(is_migrate_isolated)) {
> +               unsigned long flags;
> +               spin_lock_irqsave(&z->lock, flags);
> +               for (order = MAX_ORDER - 1; order >= 0; order--) {
> +                       struct free_area *area = &z->free_area[order];
> +                       long count = 0;
> +                       struct list_head *curr;
> +
> +                       list_for_each(curr, &area->free_list[MIGRATE_ISOLATE])
> +                               count++;
> +
> +                       free_pages -= (count << order);
> +                       if (free_pages < 0) {
> +                               free_pages = 0;
> +                               break;
> +                       }
> +               }
> +               spin_unlock_irqrestore(&z->lock, flags);
> +       }
> +#endif
> +
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>  								free_pages);
>  }
> @@ -5785,6 +5807,7 @@ int alloc_contig_range(unsigned long start,
> unsigned long end,
>  	 * put back to page allocator so that buddy can use them.
>  	 */
> 
> +	atomic_inc(&is_migrate_isolated);
>  	ret = start_isolate_page_range(pfn_max_align_down(start),
>  				       pfn_max_align_up(end), migratetype);
>  	if (ret)
> @@ -5854,6 +5877,7 @@ int alloc_contig_range(unsigned long start,
> unsigned long end,
>  done:
>  	undo_isolate_page_range(pfn_max_align_down(start),
>  				pfn_max_align_up(end), migratetype);
> +	atomic_dec(&is_migrate_isolated);
>  	return ret;
>  }
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index c9f0477..e8eb241 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -19,6 +19,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  	return pfn_to_page(pfn + i);
>  }
> 
> +atomic_t is_migrate_isolated;
> +
>  /*
>   * start_isolate_page_range() -- make page-allocation-type of range of pages
>   * to be MIGRATE_ISOLATE.
> 
> 
>> It is still racy as you already mentioned and I don't think it's trivial.
>> Direct reclaim can't wake up kswapd forever by current fragile zone->all_unreclaimable.
>> So it's a livelock.
>> Then, do you want to fix this problem by your patch[1]?
>>
>> It could solve the livelock by OOM kill if we apply your patch[1] but still doesn't wake up
>> kswapd although it's not critical. Okay. Then, please write down this problem in detail
>> in your patch's changelog and resend, please.
>>
>> [1] http://lkml.org/lkml/2012/6/14/74
>>
>> --
>> Kind regards,
>> Minchan Kim



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
