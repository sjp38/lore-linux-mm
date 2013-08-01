Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 3798B6B006C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 03:08:19 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 17/18] mem-hotplug: Introduce movablenode boot option to {en|dis}able using SRAT.
Date: Thu, 1 Aug 2013 15:06:39 +0800
Message-Id: <1375340800-19332-18-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
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

Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   15 +++++++++++++++
 arch/x86/kernel/setup.c             |   10 ++++++++--
 include/linux/memory_hotplug.h      |    3 +++
 mm/memory_hotplug.c                 |   11 +++++++++++
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 2fe6e76..3f77ba3 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1714,6 +1714,21 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
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
index 8b1bddd..7c94e92 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1060,14 +1060,20 @@ void __init setup_arch(char **cmdline_p)
 	/* Initialize ACPI root table */
 	acpi_root_table_init();
 
-#ifdef CONFIG_ACPI_NUMA
+#if defined(CONFIG_ACPI_NUMA) && defined(CONFIG_MOVABLE_NODE)
 	/*
 	 * Linux kernel cannot migrate kernel pages, as a result, memory used
 	 * by the kernel cannot be hot-removed. Find and mark hotpluggable
 	 * memory in memblock to prevent memblock from allocating hotpluggable
 	 * memory for the kernel.
+	 *
+	 * If all the memory in a node is hotpluggable, then the kernel won't
+	 * be able to use memory on that node. This will cause NUMA performance
+	 * down. So by default, we don't reserve any hotpluggable memory. Users
+	 * may use "movablenode" boot option to enable this functionality.
 	 */
-	find_hotpluggable_memory();
+	if (movablenode_enable_srat)
+		find_hotpluggable_memory();
 #endif
 
 	/*
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index c32af49..65b2a48 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -33,6 +33,9 @@ enum {
 	ONLINE_MOVABLE,
 };
 
+/* Enable/disable SRAT in movablenode boot option */
+extern bool movablenode_enable_srat;
+
 /*
  * pgdat resizing functions
  */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3e95fe5..97eb26b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -93,6 +93,17 @@ static void release_memory_resource(struct resource *res)
 }
 
 #ifdef CONFIG_ACPI_NUMA
+#ifdef CONFIG_MOVABLE_NODE
+bool __initdata movablenode_enable_srat;
+
+static int __init cmdline_parse_movablenode(char *p)
+{
+	movablenode_enable_srat = true;
+	return 0;
+}
+early_param("movablenode", cmdline_parse_movablenode);
+#endif	/* CONFIG_MOVABLE_NODE */
+
 /**
  * kernel_resides_in_range - Check if kernel resides in a memory region.
  * @base: The base address of the memory region.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
