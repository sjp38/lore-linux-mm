Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D366982F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:55:20 -0400 (EDT)
Received: by wijp11 with SMTP id p11so84105218wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:55:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si10766081wif.46.2015.10.21.01.55.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 01:55:19 -0700 (PDT)
Subject: Re: [ovs-dev] [PATCH] ovs: do not allocate memory from offline numa
 node
References: <20151002101822.12499.27658.stgit@buzz> <56128238.8010305@suse.cz>
 <5612DCC8.4040605@gmail.com>
 <CAEP_g=9JB2GptbZn9ayTPRGPbuOvVujCQ1Hui7fOijUX10HURg@mail.gmail.com>
 <FB2084BE-D591-415F-BA39-DFE82FE6FC30@nicira.com>
 <CAEP_g=9bqj_CKMTvd4dHTS+J82u7idtqa_PFA9=-CmO2ZcUMow@mail.gmail.com>
 <ECF39603-F56D-483A-A398-480C28C93F97@nicira.com>
 <CAEP_g=8TTh7pQL_DadBPdhfat+gd_XizGJqWK2wvHvo7oy6WaQ@mail.gmail.com>
 <3C0B7B0E-FDF9-45F5-9CA4-6A8D3CBB2E5C@nicira.com>
 <EDC4CBA7-1E5A-47B6-9F45-8365840F4E53@nicira.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <562752F0.1020502@suse.cz>
