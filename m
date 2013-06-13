Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 08C8B900003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:02 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 09/15] x86, numa, mem-hotplug: Mark nodes which the kernel resides in.
Date: Thu, 13 Jun 2013 21:03:33 +0800
Message-Id: <1371128619-8987-10-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If all the memory ranges in SRAT are hotpluggable, we should not
arrange them all in ZONE_MOVABLE. Otherwise the kernel won't have
enough memory to boot.

This patch introduce a global variable kernel_nodemask to mark
all the nodes the kernel resides in. And no matter if they are
hotpluggable, we arrange them as un-hotpluggable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c       |   10 ++++++++++
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   20 ++++++++++++++++++++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 005a422..1242190 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -775,6 +775,16 @@ void __init early_initmem_init(void)
 {
 	early_x86_numa_init();
 
+	/*
+	 * Need to find out which nodes the kernel resides in, and arrange
+	 * them as un-hotpluggable when parsing SRAT.
+	 *
+	 * This should be done after numa_init() is called because we
+	 * synchronized the nid info in memblock.reserve[] to numa_meminfo
+	 * in numa_init().
+	 */
+	memblock_mark_kernel_nodes();
+
 	early_x86_numa_init_mapping();
 
 	load_cr3(swapper_pg_dir);
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f558590..5a52f37 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -63,6 +63,7 @@ int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_node(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
+void memblock_mark_kernel_nodes(void);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index cc55ff0..bb53c54 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -35,6 +35,9 @@ struct memblock memblock __initdata_memblock = {
 	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
 };
 
+/* Mark which nodes the kernel resides in. */
+static nodemask_t memblock_kernel_nodemask __initdata_memblock;
+
 int memblock_debug __initdata_memblock;
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
@@ -795,6 +798,23 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 	memblock_merge_regions(type);
 	return 0;
 }
+
+void __init_memblock memblock_mark_kernel_nodes()
+{
+	int i, nid;
+	struct memblock_type *reserved = &memblock.reserved;
+
+	for (i = 0; i < reserved->cnt; i++)
+		if (reserved->regions[i].flags == MEMBLK_FLAGS_DEFAULT) {
+			nid = memblock_get_region_node(&reserved->regions[i]);
+			node_set(nid, memblock_kernel_nodemask);
+		}
+}
+#else
+void __init_memblock memblock_mark_kernel_nodes()
+{
+	node_set(0, memblock_kernel_nodemask);
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
