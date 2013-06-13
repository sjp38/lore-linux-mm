Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6143890000B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 14/15] x86, numa, acpi, memory-hotplug: Make movablecore=acpi have higher priority.
Date: Thu, 13 Jun 2013 21:03:38 +0800
Message-Id: <1371128619-8987-15-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Arrange hotpluggable memory as ZONE_MOVABLE will cause NUMA performance decreased
because the kernel cannot use movable memory.

For users who don't use memory hotplug and who don't want to lose their NUMA
performance, they need a way to disable this functionality.

So, if users specify "movablecore=acpi" in kernel commandline, the kernel will
use SRAT to arrange ZONE_MOVABLE, and it has higher priority then original
movablecore and kernelcore boot option.

For those who don't want this, just specify nothing.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |    5 +++++
 mm/page_alloc.c          |   31 +++++++++++++++++++++++++++++--
 3 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index d113175..a85ced9 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -66,6 +66,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
+bool memblock_is_hotpluggable(struct memblock_region *region);
 void memblock_free_hotpluggable(void);
 void memblock_trim_memory(phys_addr_t align);
 void memblock_mark_kernel_nodes(void);
diff --git a/mm/memblock.c b/mm/memblock.c
index 9df0b5f..0c4a709 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -626,6 +626,11 @@ int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
 	return memblock_reserve_region(base, size, nid, MEMBLK_HOTPLUGGABLE);
 }
 
+bool __init_memblock memblock_is_hotpluggable(struct memblock_region *region)
+{
+	return region->flags & MEMBLK_HOTPLUGGABLE;
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee5ae49..10c85b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4830,9 +4830,37 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
+	struct memblock_type *reserved = &memblock.reserved;
 
 	/*
-	 * If movablecore was specified, calculate what size of
+	 * Need to find movable_zone earlier in case movablecore=acpi is
+	 * specified.
+	 */
+	find_usable_zone_for_movable();
+
+	/*
+	 * If movablecore=acpi was specified, then zone_movable_pfn[] has been
+	 * initialized, and no more work needs to do.
+	 * NOTE: In this case, we ignore kernelcore option.
+	 */
+	if (movablecore_enable_srat) {
+		for (i = 0; i < reserved->cnt; i++) {
+			if (!memblock_is_hotpluggable(&reserved->regions[i]))
+				continue;
+
+			nid = reserved->regions[i].nid;
+
+			usable_startpfn = PFN_DOWN(reserved->regions[i].base);
+			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
+				min(usable_startpfn, zone_movable_pfn[nid]) :
+				usable_startpfn;
+		}
+
+		goto out;
+	}
+
+	/*
+	 * If movablecore=nn[KMG] was specified, calculate what size of
 	 * kernelcore that corresponds so that memory usable for
 	 * any allocation type is evenly spread. If both kernelcore
 	 * and movablecore are specified, then the value of kernelcore
@@ -4858,7 +4886,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
 restart:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
