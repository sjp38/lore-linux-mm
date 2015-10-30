Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DD39A82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:42:06 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so63811285pad.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 02:42:06 -0700 (PDT)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id ra4si9669835pab.126.2015.10.30.02.42.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 02:42:06 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 5F1FCAC038F
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 18:42:00 +0900 (JST)
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
 <5632FEEF.2050709@jp.fujitsu.com> <20151030082323.GB18429@dhcp22.suse.cz>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56333B4A.4030602@jp.fujitsu.com>
Date: Fri, 30 Oct 2015 18:41:30 +0900
MIME-Version: 1.0
In-Reply-To: <20151030082323.GB18429@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On 2015/10/30 17:23, Michal Hocko wrote:
> On Fri 30-10-15 14:23:59, KAMEZAWA Hiroyuki wrote:
>> On 2015/10/30 0:17, mhocko@kernel.org wrote:
> [...]
>>> @@ -3135,13 +3145,56 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>    	if (gfp_mask & __GFP_NORETRY)
>>>    		goto noretry;
>>>
>>> -	/* Keep reclaiming pages as long as there is reasonable progress */
>>> +	/*
>>> +	 * Do not retry high order allocations unless they are __GFP_REPEAT
>>> +	 * and even then do not retry endlessly.
>>> +	 */
>>>    	pages_reclaimed += did_some_progress;
>>> -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
>>> -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
>>> -		/* Wait for some write requests to complete then retry */
>>> -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
>>> -		goto retry;
>>> +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
>>> +		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
>>> +			goto noretry;
>>> +
>>> +		if (did_some_progress)
>>> +			goto retry;
>>
>> why directly retry here ?
>
> Because I wanted to preserve the previous logic for GFP_REPEAT as much
> as possible here and do an incremental change in the later patch.
>

I see.

> [...]
>
>>> @@ -3150,8 +3203,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>    		goto got_pg;
>>>
>>>    	/* Retry as long as the OOM killer is making progress */
>>> -	if (did_some_progress)
>>> +	if (did_some_progress) {
>>> +		stall_backoff = 0;
>>>    		goto retry;
>>> +	}
>>
>> Umm ? I'm sorry that I didn't notice page allocation may fail even
>> if order < PAGE_ALLOC_COSTLY_ORDER.  I thought old logic ignores
>> did_some_progress. It seems a big change.
>
> __alloc_pages_may_oom will set did_some_progress
>
>> So, now, 0-order page allocation may fail in a OOM situation ?
>
> No they don't normally and this patch doesn't change the logic here.
>

I understand your patch doesn't change the behavior.
Looking into __alloc_pages_may_oom(), *did_some_progress is finally set by

      if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
                 *did_some_progress = 1;

...depends on out_of_memory() return value.
Now, allocation may fail if oom-killer is disabled.... Isn't it complicated ?

Shouldn't we have

  if (order < PAGE_ALLOC_COSTLY_ORDER)
     goto retry;

here ?

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
