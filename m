Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id CDA766B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 05:57:29 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so6828403pbb.20
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 02:57:29 -0700 (PDT)
Message-ID: <524A9C4F.70306@cn.fujitsu.com>
Date: Tue, 01 Oct 2013 17:56:31 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH -mm 8/8] x86, numa, acpi, memory-hotplug: Make movable_node
 have higher priority
References: <524A991D.3050005@cn.fujitsu.com>
In-Reply-To: <524A991D.3050005@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, Rik van Riel <riel@redhat.com>, prarit@redhat.com, Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

Arrange hotpluggable memory as ZONE_MOVABLE will cause NUMA performance down
because the kernel cannot use movable memory. For users who don't use memory
hotplug and who don't want to lose their NUMA performance, they need a way to
disable this functionality. So we improved movable_node boot option.

If users specify the original movablecore=nn@ss boot option, the kernel will
arrange [ss, ss+nn) as ZONE_MOVABLE. The kernelcore=nn@ss boot option is similar
except it specifies ZONE_NORMAL ranges.

Now, if users specify "movable_node" in kernel commandline, the kernel will
arrange hotpluggable memory in SRAT as ZONE_MOVABLE. And if users do this, all
the other movablecore=nn@ss and kernelcore=nn@ss options should be ignored.

For those who don't want this, just specify nothing. The kernel will act as
before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/memblock.h       |    1 +
 include/linux/memory_hotplug.h |    5 +++++
 mm/memblock.c                  |    5 +++++
 mm/memory_hotplug.c            |    3 +++
 mm/page_alloc.c                |   30 ++++++++++++++++++++++++++++--
 5 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index b6f149f..046f22a 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -65,6 +65,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
+bool memblock_is_hotpluggable(struct memblock_region *region);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index dd38e62..b469513 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -33,6 +33,11 @@ enum {
 	ONLINE_MOVABLE,
 };
 
+#ifdef CONFIG_MOVABLE_NODE
+/* Enable/disable SRAT in movable_node boot option */
+extern bool movable_node_enable_srat;
+#endif /* CONFIG_MOVABLE_NODE */
+
 /*
  * pgdat resizing functions
  */
diff --git a/mm/memblock.c b/mm/memblock.c
index 9bdebfb..6241129 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -708,6 +708,11 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
 	return 0;
 }
 
+bool __init_memblock memblock_is_hotpluggable(struct memblock_region *region)
+{
+	return region->flags & MEMBLOCK_HOTPLUG;
+}
+
 /**
  * memblock_clear_hotplug - Clear flag MEMBLOCK_HOTPLUG for a specified region.
  * @base: the base phys addr of the region
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dcd819a..a635d0c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1379,6 +1379,8 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MOVABLE_NODE
+bool __initdata movable_node_enable_srat;
+
 /*
  * When CONFIG_MOVABLE_NODE, we permit offlining of a node which doesn't have
  * normal memory.
@@ -1436,6 +1438,7 @@ static int __init cmdline_parse_movablenode(char *p)
 	 * the kernel away from hotpluggable memory.
 	 */
 	memblock_set_bottom_up(true);
+	movable_node_enable_srat = true;
 #else
 	pr_warn("movablenode option not supported");
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0ee638f..612f0c8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5021,9 +5021,35 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
+	struct memblock_type *type = &memblock.memory;
+
+	/* Need to find movable_zone earlier when movable_node is specified. */
+	find_usable_zone_for_movable();
+
+#ifdef CONFIG_MOVABLE_NODE
+	/*
+	 * If movable_node is specified, ignore kernelcore and movablecore
+	 * options.
+	 */
+	if (movable_node_enable_srat) {
+		for (i = 0; i < type->cnt; i++) {
+			if (!memblock_is_hotpluggable(&type->regions[i]))
+				continue;
+
+			nid = type->regions[i].nid;
+
+			usable_startpfn = PFN_DOWN(type->regions[i].base);
+			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
+				min(usable_startpfn, zone_movable_pfn[nid]) :
+				usable_startpfn;
+		}
+
+		goto out2;
+	}
+#endif
 
 	/*
-	 * If movablecore was specified, calculate what size of
+	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
 	 * and movablecore are specified, then the value of kernelcore
@@ -5049,7 +5075,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
 restart:
@@ -5140,6 +5165,7 @@ restart:
 	if (usable_nodes && required_kernelcore > usable_nodes)
 		goto restart;
 
+out2:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
 		zone_movable_pfn[nid] =
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
