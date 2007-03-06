Date: Tue, 6 Mar 2007 07:09:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
In-Reply-To: <20070305181826.GA21515@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com>
References: <20070305181826.GA21515@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007, Mark Gross wrote:

> To exercise the capability on a platform with PM-memory, you will still
> need to include a policy manager with some code to trigger the state
> changes to enable transition into and out of a low power state. 
> 

Thanks for pushing this type of work to the community.

What type of policy manager did you have in mind for state transition?  
Since you're basing it on existing NUMA code, are you looking at something 
like /sys/devices/system/node/node*/power that would be responsible for 
migrating pages off the PM-memory it represents and then transitioning the 
hardware into a suspend or standby state?

The biggest concern is obviously going to be the interleaving.

> More will be done, but for now we would like to get this base enabling
> into the upstream kernel as an initial step.
> 

Might be a premature question, but will there be upstream support for 
transitioning the hardware state?  If so, it would be interesting to hear 
what the preliminary enter and exit latencies are for each.

Few comments on the patch follow.

> diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/arch/x86_64/mm/numa.c linux-2.6.20-mm2-monroe/arch/x86_64/mm/numa.c
> --- linux-2.6.20-mm2/arch/x86_64/mm/numa.c	2007-02-23 11:20:38.000000000 -0800
> +++ linux-2.6.20-mm2-monroe/arch/x86_64/mm/numa.c	2007-03-02 15:15:53.000000000 -0800
> @@ -156,12 +156,55 @@
>  }
>  #endif
>  
> +/* we need a place to save the next start address to use for each node because
> + * we need to allocate the pgdata and bootmem for power managed memory in
> + * non-power managed nodes.  We do this by saving off where we can start
> + * allocating in the nodes and updating them as the boot up proceeds.
> + */
> +static unsigned long bootmem_start[MAX_NUMNODES];
> +

When we're going through setup_node_bootmem(), we're already going to have 
the pm_node[] information populated for power management node detection. 
It can be represented by a nodemask (see below).  So the code in 
early_node_mem() could be simplified and more robust by eliminating 
bootmem_start[] and exporting nodes_parsed from srat.c.

We can get away with this because nodes_parsed is marked __initdata and 
will still be valid at this point.

