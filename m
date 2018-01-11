Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD5366B026C
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 10:23:53 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a9so2499626pgf.12
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:23:53 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10098.outbound.protection.outlook.com. [40.107.1.98])
        by mx.google.com with ESMTPS id p14si887348pli.680.2018.01.11.07.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 07:23:51 -0800 (PST)
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
 <20180111124629.GA1732@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ce885a69-67af-5f4c-1116-9f6803fb45ee@virtuozzo.com>
Date: Thu, 11 Jan 2018 18:23:57 +0300
MIME-Version: 1.0
In-Reply-To: <20180111124629.GA1732@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On 01/11/2018 03:46 PM, Michal Hocko wrote:
> On Thu 11-01-18 15:21:33, Andrey Ryabinin wrote:
>>
>>
>> On 01/11/2018 01:42 PM, Michal Hocko wrote:
>>> On Wed 10-01-18 15:43:17, Andrey Ryabinin wrote:
>>> [...]
>>>> @@ -2506,15 +2480,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>>>  		if (!ret)
>>>>  			break;
>>>>  
>>>> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
>>>> -
>>>> -		curusage = page_counter_read(counter);
>>>> -		/* Usage is reduced ? */
>>>> -		if (curusage >= oldusage)
>>>> -			retry_count--;
>>>> -		else
>>>> -			oldusage = curusage;
>>>> -	} while (retry_count);
>>>> +		usage = page_counter_read(counter);
>>>> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
>>>> +						GFP_KERNEL, !memsw)) {
>>>
>>> If the usage drops below limit in the meantime then you get underflow
>>> and reclaim the whole memcg. I do not think this is a good idea. This
>>> can also lead to over reclaim. Why don't you simply stick with the
>>> original SWAP_CLUSTER_MAX (aka 1 for try_to_free_mem_cgroup_pages)?
>>>
>>
>> Because, if new limit is gigabytes bellow the current usage, retrying to set
>> new limit after reclaiming only 32 pages seems unreasonable.
> 
> Who would do insanity like that?
> 

What's insane about that?


>> @@ -2487,8 +2487,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>  		if (!ret)
>>  			break;
>>  
>> -		usage = page_counter_read(counter);
>> -		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
>> +		nr_pages = max_t(long, 1, page_counter_read(counter) - limit);
>> +		if (!try_to_free_mem_cgroup_pages(memcg, nr_pages,
>>  						GFP_KERNEL, !memsw)) {
>>  			ret = -EBUSY;
>>  			break;
> 
> How does this address the over reclaim concern?
 
It protects from over reclaim due to underflow.


Assuming that yours over reclaim concern is situation like this:


         Task A                                            Task  B
                                 
mem_cgroup_resize_limit(new_limit):

...

   do {
...
        try_to_free_mem_cgroup_pages():
                //start reclaim

                                                         free memory => drop down usage below new_limit
                //end reclaim
...
    } while(true)


than I don't understand why is this a problem at all, and how try_to_free_mem_cgroup_pages(1) supposed to solve it.

First of all, this is highly unlikely situation. Decreasing limit is not something that happens very often.
I imagine that freeing large amounts of memory is also not very frequent operation, workloads mostly consume/use
resources. So this is something that should almost never happen, and when it does, who and how would notice?
I mean, that 'problem' has no user-visible effect.


Secondly, how try_to_free_mem_cgroup_pages(1) can help here? Task B could simply free() right after the limit
is successfully set. So it suddenly doesn't matter whether the memory was reclaimed by baby steps or in one go,
we 'over reclaimed' memory that B freed. Basically, your suggestion sounds like "lets slowly reclaim with baby
steps, and check the limit after each step in hope that tasks in cgroup did some of our job and freed some memory".


So, the only way to completely avoid such over reclaim would be to do not reclaim at all, and simply wait until the memory
usage goes down by itself. But we are not that crazy to do this, right?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
