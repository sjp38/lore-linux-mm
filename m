Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 083FB600385
	for <linux-mm@kvack.org>; Fri, 21 May 2010 04:22:49 -0400 (EDT)
Message-ID: <4BF642BB.2020402@linux.intel.com>
Date: Fri, 21 May 2010 16:22:19 +0800
From: minskey guo <chaohong_guo@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>	<20100520134359.fdfb397e.akpm@linux-foundation.org>	<20100521105512.0c2cf254.sfr@canb.auug.org.au> <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>


>>>> --- a/mm/percpu.c
>>>> +++ b/mm/percpu.c
>>>> @@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
>>>
>>> In linux-next, Tejun has gone and moved pcpu_alloc_pages() into the new
>>> mm/percpu-vm.c.  So either
>>
>> This has gone into Linus' tree today ...
>>
>
> Hmm, a comment here.
>
> Recently, Lee Schermerhorn developed
>
>   numa-introduce-numa_mem_id-effective-local-memory-node-id-fix2.patch
>
> Then, you can use cpu_to_mem() instead of cpu_to_node() to find the
> nearest available node.
> I don't check cpu_to_mem() is synchronized with NUMA hotplug but
> using cpu_to_mem() rather than adding
> =
>
> +			if ((nid == -1) ||
> +			    !(node_zonelist(nid, GFP_KERNEL)->_zonerefs->zone))
> +				nid = numa_node_id();
> +
> ==
>
> is better.


Yes.  I can use cpu_to_mem().  only some little difference during
CPU online:  1st cpu within memoryless node gets memory from current
node or the node to which the cpu0 belongs,


But I have a question about the patch:

    numa-slab-use-numa_mem_id-for-slab-local-memory-node.patch,




@@ -2968,9 +2991,23 @@ static int __build_all_zonelists(void *d
...

-	for_each_possible_cpu(cpu)
+	for_each_possible_cpu(cpu) {
		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
...

+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+ 	if (cpu_online(cpu))
+		cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
+#endif


Look at the last two lines, suppose that memory is onlined before CPUs,
where will cpu_to_mem(cpu) be set to the right nodeid for the last
onlined cpu ?  Does that CPU always get memory from the node including 
cpu0 for slab allocator where cpu_to_mem() is used ?



thanks,
-minskey



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
