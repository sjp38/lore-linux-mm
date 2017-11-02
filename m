Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB996B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:21:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 15so196057pgc.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:21:21 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0085.outbound.protection.outlook.com. [104.47.1.85])
        by mx.google.com with ESMTPS id t61si2667786plb.707.2017.11.02.10.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 10:21:19 -0700 (PDT)
Subject: Re: Page allocator bottleneck
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
Date: Thu, 2 Nov 2017 19:21:09 +0200
MIME-Version: 1.0
In-Reply-To: <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>



On 18/09/2017 12:16 PM, Tariq Toukan wrote:
> 
> 
> On 15/09/2017 1:23 PM, Mel Gorman wrote:
>> On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
>>> Insights: Major degradation between #1 and #2, not getting any
>>> close to linerate! Degradation is fixed between #2 and #3. This is
>>> because page allocator cannot stand the higher allocation rate. In
>>> #2, we also see that the addition of rings (cores) reduces BW (!!),
>>> as result of increasing congestion over shared resources.
>>>
>>
>> Unfortunately, no surprises there.
>>
>>> Congestion in this case is very clear. When monitored in perf top: 
>>> 85.58% [kernel] [k] queued_spin_lock_slowpath
>>>
>>
>> While it's not proven, the most likely candidate is the zone lock
>> and that should be confirmed using a call-graph profile. If so, then
>> the suggestion to tune to the size of the per-cpu allocator would
>> mitigate the problem.
>>
> Indeed, I tuned the per-cpu allocator and bottleneck is released.
> 

Hi all,

After leaving this task for a while doing other tasks, I got back to it 
now and see that the good behavior I observed earlier was not stable.

Recall: I work with a modified driver that allocates a page (4K) per 
packet (MTU=1500), in order to simulate the stress on page-allocator in 
200Gbps NICs.

Performance is good as long as pages are available in the allocating 
cores's PCP.
Issue is that pages are allocated in one core, then free'd in another, 
making it's hard for the PCP to work efficiently, and both the allocator 
core and the freeing core need to access the buddy allocator very often.

I'd like to share with you some testing numbers:

Test: ./super_netperf 128 -H 24.134.0.51 -l 1000

100% cpu on all cores, top func in perf:
    84.98%  [kernel]             [k] queued_spin_lock_slowpath

system wide (all cores)
            1135941      kmem:mm_page_alloc 

            2606629      kmem:mm_page_free 

                  0      kmem:mm_page_alloc_extfrag
            4784616      kmem:mm_page_alloc_zone_locked 

               1337      kmem:mm_page_free_batched 

            6488213      kmem:mm_page_pcpu_drain 

            8925503      net:napi_gro_receive_entry 


Two types of cores:
A core mostly running napi (8 such cores):
             221875      kmem:mm_page_alloc 

              17100      kmem:mm_page_free 

                  0      kmem:mm_page_alloc_extfrag
             766584      kmem:mm_page_alloc_zone_locked 

                 16      kmem:mm_page_free_batched 

                 35      kmem:mm_page_pcpu_drain 

            1340139      net:napi_gro_receive_entry 


Other core, mostly running user application (40 such):
                  2      kmem:mm_page_alloc 

              38922      kmem:mm_page_free 

                  0      kmem:mm_page_alloc_extfrag
                  1      kmem:mm_page_alloc_zone_locked 

                  8      kmem:mm_page_free_batched 

             107289      kmem:mm_page_pcpu_drain 

                 34      net:napi_gro_receive_entry 


As you can see, sync overhead is enormous.

PCP-wise, a key improvement in such scenarios would be reached if we 
could (1) keep and handle the allocated page on same cpu, or (2) somehow 
get the page back to the allocating core's PCP in a fast-path, without 
going through the regular buddy allocator paths.

Regards,
Tariq

>>> I think that page allocator issues should be discussed separately: 1) 
>>> Rate: Increase the allocation rate on a single core. 2)
>>> Scalability: Reduce congestion and sync overhead between cores.
>>>
>>> This is clearly the current bottleneck in the network stack receive
>>> flow.
>>>
>>> I know about some efforts that were made in the past two years. For
>>> example the ones from Jesper et al.: - Page-pool (not accepted
>>> AFAIK).
>>
>> Indeed not and it would also need driver conversion.
>>
>>> - Page-allocation bulking.
>>
>> Prototypes exist but it's pointless without the pool or driver 
>> conversion so it's in the back burner for the moment.
>>
> 
> As I already mentioned in another reply (to Jesper), this would
> perfectly fit with our Striding RQ feature, as we have large descriptors
> that serve several packets, requiring the allocation of several pages at
> once. I'd gladly move to using the bulking API.
> 
>>> - Optimize order-0 allocations in Per-Cpu-Pages.
>>>
>>
>> This had a prototype that was reverted as it must be able to cope
>> with both irq and noirq contexts.
> Yeah, I remember that I tested and reported the issue.
> 
> Unfortunately I never found the time to
>> revisit it but a split there to handle both would mitigate the
>> problem. Probably not enough to actually reach line speed though so
>> tuning of the per-cpu allocator sizes would still be needed. I don't
>> know when I'll get the chance to revisit it. I'm travelling all next
>> week and am mostly occupied with other work at the moment that is
>> consuming all my concentration.
>>
>>> I am not an mm expert, but wanted to raise the issue again, to
>>> combine the efforts and hear from you guys about status and
>>> possible directions.
>>
>> The recent effort to reduce overhead from stats will help mitigate
>> the problem.
> I should get more familiar with these stats, check how costly they are, 
> and whether they can be turned off in Kconfig.
> 
>> Finishing the page pool, the bulk allocator and converting drivers 
>> would be the most likely successful path forward but it's currently
>> stalled as everyone that was previously involved is too busy.
>>
> I think we should consider changing the default allocation of PCP 
> fraction as well, or implement some smart dynamic heuristic.
> This turned on to have significant effect over networking performance.
> 
> Many thanks Mel!
> 
> Regards,
> Tariq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
