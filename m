Date: Thu, 26 Apr 2007 18:34:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] change global zonelist order on NUMA v2
Message-Id: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Changelog from V1 -> V2
- sysctl name is changed to be relaxed_zone_order
- NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
  NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
- addes boot opttion to set relaxed_zone_order. ia64 is supported now.
- Added documentation

patch is against 2.6.21-rc7-mm2. tested on ia64 NUMA box. works well.

-Kame
> from hrere

Make zonelist creation policy selectable from sysctl v2.

[Description]
Assume 2 node NUMA, only node(0) has ZONE_DMA.
(ia64's ZONE_DMA is below 4GB...x86_64's ZONE_DMA32)

In this case, current default (node0's) zonelist order is

Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.

This means Node(0)'s DMA will be used before Node(1)'s NORMAL.

This patch changes *default* zone order to

Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.

But, if Node(0)'s memory is too small (near or below 4G), Node(0)'s process has
to allocate its memory from Node(1) even if there are free memory in Node(0).
Some applications/uses will dislike this.
This patch adds a knob to change zonelist ordering.

[What this patch adds]

command:
%echo 1 > /proc/sys/vm/relaxed_zone_order

Will rebuild zonelist in following order(old style).

Node(0)'s NORMAL -> Node(0)'s DMA -> Node(0)'s NORMAL.

And you can specify "relaxed_zone_order" boot option if supported by arch.
But this style zonelist can easily cause OOM-Kill because of ZONE_DMA
exhaition. be careful.

command:
echo 0 > /proc/sys/vm/relaxed_zone_order
will rebuild zonelist as
Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.

Added ia64 support and tested on ia64 2-Node NUMA. works well.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-rc7-mm2/kernel/sysctl.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/kernel/sysctl.c
+++ linux-2.6.21-rc7-mm2/kernel/sysctl.c
@@ -80,6 +80,7 @@ extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
+extern int sysctl_relaxed_zone_order;
 
 #if defined(CONFIG_ADAPTIVE_READAHEAD)
 extern int readahead_ratio;
@@ -893,6 +894,15 @@ static ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "relaxed_zone_order",
+		.data		= &sysctl_relaxed_zone_order,
+		.maxlen		= sizeof(sysctl_relaxed_zone_order),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_relaxed_zone_order_handler,
+		.strategy	= &sysctl_intvec,
+	},
 #endif
 #if defined(CONFIG_X86_32) || \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
Index: linux-2.6.21-rc7-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/page_alloc.c
+++ linux-2.6.21-rc7-mm2/mm/page_alloc.c
@@ -2045,7 +2045,7 @@ static int __meminit build_zonelists_nod
 
 #ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
-static int __meminitdata node_load[MAX_NUMNODES];
+static int node_load[MAX_NUMNODES];
 /**
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
@@ -2060,7 +2060,7 @@ static int __meminitdata node_load[MAX_N
  * on them otherwise.
  * It returns -1 if no node is found.
  */
-static int __meminit find_next_best_node(int node, nodemask_t *used_node_mask)
+static int find_next_best_node(int node, nodemask_t *used_node_mask)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -2106,7 +2106,10 @@ static int __meminit find_next_best_node
 	return best_node;
 }
 
-static void __meminit build_zonelists(pg_data_t *pgdat)
+/*
+ * Build zonelists based on node locality.
+ */
+static void build_zonelists_locality_aware(pg_data_t *pgdat)
 {
 	int j, node, local_node;
 	enum zone_type i;
@@ -2155,6 +2158,81 @@ static void __meminit build_zonelists(pg
 	}
 }
 
