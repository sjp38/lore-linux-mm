Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C33ED6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:31:43 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so87225454wic.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 00:31:43 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id kt9si31871733wjc.8.2015.08.18.00.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 00:31:41 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so87612662wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 00:31:41 -0700 (PDT)
Date: Tue, 18 Aug 2015 09:31:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [Patch V3 9/9] mm, x86: Enable memoryless node support to better
 support CPU/memory hotplug
Message-ID: <20150818073136.GA22311@gmail.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan =?iso-8859-1?Q?H=2E_Sch=F6nherr?= <jschoenh@amazon.de>, Igor Mammedov <imammedo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Luiz Capitulino <lcapitulino@redhat.com>, Dave Young <dyoung@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org


* Jiang Liu <jiang.liu@linux.intel.com> wrote:

> With current implementation, all CPUs within a NUMA node will be
> assocaited with another NUMA node if the node has no memory installed.

typo.

> 
> For example, on a four-node system, CPUs on node 2 and 3 are associated
> with node 0 when are no memory install on node 2 and 3, which may
> confuse users.
>
> root@bkd01sdp:~# numactl --hardware
> available: 2 nodes (0-1)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
> node 0 size: 15602 MB
> node 0 free: 15014 MB
> node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
> node 1 size: 15985 MB
> node 1 free: 15686 MB
> node distances:
> node   0   1
>   0:  10  21
>   1:  21  10
> 
> To be worse, the CPU affinity relationship won't get fixed even after
> memory has been added to those nodes. After memory hot-addition to
> node 2, CPUs on node 2 are still associated with node 0. This may cause
> sub-optimal performance.
> root@bkd01sdp:/sys/devices/system/node/node2# numactl --hardware
> available: 3 nodes (0-2)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
> node 0 size: 15602 MB
> node 0 free: 14743 MB
> node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
> node 1 size: 15985 MB
> node 1 free: 15715 MB
> node 2 cpus:
> node 2 size: 128 MB
> node 2 free: 128 MB
> node distances:
> node   0   1   2
>   0:  10  21  21
>   1:  21  10  21
>   2:  21  21  10
> 
> With support of memoryless node enabled, it will correctly report system
> hardware topology for nodes without memory installed.
> root@bkd01sdp:~# numactl --hardware
> available: 4 nodes (0-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
> node 0 size: 15725 MB
> node 0 free: 15129 MB
> node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
> node 1 size: 15862 MB
> node 1 free: 15627 MB
> node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104
> node 2 size: 0 MB
> node 2 free: 0 MB
> node 3 cpus: 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
> node 3 size: 0 MB
> node 3 free: 0 MB
> node distances:
> node   0   1   2   3
>   0:  10  21  21  21
>   1:  21  10  21  21
>   2:  21  21  10  21
>   3:  21  21  21  10
> 
> With memoryless node enabled, CPUs are correctly associated with node 2
> after memory hot-addition to node 2.
> root@bkd01sdp:/sys/devices/system/node/node2# numactl --hardware
> available: 4 nodes (0-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74
> node 0 size: 15725 MB
> node 0 free: 14872 MB
> node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89
> node 1 size: 15862 MB
> node 1 free: 15641 MB
> node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104
> node 2 size: 128 MB
> node 2 free: 127 MB
> node 3 cpus: 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
> node 3 size: 0 MB
> node 3 free: 0 MB
> node distances:
> node   0   1   2   3
>   0:  10  21  21  21
>   1:  21  10  21  21
>   2:  21  21  10  21
>   3:  21  21  21  10
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  arch/x86/Kconfig            |    3 +++
>  arch/x86/kernel/acpi/boot.c |    4 +++-
>  arch/x86/kernel/smpboot.c   |    2 ++
>  arch/x86/mm/numa.c          |   49 +++++++++++++++++++++++++++++++------------
>  4 files changed, 44 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index b3a1a5d77d92..5d7ad70ace0d 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -2069,6 +2069,9 @@ config USE_PERCPU_NUMA_NODE_ID
>  	def_bool y
>  	depends on NUMA
>  
> +config HAVE_MEMORYLESS_NODES
> +	def_bool NUMA
> +
>  config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  	def_bool y
>  	depends on X86_64 || X86_PAE
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 07930e1d2fe9..3403f1f0f28d 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -711,6 +711,7 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  		}
>  		set_apicid_to_node(physid, nid);
>  		numa_set_node(cpu, nid);
> +		set_cpu_numa_mem(cpu, local_memory_node(nid));
>  	}
>  #endif
>  }
> @@ -743,9 +744,10 @@ int acpi_unmap_cpu(int cpu)
>  {
>  #ifdef CONFIG_ACPI_NUMA
>  	set_apicid_to_node(per_cpu(x86_cpu_to_apicid, cpu), NUMA_NO_NODE);
> +	set_cpu_numa_mem(cpu, NUMA_NO_NODE);
>  #endif
>  
> -	per_cpu(x86_cpu_to_apicid, cpu) = -1;
> +	per_cpu(x86_cpu_to_apicid, cpu) = BAD_APICID;
>  	set_cpu_present(cpu, false);
>  	num_processors--;
>  
> diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
> index b1f3ed9c7a9e..aeec91ac6fd4 100644
> --- a/arch/x86/kernel/smpboot.c
> +++ b/arch/x86/kernel/smpboot.c
> @@ -162,6 +162,8 @@ static void smp_callin(void)
>  	 */
>  	phys_id = read_apic_id();
>  
> +	set_numa_mem(local_memory_node(cpu_to_node(cpuid)));
> +
>  	/*
>  	 * the boot CPU has finished the init stage and is spinning
>  	 * on callin_map until we finish. We are free to set up this
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 08860bdf5744..f2a4e23bd14d 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -22,6 +22,7 @@
>  
>  int __initdata numa_off;
>  nodemask_t numa_nodes_parsed __initdata;
> +static nodemask_t numa_nodes_empty __initdata;
>  
>  struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
>  EXPORT_SYMBOL(node_data);
> @@ -560,17 +561,16 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>  			end = max(mi->blk[i].end, end);
>  		}
>  
> -		if (start >= end)
> -			continue;
> -
>  		/*
>  		 * Don't confuse VM with a node that doesn't have the
>  		 * minimum amount of memory:
>  		 */
> -		if (end && (end - start) < NODE_MIN_SIZE)
> -			continue;
> -
> -		alloc_node_data(nid);
> +		if (start < end && (end - start) >= NODE_MIN_SIZE) {
> +			alloc_node_data(nid);
> +		} else if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
> +			alloc_node_data(nid);
> +			node_set(nid, numa_nodes_empty);
> +		}
>  	}
>  
>  	/* Dump memblock with node info and return. */
> @@ -587,14 +587,18 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
>   */
>  static void __init numa_init_array(void)
>  {
> -	int rr, i;
> +	int i, rr = MAX_NUMNODES;
>  
> -	rr = first_node(node_online_map);
>  	for (i = 0; i < nr_cpu_ids; i++) {
> +		/* Search for an onlined node with memory */
> +		do {
> +			if (rr != MAX_NUMNODES)
> +				rr = next_node(rr, node_online_map);
> +			if (rr == MAX_NUMNODES)
> +				rr = first_node(node_online_map);
> +		} while (node_isset(rr, numa_nodes_empty));
> +
>  		numa_set_node(i, rr);
> -		rr = next_node(rr, node_online_map);
> -		if (rr == MAX_NUMNODES)
> -			rr = first_node(node_online_map);
>  	}
>  }
>  
> @@ -696,9 +700,12 @@ static __init int find_near_online_node(int node)
>  {
>  	int n, val;
>  	int min_val = INT_MAX;
> -	int best_node = -1;
> +	int best_node = NUMA_NO_NODE;
>  
>  	for_each_online_node(n) {
> +		if (node_isset(n, numa_nodes_empty))
> +			continue;
> +
>  		val = node_distance(node, n);
>  
>  		if (val < min_val) {
> @@ -739,6 +746,22 @@ void __init init_cpu_to_node(void)
>  		if (!node_online(node))
>  			node = find_near_online_node(node);
>  		numa_set_node(cpu, node);
> +		if (node_spanned_pages(node))
> +			set_cpu_numa_mem(cpu, node);
> +		if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
> +			node_clear(node, numa_nodes_empty);
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
> +		}
>  	}
>  }

