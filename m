Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8456B0078
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:13:05 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:18:10 -0500
Message-Id: <20091113211810.15074.38150.sendpatchset@localhost.localdomain>
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 4/6] numa:  Introduce numa_mem_id()- effective local memory node id
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.32-rc5-mmotm-091101-1001

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

V2:  + split this out of Christoph's incomplete "starter patch"
     + flesh out the definition

---

 include/linux/mmzone.h   |    6 ++++++
 include/linux/topology.h |   24 ++++++++++++++++++++++++
 mm/page_alloc.c          |   35 +++++++++++++++++++++++++++++++++++
 mm/percpu.c              |    5 +++++
 4 files changed, 70 insertions(+)

Index: linux-2.6.32-rc5-mmotm-091101-1001/include/linux/topology.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/linux/topology.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/linux/topology.h
@@ -232,6 +232,30 @@ DECLARE_PER_CPU(int, numa_node);
 
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
Index: linux-2.6.32-rc5-mmotm-091101-1001/mm/percpu.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/mm/percpu.c
+++ linux-2.6.32-rc5-mmotm-091101-1001/mm/percpu.c
@@ -2078,3 +2078,8 @@ DEFINE_PER_CPU(int, numa_node);
 EXPORT_PER_CPU_SYMBOL(numa_node);
 #endif
 
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+DEFINE_PER_CPU(int, numa_mem);		/* Kernel "local memory" node */
+EXPORT_PER_CPU_SYMBOL(numa_mem);
+#endif
+
Index: linux-2.6.32-rc5-mmotm-091101-1001/mm/page_alloc.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/mm/page_alloc.c
+++ linux-2.6.32-rc5-mmotm-091101-1001/mm/page_alloc.c
@@ -2688,6 +2688,24 @@ static void build_zonelist_cache(pg_data
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
 
@@ -2754,6 +2772,23 @@ static int __build_all_zonelists(void *d
 		build_zonelists(pgdat);
 		build_zonelist_cache(pgdat);
 	}
+
+#ifdef CONFIG_HAVE_MEMORYLESS_NODES
+	{
+		/*
+		 * We now know the "local memory node" for each node--
+		 * i.e., the node of the first zone in the generic zonelist.
+		 * Set up numa_mem percpu variable for on-line cpus.  During
+		 * boot, only the boot cpu should be on-line;  we'll init the
+		 * secondary cpus' numa_mem as they come on-line.  During
+		 * node/memory hotplug, we'll fixup all cpus.
+		 */
+		int cpu;
+		for_each_online_cpu(cpu) {
+			cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
+		}
+	}
+#endif
 	return 0;
 }
 
Index: linux-2.6.32-rc5-mmotm-091101-1001/include/linux/mmzone.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/linux/mmzone.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/linux/mmzone.h
@@ -672,6 +672,12 @@ void memory_present(int nid, unsigned lo
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
