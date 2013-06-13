Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7EFF6900021
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:21 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 12/15] x86, acpi, numa, mem-hotplug: Introduce MEMBLK_HOTPLUGGABLE to mark and reserve hotpluggable memory.
Date: Thu, 13 Jun 2013 21:03:36 +0800
Message-Id: <1371128619-8987-13-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We mark out movable memory ranges and reserve them with MEMBLK_HOTPLUGGABLE flag in
memblock.reserved. This should be done after the memory mapping is initialized
because the kernel now supports allocate pagetable pages on local node, which
are kernel pages.

The reserved hotpluggable will be freed to buddy when memory initialization
is done.

And also, ensure all the nodes which the kernel resides in are un-hotpluggable.

This idea is from Wen Congyang <wency@cn.fujitsu.com> and Jiang Liu <jiang.liu@huawei.com>.

Suggested-by: Jiang Liu <jiang.liu@huawei.com>
Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 arch/x86/mm/numa.c       |   29 +++++++++++++++++++++++++++++
 include/linux/memblock.h |    3 +++
 mm/memblock.c            |   18 ++++++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 2b5057f..31595c5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -771,6 +771,33 @@ static void __init early_x86_numa_init_mapping(void)
 }
 #endif
 
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+static void __init early_mem_hotplug_init()
+{
+	int i, nid;
+	phys_addr_t start, end;
+
+	if (!movablecore_enable_srat)
+		return;
+
+	for (i = 0; i < numa_meminfo.nr_blks; i++) {
+		nid = numa_meminfo.blk[i].nid;
+		start = numa_meminfo.blk[i].start;
+		end = numa_meminfo.blk[i].end;
+
+		if (!numa_meminfo.blk[i].hotpluggable ||
+		    memblock_is_kernel_node(nid))
+			continue;
+
+		memblock_reserve_hotpluggable(start, end - start, nid);
+	}
+}
+#else		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+static inline void early_mem_hotplug_init()
+{
+}
+#endif		/* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+
 void __init early_initmem_init(void)
 {
 	early_x86_numa_init();
@@ -790,6 +817,8 @@ void __init early_initmem_init(void)
 	load_cr3(swapper_pg_dir);
 	__flush_tlb_all();
 
+	early_mem_hotplug_init();
+
 	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
 }
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 517c027..ce315b2 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -22,6 +22,7 @@
 /* Definition of memblock flags. */
 #define MEMBLK_FLAGS_DEFAULT	0x0	/* default flag */
 #define	MEMBLK_LOCAL_NODE	0x1	/* node-life-cycle data */
+#define	MEMBLK_HOTPLUGGABLE	0x2	/* hotpluggable region */
 
 struct memblock_region {
 	phys_addr_t base;
@@ -64,8 +65,10 @@ int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
+int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
 void memblock_mark_kernel_nodes(void);
+bool memblock_is_kernel_node(int nid);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index e747bc6..51f0264 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -603,6 +603,12 @@ int __init_memblock memblock_reserve_local_node(phys_addr_t base,
 	return memblock_reserve_region(base, size, nid, MEMBLK_LOCAL_NODE);
 }
 
+int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
+					phys_addr_t size, int nid)
+{
+	return memblock_reserve_region(base, size, nid, MEMBLK_HOTPLUGGABLE);
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
@@ -816,11 +822,23 @@ void __init_memblock memblock_mark_kernel_nodes()
 			node_set(nid, memblock_kernel_nodemask);
 		}
 }
+
+bool __init_memblock memblock_is_kernel_node(int nid)
+{
+	if (node_isset(nid, memblock_kernel_nodemask))
+		return true;
+	return false;
+}
 #else
 void __init_memblock memblock_mark_kernel_nodes()
 {
 	node_set(0, memblock_kernel_nodemask);
 }
+
+bool __init_memblock memblock_is_kernel_node(int nid)
+{
+	return true;
+}
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
