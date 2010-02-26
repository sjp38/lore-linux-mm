Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6C86B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 18:53:30 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o1QNrOX1029878
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 23:53:24 GMT
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by kpbe17.cbf.corp.google.com with ESMTP id o1QNrN7i030624
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:23 -0800
Received: by pzk11 with SMTP id 11so484987pzk.9
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:53:23 -0800 (PST)
Date: Fri, 26 Feb 2010 15:53:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2 07/10] oom: replace sysctls with quick mode
In-Reply-To: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002261551530.30830@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Two VM sysctls, oom dump_tasks and oom_kill_allocating_task, were
implemented for very large systems to avoid excessively long tasklist
scans.  The former suppresses helpful diagnostic messages that are
emitted for each thread group leader that are candidates for oom kill
including their pid, uid, vm size, rss, oom_adj value, and name; this
information is very helpful to users in understanding why a particular
task was chosen for kill over others.  The latter simply kills current,
the task triggering the oom condition, instead of iterating through the
tasklist looking for the worst offender.

Both of these sysctls are combined into one for use on the aforementioned
large systems: oom_kill_quick.  This disables the now-default
oom_dump_tasks and kills current whenever the oom killer is called.

This consolidation is possible because the audience for both tunables is
the same and there is no backwards compatibility issue in removing
oom_dump_tasks since its behavior is now default.  Since mempolicy ooms
now scan the tasklist, oom_kill_allocating_task may now find more users
to avoid the performance penalty, so it's better to unite them under one
sysctl than carry two for legacy purposes.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |   44 +++++-------------------------------------
 include/linux/oom.h         |    3 +-
 kernel/sysctl.c             |   13 ++---------
 mm/oom_kill.c               |    9 +++----
 4 files changed, 14 insertions(+), 55 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -43,9 +43,8 @@ Currently, these files are in /proc/sys/vm:
 - nr_pdflush_threads
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
-- oom_dump_tasks
 - oom_forkbomb_thres
-- oom_kill_allocating_task
+- oom_kill_quick
 - overcommit_memory
 - overcommit_ratio
 - page-cluster
@@ -470,27 +469,6 @@ this is causing problems for your system/application.
 
 ==============================================================
 
-oom_dump_tasks
-
-Enables a system-wide task dump (excluding kernel threads) to be
-produced when the kernel performs an OOM-killing and includes such
-information as pid, uid, tgid, vm size, rss, cpu, oom_adj score, and
-name.  This is helpful to determine why the OOM killer was invoked
-and to identify the rogue task that caused it.
-
-If this is set to zero, this information is suppressed.  On very
-large systems with thousands of tasks it may not be feasible to dump
-the memory state information for each one.  Such systems should not
-be forced to incur a performance penalty in OOM conditions when the
-information may not be desired.
-
-If this is set to non-zero, this information is shown whenever the
-OOM killer actually kills a memory-hogging task.
-
-The default value is 0.
-
-==============================================================
-
 oom_forkbomb_thres
 
 This value defines how many children with a seperate address space a specific
@@ -511,22 +489,12 @@ The default value is 1000.
 
 ==============================================================
 
-oom_kill_allocating_task
-
-This enables or disables killing the OOM-triggering task in
-out-of-memory situations.
-
-If this is set to zero, the OOM killer will scan through the entire
-tasklist and select a task based on heuristics to kill.  This normally
-selects a rogue memory-hogging task that frees up a large amount of
-memory when killed.
-
-If this is set to non-zero, the OOM killer simply kills the task that
-triggered the out-of-memory condition.  This avoids the expensive
-tasklist scan.
+oom_kill_quick
 
-If panic_on_oom is selected, it takes precedence over whatever value
-is used in oom_kill_allocating_task.
+When enabled, this will always kill the task that triggered the oom killer, i.e.
+the task that attempted to allocate memory that could not be found.  It also
+suppresses the tasklist dump to the kernel log whenever the oom killer is
+called.  Typically set on systems with an extremely large number of tasks.
 
 The default value is 0.
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -63,8 +63,7 @@ static inline void oom_killer_enable(void)
 }
 /* for sysctl */
 extern int sysctl_panic_on_oom;
-extern int sysctl_oom_kill_allocating_task;
-extern int sysctl_oom_dump_tasks;
+extern int sysctl_oom_kill_quick;
 extern int sysctl_oom_forkbomb_thres;
 
 #endif /* __KERNEL__*/
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -947,16 +947,9 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "oom_kill_allocating_task",
-		.data		= &sysctl_oom_kill_allocating_task,
-		.maxlen		= sizeof(sysctl_oom_kill_allocating_task),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "oom_dump_tasks",
-		.data		= &sysctl_oom_dump_tasks,
-		.maxlen		= sizeof(sysctl_oom_dump_tasks),
+		.procname	= "oom_kill_quick",
+		.data		= &sysctl_oom_kill_quick,
+		.maxlen		= sizeof(sysctl_oom_kill_quick),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,9 +32,8 @@
 #include <linux/security.h>
 
 int sysctl_panic_on_oom;
-int sysctl_oom_kill_allocating_task;
-int sysctl_oom_dump_tasks;
 int sysctl_oom_forkbomb_thres = DEFAULT_OOM_FORKBOMB_THRES;
+int sysctl_oom_kill_quick;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 /*
@@ -409,7 +408,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 	dump_stack();
 	mem_cgroup_print_oom_info(mem, p);
 	show_mem();
-	if (sysctl_oom_dump_tasks)
+	if (!sysctl_oom_kill_quick)
 		dump_tasks(mem);
 }
 
@@ -655,9 +654,9 @@ static void __out_of_memory(gfp_t gfp_mask, int order, unsigned long totalpages,
 	struct task_struct *p;
 	unsigned int points;
 
-	if (sysctl_oom_kill_allocating_task)
+	if (sysctl_oom_kill_quick)
 		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
-			NULL, "Out of memory (oom_kill_allocating_task)"))
+			NULL, "Out of memory (quick mode)"))
 			return;
 retry:
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
