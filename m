Date: Wed, 25 Apr 2007 12:19:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] syctl for selecting global zonelist[] order
Message-Id: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Make zonelist policy selectable from sysctl.

Assume 2 node NUMA, only node(0) has ZONE_DMA (ZONE_DMA32).

In this case, default (node0's) zonelist order is

Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)"s NORMAL.

This means Node(0)'s DMA is used before Node(1)'s NORMAL.

In some server, some application uses large memory allcation.
This exhaust memory in the above order.
Then....sometimes OOM_KILL will occur when 32bit device requires memory.

This patch adds sysctl for rebuilding zonelist after boot and doesn't change
default zonelist order.

command:
%echo 0 > /proc/sys/vm/better_locality

Will rebuild zonelist in following order.

Node(0)'s NORMAL -> Node(1)'s NORMAL -> Node(0)'s DMA.

if set better_locality == 1 (default), zonelist is
Node(0)'s NORMAL -> Node(0)'s DMA -> Node(1)'s NORMAL.

Maybe useful in some users with heavy memory pressure and mlocks.

Tested under ia64 2 node NUMA  against 2.6.21-rc7.. works well.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.21-rc7/kernel/sysctl.c
===================================================================
--- linux-2.6.21-rc7.orig/kernel/sysctl.c
+++ linux-2.6.21-rc7/kernel/sysctl.c
@@ -76,6 +76,9 @@ extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
+#ifdef CONFIG_NUMA
+extern int sysctl_better_locality;
+#endif
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -845,6 +848,15 @@ static ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.ctl_name	= VM_BETTER_LOCALITY,
+		.procname	= "better_locality",
+		.data		= &sysctl_better_locality,
+		.maxlen		= sizeof(sysctl_better_locality),
+		.mode		= 0644,
+		.proc_handler	= &sysctl_better_locality_handler,
+		.strategy	= &sysctl_intvec,
+	},
 #endif
 #if defined(CONFIG_X86_32) || \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
Index: linux-2.6.21-rc7/mm/page_alloc.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/page_alloc.c
+++ linux-2.6.21-rc7/mm/page_alloc.c
@@ -1670,7 +1670,7 @@ static int __meminit build_zonelists_nod
 
 #ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
-static int __meminitdata node_load[MAX_NUMNODES];
+static int node_load[MAX_NUMNODES];
 /**
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
@@ -1685,7 +1685,7 @@ static int __meminitdata node_load[MAX_N
  * on them otherwise.
  * It returns -1 if no node is found.
  */
-static int __meminit find_next_best_node(int node, nodemask_t *used_node_mask)
+static int find_next_best_node(int node, nodemask_t *used_node_mask)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -1731,7 +1731,10 @@ static int __meminit find_next_best_node
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
@@ -1780,6 +1783,78 @@ static void __meminit build_zonelists(pg
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
+int sysctl_better_locality = 1;
+
+static void build_zonelists(pg_data_t *pgdat)
+{
+	if (sysctl_better_locality) {
+		build_zonelists_locality_aware(pgdat);
+	} else {
+		build_zonelists_zone_aware(pgdat);
+	}
+}
+
+int sysctl_better_locality_handler(ctl_table *table, int write,
+		struct file *file, void __user *buffer, size_t *length,
+		loff_t *ppos)
+{
+	int oldval = sysctl_better_locality;
+	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	if (write) {
+		if (oldval != sysctl_better_locality)
+			build_all_zonelists();
+	}
+	return 0;
+}
+
 /* Construct the zonelist performance cache - see further mmzone.h */
 static void __meminit build_zonelist_cache(pg_data_t *pgdat)
 {
@@ -1847,7 +1922,7 @@ static void __meminit build_zonelist_cac
 #endif	/* CONFIG_NUMA */
 
 /* return values int ....just for stop_machine_run() */
-static int __meminit __build_all_zonelists(void *dummy)
+static int __build_all_zonelists(void *dummy)
 {
 	int nid;
 
@@ -1858,12 +1933,13 @@ static int __meminit __build_all_zonelis
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
Index: linux-2.6.21-rc7/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/mmzone.h
+++ linux-2.6.21-rc7/include/linux/mmzone.h
@@ -563,6 +563,9 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+extern int sysctl_better_locality_handler(struct ctl_table *, int,
+			struct file *, void __user *, size_t *, loff_t *);
+
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
 #ifndef numa_node_id
Index: linux-2.6.21-rc7/include/linux/sysctl.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/sysctl.h
+++ linux-2.6.21-rc7/include/linux/sysctl.h
@@ -207,6 +207,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_BETTER_LOCALITY=36,	 /* create locality-preference zonelist */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
