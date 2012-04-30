Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id CC43C6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 22:44:50 -0400 (EDT)
Message-ID: <4F9DFC9F.8090304@kernel.org>
Date: Mon, 30 Apr 2012 11:44:47 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type pageblocks
References: <201204261015.54449.b.zolnierkie@samsung.com> <20120426143620.GF15299@suse.de> <4F996F8B.1020207@redhat.com> <20120426164713.GG15299@suse.de> <4F99EF22.8070600@kernel.org> <20120427095608.GI15299@suse.de>
In-Reply-To: <20120427095608.GI15299@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 04/27/2012 06:56 PM, Mel Gorman wrote:

> On Fri, Apr 27, 2012 at 09:58:10AM +0900, Minchan Kim wrote:
>> On 04/27/2012 01:47 AM, Mel Gorman wrote:
>>
>>> On Thu, Apr 26, 2012 at 11:53:47AM -0400, Rik van Riel wrote:
>>>> On 04/26/2012 10:36 AM, Mel Gorman wrote:
>>>>
>>>>> Hmm, at what point does COMPACT_ASYNC_FULL get used? I see it gets
>>>>> used for the proc interface but it's not used via the page allocator at
>>>>> all.
>>>>
>>>> He is using COMPACT_SYNC for the proc interface, and
>>>> COMPACT_ASYNC_FULL from kswapd.
>>>>
>>>
>>> Ah, yes, of course. My bad.
>>>
>>> Even that is not particularly satisfactory though as it's depending on
>>> kswapd to do the work so it's a bit of a race to see if kswapd completes
>>> the job before the page allocator needs it.
>>
>>
>> It was a direction by my review.
> 
> Ah.
> 
>> In my point, I don't want to add more latency in direct reclaim async path if we can
>> although reclaim is already slow path.
>>
> 
> Your statement was
> 
>    Direct reclaim latency is critical on latency sensitive applications(of
>    course, you can argue it's already very slow once we reach this path,
>    but at least, let's not increase more overhead if we can) so I think
>    it would be better to use ASYNC_PARTIAL.  If we fail to allocate in
>    this phase, we set it with COMPACTION_SYNC in next phase, below code.
> 
> If a path is latency sensitive they have already lost if they are in this
> path. They have entered compaction and may enter direct reclaim shortly
> so latency is bad at this point. If the application is latency sensitive
> they probably should disable THP to avoid any spikes due to THP allocation.


Only THP isn't latency factor.
In case of ARM, we allocates 4-pages(ie, order=2) for pgd.
It means it can affect fork latency.

> 
> So I still maintain that the page allocator should not be depending on
> kswapd to do the work for it. If the caller wants high-order pages, it
> must be prepared to pay the cost of allocation.


I think it would be better if kswapd helps us.

> 
>> If async direct reclaim fails to compact memory with COMPACT_ASYNC_PARTIAL,
>> it ends up trying to compact memory with COMPACT_SYNC, again so it would
>> be no problem to allocate big order page and it's as-it-is approach by
>> async and sync mode.
>>
> 
> Is a compromise whereby a second pass consider only MIGRATE_UNMOVABLE
> pageblocks for rescus and migration targets acceptable? It would be nicer
> again if try_to_compact_pages() still accepted a "sync" parameter and would
> decide itself if a COMPACT_ASYNC_FULL pass was necessary when sync==false.


Looks good to me. 

> 
>> While latency is important in direct reclaim, kswapd isn't.
> 
> That does not mean we should tie up kswapd in compaction.c for longer
> than is necessary. It should be getting out of compaction ASAP in case
> reclaim is necessary.


Why do you think compaction and reclaim by separate?
If kswapd starts compaction, it means someone in direct reclaim path request
to kswapd to get a big order page. So I think compaction is a part of reclaim.
In this case, compaction should be necessary.

> 
>> So I think using COMPACT_ASYNC_FULL in kswapd makes sense.
>>
> 
> I'm not convinced but am not willing to push on it either. I do think
> that the caller of the page allocator does have to use
> COMPACT_ASYNC_FULL though and cannot be depending on kswapd to do the
> work.


I agree your second stage reclaiming in direct reclaim.
1. ASYNC-MOVABLE only
2. ASYNC-UNMOVABLE only
3. SYNC

Another reason we should check unmovable page block in kswapd is that we should consider
atomic allocation where is only place kswapd helps us.
I hope that reason would convince you.

> 
>>> <SNIP>
>>>
>>> This goes back to the same problem of we do not know how many
>>> MIGRATE_UNMOVABLE pageblocks are going to be encountered in advance However,
>>> I see your point.
>>>
>>> Instead of COMPACT_ASYNC_PARTIAL and COMPACT_ASYNC_FULL should we have
>>> COMPACT_ASYNC_MOVABLE and COMPACT_ASYNC_UNMOVABLE? The first pass from
>>> the page allocator (COMPACT_ASYNC_MOVABLE) would only consider MOVABLE
>>> blocks as migration targets. The second pass (COMPACT_ASYNC_UNMOVABLE)
>>> would examine UNMOVABLE blocks, rescue them and use what blocks it
>>> rescues as migration targets. The third pass (COMPACT_SYNC) would work
>>
>>
>> It does make sense.
>>
>>> as it does currently. kswapd would only ever use COMPACT_ASYNC_MOVABLE.
>>
>> I don't get it. Why do kswapd use only COMPACT_ASYNC_MOVALBE?
> 
> Because kswapds primary responsibility is reclaim, not compaction.


Again, I think compaction is a part of reclaim.

> 
>> As I mentioned, latency isn't important in kswapd so I think kswapd always
>> rescur unmovable block would help direct reclaim's first path(COMPACT_ASYNC
>> _MOVABLE)'s success rate.
>>
> 
> Latency for kswapd can be important if processes are entering direct
> reclaim because kswapd was running compaction instead of reclaim. The
> cost is indirect and difficult to detect which is why I would prefer
> kswapds use of compaction was as fast as possible.
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
