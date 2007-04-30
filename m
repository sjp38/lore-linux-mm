Subject: Re: [PATCH] change global zonelist order v4 [1/2] change zonelist
	ordering.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070427150445.895cf76f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070427150445.895cf76f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 30 Apr 2007 12:12:58 -0400
Message-Id: <1177949579.5623.40.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-04-27 at 15:04 +0900, KAMEZAWA Hiroyuki wrote:
> Make zonelist creation policy selectable from sysctl v4.
> Automatic configuration itself is provided by the next patch.
> 
> [Description]
> Assume 2 node NUMA, only node(0) has ZONE_DMA.
> (ia64's ZONE_DMA is below 4GB...x86_64's ZONE_DMA32)
> 
> In this case, current default (node0's) zonelist order is
> 
> Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.
> 
> This means Node(0)'s DMA will be used before Node(1)'s NORMAL.
> 
> This patch changes *default* zone order to
> 
> Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.
> 
> But, if Node(0)'s memory is too small (near or below 4G), Node(0)'s process has
> to allocate its memory from Node(1) even if there are free memory in Node(0).
> Some applications/uses will dislike this.
> This patch adds a knob to change zonelist ordering.
> 
> [What this patch adds]
> 
> command:
> %echo N > /proc/sys/vm/numa_zonelist_order
> 
> Will rebuild zonelist in following order(old style, NODE order).
> 
> Node(0)'s NORMAL -> Node(0)'s DMA -> Node(0)'s NORMAL.
> 
> means put more priority on locality.
> 
> command:
> %echo Z > /proc/sys/vm/numa_zonelist_order
> 
> Will rebuild zonelist in following order(new style, ZONE order)
> 
> Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.
> 
> means put more priority on zone_type.
> 
> And you can specify this option as boot param.
> 
> Because autoconfig function does nothing. Default is "Node" order.
> 
> Tested on ia64 2-Node NUMA. works well.
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

sysctl documentation could use a bit of cleanup [spelling, inconsistent
statements re:  default ordering], but this can be addressed in a
separate patch.  Code looks/tested OK.

Acked-by:  Lee.Schermerhorn <lee.schermerhorn@hp.com>
> 
> ---
>  Documentation/kernel-parameters.txt |   10 +
>  Documentation/sysctl/vm.txt         |   32 ++++++
>  include/linux/mmzone.h              |    5 
>  kernel/sysctl.c                     |    9 +
>  mm/page_alloc.c                     |  185 ++++++++++++++++++++++++++++++++----
>  5 files changed, 225 insertions(+), 16 deletions(-)
> 
> Index: linux-2.6.21-rc7-mm2/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/kernel/sysctl.c
> +++ linux-2.6.21-rc7-mm2/kernel/sysctl.c
> @@ -893,6 +893,15 @@ static ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  		.extra2		= &one_hundred,
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "numa_zonelist_order",
> +		.data		= &numa_zonelist_order,
> +		.maxlen		= NUMA_ZONELIST_ORDER_LEN,
> +		.mode		= 0644,
> +		.proc_handler	= &numa_zonelist_order_handler,
> +		.strategy	= &sysctl_string,
> +	},
>  #endif
>  #if defined(CONFIG_X86_32) || \
>     (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
> Index: linux-2.6.21-rc7-mm2/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/mm/page_alloc.c
> +++ linux-2.6.21-rc7-mm2/mm/page_alloc.c
> @@ -2024,7 +2024,8 @@ void show_free_areas(void)
>   * Add all populated zones of a node to the zonelist.
>   */
>  static int __meminit build_zonelists_node(pg_data_t *pgdat,
> -			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
> +			struct zonelist *zonelist, int nr_zones,
> +			enum zone_type zone_type)
>  {
>  	struct zone *zone;
>  
> @@ -2045,7 +2046,7 @@ static int __meminit build_zonelists_nod
>  
>  #ifdef CONFIG_NUMA
>  #define MAX_NODE_LOAD (num_online_nodes())
> -static int __meminitdata node_load[MAX_NUMNODES];
> +static int node_load[MAX_NUMNODES];
>  /**
>   * find_next_best_node - find the next node that should appear in a given node's fallback list
>   * @node: node whose fallback list we're appending
> @@ -2060,7 +2061,7 @@ static int __meminitdata node_load[MAX_N
>   * on them otherwise.
>   * It returns -1 if no node is found.
>   */
> -static int __meminit find_next_best_node(int node, nodemask_t *used_node_mask)
> +static int find_next_best_node(int node, nodemask_t *used_node_mask)
>  {
>  	int n, val;
>  	int min_val = INT_MAX;
> @@ -2106,13 +2107,124 @@ static int __meminit find_next_best_node
>  	return best_node;
>  }
>  
> -static void __meminit build_zonelists(pg_data_t *pgdat)
> +/*
> + * numa_zonelist_order:
> + *  0 = automatic detection of better ordering.
> + *  1 = order by ([node] distance, -zonetype)
> + *  2 = order by (-zonetype, [node] distance)
> + */
> +#define ZONELIST_ORDER_AUTO	0
> +#define ZONELIST_ORDER_NODE	1
> +#define ZONELIST_ORDER_ZONE	2
> +static int zonelist_order = 0;
> +
> +/*
> + * command line option "numa_zonelist_order"
> + *	= "[dD]efault | "0"	- default, automatic configuration.
> + *	= "[nN]ode"|"1" 	- order by node locality,
> + *         			  then zone within node.
> + *	= "[zZ]one"|"2" - order by zone, then by locality within zone
> + */
> +char numa_zonelist_order[NUMA_ZONELIST_ORDER_LEN] = "default";
> +
> +static int __parse_numa_zonelist_order(char *s)
> +{
> +	if (*s == 'd' || *s == 'D' || *s == '0') {
> +		strncpy(numa_zonelist_order, "default",
> +					NUMA_ZONELIST_ORDER_LEN);
> +		zonelist_order = ZONELIST_ORDER_AUTO;
> +	} else if (*s == 'n' || *s == 'N' || *s == '1') {
> +		strncpy(numa_zonelist_order, "node",
> +					NUMA_ZONELIST_ORDER_LEN);
> +		zonelist_order = ZONELIST_ORDER_NODE;
> +	} else if (*s == 'z' || *s == 'Z' || *s == '2') {
> +		strncpy(numa_zonelist_order, "zone",
> +					NUMA_ZONELIST_ORDER_LEN);
> +		zonelist_order = ZONELIST_ORDER_ZONE;
> +	} else {
> +		printk(KERN_WARNING
> +			"Ignoring invalid numa_zonelist_order value:  "
> +			"%s\n", s);
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +static __init int setup_numa_zonelist_order(char *s)
> +{
> +	if (s)
> +		return __parse_numa_zonelist_order(s);
> +	return 0;
> +}
> +early_param("numa_zonelist_order", setup_numa_zonelist_order);
> +
> +/*
> + * Build zonelists ordered by node and zones within node.
> + * This results in maximum locality--normal zone overflows into local
> + * DMA zone, if any--but risks exhausting DMA zone.
> + */
> +static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
>  {
> -	int j, node, local_node;
>  	enum zone_type i;
> -	int prev_node, load;
> +	int j;
> +	struct zonelist *zonelist;
> +
> +	for (i = 0; i < MAX_NR_ZONES; i++) {
> +		zonelist = pgdat->node_zonelists + i;
> +		for (j = 0; zonelist->zones[j] != NULL; j++);
> +
> + 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
> +		zonelist->zones[j] = NULL;
> +	}
> +}
> +
> +/*
> + * Build zonelists ordered by zone and nodes within zones.
> + * This results in conserving DMA zone[s] until all Normal memory is
> + * exhausted, but results in overflowing to remote node while memory
> + * may still exist in local DMA zone.
> + */
> +static int node_order[MAX_NUMNODES];
> +
> +static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
> +{
> +	enum zone_type i;
> +	int pos, j, node;
> +	int zone_type;		/* needs to be signed */
> +	struct zone *z;
>  	struct zonelist *zonelist;
> +
> +	for (i = 0; i < MAX_NR_ZONES; i++) {
> +		zonelist = pgdat->node_zonelists + i;
> +		pos = 0;
> +		for (zone_type = i; zone_type >= 0; zone_type--) {
> +			for (j = 0; j < nr_nodes; j++) {
> +				node = node_order[j];
> +				z = &NODE_DATA(node)->node_zones[zone_type];
> +				if (populated_zone(z))
> +					zonelist->zones[pos++] = z;
> +			}
> +		}
> +		zonelist->zones[pos] = NULL;
> +	}
> +}
> +
> +static int estimate_zonelist_order(void)
> +{
> +	/* dummy, just select node order. */
> +	return ZONELIST_ORDER_NODE;
> +}
> +
> +
> +
> +static void build_zonelists(pg_data_t *pgdat)
> +{
> +	int j, node, load;
> +	enum zone_type i;
>  	nodemask_t used_mask;
> +	int local_node, prev_node;
> +	struct zonelist *zonelist;
> +	int ordering;
>  
>  	/* initialize zonelists */
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> @@ -2120,11 +2232,18 @@ static void __meminit build_zonelists(pg
>  		zonelist->zones[0] = NULL;
>  	}
>  
> +	ordering = zonelist_order;
> +	if (ordering == ZONELIST_ORDER_AUTO)
> +		ordering = estimate_zonelist_order();
>  	/* NUMA-aware ordering of nodes */
>  	local_node = pgdat->node_id;
>  	load = num_online_nodes();
>  	prev_node = local_node;
>  	nodes_clear(used_mask);
> +
> +	memset(node_order, 0, sizeof(node_order));
> +	j = 0;
> +
>  	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
>  		int distance = node_distance(local_node, node);
>  
> @@ -2140,18 +2259,20 @@ static void __meminit build_zonelists(pg
>  		 * So adding penalty to the first node in same
>  		 * distance group to make it round-robin.
>  		 */
> -
>  		if (distance != node_distance(local_node, prev_node))
> -			node_load[node] += load;
> +			node_load[node] = load;
> +
>  		prev_node = node;
>  		load--;
> -		for (i = 0; i < MAX_NR_ZONES; i++) {
> -			zonelist = pgdat->node_zonelists + i;
> -			for (j = 0; zonelist->zones[j] != NULL; j++);
> +		if (ordering == ZONELIST_ORDER_NODE)	/* default */
> +			build_zonelists_in_node_order(pgdat, node);
> +		else
> +			node_order[j++] = node;	/* remember order */
> +	}
>  
> -	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
> -			zonelist->zones[j] = NULL;
> -		}
> +	if (ordering == ZONELIST_ORDER_ZONE) {
> +		/* calculate node order -- i.e., DMA last! */
> +		build_zonelists_in_zone_order(pgdat, j);
>  	}
>  }
>  
> @@ -2173,6 +2294,37 @@ static void __meminit build_zonelist_cac
>  	}
>  }
>  
> +/*
> + * sysctl handler for numa_zonelist_order
> + */
> +int numa_zonelist_order_handler(ctl_table *table, int write,
> +		struct file *file, void __user *buffer, size_t *length,
> +		loff_t *ppos)
> +{
> +	char saved_string[NUMA_ZONELIST_ORDER_LEN];
> +	int ret;
> +
> +	if (write)
> +		strncpy(saved_string, (char*)table->data,
> +			NUMA_ZONELIST_ORDER_LEN);
> +	ret = proc_dostring(table, write, file, buffer, length, ppos);
> +	if (ret)
> +		return ret;
> +	if (write) {
> +		int oldval = zonelist_order;
> +		if (__parse_numa_zonelist_order((char*)table->data)) {
> +			/*
> +			 * bogus value.  restore saved string
> +			 */
> +			strncpy((char*)table->data, saved_string,
> +				NUMA_ZONELIST_ORDER_LEN);
> +			zonelist_order = oldval;
> +		} else if (oldval != zonelist_order)
> +			build_all_zonelists();
> +	}
> +	return 0;
> +}
> +
>  #else	/* CONFIG_NUMA */
>  
>  static void __meminit build_zonelists(pg_data_t *pgdat)
> @@ -2222,7 +2374,7 @@ static void __meminit build_zonelist_cac
>  #endif	/* CONFIG_NUMA */
>  
>  /* return values int ....just for stop_machine_run() */
> -static int __meminit __build_all_zonelists(void *dummy)
> +static int __build_all_zonelists(void *dummy)
>  {
>  	int nid;
>  
> @@ -2233,12 +2385,13 @@ static int __meminit __build_all_zonelis
>  	return 0;
>  }
>  
> -void __meminit build_all_zonelists(void)
> +void build_all_zonelists(void)
>  {
>  	if (system_state == SYSTEM_BOOTING) {
>  		__build_all_zonelists(NULL);
>  		cpuset_init_current_mems_allowed();
>  	} else {
> +		memset(node_load, 0, sizeof(node_load));
>  		/* we have to stop all cpus to guaranntee there is no user
>  		   of zonelist */
>  		stop_machine_run(__build_all_zonelists, NULL, NR_CPUS);
> Index: linux-2.6.21-rc7-mm2/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/mmzone.h
> +++ linux-2.6.21-rc7-mm2/include/linux/mmzone.h
> @@ -608,6 +608,11 @@ int sysctl_min_unmapped_ratio_sysctl_han
>  int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
>  			struct file *, void __user *, size_t *, loff_t *);
>  
> +extern int numa_zonelist_order_handler(struct ctl_table *, int,
> +			struct file *, void __user *, size_t *, loff_t *);
> +extern char numa_zonelist_order[];
> +#define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
> +
>  #include <linux/topology.h>
>  /* Returns the number of the current Node. */
>  #ifndef numa_node_id
> Index: linux-2.6.21-rc7-mm2/Documentation/kernel-parameters.txt
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/Documentation/kernel-parameters.txt
> +++ linux-2.6.21-rc7-mm2/Documentation/kernel-parameters.txt
> @@ -1500,6 +1500,16 @@ and is between 256 and 4096 characters. 
>  			Format: <reboot_mode>[,<reboot_mode2>[,...]]
>  			See arch/*/kernel/reboot.c or arch/*/kernel/process.c			
>  
> +	numa_zonelist_order [KNL,BOOT]
> +			Select memory allocation zonelist order for NUMA
> +			platform.  Default is automatic configuration.
> +			"Node order" orders the zonelists by node [locality],
> +			then zones within nodes.  "Zone order" orders the
> +			zonelists by zone,then nodes within the zone.
> +			This moves DMA zone, if any, to the end of the
> +			allocation lists.
> +			See also Documentation/sysctl/vm.txt
> +
>  	reserve=	[KNL,BUGS] Force the kernel to ignore some iomem area
>  
>  	reservetop=	[X86-32]
> Index: linux-2.6.21-rc7-mm2/Documentation/sysctl/vm.txt
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/Documentation/sysctl/vm.txt
> +++ linux-2.6.21-rc7-mm2/Documentation/sysctl/vm.txt
> @@ -34,6 +34,7 @@ Currently, these files are in /proc/sys/
>  - swap_prefetch
>  - readahead_ratio
>  - readahead_hit_rate
> +- numa_zonelist_order
>  
>  ==============================================================
>  
> @@ -275,3 +276,34 @@ Possible values can be:
>  The larger value, the more capabilities, with more possible overheads.
>  
>  The default value is 1.
> +
> +=============================================================
> +
> +numa_zonelist_order
> +
> +This sysctl is only for NUMA.
> +
> +numa_zonelist_order selects the order of the memory allocation zonelists.
> +The default order [a.k.a. "node order"] orders the zonelists by node, the
                                                                         then
> +by zone within each node. The default is automatic configuration.
> +Specify "[Dd]fault" or "0" to request automatic configuration.
           "[Dd]efault"  but maybe should be "[Aa]uto" based on Kame's
rework and to avoid confusion w/rt node order being default? ...
> +
> + For example, assume 2 Node NUMA.  The "Node order" kernel memory allocation
> +order on Node(0) will be:
> +
> +	Node(0)NORMAL -> Node(0)DMA -> Node(1)NORMAL -> Node(1)DMA(if any)
> +
> +Thus, allocations that request Node(0) NORMAL may overflow onto Node(0)DMA
> +first.  This provides maximum locality, but risks exhausting all of DMA
> +memory while NORMAL memory exists elsewhere on the system.  This can result
> +in OOM-KILL in ZONE_DMA.  Secify "[Zz]one" or "1" to request zone order.
> +
> +If numa_zonelist_order is set to "node" order, the kernel memory allocation
> +order on Node(0) becomes:
> +
> +	Node(0)NORMAL -> Node(1)NORMAL -> Node(0)DMA -> Node(1)DMA(if any)
> +
> +In this mode, DMA memory will be used in place of NORMAL memory, only when
> +all NORMAL zones are exhausted.  Specify "[Nn]ode" or "2" for node order.
> +
> +The default value is 0.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