Date: Wed, 21 Oct 2015 10:55:12 +0200
MIME-Version: 1.0
In-Reply-To: <EDC4CBA7-1E5A-47B6-9F45-8365840F4E53@nicira.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>, Jesse Gross <jesse@nicira.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "dev@openvswitch.org" <dev@openvswitch.org>, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On 10/20/2015 07:58 PM, Jarno Rajahalme wrote:
>
>> On Oct 9, 2015, at 5:02 PM, Jarno Rajahalme <jrajahalme@nicira.com
>> <mailto:jrajahalme@nicira.com>> wrote:
>>
>>
>>> On Oct 9, 2015, at 3:11 PM, Jesse Gross <jesse@nicira.com
>>> <mailto:jesse@nicira.com>> wrote:
>>>
>>> On Fri, Oct 9, 2015 at 8:54 AM, Jarno Rajahalme
>>> <jrajahalme@nicira.com <mailto:jrajahalme@nicira.com>> wrote:
>>>>
>>>> On Oct 8, 2015, at 4:03 PM, Jesse Gross <jesse@nicira.com
>>>> <mailto:jesse@nicira.com>> wrote:
>>>>
>>>> On Wed, Oct 7, 2015 at 10:47 AM, Jarno Rajahalme
>>>> <jrajahalme@nicira.com <mailto:jrajahalme@nicira.com>>
>>>> wrote:
>>>>
>>>>
>>>> On Oct 6, 2015, at 6:01 PM, Jesse Gross <jesse@nicira.com
>>>> <mailto:jesse@nicira.com>> wrote:
>>>>
>>>> On Mon, Oct 5, 2015 at 1:25 PM, Alexander Duyck
>>>> <alexander.duyck@gmail.com <mailto:alexander.duyck@gmail.com>> wrote:
>>>>
>>>> On 10/05/2015 06:59 AM, Vlastimil Babka wrote:
>>>>
>>>>
>>>> On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
>>>>
>>>>
>>>> When openvswitch tries allocate memory from offline numa node 0:
>>>> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO,
>>>> 0)
>>>> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES ||
>>>> !node_online(nid))
>>>> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
>>>> This patch disables numa affinity in this case.
>>>>
>>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru
>>>> <mailto:khlebnikov@yandex-team.ru>>
>>>>
>>>>
>>>>
>>>> ...
>>>>
>>>> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
>>>> index f2ea83ba4763..c7f74aab34b9 100644
>>>> --- a/net/openvswitch/flow_table.c
>>>> +++ b/net/openvswitch/flow_table.c
>>>> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>>>>
>>>>    /* Initialize the default stat node. */
>>>>    stats = kmem_cache_alloc_node(flow_stats_cache,
>>>> -                      GFP_KERNEL | __GFP_ZERO, 0);
>>>> +                      GFP_KERNEL | __GFP_ZERO,
>>>> +                      node_online(0) ? 0 : NUMA_NO_NODE);
>>>>
>>>>
>>>>
>>>> Stupid question: can node 0 become offline between this check, and the
>>>> VM_WARN_ON? :) BTW what kind of system has node 0 offline?
>>>>
>>>>
>>>>
>>>> Another question to ask would be is it possible for node 0 to be
>>>> online, but
>>>> be a memoryless node?
>>>>
>>>> I would say you are better off just making this call
>>>> kmem_cache_alloc.  I
>>>> don't see anything that indicates the memory has to come from node 0, so
>>>> adding the extra overhead doesn't provide any value.
>>>>
>>>>
>>>> I agree that this at least makes me wonder, though I actually have
>>>> concerns in the opposite direction - I see assumptions about this
>>>> being on node 0 in net/openvswitch/flow.c.
>>>>
>>>> Jarno, since you original wrote this code, can you take a look to see
>>>> if everything still makes sense?
>>>>
>>>>
>>>> We keep the pre-allocated stats node at array index 0, which is
>>>> initially
>>>> used by all CPUs, but if CPUs from multiple numa nodes start
>>>> updating the
>>>> stats, we allocate additional stats nodes (up to one per numa node),
>>>> and the
>>>> CPUs on node 0 keep using the preallocated entry. If stats cannot be
>>>> allocated from CPUs local node, then those CPUs keep using the entry at
>>>> index 0. Currently the code in net/openvswitch/flow.c will try to
>>>> allocate
>>>> the local memory repeatedly, which may not be optimal when there is no
>>>> memory at the local node.
>>>>
>>>> Allocating the memory for the index 0 from other than node 0, as
>>>> discussed
>>>> here, just means that the CPUs on node 0 will keep on using
>>>> non-local memory
>>>> for stats. In a scenario where there are CPUs on two nodes (0, 1),
>>>> but only
>>>> the node 1 has memory, a shared flow entry will still end up having
>>>> separate
>>>> memory allocated for both nodes, but both of the nodes would be at
>>>> node 1.
>>>> However, there is still a high likelihood that the memory
>>>> allocations would
>>>> not share a cache line, which should prevent the nodes from invalidating
>>>> each othera??s caches. Based on this I do not see a problem relaxing the
>>>> memory allocation for the default stats node. If node 0 has memory,
>>>> however,
>>>> it would be better to allocate the memory from node 0.
>>>>
>>>>
>>>> Thanks for going through all of that.
>>>>
>>>> It seems like the question that is being raised is whether it actually
>>>> makes sense to try to get the initial memory on node 0, especially
>>>> since it seems to introduce some corner cases? Is there any reason why
>>>> the flow is more likely to hit node 0 than a randomly chosen one?
>>>> (Assuming that this is a multinode system, otherwise it's kind of a
>>>> moot point.) We could have a separate pointer to the default allocated
>>>> memory, so it wouldn't conflict with memory that was intentionally
>>>> allocated for node 0.
>>>>
>>>>
>>>> It would still be preferable to know from which node the default
>>>> stats node
>>>> was allocated, and store it in the appropriate pointer in the array. We
>>>> could then add a new a??default stats node indexa?? that would be used
>>>> to locate
>>>> the node in the array of pointers we already have. That way we would
>>>> avoid
>>>> extra allocation and processing of the default stats node.
>>>
>>> I agree, that sounds reasonable to me. Will you make that change?
>>>
>>> Besides eliminating corner cases, it might help performance in some
>>> cases too by avoiding stressing memory bandwidth on node 0.
>>
>
> According to the comment above kmem_cache_alloc_node(),
> kmem_cache_alloc_node() should not BUG_ON/WARN_ON in this case:
>> *//**/*
>> */* kmem_cache_alloc_node - Allocate an object on the specified node/*
>> */* @cachep: The cache to allocate from./*
>> */* @flags: See kmalloc()./*
>> */* @nodeid: node number of the target node./*
>> */*/*
>> */* Identical to kmem_cache_alloc but it will allocate memory on the
>> given/*
>> */* node, which can improve the performance for cpu bound structures./*
>> */*/*
>> */* Fallback to other node is possible if __GFP_THISNODE is not set./*
>> */*//*
> See also this from cpuset.c:
>
>> /**
>>  * cpuset_mem_spread_node() - On which node to begin search for a file
>> page
>>  * cpuset_slab_spread_node() - On which node to begin search for a
>> slab page
>>  *
>>  * If a task is marked PF_SPREAD_PAGE or PF_SPREAD_SLAB (as for
>>  * tasks in a cpuset with is_spread_page or is_spread_slab set),
>>  * and if the memory allocation used cpuset_mem_spread_node()
>>  * to determine on which node to start looking, as it will for
>>  * certain page cache or slab cache pages such as used for file
>>  * system buffers and inode caches, then instead of starting on the
>>  * local node to look for a free page, rather spread the starting
>>  * node around the tasks mems_allowed nodes.
>>  *
>>  * We don't have to worry about the returned node being offline
>>  * because "it can't happen", and even if it did, it would be ok.
>>  *
>>  * The routines calling guarantee_online_mems() are careful to
>>  * only set nodes in task->mems_allowed that are online.  So it
>>  * should not be possible for the following code to return an
>>  * offline node.  But if it did, that would be ok, as this routine
>>  * is not returning the node where the allocation must be, only
>>  * the node where the search should start.  The zonelist passed to
>>  * __alloc_pages() will include all nodes.  If the slab allocator
>>  * is passed an offline node, it will fall back to the local node.

OK, this is probably only true without __GFP_THISNODE.

>>  * See kmem_cache_alloc_node().
>>  */
>
> Based on this it seems this is a bug in the memory allocator, it
> probably should not be calling alloc_pages_exact_node()

alloc_pages_exact_node() doesn't exist anymore in 4.3-rcX

So what exact problem do you think there is? What I can see is that:
- cpuset_slab_spread_node() says it shouldn't return offline node, but 
asserts that if it happens anyway, slab will fall back
- slab.c calls the spread_node function from alternate_node_alloc() and 
then passes the nodeid to ____cache_alloc_node(), which calls 
cache_grow() with __GFP_THISNODE, which eventually calls 
__alloc_pages_node() and VM_WARN_ON() may happen for an offline node, 
and also with __GFP_THISNODE the allocation will fail... but then a 
fallback_alloc() occurs.

So the issue is a potential VM_WARN_ON when/if cpuset_slab_spread_node() 
fails to guarantee the node is online?

> when __GFP_THISNODE is not set?
>
>    Jarno
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
