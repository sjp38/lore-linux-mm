Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE8756B02E7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 00:40:44 -0400 (EDT)
Received: by padck2 with SMTP id ck2so95134354pad.0
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 21:40:44 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id fl5si32923267pab.130.2015.07.19.21.40.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Jul 2015 21:40:43 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NRR01BMCRNMD060@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 20 Jul 2015 13:40:34 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
Date: Mon, 20 Jul 2015 09:59:04 +0530
Message-id: <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
In-reply-to: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, pintu.k@samsung.com, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, mgorman@suse.de, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

This patch provides 2 things:
1. Add new control called shrink_memory in /proc/sys/vm/.
This control can be used to aggressively reclaim memory system-wide
in one shot from the user space. A value of 1 will instruct the
kernel to reclaim as much as totalram_pages in the system.
Example: echo 1 > /proc/sys/vm/shrink_memory

If any other value than 1 is written to shrink_memory an error EINVAL
occurs.

2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
Currently, shrink_all_memory function is used only during hibernation.
With the new config we can make use of this API for non-hibernation case
also without disturbing the hibernation case.

The detailed paper was presented in Embedded Linux Conference, Mar-2015
http://events.linuxfoundation.org/sites/events/files/slides/
%5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf

A sample example is shown below:
Device: ARMv7, Dual Core CPU 1.2GHz
RAM: 512MB (Without SWAP/ZRAM)
Linux Kernel: 3.10.17
Scenario: Just after boot-up finished.

BEFORE:
-------------------------------------------------------------------------
shell> free -tm ; cat /proc/buddyinfo
             total       used       free     shared    buffers     cached
Mem:           460        440         20          0         35        154
-/+ buffers/cache:        250        209
Swap:            0          0          0
Total:         460        440         20
Node 0, zone   Normal   1037    705     92     19     19     17      4      9      0      0      0

shell> vmstat 1 &

AFTER:
-------------------------------------------------------------------------
shell> echo 1 > /proc/sys/vm/shrink_memory

 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0  20768  35876 157876    0    0     0     0   64  177  0  1 99  0  0
--------------------------------------------------------------------------------
|1  0      0  33104  34864 149808    0    0     0     0   82  221  0 12 88  0  0|
--------------------------------------------------------------------------------
 0  0      0 188776   3000  54420    0    0     0     0  216  374  0 30 70  0  0
 0  0      0 188400   3652  54528    0    0   740     8  188  337  2  1 95  2  0

shell> free -tm ; cat /proc/buddyinfo
             total       used       free     shared    buffers     cached
Mem:           460        278        182          0          4         54
-/+ buffers/cache:        219        240
Swap:            0          0          0
Total:         460        278        182
Node 0, zone   Normal   5575   3158   1500    727    240     90     33     18     10      6      6

RESULTS:
-----------------------------------------------------
Around 160MB of memory were recovered in one shot.
Many higher-order pages were recovered in the process.
>From the vmstat output the total CPU usage is: ~12% (system), when this
command is running, for 1 second.
We also measured the power consumption using H/W power monitor tool.
Below is the result:
Before - ~180mA
During shrink memory - ~237mA
Duration - ~0.5 sec
Consumption: ~57mA

FURTHER OBSERVATIONS:
-----------------------------------------------------
37% reduction in killing of application with memory shrink calling on boot up.
Around ~4000 page faults are reduced.
Around ~43% of reduction in kswapd calls.
Movement to slowpath reduced dractically.
Combining shrink_memory with compaction shows good benefits over fragmentation.

APPLICATION LAUNCH BEHAVIOR:
-----------------------------------------------------
During First Launch:
============================================================================
Application	Before_shrink_memory	After_shrink_memory	Difference
Camera		1.981			1.86			0.121
Gallery		1.276			0.94			0.336
contacts	1.112			0.941			0.171
messaging	0.886			0.795			0.091
settings	1.257			1.212			0.045
Music		1.854			2.098			-0.244
Gmail		1.872			1.935			-0.063
Browser		2.569			2.677			-0.108
============================================================================

During Re-launch:
============================================================================
Application	Before_shrink_memory	After_shrink_memory	Difference
Camera		1.248			0.976			0.272
Gallery		0.697			0.633			0.064
contacts	0.506			0.561			-0.055
messaging	0.533			0.489			0.044
settings	0.833			0.805			0.028
Music		0.832			0.769			0.063
Gmail		0.913			0.841			0.072
Browser		0.579			0.57			0.009
============================================================================

Various other use cases where this can be used:
----------------------------------------------------------------------------
1) Just after system boot-up is finished, using the sysctl configuration from
   bootup script.
2) During system suspend state, after suspend_freeze_processes()
   [kernel/power/suspend.c]
   Based on certain condition about fragmentation or free memory state.
3) From Android ION system heap driver, when order-4 allocation starts failing.
   By calling shrink_all_memory, in a separate worker thread, based on certain
   condition.
4) It can be combined with compact_memory to achieve better results on memory
   fragmentation.
