Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BE7936B005A
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 03:08:17 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 16/18] memblock, mem_hotplug: Make memblock skip hotpluggable regions by default.
Date: Thu, 1 Aug 2013 15:06:38 +0800
Message-Id: <1375340800-19332-17-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Linux kernel cannot migrate pages used by the kernel. As a result, hotpluggable
memory used by the kernel won't be able to be hot-removed. To solve this
problem, the basic idea is to prevent memblock from allocating hotpluggable
memory for the kernel at early time, and arrange all hotpluggable memory in
ACPI SRAT(System Resource Affinity Table) as ZONE_MOVABLE when initializing
zones.

In the previous patches, we have marked hotpluggable memory regions with
MEMBLOCK_HOTPLUG flag in memblock.memory.

In this patch, we make memblock skip these hotpluggable memory regions in
the default allocate function.

memblock_find_in_range_node()
  |-->for_each_free_mem_range_reverse()
        |-->__next_free_mem_range_rev()

The above is the only place where __next_free_mem_range_rev() is used. So
skip hotpluggable memory regions when iterating memblock.memory to find
free memory.

In the later patches, a boot option named "movablenode" will be introduced
to enable/disable using SRAT to arrange ZONE_MOVABLE.


NOTE: This check will always be done. It is OK because if users didn't specify
      movablenode option, the hotpluggable memory won't be marked. So this
      check won't skip any memory, which means the kernel will act as before.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/memblock.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 05e142b..84bd568 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -695,6 +695,10 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
  * Reverse of __next_free_mem_range().
+ *
+ * Linux kernel cannot migrate pages used by itself. Memory hotplug users won't
+ * be able to hot-remove hotpluggable memory used by the kernel. So this
+ * function skip hotpluggable regions when allocating memory for the kernel.
  */
 void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 					   phys_addr_t *out_start,
@@ -719,6 +723,10 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		if (nid != MAX_NUMNODES && nid != memblock_get_region_node(m))
 			continue;
 
+		/* skip hotpluggable memory regions */
+		if (m->flags & MEMBLOCK_HOTPLUG)
+			continue;
+
 		/* scan areas before each reservation for intersection */
 		for ( ; ri >= 0; ri--) {
 			struct memblock_region *r = &rsv->regions[ri];
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
