Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4B46B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 02:12:40 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so81585744pac.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 23:12:40 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id nt7si28374783pdb.149.2015.08.17.23.12.37
        for <linux-mm@kvack.org>;
        Mon, 17 Aug 2015 23:12:39 -0700 (PDT)
Message-ID: <55D2CC76.4020100@cn.fujitsu.com>
Date: Tue, 18 Aug 2015 14:11:02 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch V3 9/9] mm, x86: Enable memoryless node support to better
 support CPU/memory hotplug
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-1?Q?=22Jan_H=2E_?= =?ISO-8859-1?Q?Sch=F6nherr=22?= <jschoenh@amazon.de>, Igor Mammedov <imammedo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Luiz Capitulino <lcapitulino@redhat.com>, Dave Young <dyoung@redhat.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-pm@vger.kernel.org, tangchen@cn.fujitsu.com


Hi Liu,

On 08/17/2015 11:19 AM, Jiang Liu wrote:
> ......
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index b3a1a5d77d92..5d7ad70ace0d 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -2069,6 +2069,9 @@ config USE_PERCPU_NUMA_NODE_ID
>   	def_bool y
>   	depends on NUMA
>   
> +config HAVE_MEMORYLESS_NODES
> +	def_bool NUMA
> +
>   config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>   	def_bool y
>   	depends on X86_64 || X86_PAE
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 07930e1d2fe9..3403f1f0f28d 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -711,6 +711,7 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>   		}
>   		set_apicid_to_node(physid, nid);
>   		numa_set_node(cpu, nid);
> +		set_cpu_numa_mem(cpu, local_memory_node(nid));
>   	}
>   #endif
>   }
> @@ -743,9 +744,10 @@ int acpi_unmap_cpu(int cpu)
>   {
>   #ifdef CONFIG_ACPI_NUMA
>   	set_apicid_to_node(per_cpu(x86_cpu_to_apicid, cpu), NUMA_NO_NODE);
> +	set_cpu_numa_mem(cpu, NUMA_NO_NODE);
>   #endif
>   
> -	per_cpu(x86_cpu_to_apicid, cpu) = -1;
> +	per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
>   	set_cpu_present(cpu, false);
>   	num_processors--;
>   
> diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
> index b1f3ed9c7a9e..aeec91ac6fd4 100644
> --- a/arch/x86/kernel/smpboot.c
> +++ b/arch/x86/kernel/smpboot.c
> @@ -162,6 +162,8 @@ static void smp_callin(void)
>   	 */
>   	phys_id = read_apic_id();
>   
> +	set_numa_mem(local_memory_node(cpu_to_node(cpuid)));
> +
>   	/*
>   	 * the boot CPU has finished the init stage and is spinning
>   	 * on callin_map until we finish. We are free to set up this
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 08860bdf5744..f2a4e23bd14d 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -22,6 +22,7 @@
>   
>   int __initdata numa_off;
>   nodemask_t numa_nodes_parsed __initdata;
> +static nodemask_t numa_nodes_empty __initdata;
>   
>   struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
>   EXPORT_SYMBOL(node_data);
> @@ -560,17 +561,16 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>   			end = max(mi->blk[i].end, end);
>   		}
>   
> -		if (start >= end)
> -			continue;
> -
>   		/*
>   		 * Don't confuse VM with a node that doesn't have the
>   		 * minimum amount of memory:
>   		 */
> -		if (end && (end - start) < NODE_MIN_SIZE)
> -			continue;
> -
> -		alloc_node_data(nid);
> +		if (start < end && (end - start) >= NODE_MIN_SIZE) {
> +			alloc_node_data(nid);
> +		} else if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
> +			alloc_node_data(nid);
> +			node_set(nid, numa_nodes_empty);

Seeing from here, I think numa_nodes_empty represents all memory-less nodes.
So, since we still have cpu-less nodes out there, shall we rename it to
numa_nodes_memoryless or something similar ?

And BTW, does x86 support cpu-less node after these patches ?

Since I don't have any memory-less or cpu-less node on my box, I cannot 
tell it clearly.
A node is brought online when is has memory in original kernel. So I 
think it is supported.

> +		}
>   	}
>   
>   	/* Dump memblock with node info and return. */
> @@ -587,14 +587,18 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>    */
>   static void __init numa_init_array(void)
>   {
> -	int rr, i;
> +	int i, rr = MAX_NUMNODES;
>   
> -	rr = first_node(node_online_map);
>   	for (i = 0; i < nr_cpu_ids; i++) {
> +		/* Search for an onlined node with memory */
> +		do {
> +			if (rr != MAX_NUMNODES)
> +				rr = next_node(rr, node_online_map);
> +			if (rr == MAX_NUMNODES)
> +				rr = first_node(node_online_map);
> +		} while (node_isset(rr, numa_nodes_empty));
> +
>   		numa_set_node(i, rr);
> -		rr = next_node(rr, node_online_map);
> -		if (rr == MAX_NUMNODES)
> -			rr = first_node(node_online_map);
>   	}
>   }
>   
> @@ -696,9 +700,12 @@ static __init int find_near_online_node(int node)
>   {
>   	int n, val;
>   	int min_val = INT_MAX;
> -	int best_node = -1;
> +	int best_node = NUMA_NO_NODE;
>   
>   	for_each_online_node(n) {
> +		if (node_isset(n, numa_nodes_empty))
> +			continue;
> +
>   		val = node_distance(node, n);
>   
>   		if (val < min_val) {
> @@ -739,6 +746,22 @@ void __init init_cpu_to_node(void)
>   		if (!node_online(node))
>   			node = find_near_online_node(node);
>   		numa_set_node(cpu, node);

So, CPUs are still mapped to online near node, right ?

I was expecting CPUs on a memory-less node are mapped to the node they
belong to. If so, the current memory allocator may fail because they assume
each online node has memory. I was trying to do this in my patch.

https://lkml.org/lkml/2015/7/7/205

Of course, my patch is not to support memory-less node, just run into 
this problem.

> +		if (node_spanned_pages(node))
> +			set_cpu_numa_mem(cpu, node);
> +		if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
> +			node_clear(node, numa_nodes_empty);

And since we are supporting memory-less node, it's better to provide a
for_each_memoryless_node() wrapper.

> +	}
> +
> +	/* Destroy empty nodes */
> +	if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
> +		int nid;
> +		const size_t nd_size = roundup(sizeof(pg_data_t), PAGE_SIZE);
> +
> +		for_each_node_mask(nid, numa_nodes_empty) {
> +			node_set_offline(nid);
> +			memblock_free(__pa(node_data[nid]), nd_size);
> +			node_data[nid] = NULL;

So, memory-less nodes are set offline finally. It's a little different 
from what I thought.
I was expecting that both memory-less and cpu-less nodes could also be 
online after
this patch, which would be very helpful to me.

But actually, they are just exist temporarily, used to set _numa_mem_ so 
that cpu_to_mem()
is able to work, right ?

Thanks.

> +		}
>   	}
>   }
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
