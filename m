Date: Sun, 10 Jul 2005 18:58:42 -0700 (PDT)
From: Paul Jackson <pj@sgi.com>
Message-Id: <20050711015842.23183.53450.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
References: <20050711015835.23183.40213.sendpatchset@tomahawk.engr.sgi.com>
Subject: [PATCH 1/4] cpusets oom_kill and page_alloc tweaks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dinakar Guniguntala <dino@in.ibm.com>, Simon Derr <Simon.Derr@bull.net>, Erich Focht <efocht@hpce.nec.com>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch applies a few comment and code cleanups, to mm/oom_kill.c
and mm/page_alloc.c, prior to applying a patch set to improve
cpuset management of memory placement.

The first comment changed in oom_kill.c, and the first one and only
one changed in page_alloc.c, were seriously misleading.  The code
layout change in select_bad_process() makes room for adding another
condition on which a process can be spared the oom killer (see the
subsequent cpuset_nodes_overlap patch for this addition).

Also a couple typos and spellos that bugged me, while I was here.
And add documentation for cpuset flag notify_on_release.

This patch should have no material affect.

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: linux-2.6-mem_exclusive/mm/oom_kill.c
===================================================================
--- linux-2.6-mem_exclusive.orig/mm/oom_kill.c	2005-06-29 23:11:41.000000000 -0700
+++ linux-2.6-mem_exclusive/mm/oom_kill.c	2005-07-02 17:40:03.000000000 -0700
@@ -6,8 +6,8 @@
  *	for goading me into coding this file...
  *
  *  The routines in this file are used to kill a process when
- *  we're seriously out of memory. This gets called from kswapd()
- *  in linux/mm/vmscan.c when we really run out of memory.
+ *  we're seriously out of memory. This gets called from __alloc_pages()
+ *  in mm/page_alloc.c when we really run out of memory.
  *
  *  Since we won't call these routines often (on a well-configured
  *  machine) this file will double as a 'coding guide' and a signpost
@@ -26,7 +26,7 @@
 /**
  * oom_badness - calculate a numeric value for how bad this task has been
  * @p: task struct of which task we should calculate
- * @p: current uptime in seconds
+ * @uptime: current uptime in seconds
  *
  * The formula used is relatively simple and documented inline in the
  * function. The main rationale is that we want to select a good task
@@ -57,9 +57,9 @@ unsigned long badness(struct task_struct
 
 	/*
 	 * Processes which fork a lot of child processes are likely
-	 * a good choice. We add the vmsize of the childs if they
+	 * a good choice. We add the vmsize of the children if they
 	 * have an own mm. This prevents forking servers to flood the
-	 * machine with an endless amount of childs
+	 * machine with an endless amount of children
 	 */
 	list_for_each(tsk, &p->children) {
 		struct task_struct *chld;
@@ -143,28 +143,32 @@ static struct task_struct * select_bad_p
 	struct timespec uptime;
 
 	do_posix_clock_monotonic_gettime(&uptime);
-	do_each_thread(g, p)
-		/* skip the init task with pid == 1 */
-		if (p->pid > 1 && p->oomkilladj != OOM_DISABLE) {
-			unsigned long points;
+	do_each_thread(g, p) {
+		unsigned long points;
+		int releasing;
 
-			/*
-			 * This is in the process of releasing memory so wait it
-			 * to finish before killing some other task by mistake.
-			 */
-			if ((unlikely(test_tsk_thread_flag(p, TIF_MEMDIE)) || (p->flags & PF_EXITING)) &&
-			    !(p->flags & PF_DEAD))
-				return ERR_PTR(-1UL);
-			if (p->flags & PF_SWAPOFF)
-				return p;
-
-			points = badness(p, uptime.tv_sec);
-			if (points > maxpoints || !chosen) {
-				chosen = p;
-				maxpoints = points;
-			}
+		/* skip the init task with pid == 1 */
+		if (p->pid == 1)
+			continue;
+		if (p->oomkilladj == OOM_DISABLE)
+			continue;
+		/*
+		 * This is in the process of releasing memory so for wait it
+		 * to finish before killing some other task by mistake.
+		 */
+		releasing = test_tsk_thread_flag(p, TIF_MEMDIE) ||
+						p->flags & PF_EXITING;
+		if (releasing && !(p->flags & PF_DEAD))
+			return ERR_PTR(-1UL);
+		if (p->flags & PF_SWAPOFF)
+			return p;
+
+		points = badness(p, uptime.tv_sec);
+		if (points > maxpoints || !chosen) {
+			chosen = p;
+			maxpoints = points;
 		}
-	while_each_thread(g, p);
+	} while_each_thread(g, p);
 	return chosen;
 }
 
@@ -189,7 +193,8 @@ static void __oom_kill_task(task_t *p)
 		return;
 	}
 	task_unlock(p);
