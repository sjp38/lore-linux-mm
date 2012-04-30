Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B6D516B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:55:11 -0400 (EDT)
Message-ID: <4F9E536D.8070508@kernel.org>
Date: Mon, 30 Apr 2012 17:55:09 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type pageblocks
References: <201204261015.54449.b.zolnierkie@samsung.com> <20120426143620.GF15299@suse.de> <4F996F8B.1020207@redhat.com> <20120426164713.GG15299@suse.de> <4F99EF22.8070600@kernel.org> <20120427095608.GI15299@suse.de> <4F9DFC9F.8090304@kernel.org> <20120430083152.GK9226@suse.de>
In-Reply-To: <20120430083152.GK9226@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 04/30/2012 05:31 PM, Mel Gorman wrote:

> On Mon, Apr 30, 2012 at 11:44:47AM +0900, Minchan Kim wrote:
>>> Your statement was
>>>
>>>    Direct reclaim latency is critical on latency sensitive applications(of
>>>    course, you can argue it's already very slow once we reach this path,
>>>    but at least, let's not increase more overhead if we can) so I think
>>>    it would be better to use ASYNC_PARTIAL.  If we fail to allocate in
>>>    this phase, we set it with COMPACTION_SYNC in next phase, below code.
>>>
>>> If a path is latency sensitive they have already lost if they are in this
>>> path. They have entered compaction and may enter direct reclaim shortly
>>> so latency is bad at this point. If the application is latency sensitive
>>> they probably should disable THP to avoid any spikes due to THP allocation.
>>
>>
>> Only THP isn't latency factor.
>> In case of ARM, we allocates 4-pages(ie, order=2) for pgd.
>> It means it can affect fork latency.
>>
> 
> order-2 is below PAGE_ALLOC_COSTLY_ORDER where the expectation is that
> reclaim on its own should be able to free the necessary pages. That aside,
> part of what you are proposing is that the page allocator not use ASYNC_FULL
> and instead depend on kswapd to compact memory out of line.  That means
> the caller of fork() either gets to do reclaim pages or loop until kswapd
> does the compaction. That does not make sense from a latency perspective.
> 
>>> So I still maintain that the page allocator should not be depending on
>>> kswapd to do the work for it. If the caller wants high-order pages, it
>>> must be prepared to pay the cost of allocation.
>>
>>
>> I think it would be better if kswapd helps us.
>>
> 
> Help maybe, but you are proposing the caller of fork() does not do the work
> necessary to allocate the order-2 page (using ASYNC_PARTIAL, ASYNC_FULL
> and SYNC) and instead depends on kswapd to do it.


Hmm, there was misunderstanding.
I agreed your page allocator suggestion after you suggest AYNC_PARTIAL, ASYNC_FULL and sync.
The concern was only kswapd. :)

> 
>>>> If async direct reclaim fails to compact memory with COMPACT_ASYNC_PARTIAL,
>>>> it ends up trying to compact memory with COMPACT_SYNC, again so it would
>>>> be no problem to allocate big order page and it's as-it-is approach by
>>>> async and sync mode.
>>>>
>>>
>>> Is a compromise whereby a second pass consider only MIGRATE_UNMOVABLE
>>> pageblocks for rescus and migration targets acceptable? It would be nicer
>>> again if try_to_compact_pages() still accepted a "sync" parameter and would
>>> decide itself if a COMPACT_ASYNC_FULL pass was necessary when sync==false.
>>
>>
>> Looks good to me. 
>>
> 
> Ok.
> 
>>>
>>>> While latency is important in direct reclaim, kswapd isn't.
>>>
>>> That does not mean we should tie up kswapd in compaction.c for longer
>>> than is necessary. It should be getting out of compaction ASAP in case
>>> reclaim is necessary.
>>
>> Why do you think compaction and reclaim by separate?
>> If kswapd starts compaction, it means someone in direct reclaim path request
>> to kswapd to get a big order page.
> 
> It's not all about high order pages. If kswapd is running compaction and a
> caller needs an order-0 page it may enter direct reclaim instead which is
> worse from a latency perspective. The possibility for this situation should
> be limited as much as possible without a very strong compelling reason.I
> do not think there is a compelling reason right now to take the risk.



Hmm, I understand your point.
Suggestion:
Couldn't we can coded to give up kswapd's compaction 
immediately if another task requests order-0 in direct reclaim path?

> 
>> So I think compaction is a part of reclaim.
>> In this case, compaction should be necessary.
>>
>>>
>>>> So I think using COMPACT_ASYNC_FULL in kswapd makes sense.
>>>>
>>>
>>> I'm not convinced but am not willing to push on it either. I do think
>>> that the caller of the page allocator does have to use
>>> COMPACT_ASYNC_FULL though and cannot be depending on kswapd to do the
>>> work.
>>
>> I agree your second stage reclaiming in direct reclaim.
>> 1. ASYNC-MOVABLE only
>> 2. ASYNC-UNMOVABLE only
>> 3. SYNC
>>
> 
> Ok, then can we at least start with that? Specifically that the
> page allocator continue to pass in sync to try_to_compact_pages() and
> try_to_compact_pages() doing compaction first as ASYNC_PARTIAL and then
> deciding whether it should do a second pass as ASYNC_FULL?


Yeb. We can proceed second pass once we found many unmovalbe page blocks
during first ASYNC_PARTIAL compaction.

> 
>> Another reason we should check unmovable page block in kswapd is that we should consider
>> atomic allocation where is only place kswapd helps us.
>> I hope that reason would convince you.
>>
> 
> It doesn't really. High-order atomic allocations are something that should
> be avoided as much as possible and the longer kswapd runs compaction the
> greater the risk that processes stall in direct reclaim unnecessarily.
> I know the current logic of kswapd using compaction.c is meant to help high
> order atomics but that does not mean I think kswapd should spend even more
> time in compaction.c without a compelling use case.
> 


My suggestion may mitigate the problem.

> At the very least, make kswapd using ASYNC_FULL a separate patch. I will
> not ACK it without compelling data backing it up but patch 1 would be
> there to handle Bartlomiej's adverse workload.
> 


If I have a time, I will try it but now I don't have a time to make such data.
So let's keep remember this discussion for trial later if we look the problem.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
