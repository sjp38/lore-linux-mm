Message-Id: <20070907040944.380253345@sgi.com>
References: <20070907040943.467530005@sgi.com>
Date: Thu, 06 Sep 2007 21:09:46 -0700
From: travis@sgi.com
Subject: [PATCH 3/3] ppc64: Convert cpu_sibling_map to a per_cpu data array
Content-Disposition: inline; filename=ppc64-convert-cpu_sibling_map-to-per_cpu_data
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Convert cpu_sibling_map to a per_cpu cpumask_t array for the ppc64
architecture.

Note: these changes have not been built nor tested.

Note: I also don't know if these changes are particularly
relevant for the ppc64 architecture.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/powerpc/kernel/setup-common.c        |    4 ++--
 arch/powerpc/kernel/smp.c                 |    4 ++--
 arch/powerpc/platforms/cell/cbe_cpufreq.c |    2 +-
 include/asm-powerpc/smp.h                 |    3 ++-
 include/asm-powerpc/topology.h            |    2 +-
 5 files changed, 8 insertions(+), 7 deletions(-)

--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -415,9 +415,9 @@
 	 * Do the sibling map; assume only two threads per processor.
 	 */
 	for_each_possible_cpu(cpu) {
-		cpu_set(cpu, cpu_sibling_map[cpu]);
+		cpu_set(cpu, cpu_sibling_map(cpu));
 		if (cpu_has_feature(CPU_FTR_SMT))
-			cpu_set(cpu ^ 0x1, cpu_sibling_map[cpu]);
+			cpu_set(cpu ^ 0x1, cpu_sibling_map(cpu));
 	}
 
 	vdso_data->processorCount = num_present_cpus();
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -61,11 +61,11 @@
 
 cpumask_t cpu_possible_map = CPU_MASK_NONE;
 cpumask_t cpu_online_map = CPU_MASK_NONE;
-cpumask_t cpu_sibling_map[NR_CPUS] = { [0 ... NR_CPUS-1] = CPU_MASK_NONE };
+DEFINE_PER_CPU(cpumask_t, cpu_sibling_map) = CPU_MASK_NONE;
 
 EXPORT_SYMBOL(cpu_online_map);
 EXPORT_SYMBOL(cpu_possible_map);
-EXPORT_SYMBOL(cpu_sibling_map);
+EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 
 /* SMP operations for this machine */
 struct smp_ops_t *smp_ops;
--- a/arch/powerpc/platforms/cell/cbe_cpufreq.c
+++ b/arch/powerpc/platforms/cell/cbe_cpufreq.c
@@ -117,7 +117,7 @@
 	policy->cur = cbe_freqs[cur_pmode].frequency;
 
 #ifdef CONFIG_SMP
-	policy->cpus = cpu_sibling_map[policy->cpu];
+	policy->cpus = cpu_sibling_map(policy->cpu);
 #endif
 
 	cpufreq_frequency_table_get_attr(cbe_freqs, policy->cpu);
--- a/include/asm-powerpc/smp.h
+++ b/include/asm-powerpc/smp.h
@@ -58,7 +58,8 @@
 					(smp_hw_index[(cpu)] = (phys))
 #endif
 
-extern cpumask_t cpu_sibling_map[NR_CPUS];
+DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
+#define cpu_sibling_map(cpu) per_cpu(cpu_sibling_map, cpu)
 
 /* Since OpenPIC has only 4 IPIs, we use slightly different message numbers.
  *
--- a/include/asm-powerpc/topology.h
+++ b/include/asm-powerpc/topology.h
@@ -108,7 +108,7 @@
 #ifdef CONFIG_PPC64
 #include <asm/smp.h>
 
-#define topology_thread_siblings(cpu)	(cpu_sibling_map[cpu])
+#define topology_thread_siblings(cpu)	(cpu_sibling_map(cpu))
 #endif
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
