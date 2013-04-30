Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id EC6D96B00C8
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 05:18:43 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 10/13] x86, acpi, numa, mem-hotplug: Introduce MEMBLK_HOTPLUGGABLE to mark and reserve hotpluggable memory.
Date: Tue, 30 Apr 2013 17:21:20 +0800
Message-Id: <1367313683-10267-11-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We mark out movable memory ranges and reserve them with MEMBLK_HOTPLUGGABLE flag in
memblock.reserved. This should be done after the memory mapping is initialized
because the kernel now supports allocate pagetable pages on local node, which
are kernel pages.

The reserved hotpluggable will be freed to buddy when memory initialization
is done.

This idea is from Wen Congyang <wency@cn.fujitsu.com> and Jiang Liu <jiang.liu@huawei.com>.

Suggested-by: Jiang Liu <jiang.liu@huawei.com>
Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c       |   28 ++++++++++++++++++++++++++++
 include/linux/memblock.h |    3 +++
 mm/memblock.c            |   19 +++++++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1367fe4..a1f1f90 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -731,6 +731,32 @@ static void __init early_x86_numa_init_mapping(void)
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
+		if (!numa_meminfo.blk[i].hotpluggable)
+			continue;
+
+		nid = numa_meminfo.blk[i].nid;
+		start = numa_meminfo.blk[i].start;
+		end = numa_meminfo.blk[i].end;
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
@@ -740,6 +766,8 @@ void __init early_initmem_init(void)
 	load_cr3(swapper_pg_dir);
 	__flush_tlb_all();
 
+	early_mem_hotplug_init();
+
 	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
 }
 
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 3b2d1c4..0f01930 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -24,6 +24,7 @@
 /* Definition of memblock flags. */
 enum memblock_flags {
 	MEMBLK_LOCAL_NODE,	/* node-life-cycle data */
+	MEMBLK_HOTPLUGGABLE,	/* hotpluggable region */
 	__NR_MEMBLK_FLAGS,	/* number of flags */
 };
 
@@ -67,8 +68,10 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
+int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
 void memblock_mark_kernel_nodes(void);
+bool memblock_is_kernel_node(int nid);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index edde4c2..0c55588 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -596,6 +596,13 @@ int __init_memblock memblock_reserve_local_node(phys_addr_t base,
 	return memblock_reserve_region(base, size, nid, flags);
 }
 
+int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
+					phys_addr_t size, int nid)
+{
+	unsigned long flags = 1 << MEMBLK_HOTPLUGGABLE;
+	return memblock_reserve_region(base, size, nid, flags);
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
@@ -809,11 +816,23 @@ void __init_memblock memblock_mark_kernel_nodes()
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
