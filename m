Subject: Re: [PATCH] change zonelist order v5 [1/3] implements zonelist
	order selection
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070508201642.c63b3f65.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 08 May 2007 13:06:25 -0400
Message-Id: <1178643985.5203.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-08 at 20:16 +0900, KAMEZAWA Hiroyuki wrote:
> Make zonelist creation policy selectable from sysctl/boot option v5.
> 
> This patch makes NUMA's zonelist (of pgdat) order selectable.
> Available order are Default(automatic)/ Node-based / Zone-based.
> 
> [Default Order]
> The kernel selects Node-based or Zone-based order automatically.
> 
> [Node-based Order]
> This policy treats the locality of memory as the most important parameter.
> Zonelist order is created by each zone's locality. This means lower zones
> (ex. ZONE_DMA) can be used before higher zone (ex. ZONE_NORMAL) exhausion.
> IOW. ZONE_DMA will be in the middle of zonelist.
> current 2.6.21 kernel uses this.
> 
> Pros.
>  * A user can expect local memory as much as possible.
> Cons.
>  * lower zone will be exhansted before higher zone. This may cause OOM_KILL.
> 
> Maybe suitable if ZONE_DMA is relatively big and you never see OOM_KILL
> because of ZONE_DMA exhaution and you need the best locality.
> 
> (example)
> assume 2 node NUMA. node(0) has ZONE_DMA/ZONE_NORMAL, node(1) has ZONE_NORMAL.
> 
> *node(0)'s memory allocation order:
> 
>  node(0)'s NORMAL -> node(0)'s DMA -> node(1)'s NORMAL.
> 
> *node(1)'s memory allocation order:
>  
>  node(1)'s NORMAL -> node(0)'s NORMAL -> node(0)'s DMA.
> 
> [Zone-based order]
> This policy treats the zone type as the most important parameter.
> Zonelist order is created by zone-type order. This means lower zone 
> never be used bofere higher zone exhaustion.
> IOW. ZONE_DMA will be always at the tail of zonelist.
> 
> Pros.
>  * OOM_KILL(bacause of lower zone) occurs only if the whole zones are exhausted.
> Cons.
>  * memory locality may not be best.
> 
> (example)
> assume 2 node NUMA. node(0) has ZONE_DMA/ZONE_NORMAL, node(1) has ZONE_NORMAL.
> 
> *node(0)'s memory allocation order:
> 
>  node(0)'s NORMAL -> node(1)'s NORMAL -> node(0)'s DMA.
> 
> *node(1)'s memory allocation order:
> 
>  node(1)'s NORMAL -> node(0)'s NORMAL -> node(0)'s DMA.
> 
> bootoption "numa_zonelist_order=" and proc/sysctl is supporetd.
> 
> command:
> %echo N > /proc/sys/vm/numa_zonelist_order
> 
> Will rebuild zonelist in Node-based order.
> 
> command:
> %echo Z > /proc/sys/vm/numa_zonelist_order
> 
> Will rebuild zonelist in Zone-based order.
> 
> Tested on ia64 2-Node NUMA. works well.
> 
> Thanks to Lee Schermerhorn, he gives me much help and codes.
> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Tested OK on my platform.
Acked-by:   Lee Schermerhorn <lee.schermerhorn@hp.com>

