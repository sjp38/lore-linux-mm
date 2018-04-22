Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12D136B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 12:43:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so4954207pgb.5
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 09:43:44 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0055.outbound.protection.outlook.com. [104.47.2.55])
        by mx.google.com with ESMTPS id v23si9540956pfk.116.2018.04.22.09.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 22 Apr 2018 09:43:42 -0700 (PDT)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20180421081505.GA24916@intel.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <127df719-b978-60b7-5d77-3c8efbf2ecff@mellanox.com>
Date: Sun, 22 Apr 2018 19:43:29 +0300
MIME-Version: 1.0
In-Reply-To: <20180421081505.GA24916@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 21/04/2018 11:15 AM, Aaron Lu wrote:
> Sorry to bring up an old thread...
> 

I want to thank you very much for bringing this up!

> On Thu, Nov 02, 2017 at 07:21:09PM +0200, Tariq Toukan wrote:
>>
>>
>> On 18/09/2017 12:16 PM, Tariq Toukan wrote:
>>>
>>>
>>> On 15/09/2017 1:23 PM, Mel Gorman wrote:
>>>> On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
>>>>> Insights: Major degradation between #1 and #2, not getting any
>>>>> close to linerate! Degradation is fixed between #2 and #3. This is
>>>>> because page allocator cannot stand the higher allocation rate. In
>>>>> #2, we also see that the addition of rings (cores) reduces BW (!!),
>>>>> as result of increasing congestion over shared resources.
>>>>>
>>>>
>>>> Unfortunately, no surprises there.
>>>>
>>>>> Congestion in this case is very clear. When monitored in perf
>>>>> top: 85.58% [kernel] [k] queued_spin_lock_slowpath
>>>>>
>>>>
>>>> While it's not proven, the most likely candidate is the zone lock
>>>> and that should be confirmed using a call-graph profile. If so, then
>>>> the suggestion to tune to the size of the per-cpu allocator would
>>>> mitigate the problem.
>>>>
>>> Indeed, I tuned the per-cpu allocator and bottleneck is released.
>>>
>>
>> Hi all,
>>
>> After leaving this task for a while doing other tasks, I got back to it now
>> and see that the good behavior I observed earlier was not stable.
> 
> I posted a patchset to improve zone->lock contention for order-0 pages
> recently, it can almost eliminate 80% zone->lock contention for
> will-it-scale/page_fault1 testcase when tested on a 2 sockets Intel
> Skylake server and it doesn't require PCP size tune, so should have
> some effects on your workload where one CPU does allocation while
> another does free.
> 

That is great news. In our driver's memory scheme (and many others as 
well) we allocate only order-0 pages (the only flow that does not do 
that yet in upstream will do so very soon, we already have the patches 
in our internal branch).
Allocation of order-0 pages is not only the common case, but is the only 
type of allocation in our data-path. Let's optimize it!


> It did this by some disruptive changes:
> 1 on free path, it skipped doing merge(so could be bad for mixed
>    workloads where both 4K and high order pages are needed);

I think there are so many advantages to not using high order 
allocations, especially in production servers that are not rebooted for 
long periods and become fragmented.
AFAIK, the community direction (at least in networking) is using order-0 
pages in datapath, so optimizing their allocaiton is a very good idea. 
Need of course to perf evaluate possible degradations, and see how 
important these use cases are.

> 2 on allocation path, it avoided touching multiple cachelines.
> 

Great!

> RFC v2 patchset:
> https://lkml.org/lkml/2018/3/20/171
> 
> repo:
> https://github.com/aaronlu/linux zone_lock_rfc_v2
> 

I will check them out first thing tomorrow!

p.s., I will be on vacation for a week starting Tuesday.
I hope I can make some progress before that :)

Thanks,
Tariq

>   
>> Recall: I work with a modified driver that allocates a page (4K) per packet
>> (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
>> NICs.
>>
>> Performance is good as long as pages are available in the allocating cores's
>> PCP.
>> Issue is that pages are allocated in one core, then free'd in another,
>> making it's hard for the PCP to work efficiently, and both the allocator
>> core and the freeing core need to access the buddy allocator very often.
>>
>> I'd like to share with you some testing numbers:
>>
>> Test: ./super_netperf 128 -H 24.134.0.51 -l 1000
>>
>> 100% cpu on all cores, top func in perf:
>>     84.98%  [kernel]             [k] queued_spin_lock_slowpath
>>
>> system wide (all cores)
>>             1135941      kmem:mm_page_alloc
>>
>>             2606629      kmem:mm_page_free
>>
>>                   0      kmem:mm_page_alloc_extfrag
>>             4784616      kmem:mm_page_alloc_zone_locked
>>
>>                1337      kmem:mm_page_free_batched
>>
>>             6488213      kmem:mm_page_pcpu_drain
>>
>>             8925503      net:napi_gro_receive_entry
>>
>>
>> Two types of cores:
>> A core mostly running napi (8 such cores):
>>              221875      kmem:mm_page_alloc
>>
>>               17100      kmem:mm_page_free
>>
>>                   0      kmem:mm_page_alloc_extfrag
>>              766584      kmem:mm_page_alloc_zone_locked
>>
>>                  16      kmem:mm_page_free_batched
>>
>>                  35      kmem:mm_page_pcpu_drain
>>
>>             1340139      net:napi_gro_receive_entry
>>
>>
>> Other core, mostly running user application (40 such):
>>                   2      kmem:mm_page_alloc
>>
>>               38922      kmem:mm_page_free
>>
>>                   0      kmem:mm_page_alloc_extfrag
>>                   1      kmem:mm_page_alloc_zone_locked
>>
>>                   8      kmem:mm_page_free_batched
>>
>>              107289      kmem:mm_page_pcpu_drain
>>
>>                  34      net:napi_gro_receive_entry
>>
>>
>> As you can see, sync overhead is enormous.
>>
>> PCP-wise, a key improvement in such scenarios would be reached if we could
>> (1) keep and handle the allocated page on same cpu, or (2) somehow get the
>> page back to the allocating core's PCP in a fast-path, without going through
>> the regular buddy allocator paths.
