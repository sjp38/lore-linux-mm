Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id B64D26B0073
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:32:59 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so20291992pbc.19
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:32:59 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id tt8si10662700pbc.198.2013.12.02.18.32.56
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:32:58 -0800 (PST)
Message-ID: <529D420D.7060503@cn.fujitsu.com>
Date: Tue, 03 Dec 2013 10:29:33 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH RESEND part2 v2 7/8] memblock, mem_hotplug: Make memblock
 skip hotpluggable regions if needed
References: <529D3FC0.6000403@cn.fujitsu.com>
In-Reply-To: <529D3FC0.6000403@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

Linux kernel cannot migrate pages used by the kernel. As a result, hotpluggable
memory used by the kernel won't be able to be hot-removed. To solve this
problem, the basic idea is to prevent memblock from allocating hotpluggable
memory for the kernel at early time, and arrange all hotpluggable memory in
ACPI SRAT(System Resource Affinity Table) as ZONE_MOVABLE when initializing
zones.

In the previous patches, we have marked hotpluggable memory regions with
MEMBLOCK_HOTPLUG flag in memblock.memory.

In this patch, we make memblock skip these hotpluggable memory regions in
the default top-down allocation function if movable_node boot option is
specified.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |   18 ++++++++++++++++++
 mm/memblock.c            |   12 ++++++++++++
 mm/memory_hotplug.c      |    1 +
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 97480d3..bfc1dba 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -47,6 +47,10 @@ struct memblock {
 
 extern struct memblock memblock;
 extern int memblock_debug;
+#ifdef CONFIG_MOVABLE_NODE
+/* If movable_node boot option specified */
+extern bool movable_node_enabled;
+#endif /* CONFIG_MOVABLE_NODE */
 
 #define memblock_dbg(fmt, ...) \
 	if (memblock_debug) printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
@@ -65,6 +69,20 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
+#ifdef CONFIG_MOVABLE_NODE
+static inline bool memblock_is_hotpluggable(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_HOTPLUG;
+}
+
+static inline bool movable_node_is_enabled(void)
+{
+	return movable_node_enabled;
+}
+#else
+static inline bool memblock_is_hotpluggable(struct memblock_region *m){ return false; }
+static inline bool movable_node_is_enabled(void) { return false; }
+#endif
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index 7de9c76..7f69012 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -39,6 +39,9 @@ struct memblock memblock __initdata_memblock = {
 };
 
 int memblock_debug __initdata_memblock;
+#ifdef CONFIG_MOVABLE_NODE
+bool movable_node_enabled __initdata_memblock = false;
+#endif
 static int memblock_can_resize __initdata_memblock;
 static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;
@@ -819,6 +822,11 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
  * Reverse of __next_free_mem_range().
+ *
+ * Linux kernel cannot migrate pages used by itself. Memory hotplug users won't
+ * be able to hot-remove hotpluggable memory used by the kernel. So this
+ * function skip hotpluggable regions if needed when allocating memory for the
+ * kernel.
  */
 void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 					   phys_addr_t *out_start,
@@ -843,6 +851,10 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
 			continue;
 
+		/* skip hotpluggable memory regions if needed */
+		if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
+			continue;
+
 		/* scan areas before each reservation for intersection */
 		for ( ; ri >= 0; ri--) {
 			struct memblock_region *r = &rsv->regions[ri];
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8c91d0a..729a2d8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1436,6 +1436,7 @@ static int __init cmdline_parse_movable_node(char *p)
 	 * the kernel away from hotpluggable memory.
 	 */
 	memblock_set_bottom_up(true);
+	movable_node_enabled = true;
 #else
 	pr_warn("movable_node option not supported\n");
 #endif
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
