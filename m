Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3BAB06B0029
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 03:01:16 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH] x86, ACPI, mm: Revert SRAT support from movablemem_map boot option.
Date: Thu, 28 Feb 2013 16:00:38 +0800
Message-Id: <1362038438-22033-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org, akpm@linux-foundation.org, don.morris@hp.com, tim.gardner@canonical.com, hpa@zytor.com, torvalds@linux-foundation.org, tj@kernel.org, tony.luck@intel.com, trenn@suse.de, tglx@linutronix.de, mingo@redhat.com, a.p.zijlstra@chello.nl, jarkko.sakkinen@intel.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, x86@kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

The following two commits suooprt getting info from SRAT and determine
which memory is hot-pluggable, also AKA "movablemem_map=srat" boot option.

	commit 01a178a94e8eaec351b29ee49fbb3d1c124cb7fb
		acpi, memory-hotplug: support getting hotplug info from SRAT
	commit e8d1955258091e4c92d5a975ebd7fd8a98f5d30f
		acpi, memory-hotplug: parse SRAT before memblock is ready

We need to know SRAT info before memblock is ready, so that we can
prevent memblock from allocate movable memory.

To achieve goal, we moved SRAT parsing code earlier in these patches. But it broke
ACPI_INITRD_TABLE_OVERRIDE functionality, and the fallback path of numa_init().

So we revert these two commits for now. And after that, users can only use
"movablemem_map=nn[KMG]@ss[KMG]".

NOTE: 
1) It is OK to revert only these two patches. The core problems mentioned by
   Lu Yinghai:
   1. numa_init is called several times, NOT just for srat. so those
	nodes_clear(numa_nodes_parsed)
	memset(&numa_meminfo, 0, sizeof(numa_meminfo))
      can not be just removed.  Need to consider sequence is: numaq, srat, amd, dummy.
      and make fall back path working.
   2. simply split acpi_numa_init to early_parse_srat.
      a. that early_parse_srat is NOT called for ia64, so you break ia64.
      b. for (i = 0; i < MAX_LOCAL_APIC; i++)
	    set_apicid_to_node(i, NUMA_NO_NODE)
         still left in numa_init. So it will just clear result from early_parse_srat.
         it should be moved before that....
      c.  it breaks ACPI_TABLE_OVERRIDE...as the acpi table scan is moved
          early before override from INITRD is settled.

   They are caused by moving SRAT parsing earlier. And "movablemem_map=nn[KMG]@ss[KMG]" 
   causes no harm to kernel.

2) With these two patches reverted, memblock will start to work before we parse SRAT,
   which means we won't know the end address of each node early enough.

   For example:
   If one node has memory [10G, 20G), and user specifies [15G, 16G), we cannot extend
   it to [15G, 20G). So memblock could still have a chance to allocate memory from
   [16G, 20G) for kernel, which is non-movable.

   As a resule, users could only use this option in a very limit way: 
   They should specify the memory range to the end of each node.

Reported-by: Tim Gardner <tim.gardner@canonical.com>
Reported-by: Don Morris <don.morris@hp.com>
Bisected-by: Don Morris <don.morris@hp.com>
Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Thomas Renninger <trenn@suse.de>
Cc: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   29 ++------------
 arch/x86/kernel/setup.c             |   13 ++----
 arch/x86/mm/numa.c                  |    6 +--
 arch/x86/mm/srat.c                  |   71 ++--------------------------------
 drivers/acpi/numa.c                 |   23 +++++------
 include/linux/acpi.h                |    8 ----
 include/linux/mm.h                  |    2 -
 mm/page_alloc.c                     |   22 +----------
 8 files changed, 27 insertions(+), 147 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 7660877..722a741 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1640,30 +1640,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movablemem_map=acpi
-			[KNL,X86,IA-64,PPC] This parameter is similar to
-			memmap except it specifies the memory map of
-			ZONE_MOVABLE.
-			This option inform the kernel to use Hot Pluggable bit
-			in flags from SRAT from ACPI BIOS to determine which
-			memory devices could be hotplugged. The corresponding
-			memory ranges will be set as ZONE_MOVABLE.
-			NOTE: Whatever node the kernel resides in will always
-			      be un-hotpluggable.
-
 	movablemem_map=nn[KMG]@ss[KMG]
 			[KNL,X86,IA-64,PPC] This parameter is similar to
 			memmap except it specifies the memory map of
 			ZONE_MOVABLE.
-			If user specifies memory ranges, the info in SRAT will
-			be ingored. And it works like the following:
-			- If more ranges are all within one node, then from
-			  lowest ss to the end of the node will be ZONE_MOVABLE.
-			- If a range is within a node, then from ss to the end
-			  of the node will be ZONE_MOVABLE.
-			- If a range covers two or more nodes, then from ss to
-			  the end of the 1st node will be ZONE_MOVABLE, and all
-			  the rest nodes will only have ZONE_MOVABLE.
+			If more areas are all within one node, then from
+			lowest ss to the end of the node will be ZONE_MOVABLE.
+			If an area covers two or more nodes, the area from
+			ss to the end of the 1st node will be ZONE_MOVABLE,
+			and all the rest nodes will only have ZONE_MOVABLE.
 			If memmap is specified at the same time, the
 			movablemem_map will be limited within the memmap
 			areas. If kernelcore or movablecore is also specified,
