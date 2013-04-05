Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 177B36B0073
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:27 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 07/11] x86, numa, acpi, memory-hotplug: Make any node which the kernel resides in un-hotpluggable.
Date: Fri, 5 Apr 2013 17:39:57 +0800
Message-Id: <1365154801-473-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Before parsing SRAT, memblock has already reserved some memory ranges
for other purposes, such as for kernel image. We cannot prevent
kernel from using these memory. Furthermore, if all the memory is
hotpluggable, then the system won't have enough memory to boot if we set
all of them as movable. So we always set the nodes which the kernel
resides in as non-movable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   25 +++++++++++++++++++------
 arch/x86/mm/srat.c |   17 ++++++++++++++++-
 include/linux/mm.h |    1 +
 3 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 73e7934..dcaf248 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -736,24 +736,37 @@ static void __init early_x86_numa_init_mapping(void)
  * we will put pagetable pages in local node even if the memory of that node is
  * hotpluggable.
  *
- * If users specify movablemem_map=acpi, then:
+ * And, when the kernel is booting, memblock has reserved some memory for other
+ * purpose, such as storing kernel image. We cannot prevent the kernel from
+ * using this kind of memory. So whatever node the kernel resides in should be
+ * un-hotpluggable, because if all the memory is hotpluggable, and is set as
+ * movable, the kernel won't have enough memory to boot.
+ *
+ * It works like this:
+ * If users specify movablemem_map=acpi, then
  *
  * SRAT:                |_____| |_____| |_________| |_________| ......
  * node id:                0       1         1           2
- * hotpluggable:           n       y         y           n
+ * hotpluggable:           y       y         y           n
+ * kernel resides in:      y       n         n           n
  * movablemem_map:              |_____| |_________|
  */
 static void __init early_mem_hotplug_init()
 {
-	int i;
+	int i, nid;
 
 	if (!movablemem_map.acpi)
 		return;
 
 	for (i = 0; i < numa_meminfo.nr_blks; i++) {
-		if (numa_meminfo.blk[i].hotpluggable)
-			movablemem_map_add_region(numa_meminfo.blk[i].start,
-						  numa_meminfo.blk[i].end);
+		nid = numa_meminfo_all.blk[i].nid;
+
+		if (node_isset(nid, movablemem_map.numa_nodes_kernel) ||
+		    !numa_meminfo.blk[i].hotpluggable)
+			continue;
+
+		movablemem_map_add_region(numa_meminfo.blk[i].start,
+					  numa_meminfo.blk[i].end);
 	}
 }
 #else          /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index f7f6fd4..0b5904e 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -147,7 +147,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	u64 start, end;
 	u32 hotpluggable;
-	int node, pxm;
+	int node, pxm, i;
+	struct memblock_type *rgn = &memblock.reserved;
 
 	if (srat_disabled())
 		goto out_err;
@@ -176,6 +177,20 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	node_set(node, numa_nodes_parsed);
 
+	/*
+	 * Before parsing SRAT, memblock has reserved some memory for other
+	 * purpose, such as storing kernel image. We cannot prevent the kernel
+	 * from using this kind of memory. So just mark which nodes the kernel
+	 * resides in, and set these nodes un-hotpluggable later.
+	 */
+	for (i = 0; i < rgn->cnt; i++) {
+		if (end <= rgn->regions[i].base ||
+		    start >= rgn->regions[i].base + rgn->regions[i].size)
+			continue;
+
+		node_set(node, movablemem_map.numa_nodes_kernel);
+	}
+
 	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
 	       node, pxm,
 	       (unsigned long long) start, (unsigned long long) end - 1,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7468221..2835c91 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1342,6 +1342,7 @@ struct movablemem_map {
 	bool acpi;
 	int nr_map;
 	struct movablemem_entry map[MOVABLEMEM_MAP_MAX];
+	nodemask_t numa_nodes_kernel;   /* on which nodes kernel resides in */
 };
 
 extern struct movablemem_map movablemem_map;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
