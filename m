Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A687D6B0062
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 23:34:33 -0400 (EDT)
Received: from sj-core-1.cisco.com (sj-core-1.cisco.com [171.71.177.237])
	by sj-dkim-3.cisco.com (8.12.11/8.12.11) with ESMTP id n3T3Z51R012765
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 20:35:05 -0700
Received: from cliff.cisco.com (cliff.cisco.com [171.69.11.141])
	by sj-core-1.cisco.com (8.13.8/8.13.8) with ESMTP id n3T3Z5r3009303
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:35:05 GMT
Received: from cuplxvomd02.corp.sa.net ([64.101.20.155]) by cliff.cisco.com (8.6.12/8.6.5) with ESMTP id DAA25906 for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:35:04 GMT
Date: Tue, 28 Apr 2009 20:35:04 -0700
From: David VomLehn <dvomlehn@cisco.com>
Subject: [Patch 2/2] MM: Add sysctls for vm_enough_memory
Message-ID: <20090429033504.GA27893@cuplxvomd02.corp.sa.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the second part of what was originally submitted as a single patch.
The first part consolidates duplicates of get_user_pages and __vm_enough_memory
into mm/util.c This part changes the functionality of __vm_enough_memory():
1.	There was a check that seems intended to assure that a single task
	does not use more than 97% of virtual memory in the case that the
	overcommit setting is OVERCOMMIT_NEVER. If this was the intended
	behavior, it appears as though it never worked. The check seems
	reasonable though, and the new code tries to implement this limit.
2.	It introduces sysctl_max_task_ratio to control the maximum size of a
	single task for OVERCOMMIT_NEVER.
3.	It introduces sysctl_sysadmin_reserved controlling the amount of RAM
	reserved for tasks with cap_sys_admin set, which is used for both
	OVERCOMMIT_GUESS and OVERCOMMIT_NEVER.

The last two items are important on systems that have all of the following:
1. Disable memory commit
2. Have have large amounts of memory
3. Have a single large primary process that handles the bulk of processing

This is a reasonable configuration for large embedded systems. On a 512 MiB
system, the 3% reserved for cap_sys_admin tasks amounts to 15 MiB, more than
would normally be needed to to run last-ditch clean-up tasks. Introducing
configurables allows the memory that is now reserved to be used by the
large primary process

The default value for sysctl_sysadmin_reserved is the same as previous
hardcoded value. The default value of sysctl_max_task_ratio was chosen to
agree with what the intent of the task size limitation code seemed to be.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 include/linux/mman.h   |    2 ++
 include/linux/sysctl.h |    3 +++
 kernel/sysctl.c        |   23 +++++++++++++++++++++++
 kernel/sysctl_check.c  |    2 ++
 mm/util.c              |   36 ++++++++++++++++++++++++------------
 5 files changed, 54 insertions(+), 12 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 30d1073..06b4d75 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -17,6 +17,8 @@
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern int sysctl_sysadmin_reserved;
+extern int sysctl_max_task_ratio;
 extern atomic_long_t vm_committed_space;
 
 #ifdef CONFIG_SMP
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index e76d3b2..d4924c5 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -205,6 +205,9 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_SYSADMIN_RESERVED = 36, /* % memory reserved for sysadmin threads */
+	VM_MAX_TASK_RATIO = 37, /* Maximum % virtual address space allowed */
+				/* for a single memory descriptor,i.e. task */
 };
 
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e3d2c7d..89269fd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -20,6 +20,7 @@
 
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
@@ -1234,6 +1235,28 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one_hundred,
 	},
 #endif
+	{
+		.ctl_name	= VM_SYSADMIN_RESERVED,
+		.procname	= "sysadmin_reserved",
+		.data		= &sysctl_sysadmin_reserved,
+		.maxlen		= sizeof(sysctl_sysadmin_reserved),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
+	{
+		.ctl_name	= VM_MAX_TASK_RATIO,
+		.procname	= "max_task_ratio",
+		.data		= &sysctl_max_task_ratio,
+		.maxlen		= sizeof(sysctl_max_task_ratio),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 #ifdef CONFIG_SMP
 	{
 		.ctl_name	= CTL_UNNUMBERED,
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index b38423c..36aad18 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -135,6 +135,8 @@ static const struct trans_ctl_table trans_vm_table[] = {
 	{ VM_PANIC_ON_OOM,		"panic_on_oom" },
 	{ VM_VDSO_ENABLED,		"vdso_enabled" },
 	{ VM_MIN_SLAB,			"min_slab_ratio" },
+	{ VM_SYSADMIN_RESERVED,		"sysadmin_reserved" },
+	{ VM_MAX_TASK_RATIO,		"max_task_ratio" },
 
 	{}
 };
diff --git a/mm/util.c b/mm/util.c
index 5cdaa35..ebf4e0d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -282,8 +282,13 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
+/*
+ * System configurables for controlling memory overcommitting
+ */
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50;	/* default is 50% */
+int sysctl_sysadmin_reserved = 3;	/* Memory reserved for root users */
+int sysctl_max_task_ratio = (100 - 3);	/* % memory available to threads */
 atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
 
 /*
@@ -305,6 +310,7 @@ atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
 int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 {
 	unsigned long free, allowed;
+	unsigned long max_task_size;
 
 	vm_acct_memory(pages);
 
@@ -329,10 +335,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		free += global_page_state(NR_SLAB_RECLAIMABLE);
 
 		/*
-		 * Leave the last 3% for root
+		 * Leave the last bit of memory for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= (free * sysctl_sysadmin_reserved) / 100;
 
 		if (free > pages)
 			return 0;
@@ -352,10 +358,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			n -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Leave the last bit of memory for root
 		 */
 		if (!cap_sys_admin)
-			n -= n / 32;
+			n -= (n * sysctl_sysadmin_reserved) / 100;
 		free += n;
 
 		if (free > pages)
@@ -367,23 +373,29 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed = (totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * The last bit of memory is reserved for the root user
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= (allowed * sysctl_sysadmin_reserved) / 100;
 	allowed += total_swap_pages;
 
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
-	if (mm)
-		allowed -= mm->total_vm / 32;
-
 	/*
 	 * cast `allowed' as a signed long because vm_committed_space
 	 * sometimes has a negative value
 	 */
-	if (atomic_long_read(&vm_committed_space) < (long)allowed)
+	if (atomic_long_read(&vm_committed_space) >= (long)allowed)
+		goto error;
+
+	/* Don't let a single process grow too big: leave some memory for
+	 * other processes */
+	if (mm)
+		max_task_size = (allowed * sysctl_max_task_ratio) / 100;
+	else
+		max_task_size = allowed;
+
+	if (mm->total_vm <= max_task_size)
 		return 0;
+
 error:
 	vm_unacct_memory(pages);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
