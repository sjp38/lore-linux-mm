Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 593666B00B5
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 06:54:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5D53F3EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:54:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DB7745DEAD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:54:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 236F945DE7E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:54:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13544E08002
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:54:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B70071DB803B
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:54:56 +0900 (JST)
Message-ID: <4FE2FCFB.4040808@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 19:52:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org>
In-Reply-To: <4FE2A937.6040701@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(2012/06/21 13:55), Minchan Kim wrote:
> On 06/21/2012 11:45 AM, KOSAKI Motohiro wrote:
>
>> On Wed, Jun 20, 2012 at 9:55 PM, Minchan Kim<minchan@kernel.org>  wrote:
>>> On 06/21/2012 10:39 AM, KOSAKI Motohiro wrote:
>>>
>>>>>> number of isolate page block is almost always 0. then if we have such counter,
>>>>>> we almost always can avoid zone->lock. Just idea.
>>>>>
>>>>> Yeb. I thought about it but unfortunately we can't have a counter for MIGRATE_ISOLATE.
>>>>> Because we have to tweak in page free path for pages which are going to free later after we
>>>>> mark pageblock type to MIGRATE_ISOLATE.
>>>>
>>>> I mean,
>>>>
>>>> if (nr_isolate_pageblock != 0)
>>>>     free_pages -= nr_isolated_free_pages(); // your counting logic
>>>>
>>>> return __zone_watermark_ok(z, alloc_order, mark,
>>>>                                classzone_idx, alloc_flags, free_pages);
>>>>
>>>>
>>>> I don't think this logic affect your race. zone_watermark_ok() is already
>>>> racy. then new little race is no big matter.
>>>
>>>
>>> It seems my explanation wasn't enough. :(
>>> I already understand your intention but we can't make nr_isolate_pageblock.
>>> Because we should count two type of free pages.
>>
>> I mean, move_freepages_block increment number of page *block*, not pages.
>> number of free *pages* are counted by zone_watermark_ok_safe().
>>
>>
>>> 1. Already freed page so they are already in buddy list.
>>>    Of course, we can count it with return value of move_freepages_block(zone, page, MIGRATE_ISOLATE) easily.
>>>
>>> 2. Will be FREEed page by do_migrate_range.
>>>    It's a _PROBLEM_. For it, we should tweak free path. No?
>>
>> No.
>>
>>
>>> If All of pages are PageLRU when hot-plug happens(ie, 2), nr_isolate_pagblock is zero and
>>> zone_watermk_ok_safe can't do his role.
>>
>> number of isolate pageblock don't depend on number of free pages. It's
>> a concept of
>> an attribute of PFN range.
>
>
> It seems you mean is_migrate_isolate as a just flag, NOT nr_isolate_pageblock.
> So do you mean this?
>
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 3bdcab3..7f4d19c 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -1,6 +1,7 @@
>   #ifndef __LINUX_PAGEISOLATION_H
>   #define __LINUX_PAGEISOLATION_H
>
> +extern bool is_migrate_isolate;
>   /*
>    * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
>    * If specified range includes migrate types other than MOVABLE or CMA,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d2a515d..b997cb3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1756,6 +1756,27 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long ma
>          if (z->percpu_drift_mark&&  free_pages<  z->percpu_drift_mark)
>                  free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>
> +#if defined CONFIG_CMA || CONFIG_MEMORY_HOTPLUG
> +       if (unlikely(is_migrate_isolate)) {
> +               unsigned long flags;
> +               spin_lock_irqsave(&z->lock, flags);
> +               for (order = MAX_ORDER - 1; order>= 0; order--) {
> +                       struct free_area *area =&z->free_area[order];
> +                       long count = 0;
> +                       struct list_head *curr;
> +
> +                       list_for_each(curr,&area->free_list[MIGRATE_ISOLATE])
> +                               count++;
> +
> +                       free_pages -= (count<<  order);
> +                       if (free_pages<  0) {
> +                               free_pages = 0;
> +                               break;
> +                       }
> +               }
> +               spin_unlock_irqrestore(&z->lock, flags);
> +       }
> +#endif
>          return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>                                                                  free_pages);
>   }
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index c9f0477..212e526 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -19,6 +19,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>          return pfn_to_page(pfn + i);
>   }
>
> +bool is_migrate_isolate = false;
> +
>   /*
>    * start_isolate_page_range() -- make page-allocation-type of range of pages
>    * to be MIGRATE_ISOLATE.
> @@ -43,6 +45,8 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>          BUG_ON((start_pfn)&  (pageblock_nr_pages - 1));
>          BUG_ON((end_pfn)&  (pageblock_nr_pages - 1));
>
> +       is_migrate_isolate = true;
> +
>          for (pfn = start_pfn;
>               pfn<  end_pfn;
>               pfn += pageblock_nr_pages) {
> @@ -59,6 +63,7 @@ undo:
>               pfn += pageblock_nr_pages)
>                  unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
>
> +       is_migrate_isolate = false;
>          return -EBUSY;
>   }
>
> @@ -80,6 +85,9 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>                          continue;
>                  unset_migratetype_isolate(page, migratetype);
>          }
> +
> +       is_migrate_isolate = false;
> +
>          return 0;
>   }
>   /*
>
> It is still racy as you already mentioned and I don't think it's trivial.
> Direct reclaim can't wake up kswapd forever by current fragile zone->all_unreclaimable.
> So it's a livelock.
> Then, do you want to fix this problem by your patch[1]?
>
> It could solve the livelock by OOM kill if we apply your patch[1] but still doesn't wake up
> kswapd although it's not critical. Okay. Then, please write down this problem in detail
> in your patch's changelog and resend, please.
>

Hm. I'm sorry if I couldn't chase the disucussion...Can I make summary ?

As you shown, it seems to be not difficult to counting free pages under MIGRATE_ISOLATE.
And we can know the zone contains MIGRATE_ISOLATE area or not by simple check.
for example.
==
                 set_pageblock_migratetype(page, MIGRATE_ISOLATE);
                 move_freepages_block(zone, page, MIGRATE_ISOLATE);
                 zone->nr_isolated_areas++;
=

Then, the solution will be adding a function like following
=
u64 zone_nr_free_pages(struct zone *zone) {
	unsigned long free_pages;

	free_pages = zone_page_state(NR_FREE_PAGES);
	if (unlikely(z->nr_isolated_areas)) {
		isolated = count_migrate_isolated_pages(zone);
		free_pages -= isolated;
	}
	return free_pages;
}
=

Right ? and... zone->all_unreclaimable is a different problem ?

Thanks,
-Kame









  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
