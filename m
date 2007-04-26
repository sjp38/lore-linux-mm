Subject: Re: [PATCH] change global zonelist order on NUMA v2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 26 Apr 2007 17:57:40 -0400
Message-Id: <1177624660.5705.72.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-26 at 18:34 +0900, KAMEZAWA Hiroyuki wrote:
> Changelog from V1 -> V2
> - sysctl name is changed to be relaxed_zone_order
> - NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
>   NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
> - addes boot opttion to set relaxed_zone_order. ia64 is supported now.
> - Added documentation
> 
> patch is against 2.6.21-rc7-mm2. tested on ia64 NUMA box. works well.

[PATCH] factor/rework change zonelist order patch

Against 2.6.21-rc7 atop KAMEZAWA Hiroyuki's "change global zonelist
order on NUMA v2" patch.

This patch reworks Kame's patch to select the zonelist order as
follows:

1) factor common code out of the build_zonelists_*_aware() functions.
   Renamed these functions to "build_zonelists_in_{node|zone}_order()".
   Restored the comments about zone_reclaim and node "loading" in 
   build_zonelists().  Diff stats for page_alloc.c are inflated by some
   code reorg/movement [or maybe not].

2) renamed the sysctl and boot parameter to "numa_zonelist_order".  I had
   already started this against the v1 patch when Kame came out with his
   v2 patch, so I kept that name here.  One can specify values:

     "[Nn]ode" | "[Dd]efault" | "0" => default/node order
     "[Zz]one" | "1"                => alternate/zone order

   Being lazy, I only check the 1st character of the parameter string.

   Differentiate between default and explicitly specified "node" order
   in case we want to add arch-specific auto-tuning.  Admin/Operator can
   still override by specifying a non-default mode.

   Note that the sense of this switch [0/1] is opposite that of the
   "relaxed_zone_order" in Kame's v2 patch.  I.e., same as the v1 patch.
   Easy to change if we want the new behavior to become the default.

3) kept early_param() definition for boot parameter in mm/page_alloc.c,
   along with the handler function.  One less file to modify.

4) modified the two Documentation additions to match these changes.

I've tested various combinations [non-exhaustive], with an ad hoc
instrumentation patch, and it appears to work as expected [as I expect,
anyway] on ia64 NUMA.

Question:  do we need to rebuild the zonelist caches when we reorder
           the zones?  The z_to_n[] array appears to be dependent on
           the zonelist order... 

