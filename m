Message-Id: <20080121211600.671953000@sgi.com>
References: <20080121211600.079162000@sgi.com>
Date: Mon, 21 Jan 2008 13:16:04 -0800
From: travis@sgi.com
Subject: [PATCH 4/4] x86: Add debug of invalid per_cpu map accesses fixup V2
Content-Disposition: inline; filename=debug-cpu_to_node
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Provide a means to discover usages of per_cpu map variables before
they are setup.  Define CONFIG_DEBUG_PER_CPU_MAPS to activate.

Based on 2.6.24-rc8-mm1

Signed-off-by: Mike Travis <travis@sgi.com>
---
Fixup:
    - for cpu_to_node() instead of panic'ing with BUG() use
      dump_stack and return valid node id.
---
 arch/x86/Kconfig.debug     |   12 ++++++++++++
 arch/x86/mm/numa_64.c      |    3 +++
 include/asm-x86/topology.h |   12 ++++++++++--
 3 files changed, 25 insertions(+), 2 deletions(-)

--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -47,6 +47,18 @@ config DEBUG_PAGEALLOC
 	  This results in a large slowdown, but helps to find certain types
 	  of memory corruptions.
 
+config DEBUG_PER_CPU_MAPS
+	bool "Debug access to per_cpu maps"
+	depends on DEBUG_KERNEL
+	depends on X86_64_SMP
+	default n
+	help
+	  Say Y to verify that the per_cpu map being accessed has
+	  been setup.  Adds a fair amount of code to kernel memory
+	  and decreases performance.
+
+	  Say N if unsure.
+
 config DEBUG_RODATA
 	bool "Write protect kernel read-only data structures"
 	depends on DEBUG_KERNEL
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -37,6 +37,9 @@ int x86_cpu_to_node_map_init[NR_CPUS] = 
 void *x86_cpu_to_node_map_early_ptr;
 DEFINE_PER_CPU(int, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);
+#ifdef	CONFIG_DEBUG_PER_CPU_MAPS
+EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
+#endif
 
 s16 apicid_to_node[MAX_LOCAL_APIC] __cpuinitdata = {
 	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
--- a/include/asm-x86/topology.h
+++ b/include/asm-x86/topology.h
@@ -58,7 +58,7 @@ static inline int early_cpu_to_node(int 
 
 	if (cpu_to_node_map)
 		return cpu_to_node_map[cpu];
-	else if(per_cpu_offset(cpu))
+	else if (per_cpu_offset(cpu))
 		return per_cpu(x86_cpu_to_node_map, cpu);
 	else
 		return NUMA_NO_NODE;
@@ -66,7 +66,15 @@ static inline int early_cpu_to_node(int 
 
 static inline int cpu_to_node(int cpu)
 {
-	if(per_cpu_offset(cpu))
+#ifdef CONFIG_DEBUG_PER_CPU_MAPS
+	if (x86_cpu_to_node_map_early_ptr) {
+		printk("KERN_NOTICE cpu_to_node(%d): usage too early!\n",
+			(int)cpu);
+		dump_stack();
+		return ((int *)x86_cpu_to_node_map_early_ptr)[cpu];
+	}
+#endif
+	if (per_cpu_offset(cpu))
 		return per_cpu(x86_cpu_to_node_map, cpu);
 	else
 		return NUMA_NO_NODE;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
