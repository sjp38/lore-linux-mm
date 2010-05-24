Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B20EB6B01B1
	for <linux-mm@kvack.org>; Sun, 23 May 2010 21:04:39 -0400 (EDT)
From: "Guo, Chaohong" <chaohong.guo@intel.com>
Date: Mon, 24 May 2010 09:03:53 +0800
Subject: RE: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-ID: <CF2F38D4AE21BB4CB845318E4C5ECB671E790500@shsmsx501.ccr.corp.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	 <20100520134359.fdfb397e.akpm@linux-foundation.org>
	 <20100521105512.0c2cf254.sfr@canb.auug.org.au>
	 <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF642BB.2020402@linux.intel.com>
	 <20100521173940.8f130205.kamezawa.hiroyu@jp.fujitsu.com>
	 <4BF64E79.4010401@linux.intel.com>
 <1274448107.9131.87.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1274448107.9131.87.camel@useless.americas.hpqcorp.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minskey guo <chaohong_guo@linux.intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "prarit@redhat.com" <prarit@redhat.com>, "Kleen, Andi" <andi.kleen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, "stable@kernel.org" <stable@kernel.org>
List-ID: <linux-mm.kvack.org>



>> >>
>> >>
>> >> @@ -2968,9 +2991,23 @@ static int __build_all_zonelists(void *d
>> >> ...
>> >>
>> >> -	for_each_possible_cpu(cpu)
>> >> +	for_each_possible_cpu(cpu) {
>> >> 		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
>> >> ...
>> >>
>> >> +#ifdef CONFIG_HAVE_MEMORYLESS_NODES
>> >> + 	if (cpu_online(cpu))
>> >> +		cpu_to_mem(cpu) =3D local_memory_node(cpu_to_node(cpu));
>> >> +#endif
>>
>> Look at the above code,  int __build_all_zonelists(),  cpu_to_mem(cpu)
>> is set only when cpu is onlined.  Suppose that a node with local memory,
>> all memory segments are onlined first, and then,  cpus within that node
>> are onlined one by one,  in this case,  where does the cpu_to_mem(cpu)
>> for the last cpu get its value ?
>
>Minskey:
>
>As I mentioned to Kame-san, x86 does not define
>CONFIG_HAVE_MEMORYLESS_NODES, so this code is not compiled for that
>arch.  If x86 did support memoryless nodes--i.e., did not hide them and
>reassign the cpus to other nodes, as is the case for ia64--then we could
>have on-line cpus associated with memoryless nodes.  The code above is
>in __build_all_zonelists() so that in the case where we add memory to a
>previously memoryless node, we re-evaluate the "local memory node" for
>all online cpus.
>
>For cpu hotplug--again, if x86 supports memoryless nodes--we'll need to
>add a similar chunk to the path where we set up the cpu_to_node map for
>a hotplugged cpu.  See, for example, the call to set_numa_mem() in
>smp_callin() in arch/ia64/kernel/smpboot.c.=20


Yeah, that's what I am looking for.=20



 But currently, I don't
>think you can use the numa_mem_id()/cpu_to_mem() interfaces for your
>purpose.  I suppose you could change page_alloc.c to compile
>local_memory_node() #if defined(CONFIG_HAVE_MEMORYLESS_NODES) ||
>defined
>(CPU_HOTPLUG) and use that function to find the nearest memory.  It
>should return a valid node after zonelists have been rebuilt.
>
>Does that make sense?

Yes, besides,  I need to find a place in hotplug path to call set_numa_mem(=
)
just as you mentioned for ia64 platform.  Is my understanding right ?




Thanks,
-minskey








>
>Lee
>>
>>
>> >
>> > So, cpu_to_node(cpu) for possible cpus will have NUMA_NO_NODE(-1)
>> > or the number of the nearest node.
>> >
>> > IIUC, if SRAT is not broken, all pxm has its own node_id.
>>
>> Thank you very much for the info,  I have been thinking why node_id
>> is (-1) in some cases.
>>
>>
>> -minskey
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