Also:      I see the "Movable" zones show up in 21-rc7-mm2.  This patch
           will cause Movable zone to overflow to remote movable zones
           before using local Normal memory in non-default, zone order.
           Is this what we want?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/kernel-parameters.txt |   11 +
 Documentation/sysctl/vm.txt         |   38 +++--
 arch/ia64/mm/discontig.c            |    2 
 include/linux/mmzone.h              |    6 
 kernel/sysctl.c                     |   11 -
 mm/page_alloc.c                     |  229 ++++++++++++++++++++++--------------
 6 files changed, 182 insertions(+), 115 deletions(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-04-26 14:06:17.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-04-26 16:51:31.000000000 -0400
@@ -2024,7 +2024,8 @@ void show_free_areas(void)
  * Add all populated zones of a node to the zonelist.
  */
 static int __meminit build_zonelists_node(pg_data_t *pgdat,
-			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
+			struct zonelist *zonelist, int nr_zones,
+			enum zone_type zone_type)
 {
 	struct zone *zone;
 
@@ -2107,130 +2108,155 @@ static int find_next_best_node(int node,
 }
 
 /*
- * Build zonelists based on node locality.
+ * numa_zonelist_order:
+ *  0 [default] = order by ([node] distance, -zonetype)
+ *  1           = order by (-zonetype, [node] distance)
+ */
+static int zonelist_order = 0;
+
+/*
+ * command line option "numa_zonelist_order"
+ *      = "[dD]efault|[nN]ode"|"0" - default, order by node locality,
+ *         then zone within node.
+ *	= "[zZ]one"|"1" - order by zone, then by locality within zone
+ */
+char numa_zonelist_order[NUMA_ZONELIST_ORDER_LEN] = "default";
+
+static int __parse_numa_zonelist_order(char *s)
+{
+	if (*s == 'd' || *s == 'D') {
+		strncpy(numa_zonelist_order, "default",
+					NUMA_ZONELIST_ORDER_LEN);
+		zonelist_order = 0;
+	} else if (*s == 'n' || *s == 'N' || *s == '0') {
+		strncpy(numa_zonelist_order, "node",
+					NUMA_ZONELIST_ORDER_LEN);
+		zonelist_order = 0;
+	} else if (*s == 'z' || *s == 'Z' || *s == '1') {
+		strncpy(numa_zonelist_order, "zone",
+					NUMA_ZONELIST_ORDER_LEN);
+		zonelist_order = 1;
+	} else {
+		printk(KERN_WARNING
+			"Ignoring invalid numa_zonelist_order value:  "
+			"%s\n", s);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static __init int setup_numa_zonelist_order(char *s)
+{
+	if (s)
+		return __parse_numa_zonelist_order(s);
+	return 0;
+}
+early_param("numa_zonelist_order", setup_numa_zonelist_order);
+
+/*
+ * Build zonelists ordered by node and zones within node.
+ * This results in maximum locality--normal zone overflows into local
+ * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_locality_aware(pg_data_t *pgdat)
+static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 {
-	int j, node, local_node;
 	enum zone_type i;
-	int prev_node, load;
+	int j;
 	struct zonelist *zonelist;
-	nodemask_t used_mask;
 
-	/* initialize zonelists */
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
-		zonelist->zones[0] = NULL;
-	}
+		for (j = 0; zonelist->zones[j] != NULL; j++);
 
-	/* NUMA-aware ordering of nodes */
-	local_node = pgdat->node_id;
-	load = num_online_nodes();
-	prev_node = local_node;
-	nodes_clear(used_mask);
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
-		int distance = node_distance(local_node, node);
-
-		/*
-		 * If another node is sufficiently far away then it is better
-		 * to reclaim pages in a zone before going off node.
-		 */
-		if (distance > RECLAIM_DISTANCE)
-			zone_reclaim_mode = 1;
+ 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
+		zonelist->zones[j] = NULL;
+	}
+}
 
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
+/*
+ * Build zonelists ordered by zone and nodes within zones.
+ * This results in conserving DMA zone[s] until all Normal memory is
+ * exhausted, but results in overflowing to remote node while memory
+ * may still exist in local DMA zone.
+ */
+static int node_order[MAX_NUMNODES];
 
-		if (distance != node_distance(local_node, prev_node))
-			node_load[node] += load;
-		prev_node = node;
-		load--;
-		for (i = 0; i < MAX_NR_ZONES; i++) {
-			zonelist = pgdat->node_zonelists + i;
-			for (j = 0; zonelist->zones[j] != NULL; j++);
+static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
+{
+	enum zone_type i;
+	int pos, j, node;
+	int zone_type;		/* needs to be signed */
+	struct zone *z;
+	struct zonelist *zonelist;
 
-	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
-			zonelist->zones[j] = NULL;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + i;
+		pos = 0;
+		for (zone_type = i; zone_type >= 0; zone_type--) {
+			for (j = 0; j < nr_nodes; j++) {
+				node = node_order[j];
+				z = &NODE_DATA(node)->node_zones[zone_type];
+				if (populated_zone(z))
+					zonelist->zones[pos++] = z;
+			}
 		}
+		zonelist->zones[pos] = NULL;
 	}
 }
 
-/*
- * Build zonelist based on zone priority.
- */
-static int node_order[MAX_NUMNODES];
-static void build_zonelists_zone_aware(pg_data_t *pgdat)
+static void build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, pos, zone_type, node, load;
+	int j, node, load;
+	enum zone_type i;
 	nodemask_t used_mask;
 	int local_node, prev_node;
-	struct zone *z;
 	struct zonelist *zonelist;
 
+	/* initialize zonelists */
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		zonelist->zones[0] = NULL;
 	}
-	memset(node_order, 0, sizeof(node_order));
+
+	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
 	load = num_online_nodes();
 	prev_node = local_node;
 	nodes_clear(used_mask);
+
+	memset(node_order, 0, sizeof(node_order));
 	j = 0;
+
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
 		int distance = node_distance(local_node, node);
+
+		/*
+		 * If another node is sufficiently far away then it is better
+		 * to reclaim pages in a zone before going off node.
+		 */
 		if (distance > RECLAIM_DISTANCE)
 			zone_reclaim_mode = 1;
+
+		/*
+		 * We don't want to pressure a particular node.
+		 * So adding penalty to the first node in same
+		 * distance group to make it round-robin.
+		 */
 		if (distance != node_distance(local_node, prev_node))
 			node_load[node] = load;
