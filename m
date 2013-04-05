Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 18A026B0070
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:26 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 08/11] x86, numa, acpi, memory-hotplug: Introduce zone_movable_limit[] to store start pfn of ZONE_MOVABLE.
Date: Fri, 5 Apr 2013 17:39:58 +0800
Message-Id: <1365154801-473-9-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since node info in SRAT may not be in increasing order, we may meet
a lower range after we handled a higher range. So we need to keep
the lowest movable pfn each time we parse a SRAT memory entry, and
update it when we get a lower one.

This patch introduces a new array zone_movable_limit[], which is used
to store the start pfn of each node's ZONE_MOVABLE.

We update it each time we parsed a SRAT memory entry if necessary.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   16 ++++++++++++++--
 include/linux/mm.h |    2 ++
 mm/page_alloc.c    |    1 +
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index dcaf248..8cbe8a0 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -727,7 +727,8 @@ static void __init early_x86_numa_init_mapping(void)
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /**
- * early_mem_hotplug_init - Add hotpluggable memory ranges to movablemem_map.
+ * early_mem_hotplug_init - Add hotpluggable memory ranges to movablemem_mapi,
+ *                          and initialize zone_movable_limit.
  *
  * This function scan numa_meminfo.blk[], and add all the hotpluggable memory 
  * ranges to movablemem_map. movablemem_map can be used to prevent memblock
@@ -750,6 +751,10 @@ static void __init early_x86_numa_init_mapping(void)
  * hotpluggable:           y       y         y           n
  * kernel resides in:      y       n         n           n
  * movablemem_map:              |_____| |_________|
+ *
+ * This function will also initialize zone_movable_limit[].
+ * ZONE_MOVABLE of node i should start at least from zone_movable_limit[i].
+ * zone_movable_limit[i] == 0 means there is no limitation for node i.
  */
 static void __init early_mem_hotplug_init()
 {
@@ -759,7 +764,7 @@ static void __init early_mem_hotplug_init()
 		return;
 
 	for (i = 0; i < numa_meminfo.nr_blks; i++) {
-		nid = numa_meminfo_all.blk[i].nid;
+		nid = numa_meminfo.blk[i].nid;
 
 		if (node_isset(nid, movablemem_map.numa_nodes_kernel) ||
 		    !numa_meminfo.blk[i].hotpluggable)
@@ -767,6 +772,13 @@ static void __init early_mem_hotplug_init()
 
 		movablemem_map_add_region(numa_meminfo.blk[i].start,
 					  numa_meminfo.blk[i].end);
+
+		if (zone_movable_limit[nid])
+			zone_movable_limit[nid] = min(zone_movable_limit[nid],
+					PFN_DOWN(numa_meminfo.blk[i].start));
+		else
+			zone_movable_limit[nid] = 
+					PFN_DOWN(numa_meminfo.blk[i].start);
 	}
 }
 #else          /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2835c91..b313d83 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1349,6 +1349,8 @@ extern struct movablemem_map movablemem_map;
 
 extern void __init movablemem_map_add_region(u64 start, u64 size);
 
+extern unsigned long __meminitdata zone_movable_limit[MAX_NUMNODES];
+
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2a7904f..b97bdb5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -213,6 +213,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 static unsigned long __initdata required_kernelcore;
 static unsigned long __initdata required_movablecore;
 static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
+unsigned long __meminitdata zone_movable_limit[MAX_NUMNODES];
 
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
 int movable_zone;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
