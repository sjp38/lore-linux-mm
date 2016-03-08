Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ACB266B0255
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:52:19 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so19836141wml.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:52:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j143si3390710wmd.65.2016.03.08.01.52.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 01:52:18 -0800 (PST)
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz> <56DE9A68.2010301@suse.cz>
 <20160308094612.GB13542@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEA0CF.2070902@suse.cz>
Date: Tue, 8 Mar 2016 10:52:15 +0100
MIME-Version: 1.0
In-Reply-To: <20160308094612.GB13542@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On 03/08/2016 10:46 AM, Michal Hocko wrote:
> On Tue 08-03-16 10:24:56, Vlastimil Babka wrote:
> [...]
>>> @@ -2819,28 +2819,22 @@ static struct page *
>>>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>>>  		int alloc_flags, const struct alloc_context *ac,
>>>  		enum migrate_mode mode, int *contended_compaction,
>>> -		bool *deferred_compaction)
>>> +		unsigned long *compact_result)
>>>  {
>>> -	unsigned long compact_result;
>>>  	struct page *page;
>>>  
>>> -	if (!order)
>>> +	if (!order) {
>>> +		*compact_result = COMPACT_NONE;
>>>  		return NULL;
>>> +	}
>>>  
>>>  	current->flags |= PF_MEMALLOC;
>>> -	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>>> +	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>>>  						mode, contended_compaction);
>>>  	current->flags &= ~PF_MEMALLOC;
>>>  
>>> -	switch (compact_result) {
>>> -	case COMPACT_DEFERRED:
>>> -		*deferred_compaction = true;
>>> -		/* fall-through */
>>> -	case COMPACT_SKIPPED:
>>> +	if (*compact_result <= COMPACT_SKIPPED)
>>
>> COMPACT_NONE is -1 and compact_result is unsigned long, so this won't
>> work as expected.
> 
> Well, COMPACT_NONE is documented as /* compaction disabled */ so we
> should never get it from try_to_compact_pages.

Right.

>
> [...]
>>> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>  				 did_some_progress > 0, no_progress_loops))
>>>  		goto retry;
>>>  
>>> +	/*
>>> +	 * !costly allocations are really important and we have to make sure
>>> +	 * the compaction wasn't deferred or didn't bail out early due to locks
>>> +	 * contention before we go OOM.
>>> +	 */
>>> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
>>> +		if (compact_result <= COMPACT_CONTINUE)
>>
>> Same here.
>> I was going to say that this didn't have effect on Sergey's test, but
>> turns out it did :)
> 
> This should work as expected because compact_result is unsigned long
> and so this is the unsigned arithmetic. I can make
> #define COMPACT_NONE            -1UL
> 
> to make the intention more obvious if you prefer, though.

Well, what wasn't obvious to me is actually that here (unlike in the
test above) it was actually intended that COMPACT_NONE doesn't result in
a retry. But it makes sense, otherwise we would retry endlessly if
reclaim couldn't form a higher-order page, right.

> Thanks for the review.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
