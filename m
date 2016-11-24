Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B63626B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:41:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so4900640wjc.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 23:41:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qi6si35464393wjb.175.2016.11.23.23.41.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 23:41:33 -0800 (PST)
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
 <87b89181-a141-611d-c772-c5e483aa4f49@suse.cz>
 <20161123123532.GJ2864@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <75ad0d8e-3dff-8893-eb2d-5f3817d91d83@suse.cz>
Date: Thu, 24 Nov 2016 08:41:30 +0100
MIME-Version: 1.0
In-Reply-To: <20161123123532.GJ2864@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 11/23/2016 01:35 PM, Michal Hocko wrote:
> On Wed 23-11-16 13:19:20, Vlastimil Babka wrote:
>> This makes some sense to me, but there might be unpleasant consequences,
>> e.g. due to allowing costly allocations without reserves.
>
> I am not sure I understand. Did you mean with reserves? Anyway, my code

Yeah, with reserves/without watermarks checks. Sorry.

> inspection shown that we are not really doing GFP_NOFAIL for costly
> orders. This might change in the future but even if we do that then this
> shouldn't add a risk of the reserves depletion, right?

Well it's true that it will be unlikely that high-order pages will exist 
at min watermark, but if they do, high-order page depletes more than 
order-0. Anyway we have the WARN_ON_ONCE on cosly nofail allocations, so 
at least this won't happen silently...

>> I guess only testing will show...
>>
>> Also some comments below.
> [...]
>>>  static inline struct page *
>>> +__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
>>> +						const struct alloc_context *ac)
>>> +{
>>> +	struct page *page;
>>> +
>>> +	page = get_page_from_freelist(gfp_mask, order,
>>> +			ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
>>> +	/*
>>> +	 * fallback to ignore cpuset restriction if our nodes
>>> +	 * are depleted
>>> +	 */
>>> +	if (!page)
>>> +		page = get_page_from_freelist(gfp_mask, order,
>>> +				ALLOC_NO_WATERMARKS, ac);
>>
>> Is this enough? Look at what __alloc_pages_slowpath() does since
>> e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the
>> context can ignore memory policies").
>
> this is a one time attempt to do the nowmark allocation. If we need to
> do the recalculation then this should happen in the next round. Or am I
> missing your question?

The next round no-watermarks allocation attempt in 
__alloc_pages_slowpath() uses different criteria than the new 
__alloc_pages_nowmark() callers. And it would be nicer to unify this as 
well, if possible.

>
>>
>> ...
>>
>>> -	}
>>>  	/* Exhausted what can be done so it's blamo time */
>>> -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>>> +	if (out_of_memory(&oc)) {
>>
>> This removes the warning, but also the check for __GFP_NOFAIL itself. Was it
>> what you wanted?
>
> The point of the check was to keep looping for __GFP_NOFAIL requests
> even when the OOM killer is disabled (out_of_memory returns false). We
> are accomplishing that by
>>
>>>  		*did_some_progress = 1;
> 		^^^^ this

But oom disabled means that this line is not reached?

> it is true we will not have the warning but I am not really sure we care
> all that much. In any case it wouldn't be all that hard to check for oom
> killer disabled and warn on in the allocator slow path.
>
> thanks for having a look!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
