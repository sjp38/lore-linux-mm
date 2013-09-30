Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 925DD6B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 13:41:43 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so6177535pab.24
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 10:41:43 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so6246888pab.27
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 10:41:40 -0700 (PDT)
Message-ID: <5249B7C6.7010902@gmail.com>
Date: Tue, 01 Oct 2013 01:41:26 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH -mm] mm, memory-hotpulg: Rename movablenode boot option to
 movable_node
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, imtangchen@gmail.com

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Since we already has config MOVABLE_NODE, and the boot option
movablenode is introduced as the boot-time switch to disable
the effects of CONFIG_MOVABLE_NODE=y when the system is booting.

So rename boot option movablenode to movable_node to match the
config MOVABLE_NODE. And also updates the description of MOVABLE_NODE
in mm/Kconfig and the description of movable_node in kernel doc.

Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 Documentation/kernel-parameters.txt |   16 ++--------------
 mm/Kconfig                          |   17 ++++++++++++-----
 mm/memory_hotplug.c                 |    6 +++---
 3 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a87e17e..953a533 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1773,20 +1773,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movablenode		[KNL,X86] This parameter enables/disables the
-			kernel to arrange hotpluggable memory ranges recorded
-			in ACPI SRAT(System Resource Affinity Table) as
-			ZONE_MOVABLE. And these memory can be hot-removed when
-			the system is up.
-			By specifying this option, all the hotpluggable memory
-			will be in ZONE_MOVABLE, which the kernel cannot use.
-			This will cause NUMA performance down. For users who
-			care about NUMA performance, just don't use it.
-			If all the memory ranges in the system are hotpluggable,
-			then the ones used by the kernel at early time, such as
-			kernel code and data segments, initrd file and so on,
-			won't be set as ZONE_MOVABLE, and won't be hotpluggable.
-			Otherwise the kernel won't have enough memory to boot.
+	movable_node	[KNL,X86] Boot-time switch to disable the effects
+			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
 	MTD_Partition=	[MTD]
 			Format: <name>,<region-number>,<size>,<offset>
diff --git a/mm/Kconfig b/mm/Kconfig
index ff6e820..8d4ebb0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -153,11 +153,18 @@ config MOVABLE_NODE
 	help
 	  Allow a node to have only movable memory.  Pages used by the kernel,
 	  such as direct mapping pages cannot be migrated.  So the corresponding
-	  memory device cannot be hotplugged.  This option allows users to
-	  online all the memory of a node as movable memory so that the whole
-	  node can be hotplugged.  Users who don't use the memory hotplug
-	  feature are fine with this option on since they don't online memory
-	  as movable.
+	  memory device cannot be hotplugged.  This option allows the following
+	  two things:
+	  - When the system is booting, node full of hotpluggable memory can
+	  be arranged to have only movable memory so that the whole node can
+	  be hotplugged. (need movable_node boot option specified).
+	  - After the system is up, the option allows users to online all the
+	  memory of a node as movable memory so that the whole node can be
+	  hotplugged.
+
+	  Users who don't use the memory hotplug feature are fine with this
+	  option on since they don't specify movable_node boot option or they
+	  don't online memory as movable.
 
 	  Say Y here if you want to hotplug a whole node.
 	  Say N here if you want kernel to use memory on all nodes evenly.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b468f77..5e2aed9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1424,7 +1424,7 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 }
 #endif /* CONFIG_MOVABLE_NODE */
 
-static int __init cmdline_parse_movablenode(char *p)
+static int __init cmdline_parse_movable_node(char *p)
 {
 #ifdef CONFIG_MOVABLE_NODE
 	/*
@@ -1448,11 +1448,11 @@ static int __init cmdline_parse_movablenode(char *p)
 	 */
 	memblock_set_bottom_up(true);
 #else
-	pr_warn("movablenode option not supported");
+	pr_warn("movable_node option not supported");
 #endif
 	return 0;
 }
-early_param("movablenode", cmdline_parse_movablenode);
+early_param("movable_node", cmdline_parse_movable_node);
 
 /* check which state of node_states will be changed when offline memory */
 static void node_states_check_changes_offline(unsigned long nr_pages,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
