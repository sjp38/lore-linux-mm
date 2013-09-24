Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id E57576B0034
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 06:12:31 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id x13so8828743ief.15
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 03:12:31 -0700 (PDT)
Message-ID: <5241655E.1000007@cn.fujitsu.com>
Date: Tue, 24 Sep 2013 18:11:42 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 6/6] mem-hotplug: Introduce movablenode boot option
References: <524162DA.30004@cn.fujitsu.com>
In-Reply-To: <524162DA.30004@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com
Cc: "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei.yes@gmail.com>

From: Tang Chen <tangchen@cn.fujitsu.com>

The hot-Pluggable field in SRAT specifies which memory is hotpluggable.
As we mentioned before, if hotpluggable memory is used by the kernel,
it cannot be hot-removed. So memory hotplug users may want to set all
hotpluggable memory in ZONE_MOVABLE so that the kernel won't use it.

Memory hotplug users may also set a node as movable node, which has
ZONE_MOVABLE only, so that the whole node can be hot-removed.

But the kernel cannot use memory in ZONE_MOVABLE. By doing this, the
kernel cannot use memory in movable nodes. This will cause NUMA
performance down. And other users may be unhappy.

So we need a way to allow users to enable and disable this functionality.
In this patch, we introduce movablenode boot option to allow users to
choose to not to consume hotpluggable memory at early boot time and
later we can set it as ZONE_MOVABLE.

To achieve this, the movablenode boot option will control the memblock
allocation direction. That said, after memblock is ready, before SRAT is
parsed, we should allocate memory near the kernel image as we explained
in the previous patches. So if movablenode boot option is set, the kernel
does the following:

1. After memblock is ready, make memblock allocate memory bottom up.
2. After SRAT is parsed, make memblock behave as default, allocate memory
   top down.

Users can specify "movablenode" in kernel commandline to enable this
functionality. For those who don't use memory hotplug or who don't want
to lose their NUMA performance, just don't specify anything. The kernel
will work as before.

Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   15 +++++++++++++++
 arch/x86/kernel/setup.c             |    8 ++++++++
 mm/memory_hotplug.c                 |   27 +++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 1a036cd..8c056c4 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1769,6 +1769,21 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
+	movablenode		[KNL,X86] This parameter enables/disables the
+			kernel to arrange hotpluggable memory ranges recorded
+			in ACPI SRAT(System Resource Affinity Table) as
+			ZONE_MOVABLE. And these memory can be hot-removed when
+			the system is up.
+			By specifying this option, all the hotpluggable memory
+			will be in ZONE_MOVABLE, which the kernel cannot use.
+			This will cause NUMA performance down. For users who
+			care about NUMA performance, just don't use it.
+			If all the memory ranges in the system are hotpluggable,
+			then the ones used by the kernel at early time, such as
+			kernel code and data segments, initrd file and so on,
+			won't be set as ZONE_MOVABLE, and won't be hotpluggable.
+			Otherwise the kernel won't have enough memory to boot.
+
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 36cfce3..2cf04fd 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1132,6 +1132,14 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+
+	/*
+	 * When ACPI SRAT is parsed, which is done in initmem_init(),
+	 * set memblock back to the top-down direction.
+	 */
+	if (memblock_bottom_up())
+		memblock_set_bottom_up(false);
+
 	memblock_find_dma_reserve();
 
 	/*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ed85fe3..9d36fee 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -31,6 +31,7 @@
 #include <linux/firmware-map.h>
 #include <linux/stop_machine.h>
 #include <linux/hugetlb.h>
+#include <linux/memblock.h>
 
 #include <asm/tlbflush.h>
 
@@ -1386,6 +1387,32 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 {
 	return true;
 }
+
+static int __init cmdline_parse_movablenode(char *p)
+{
+	/*
+	 * Memory used by the kernel cannot be hot-removed because Linux
+	 * cannot migrate the kernel pages. When memory hotplug is
+	 * enabled, we should prevent memblock from allocating memory
+	 * for the kernel.
+	 *
+	 * ACPI SRAT records all hotpluggable memory ranges. But before
+	 * SRAT is parsed, we don't know about it.
+	 *
+	 * The kernel image is loaded into memory at very early time. We
+	 * cannot prevent this anyway. So on NUMA system, we set any
+	 * node the kernel resides in as un-hotpluggable.
+	 *
+	 * Since on modern servers, one node could have double-digit
+	 * gigabytes memory, we can assume the memory around the kernel
+	 * image is also un-hotpluggable. So before SRAT is parsed, just
+	 * allocate memory near the kernel image to try the best to keep
+	 * the kernel away from hotpluggable memory.
+	 */
+	memblock_set_bottom_up(true);
+	return 0;
+}
+early_param("movablenode", cmdline_parse_movablenode);
 #else /* CONFIG_MOVABLE_NODE */
 /* ensure the node has NORMAL memory if it is still online */
 static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