>  static void * __init
>  early_node_mem(int nodeid, unsigned long start, unsigned long end,
>  	      unsigned long size)
>  {
> -	unsigned long mem = find_e820_area(start, end, size);
> +	unsigned long mem;
>  	void *ptr;
> +	if (bootmem_start[nodeid] <= start) {
> +		bootmem_start[nodeid] = start;
> +	}
> +
> +	mem = -1L;
> +	if (power_managed_node(nodeid)) {
> +		int non_pm_node = find_closest_non_pm_node(nodeid);
> +
> +		if (!node_online(non_pm_node)) {
> +			return NULL; /* expect nodeid to get setup on the next
> +					pass of setup_node_boot_mem after
> +					non_pm_node is online*/
> +		} else {
> +			/* We set up the allocation in the non_pm_node
> +			 * get the end of non_pm_node boot allocations
> +			 * allocate from there.
> +			 */
> +			unsigned int non_pm_end;
> +
> +			non_pm_end = (NODE_DATA(non_pm_node)->node_start_pfn +
> +				NODE_DATA(non_pm_node)->node_spanned_pages)
> +					<< PAGE_SHIFT;
> +
> +			mem = find_e820_area(bootmem_start[non_pm_node],
> +					non_pm_end, size);
> +			/* now increment bootmem_start for next call */
> +			if (mem!= -1L)
> +				bootmem_start[non_pm_node] =
> +					round_up(mem + size, PAGE_SIZE);
> +		}
> +	} else {
> +		mem = find_e820_area(bootmem_start[nodeid], end, size);
> +		if (mem!= -1L)
> +			bootmem_start[nodeid] = round_up(mem + size, PAGE_SIZE);
> +	}	
>  	if (mem != -1L)
>  		return __va(mem);
>  	ptr = __alloc_bootmem_nopanic(size,

Then the change above becomes much easier:

	if (power_managed_node(nodeid)) {
		int new_node = node_remap(nodeid, *nodes_parsed, *pm_nodes);
		if (nodeid != new_node) {
			start = NODE_DATA(new_node)->node_start_pfn;
			end = start + NODE_DATA(new_node)->node_spanned_pages;
		}
	}
	mem = find_e820_area(start, end, size);

> diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/arch/x86_64/mm/srat.c linux-2.6.20-mm2-monroe/arch/x86_64/mm/srat.c
> --- linux-2.6.20-mm2/arch/x86_64/mm/srat.c	2007-02-23 11:20:38.000000000 -0800
> +++ linux-2.6.20-mm2-monroe/arch/x86_64/mm/srat.c	2007-03-02 15:15:53.000000000 -0800
> @@ -28,6 +28,7 @@
>  static nodemask_t nodes_parsed __initdata;
>  static struct bootnode nodes[MAX_NUMNODES] __initdata;
>  static struct bootnode nodes_add[MAX_NUMNODES];
> +static int pm_node[MAX_NUMNODES];
>  static int found_add_area __initdata;
>  int hotadd_percent __initdata = 0;
>  

I would recommend making this a nodemask that is an extern from 
include/asm-x86_64/numa.h:

	nodemask_t pm_nodes;

> @@ -479,5 +482,36 @@
>  
>  	return ret;
>  }
> -EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>  
> +int __power_managed_node(int srat_node)
> +{
> +	return pm_node[node_to_pxm(srat_node)];
> +}
> +
> +int __power_managed_memory_present(void)
> +{
> +	int j;
> +
> +	for (j=0; j<MAX_LOCAL_APIC; j++) {
> +		if(__power_managed_node(j) )
> +			return 1;
> +	}
> +	return 0;
> +}
> +
> +int __find_closest_non_pm_node(int nodeid)
> +{
> +	int i, dist, closest, temp;
> +
> +	dist = closest= 255;
> +	for_each_node(i) {
> +		if ((i != nodeid) && !power_managed_node(i)) {
> +			temp = __node_distance(nodeid, i );
> +			if (temp < dist) {
> +				closest = i;
> +				dist = temp;
> +			}
> +		}
> +	}
> +	return closest;
> +}

Then all these functions become trivial:

	int __power_managed_node(int nid)
	{
		return node_isset(node_to_pxm(nid), pm_nodes);
	}

	int __power_managed_memory_present(void)
	{
		return !nodes_empty(pm_nodes);
	}

	int __find_closest_non_pm_node(int nid)
	{
		int node;
		node = next_node(nid, pm_nodes);
		if (node == MAX_NUMNODES)
			node = first_node(pm_nodes);
	}

> diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/memory.c linux-2.6.20-mm2-monroe/mm/memory.c
> --- linux-2.6.20-mm2/mm/memory.c	2007-02-23 11:20:40.000000000 -0800
> +++ linux-2.6.20-mm2-monroe/mm/memory.c	2007-03-02 15:15:53.000000000 -0800
> @@ -2882,3 +2882,29 @@
>  	return buf - old_buf;
>  }
>  EXPORT_SYMBOL_GPL(access_process_vm);
> +
> +#ifdef __x86_64__
> +extern int __power_managed_memory_present(void);
> +extern int __power_managed_node(int srat_node);
> +extern int __find_closest_non_pm_node(int nodeid);
> +#else
> +inline int __power_managed_memory_present(void) { return 0};
> +inline int __power_managed_node(int srat_node) { return 0};
> +inline int __find_closest_non_pm_node(int nodeid) { return nodeid};
> +#endif
> +
> +int power_managed_memory_present(void)
> +{
> +	return __power_managed_memory_present();
> +}
> +
> +int power_managed_node(int srat_node)
> +{
> +	return __power_managed_node(srat_node);
> +}
> +
> +int find_closest_non_pm_node(int nodeid)
> +{
> +	return __find_closest_non_pm_node(nodeid);
> +}
> +

Probably should reconsider extern declarations in .c files.

> diff -urN -X linux-2.6.20-mm2/Documentation/dontdiff linux-2.6.20-mm2/mm/mempolicy.c linux-2.6.20-mm2-monroe/mm/mempolicy.c
> --- linux-2.6.20-mm2/mm/mempolicy.c	2007-02-23 11:20:40.000000000 -0800
> +++ linux-2.6.20-mm2-monroe/mm/mempolicy.c	2007-03-02 15:15:53.000000000 -0800
> @@ -1617,8 +1617,13 @@
>  	/* Set interleaving policy for system init. This way not all
>  	   the data structures allocated at system boot end up in node zero. */
>  
> -	if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
> -		printk("numa_policy_init: interleaving failed\n");
> +	if (power_managed_memory_present()) {
> +		if (do_set_mempolicy(MPOL_DEFAULT, &node_online_map))
> +			printk("numa_policy_init: interleaving failed\n");
> +	} else {
> +		if (do_set_mempolicy(MPOL_INTERLEAVE, &node_online_map))
> +			printk("numa_policy_init: interleaving failed\n");
> +	}
>  }
>  
>  /* Reset policy of current process to default */

These prink comments are misleading since MPOL_DEFAULT doesn't attempt to 
set interleaving policy.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