So this patch makes messy code even messier.

I'd like to see the fixes, but this really needs to be done cleaner.

There are several problems:

1) the naming is not clear enough between VM and scheduling nodes and their masks. 
   For example we are mixing uses of 'numa_nodes_empty' (a memory space concept),
   'node_online_map' (a scheduling concept), which makes the code hard to read.

   To add insult to injury, 'numa_nodes_empty' is added with zero comments:

       > +static nodemask_t numa_nodes_empty __initdata;

   To resolve this the names should be clearer I think. Something like 
   numa_nomem_mask or so.

2) the existing code is (unfortunately) confusing to begin with. For example what 
   does find_near_online_node() do? It's not commented.

   init_cpu_to_node() has comments but it's mostly implementational gibberish that 
   does not answer the question of what the function's main, high level purpose 
   is. I'm uneasy about modifying code that is hard to read - it should be 
   improved first.

3)

   So I'm wondering about logic like this:

> +		if (node_spanned_pages(node))
> +			set_cpu_numa_mem(cpu, node);

   So first we link the node in the _numa_mem_ array if the node has memory (?).

> +		if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES))
> +			node_clear(node, numa_nodes_empty);

   But we unconditionally clear it in the numa_nodes_empty - i.e. it has memory?
   Shouldn't the node_clear() be inside the 'has memory' condition?

4)

    Bits like this are confusing:

> +	/* Destroy empty nodes */
> +	if (IS_ENABLED(CONFIG_HAVE_MEMORYLESS_NODES)) {
> +		int nid;
> +		const size_t nd_size = roundup(sizeof(pg_data_t), PAGE_SIZE);

    Why do we 'destroy' them? What does 'destroy' mean here?

So I think this series should first make the whole code readable and 
understandable - then fix the bugs as gradually as possible: one bug one patch.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
