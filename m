Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9C4C6B0261
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 03:42:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so8140227wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:42:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si18478472wmi.136.2016.07.19.00.42.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 00:42:43 -0700 (PDT)
Subject: Re: [PATCH v3 12/17] mm, compaction: more reliably increase direct
 compaction priority
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-13-vbabka@suse.cz>
 <20160706053954.GE23627@js1304-P5Q-DELUXE>
 <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
 <20160718044112.GA9460@js1304-P5Q-DELUXE>
 <f5e07f1d-df29-24fb-a49d-9d436ad9b928@suse.cz>
 <20160719045330.GA17479@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b69264a4-030b-d7e4-7ae4-00092a012129@suse.cz>
Date: Tue, 19 Jul 2016 09:42:39 +0200
MIME-Version: 1.0
In-Reply-To: <20160719045330.GA17479@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/19/2016 06:53 AM, Joonsoo Kim wrote:
> On Mon, Jul 18, 2016 at 02:21:02PM +0200, Vlastimil Babka wrote:
>> On 07/18/2016 06:41 AM, Joonsoo Kim wrote:
>>> On Fri, Jul 15, 2016 at 03:37:52PM +0200, Vlastimil Babka wrote:
>>>> On 07/06/2016 07:39 AM, Joonsoo Kim wrote:
>>>>> On Fri, Jun 24, 2016 at 11:54:32AM +0200, Vlastimil Babka
>>>>> wrote:
>>>>>> During reclaim/compaction loop, compaction priority can be
>>>>>> increased by the should_compact_retry() function, but the
>>>>>> current code is not optimal. Priority is only increased
>>>>>> when compaction_failed() is true, which means that
>>>>>> compaction has scanned the whole zone. This may not happen
>>>>>> even after multiple attempts with the lower priority due to
>>>>>> parallel activity, so we might needlessly struggle on the
>>>>>> lower priority and possibly run out of compaction retry 
>>>>>> attempts in the process.
>>>>>> 
>>>>>> We can remove these corner cases by increasing compaction
>>>>>> priority regardless of compaction_failed(). Examining
>>>>>> further the compaction result can be postponed only after
>>>>>> reaching the highest priority. This is a simple solution 
>>>>>> and we don't need to worry about reaching the highest
>>>>>> priority "too soon" here, because hen
>>>>>> should_compact_retry() is called it means that the system
>>>>>> is already struggling and the allocation is supposed to
>>>>>> either try as hard as possible, or it cannot fail at all.
>>>>>> There's not much point staying at lower priorities with
>>>>>> heuristics that may result in only partial compaction. Also
>>>>>> we now count compaction retries only after reaching the
>>>>>> highest priority.
>>>>> 
>>>>> I'm not sure that this patch is safe. Deferring and skip-bit
>>>>> in compaction is highly related to reclaim/compaction. Just
>>>>> ignoring them and (almost) unconditionally increasing
>>>>> compaction priority will result in less reclaim and less
>>>>> success rate on compaction.
>>>> 
>>>> I don't see why less reclaim? Reclaim is always attempted
>>>> before compaction and compaction priority doesn't affect it.
>>>> And as long as reclaim wants to retry, should_compact_retry()
>>>> isn't even called, so the priority stays. I wanted to change
>>>> that in v1, but Michal suggested I shouldn't.
>>> 
>>> I assume the situation that there is no !costly highorder
>>> freepage because of fragmentation. In this case,
>>> should_reclaim_retry() would return false since watermark cannot
>>> be met due to absence of high order freepage. Now, please see
>>> should_compact_retry() with assumption that there are enough
>>> order-0 free pages. Reclaim/compaction is only retried two times
>>> (SYNC_LIGHT and SYNC_FULL) with your patchset since 
>>> compaction_withdrawn() return false with enough freepages and 
>>> !COMPACT_SKIPPED.
>>> 
>>> But, before your patchset, COMPACT_PARTIAL_SKIPPED and 
>>> COMPACT_DEFERRED is considered as withdrawn so will retry 
>>> reclaim/compaction more times.
>> 
>> Perhaps, but it wouldn't guarantee to reach the highest priority.
> 
> Yes.

Since this is my greatest concern here, would the alternative patch at
the end of the mail work for you? Trying your test would be nice too,
but can also wait until I repost whole series (the missed watermark
checks you spotted in patch 13 could also play a role there).

> 
>> order-3 allocation just to avoid OOM, ignoring that the system
>> might be thrashing heavily? Previously it also wasn't guaranteed
>> to reclaim everything, but what is the optimal number of retries?
> 
> So, you say the similar logic in other thread we talked yesterday. 
> The fact that it wasn't guaranteed to reclaim every thing before 
> doesn't mean that we could relax guarantee more.
> 
> I'm not sure below is relevant to this series but just note.
> 
> I don't know the optimal number of retries. We are in a way to find 
> it and I hope this discussion would help. I don't think that we can 
> judge the point properly with simple checking on stat information at
> some moment. It only has too limited knowledge about the system so it
> would wrongly advise us to invoke OOM prematurely.
> 
> I think that using compaction result isn't a good way to determine
> if further reclaim/compaction is useless or not because compaction
> result can vary with further reclaim/compaction itself.

If we scan whole zone ignoring all the heuristics, and still fail, I
think it's pretty reliable (ignoring parallel activity, because then we
can indeed never be sure).

> If we want to check more accurately if compaction is really
> impossible, scanning whole range and checking arrangement of freepage
> and lru(movable) pages would more help.

But the whole zone compaction just did exactly this and failed? Sure, we
might have missed something due to the way compaction scanners meet
around the middle of zone, but that's a reason to improve the algorithm,
not to attempt more reclaim based on checks that duplicate the scanning
work.

> Although there is some possibility to fail the compaction even if 
> this check is passed, it would give us more information about the 
> system state and we would invoke OOM less prematurely. In this case 
> that theoretically compaction success is possible, we could keep 
> reclaim/compaction more times even if full compaction fails because 
> we have a hope that more freepages would give us more compaction 
> success probability.

They can only give us more probability because of a) more resilience
against parallel memory allocations getting us below low order-0
watermark during our compaction and b) we increase chances of migrate
scanner reaching higher pfn in the zone, if there are unmovable
fragmentations in the lower pfns. Both are problems to potentially
solve, and I think further tuning the decisions for reclaim/compaction
retry is just a bad workaround, and definitely not something I would
like to do in this series. So I'll try to avoid decreasing number of
retries in the patch below, but not more:

-----8<-----
