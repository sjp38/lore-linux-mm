Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 63F486B006C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 02:32:36 -0400 (EDT)
Received: by qaea16 with SMTP id a16so108436qae.3
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 23:32:35 -0700 (PDT)
Message-ID: <4FE16E80.9000306@gmail.com>
Date: Wed, 20 Jun 2012 02:32:32 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org>
In-Reply-To: <4FE169B1.7020600@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(6/20/12 2:12 AM), Minchan Kim wrote:
> 
> Hi Aaditya,
> 
> I want to discuss this problem on another thread.
> 
> On 06/19/2012 10:18 PM, Aaditya Kumar wrote:
>> On Mon, Jun 18, 2012 at 6:13 AM, Minchan Kim <minchan@kernel.org> wrote:
>>> On 06/17/2012 02:48 AM, Aaditya Kumar wrote:
>>>
>>>> On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> wrote:
>>>>
>>>>>>
>>>>>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>>>>>> if node has multiple zones. Hm ok, I realized my descriptions was
>>>>>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>>>>>> pgdat_balanced()
>>>>>> every priority. Most easy case is, movable zone has a lot of free pages and
>>>>>> normal zone has no reclaimable page.
>>>>>>
>>>>>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>>>>>> sleep only if every zones have much free pages than high water mark
>>>>>> _and_ 25% of present pages in node are free.
>>>>>>
>>>>>
>>>>>
>>>>> Sorry. I can't understand your point.
>>>>> Current kswapd doesn't sleep if relevant zones don't have free pages above high watermark.
>>>>> It seems I am missing your point.
>>>>> Please anybody correct me.
>>>>
>>>> Since currently direct reclaim is given up based on
>>>> zone->all_unreclaimable flag,
>>>> so for e.g in one of the scenarios:
>>>>
>>>> Lets say system has one node with two zones (NORMAL and MOVABLE) and we
>>>> hot-remove the all the pages of the MOVABLE zone.
>>>>
>>>> While migrating pages during memory hot-unplugging, the allocation function
>>>> (for new page to which the page in MOVABLE zone would be moved)  can end up
>>>> looping in direct reclaim path for ever.
>>>>
>>>> This is so because when most of the pages in the MOVABLE zone have
>>>> been migrated,
>>>> the zone now contains lots of free memory (basically above low watermark)
>>>> BUT all are in MIGRATE_ISOLATE list of the buddy list.
>>>>
>>>> So kswapd() would not balance this zone as free pages are above low watermark
>>>> (but all are in isolate list). So zone->all_unreclaimable flag would
>>>> never be set for this zone
>>>> and allocation function would end up looping forever. (assuming the
>>>> zone NORMAL is
>>>> left with no reclaimable memory)
>>>>
>>>
>>>
>>> Thanks a lot, Aaditya! Scenario you mentioned makes perfect.
>>> But I don't see it's a problem of kswapd.
>>
>> Hi Kim,
> 
> I like called Minchan rather than Kim
> Never mind. :)
> 
>>
>> Yes I agree it is not a problem of kswapd.
> 
> Yeb.
> 
>>
>>> a5d76b54 made new migration type 'MIGRATE_ISOLATE' which is very irony type because there are many free pages in free list
>>> but we can't allocate it. :(
>>> It doesn't reflect right NR_FREE_PAGES while many places in the kernel use NR_FREE_PAGES to trigger some operation.
>>> Kswapd is just one of them confused.
>>> As right fix of this problem, we should fix hot plug code, IMHO which can fix CMA, too.
>>>
>>> This patch could make inconsistency between NR_FREE_PAGES and SumOf[free_area[order].nr_free]
>>
>>
>> I assume that by the inconsistency you mention above, you mean
>> temporary inconsistency.
>>
>> Sorry, but IMHO as for memory hot plug the main issue with this patch
>> is that the inconsistency you mentioned above would NOT be a temporary
>> inconsistency.
>>
>> Every time say 'x' number of page frames are off lined, they will
>> introduce a difference of 'x' pages between
>> NR_FREE_PAGES and SumOf[free_area[order].nr_free].
>> (So for e.g. if we do a frequent offline/online it will make
>> NR_FREE_PAGES  negative)
>>
>> This is so because, unset_migratetype_isolate() is called from
>> offlining  code (to set the migrate type of off lined pages again back
>> to MIGRATE_MOVABLE)
>> after the pages have been off lined and removed from the buddy list.
>> Since the pages for which unset_migratetype_isolate() is called are
>> not buddy pages so move_freepages_block() does not move any page, and
>> thus introducing a permanent inconsistency.
> 
> Good point. Negative NR_FREE_PAGES is caused by double counting by my patch and __offline_isolated_pages.
> I think at first MIGRATE_ISOLATE type freed page shouldn't account as free page.
> 
>>
>>> and it could make __zone_watermark_ok confuse so we might need to fix move_freepages_block itself to reflect
>>> free_area[order].nr_free exactly.
>>>
>>> Any thought?
>>
>> As for fixing move_freepages_block(), At least for memory hot plug,
>> the pages stay in MIGRATE_ISOLATE list only for duration
>> offline_pages() function,
>> I mean only temporarily. Since fixing move_freepages_block() for will
>> introduce some overhead, So I am not very sure whether that overhead
>> is justified
>> for a temporary condition. What do you think?
> 
> Yes. I don't like hurt fast path, either.
> How about this? (Passed just compile test :(  )
> The patch's goal is to NOT increase nr_free and NR_FREE_PAGES about freed page into MIGRATE_ISOLATED.
> 
> This patch hurts high order page free path but I think it's not critical because higher order allocation
> is rare than order-0 allocation and we already have done same thing on free_hot_cold_page on order-0 free path
> which is more hot.

Can't we change zone_water_mark_ok_safe() instead of page allocator? memory hotplug is really rare event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