-		node_order[j++] = node;
+
 		prev_node = node;
 		load--;
+		if (!zonelist_order)	/* default */
+			build_zonelists_in_node_order(pgdat, node);
+		else
+			node_order[j++] = node;	/* remember order */
 	}
-	/* calculate node order */
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		pos = 0;
-		for (zone_type = i; zone_type >= 0; zone_type--) {
-			for (j = 0; j < num_online_nodes(); j++) {
-				node = node_order[j];
-				z = &NODE_DATA(node)->node_zones[zone_type];
-				if (populated_zone(z))
-					zonelist->zones[pos++] = z;
-			}
-		}
-		zonelist->zones[pos] = NULL;
-	}
-}
 
-int sysctl_relaxed_zone_order = 0;
-
-static void build_zonelists(pg_data_t *pgdat)
-{
-	if (sysctl_relaxed_zone_order)
-		build_zonelists_locality_aware(pgdat);
-	else
-		build_zonelists_zone_aware(pgdat);
-}
-
-int sysctl_relaxed_zone_order_handler(ctl_table *table, int write,
-		struct file *file, void __user *buffer, size_t *length,
-		loff_t *ppos)
-{
-	int oldval = sysctl_relaxed_zone_order;
-	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
-	if (write && (oldval != sysctl_relaxed_zone_order))
-		build_all_zonelists();
-	return 0;
-}
-
-int __init cmdline_parse_relaxed_zone_order(char *p)
-{
-	sysctl_relaxed_zone_order = 1;
-	return 0;
+	if (zonelist_order) {
+		/* calculate node order -- i.e., DMA last! */
+		build_zonelists_in_zone_order(pgdat, j);
+	}
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
@@ -2251,6 +2277,37 @@ static void __meminit build_zonelist_cac
 	}
 }
 
+/*
+ * sysctl handler for numa_zonelist_order
+ */
+int numa_zonelist_order_handler(ctl_table *table, int write,
+		struct file *file, void __user *buffer, size_t *length,
+		loff_t *ppos)
+{
+	char saved_string[NUMA_ZONELIST_ORDER_LEN];
+	int ret;
+
+	if (write)
+		strncpy(saved_string, (char*)table->data,
+			NUMA_ZONELIST_ORDER_LEN);
+	ret = proc_dostring(table, write, file, buffer, length, ppos);
+	if (ret)
+		return ret;
+	if (write) {
+		int oldval = zonelist_order;
+		if (__parse_numa_zonelist_order((char*)table->data)) {
+			/*
+			 * bogus value.  restore saved string
+			 */
+			strncpy((char*)table->data, saved_string,
+				NUMA_ZONELIST_ORDER_LEN);
+			zonelist_order = oldval;
+		} else if (oldval != zonelist_order)
+			build_all_zonelists();
+	}
+	return 0;
+}
+
 #else	/* CONFIG_NUMA */
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
Index: Linux/kernel/sysctl.c
===================================================================
--- Linux.orig/kernel/sysctl.c	2007-04-26 14:06:17.000000000 -0400
+++ Linux/kernel/sysctl.c	2007-04-26 16:46:29.000000000 -0400
@@ -80,7 +80,6 @@ extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
-extern int sysctl_relaxed_zone_order;
 
 #if defined(CONFIG_ADAPTIVE_READAHEAD)
 extern int readahead_ratio;
