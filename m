Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PC0uLH023576
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:00:56 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PC0ub1301210
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:00:56 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PC0tC6000657
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 07:00:56 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 17:25:09 +0530
Message-Id: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
Subject: [PATCH] Memory controller rename to Memory Resource Controller
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Rename Memory Controller to Memory Resource Controller. Reflect the same
changes in the CONFIG definition for the Memory Resource Controller.
Group together the config options for Resource Counters and Memory
Resource Controller.

This code has been compile tested with the Memory Resource Controller on and off.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/controllers/memory.txt |    8 ++++++--
 include/linux/cgroup_subsys.h        |    2 +-
 include/linux/memcontrol.h           |    4 ++--
 include/linux/mm_types.h             |    4 ++--
 init/Kconfig                         |   30 +++++++++++++++---------------
 mm/Makefile                          |    2 +-
 mm/oom_kill.c                        |    2 +-
 mm/vmscan.c                          |    4 ++--
 8 files changed, 30 insertions(+), 26 deletions(-)

diff -puN Documentation/controllers/memory.txt~memory-controller-naming-fixes Documentation/controllers/memory.txt
--- linux-2.6.25-rc3/Documentation/controllers/memory.txt~memory-controller-naming-fixes	2008-02-25 14:22:36.000000000 +0530
+++ linux-2.6.25-rc3-balbir/Documentation/controllers/memory.txt	2008-02-25 14:53:49.000000000 +0530
@@ -1,4 +1,8 @@
-Memory Controller
+Memory Resource Controller
+
+NOTE: The Memory Resource Controller has been generically been referred
+to as the memory controller in this document. Do not confuse memory controller
+used here with the memory controller that is used in hardware.
 
 Salient features
 
@@ -152,7 +156,7 @@ The memory controller uses the following
 
 a. Enable CONFIG_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
-c. Enable CONFIG_CGROUP_MEM_CONT
+c. Enable CONFIG_CGROUP_MEM_RES_CTLR
 
 1. Prepare the cgroups
 # mkdir -p /cgroups
diff -puN init/Kconfig~memory-controller-naming-fixes init/Kconfig
--- linux-2.6.25-rc3/init/Kconfig~memory-controller-naming-fixes	2008-02-25 14:22:36.000000000 +0530
+++ linux-2.6.25-rc3-balbir/init/Kconfig	2008-02-25 15:03:43.000000000 +0530
@@ -366,6 +366,21 @@ config RESOURCE_COUNTERS
           infrastructure that works with cgroups
 	depends on CGROUPS
 
+config CGROUP_MEM_RES_CTLR
+	bool "Memory Resource Controller for Control Groups"
+	depends on CGROUPS && RESOURCE_COUNTERS
+	help
+	  Provides a memory resource controller that manages both page cache and
+	  RSS memory.
+
+	  Note that setting this option increases fixed memory overhead
+	  associated with each page of memory in the system by 4/8 bytes
+	  and also increases cache misses because struct page on many 64bit
+	  systems will not fit into a single cache line anymore.
+
+	  Only enable when you're ok with these trade offs and really
+	  sure you need the memory resource controller.
+
 config SYSFS_DEPRECATED
 	bool "Create deprecated sysfs files"
 	depends on SYSFS
@@ -387,21 +402,6 @@ config SYSFS_DEPRECATED
 	  If you are using a distro that was released in 2006 or later,
 	  it should be safe to say N here.
 
-config CGROUP_MEM_CONT
-	bool "Memory controller for cgroups"
-	depends on CGROUPS && RESOURCE_COUNTERS
-	help
-	  Provides a memory controller that manages both page cache and
-	  RSS memory.
-
-	  Note that setting this option increases fixed memory overhead
-	  associated with each page of memory in the system by 4/8 bytes
-	  and also increases cache misses because struct page on many 64bit
-	  systems will not fit into a single cache line anymore.
-
-	  Only enable when you're ok with these trade offs and really
-	  sure you need the memory controller.
-
 config PROC_PID_CPUSET
 	bool "Include legacy /proc/<pid>/cpuset file"
 	depends on CPUSETS
