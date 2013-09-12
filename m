Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 465B76B003B
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 06:03:34 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [RESEND PATCH v2 9/9] mem-hotplug: Introduce movablenode boot option to control memblock allocation direction.
Date: Thu, 12 Sep 2013 17:52:17 +0800
Message-Id: <1378979537-21196-10-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1378979537-21196-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The Hot-Pluggable fired in SRAT specifies which memory is hotpluggable.
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
choose to reserve hotpluggable memory and set it as ZONE_MOVABLE or not.

Users can specify "movablenode" in kernel commandline to enable this
functionality. For those who don't use memory hotplug or who don't want
to lose their NUMA performance, just don't specify anything. The kernel
will work as before.

After memblock is ready, before SRAT is parsed, we should allocate memory
near the kernel image. So this patch does the following:

1. After memblock is ready, make memblock allocate memory from low address
   to high.
2. After SRAT is parsed, make memblock behave as default, allocate memory
   from high address to low.

This behavior is controlled by movablenode boot option.

Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   15 ++++++++++++++
 arch/x86/kernel/setup.c             |   36 +++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h      |    5 ++++
 mm/memory_hotplug.c                 |    9 ++++++++
 4 files changed, 65 insertions(+), 0 deletions(-)

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
index fa56a57..b87069b 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1104,6 +1104,31 @@ void __init setup_arch(char **cmdline_p)
 	trim_platform_memory_ranges();
 	trim_low_memory_range();
 
+#ifdef CONFIG_MOVABLE_NODE
+	if (movablenode_enable_srat) {
+		/*
+		 * Memory used by the kernel cannot be hot-removed because Linux
+		 * cannot migrate the kernel pages. When memory hotplug is
+		 * enabled, we should prevent memblock from allocating memory
+		 * for the kernel.
+		 *
+		 * ACPI SRAT records all hotpluggable memory ranges. But before
+		 * SRAT is parsed, we don't know about it.
+		 *
+		 * The kernel image is loaded into memory at very early time. We
+		 * cannot prevent this anyway. So on NUMA system, we set any
+		 * node the kernel resides in as un-hotpluggable.
+		 *
+		 * Since on modern servers, one node could have double-digit
+		 * gigabytes memory, we can assume the memory around the kernel
+		 * image is also un-hotpluggable. So before SRAT is parsed, just
+		 * allocate memory near the kernel image to try the best to keep
+		 * the kernel away from hotpluggable memory.
+		 */
+		memblock_set_current_direction(MEMBLOCK_DIRECTION_LOW_TO_HIGH);
+	}
+#endif /* CONFIG_MOVABLE_NODE */
+
 	init_mem_mapping();
 
 	early_trap_pf_init();
@@ -1142,6 +1167,17 @@ void __init setup_arch(char **cmdline_p)
 	early_acpi_boot_init();
 
 	initmem_init();
+
+#ifdef CONFIG_MOVABLE_NODE
+	if (movablenode_enable_srat) {
+		/*
+		 * When ACPI SRAT is parsed, which is done in initmem_init(),
+		 * set memblock back to the default behavior.
+		 */
+		memblock_set_current_direction(MEMBLOCK_DIRECTION_DEFAULT);
+	}
+#endif /* CONFIG_MOVABLE_NODE */
+
 	memblock_find_dma_reserve();
 
 	/*
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index dd38e62..5d2c07b 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -33,6 +33,11 @@ enum {
 	ONLINE_MOVABLE,
 };
 
+#ifdef CONFIG_MOVABLE_NODE
+/* Enable/disable SRAT in movablenode boot option */
+extern bool movablenode_enable_srat;
+#endif /* CONFIG_MOVABLE_NODE */
+
 /*
  * pgdat resizing functions
  */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0eb1a1d..8a4c8ff 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1390,6 +1390,15 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 {
 	return true;
 }
+
+bool __initdata movablenode_enable_srat;
+
+static int __init cmdline_parse_movablenode(char *p)
+{
+	movablenode_enable_srat = true;
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