> 
> ---
>  include/linux/mmzone.h |    5 +
>  kernel/sysctl.c        |    9 ++
>  mm/page_alloc.c        |  217 ++++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 209 insertions(+), 22 deletions(-)
> 
> Index: linux-2.6.21-mm1/kernel/sysctl.c
> ===================================================================
> --- linux-2.6.21-mm1.orig/kernel/sysctl.c
> +++ linux-2.6.21-mm1/kernel/sysctl.c
> @@ -891,6 +891,15 @@ static ctl_table vm_table[] = {
>  		.proc_handler	= &proc_dointvec_jiffies,
>  		.strategy	= &sysctl_jiffies,
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
> Index: linux-2.6.21-mm1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.21-mm1.orig/mm/page_alloc.c
> +++ linux-2.6.21-mm1/mm/page_alloc.c
> @@ -2023,7 +2023,8 @@ void show_free_areas(void)
>   * Add all populated zones of a node to the zonelist.
>   */
>  static int __meminit build_zonelists_node(pg_data_t *pgdat,
> -			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
> +			struct zonelist *zonelist, int nr_zones,
> +			enum zone_type zone_type)
>  {
>  	struct zone *zone;
>  
> @@ -2042,9 +2043,97 @@ static int __meminit build_zonelists_nod
>  	return nr_zones;
>  }
>  
> +
> +/*
> + *  zonelist_order:
> + *  0 = automatic detection of better ordering.
> + *  1 = order by ([node] distance, -zonetype)
> + *  2 = order by (-zonetype, [node] distance)
> + *
> + *  If not NUMA, ZONELIST_ORDER_ZONE and ZONELIST_ORDER_NODE will create
> + *  the same zonelist. So only NUMA can configure this param.
> + */
> +#define ZONELIST_ORDER_DEFAULT  0
> +#define ZONELIST_ORDER_NODE     1
> +#define ZONELIST_ORDER_ZONE     2
> +
> +static int zonelist_order = ZONELIST_ORDER_DEFAULT;
> +static char zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
> +
> +
>  #ifdef CONFIG_NUMA
> +/* string for sysctl */
> +#define NUMA_ZONELIST_ORDER_LEN	16
> +char numa_zonelist_order[16] = "default";
> +
> +/*
> + * interface for configure zonelist ordering.
> + * command line option "numa_zonelist_order"
> + *	= "[dD]efault	- default, automatic configuration.
> + *	= "[nN]ode 	- order by node locality, then by zone within node
> + *	= "[zZ]one      - order by zone, then by locality within zone
> + */
> +
> +static int __parse_numa_zonelist_order(char *s)
> +{
> +	if (*s == 'd' || *s == 'D') {
> +		zonelist_order = ZONELIST_ORDER_DEFAULT;
> +	} else if (*s == 'n' || *s == 'N') {
> +		zonelist_order = ZONELIST_ORDER_NODE;
> +	} else if (*s == 'z' || *s == 'Z') {
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
> +
>  #define MAX_NODE_LOAD (num_online_nodes())
> -static int __meminitdata node_load[MAX_NUMNODES];
> +static int node_load[MAX_NUMNODES];
> +
>  /**
>   * find_next_best_node - find the next node that should appear in a given node's fallback list
>   * @node: node whose fallback list we're appending
> @@ -2059,7 +2148,7 @@ static int __meminitdata node_load[MAX_N
>   * on them otherwise.
>   * It returns -1 if no node is found.
>   */
> -static int __meminit find_next_best_node(int node, nodemask_t *used_node_mask)
> +static int find_next_best_node(int node, nodemask_t *used_node_mask)
>  {
>  	int n, val;
>  	int min_val = INT_MAX;
> @@ -2105,13 +2194,73 @@ static int __meminit find_next_best_node
>  	return best_node;
>  }
>  
> -static void __meminit build_zonelists(pg_data_t *pgdat)
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
>  	struct zonelist *zonelist;
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
> +	struct zonelist *zonelist;
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
> +static int default_zonelist_order(void)
> +{
> +	/* dummy, just select node order. */
> +	return ZONELIST_ORDER_NODE;
> +}
> +
> +
> +
> +static void build_zonelists(pg_data_t *pgdat, int ordering)
> +{
> +	int j, node, load;
> +	enum zone_type i;
>  	nodemask_t used_mask;
> +	int local_node, prev_node;
> +	struct zonelist *zonelist;
>  
>  	/* initialize zonelists */
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> @@ -2124,6 +2273,10 @@ static void __meminit build_zonelists(pg
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
> @@ -2139,18 +2292,20 @@ static void __meminit build_zonelists(pg
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
> +		if (ordering == ZONELIST_ORDER_NODE)
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
> @@ -2172,9 +2327,18 @@ static void __meminit build_zonelist_cac
>  	}
>  }
>  
> +
>  #else	/* CONFIG_NUMA */
>  
> -static void __meminit build_zonelists(pg_data_t *pgdat)
> +static int default_zonelist_order(void)
> +{
> +	return ZONELIST_ORDER_ZONE;
> +}
> +
> +/*
> + * order is ignored.
> + */
> +static void __meminit build_zonelists(pg_data_t *pgdat, int order)
>  {
>  	int node, local_node;
>  	enum zone_type i,j;
> @@ -2221,26 +2385,33 @@ static void __meminit build_zonelist_cac
>  #endif	/* CONFIG_NUMA */
>  
>  /* return values int ....just for stop_machine_run() */
> -static int __meminit __build_all_zonelists(void *dummy)
> +static int __build_all_zonelists(void *dummy)
>  {
>  	int nid;
> -
> +	int order = *(int *)dummy;
>  	for_each_online_node(nid) {
> -		build_zonelists(NODE_DATA(nid));
> +		build_zonelists(NODE_DATA(nid), order);
>  		build_zonelist_cache(NODE_DATA(nid));
>  	}
>  	return 0;
>  }
>  
> -void __meminit build_all_zonelists(void)
> +void build_all_zonelists(void)
>  {
> +	int order;
> +	if (zonelist_order == ZONELIST_ORDER_DEFAULT)
> +		order = default_zonelist_order();
> +	else
> +		order = zonelist_order;
> +
>  	if (system_state == SYSTEM_BOOTING) {
> -		__build_all_zonelists(NULL);
> +		__build_all_zonelists(&order);
>  		cpuset_init_current_mems_allowed();
>  	} else {
> +		memset(node_load, 0, sizeof(node_load));
>  		/* we have to stop all cpus to guaranntee there is no user
>  		   of zonelist */
> -		stop_machine_run(__build_all_zonelists, NULL, NR_CPUS);
> +		stop_machine_run(__build_all_zonelists, &order, NR_CPUS);
>  		/* cpuset refresh routine should be here */
>  	}
>  	vm_total_pages = nr_free_pagecache_pages();
> @@ -2257,8 +2428,10 @@ void __meminit build_all_zonelists(void)
>  	else
>  		page_group_by_mobility_disabled = 0;
>  
> -	printk("Built %i zonelists, mobility grouping %s.  Total pages: %ld\n",
> +	printk("Built %i zonelists in %s order, mobility grouping %s."
> +	       "Total pages: %ld\n",
>  			num_online_nodes(),
> +			zonelist_order_name[order],
>  			page_group_by_mobility_disabled ? "off" : "on",
>  			vm_total_pages);
>  }
> Index: linux-2.6.21-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.21-mm1.orig/include/linux/mmzone.h
> +++ linux-2.6.21-mm1/include/linux/mmzone.h
> @@ -610,6 +610,11 @@ int sysctl_min_unmapped_ratio_sysctl_han
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
