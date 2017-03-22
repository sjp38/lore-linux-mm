Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10A106B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 13:39:29 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 15so38012275itw.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:39:29 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0061.outbound.protection.outlook.com. [104.47.1.61])
        by mx.google.com with ESMTPS id m12si10237895iti.60.2017.03.22.10.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 10:39:27 -0700 (PDT)
Subject: Re: Page allocator order-0 optimizations merged
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
Date: Wed, 22 Mar 2017 19:39:17 +0200
MIME-Version: 1.0
In-Reply-To: <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>



On 01/03/2017 7:36 PM, Tariq Toukan wrote:
>
> On 01/03/2017 3:48 PM, Jesper Dangaard Brouer wrote:
>> Hi NetDev community,
>>
>> I just wanted to make net driver people aware that this MM commit[1] got
>> merged and is available in net-next.
>>
>>   commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator 
>> for irq-safe requests")
>>   [1] https://git.kernel.org/davem/net-next/c/374ad05ab64d696
>>
>> It provides approx 14% speedup of order-0 page allocations.  I do know
>> most driver do their own page-recycling.  Thus, this gain will only be
>> seen when this page recycling is insufficient, which Tariq was affected
>> by AFAIK.
> Thanks Jesper, this is great news!
> I will start perf testing this tomorrow.
>>
>> We are also playing with a bulk page allocator facility[2], that I've
>> benchmarked[3][4].  While I'm seeing between 34%-46% improvements by
>> bulking, I believe we actually need to do better, before it reach our
>> performance target for high-speed networking.
> Very promising!
> This fits perfectly in our Striding RQ feature (Multi-Packet WQE)
> where we allocate fragmented buffers (of order-0 pages) of 256KB total.
> Big like :)
>
> Thanks,
> Tariq
>> --Jesper
>>
>> [2] 
>> http://lkml.kernel.org/r/20170109163518.6001-5-mgorman%40techsingularity.net
>> [3] http://lkml.kernel.org/r/20170116152518.5519dc1e%40redhat.com
>> [4] 
>> https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench04_bulk.c
>>
>>
>> On Mon, 27 Feb 2017 12:25:03 -0800 akpm@linux-foundation.org wrote:
>>
>>> The patch titled
>>>       Subject: mm, page_alloc: only use per-cpu allocator for 
>>> irq-safe requests
>>> has been removed from the -mm tree.  Its filename was
>>> mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
>>>
>>> This patch was dropped because it was merged into mainline or a 
>>> subsystem tree
>>>
>>> ------------------------------------------------------
>>> From: Mel Gorman <mgorman@techsingularity.net>
>>> Subject: mm, page_alloc: only use per-cpu allocator for irq-safe 
>>> requests
>>>
>>> Many workloads that allocate pages are not handling an interrupt at a
>>> time.  As allocation requests may be from IRQ context, it's 
>>> necessary to
>>> disable/enable IRQs for every page allocation.  This cost is the 
>>> bulk of
>>> the free path but also a significant percentage of the allocation path.
>>>
>>> This patch alters the locking and checks such that only irq-safe
>>> allocation requests use the per-cpu allocator.  All others acquire the
>>> irq-safe zone->lock and allocate from the buddy allocator. It relies on
>>> disabling preemption to safely access the per-cpu structures. It 
>>> could be
>>> slightly modified to avoid soft IRQs using it but it's not clear it's
>>> worthwhile.
>>>
>>> This modification may slow allocations from IRQ context slightly but 
>>> the
>>> main gain from the per-cpu allocator is that it scales better for
>>> allocations from multiple contexts.  There is an implicit assumption 
>>> that
>>> intensive allocations from IRQ contexts on multiple CPUs from a single
>>> NUMA node are rare 
Hi Mel, Jesper, and all.

This assumption contradicts regular multi-stream traffic that is 
naturally handled
over close numa cores.  I compared iperf TCP multistream (8 streams)
over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
kernel v4.11-rc1 (with this series).
I disabled the page-cache (recycle) mechanism to stress the page allocator,
and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in 
v4.11-rc1 (34% drop).
I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.

Best,
Tariq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
