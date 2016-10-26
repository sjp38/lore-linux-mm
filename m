Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41A726B0273
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 23:14:20 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so62785380oig.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 20:14:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id t197si10342925oie.275.2016.10.25.20.14.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 20:14:19 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/memblock: prepare a capability to support memblock
 near alloc
References: <1477364358-10620-1-git-send-email-thunder.leizhen@huawei.com>
 <1477364358-10620-2-git-send-email-thunder.leizhen@huawei.com>
 <20161025132338.GA31239@dhcp22.suse.cz>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <58101EB4.2080305@huawei.com>
Date: Wed, 26 Oct 2016 11:10:44 +0800
MIME-Version: 1.0
In-Reply-To: <20161025132338.GA31239@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Hanjun Guo <guohanjun@huawei.com>



On 2016/10/25 21:23, Michal Hocko wrote:
> On Tue 25-10-16 10:59:17, Zhen Lei wrote:
>> If HAVE_MEMORYLESS_NODES is selected, and some memoryless numa nodes are
>> actually exist. The percpu variable areas and numa control blocks of that
>> memoryless numa nodes need to be allocated from the nearest available
>> node to improve performance.
>>
>> Although memblock_alloc_try_nid and memblock_virt_alloc_try_nid try the
>> specified nid at the first time, but if that allocation failed it will
>> directly drop to use NUMA_NO_NODE. This mean any nodes maybe possible at
>> the second time.
>>
>> To compatible the above old scene, I use a marco node_distance_ready to
>> control it. By default, the marco node_distance_ready is not defined in
>> any platforms, the above mentioned functions will work as normal as
>> before. Otherwise, they will try the nearest node first.
> 
> I am sorry but it is absolutely unclear to me _what_ is the motivation
> of the patch. Is this a performance optimization, correctness issue or
> something else? Could you please restate what is the problem, why do you
> think it has to be fixed at memblock layer and describe what the actual
> fix is please?
This is a performance optimization. The problem is if some memoryless numa nodes are
actually exist, for example: there are total 4 nodes, 0,1,2,3, node 1 has no memory,
and the node distances is as below:
                    ---------board-------
		    |                   |
                    |                   |
                 socket0             socket1
                   / \                 / \
                  /   \               /   \
               node0 node1         node2 node3
distance[1][0] is nearer than distance[1][2] and distance[1][3]. CPUs on node1 access
the memory of node0 is faster than node2 or node3.

Linux defines a lot of percpu variables, each cpu has a copy of it and most of the time
only to access their own percpu area. In this example, we hope the percpu area of CPUs
on node1 allocated from node0. But without these patches, it's not sure that.

If each node has their own memory, we can directly use below functions to allocate memory
from its local node:
1. memblock_alloc_nid
2. memblock_alloc_try_nid
3. memblock_virt_alloc_try_nid_nopanic
4. memblock_virt_alloc_try_nid

So, these patches is only used for numa memoryless scenario.

Another use case is the control block "extern pg_data_t *node_data[]",
Here is an example of x86 numa in arch/x86/mm/numa.c:
static void __init alloc_node_data(int nid)
{
	... ...
        /*
         * Allocate node data.  Try node-local memory and then any node.	//==>But the nearest node is the best
         * Never allocate in DMA zone.
         */
        nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
        if (!nd_pa) {
                nd_pa = __memblock_alloc_base(nd_size, SMP_CACHE_BYTES,
                                              MEMBLOCK_ALLOC_ACCESSIBLE);
                if (!nd_pa) {
                        pr_err("Cannot find %zu bytes in node %d\n",
                               nd_size, nid);
                        return;
                }
        }
        nd = __va(nd_pa);
        ... ...
        node_data[nid] = nd;

> 
>>From a quick glance you are trying to bend over the memblock API for
> something that should be handled on a different layer.
> 
>>
>> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
>> ---
>>  mm/memblock.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
>>  1 file changed, 65 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index 7608bc3..556bbd2 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1213,9 +1213,71 @@ phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
>>  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>>  }
>>
>> +#ifndef node_distance_ready
>> +#define node_distance_ready()		0
>> +#endif
>> +
>> +static phys_addr_t __init memblock_alloc_near_nid(phys_addr_t size,
>> +					phys_addr_t align, phys_addr_t start,
>> +					phys_addr_t end, int nid, ulong flags,
>> +					int alloc_func_type)
>> +{
>> +	int nnid, round = 0;
>> +	u64 pa;
>> +	DECLARE_BITMAP(nodes_map, MAX_NUMNODES);
>> +
>> +	bitmap_zero(nodes_map, MAX_NUMNODES);
>> +
>> +again:
>> +	/*
>> +	 * There are total 4 cases:
>> +	 * <nid == NUMA_NO_NODE>
>> +	 *   1)2) node_distance_ready || !node_distance_ready
>> +	 *	Round 1, nnid = nid = NUMA_NO_NODE;
>> +	 * <nid != NUMA_NO_NODE>
>> +	 *   3) !node_distance_ready
>> +	 *	Round 1, nnid = nid;
>> +	 *    ::Round 2, currently only applicable for alloc_func_type = <0>
>> +	 *	Round 2, nnid = NUMA_NO_NODE;
>> +	 *   4) node_distance_ready
>> +	 *	Round 1, LOCAL_DISTANCE, nnid = nid;
>> +	 *	Round ?, nnid = nearest nid;
>> +	 */
>> +	if (!node_distance_ready() || (nid == NUMA_NO_NODE)) {
>> +		nnid = (++round == 1) ? nid : NUMA_NO_NODE;
>> +	} else {
>> +		int i, distance = INT_MAX;
>> +
>> +		for_each_clear_bit(i, nodes_map, MAX_NUMNODES)
>> +			if (node_distance(nid, i) < distance) {
>> +				nnid = i;
>> +				distance = node_distance(nid, i);
>> +			}
>> +	}
>> +
>> +	switch (alloc_func_type) {
>> +	case 0:
>> +		pa = memblock_find_in_range_node(size, align, start, end, nnid, flags);
>> +		break;
>> +
>> +	case 1:
>> +	default:
>> +		pa = memblock_alloc_nid(size, align, nnid);
>> +		if (!node_distance_ready())
>> +			return pa;
>> +	}
>> +
>> +	if (!pa && (nnid != NUMA_NO_NODE)) {
>> +		bitmap_set(nodes_map, nnid, 1);
>> +		goto again;
>> +	}
>> +
>> +	return pa;
>> +}
>> +
>>  phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
>>  {
>> -	phys_addr_t res = memblock_alloc_nid(size, align, nid);
>> +	phys_addr_t res = memblock_alloc_near_nid(size, align, 0, 0, nid, 0, 1);
>>
>>  	if (res)
>>  		return res;
>> @@ -1276,19 +1338,11 @@ static void * __init memblock_virt_alloc_internal(
>>  		max_addr = memblock.current_limit;
>>
>>  again:
>> -	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
>> -					    nid, flags);
>> +	alloc = memblock_alloc_near_nid(size, align, min_addr, max_addr,
>> +					    nid, flags, 0);
>>  	if (alloc)
>>  		goto done;
>>
>> -	if (nid != NUMA_NO_NODE) {
>> -		alloc = memblock_find_in_range_node(size, align, min_addr,
>> -						    max_addr, NUMA_NO_NODE,
>> -						    flags);
>> -		if (alloc)
>> -			goto done;
>> -	}
>> -
>>  	if (min_addr) {
>>  		min_addr = 0;
>>  		goto again;
>> --
>> 2.5.0
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
