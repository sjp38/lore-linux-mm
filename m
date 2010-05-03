Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6A3A600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:07:06 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 03 May 2010 11:06:17 -0400
Message-Id: <20100503150617.15039.56172.sendpatchset@localhost.localdomain>
In-Reply-To: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
Subject: [PATCH 5/7] numa-introduce-numa_mem_id-effective-local-memory-node-id-fix2
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Incremental patch 1 to
numa-introduce-numa_mem_id-effective-local-memory-node-id.patch
in mmotm 100428-1638.  Atop Andrew's build fix to that patch.

If any of the numa topology functions--numa_mem_id() et al--have not
been overridden by the arch, we can define them as static inline
functions.

Now, since we can no longer use cpu_to_mem() as an lvalue, also
define set_cpu_numa_mem(cpu, node) and use this to initialize the
per cpu numa_mem variable in __build_all_zonelists().

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/topology.h |   24 +++++++++++++++++++++---
 mm/page_alloc.c          |    2 +-
 2 files changed, 22 insertions(+), 4 deletions(-)

Index: linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/include/linux/topology.h
+++ linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
@@ -256,7 +256,17 @@ static inline int numa_node_id(void)
 DECLARE_PER_CPU(int, numa_mem);
 
 #ifndef set_numa_mem
-#define set_numa_mem(__node) percpu_write(numa_mem, __node)
+static inline void set_numa_mem(int node)
+{
+	percpu_write(numa_mem, node);
+}
+#endif
+
+#ifndef set_cpu_numa_mem
+static inline void set_cpu_numa_mem(int cpu, int node)
+{
+	per_cpu(numa_mem, cpu) = node;
+}
 #endif
 
 #else	/* !CONFIG_HAVE_MEMORYLESS_NODES */
@@ -264,15 +274,23 @@ DECLARE_PER_CPU(int, numa_mem);
 #define numa_mem numa_node
 static inline void set_numa_mem(int node) {}
 
+static inline void set_cpu_numa_mem(int cpu, int node) {}
+
 #endif	/* [!]CONFIG_HAVE_MEMORYLESS_NODES */
 
 #ifndef numa_mem_id
 /* Returns the number of the nearest Node with memory */
-#define numa_mem_id()		__this_cpu_read(numa_mem)
+static inline int numa_mem_id(void)
+{
+	return __this_cpu_read(numa_mem);
+}
 #endif
 
 #ifndef cpu_to_mem
-#define cpu_to_mem(__cpu)	per_cpu(numa_mem, (__cpu))
+static inline int cpu_to_mem(int cpu)
+{
+	return per_cpu(numa_mem, cpu);
+}
 #endif
 
 #ifndef topology_physical_package_id
Index: linux-2.6.34-rc5-mmotm-100428-1653/mm/page_alloc.c
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/mm/page_alloc.c
+++ linux-2.6.34-rc5-mmotm-100428-1653/mm/page_alloc.c
@@ -3000,7 +3000,7 @@ static int __build_all_zonelists(void *d
 		 * node/memory hotplug, we'll fixup all on-line cpus.
 		 */
 		if (cpu_online(cpu))
-			cpu_to_mem(cpu) = local_memory_node(cpu_to_node(cpu));
+			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
 #endif
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
