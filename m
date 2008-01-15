Message-Id: <20080115021736.061141000@sgi.com>
References: <20080115021735.779102000@sgi.com>
Date: Mon, 14 Jan 2008 18:17:36 -0800
From: travis@sgi.com
Subject: [PATCH 01/10] x86: Change size of APICIDs from u8 to u16 V2
Content-Disposition: inline; filename=big_apicids
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change the size of APICIDs from u8 to u16.  This partially
supports the new x2apic mode that will be present on future
processor chips. (Chips actually support 32-bit APICIDs, but that
change is more intrusive. Supporting 16-bit is sufficient for now).

Signed-off-by: Jack Steiner <steiner@sgi.com>

I've included just the partial change from u8 to u16 apicids.  The
remaining x2apic changes will be in a separate patch.

In addition, the fake_node_to_pxm_map[] and fake_apicid_to_node[]
tables have been moved from local data to the __initdata section
reducing stack pressure when MAX_NUMNODES and MAX_LOCAL_APIC are
increased in size.

Signed-off-by: Mike Travis <travis@sgi.com>
Reviewed-by: Christoph Lameter <clameter@sgi.com>
---
V1->V2:
    - Remove extraneous casts
    - Add comment about node memory < NODE_MIN_SIZE
---
 arch/x86/kernel/genapic_64.c |    4 ++--
 arch/x86/kernel/mpparse_64.c |    4 ++--
 arch/x86/kernel/smpboot_64.c |    2 +-
 arch/x86/mm/numa_64.c        |    2 +-
 arch/x86/mm/srat_64.c        |   26 +++++++++++++++++---------
 include/asm-x86/processor.h  |   14 +++++++-------
 include/asm-x86/smp_64.h     |    8 ++++----
 7 files changed, 34 insertions(+), 26 deletions(-)

--- a/arch/x86/kernel/genapic_64.c
+++ b/arch/x86/kernel/genapic_64.c
@@ -32,10 +32,10 @@
  * array during this time.  Is it zeroed when the per_cpu
  * data area is removed.
  */
-u8 x86_cpu_to_apicid_init[NR_CPUS] __initdata
+u16 x86_cpu_to_apicid_init[NR_CPUS] __initdata
 					= { [0 ... NR_CPUS-1] = BAD_APICID };
 void *x86_cpu_to_apicid_ptr;
