Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id CD4CB6B0008
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 04:43:01 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/3] acpi, memory-hotplug: Parse SRAT before memblock is ready.
Date: Fri, 25 Jan 2013 17:42:07 +0800
Message-Id: <1359106929-3034-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On linux, the pages used by kernel could not be migrated. As a result,
if a memory range is used by kernel, it cannot be hot-removed. So if
we want to hot-remove memory, we should prevent kernel from using it.

The way now used to prevent this is specify a memory range by
movablemem_map boot option and set it as ZONE_MOVABLE.

But when the system is booting, memblock will allocate memory, and
reserve the memory for kernel. And before we parse SRAT, and know the
node memory ranges, memblock is working. And it may allocate memory
in ranges to be set as ZONE_MOVABLE. This memory can be used by kernel,
and never be freed.

So, let's parse SRAT before memblock is called first. And it is early enough.

The first call of memblock_find_in_range_node() is in:
setup_arch()
 |-->setup_real_mode()

so, this patch add a function early_parse_srat() to parse SRAT, and call
it before setup_real_mode() is called.

NOTE:
1) Do not clear numa_nodes_parsed in numa_init() because SRAT was parsed earlier.
2) I don't know why using count of memory affinities parsed from SRAT as a return
   value in original acpi_numa_init(). So I add a static variable srat_mem_cnt to
   remember this count and use it as the return value of the new acpi_numa_init()

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/kernel/setup.c |   13 +++++++++----
 arch/x86/mm/numa.c      |    2 +-
 drivers/acpi/numa.c     |   23 +++++++++++++----------
 include/linux/acpi.h    |    1 +
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 23ddd55..3787f14 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -903,6 +903,15 @@ void __init setup_arch(char **cmdline_p)
 	setup_bios_corruption_check();
 #endif
 
+	/*
+	 * In the memory hotplug case, the kernel need info from SRAT to
+	 * determine which memory is hotpluggable before allocating memory
+	 * using memblock.
+	 */
+	acpi_boot_table_init();
+	early_acpi_boot_init();
+	early_parse_srat();
+
 	printk(KERN_DEBUG "initial memory mapped: [mem 0x00000000-%#010lx]\n",
 			(max_pfn_mapped<<PAGE_SHIFT) - 1);
 
@@ -965,10 +974,6 @@ void __init setup_arch(char **cmdline_p)
 	/*
 	 * Parse the ACPI tables for possible boot-time SMP configuration.
 	 */
-	acpi_boot_table_init();
-
-	early_acpi_boot_init();
-
 	initmem_init();
 	memblock_find_dma_reserve();
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index db939b6..6bdee58 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -570,7 +570,7 @@ static int __init numa_init(int (*init_func)(void))
 	for (i = 0; i < MAX_LOCAL_APIC; i++)
 		set_apicid_to_node(i, NUMA_NO_NODE);
 
-	nodes_clear(numa_nodes_parsed);
+	/* Do not clear numa_nodes_parsed because SRAT was parsed earlier. */
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index cb31298..2d255b1 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -280,10 +280,10 @@ acpi_table_parse_srat(enum acpi_srat_type id,
 					    handler, max_entries);
 }
 
-int __init acpi_numa_init(void)
-{
-	int cnt = 0;
+static int srat_mem_cnt;
 
+void __init early_parse_srat(void)
+{
 	/*
 	 * Should not limit number with cpu num that is from NR_CPUS or nr_cpus=
 	 * SRAT cpu entries could have different order with that in MADT.
@@ -293,21 +293,24 @@ int __init acpi_numa_init(void)
 	/* SRAT: Static Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_X2APIC_CPU_AFFINITY,
-				     acpi_parse_x2apic_affinity, 0);
+				      acpi_parse_x2apic_affinity, 0);
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_CPU_AFFINITY,
-				     acpi_parse_processor_affinity, 0);
-		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
-					    acpi_parse_memory_affinity,
-					    NR_NODE_MEMBLKS);
+				      acpi_parse_processor_affinity, 0);
+		srat_mem_cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
+						     acpi_parse_memory_affinity,
+						     NR_NODE_MEMBLKS);
 	}
+}
 
+int __init acpi_numa_init(void)
+{
 	/* SLIT: System Locality Information Table */
 	acpi_table_parse(ACPI_SIG_SLIT, acpi_parse_slit);
 
 	acpi_numa_arch_fixup();
 
-	if (cnt < 0)
-		return cnt;
+	if (srat_mem_cnt < 0)
+		return srat_mem_cnt;
 	else if (!parsed_numa_memblks)
 		return -ENOENT;
 	return 0;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 3994d77..9a8b9c6 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -93,6 +93,7 @@ int acpi_boot_init (void);
 void acpi_boot_table_init (void);
 int acpi_mps_check (void);
 int acpi_numa_init (void);
+void __init early_parse_srat(void);
 
 int acpi_table_init (void);
 int acpi_table_parse (char *id, acpi_table_handler handler);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
