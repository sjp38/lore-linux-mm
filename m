Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B351F6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:12:28 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p65so144878253wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:12:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si3117966wjw.45.2016.03.08.03.12.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 03:12:27 -0800 (PST)
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz> <56DE9A68.2010301@suse.cz>
 <20160308094612.GB13542@dhcp22.suse.cz> <56DEA0CF.2070902@suse.cz>
 <20160308101016.GC13542@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEB394.40602@suse.cz>
Date: Tue, 8 Mar 2016 12:12:20 +0100
MIME-Version: 1.0
In-Reply-To: <20160308101016.GC13542@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On 03/08/2016 11:10 AM, Michal Hocko wrote:
> On Tue 08-03-16 10:52:15, Vlastimil Babka wrote:
>> On 03/08/2016 10:46 AM, Michal Hocko wrote:
> [...]
>>>>> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>>>  				 did_some_progress > 0, no_progress_loops))
>>>>>  		goto retry;
>>>>>  
>>>>> +	/*
>>>>> +	 * !costly allocations are really important and we have to make sure
>>>>> +	 * the compaction wasn't deferred or didn't bail out early due to locks
>>>>> +	 * contention before we go OOM.
>>>>> +	 */
>>>>> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
>>>>> +		if (compact_result <= COMPACT_CONTINUE)
>>>>
>>>> Same here.
>>>> I was going to say that this didn't have effect on Sergey's test, but
>>>> turns out it did :)
>>>
>>> This should work as expected because compact_result is unsigned long
>>> and so this is the unsigned arithmetic. I can make
>>> #define COMPACT_NONE            -1UL
>>>
>>> to make the intention more obvious if you prefer, though.
>>
>> Well, what wasn't obvious to me is actually that here (unlike in the
>> test above) it was actually intended that COMPACT_NONE doesn't result in
>> a retry. But it makes sense, otherwise we would retry endlessly if
>> reclaim couldn't form a higher-order page, right.
> 
> Yeah, that was the whole point. An alternative would be moving the test
> into should_compact_retry(order, compact_result, contended_compaction)
> which would be CONFIG_COMPACTION specific so we can get rid of the
> COMPACT_NONE altogether. Something like the following. We would lose the
> always initialized compact_result but this would matter only for
> order==0 and we check for that. Even gcc doesn't complain.

Yeah I like this version better, you can add my Acked-By.

Thanks.

> A more important question is whether the criteria I have chosen are
> reasonable and reasonably independent on the particular implementation
> of the compaction. I still cannot convince myself about the convergence
> here. Is it possible that the compaction would keep returning 
> compact_result <= COMPACT_CONTINUE while not making any progress at all?

Theoretically, if reclaim/compaction suitability decisions and
allocation attempts didn't match the watermark checks, including the
alloc_flags and classzone_idx parameters. Possible scenarios:

- reclaim thinks compaction has enough to proceed, but compaction thinks
otherwise and returns COMPACT_SKIPPED
- compaction thinks it succeeded and returns COMPACT_PARTIAL, but
allocation attempt fails
- and perhaps some other combinations

> Sure we can see a case where somebody is stealing the compacted blocks
> but that is very same with the order-0 where parallel mem eaters will
> piggy back on the reclaimer and there is no upper boundary as well well.

Yep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