@@ -1671,10 +1656,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			satisfied. So the administrator should be careful that
 			the amount of movablemem_map areas are not too large.
 			Otherwise kernel won't have enough memory to start.
-			NOTE: We don't stop users specifying the node the
-			      kernel resides in as hotpluggable so that this
-			      option can be used as a workaround of firmware
-                              bugs.
 
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 9c857f0..915f5ef 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1056,15 +1056,6 @@ void __init setup_arch(char **cmdline_p)
 	setup_bios_corruption_check();
 #endif
 
-	/*
-	 * In the memory hotplug case, the kernel needs info from SRAT to
-	 * determine which memory is hotpluggable before allocating memory
-	 * using memblock.
-	 */
-	acpi_boot_table_init();
-	early_acpi_boot_init();
-	early_parse_srat();
-
 #ifdef CONFIG_X86_32
 	printk(KERN_DEBUG "initial memory mapped: [mem 0x00000000-%#010lx]\n",
 			(max_pfn_mapped<<PAGE_SHIFT) - 1);
@@ -1110,6 +1101,10 @@ void __init setup_arch(char **cmdline_p)
 	/*
 	 * Parse the ACPI tables for possible boot-time SMP configuration.
 	 */
+	acpi_boot_table_init();
+
+	early_acpi_boot_init();
+
 	initmem_init();
 	memblock_find_dma_reserve();
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index dfd3025..e3963f5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -560,12 +560,10 @@ static int __init numa_init(int (*init_func)(void))
 	for (i = 0; i < MAX_LOCAL_APIC; i++)
 		set_apicid_to_node(i, NUMA_NO_NODE);
 
-	/*
-	 * Do not clear numa_nodes_parsed or zero numa_meminfo here, because
-	 * SRAT was parsed earlier in early_parse_srat().
-	 */
+	nodes_clear(numa_nodes_parsed);
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
+	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, MAX_NUMNODES));
 	numa_reset_distance();
 
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 79836d0..3e90039 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -142,72 +142,16 @@ static inline int save_add_info(void) {return 0;}
 #endif
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-static void __init
-handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
+static void __init handle_movablemem(int node, u64 start, u64 end)
 {
-	int overlap, i;
+	int overlap;
 	unsigned long start_pfn, end_pfn;
 
 	start_pfn = PFN_DOWN(start);
 	end_pfn = PFN_UP(end);
 
 	/*
-	 * For movablemem_map=acpi:
-	 *
-	 * SRAT:		|_____| |_____| |_________| |_________| ......
-	 * node id:                0       1         1           2
-	 * hotpluggable:	   n       y         y           n
-	 * movablemem_map:	        |_____| |_________|
-	 *
-	 * Using movablemem_map, we can prevent memblock from allocating memory
-	 * on ZONE_MOVABLE at boot time.
-	 *
-	 * Before parsing SRAT, memblock has already reserve some memory ranges
-	 * for other purposes, such as for kernel image. We cannot prevent
-	 * kernel from using these memory, so we need to exclude these memory
-	 * even if it is hotpluggable.
-	 * Furthermore, to ensure the kernel has enough memory to boot, we make
-	 * all the memory on the node which the kernel resides in
-	 * un-hotpluggable.
-	 */
-	if (hotpluggable && movablemem_map.acpi) {
-		/* Exclude ranges reserved by memblock. */
-		struct memblock_type *rgn = &memblock.reserved;
-
-		for (i = 0; i < rgn->cnt; i++) {
-			if (end <= rgn->regions[i].base ||
-			    start >= rgn->regions[i].base +
-			    rgn->regions[i].size)
-				continue;
-
-			/*
-			 * If the memory range overlaps the memory reserved by
-			 * memblock, then the kernel resides in this node.
-			 */
-			node_set(node, movablemem_map.numa_nodes_kernel);
-
-			goto out;
-		}
-
-		/*
-		 * If the kernel resides in this node, then the whole node
-		 * should not be hotpluggable.
-		 */
-		if (node_isset(node, movablemem_map.numa_nodes_kernel))
-			goto out;
-
-		insert_movablemem_map(start_pfn, end_pfn);
-
-		/*
-		 * numa_nodes_hotplug nodemask represents which nodes are put
-		 * into movablemem_map.map[].
-		 */
-		node_set(node, movablemem_map.numa_nodes_hotplug);
-		goto out;
-	}
-
-	/*
-	 * For movablemem_map=nn[KMG]@ss[KMG]:
+	 * For movablecore_map=nn[KMG]@ss[KMG]:
 	 *
 	 * SRAT:		|_____| |_____| |_________| |_________| ......
 	 * node id:		   0       1         1           2
@@ -216,8 +160,6 @@ handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
 	 *
 	 * Using movablemem_map, we can prevent memblock from allocating memory
 	 * on ZONE_MOVABLE at boot time.
-	 *
-	 * NOTE: In this case, SRAT info will be ingored.
 	 */
 	overlap = movablemem_map_overlap(start_pfn, end_pfn);
 	if (overlap >= 0) {
@@ -245,12 +187,9 @@ handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
 			 */
 			insert_movablemem_map(start_pfn, end_pfn);
 	}
-out:
-	return;
 }
 #else		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
