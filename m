Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 00ABE6B0035
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 02:06:30 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5178118pbb.27
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 23:06:30 -0700 (PDT)
Message-ID: <5258E69C.3060304@cn.fujitsu.com>
Date: Sat, 12 Oct 2013 14:05:16 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH part2 v2 3/8] memblock, mem_hotplug: Introduce MEMBLOCK_HOTPLUG
 flag to mark hotpluggable regions
References: <5258E560.5050506@cn.fujitsu.com>
In-Reply-To: <5258E560.5050506@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

In find_hotpluggable_memory, once we find out a memory region which is
hotpluggable, we want to mark them in memblock.memory. So that we could
control memblock allocator not to allocte hotpluggable memory for the kernel
later.

To achieve this goal, we introduce MEMBLOCK_HOTPLUG flag to indicate the
hotpluggable memory regions in memblock and a function memblock_mark_hotplug()
to mark hotpluggable memory if we find one.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |   17 +++++++++++++++
 mm/memblock.c            |   52 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 9a805ec..b788faa 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -19,6 +19,9 @@
 
 #define INIT_MEMBLOCK_REGIONS	128
 
+/* Definition of memblock flags. */
+#define MEMBLOCK_HOTPLUG	0x1	/* hotpluggable region */
+
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
@@ -60,6 +63,8 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
+int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
+int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
@@ -122,6 +127,18 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 	     i != (u64)ULLONG_MAX;					\
 	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
 
+static inline void memblock_set_region_flags(struct memblock_region *r,
+					     unsigned long flags)
+{
+	r->flags |= flags;
+}
+
+static inline void memblock_clear_region_flags(struct memblock_region *r,
+					       unsigned long flags)
+{
+	r->flags &= ~flags;
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_set_node(phys_addr_t base, phys_addr_t size, int nid);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 877973e..5bea331 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -683,6 +683,58 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * memblock_mark_hotplug - Mark hotpluggable memory with flag MEMBLOCK_HOTPLUG.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * This function isolates region [@base, @base + @size), and mark it with flag
+ * MEMBLOCK_HOTPLUG.
+ *
+ * Return 0 on succees, -errno on failure.
+ */
+int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
+{
+	struct memblock_type *type = &memblock.memory;
+	int i, ret, start_rgn, end_rgn;
+
+	ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
+	if (ret)
+		return ret;
+
+	for (i = start_rgn; i < end_rgn; i++)
+		memblock_set_region_flags(&type->regions[i], MEMBLOCK_HOTPLUG);
+
+	memblock_merge_regions(type);
+	return 0;
+}
+
+/**
+ * memblock_clear_hotplug - Clear flag MEMBLOCK_HOTPLUG for a specified region.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * This function isolates region [@base, @base + @size), and clear flag
+ * MEMBLOCK_HOTPLUG for the isolated regions.
+ *
+ * Return 0 on succees, -errno on failure.
+ */
+int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
+{
+	struct memblock_type *type = &memblock.memory;
+	int i, ret, start_rgn, end_rgn;
+
+	ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
+	if (ret)
+		return ret;
+
+	for (i = start_rgn; i < end_rgn; i++)
+		memblock_clear_region_flags(&type->regions[i], MEMBLOCK_HOTPLUG);
+
+	memblock_merge_regions(type);
+	return 0;
+}
+
+/**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %MAX_NUMNODES for all nodes
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
