Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 8CD636B003C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:23 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 03/11] numa, acpi, memory-hotplug: Add movablemem_map=acpi boot option.
Date: Fri, 5 Apr 2013 17:39:53 +0800
Message-Id: <1365154801-473-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since the kernel pages cannot be migrated, if we want a memory device
hotpluggable, we have to set all the memory on it as ZONE_MOVABLE.

This patch adds a boot option movablemem_map=acpi to inform the kernel
to use Hot Pluggable bit in SRAT to determine which memory device is
hotpluggable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   11 +++++++++++
 include/linux/mm.h                  |   12 ++++++++++++
 mm/page_alloc.c                     |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 4609e81..e039888 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1649,6 +1649,17 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
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
+			NOTE: Whatever node the kernel resides in will always
+			      be un-hotpluggable.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1c79b10..52c3558 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1332,6 +1332,18 @@ extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
 
+#define MOVABLEMEM_MAP_MAX MAX_NUMNODES
+struct movablemem_entry {
+	unsigned long start_pfn;    /* start pfn of memory segment */
+	unsigned long end_pfn;      /* end pfn of memory segment (exclusive) */
+};
+
+struct movablemem_map {
+	bool acpi;
+	int nr_map;
+	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
+};
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f368db4..475fd8b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -202,6 +202,12 @@ static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+/* Movable memory ranges, will also be used by memblock subsystem. */
+struct movablemem_map movablemem_map = {
+	.acpi = false,
+	.nr_map = 0,
+};
+
 static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
@@ -5061,6 +5067,35 @@ static int __init cmdline_parse_movablecore(char *p)
 early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
+/**
+ * cmdline_parse_movablemem_map - Parse boot option movablemem_map.
+ * @p:	The boot option of the following format:
+ *	movablemem_map=acpi
+ *
+ * This option inform the kernel to use Hot Pluggable bit in SRAT to determine
+ * which memory device is hotpluggable, and set the memory on it as movable.
+ *
+ * Return: 0 on success or -EINVAL on failure.
+ */
+static int __init cmdline_parse_movablemem_map(char *p)
+{
+	if (!p || strcmp(p, "acpi"))
+		goto err;
+
+	movablemem_map.acpi = true;
+
+	if (movablemem_map.nr_map) {
+		memset(movablemem_map.map, 0,
+		       sizeof(struct movablemem_entry) * movablemem_map.nr_map);
+	}
+
+	return 0;
+
+err:
+	return -EINVAL;
+}
+early_param("movablemem_map", cmdline_parse_movablemem_map);
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