-DEFINE_PER_CPU(u8, x86_cpu_to_apicid) = BAD_APICID;
+DEFINE_PER_CPU(u16, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
 
 struct genapic __read_mostly *genapic = &apic_flat;
--- a/arch/x86/kernel/mpparse_64.c
+++ b/arch/x86/kernel/mpparse_64.c
@@ -67,7 +67,7 @@ unsigned disabled_cpus __cpuinitdata;
 /* Bitmask of physically existing CPUs */
 physid_mask_t phys_cpu_present_map = PHYSID_MASK_NONE;
 
-u8 bios_cpu_apicid[NR_CPUS] = { [0 ... NR_CPUS-1] = BAD_APICID };
+u16 bios_cpu_apicid[NR_CPUS] = { [0 ... NR_CPUS-1] = BAD_APICID };
 
 
 /*
@@ -132,7 +132,7 @@ static void __cpuinit MP_processor_info(
 	 * area is created.
 	 */
 	if (x86_cpu_to_apicid_ptr) {
-		u8 *x86_cpu_to_apicid = (u8 *)x86_cpu_to_apicid_ptr;
+		u16 *x86_cpu_to_apicid = x86_cpu_to_apicid_ptr;
 		x86_cpu_to_apicid[cpu] = m->mpc_apicid;
 	} else {
 		per_cpu(x86_cpu_to_apicid, cpu) = m->mpc_apicid;
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -65,7 +65,7 @@ int smp_num_siblings = 1;
 EXPORT_SYMBOL(smp_num_siblings);
 
 /* Last level cache ID of each logical CPU */
-DEFINE_PER_CPU(u8, cpu_llc_id) = BAD_APICID;
+DEFINE_PER_CPU(u16, cpu_llc_id) = BAD_APICID;
 
 /* Bitmask of currently online CPUs */
 cpumask_t cpu_online_map __read_mostly;
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -627,7 +627,7 @@ void __init init_cpu_to_node(void)
 	int i;
 
 	for (i = 0; i < NR_CPUS; i++) {
-		u8 apicid = x86_cpu_to_apicid_init[i];
+		u16 apicid = x86_cpu_to_apicid_init[i];
 
 		if (apicid == BAD_APICID)
 			continue;
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -130,6 +130,9 @@ void __init
 acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 {
 	int pxm, node;
+	int apic_id;
+
+	apic_id = pa->apic_id;
 	if (srat_disabled())
 		return;
 	if (pa->header.length != sizeof(struct acpi_srat_cpu_affinity)) {
@@ -145,10 +148,10 @@ acpi_numa_processor_affinity_init(struct
 		bad_srat();
 		return;
 	}
-	apicid_to_node[pa->apic_id] = node;
+	apicid_to_node[apic_id] = node;
 	acpi_numa = 1;
 	printk(KERN_INFO "SRAT: PXM %u -> APIC %u -> Node %u\n",
-	       pxm, pa->apic_id, node);
+	       pxm, apic_id, node);
 }
 
 int update_end_of_memory(unsigned long end) {return -1;}
@@ -343,7 +346,12 @@ int __init acpi_scan_nodes(unsigned long
 	/* First clean up the node list */
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		cutoff_node(i, start, end);
-		if ((nodes[i].end - nodes[i].start) < NODE_MIN_SIZE) {
+		/*
+		 * don't confuse VM with a node that doesn't have the
+		 * minimum memory.
+		 */
+		if (nodes[i].end &&
+			(nodes[i].end - nodes[i].start) < NODE_MIN_SIZE) {
 			unparse_node(i);
 			node_set_offline(i);
 		}
@@ -384,6 +392,12 @@ int __init acpi_scan_nodes(unsigned long
 }
 
 #ifdef CONFIG_NUMA_EMU
+static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
+	[0 ... MAX_NUMNODES-1] = PXM_INVAL
+};
+static unsigned char fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
+	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
+};
 static int __init find_node_by_addr(unsigned long addr)
 {
 	int ret = NUMA_NO_NODE;
@@ -414,12 +428,6 @@ static int __init find_node_by_addr(unsi
 void __init acpi_fake_nodes(const struct bootnode *fake_nodes, int num_nodes)
 {
 	int i, j;
-	int fake_node_to_pxm_map[MAX_NUMNODES] = {
-		[0 ... MAX_NUMNODES-1] = PXM_INVAL
-	};
-	unsigned char fake_apicid_to_node[MAX_LOCAL_APIC] = {
-		[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
-	};
 
 	printk(KERN_INFO "Faking PXM affinity for fake nodes on real "
 			 "topology.\n");
--- a/include/asm-x86/processor.h
+++ b/include/asm-x86/processor.h
@@ -86,14 +86,14 @@ struct cpuinfo_x86 {
 #ifdef CONFIG_SMP
 	cpumask_t llc_shared_map;	/* cpus sharing the last level cache */
 #endif
-	unsigned char x86_max_cores;	/* cpuid returned max cores value */
-	unsigned char apicid;
-	unsigned short x86_clflush_size;
+	u16 x86_max_cores;		/* cpuid returned max cores value */
+	u16 apicid;
+	u16 x86_clflush_size;
 #ifdef CONFIG_SMP
-	unsigned char booted_cores;	/* number of cores as seen by OS */
-	__u8 phys_proc_id; 		/* Physical processor id. */
-	__u8 cpu_core_id;  		/* Core id */
-	__u8 cpu_index;			/* index into per_cpu list */
+	u16 booted_cores;		/* number of cores as seen by OS */
+	u16 phys_proc_id; 		/* Physical processor id. */
+	u16 cpu_core_id;  		/* Core id */
+	u16 cpu_index;			/* index into per_cpu list */
 #endif
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
--- a/include/asm-x86/smp_64.h
+++ b/include/asm-x86/smp_64.h
@@ -26,14 +26,14 @@ extern void unlock_ipi_call_lock(void);
 extern int smp_call_function_mask(cpumask_t mask, void (*func)(void *),
 				  void *info, int wait);
 
-extern u8 __initdata x86_cpu_to_apicid_init[];
+extern u16 __initdata x86_cpu_to_apicid_init[];
 extern void *x86_cpu_to_apicid_ptr;
-extern u8 bios_cpu_apicid[];
+extern u16 bios_cpu_apicid[];
 
 DECLARE_PER_CPU(cpumask_t, cpu_sibling_map);
 DECLARE_PER_CPU(cpumask_t, cpu_core_map);
-DECLARE_PER_CPU(u8, cpu_llc_id);
-DECLARE_PER_CPU(u8, x86_cpu_to_apicid);
+DECLARE_PER_CPU(u16, cpu_llc_id);
+DECLARE_PER_CPU(u16, x86_cpu_to_apicid);
 
 static inline int cpu_present_to_apicid(int mps_cpu)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
