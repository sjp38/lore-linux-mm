Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F8826B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 04:55:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x7-v6so13708966iob.21
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 01:55:10 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0050.outbound.protection.outlook.com. [104.47.1.50])
        by mx.google.com with ESMTPS id d7-v6si6364215itf.77.2018.04.23.01.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 01:55:08 -0700 (PDT)
Subject: Re: Page allocator bottleneck
From: Tariq Toukan <tariqt@mellanox.com>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20180421081505.GA24916@intel.com>
 <127df719-b978-60b7-5d77-3c8efbf2ecff@mellanox.com>
Message-ID: <0dea4da6-8756-22d4-c586-267217a5fa63@mellanox.com>
Date: Mon, 23 Apr 2018 11:54:57 +0300
MIME-Version: 1.0
In-Reply-To: <127df719-b978-60b7-5d77-3c8efbf2ecff@mellanox.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 22/04/2018 7:43 PM, Tariq Toukan wrote:
> 
> 
> On 21/04/2018 11:15 AM, Aaron Lu wrote:
>> Sorry to bring up an old thread...
>>
> 
> I want to thank you very much for bringing this up!
> 
>> On Thu, Nov 02, 2017 at 07:21:09PM +0200, Tariq Toukan wrote:
>>>
>>>
>>> On 18/09/2017 12:16 PM, Tariq Toukan wrote:
>>>>
>>>>
>>>> On 15/09/2017 1:23 PM, Mel Gorman wrote:
>>>>> On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
>>>>>> Insights: Major degradation between #1 and #2, not getting any
>>>>>> close to linerate! Degradation is fixed between #2 and #3. This is
>>>>>> because page allocator cannot stand the higher allocation rate. In
>>>>>> #2, we also see that the addition of rings (cores) reduces BW (!!),
>>>>>> as result of increasing congestion over shared resources.
>>>>>>
>>>>>
>>>>> Unfortunately, no surprises there.
>>>>>
>>>>>> Congestion in this case is very clear. When monitored in perf
>>>>>> top: 85.58% [kernel] [k] queued_spin_lock_slowpath
>>>>>>
>>>>>
>>>>> While it's not proven, the most likely candidate is the zone lock
>>>>> and that should be confirmed using a call-graph profile. If so, then
>>>>> the suggestion to tune to the size of the per-cpu allocator would
>>>>> mitigate the problem.
>>>>>
>>>> Indeed, I tuned the per-cpu allocator and bottleneck is released.
>>>>
>>>
>>> Hi all,
>>>
>>> After leaving this task for a while doing other tasks, I got back to 
>>> it now
>>> and see that the good behavior I observed earlier was not stable.
>>
>> I posted a patchset to improve zone->lock contention for order-0 pages
>> recently, it can almost eliminate 80% zone->lock contention for
>> will-it-scale/page_fault1 testcase when tested on a 2 sockets Intel
>> Skylake server and it doesn't require PCP size tune, so should have
>> some effects on your workload where one CPU does allocation while
>> another does free.
>>
> 
> That is great news. In our driver's memory scheme (and many others as 
> well) we allocate only order-0 pages (the only flow that does not do 
> that yet in upstream will do so very soon, we already have the patches 
> in our internal branch).
> Allocation of order-0 pages is not only the common case, but is the only 
> type of allocation in our data-path. Let's optimize it!
> 
> 
>> It did this by some disruptive changes:
>> 1 on free path, it skipped doing merge(so could be bad for mixed
>> A A  workloads where both 4K and high order pages are needed);
> 
> I think there are so many advantages to not using high order 
> allocations, especially in production servers that are not rebooted for 
> long periods and become fragmented.
> AFAIK, the community direction (at least in networking) is using order-0 
> pages in datapath, so optimizing their allocaiton is a very good idea. 
> Need of course to perf evaluate possible degradations, and see how 
> important these use cases are.
> 
>> 2 on allocation path, it avoided touching multiple cachelines.
>>
> 
> Great!
> 
>> RFC v2 patchset:
>> https://lkml.org/lkml/2018/3/20/171
>>
>> repo:
>> https://github.com/aaronlu/linux zone_lock_rfc_v2
>>
> 
> I will check them out first thing tomorrow!
> 
> p.s., I will be on vacation for a week starting Tuesday.
> I hope I can make some progress before that :)
> 
> Thanks,
> Tariq
> 

Hi,

