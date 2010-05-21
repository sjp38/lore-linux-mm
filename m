Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 703BC600385
	for <linux-mm@kvack.org>; Fri, 21 May 2010 04:43:54 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L8hq7J007516
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 May 2010 17:43:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2A145DE53
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:43:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 91BDF45DE4F
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:43:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BB111DB8019
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:43:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EFA3D1DB8017
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:43:50 +0900 (JST)
Date: Fri, 21 May 2010 17:39:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-Id: <20100521173940.8f130205.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BF642BB.2020402@linux.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	<20100520134359.fdfb397e.akpm@linux-foundation.org>
	<20100521105512.0c2cf254.sfr@canb.auug.org.au>
	<20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
	<4BF642BB.2020402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: minskey guo <chaohong_guo@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010 16:22:19 +0800
minskey guo <chaohong_guo@linux.intel.com> wrote:

> Yes.  I can use cpu_to_mem().  only some little difference during
> CPU online:  1st cpu within memoryless node gets memory from current
> node or the node to which the cpu0 belongs,
> 
> 
> But I have a question about the patch:
> 
>     numa-slab-use-numa_mem_id-for-slab-local-memory-node.patch,
> 
> 
> 
> 
> @@ -2968,9 +2991,23 @@ static int __build_all_zonelists(void *d
> ...
> 
> -	for_each_possible_cpu(cpu)
> +	for_each_possible_cpu(cpu) {
> 		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
> ...
> 
> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> + 	if (cpu_online(cpu))
> +		cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
> +#endif
> 
> 
> Look at the last two lines, suppose that memory is onlined before CPUs,
> where will cpu_to_mem(cpu) be set to the right nodeid for the last
> onlined cpu ?  Does that CPU always get memory from the node including 
> cpu0 for slab allocator where cpu_to_mem() is used ?
> 
build_all_zonelist() is called at boot, initialization.
And it calls local_memory_node(cpu_to_node(cpu)) for possible cpus.

So, "how cpu_to_node() for possible cpus is configured" is important.
At quick look, root/arch/x86/mm/numa_64.c has following code.


 786 /*
 787  * Setup early cpu_to_node.
 788  *
 789  * Populate cpu_to_node[] only if x86_cpu_to_apicid[],
 790  * and apicid_to_node[] tables have valid entries for a CPU.
 791  * This means we skip cpu_to_node[] initialisation for NUMA
 792  * emulation and faking node case (when running a kernel compiled
 793  * for NUMA on a non NUMA box), which is OK as cpu_to_node[]
 794  * is already initialized in a round robin manner at numa_init_array,
 795  * prior to this call, and this initialization is good enough
 796  * for the fake NUMA cases.
 797  *
 798  * Called before the per_cpu areas are setup.
 799  */
 800 void __init init_cpu_to_node(void)
 801 {
 802         int cpu;
 803         u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);
 804 
 805         BUG_ON(cpu_to_apicid == NULL);
 806 
 807         for_each_possible_cpu(cpu) {
 808                 int node;
 809                 u16 apicid = cpu_to_apicid[cpu];
 810 
 811                 if (apicid == BAD_APICID)
 812                         continue;
 813                 node = apicid_to_node[apicid];
 814                 if (node == NUMA_NO_NODE)
 815                         continue;
 816                 if (!node_online(node))
 817                         node = find_near_online_node(node);
 818                 numa_set_node(cpu, node);
 819         }
 820 }


So, cpu_to_node(cpu) for possible cpus will have NUMA_NO_NODE(-1)
or the number of the nearest node.

IIUC, if SRAT is not broken, all pxm has its own node_id. So,
cpu_to_node(cpu) will return the nearest node and cpu_to_mem() will
find the nearest node with memory.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
