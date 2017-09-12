Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED5E66B0322
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 03:15:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so9882160pga.6
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 00:15:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10si7217854pgs.609.2017.09.12.00.15.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 00:15:14 -0700 (PDT)
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about
 stalls
References: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com>
 <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
 <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d677d23a-9b1d-e3fd-9ff2-bac8cccfb200@suse.cz>
Date: Tue, 12 Sep 2017 09:14:05 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2017 01:36 AM, Mikulas Patocka wrote:
> 
> 
> On Mon, 11 Sep 2017, Michal Hocko wrote:
> 
>> On Mon 11-09-17 02:52:53, Mikulas Patocka wrote:
>>
>> This patch hasn't introduced this behavior. It deliberately skipped
>> warning on __GFP_NOWARN. This has been introduced later by 822519634142
>> ("mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"). I
>> disagreed [1] but overall consensus was that such a warning won't be
>> harmful. Could you be more specific why do you consider it wrong,
>> please?
> 
> I consider the warning wrong, because it warns when nothing goes wrong. 
> I've got 7 these warnings for 4 weeks of uptime. The warnings typically 
> happen when I run some compilation.
> 
> A process with low priority is expected to be running slowly when there's 
> some high-priority process, so there's no need to warn that the 
> low-priority process runs slowly.
> 
> What else can be done to avoid the warning? Skip the warning if the 
> process has lower priority?

We would have to consider (instead of jiffies) the time the process was
either running, or waiting on something that's related to memory
allocation/reclaim (page lock etc.). I.e. deduct the time the process
was runable but there was no available cpu. I expect however that such
level of detail wouldn't be feasible here, though?

Vlastimil

> Mikulas
> 
>> [1] http://lkml.kernel.org/r/20170125184548.GB32041@dhcp22.suse.cz
>>
>>>
>>> ---
>>>  mm/page_alloc.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> Index: linux-2.6/mm/page_alloc.c
>>> ===================================================================
>>> --- linux-2.6.orig/mm/page_alloc.c
>>> +++ linux-2.6/mm/page_alloc.c
>>> @@ -3923,7 +3923,7 @@ retry:
>>>  
>>>  	/* Make sure we know about allocations which stall for too long */
>>>  	if (time_after(jiffies, alloc_start + stall_timeout)) {
>>> -		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
>>> +		warn_alloc(gfp_mask, ac->nodemask,
>>>  			"page allocation stalls for %ums, order:%u",
>>>  			jiffies_to_msecs(jiffies-alloc_start), order);
>>>  		stall_timeout += 10 * HZ;
>>
>> -- 
>> Michal Hocko
>> SUSE Labs
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
