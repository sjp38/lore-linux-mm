Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 60618600375
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:31:06 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 15 Apr 2010 13:30:16 -0400
Message-Id: <20100415173016.8801.34970.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/8] numa:  Introduce numa_mem_id()- effective local memory node id
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.34-rc3-mmotm-100405-1609

Introduce numa_mem_id(), based on generic percpu variable infrastructure
to track "nearest node with memory" for archs that support memoryless
nodes.

Define API in <linux/topology.h> when CONFIG_HAVE_MEMORYLESS_NODES
defined, else stubs. Architectures will define HAVE_MEMORYLESS_NODES
if/when they support them.

Archs can override definitions of:

numa_mem_id() - returns node number of "local memory" node
set_numa_mem() - initialize [this cpus'] per cpu variable 'numa_mem'
cpu_to_mem()  - return numa_mem for specified cpu; may be used as lvalue

Generic initialization of 'numa_mem' occurs in __build_all_zonelists().
This will initialize the boot cpu at boot time, and all cpus on change of
numa_zonelist_order, or when node or memory hot-plug requires zonelist rebuild.
Archs that support memoryless nodes will need to initialize 'numa_mem' for
secondary cpus as they're brought on-line.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---

V2:  + split this out of Christoph's incomplete "starter patch"
     + flesh out the definition

V3,V4:  no change

 include/asm-generic/topology.h |    3 +++
 include/linux/mmzone.h         |    6 ++++++
 include/linux/topology.h       |   24 ++++++++++++++++++++++++
 mm/page_alloc.c                |   39 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 71 insertions(+), 1 deletion(-)

Index: linux-2.6.34-rc3-mmotm-100405-1609/include/linux/topology.h
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/include/linux/topology.h	2010-04-07 10:10:23.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/include/linux/topology.h	2010-04-07 10:10:28.000000000 -0400
@@ -233,6 +233,30 @@ DECLARE_PER_CPU(int, numa_node);
 
 #endif	/* [!]CONFIG_USE_PERCPU_NUMA_NODE_ID */
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+
+DECLARE_PER_CPU(int, numa_mem);
+
+#ifndef set_numa_mem
+#define set_numa_mem(__node) percpu_write(numa_mem, __node)
+#endif
+
+#else	/* !CONFIG_HAVE_MEMORYLESS_NODES */
+
+#define numa_mem numa_node
+static inline void set_numa_mem(int node) {}
+
+#endif	/* [!]CONFIG_HAVE_MEMORYLESS_NODES */
+
+#ifndef numa_mem_id
+/* Returns the number of the nearest Node with memory */
+#define numa_mem_id()		__this_cpu_read(numa_mem)
+#endif
+
+#ifndef cpu_to_mem
+#define cpu_to_mem(__cpu)	per_cpu(numa_mem, (__cpu))
+#endif
+
 #ifndef topology_physical_package_id
 #define topology_physical_package_id(cpu)	((void)(cpu), -1)
 #endif
Index: linux-2.6.34-rc3-mmotm-100405-1609/mm/page_alloc.c
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/mm/page_alloc.c	2010-04-07 10:10:23.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/mm/page_alloc.c	2010-04-07 10:10:28.000000000 -0400
@@ -61,6 +61,11 @@ DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
 #endif
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+DEFINE_PER_CPU(int, numa_mem);		/* Kernel "local memory" node */
+EXPORT_PER_CPU_SYMBOL(numa_mem);
+#endif
+
 /*
  * Array of node states.
  */
@@ -2752,6 +2757,24 @@ static void build_zonelist_cache(pg_data
 		zlc->z_to_n[z - zonelist->_zonerefs] = zonelist_node_idx(z);
 }
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+/*
+ * Return node id of node used for "local" allocations.
+ * I.e., first node id of first zone in arg node's generic zonelist.
+ * Used for initializing percpu 'numa_mem', which is used primarily
+ * for kernel allocations, so use GFP_KERNEL flags to locate zonelist.
+ */
+int local_memory_node(int node)
+{
+	struct zone *zone;
+
+	(void)first_zones_zonelist(node_zonelist(node, GFP_KERNEL),
+				   gfp_zone(GFP_KERNEL),
+				   NULL,
+				   &zone);
+	return zone->node;
+}
+#endif
 
 #else	/* CONFIG_NUMA */
 
@@ -2851,9 +2874,23 @@ static int __build_all_zonelists(void *d
 	 * needs the percpu allocator in order to allocate its pagesets
 	 * (a chicken-egg dilemma).
 	 */
-	for_each_possible_cpu(cpu)
+	for_each_possible_cpu(cpu) {
 		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+		/*
+		 * We now know the "local memory node" for each node--
+		 * i.e., the node of the first zone in the generic zonelist.
+		 * Set up numa_mem percpu variable for on-line cpus.  During
+		 * boot, only the boot cpu should be on-line;  we'll init the
+		 * secondary cpus' numa_mem as they come on-line.  During
+		 * node/memory hotplug, we'll fixup all on-line cpus.
+		 */
+		if (cpu_online(cpu))
+			cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
+#endif
+	}
+
 	return 0;
 }
 
Index: linux-2.6.34-rc3-mmotm-100405-1609/include/linux/mmzone.h
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/include/linux/mmzone.h	2010-04-07 10:03:46.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/include/linux/mmzone.h	2010-04-07 10:10:28.000000000 -0400
@@ -661,6 +661,12 @@ void memory_present(int nid, unsigned lo
 static inline void memory_present(int nid, unsigned long start, unsigned long end) {}
 #endif
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+int local_memory_node(int node_id);
+#else
+static inline int local_memory_node(int node_id) { return node_id; };
+#endif
+
 #ifdef CONFIG_NEED_NODE_MEMMAP_SIZE
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #endif
Index: linux-2.6.34-rc3-mmotm-100405-1609/include/asm-generic/topology.h
===================================================================
--- linux-2.6.34-rc3-mmotm-100405-1609.orig/include/asm-generic/topology.h	2010-04-07 09:49:13.000000000 -0400
+++ linux-2.6.34-rc3-mmotm-100405-1609/include/asm-generic/topology.h	2010-04-07 10:10:28.000000000 -0400
@@ -34,6 +34,9 @@
 #ifndef cpu_to_node
 #define cpu_to_node(cpu)	((void)(cpu),0)
 #endif
+#ifndef cpu_to_mem
+#define cpu_to_mem(cpu)		(void)(cpu),0)
+#endif
 #ifndef parent_node
 #define parent_node(node)	((void)(node),0)
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
