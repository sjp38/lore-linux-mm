Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id ADB596B00AA
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:53:51 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v3 20/25] x86, numa, mem_hotplug: Skip all the regions the kernel resides in.
Date: Wed, 7 Aug 2013 18:52:11 +0800
Message-Id: <1375872736-4822-21-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375872736-4822-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

At early time, memblock will reserve some memory for the kernel,
such as the kernel code and data segments, initrd file, and so on,
which means the kernel resides in these memory regions.

Even if these memory regions are hotpluggable, we should not
mark them as hotpluggable. Otherwise the kernel won't have enough
memory to boot.

This patch finds out which memory regions the kernel resides in,
and skip them when finding all hotpluggable memory regions.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ef9ccf8..3d760fc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -31,6 +31,7 @@
 #include <linux/firmware-map.h>
 #include <linux/stop_machine.h>
 #include <linux/acpi.h>
+#include <linux/memblock.h>
 
 #include <asm/tlbflush.h>
 
@@ -93,6 +94,40 @@ static void release_memory_resource(struct resource *res)
 
 #ifdef CONFIG_ACPI_NUMA
 /**
+ * kernel_resides_in_range - Check if kernel resides in a memory region.
+ * @base: The base address of the memory region.
+ * @length: The length of the memory region.
+ *
+ * This function is used at early time. It iterates memblock.reserved and check
+ * if the kernel has used any memory in [@base, @base + @length).
+ *
+ * Return true if the kernel resides in the memory region, false otherwise.
+ */
+static bool __init kernel_resides_in_region(phys_addr_t base, u64 length)
+{
+	int i;
+	phys_addr_t start, end;
+	struct memblock_region *region;
+	struct memblock_type *reserved = &memblock.reserved;
+
+	for (i = 0; i < reserved->cnt; i++) {
+		region = &reserved->regions[i];
+
+		if (region->flags != MEMBLOCK_HOTPLUG)
+			continue;
+
+		start = region->base;
+		end = region->base + region->size;
+		if (end <= base || start >= base + length)
+			continue;
+
+		return true;
+	}
+
+	return false;
+}
+
+/**
  * find_hotpluggable_memory - Find out hotpluggable memory from ACPI SRAT.
  *
  * This function did the following:
@@ -129,6 +164,16 @@ void __init find_hotpluggable_memory(void)
 
 	while (ACPI_SUCCESS(acpi_hotplug_mem_affinity(srat_vaddr, &base,
 						      &size, &offset))) {
+		/*
+		 * At early time, memblock will reserve some memory for the
+		 * kernel, such as the kernel code and data segments, initrd
+		 * file, and so on, which means the kernel resides in these
+		 * memory regions. These regions should not be hotpluggable.
+		 * So do not mark them as hotpluggable.
+		 */
+		if (kernel_resides_in_region(base, size))
+			continue;
+
 		/* Will mark hotpluggable memory regions here */
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
