Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 207AF600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 11:07:13 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 03 May 2010 11:07:08 -0400
Message-Id: <20100503150708.15039.67683.sendpatchset@localhost.localdomain>
In-Reply-To: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
Subject: [PATCH 6/7] numa-introduce-numa_mem_id-effective-local-memory-node-id-fix3
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Valdis.Kletnieks@vt.edu, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Incremental patch 2 to
numa-introduce-numa_mem_id-effective-local-memory-node-id
in 28april10 mmotm.

Remove the "#define numa_mem numa_node" when !HAVE_MEMORYLESS_NODES
from topology.h per Tejun Heo.  Because 'numa_mem' is [was] a percpu
variable, we cannot make it a macro with arguments or a static inline
function.  I considered making it a variable alias for numa_node, but
since both are percpu variables whose actual definitions and declarations
are buried deep in the DECLARE_PER_CPU() macros, I proposed a
DECLARE_PER_CPU_ALIAS(variable, alias).  Tejun agreed that if this
were a common occurrence, that would be a good idea, but since we
currently have only this instance, we agreed to just eliminate
the numa_mem variable when !HAVE_MEMORYLESS_NODES.

This patch renames the variable to _numa_mem_ and adds warnings
in both linux/topology.h and mm/page_alloc.c against referencing
the variable directly.  The accessor functions numa_mem_id() and
cpu_to_mem() will return the appropriate value when
!HAVE_MEMORYLESS_NODES.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/topology.h |   35 +++++++++++++++++++++++++++--------
 mm/page_alloc.c          |   10 ++++++++--
 2 files changed, 35 insertions(+), 10 deletions(-)

Index: linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/include/linux/topology.h
+++ linux-2.6.34-rc5-mmotm-100428-1653/include/linux/topology.h
@@ -253,46 +253,65 @@ static inline int numa_node_id(void)
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 
-DECLARE_PER_CPU(int, numa_mem);
+/*
+ * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
+ * It will not be defined when CONFIG_HAVE_MEMORYLESS_NODES is not defined.
+ * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem().
+ */
+DECLARE_PER_CPU(int, _numa_mem_);
 
 #ifndef set_numa_mem
 static inline void set_numa_mem(int node)
 {
-	percpu_write(numa_mem, node);
+	percpu_write(_numa_mem_, node);
+}
+#endif
+
+#ifndef numa_mem_id
+/* Returns the number of the nearest Node with memory */
+static inline int numa_mem_id(void)
+{
+	return __this_cpu_read(_numa_mem_);
+}
+#endif
+
+#ifndef cpu_to_mem
+static inline int cpu_to_mem(int cpu)
+{
+	return per_cpu(_numa_mem_, cpu);
 }
 #endif
 
 #ifndef set_cpu_numa_mem
 static inline void set_cpu_numa_mem(int cpu, int node)
 {
-	per_cpu(numa_mem, cpu) = node;
+	per_cpu(_numa_mem_, cpu) = node;
 }
 #endif
 
 #else	/* !CONFIG_HAVE_MEMORYLESS_NODES */
 
-#define numa_mem numa_node
 static inline void set_numa_mem(int node) {}
 
 static inline void set_cpu_numa_mem(int cpu, int node) {}
 
-#endif	/* [!]CONFIG_HAVE_MEMORYLESS_NODES */
-
 #ifndef numa_mem_id
 /* Returns the number of the nearest Node with memory */
 static inline int numa_mem_id(void)
 {
-	return __this_cpu_read(numa_mem);
+	return numa_node_id();
 }
 #endif
 
 #ifndef cpu_to_mem
 static inline int cpu_to_mem(int cpu)
 {
-	return per_cpu(numa_mem, cpu);
+	return cpu_to_node(cpu);
 }
 #endif
 
+#endif	/* [!]CONFIG_HAVE_MEMORYLESS_NODES */
+
 #ifndef topology_physical_package_id
 #define topology_physical_package_id(cpu)	((void)(cpu), -1)
 #endif
Index: linux-2.6.34-rc5-mmotm-100428-1653/mm/page_alloc.c
===================================================================
--- linux-2.6.34-rc5-mmotm-100428-1653.orig/mm/page_alloc.c
+++ linux-2.6.34-rc5-mmotm-100428-1653/mm/page_alloc.c
@@ -63,8 +63,14 @@ EXPORT_PER_CPU_SYMBOL(numa_node);
 #endif
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-DEFINE_PER_CPU(int, numa_mem);		/* Kernel "local memory" node */
-EXPORT_PER_CPU_SYMBOL(numa_mem);
+/*
+ * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
+ * It will not be defined when CONFIG_HAVE_MEMORYLESS_NODES is not defined.
+ * Use the accessor functions set_numa_mem(), numa_mem_id() and cpu_to_mem()
+ * defined in <linux/topology.h>.
+ */
+DEFINE_PER_CPU(int, _numa_mem_);		/* Kernel "local memory" node */
+EXPORT_PER_CPU_SYMBOL(_numa_mem_);
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