I ran my tests with your patches.
Initial BW numbers are significantly higher than I documented back then 
in this mail-thread.
For example, in driver #2 (see original mail thread), with 6 rings, I 
now get 92Gbps (slightly less than linerate) in comparison to 64Gbps 
back then.

However, there were many kernel changes since then, I need to isolate 
your changes. I am not sure I can finish this today, but I will surely 
get to it next week after I'm back from vacation.

Still, when I increase the scale (more rings, i.e. more cpus), I see 
that queued_spin_lock_slowpath gets to 60%+ cpu. Still high, but lower 
than it used to be.

This should be root solved by the (orthogonal) changes planned in 
network subsystem, which will change the SKB allocation/free scheme so 
that SKBs are released on the originating cpu.

Thanks,
Tariq

>>> Recall: I work with a modified driver that allocates a page (4K) per 
>>> packet
>>> (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
>>> NICs.
>>>
>>> Performance is good as long as pages are available in the allocating 
>>> cores's
>>> PCP.
>>> Issue is that pages are allocated in one core, then free'd in another,
>>> making it's hard for the PCP to work efficiently, and both the allocator
>>> core and the freeing core need to access the buddy allocator very often.
>>>
>>> I'd like to share with you some testing numbers:
>>>
>>> Test: ./super_netperf 128 -H 24.134.0.51 -l 1000
>>>
>>> 100% cpu on all cores, top func in perf:
>>> A A A  84.98%A  [kernel]A A A A A A A A A A A A  [k] queued_spin_lock_slowpath
>>>
>>> system wide (all cores)
>>> A A A A A A A A A A A  1135941A A A A A  kmem:mm_page_alloc
>>>
>>> A A A A A A A A A A A  2606629A A A A A  kmem:mm_page_free
>>>
>>> A A A A A A A A A A A A A A A A A  0A A A A A  kmem:mm_page_alloc_extfrag
>>> A A A A A A A A A A A  4784616A A A A A  kmem:mm_page_alloc_zone_locked
>>>
>>> A A A A A A A A A A A A A A  1337A A A A A  kmem:mm_page_free_batched
>>>
>>> A A A A A A A A A A A  6488213A A A A A  kmem:mm_page_pcpu_drain
>>>
>>> A A A A A A A A A A A  8925503A A A A A  net:napi_gro_receive_entry
>>>
>>>
>>> Two types of cores:
>>> A core mostly running napi (8 such cores):
>>> A A A A A A A A A A A A  221875A A A A A  kmem:mm_page_alloc
>>>
>>> A A A A A A A A A A A A A  17100A A A A A  kmem:mm_page_free
>>>
>>> A A A A A A A A A A A A A A A A A  0A A A A A  kmem:mm_page_alloc_extfrag
>>> A A A A A A A A A A A A  766584A A A A A  kmem:mm_page_alloc_zone_locked
>>>
>>> A A A A A A A A A A A A A A A A  16A A A A A  kmem:mm_page_free_batched
>>>
>>> A A A A A A A A A A A A A A A A  35A A A A A  kmem:mm_page_pcpu_drain
>>>
>>> A A A A A A A A A A A  1340139A A A A A  net:napi_gro_receive_entry
>>>
>>>
>>> Other core, mostly running user application (40 such):
>>> A A A A A A A A A A A A A A A A A  2A A A A A  kmem:mm_page_alloc
>>>
>>> A A A A A A A A A A A A A  38922A A A A A  kmem:mm_page_free
>>>
>>> A A A A A A A A A A A A A A A A A  0A A A A A  kmem:mm_page_alloc_extfrag
>>> A A A A A A A A A A A A A A A A A  1A A A A A  kmem:mm_page_alloc_zone_locked
>>>
>>> A A A A A A A A A A A A A A A A A  8A A A A A  kmem:mm_page_free_batched
>>>
>>> A A A A A A A A A A A A  107289A A A A A  kmem:mm_page_pcpu_drain
>>>
>>> A A A A A A A A A A A A A A A A  34A A A A A  net:napi_gro_receive_entry
>>>
>>>
>>> As you can see, sync overhead is enormous.
>>>
>>> PCP-wise, a key improvement in such scenarios would be reached if we 
>>> could
>>> (1) keep and handle the allocated page on same cpu, or (2) somehow 
>>> get the
>>> page back to the allocating core's PCP in a fast-path, without going 
>>> through
>>> the regular buddy allocator paths.
