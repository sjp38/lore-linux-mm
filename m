Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id E967D6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:00:16 -0400 (EDT)
Received: by obcor6 with SMTP id or6so17557948obc.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 00:00:16 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id xf6si7874696oeb.63.2015.10.12.00.00.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 00:00:15 -0700 (PDT)
From: Changsheng Liu <liuchangsheng@inspur.com>
Subject: [PATCH V7] mm: memory hot-add: memory can not be added to movable zone defaultly
Date: Mon, 12 Oct 2015 02:58:33 -0400
Message-ID: <1444633113-27607-1-git-send-email-liuchangsheng@inspur.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, yasu.isimatu@gmail.com, tangchen@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, liuchangsheng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

From: Changsheng Liu <liuchangcheng@inspur.com>

After the user config CONFIG_MOVABLE_NODE,
When the memory is hot added, should_add_memory_movable() return 0
because all zones including ZONE_MOVABLE are empty,
so the memory that was hot added will be assigned to ZONE_NORMAL
and ZONE_NORMAL will be created firstly.
But we want the whole node to be added to ZONE_MOVABLE by default.

So we change should_add_memory_movable(): if the user config
CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable is 1
and the ZONE_NORMAL is empty or the pfn of the hot-added memory
is after the end of the ZONE_NORMAL it will always return 1
and then the whole node will be added to ZONE_MOVABLE by default.
If we want the node to be assigned to ZONE_NORMAL,
we can do it as follows:
"echo online_kernel > /sys/devices/system/memory/memoryXXX/state"

By the patch, the behavious of kernel is changed by sysctl,
user can automatically create movable memory
by only the following udev rule:
SUBSYSTEM=="memory", ACTION=="add",
ATTR{state}=="offline", ATTR{state}="online"

Signed-off-by: Changsheng Liu <liuchangsheng@inspur.com>
Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
Tested-by: Dongdong Fan <fandd@inspur.com>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
---
 Documentation/memory-hotplug.txt |    5 ++++-
 kernel/sysctl.c                  |   15 +++++++++++++++
 mm/memory_hotplug.c              |   24 ++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index ce2cfcf..7ac7485 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -277,7 +277,7 @@ And if the memory block is in ZONE_MOVABLE, you can change it to ZONE_NORMAL:
 After this, memory block XXX's state will be 'online' and the amount of
 available memory will be increased.
 
-Currently, newly added memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA).
+Currently, newly added memory is added as ZONE_NORMAL or ZONE_MOVABLE (for powerpc, ZONE_DMA).
 This may be changed in future.
 
 
@@ -319,6 +319,9 @@ creates ZONE_MOVABLE as following.
   Size of memory not for movable pages (not for offline) is TOTAL - ZZZZ.
   Size of memory for movable pages (for offline) is ZZZZ.
 
+And a sysctl parameter for assigning the hot added memory to ZONE_MOVABLE is
+supported. If the value of "kernel/hotadd_memory_as_movable" is 1,the hot added
+memory will be assigned to ZONE_MOVABLE by default.
 
 Note: Unfortunately, there is no information to show which memory block belongs
 to ZONE_MOVABLE. This is TBD.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 19b62b5..16b1501 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -166,6 +166,10 @@ extern int unaligned_dump_stack;
 extern int no_unaligned_warning;
 #endif
 
+#ifdef CONFIG_MOVABLE_NODE
+extern int hotadd_memory_as_movable;
+#endif
+
 #ifdef CONFIG_PROC_SYSCTL
 
 #define SYSCTL_WRITES_LEGACY	-1
@@ -1139,6 +1143,17 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= timer_migration_handler,
 	},
 #endif
+/*If the value of "kernel/hotadd_memory_as_movable" is 1,the hot added
+ * memory will be assigned to ZONE_MOVABLE by default.*/
+#ifdef CONFIG_MOVABLE_NODE
+	{
+		.procname	= "hotadd_memory_as_movable",
+		.data		= &hotadd_memory_as_movable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..eca5512 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -37,6 +37,11 @@
 
 #include "internal.h"
 
+/*If the global variable value is 1,
+ * the hot added memory will be assigned to ZONE_MOVABLE by default
+ */
+int hotadd_memory_as_movable;
+
 /*
  * online_page_callback contains pointer to current page onlining function.
  * Initially it is generic_online_page(). If it is required it could be
@@ -1190,6 +1195,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
 /*
  * If movable zone has already been setup, newly added memory should be check.
  * If its address is higher than movable zone, it should be added as movable.
+ * And if system config CONFIG_MOVABLE_NODE and set the sysctl parameter
+ * "hotadd_memory_as_movable" and added memory does not overlap the zone
+ * before MOVABLE_ZONE,the memory will be added as movable.
  * Without this check, movable zone may overlap with other zone.
  */
 static int should_add_memory_movable(int nid, u64 start, u64 size)
@@ -1197,6 +1205,22 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
+	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
+	/*
+	 * The system configs CONFIG_MOVABLE_NODE to assign a node
+	 * which has only movable memory,so the hot-added memory should
+	 * be assigned to ZONE_MOVABLE by default,
+	 * but the function zone_for_memory() assign the hot-added memory
+	 * to ZONE_NORMAL(x86_64) by default.Kernel does not allow to
+	 * create ZONE_MOVABLE before ZONE_NORMAL,So if the value of
+	 * sysctl parameter "hotadd_memory_as_movable" is 1
+	 * and the ZONE_NORMAL is empty or the pfn of the hot-added memory
+	 * is after the end of ZONE_NORMAL
+	 * the hot-added memory will be assigned to ZONE_MOVABLE.
+	 */
+	if (hotadd_memory_as_movable
+	&& (zone_is_empty(pre_zone) || zone_end_pfn(pre_zone) <= start_pfn))
+		return 1;
 
 	if (zone_is_empty(movable_zone))
 		return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