-static inline void
-handle_movablemem(int node, u64 start, u64 end, u32 hotpluggable)
+static inline void handle_movablemem(int node, u64 start, u64 end)
 {
 }
 #endif		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
@@ -295,7 +234,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	       (unsigned long long) start, (unsigned long long) end - 1,
 	       hotpluggable ? "Hot Pluggable": "");
 
-	handle_movablemem(node, start, end, hotpluggable);
+	handle_movablemem(node, start, end);
 
 	return 0;
 out_err_bad_srat:
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 59844ee..33e609f 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -282,10 +282,10 @@ acpi_table_parse_srat(enum acpi_srat_type id,
 					    handler, max_entries);
 }
 
-static int srat_mem_cnt;
-
-void __init early_parse_srat(void)
+int __init acpi_numa_init(void)
 {
+	int cnt = 0;
+
 	/*
 	 * Should not limit number with cpu num that is from NR_CPUS or nr_cpus=
 	 * SRAT cpu entries could have different order with that in MADT.
@@ -295,24 +295,21 @@ void __init early_parse_srat(void)
 	/* SRAT: Static Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_X2APIC_CPU_AFFINITY,
-				      acpi_parse_x2apic_affinity, 0);
+				     acpi_parse_x2apic_affinity, 0);
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_CPU_AFFINITY,
-				      acpi_parse_processor_affinity, 0);
-		srat_mem_cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
-						     acpi_parse_memory_affinity,
-						     NR_NODE_MEMBLKS);
+				     acpi_parse_processor_affinity, 0);
+		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
+					    acpi_parse_memory_affinity,
+					    NR_NODE_MEMBLKS);
 	}
-}
 
-int __init acpi_numa_init(void)
-{
 	/* SLIT: System Locality Information Table */
 	acpi_table_parse(ACPI_SIG_SLIT, acpi_parse_slit);
 
 	acpi_numa_arch_fixup();
 
-	if (srat_mem_cnt < 0)
-		return srat_mem_cnt;
+	if (cnt < 0)
+		return cnt;
 	else if (!parsed_numa_memblks)
 		return -ENOENT;
 	return 0;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index f46cfd7..bcbdd74 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -485,14 +485,6 @@ static inline bool acpi_driver_match_device(struct device *dev,
 
 #endif	/* !CONFIG_ACPI */
 
-#ifdef CONFIG_ACPI_NUMA
-void __init early_parse_srat(void);
-#else
-static inline void early_parse_srat(void)
-{
-}
-#endif
-
 #ifdef CONFIG_ACPI
 void acpi_os_set_prepare_sleep(int (*func)(u8 sleep_state,
 			       u32 pm1a_ctrl,  u32 pm1b_ctrl));
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e7c3f9a..7cbf316 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1340,11 +1340,9 @@ struct movablemem_entry {
 };
 
 struct movablemem_map {
-	bool acpi;	/* true if using SRAT info */
 	int nr_map;
 	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
 	nodemask_t numa_nodes_hotplug;	/* on which nodes we specify memory */
-	nodemask_t numa_nodes_kernel;	/* on which nodes kernel resides in */
 };
 
 extern void __init insert_movablemem_map(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e9075fd..386dfb7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -203,10 +203,7 @@ static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /* Movable memory ranges, will also be used by memblock subsystem. */
-struct movablemem_map movablemem_map = {
-	.acpi = false,
-	.nr_map = 0,
-};
+struct movablemem_map movablemem_map;
 
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
@@ -5350,23 +5347,6 @@ static int __init cmdline_parse_movablemem_map(char *p)
 	if (!p)
 		goto err;
 
-	if (!strcmp(p, "acpi"))
-		movablemem_map.acpi = true;
-
-	/*
-	 * If user decide to use info from BIOS, all the other user specified
-	 * ranges will be ingored.
-	 */
-	if (movablemem_map.acpi) {
-		if (movablemem_map.nr_map) {
-			memset(movablemem_map.map, 0,
-				sizeof(struct movablemem_entry)
-				* movablemem_map.nr_map);
-			movablemem_map.nr_map = 0;
-		}
-		return 0;
-	}
-
 	oldp = p;
 	mem_size = memparse(p, &p);
 	if (p == oldp)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
