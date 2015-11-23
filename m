Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7B56B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:43:44 -0500 (EST)
Received: by wmvv187 with SMTP id v187so151647535wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:43:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si17973821wmg.115.2015.11.23.01.43.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 01:43:43 -0800 (PST)
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz> <20151123092925.GB21050@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5652DFCE.3010201@suse.cz>
Date: Mon, 23 Nov 2015 10:43:42 +0100
MIME-Version: 1.0
In-Reply-To: <20151123092925.GB21050@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 11/23/2015 10:29 AM, Michal Hocko wrote:
> On Sun 22-11-15 13:55:31, Vlastimil Babka wrote:
>> On 11.11.2015 14:48, mhocko@kernel.org wrote:
>>>   mm/page_alloc.c | 10 +++++++++-
>>>   1 file changed, 9 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 8034909faad2..d30bce9d7ac8 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>>>   			goto out;
>>>   	}
>>>   	/* Exhausted what can be done so it's blamo time */
>>> -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
>>> +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>>>   		*did_some_progress = 1;
>>> +
>>> +		if (gfp_mask & __GFP_NOFAIL) {
>>> +			page = get_page_from_freelist(gfp_mask, order,
>>> +					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
>>> +			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
>>> +				    " Consider increasing min_free_kbytes.\n");
>>
>> It seems redundant to me to keep the WARN_ON_ONCE also above in the if () part?
>
> They are warning about two different things. The first one catches a
> buggy code which uses __GFP_NOFAIL from oom disabled context while the

Ah, I see, I misinterpreted what the return values of out_of_memory() 
mean. But now that I look at its code, it seems to only return false 
when oom_killer_disabled is set to true. Which is a global thing and 
nothing to do with the context of the __GFP_NOFAIL allocation?

> second one tries to help the administrator with a hint that memory
> reserves are too small.
>
>> Also s/gfp_nofail/GFP_NOFAIL/ for consistency?
>
> Fair enough, changed.
>
>> Hm and probably out of scope of your patch, but I understand the WARN_ONCE
>> (WARN_ON_ONCE) to be _ONCE just to prevent a flood from a single task looping
>> here. But for distinct tasks and potentially far away in time, wouldn't we want
>> to see all the warnings? Would that be feasible to implement?
>
> I was thinking about that as well some time ago but it was quite
> hard to find a good enough API to tell when to warn again. The first
> WARN_ON_ONCE should trigger for all different _code paths_ no matter
> how frequently they appear to catch all the buggy callers. The second
> one would benefit from a new warning after min_free_kbytes was updated
> because it would tell the administrator that the last update was not
> sufficient for the workload.

Hm, what about adding a flag to the struct alloc_context, so that when 
the particular allocation attempt emits the warning, it sets a flag in 
the alloc_context so that it won't emit them again as long as it keeps 
looping and attempting oom. Other allocations will warn independently.

We could also print the same info as the "allocation failed" warnings 
do, since it's very similar, except we can't fail - but the admin/bug 
reporter should be interested in the same details as for an allocation 
failure that is allowed to fail. But it's also true that we have 
probably just printed the info during out_of_memory()... except when we 
skipped that for some reason?

>>
>>> +		}
>>> +	}
>>>   out:
>>>   	mutex_unlock(&oom_lock);
>>>   	return page;
>>>
>
> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
