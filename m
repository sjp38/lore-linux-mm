Message-Id: <20070912015647.758716998@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:54 -0700
From: travis@sgi.com
Subject: [PATCH 10/10] sparc64: Convert cpu_sibling_map to a per_cpu data array (v3)
Content-Disposition: inline; filename=convert-sparc64-cpu_sibling_map-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert cpu_sibling_map to a per_cpu cpumask_t array for the sparc64
architecture.  This fixes build errors in block/blktrace.c and
kernel/sched.c when CONFIG_SCHED_SMT is defined.

Note: these changes have not been built nor tested.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/sparc64/kernel/smp.c      |   17 ++++++++---------
 include/asm-sparc64/smp.h      |    3 ++-
 include/asm-sparc64/topology.h |    2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

--- a/arch/sparc64/kernel/smp.c
+++ b/arch/sparc64/kernel/smp.c
@@ -52,14 +52,13 @@
 
 cpumask_t cpu_possible_map __read_mostly = CPU_MASK_NONE;
 cpumask_t cpu_online_map __read_mostly = CPU_MASK_NONE;
-cpumask_t cpu_sibling_map[NR_CPUS] __read_mostly =
-	{ [0 ... NR_CPUS-1] = CPU_MASK_NONE };
+DEFINE_PER_CPU(cpumask_t, cpu_sibling_map) = CPU_MASK_NONE;
 cpumask_t cpu_core_map[NR_CPUS] __read_mostly =
 	{ [0 ... NR_CPUS-1] = CPU_MASK_NONE };
 
 EXPORT_SYMBOL(cpu_possible_map);
 EXPORT_SYMBOL(cpu_online_map);
-EXPORT_SYMBOL(cpu_sibling_map);
+EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 EXPORT_SYMBOL(cpu_core_map);
 
 static cpumask_t smp_commenced_mask;
@@ -1259,16 +1258,16 @@
 	for_each_present_cpu(i) {
 		unsigned int j;
 
-		cpus_clear(cpu_sibling_map[i]);
+		cpus_clear(per_cpu(cpu_sibling_map, i));
 		if (cpu_data(i).proc_id == -1) {
-			cpu_set(i, cpu_sibling_map[i]);
+			cpu_set(i, per_cpu(cpu_sibling_map, i));
 			continue;
 		}
 
 		for_each_present_cpu(j) {
 			if (cpu_data(i).proc_id ==
 			    cpu_data(j).proc_id)
-				cpu_set(j, cpu_sibling_map[i]);
+				cpu_set(j, per_cpu(cpu_sibling_map, i));
 		}
 	}
 }
@@ -1340,9 +1339,9 @@
 		cpu_clear(cpu, cpu_core_map[i]);
 	cpus_clear(cpu_core_map[cpu]);
 
-	for_each_cpu_mask(i, cpu_sibling_map[cpu])
-		cpu_clear(cpu, cpu_sibling_map[i]);
-	cpus_clear(cpu_sibling_map[cpu]);
+	for_each_cpu_mask(i, per_cpu(cpu_sibling_map, cpu))
+		cpu_clear(cpu, per_cpu(cpu_sibling_map, i));
+	cpus_clear(per_cpu(cpu_sibling_map, cpu));
 
 	c = &cpu_data(cpu);
 
--- a/include/asm-sparc64/smp.h
+++ b/include/asm-sparc64/smp.h
@@ -28,8 +28,9 @@
  
 #include <asm/bitops.h>
 #include <asm/atomic.h>
+#include <asm/percpu.h>
 
-extern cpumask_t cpu_sibling_map[NR_CPUS];
+DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 extern cpumask_t cpu_core_map[NR_CPUS];
 extern int sparc64_multi_core;
 
--- a/include/asm-sparc64/topology.h
+++ b/include/asm-sparc64/topology.h
@@ -5,7 +5,7 @@
 #define topology_physical_package_id(cpu)	(cpu_data(cpu).proc_id)
 #define topology_core_id(cpu)			(cpu_data(cpu).core_id)
 #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
-#define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
+#define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #define mc_capable()				(sparc64_multi_core)
 #define smt_capable()				(sparc64_multi_core)
 #endif /* CONFIG_SMP */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
