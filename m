Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id D132B6B000C
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 04:43:03 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 3/3] acpi, memory-hotplug: Support getting hotplug info from SRAT.
Date: Fri, 25 Jan 2013 17:42:09 +0800
Message-Id: <1359106929-3034-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1359106929-3034-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

We now provide an option for users who don't want to specify physical
memory address in kernel commandline.

        /*
         * For movablemem_map=acpi:
         *
         * SRAT:                |_____| |_____| |_________| |_________| ......
         * node id:                0       1         1           2
         * hotpluggable:           n       y         y           n
         * movablemem_map:              |_____| |_________|
         *
         * Using movablemem_map, we can prevent memblock from allocating memory
         * on ZONE_MOVABLE at boot time.
         */

So user just specify movablemem_map=acpi, and the kernel will use hotpluggable
info in SRAT to determine which memory ranges should be set as ZONE_MOVABLE.

NOTE: Using this way will cause NUMA performance down because the whole node
      will be set as ZONE_MOVABLE, and kernel cannot use memory on it.
      If users don't want to lose NUMA performance, just don't use it.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   23 ++++++++++++++++++-----
 arch/x86/mm/srat.c                  |   22 +++++++++++++++++++++-
 include/linux/mm.h                  |    1 +
 mm/page_alloc.c                     |   22 +++++++++++++++++++++-
 4 files changed, 61 insertions(+), 7 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 7770611..3d9dc9d 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1637,15 +1637,28 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablemem_map=acpi
+			[KNL,X86,IA-64,PPC] This parameter is similar to
+			memmap except it specifies the memory map of
+			ZONE_MOVABLE.
+			This option inform the kernel to use Hot Pluggable bit
+			in flags from SRAT from ACPI BIOS to determine which
+			memory devices could be hotplugged. The corresponding
+			memory ranges will be set as ZONE_MOVABLE.
+
 	movablemem_map=nn[KMG]@ss[KMG]
 			[KNL,X86,IA-64,PPC] This parameter is similar to
 			memmap except it specifies the memory map of
 			ZONE_MOVABLE.
-			If more areas are all within one node, then from
-			lowest ss to the end of the node will be ZONE_MOVABLE.
-			If an area covers two or more nodes, the area from
-			ss to the end of the 1st node will be ZONE_MOVABLE,
-			and all the rest nodes will only have ZONE_MOVABLE.
+			If user specifies memory ranges, the info in SRAT will
+			be ingored. And it works like the following:
+			- If more ranges are all within one node, then from
+			  lowest ss to the end of the node will be ZONE_MOVABLE.
+			- If a range is within a node, then from ss to the end
+			  of the node will be ZONE_MOVABLE.
+			- If a range covers two or more nodes, then from ss to
+			  the end of the 1st node will be ZONE_MOVABLE, and all
+			  the rest nodes will only have ZONE_MOVABLE.
 			If memmap is specified at the same time, the
 			movablemem_map will be limited within the memmap
 			areas. If kernelcore or movablecore is also specified,
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index f841d0e..94d6e72 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -198,7 +198,23 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	end_pfn = PFN_UP(end);
 
 	/*
-	 * For movablecore_map=nn[KMG]@ss[KMG]:
+	 * For movablemem_map=acpi:
+	 *
+	 * SRAT:		|_____| |_____| |_________| |_________| ......
+	 * node id:                0       1         1           2
+	 * hotpluggable:	   n       y         y           n
+	 * movablemem_map:	        |_____| |_________|
+	 *
+	 * Using movablemem_map, we can prevent memblock from allocating memory
+	 * on ZONE_MOVABLE at boot time.
+	 */
+	if (hotpluggable && movablemem_map.acpi) {
+		insert_movablemem_map(start_pfn, end_pfn);
+		goto out;
+	}
+
+	/*
+	 * For movablemem_map=nn[KMG]@ss[KMG]:
 	 *
 	 * SRAT:		|_____| |_____| |_________| |_________| ......
 	 * node id:		   0       1         1           2
@@ -207,6 +223,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	 *
 	 * Using movablemem_map, we can prevent memblock from allocating memory
 	 * on ZONE_MOVABLE at boot time.
+	 *
+	 * NOTE: In this case, SRAT info will be ingored.
 	 */
 	overlap = movablemem_map_overlap(start_pfn, end_pfn);
 	if (overlap >= 0) {
@@ -234,6 +252,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 			 */
 			insert_movablemem_map(start_pfn, end_pfn);
 	}
+
+out:
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 	return 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e88077a..3eda45f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1366,6 +1366,7 @@ struct movablemem_entry {
 };
 
 struct movablemem_map {
+	bool acpi;	/* true if using SRAT info */
 	int nr_map;
 	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
 	nodemask_t numa_nodes_hotplug;	/* on which nodes we specify memory */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bdbce73..843c00d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,7 +202,10 @@ static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /* Movable memory ranges, will also be used by memblock subsystem. */
-struct movablemem_map movablemem_map;
+struct movablemem_map movablemem_map = {
+	.acpi = false,
+	.nr_map = 0,
+};
 
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
@@ -5306,6 +5309,23 @@ static int __init cmdline_parse_movablemem_map(char *p)
 	if (!p)
 		goto err;
 
+	if (!strncmp(p, "acpi", max(4, strlen(p))))
+		movablemem_map.acpi = true;
+
+	/*
+	 * If user decide to use info from BIOS, all the other user specified
+	 * ranges will be ingored.
+	 */
+	if (movablemem_map.acpi) {
+		if (movablemem_map.nr_map) {
+			memset(movablemem_map.map, 0,
+				sizeof(struct movablemem_entry)
+				* movablemem_map.nr_map);
+			movablemem_map.nr_map = 0;
+		}
+		return 0;
+	}
+
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