-	printk(KERN_ERR "Out of Memory: Killed process %d (%s).\n", p->pid, p->comm);
+	printk(KERN_ERR "Out of Memory: Killed process %d (%s).\n",
+							p->pid, p->comm);
 
 	/*
 	 * We give our sacrificial lamb high priority and access to
Index: linux-2.6-mem_exclusive/mm/page_alloc.c
===================================================================
--- linux-2.6-mem_exclusive.orig/mm/page_alloc.c	2005-06-29 23:11:41.000000000 -0700
+++ linux-2.6-mem_exclusive/mm/page_alloc.c	2005-07-02 17:40:04.000000000 -0700
@@ -898,10 +898,9 @@ rebalance:
 
 	if (likely(did_some_progress)) {
 		/*
-		 * Go through the zonelist yet one more time, keep
-		 * very high watermark here, this is only to catch
-		 * a parallel oom killing, we must fail if we're still
-		 * under heavy pressure.
+		 * Go through the zone list yet one more time, with
+		 * min watermark and trying harder.  Since try_to_free_pages
+		 * made some progress, there might be something free.
 		 */
 		for (i = 0; (z = zones[i]) != NULL; i++) {
 			if (!zone_watermark_ok(z, order, z->pages_min,
Index: linux-2.6-mem_exclusive/Documentation/cpusets.txt
===================================================================
--- linux-2.6-mem_exclusive.orig/Documentation/cpusets.txt	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/Documentation/cpusets.txt	2005-07-02 17:40:54.000000000 -0700
@@ -143,7 +143,7 @@ Cpusets extends these two mechanisms as 
 The implementation of cpusets requires a few, simple hooks
 into the rest of the kernel, none in performance critical paths:
 
- - in main/init.c, to initialize the root cpuset at system boot.
+ - in init/main.c, to initialize the root cpuset at system boot.
  - in fork and exit, to attach and detach a task from its cpuset.
  - in sched_setaffinity, to mask the requested CPUs by what's
    allowed in that tasks cpuset.
@@ -154,7 +154,7 @@ into the rest of the kernel, none in per
    and related changes in both sched.c and arch/ia64/kernel/domain.c
  - in the mbind and set_mempolicy system calls, to mask the requested
    Memory Nodes by what's allowed in that tasks cpuset.
- - in page_alloc, to restrict memory to allowed nodes.
+ - in page_alloc.c, to restrict memory to allowed nodes.
  - in vmscan.c, to restrict page recovery to the current cpuset.
 
 In addition a new file system, of type "cpuset" may be mounted,
@@ -182,6 +182,7 @@ containing the following files describin
  - mems: list of Memory Nodes in that cpuset
  - cpu_exclusive flag: is cpu placement exclusive?
  - mem_exclusive flag: is memory placement exclusive?
+ - notify_on_release: call /sbin/cpuset_release_agent on exit if set
  - tasks: list of tasks (by pid) attached to that cpuset
 
 New cpusets are created using the mkdir system call or shell
@@ -356,7 +357,8 @@ Now you want to do something with this c
 
 In this directory you can find several files:
 # ls
-cpus  cpu_exclusive  mems  mem_exclusive  tasks
+cpu_exclusive  mem_exclusive  notify_on_release
+cpus           mems           tasks
 
 Reading them will give you information about the state of this cpuset:
 the CPUs and Memory Nodes it can use, the processes that are using
Index: linux-2.6-mem_exclusive/include/linux/gfp.h
===================================================================
--- linux-2.6-mem_exclusive.orig/include/linux/gfp.h	2005-07-02 17:40:04.000000000 -0700
+++ linux-2.6-mem_exclusive/include/linux/gfp.h	2005-07-02 17:42:02.000000000 -0700
@@ -39,7 +39,7 @@ struct vm_area_struct;
 #define __GFP_COMP	0x4000u	/* Add compound page metadata */
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
-#define __GFP_NORECLAIM  0x20000u /* No realy zone reclaim during allocation */
+#define __GFP_NORECLAIM  0x20000u /* No zone reclaim during page_cache_alloc */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
