Subject: [PATCH] Make dynamic/run-time configuration of zonelist order
	configurable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 29 May 2007 15:48:41 -0400
Message-Id: <1180468121.5067.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

[PATCH] Make dynamic/run-time configuration of zonelist order configurable

Against 2.6.22-rc2-mm1 with the huge page allocation fix applied:

	http://marc.info/?l=linux-mm&m=117935390224779&w=4

The patch series to make the numa zonelist order configurable removed
the __*init* attributes from the zonelist build functions and related
data, and added a sysctl to reconfigure the zonelist order at runtime,
as well as a boot parameter.  Not all systems require this feature, so
they should not have to incur the overhead of the additional sysctl nor
keeping the zonelist build functions around at runtime.  [This might be
of concern to users of 32-bit systems using numa emulation for resource
management.]

This patch makes the 'vm.numa_zonelist_order' sysctl varible configurable
via the DYNAMIC_ZONELIST_ORDER Kconfig option and makes the runtime
availability of the zonelist build functions depend on DYNAMIC_ZONELIST_ORDER
or MEMORY_HOTPLUG.

Built and boot tested on ia64 and 2 node/socket x86_64, with various
values of above config options.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mmzone.h |   16 ++++++++++++++++
 kernel/sysctl.c        |    2 +-
 mm/Kconfig             |    7 +++++++
 mm/page_alloc.c        |   47 +++++++++++++++++++++++++----------------------
 4 files changed, 49 insertions(+), 23 deletions(-)

Index: Linux/include/linux/mmzone.h
===================================================================
--- Linux.orig/include/linux/mmzone.h	2007-05-23 10:57:07.000000000 -0400
+++ Linux/include/linux/mmzone.h	2007-05-25 11:29:31.000000000 -0400
@@ -432,6 +432,20 @@ struct zonelist {
 #endif
 };
 
+/*
+ * no need to keep zonelist build functions around after init, unless
+ * we've configured DYNAMIC_ZONELIST_ORDER or MEMORY_HOTPLUG
+ */
+#if defined(CONFIG_DYNAMIC_ZONELIST_ORDER) || defined(CONFIG_MEMORY_HOTPLUG)
+#define ZL_INIT
+#define ZL_MEMINIT
+#define ZL_MEMINITDATA
+#else
+#define ZL_INIT	__init
+#define ZL_MEMINIT __meminit
+#define ZL_MEMINITDATA __meminitdata
+#endif
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 struct node_active_region {
 	unsigned long start_pfn;
@@ -611,10 +625,12 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+#ifdef CONFIG_DYNAMIC_ZONELIST_ORDER
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 extern char numa_zonelist_order[];
 #define NUMA_ZONELIST_ORDER_LEN 16	/* string buffer size */
+#endif
 
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
Index: Linux/kernel/sysctl.c
===================================================================
--- Linux.orig/kernel/sysctl.c	2007-05-23 10:57:09.000000000 -0400
+++ Linux/kernel/sysctl.c	2007-05-25 11:39:12.000000000 -0400
@@ -944,7 +944,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 		.strategy	= &sysctl_jiffies,
 	},
-#ifdef CONFIG_NUMA
+#ifdef CONFIG_DYNAMIC_ZONELIST_ORDER
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "numa_zonelist_order",
Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-05-25 11:15:26.000000000 -0400
+++ Linux/mm/Kconfig	2007-05-25 11:20:27.000000000 -0400
@@ -172,3 +172,10 @@ config NR_QUICK
 	depends on QUICKLIST
 	default "2" if (SUPERH && !SUPERH64)
 	default "1"
+
+config DYNAMIC_ZONELIST_ORDER
+	bool "runtime configuration of zonelist order via sysctl"
+	depends on NUMA
+	help
+	  Supports the runtime reconfiguration of zonelist order via
+	  a sysctl variable:  vm.numa_zonelist_order.
Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-05-23 11:05:09.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-05-25 11:34:45.000000000 -0400
@@ -1976,7 +1976,8 @@ void show_free_areas(void)
  *
  * Add all populated zones of a node to the zonelist.
  */