5) It can be helpful in debugging and tuning various vm parameters.
6) It can be helpful to identify how much of maximum memory could be
   reclaimable at any point of time.
   And how much higher-order pages could be formed with this amount of
   reclaimable memory.
   Thus it can be helpful in accordingly tuning the reserved memory needs
   of a system.
7) It can be helpful in properly tuning the SWAP size in the system.
   In shrink_all_memory, we enable may_swap = 1, that means all unused pages
   will be swapped out.
   Thus, running shrink_memory on a heavy loaded system, we can check how much
   swap is getting full.
   That can be the maximum swap size with a 10% delta.
   Also if ZRAM is used, it helps us in compressing and storing the pages for
   later use.
8) It can be helpful to allow more new applications to be launched, without
   killing the older once.
   And moving the least recently used pages to the SWAP area.
   Thus user data can be retained.
9) Can be part of a system utility to quickly defragment entire system
   memory.
10) This may also help in reducing fragmentation within CMA region.
11) More use cases can be identified.

Most importantly, it can be more effective when applied intelligently, based
on certain conditions.
It should not be executed always and the decision is left upto the user.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
V3: Correcting a small typo error at the end of commit message.

V2: Added min,max parameter for shrink_memory, suggested by
    Heinrich Schuchardt <xypron.glpk@gmx.de>.
    Error handling in sysctl_shrinkmem_handler, for any value other than 1,
    suggested by, Heinrich Schuchardt <xypron.glpk@gmx.de>.
    Fixed HIBERNATION+SHRINK_MEMORY issue in shrink_all_memory,
    suggested by Valdis.Kletnieks@vt.edu.
    Restore gfp_mask to original, because of other dependencies.
    Also adding GFP_RECLAIM_MASK, does not affect anything.
    Verified power consumption data during shrink_memory,
    as suggested by Johannes Weiner <hannes@cmpxchg.org>.
    Verified application launch/re-launch scenarios before/after shrink_memory,
    as suggested by Xishi Qiu <qiuxishi@huawei.com>.
    Updates the commit messages with examples and use cases.

 Documentation/sysctl/vm.txt |   18 ++++++++++++++++++
 include/linux/swap.h        |    7 +++++++
 kernel/sysctl.c             |   16 ++++++++++++++++
 mm/Kconfig                  |    8 ++++++++
 mm/vmscan.c                 |   34 ++++++++++++++++++++++++++++++++--
 5 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9832ec5..54eda3a 100644
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
@@ -718,6 +719,23 @@ sysctl, it will revert to this default behavior.
 
 ==============================================================
 
+shrink_memory
+
+This control is available only when CONFIG_SHRINK_MEMORY is set. This control
+can be used to aggressively reclaim memory system-wide in one shot. A value of
+1 will instruct the kernel to reclaim as much as totalram_pages in the system.
+For example, to reclaim all memory system-wide we can do:
+# echo 1 > /proc/sys/vm/shrink_memory
+
+If any other value than 1 is written to shrink_memory an error EINVAL occurs.
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
index c566b56..e66581b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -275,6 +275,11 @@ static int min_extfrag_threshold;
 static int max_extfrag_threshold = 1000;
 #endif
 
+#ifdef CONFIG_SHRINK_MEMORY
+static int min_shrink_memory = 1;
+static int max_shrink_memory = 1;
+#endif
+
 static struct ctl_table kern_table[] = {
 	{
 		.procname	= "sched_child_runs_first",
@@ -1351,6 +1356,17 @@ static struct ctl_table vm_table[] = {
 	},
 
 #endif /* CONFIG_COMPACTION */
+#ifdef CONFIG_SHRINK_MEMORY
+	{
+		.procname	= "shrink_memory",
+		.data		= &sysctl_shrink_memory,
+		.maxlen		= sizeof(int),
+		.mode		= 0200,
+		.proc_handler	= sysctl_shrinkmem_handler,
+		.extra1         = &min_shrink_memory,
+		.extra2         = &max_shrink_memory,
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
index c8d8282..e802fa7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -58,6 +58,10 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
+#ifdef CONFIG_SHRINK_MEMORY
+#include <linux/suspend.h>
+#endif
+
 struct scan_control {
 	/* How many pages shrink_list() should reclaim */
 	unsigned long nr_to_reclaim;
@@ -3557,7 +3561,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
-#ifdef CONFIG_HIBERNATION
+#if defined CONFIG_HIBERNATION || CONFIG_SHRINK_MEMORY
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
  * freed pages.
@@ -3576,12 +3580,16 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.may_writepage = 1,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.hibernation_mode = 1,
 	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
 
+	if (system_entering_hibernation())
+		sc.hibernation_mode = 1;
+	else
+		sc.hibernation_mode = 0;
+
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
@@ -3597,6 +3605,28 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 }
 #endif /* CONFIG_HIBERNATION */
 
+#ifdef CONFIG_SHRINK_MEMORY
+int sysctl_shrink_memory;
+/* This is the entry point for system-wide shrink memory
++via /proc/sys/vm/shrink_memory */
+int sysctl_shrinkmem_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		return ret;
+
+	if (write) {
+		if (sysctl_shrink_memory & 1)
+			shrink_all_memory(totalram_pages);
+	}
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
