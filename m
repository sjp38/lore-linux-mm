Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2D919280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 09:33:08 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so64092001pdb.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 06:33:07 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id bq3si14380204pdb.151.2015.07.03.06.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 06:33:07 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NQW02SFFYZ49H10@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 03 Jul 2015 22:33:04 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
Date: Fri, 03 Jul 2015 18:50:07 +0530
Message-id: <1435929607-3435-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, akpm@linux-foundation.org, vbabka@suse.cz, gorcunov@openvz.org, pintu.k@samsung.com, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, mgorman@suse.de, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

This patch provides 2 things:
1. Add new control called shrink_memory in /proc/sys/vm/.
This control can be used to aggressively reclaim memory system-wide
in one shot from the user space. A value of 1 will instruct the
kernel to reclaim as much as totalram_pages in the system.
Example: echo 1 > /proc/sys/vm/shrink_memory

2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
Currently, shrink_all_memory function is used only during hibernation.
With the new config we can make use of this API for non-hibernation case
also without disturbing the hibernation case.

The detailed paper was presented in Embedded Linux Conference, Mar-2015
http://events.linuxfoundation.org/sites/events/files/slides/
%5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf

Scenarios were this can be used and helpful are:
1) Can be invoked just after system boot-up is finished.
2) Can be invoked just before entering entire system suspend.
3) Can be invoked from kernel when order-4 pages starts failing.
4) Can be helpful to completely avoid or delay the kerenl OOM condition.
5) Can be developed as a system-tool to quickly defragment entire system
   from user space, without the need to kill any application.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 Documentation/sysctl/vm.txt |   16 ++++++++++++++++
 include/linux/swap.h        |    7 +++++++
 kernel/sysctl.c             |    9 +++++++++
 mm/Kconfig                  |    8 ++++++++
 mm/vmscan.c                 |   23 +++++++++++++++++++++--
 5 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9832ec5..a959ad1 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -54,6 +54,7 @@ Currently, these files are in /proc/sys/vm:
 - page-cluster
 - panic_on_oom
 - percpu_pagelist_fraction
+- shrink_memory
 - stat_interval
 - swappiness
 - user_reserve_kbytes
@@ -718,6 +719,21 @@ sysctl, it will revert to this default behavior.
 
 ==============================================================
 
+shrink_memory
+
+This control is available only when CONFIG_SHRINK_MEMORY is set. This control
+can be used to aggressively reclaim memory system-wide in one shot. A value of
+1 will instruct the kernel to reclaim as much as totalram_pages in the system.
+For example, to reclaim all memory system-wide we can do:
+# echo 1 > /proc/sys/vm/shrink_memory
+
+For more information about this control, please visit the following
+presentation in embedded linux conference, 2015.
+http://events.linuxfoundation.org/sites/events/files/slides/
+%5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
+
+==============================================================
+
 stat_interval
 
 The time interval between which vm statistics are updated.  The default
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9a7adfb..6505b0b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -333,6 +333,13 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
+#ifdef CONFIG_SHRINK_MEMORY
+extern int sysctl_shrink_memory;
+extern int sysctl_shrinkmem_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos);
+#endif
+
+
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c566b56..2895099 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1351,6 +1351,15 @@ static struct ctl_table vm_table[] = {
 	},
 
 #endif /* CONFIG_COMPACTION */
+#ifdef CONFIG_SHRINK_MEMORY
+	{
+		.procname	= "shrink_memory",
+		.data		= &sysctl_shrink_memory,
+		.maxlen		= sizeof(int),
+		.mode		= 0200,
+		.proc_handler	= sysctl_shrinkmem_handler,
+	},
+#endif
 	{
 		.procname	= "min_free_kbytes",
 		.data		= &min_free_kbytes,
diff --git a/mm/Kconfig b/mm/Kconfig
index b3a60ee..8e04bd9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -657,3 +657,11 @@ config DEFERRED_STRUCT_PAGE_INIT
 	  when kswapd starts. This has a potential performance impact on
 	  processes running early in the lifetime of the systemm until kswapd
 	  finishes the initialisation.
+
+config SHRINK_MEMORY
+	bool "Allow for system-wide shrinking of memory"
+	default n
+	depends on MMU
+	help
+	  It enables support for system-wide memory reclaim in one shot using
+	  echo 1 > /proc/sys/vm/shrink_memory.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c8d8282..837b88d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3557,7 +3557,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
-#ifdef CONFIG_HIBERNATION
+#if defined CONFIG_HIBERNATION || CONFIG_SHRINK_MEMORY
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
  * freed pages.
@@ -3571,12 +3571,17 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
+#ifdef CONFIG_SHRINK_MEMORY
+		.gfp_mask = (GFP_HIGHUSER_MOVABLE | GFP_RECLAIM_MASK),
+		.hibernation_mode = 0,
+#else
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
+		.hibernation_mode = 1,
+#endif
 		.priority = DEF_PRIORITY,
 		.may_writepage = 1,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.hibernation_mode = 1,
 	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
@@ -3597,6 +3602,20 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 }
 #endif /* CONFIG_HIBERNATION */
 
+#ifdef CONFIG_SHRINK_MEMORY
+int sysctl_shrink_memory;
+/* This is the entry point for system-wide shrink memory
++via /proc/sys/vm/shrink_memory */
+int sysctl_shrinkmem_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	if (write)
+		shrink_all_memory(totalram_pages);
+
+	return 0;
+}
+#endif
+
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes
    away, we get changed to run anywhere: as the first one comes back,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
