Message-Id: <20080115021737.571491000@sgi.com>
References: <20080115021735.779102000@sgi.com>
Date: Mon, 14 Jan 2008 18:17:45 -0800
From: travis@sgi.com
Subject: [PATCH 10/10] x86: Change bios_cpu_apicid to percpu data variable V2
Content-Disposition: inline; filename=change-bios_cpu_apicid-to-percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change static bios_cpu_apicid array to a per_cpu data variable.
This includes using a static array used during initialization
similar to the way x86_cpu_to_apicid[] is handled.

There is one early use of bios_cpu_apicid in apic_is_clustered_box().
The other reference in cpu_present_to_apicid() is called after
smp_set_apicids() has setup the percpu version of bios_cpu_apicid.


Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - Removed extraneous casts
    - Add slight optimization to apic_is_clustered_box()
      [don't reference x86_bios_cpu_apicid_early_ptr each pass.]
---
 arch/x86/kernel/apic_64.c    |   17 +++++++++++++++--
 arch/x86/kernel/mpparse_64.c |   12 +++++++++---
 arch/x86/kernel/setup_64.c   |    1 +
 arch/x86/kernel/smpboot_64.c |    3 +++
 include/asm-x86/smp_64.h     |    8 +++++---
 5 files changed, 33 insertions(+), 8 deletions(-)

--- a/arch/x86/kernel/apic_64.c
+++ b/arch/x86/kernel/apic_64.c
@@ -1150,19 +1150,32 @@ __cpuinit int apic_is_clustered_box(void
 {
 	int i, clusters, zeros;
 	unsigned id;
+	u16 *bios_cpu_apicid = x86_bios_cpu_apicid_early_ptr;
 	DECLARE_BITMAP(clustermap, NUM_APIC_CLUSTERS);
 
 	bitmap_zero(clustermap, NUM_APIC_CLUSTERS);
 
 	for (i = 0; i < NR_CPUS; i++) {
-		id = bios_cpu_apicid[i];
+		/* are we being called early in kernel startup? */
+		if (bios_cpu_apicid) {
+			id = bios_cpu_apicid[i];
+		}
+		else if (i < nr_cpu_ids) {
+			if (cpu_present(i))
+				id = per_cpu(x86_bios_cpu_apicid, i);
+			else
+				continue;
+		}
+		else
+			break;
+
 		if (id != BAD_APICID)
 			__set_bit(APIC_CLUSTERID(id), clustermap);
 	}
 
 	/* Problem:  Partially populated chassis may not have CPUs in some of
 	 * the APIC clusters they have been allocated.  Only present CPUs have
-	 * bios_cpu_apicid entries, thus causing zeroes in the bitmap.  Since
+	 * x86_bios_cpu_apicid entries, thus causing zeroes in the bitmap.  Since
 	 * clusters are allocated sequentially, count zeros only if they are
 	 * bounded by ones.
 	 */
--- a/arch/x86/kernel/mpparse_64.c
+++ b/arch/x86/kernel/mpparse_64.c
@@ -67,7 +67,11 @@ unsigned disabled_cpus __cpuinitdata;
 /* Bitmask of physically existing CPUs */
 physid_mask_t phys_cpu_present_map = PHYSID_MASK_NONE;
 
-u16 bios_cpu_apicid[NR_CPUS] = { [0 ... NR_CPUS-1] = BAD_APICID };
+u16 x86_bios_cpu_apicid_init[NR_CPUS] __initdata
+				= { [0 ... NR_CPUS-1] = BAD_APICID };
+void *x86_bios_cpu_apicid_early_ptr;
+DEFINE_PER_CPU(u16, x86_bios_cpu_apicid) = BAD_APICID;
+EXPORT_PER_CPU_SYMBOL(x86_bios_cpu_apicid);
 
 
 /*
@@ -118,20 +122,22 @@ static void __cpuinit MP_processor_info(
 	physid_set(m->mpc_apicid, phys_cpu_present_map);
  	if (m->mpc_cpuflag & CPU_BOOTPROCESSOR) {
  		/*
- 		 * bios_cpu_apicid is required to have processors listed
+		 * x86_bios_cpu_apicid is required to have processors listed
  		 * in same order as logical cpu numbers. Hence the first
  		 * entry is BSP, and so on.
  		 */
 		cpu = 0;
  	}
-	bios_cpu_apicid[cpu] = m->mpc_apicid;
 	/* are we being called early in kernel startup? */
 	if (x86_cpu_to_apicid_early_ptr) {
 		u16 *cpu_to_apicid = x86_cpu_to_apicid_early_ptr;
+		u16 *bios_cpu_apicid = x86_bios_cpu_apicid_early_ptr;
 
 		cpu_to_apicid[cpu] = m->mpc_apicid;
+		bios_cpu_apicid[cpu] = m->mpc_apicid;
 	} else {
 		per_cpu(x86_cpu_to_apicid, cpu) = m->mpc_apicid;
+		per_cpu(x86_bios_cpu_apicid, cpu) = m->mpc_apicid;
 	}
 
 	cpu_set(cpu, cpu_possible_map);
--- a/arch/x86/kernel/setup_64.c
+++ b/arch/x86/kernel/setup_64.c
@@ -375,6 +375,7 @@ void __init setup_arch(char **cmdline_p)
 #ifdef CONFIG_SMP
 	/* setup to use the early static init tables during kernel startup */
 	x86_cpu_to_apicid_early_ptr = (void *)&x86_cpu_to_apicid_init;
+	x86_bios_cpu_apicid_early_ptr = (void *)&x86_bios_cpu_apicid_init;
 #ifdef CONFIG_NUMA
 	x86_cpu_to_node_map_early_ptr = (void *)&x86_cpu_to_node_map_init;
 #endif
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -864,6 +864,8 @@ void __init smp_set_apicids(void)
 		if (per_cpu_offset(cpu)) {
 			per_cpu(x86_cpu_to_apicid, cpu) =
 						x86_cpu_to_apicid_init[cpu];
+			per_cpu(x86_bios_cpu_apicid, cpu) =
+						x86_bios_cpu_apicid_init[cpu];
 #ifdef CONFIG_NUMA
 			per_cpu(x86_cpu_to_node_map, cpu) =
 						x86_cpu_to_node_map_init[cpu];
@@ -876,6 +878,7 @@ void __init smp_set_apicids(void)
 
 	/* indicate the early static arrays are gone */
 	x86_cpu_to_apicid_early_ptr = NULL;
+	x86_bios_cpu_apicid_early_ptr = NULL;
 #ifdef CONFIG_NUMA
 	x86_cpu_to_node_map_early_ptr = NULL;
 #endif
--- a/include/asm-x86/smp_64.h
+++ b/include/asm-x86/smp_64.h
@@ -27,18 +27,20 @@ extern int smp_call_function_mask(cpumas
 				  void *info, int wait);
 
 extern u16 __initdata x86_cpu_to_apicid_init[];
+extern u16 __initdata x86_bios_cpu_apicid_init[];
 extern void *x86_cpu_to_apicid_early_ptr;
-extern u16 bios_cpu_apicid[];
+extern void *x86_bios_cpu_apicid_early_ptr;
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
 DECLARE_PER_CPU(u16, cpu_llc_id);
 DECLARE_PER_CPU(u16, x86_cpu_to_apicid);
+DECLARE_PER_CPU(u16, x86_bios_cpu_apicid);
 
 static inline int cpu_present_to_apicid(int mps_cpu)
 {
-	if (mps_cpu < NR_CPUS)
-		return (int)bios_cpu_apicid[mps_cpu];
+	if (cpu_present(mps_cpu))
+		return (int)per_cpu(x86_bios_cpu_apicid, mps_cpu);
 	else
 		return BAD_APICID;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
