Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5B06B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:59:33 -0400 (EDT)
Subject: RE: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <CF2F38D4AE21BB4CB845318E4C5ECB671E790500@shsmsx501.ccr.corp.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	 <20100520134359.fdfb397e.akpm@linux-foundation.org>
	 <20100521105512.0c2cf254.sfr@canb.auug.org.au>
	 <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF642BB.2020402@linux.intel.com>
	 <20100521173940.8f130205.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF64E79.4010401@linux.intel.com>
	 <1274448107.9131.87.camel@useless.americas.hpqcorp.net>
	 <CF2F38D4AE21BB4CB845318E4C5ECB671E790500@shsmsx501.ccr.corp.intel.com>
Content-Type: text/plain
Date: Mon, 24 May 2010 10:59:22 -0400
Message-Id: <1274713162.13756.209.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Guo, Chaohong" <chaohong.guo@intel.com>
Cc: minskey guo <chaohong_guo@linux.intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "prarit@redhat.com" <prarit@redhat.com>, "Kleen, Andi" <andi.kleen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, "stable@kernel.org" <stable@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-24 at 09:03 +0800, Guo, Chaohong wrote:
> 
> >> >>
> >> >>
> >> >> @@ -2968,9 +2991,23 @@ static int __build_all_zonelists(void *d
> >> >> ...
> >> >>
> >> >> -	for_each_possible_cpu(cpu)
> >> >> +	for_each_possible_cpu(cpu) {
> >> >> 		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
> >> >> ...
> >> >>
> >> >> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
> >> >> + 	if (cpu_online(cpu))
> >> >> +		cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
> >> >> +#endif
> >>
> >> Look at the above code,  int __build_all_zonelists(),  cpu_to_mem(cpu)
> >> is set only when cpu is onlined.  Suppose that a node with local memory,
> >> all memory segments are onlined first, and then,  cpus within that node
> >> are onlined one by one,  in this case,  where does the cpu_to_mem(cpu)
> >> for the last cpu get its value ?
> >
> >Minskey:
> >
> >As I mentioned to Kame-san, x86 does not define
> >CONFIG_HAVE_MEMORYLESS_NODES, so this code is not compiled for that
> >arch.  If x86 did support memoryless nodes--i.e., did not hide them and
> >reassign the cpus to other nodes, as is the case for ia64--then we could
> >have on-line cpus associated with memoryless nodes.  The code above is
> >in __build_all_zonelists() so that in the case where we add memory to a
> >previously memoryless node, we re-evaluate the "local memory node" for
> >all online cpus.
> >
> >For cpu hotplug--again, if x86 supports memoryless nodes--we'll need to
> >add a similar chunk to the path where we set up the cpu_to_node map for
> >a hotplugged cpu.  See, for example, the call to set_numa_mem() in
> >smp_callin() in arch/ia64/kernel/smpboot.c. 
> 
> 
> Yeah, that's what I am looking for. 
> 
> 
> 
>  But currently, I don't
> >think you can use the numa_mem_id()/cpu_to_mem() interfaces for your
> >purpose.  I suppose you could change page_alloc.c to compile
> >local_memory_node() #if defined(CONFIG_HAVE_MEMORYLESS_NODES) ||
> >defined
> >(CPU_HOTPLUG) and use that function to find the nearest memory.  It
> >should return a valid node after zonelists have been rebuilt.
> >
> >Does that make sense?
> 
> Yes, besides,  I need to find a place in hotplug path to call set_numa_mem()
> just as you mentioned for ia64 platform.  Is my understanding right ?

I don't think you can use any of the "numa_mem" functions on x86[_64]
without doing a lot more work to expose memoryless nodes.  On x86_64,
numa_mem_id() and cpu_to_mem() always return the same as numa_node_id()
and cpu_to_node().  This is because x86_64 code hides memoryless nodes
and reassigns all cpus to nodes with memory.  Are you planning on
changing this such that memoryless nodes remain on-line with their cpus
associated with them?  If so, go for it!   If not, then you don't need
to [can't really, I think] use set_numa_mem()/cpu_to_mem() for your
purposes.  That's why I suggested you arrange for local_memory_node() to
be compiled for CPU_HOTPLUG and call that function directly to obtain a
nearby node from which you can allocate memory during cpu hot plug.  Or,
I could just completely misunderstand what you propose to do with these
percpu variables.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