-static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
+static int ZL_MEMINIT build_zonelists_node(pg_data_t *pgdat,
+				struct zonelist *zonelist,
 				int nr_zones, enum zone_type zone_type)
 {
 	struct zone *zone;
@@ -2013,16 +2014,16 @@ static int build_zonelists_node(pg_data_
 /* zonelist order in the kernel.
  * set_zonelist_order() will set this to NODE or ZONE.
  */
-static int current_zonelist_order = ZONELIST_ORDER_DEFAULT;
-static char zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
+static int ZL_MEMINITDATA current_zonelist_order = ZONELIST_ORDER_DEFAULT;
+static char ZL_MEMINITDATA zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
 
 
 #ifdef CONFIG_NUMA
 /* The value user specified ....changed by config */
-static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
+static int ZL_MEMINITDATA user_zonelist_order = ZONELIST_ORDER_DEFAULT;
 /* string for sysctl */
 #define NUMA_ZONELIST_ORDER_LEN	16
-char numa_zonelist_order[16] = "default";
+char ZL_MEMINITDATA numa_zonelist_order[16] = "default";
 
 /*
  * interface for configure zonelist ordering.
@@ -2032,7 +2033,7 @@ char numa_zonelist_order[16] = "default"
  *	= "[zZ]one      - order by zone, then by locality within zone
  */
 
-static int __parse_numa_zonelist_order(char *s)
+static int ZL_INIT __parse_numa_zonelist_order(char *s)
 {
 	if (*s == 'd' || *s == 'D') {
 		user_zonelist_order = ZONELIST_ORDER_DEFAULT;
@@ -2057,6 +2058,7 @@ static __init int setup_numa_zonelist_or
 }
 early_param("numa_zonelist_order", setup_numa_zonelist_order);
 
+#ifdef CONFIG_DYNAMIC_ZONELIST_ORDER
 /*
  * sysctl handler for numa_zonelist_order
  */
@@ -2087,10 +2089,11 @@ int numa_zonelist_order_handler(ctl_tabl
 	}
 	return 0;
 }
+#endif
 
 
 #define MAX_NODE_LOAD (num_online_nodes())
-static int node_load[MAX_NUMNODES];
+static int ZL_MEMINITDATA node_load[MAX_NUMNODES];
 
 /**
  * find_next_best_node - find the next node that should appear in a given node's fallback list
@@ -2106,7 +2109,7 @@ static int node_load[MAX_NUMNODES];
  * on them otherwise.
  * It returns -1 if no node is found.
  */
-static int find_next_best_node(int node, nodemask_t *used_node_mask)
+static int ZL_MEMINIT find_next_best_node(int node, nodemask_t *used_node_mask)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -2158,7 +2161,7 @@ static int find_next_best_node(int node,
  * This results in maximum locality--normal zone overflows into local
  * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
+static void ZL_MEMINIT build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 {
 	enum zone_type i;
 	int j;
@@ -2179,9 +2182,9 @@ static void build_zonelists_in_node_orde
  * exhausted, but results in overflowing to remote node while memory
  * may still exist in local DMA zone.
  */
-static int node_order[MAX_NUMNODES];
+static int ZL_MEMINITDATA node_order[MAX_NUMNODES];
 
-static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
+static void ZL_MEMINIT build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
 	enum zone_type i;
 	int pos, j;
@@ -2206,7 +2209,7 @@ static void build_zonelists_in_zone_orde
 	}
 }
 
-static int default_zonelist_order(void)
+static int ZL_MEMINIT default_zonelist_order(void)
 {
 	int nid, zone_type;
 	unsigned long low_kmem_size,total_size;
@@ -2259,7 +2262,7 @@ static int default_zonelist_order(void)
 	return ZONELIST_ORDER_ZONE;
 }
 
-static void set_zonelist_order(void)
+static void ZL_MEMINIT set_zonelist_order(void)
 {
 	if (user_zonelist_order == ZONELIST_ORDER_DEFAULT)
 		current_zonelist_order = default_zonelist_order();
@@ -2270,7 +2273,7 @@ static void set_zonelist_order(void)
 /*
  * setup_populate_map() - record nodes whose "policy_zone" is "on-node".
  */
-static void setup_populated_map(int nid)
+static void ZL_MEMINIT setup_populated_map(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zonelist *zl = pgdat->node_zonelists + policy_zone;
@@ -2283,7 +2286,7 @@ static void setup_populated_map(int nid)
 		node_not_populated(nid);
 }
 
-static void build_zonelists(pg_data_t *pgdat)
+static void ZL_MEMINIT build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, load;
 	enum zone_type i;
@@ -2341,7 +2344,7 @@ static void build_zonelists(pg_data_t *p
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */
-static void build_zonelist_cache(pg_data_t *pgdat)
+static void ZL_MEMINIT build_zonelist_cache(pg_data_t *pgdat)
 {
 	int i;
 
@@ -2361,7 +2364,7 @@ static void build_zonelist_cache(pg_data
 
 #else	/* CONFIG_NUMA */
 
-static void set_zonelist_order(void)
+static void ZL_MEMINIT set_zonelist_order(void)
 {
 	current_zonelist_order = ZONELIST_ORDER_ZONE;
 }
@@ -2370,12 +2373,12 @@ static void set_zonelist_order(void)
  * setup_populated_map - non-NUMA case
  * Only node 0 should be on-line, and it MUST be populated!
  */
-static void setup_populated_map(int nid)
+static void ZL_MEMINIT setup_populated_map(int nid)
 {
 	node_set_populated(nid);
 }
 
-static void build_zonelists(pg_data_t *pgdat)
+static void ZL_MEMINIT build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
 	enum zone_type i,j;
@@ -2411,7 +2414,7 @@ static void build_zonelists(pg_data_t *p
 }
 
 /* non-NUMA variant of zonelist performance cache - just NULL zlcache_ptr */
-static void build_zonelist_cache(pg_data_t *pgdat)
+static void ZL_MEMINIT build_zonelist_cache(pg_data_t *pgdat)
 {
 	int i;
 
@@ -2422,7 +2425,7 @@ static void build_zonelist_cache(pg_data
 #endif	/* CONFIG_NUMA */
 
 /* return values int ....just for stop_machine_run() */
-static int __build_all_zonelists(void *dummy)
+static int ZL_MEMINIT __build_all_zonelists(void *dummy)
 {
 	int nid;
 
@@ -2434,7 +2437,7 @@ static int __build_all_zonelists(void *d
 	return 0;
 }
 
-void build_all_zonelists(void)
+void ZL_MEMINIT build_all_zonelists(void)
 {
 	set_zonelist_order();
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
