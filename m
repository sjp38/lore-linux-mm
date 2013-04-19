Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 5B8AA6B00A5
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 05:29:26 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v1 07/12] x86, numa, mem-hotplug: Mark nodes which the kernel resides in.
Date: Fri, 19 Apr 2013 17:31:44 +0800
Message-Id: <1366363909-12771-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1366363909-12771-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1366363909-12771-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, dhowells@redhat.com, davej@redhat.com, agordeev@redhat.com, suresh.b.siddha@intel.com, mst@redhat.com, yinghai@kernel.org, penberg@kernel.org, jacob.shin@amd.com, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, rientjes@google.com, tj@kernel.org, laijs@cn.fujitsu.com, hannes@cmpxchg.org, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If all the memory ranges in SRAT are hotpluggable, we should not
arrange them all in ZONE_MOVABLE. Otherwise the kernel won't have
enough memory to boot.

This patch introduce a global variable kernel_nodemask to mark
all the nodes the kernel resides in. And no matter if they are
hotpluggable, we arrange them as un-hotpluggable.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c       |    6 ++++++
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   20 ++++++++++++++++++++
 3 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 26d1800..105b092 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -658,6 +658,12 @@ static bool srat_used __initdata;
  */
 static void __init early_x86_numa_init(void)
 {
+	/*
+	 * Need to find out which nodes the kernel resides in, and arrange
+	 * them as un-hotpluggable when parsing SRAT.
+	 */
+	memblock_mark_kernel_nodes();
+
 	if (!numa_off) {
 #ifdef CONFIG_X86_NUMAQ
 		if (!numa_init(numaq_numa_init))
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c63a66e..5064eed 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -66,6 +66,7 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
+void memblock_mark_kernel_nodes(void);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index 63924ae..1b93a5d 100644
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
@@ -787,6 +790,23 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
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
