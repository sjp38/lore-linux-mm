Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 617646B00B5
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:53:53 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 25/25] x86, numa, acpi, memory-hotplug: Make movablenode have higher priority.
Date: Wed, 7 Aug 2013 18:52:16 +0800
Message-Id: <1375872736-4822-26-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Arrange hotpluggable memory as ZONE_MOVABLE will cause NUMA performance down
because the kernel cannot use movable memory. For users who don't use memory
hotplug and who don't want to lose their NUMA performance, they need a way to
disable this functionality. So we improved movablecore boot option.

If users specify the original movablecore=nn@ss boot option, the kernel will
arrange [ss, ss+nn) as ZONE_MOVABLE. The kernelcore=nn@ss boot option is similar
except it specifies ZONE_NORMAL ranges.

Now, if users specify "movablenode" in kernel commandline, the kernel will
arrange hotpluggable memory in SRAT as ZONE_MOVABLE. And if users do this, all
the other movablecore=nn@ss and kernelcore=nn@ss options should be ignored.

For those who don't want this, just specify nothing. The kernel will act as
before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |    5 +++++
 mm/page_alloc.c          |   31 ++++++++++++++++++++++++++++---
 3 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c0bd31c..e78e32f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -64,6 +64,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
+bool memblock_is_hotpluggable(struct memblock_region *region);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index 3ea4301..c8eb5d2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -610,6 +610,11 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
 	return 0;
 }
 
+bool __init_memblock memblock_is_hotpluggable(struct memblock_region *region)
+{
+	return region->flags & MEMBLOCK_HOTPLUG;
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..86d4381 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4948,9 +4948,35 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
+	struct memblock_type *type = &memblock.memory;
 
+	/* Need to find movable_zone earlier when movablenode is specified. */
+	find_usable_zone_for_movable();
+
+#ifdef CONFIG_MOVABLE_NODE
 	/*
-	 * If movablecore was specified, calculate what size of
+	 * If movablenode is specified, ignore kernelcore and movablecore
+	 * options.
+	 */
+	if (movablenode_enable_srat) {
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
+		goto out;
+	}
+#endif
+
+	/*
+	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
 	 * and movablecore are specified, then the value of kernelcore
@@ -4976,7 +5002,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
 restart:
@@ -5067,12 +5092,12 @@ restart:
 	if (usable_nodes && required_kernelcore > usable_nodes)
 		goto restart;
 
+out:
 	/* Align start of ZONE_MOVABLE on all nids to MAX_ORDER_NR_PAGES */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
 		zone_movable_pfn[nid] =
 			roundup(zone_movable_pfn[nid], MAX_ORDER_NR_PAGES);
 
-out:
 	/* restore the node_state */
 	node_states[N_MEMORY] = saved_node_state;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
