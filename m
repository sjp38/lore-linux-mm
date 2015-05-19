Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 65BF46B00C6
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:12:39 -0400 (EDT)
Received: by lagv1 with SMTP id v1so29401530lag.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:12:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si24019123wjr.172.2015.05.19.08.12.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 08:12:37 -0700 (PDT)
Message-ID: <555B52E3.3010504@suse.cz>
Date: Tue, 19 May 2015 17:12:35 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
References: <20150519104057.GC2462@suse.de> <20150519141807.GA9788@cmpxchg.org> <20150519145340.GI6203@dhcp22.suse.cz>
In-Reply-To: <20150519145340.GI6203@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On 05/19/2015 04:53 PM, Michal Hocko wrote:
> On Tue 19-05-15 10:18:07, Johannes Weiner wrote:
>> CC'ing Tejun and cgroups for the generic cgroup interface part
>>
>> On Tue, May 19, 2015 at 11:40:57AM +0100, Mel Gorman wrote:
> [...]
>>> /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
>>>    mem_cgroup_try_charge                                                        2.950%   175781
>>
>> Ouch.  Do you have a way to get the per-instruction breakdown of this?
>> This function really isn't doing much.  I'll try to reproduce it here
>> too, I haven't seen such high costs with pft in the past.
>>
>>>    try_charge                                                                   0.150%     8928
>>>    get_mem_cgroup_from_mm                                                       0.121%     7184
>
> Indeed! try_charge + get_mem_cgroup_from_mm which I would expect to be
> the biggest consumers here are below 10% of the mem_cgroup_try_charge.

Note that they don't explain 10% of the mem_cgroup_try_charge. They 
*add* their own overhead to the overhead of mem_cgroup_try_charge 
itself. Which might be what you meant but I wasn't sure.

> Other than that the function doesn't do much else than some flags
> queries and css_put...
>
> Do you have the full trace?
> Sorry for a stupid question but do inlines
> from other header files get accounted to memcontrol.c?

Yes, perf doesn't know about them so it's accounted to function where 
the code physically is.

>
> [...]
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
