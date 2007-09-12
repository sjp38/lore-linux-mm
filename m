Message-Id: <20070912015647.214306428@sgi.com>
References: <20070912015644.927677070@sgi.com>
Date: Tue, 11 Sep 2007 18:56:52 -0700
From: travis@sgi.com
Subject: [PATCH 08/10] ia64: Convert cpu_sibling_map to a per_cpu data array (v3)
Content-Disposition: inline; filename=convert-ia64-cpu_sibling_map-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert cpu_sibling_map to a per_cpu cpumask_t array for the ia64
architecture.  This fixes build errors in block/blktrace.c and
kernel/sched.c when CONFIG_SCHED_SMT is defined.


There was one access to cpu_sibling_map before the per_cpu data
area was created, so that step was moved to after the per_cpu
area is setup.

Tested and verified on an A4700.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/ia64/kernel/setup.c    |    4 ----
 arch/ia64/kernel/smpboot.c  |   18 ++++++++++--------
 arch/ia64/mm/contig.c       |    6 ++++++
 include/asm-ia64/smp.h      |    2 +-
 include/asm-ia64/topology.h |    2 +-
 5 files changed, 18 insertions(+), 14 deletions(-)

--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -528,10 +528,6 @@
 
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();
-
-	cpu_set(0, cpu_sibling_map[0]);
-	cpu_set(0, cpu_core_map[0]);
-
 	check_for_logical_procs();
 	if (smp_num_cpucores > 1)
 		printk(KERN_INFO
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -138,7 +138,9 @@
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
-cpumask_t cpu_sibling_map[NR_CPUS] __cacheline_aligned;
+DEFINE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
+EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
+
 int smp_num_siblings = 1;
 int smp_num_cpucores = 1;
 
@@ -650,12 +652,12 @@
 {
 	int i;
 
-	for_each_cpu_mask(i, cpu_sibling_map[cpu])
-		cpu_clear(cpu, cpu_sibling_map[i]);
+	for_each_cpu_mask(i, per_cpu(cpu_sibling_map, cpu))
+		cpu_clear(cpu, per_cpu(cpu_sibling_map, i));
 	for_each_cpu_mask(i, cpu_core_map[cpu])
 		cpu_clear(cpu, cpu_core_map[i]);
 
-	cpu_sibling_map[cpu] = cpu_core_map[cpu] = CPU_MASK_NONE;
+	per_cpu(cpu_sibling_map, cpu) = cpu_core_map[cpu] = CPU_MASK_NONE;
 }
 
 static void
@@ -666,7 +668,7 @@
 	if (cpu_data(cpu)->threads_per_core == 1 &&
 	    cpu_data(cpu)->cores_per_socket == 1) {
 		cpu_clear(cpu, cpu_core_map[cpu]);
-		cpu_clear(cpu, cpu_sibling_map[cpu]);
+		cpu_clear(cpu, per_cpu(cpu_sibling_map, cpu));
 		return;
 	}
 
@@ -807,8 +809,8 @@
 			cpu_set(i, cpu_core_map[cpu]);
 			cpu_set(cpu, cpu_core_map[i]);
 			if (cpu_data(cpu)->core_id == cpu_data(i)->core_id) {
-				cpu_set(i, cpu_sibling_map[cpu]);
-				cpu_set(cpu, cpu_sibling_map[i]);
+				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
+				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
 			}
 		}
 	}
@@ -839,7 +841,7 @@
 
 	if (cpu_data(cpu)->threads_per_core == 1 &&
 	    cpu_data(cpu)->cores_per_socket == 1) {
-		cpu_set(cpu, cpu_sibling_map[cpu]);
+		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
 		cpu_set(cpu, cpu_core_map[cpu]);
 		return 0;
 	}
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -58,7 +58,7 @@
 
 extern cpumask_t cpu_online_map;
 extern cpumask_t cpu_core_map[NR_CPUS];
-extern cpumask_t cpu_sibling_map[NR_CPUS];
+DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 extern int smp_num_siblings;
 extern int smp_num_cpucores;
 extern void __iomem *ipi_base_addr;
--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -112,7 +112,7 @@
 #define topology_physical_package_id(cpu)	(cpu_data(cpu)->socket_id)
 #define topology_core_id(cpu)			(cpu_data(cpu)->core_id)
 #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
-#define topology_thread_siblings(cpu)		(cpu_sibling_map[cpu])
+#define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
 #define smt_capable() 				(smp_num_siblings > 1)
 #endif
 
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -212,6 +212,12 @@
 			cpu_data += PERCPU_PAGE_SIZE;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
 		}
+		/*
+		 * cpu_sibling_map is now a per_cpu variable - it needs to
+		 * be accessed after per_cpu_init() sets up the per_cpu area.
+		 */
+		cpu_set(0, per_cpu(cpu_sibling_map, 0));
+		cpu_set(0, cpu_core_map[0]);
 	}
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