diff -puN include/linux/memcontrol.h~memory-controller-naming-fixes include/linux/memcontrol.h
--- linux-2.6.25-rc3/include/linux/memcontrol.h~memory-controller-naming-fixes	2008-02-25 14:22:36.000000000 +0530
+++ linux-2.6.25-rc3-balbir/include/linux/memcontrol.h	2008-02-25 15:55:44.000000000 +0530
@@ -25,7 +25,7 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
@@ -72,7 +72,7 @@ extern long mem_cgroup_calc_reclaim_acti
 extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
 				struct zone *zone, int priority);
 
-#else /* CONFIG_CGROUP_MEM_CONT */
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
 static inline void mm_init_cgroup(struct mm_struct *mm,
 					struct task_struct *p)
 {
diff -puN mm/memcontrol.c~memory-controller-naming-fixes mm/memcontrol.c
diff -puN mm/vmscan.c~memory-controller-naming-fixes mm/vmscan.c
--- linux-2.6.25-rc3/mm/vmscan.c~memory-controller-naming-fixes	2008-02-25 14:22:36.000000000 +0530
+++ linux-2.6.25-rc3-balbir/mm/vmscan.c	2008-02-25 14:32:55.000000000 +0530
@@ -126,7 +126,7 @@ long vm_total_pages;	/* The total number
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
 #else
 #define scan_global_lru(sc)	(1)
@@ -1427,7 +1427,7 @@ unsigned long try_to_free_pages(struct z
 	return do_try_to_free_pages(zones, gfp_mask, &sc);
 }
 
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 						gfp_t gfp_mask)
diff -puN mm/rmap.c~memory-controller-naming-fixes mm/rmap.c
diff -puN mm/Makefile~memory-controller-naming-fixes mm/Makefile
--- linux-2.6.25-rc3/mm/Makefile~memory-controller-naming-fixes	2008-02-25 14:22:36.000000000 +0530
+++ linux-2.6.25-rc3-balbir/mm/Makefile	2008-02-25 14:33:10.000000000 +0530
@@ -32,5 +32,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_CONT) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 
diff -puN include/linux/cgroup_subsys.h~memory-controller-naming-fixes include/linux/cgroup_subsys.h
--- linux-2.6.25-rc3/include/linux/cgroup_subsys.h~memory-controller-naming-fixes	2008-02-25 14:31:04.000000000 +0530
+++ linux-2.6.25-rc3-balbir/include/linux/cgroup_subsys.h	2008-02-25 14:31:18.000000000 +0530
@@ -37,7 +37,7 @@ SUBSYS(cpuacct)
 
 /* */
 
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 SUBSYS(mem_cgroup)
 #endif
 
diff -puN include/linux/mm_types.h~memory-controller-naming-fixes include/linux/mm_types.h
--- linux-2.6.25-rc3/include/linux/mm_types.h~memory-controller-naming-fixes	2008-02-25 14:32:18.000000000 +0530
+++ linux-2.6.25-rc3-balbir/include/linux/mm_types.h	2008-02-25 15:13:53.000000000 +0530
@@ -91,7 +91,7 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	unsigned long page_cgroup;
 #endif
 };
@@ -225,7 +225,7 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif
 };
diff -puN mm/oom_kill.c~memory-controller-naming-fixes mm/oom_kill.c
--- linux-2.6.25-rc3/mm/oom_kill.c~memory-controller-naming-fixes	2008-02-25 14:33:17.000000000 +0530
+++ linux-2.6.25-rc3-balbir/mm/oom_kill.c	2008-02-25 14:33:27.000000000 +0530
@@ -412,7 +412,7 @@ static int oom_kill_process(struct task_
 	return oom_kill_task(p);
 }
 
-#ifdef CONFIG_CGROUP_MEM_CONT
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	unsigned long points = 0;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