@@ -896,12 +895,12 @@ static ctl_table vm_table[] = {
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "relaxed_zone_order",
-		.data		= &sysctl_relaxed_zone_order,
-		.maxlen		= sizeof(sysctl_relaxed_zone_order),
+		.procname	= "numa_zonelist_order",
+		.data		= &numa_zonelist_order,
+		.maxlen		= NUMA_ZONELIST_ORDER_LEN,
 		.mode		= 0644,
-		.proc_handler	= &sysctl_relaxed_zone_order_handler,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= &numa_zonelist_order_handler,
+		.strategy	= &sysctl_string,
 	},
 #endif
 #if defined(CONFIG_X86_32) || \
Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-04-26 13:35:49.000000000 -0400
+++ Linux/include/linux/mmzone.h	2007-04-26 16:51:15.000000000 -0400
@@ -608,10 +608,10 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
-extern int sysctl_relaxed_zone_order_handler(struct ctl_table *, int,
+extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
-
-extern int cmdline_parse_relaxed_zone_order(char *p);
+extern char numa_zonelist_order[];
+#define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: Linux/arch/ia64/mm/discontig.c
===================================================================
--- Linux.orig/arch/ia64/mm/discontig.c	2007-04-26 13:35:49.000000000 -0400
+++ Linux/arch/ia64/mm/discontig.c	2007-04-26 14:10:23.000000000 -0400
@@ -27,8 +27,6 @@
 #include <asm/numa.h>
 #include <asm/sections.h>
 
-
-early_param("relaxed_zone_order", cmdline_parse_relaxed_zone_order);
 /*
  * Track per-node information needed to setup the boot memory allocator, the
  * per-node areas, and the real VM.
Index: Linux/Documentation/kernel-parameters.txt
===================================================================
--- Linux.orig/Documentation/kernel-parameters.txt	2007-04-26 13:35:49.000000000 -0400
+++ Linux/Documentation/kernel-parameters.txt	2007-04-26 15:38:54.000000000 -0400
@@ -1500,9 +1500,14 @@ and is between 256 and 4096 characters. 
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c			
 
-	relaxed_zone_order [KNL,BOOT]
-			give memory allocation priority to locality rather
-			than zone class. See Documentation/sysctl/vm.txt
+	numa_zonelist_order [KNL,BOOT]
+			Select memory allocation zonelist order for NUMA
+			platform.  Default a.k.a. "Node order" orders the
+			zonelists by node [locality], then zones within
+			nodes.  "Zone order" orders the zonelists by zone,
+			then nodes within the zone.  This moves DMA zone,
+			if any, to the end of the allocation lists.
+			See also Documentation/sysctl/vm.txt
 
 	reserve=	[KNL,BUGS] Force the kernel to ignore some iomem area
 
Index: Linux/Documentation/sysctl/vm.txt
===================================================================
--- Linux.orig/Documentation/sysctl/vm.txt	2007-04-26 13:35:49.000000000 -0400
+++ Linux/Documentation/sysctl/vm.txt	2007-04-26 15:48:20.000000000 -0400
@@ -34,7 +34,7 @@ Currently, these files are in /proc/sys/
 - swap_prefetch
 - readahead_ratio
 - readahead_hit_rate
-- relaxed_zone_order
+- numa_zonelist_order
 
 ==============================================================
 
@@ -279,21 +279,29 @@ The default value is 1.
 
 =============================================================
 
-relaxed_zone_order
+numa_zonelist_order
 
 This sysctl is only for NUMA.
-This allows you to allocate local memory more aggresively.
-Assume 2 Node NUMA.The kernel memory allocateion order on Node(0)
-is following. relaxed_zone_order=0 in this case.(default)
-==
-Node(0)NORMAL -> Node(1)NORMAL -> Node(0)DMA -> Node(1)DMA(if any)
-==
-If set to relaxed_zone_order=1, This option changes this order to be
-==
-Node(0)NORMAL -> Node(0)DMA -> Node(1)NORMA -> Node(1)DMA
-==
-Then you can use more local memory. But, in this case, ZONE_DMA can be
-used more eagerly than default. Then, OOM-KILL in ZONE_DMA can happen easier.
 
-The default value is 0.
+numa_zonelist_order selects the order of the memory allocation zonelists.
+The default order [a.k.a. "node order"] orders the zonelists by node, the
+by zone within each node.  For example, assume 2 Node NUMA.  The default
+kernel memory allocation order on Node(0) will be:
+
+	Node(0)NORMAL -> Node(0)DMA -> Node(1)NORMAL -> Node(1)DMA(if any)
+
+Thus, allocations that request Node(0) NORMAL may overflow onto Node(0)DMA
+first.  This provides maximum locality, but risks exhausting all of DMA
+memory while NORMAL memory exists elsewhere on the system.  This can result
+in OOM-KILL in ZONE_DMA.  You can specify "[Dd]efault", "[Zz]one" or "0" to
+request default/zone order.
+
+If numa_zonelist_order is set to "node" order, the kernel memory allocation
+order on Node(0) becomes:
+
+	Node(0)NORMAL -> Node(1)NORMAL -> Node(0)DMA -> Node(1)DMA(if any)
+
+In this mode, DMA memory will be used in place of NORMAL memory, only when
+all NORMAL zones are exhausted.  Specify "[Nn]ode" or "1" for node order.
+
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
