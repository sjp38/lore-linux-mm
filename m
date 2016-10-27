Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C17FD6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 22:43:55 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n202so2580927oig.3
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 19:43:55 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id j8si3356097oib.91.2016.10.26.19.43.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Oct 2016 19:43:53 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/memblock: prepare a capability to support memblock
 near alloc
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
 <1477364358-10620-2-git-send-email-thunder.leizhen@huawei.com>
 <20161025132338.GA31239@dhcp22.suse.cz> <58101EB4.2080305@huawei.com>
 <20161026093152.GE18382@dhcp22.suse.cz>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <58116954.8080908@huawei.com>
Date: Thu, 27 Oct 2016 10:41:24 +0800
MIME-Version: 1.0
In-Reply-To: <20161026093152.GE18382@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>



On 2016/10/26 17:31, Michal Hocko wrote:
> On Wed 26-10-16 11:10:44, Leizhen (ThunderTown) wrote:
>>
>>
>> On 2016/10/25 21:23, Michal Hocko wrote:
>>> On Tue 25-10-16 10:59:17, Zhen Lei wrote:
>>>> If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
>>>> actually exist. The percpu variable areas and numa control blocks of that
>>>> memoryless numa nodes need to be allocated from the nearest available
>>>> node to improve performance.
>>>>
>>>> Although memblock_alloc_try_nid and memblock_virt_alloc_try_nid try the
>>>> specified nid at the first time, but if that allocation failed it will
>>>> directly drop to use NUMA_NO_NODE. This mean any nodes maybe possible at
>>>> the second time.
>>>>
>>>> To compatible the above old scene, I use a marco node_distance_ready to
>>>> control it. By default, the marco node_distance_ready is not defined in
>>>> any platforms, the above mentioned functions will work as normal as
>>>> before. Otherwise, they will try the nearest node first.
>>>
>>> I am sorry but it is absolutely unclear to me _what_ is the motivation
>>> of the patch. Is this a performance optimization, correctness issue or
>>> something else? Could you please restate what is the problem, why do you
>>> think it has to be fixed at memblock layer and describe what the actual
>>> fix is please?
>>
>> This is a performance optimization.
> 
> Do you have any numbers to back the improvements?
I have not collected any performance data, but at least in theory, it's beneficial and harmless,
except make code looks a bit urly. Because all related functions are actually defined as __init,
for example:
phys_addr_t __init memblock_alloc_try_nid(
void * __init memblock_virt_alloc_try_nid(

And all related memory(percpu variables and NODE_DATA) is mostly referred at running time.

> 
>> The problem is if some memoryless numa nodes are
>> actually exist, for example: there are total 4 nodes, 0,1,2,3, node 1 has no memory,
>> and the node distances is as below:
>>                     ---------board-------
>> 		    |                   |
>>                     |                   |
>>                  socket0             socket1
>>                    / \                 / \
>>                   /   \               /   \
>>                node0 node1         node2 node3
>> distance[1][0] is nearer than distance[1][2] and distance[1][3]. CPUs on node1 access
>> the memory of node0 is faster than node2 or node3.
>>
>> Linux defines a lot of percpu variables, each cpu has a copy of it and most of the time
>> only to access their own percpu area. In this example, we hope the percpu area of CPUs
>> on node1 allocated from node0. But without these patches, it's not sure that.
> 
> I am not familiar with the percpu allocator much so I might be
> completely missig a point but why cannot this be solved in the percpu
> allocator directly e.g. by using cpu_to_mem which should already be
> memoryless aware.
My test result told me that it can not:
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x00000011ffffffff]
[    0.000000] Could not find start_pfn for node 1
[    0.000000] Initmem setup node 1 [mem 0x0000000000000000-0x0000000000000000]
[    0.000000] Initmem setup node 2 [mem 0x0000001200000000-0x00000013ffffffff]
[    0.000000] Initmem setup node 3 [mem 0x0000001400000000-0x00000017ffffffff]


[   14.801895] NODE_DATA(0) = 0x11ffffe500
[   14.805749] NODE_DATA(1) = 0x11ffffca00	//(1), see below
[   14.809602] NODE_DATA(2) = 0x13ffffe500
[   14.813455] NODE_DATA(3) = 0x17fffe5480
[   14.817316] cpu 0 on node0: 11fff87638
[   14.821083] cpu 1 on node0: 11fff9c638
[   14.824850] cpu 2 on node0: 11fffb1638
[   14.828616] cpu 3 on node0: 11fffc6638
[   14.832383] cpu 4 on node1: 17fff8a638	//(2), see below
[   14.836149] cpu 5 on node1: 17fff9f638
[   14.839912] cpu 6 on node1: 17fffb4638
[   14.843677] cpu 7 on node1: 17fffc9638
[   14.847444] cpu 8 on node2: 13fffa4638
[   14.851210] cpu 9 on node2: 13fffb9638
[   14.854976] cpu10 on node2: 13fffce638
[   14.858742] cpu11 on node2: 13fffe3638
[   14.862510] cpu12 on node3: 17fff36638
[   14.866276] cpu13 on node3: 17fff4b638
[   14.870042] cpu14 on node3: 17fff60638
[   14.873809] cpu15 on node3: 17fff75638

(1) memblock_alloc_try_nid and with these patches, memory was allocated from node0
(2) do the same implementation as X86 and PowerPC, memory was allocated from node3:
    	return  __alloc_bootmem_node(NODE_DATA(nid), size, align, __pa(MAX_DMA_ADDRESS));

I'm not sure how about on X86 and PowerPC, here is my test cases. Is anybody interested and
have testing environment, can you help me to execute it?

static int tst_numa_002(void)
{
        int i;

        for (i = 0; i < nr_node_ids; i++)
                pr_info("NODE_DATA(%d) = 0x%llx\n", i, virt_to_phys(NODE_DATA(i)));

        return 0;
}

static int tst_numa_003(void)
{
        int cpu;
        void __percpu *p;

        p = __alloc_percpu(0x100, 1);

        for_each_possible_cpu(cpu)
                pr_info("cpu%2d on node%d: %llx\n", cpu, cpu_to_node(cpu), per_cpu_ptr_to_phys(per_cpu_ptr(p, cpu)));

        free_percpu(p);

        return 0;
}

> 
> Generating a new API while we have means to use an existing one sounds
> just not right to me.
Yes, so I gave up to create two new functions and selected this implementation.

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
