Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F14276B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 16:59:51 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n2so3131086pgs.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 13:59:51 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00108.outbound.protection.outlook.com. [40.107.0.108])
        by mx.google.com with ESMTPS id 62si14594647pld.618.2018.01.11.13.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 13:59:50 -0800 (PST)
Subject: Re: [PATCH v4] mm/memcg: try harder to decrease
 [memory,memsw].limit_in_bytes
References: <20180109152622.31ca558acb0cc25a1b14f38c@linux-foundation.org>
 <20180110124317.28887-1-aryabinin@virtuozzo.com>
 <20180111104239.GZ1732@dhcp22.suse.cz>
 <4a8f667d-c2ae-e3df-00fd-edc01afe19e1@virtuozzo.com>
 <20180111124629.GA1732@dhcp22.suse.cz>
 <ce885a69-67af-5f4c-1116-9f6803fb45ee@virtuozzo.com>
 <20180111162947.GG1732@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <560a77b5-02d7-cbae-35f3-0b20a1c384c2@virtuozzo.com>
Date: Fri, 12 Jan 2018 00:59:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180111162947.GG1732@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

On 01/11/2018 07:29 PM, Michal Hocko wrote:
> On Thu 11-01-18 18:23:57, Andrey Ryabinin wrote:
>> On 01/11/2018 03:46 PM, Michal Hocko wrote:
>>> On Thu 11-01-18 15:21:33, Andrey Ryabinin wrote:
>>>>
>>>>
>>>> On 01/11/2018 01:42 PM, Michal Hocko wrote:
>>>>> On Wed 10-01-18 15:43:17, Andrey Ryabinin wrote:
>>>>> [...]
>>>>>> @@ -2506,15 +2480,13 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>>>>>  		if (!ret)
>>>>>>  			break;
>>>>>>  
>>>>>> -		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, !memsw);
>>>>>> -
>>>>>> -		curusage = page_counter_read(counter);
>>>>>> -		/* Usage is reduced ? */
>>>>>> -		if (curusage >= oldusage)
>>>>>> -			retry_count--;
>>>>>> -		else
>>>>>> -			oldusage = curusage;
>>>>>> -	} while (retry_count);
>>>>>> +		usage = page_counter_read(counter);
>>>>>> +		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
>>>>>> +						GFP_KERNEL, !memsw)) {
>>>>>
>>>>> If the usage drops below limit in the meantime then you get underflow
>>>>> and reclaim the whole memcg. I do not think this is a good idea. This
>>>>> can also lead to over reclaim. Why don't you simply stick with the
>>>>> original SWAP_CLUSTER_MAX (aka 1 for try_to_free_mem_cgroup_pages)?
>>>>>
>>>>
>>>> Because, if new limit is gigabytes bellow the current usage, retrying to set
>>>> new limit after reclaiming only 32 pages seems unreasonable.
>>>
>>> Who would do insanity like that?
>>>
>>
>> What's insane about that?
> 
> I haven't seen this being done in practice. Why would you want to
> reclaim GBs of memory from a cgroup? Anyway, if you believe this is
> really needed then simply do it in a separate patch.
>  

For the same reason as anyone would want to set memory limit on some job that generates
too much pressure and disrupts others. Whether this GBs or MBs is just a matter of scale.

More concrete example is workload that generates lots of page cache. Without limit (or with too high limit)
it wakes up kswapd which starts trashing all other cgroups. It's pretty bad for anon mostly cgroups
as we may constantly swap back and forth hot data.


>>>> @@ -2487,8 +2487,8 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>>>>  		if (!ret)
>>>>  			break;
>>>>  
>>>> -		usage = page_counter_read(counter);
>>>> -		if (!try_to_free_mem_cgroup_pages(memcg, usage - limit,
>>>> +		nr_pages = max_t(long, 1, page_counter_read(counter) - limit);
>>>> +		if (!try_to_free_mem_cgroup_pages(memcg, nr_pages,
>>>>  						GFP_KERNEL, !memsw)) {
>>>>  			ret = -EBUSY;
>>>>  			break;
>>>
>>> How does this address the over reclaim concern?
>>  
>> It protects from over reclaim due to underflow.
> 
> I do not think so. Consider that this reclaim races with other
> reclaimers. Now you are reclaiming a large chunk so you might end up
> reclaiming more than necessary. SWAP_CLUSTER_MAX would reduce the over
> reclaim to be negligible.
> 

I did consider this. And I think, I already explained that sort of race in previous email.
Whether "Task B" is really a task in cgroup or it's actually a bunch of reclaimers,
doesn't matter. That doesn't change anything.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