+/*
+ * Build zonelist based on zone priority.
+ */
+static int node_order[MAX_NUMNODES];
+static void build_zonelists_zone_aware(pg_data_t *pgdat)
+{
+	int i, j, pos, zone_type, node, load;
+	nodemask_t used_mask;
+	int local_node, prev_node;
+	struct zone *z;
+	struct zonelist *zonelist;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + i;
+		zonelist->zones[0] = NULL;
+	}
+	memset(node_order, 0, sizeof(node_order));
+	local_node = pgdat->node_id;
+	load = num_online_nodes();
+	prev_node = local_node;
+	nodes_clear(used_mask);
+	j = 0;
+	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+		int distance = node_distance(local_node, node);
+		if (distance > RECLAIM_DISTANCE)
+			zone_reclaim_mode = 1;
+		if (distance != node_distance(local_node, prev_node))
+			node_load[node] = load;
+		node_order[j++] = node;
+		prev_node = node;
+		load--;
+	}
+	/* calculate node order */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		zonelist = pgdat->node_zonelists + i;
+		pos = 0;
+		for (zone_type = i; zone_type >= 0; zone_type--) {
+			for (j = 0; j < num_online_nodes(); j++) {
+				node = node_order[j];
+				z = &NODE_DATA(node)->node_zones[zone_type];
+				if (populated_zone(z))
+					zonelist->zones[pos++] = z;
+			}
+		}
+		zonelist->zones[pos] = NULL;
+	}
+}
+
+int sysctl_relaxed_zone_order = 0;
+
+static void build_zonelists(pg_data_t *pgdat)
+{
+	if (sysctl_relaxed_zone_order)
+		build_zonelists_locality_aware(pgdat);
+	else
+		build_zonelists_zone_aware(pgdat);
+}
+
+int sysctl_relaxed_zone_order_handler(ctl_table *table, int write,
+		struct file *file, void __user *buffer, size_t *length,
+		loff_t *ppos)
+{
+	int oldval = sysctl_relaxed_zone_order;
+	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	if (write && (oldval != sysctl_relaxed_zone_order))
+		build_all_zonelists();
+	return 0;
+}
+
+int __init cmdline_parse_relaxed_zone_order(char *p)
+{
+	sysctl_relaxed_zone_order = 1;
+	return 0;
+}
+
 /* Construct the zonelist performance cache - see further mmzone.h */
 static void __meminit build_zonelist_cache(pg_data_t *pgdat)
 {
@@ -2222,7 +2300,7 @@ static void __meminit build_zonelist_cac
 #endif	/* CONFIG_NUMA */
 
 /* return values int ....just for stop_machine_run() */
-static int __meminit __build_all_zonelists(void *dummy)
+static int __build_all_zonelists(void *dummy)
 {
 	int nid;
 
@@ -2233,12 +2311,13 @@ static int __meminit __build_all_zonelis
 	return 0;
 }
 
-void __meminit build_all_zonelists(void)
+void build_all_zonelists(void)
 {
 	if (system_state == SYSTEM_BOOTING) {
 		__build_all_zonelists(NULL);
 		cpuset_init_current_mems_allowed();
 	} else {
+		memset(node_load, 0, sizeof(node_load));
 		/* we have to stop all cpus to guaranntee there is no user
 		   of zonelist */
 		stop_machine_run(__build_all_zonelists, NULL, NR_CPUS);
Index: linux-2.6.21-rc7-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-rc7-mm2.orig/include/linux/mmzone.h
+++ linux-2.6.21-rc7-mm2/include/linux/mmzone.h
@@ -608,6 +608,11 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+extern int sysctl_relaxed_zone_order_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
+
+extern int cmdline_parse_relaxed_zone_order(char *p);
+
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
 #ifndef numa_node_id
Index: linux-2.6.21-rc7-mm2/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.21-rc7-mm2.orig/Documentation/kernel-parameters.txt
+++ linux-2.6.21-rc7-mm2/Documentation/kernel-parameters.txt
@@ -1500,6 +1500,10 @@ and is between 256 and 4096 characters. 
 			Format: <reboot_mode>[,<reboot_mode2>[,...]]
 			See arch/*/kernel/reboot.c or arch/*/kernel/process.c			
 
+	relaxed_zone_order [KNL,BOOT]
+			give memory allocation priority to locality rather
+			than zone class. See Documentation/sysctl/vm.txt
+
 	reserve=	[KNL,BUGS] Force the kernel to ignore some iomem area
 
 	reservetop=	[X86-32]
Index: linux-2.6.21-rc7-mm2/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.21-rc7-mm2.orig/Documentation/sysctl/vm.txt
+++ linux-2.6.21-rc7-mm2/Documentation/sysctl/vm.txt
@@ -34,6 +34,7 @@ Currently, these files are in /proc/sys/
 - swap_prefetch
 - readahead_ratio
 - readahead_hit_rate
+- relaxed_zone_order
 
 ==============================================================
 
@@ -275,3 +276,24 @@ Possible values can be:
 The larger value, the more capabilities, with more possible overheads.
 
 The default value is 1.
+
+=============================================================
+
+relaxed_zone_order
+
+This sysctl is only for NUMA.
+This allows you to allocate local memory more aggresively.
+Assume 2 Node NUMA.The kernel memory allocateion order on Node(0)
+is following. relaxed_zone_order=0 in this case.(default)
+==
+Node(0)NORMAL -> Node(1)NORMAL -> Node(0)DMA -> Node(1)DMA(if any)
+==
+If set to relaxed_zone_order=1, This option changes this order to be
+==
+Node(0)NORMAL -> Node(0)DMA -> Node(1)NORMA -> Node(1)DMA
+==
+Then you can use more local memory. But, in this case, ZONE_DMA can be
+used more eagerly than default. Then, OOM-KILL in ZONE_DMA can happen easier.
+
+The default value is 0.
+
Index: linux-2.6.21-rc7-mm2/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/arch/ia64/mm/discontig.c
+++ linux-2.6.21-rc7-mm2/arch/ia64/mm/discontig.c
@@ -27,6 +27,8 @@
 #include <asm/numa.h>
 #include <asm/sections.h>
 
+
+early_param("relaxed_zone_order", cmdline_parse_relaxed_zone_order);
 /*
  * Track per-node information needed to setup the boot memory allocator, the
  * per-node areas, and the real VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
