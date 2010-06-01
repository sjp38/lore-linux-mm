Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF6B86B01D2
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:18:53 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o517Ipcw025600
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:51 -0700
Received: from pwi6 (pwi6.prod.google.com [10.241.219.6])
	by kpbe15.cbf.corp.google.com with ESMTP id o517InRX031830
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:18:50 -0700
Received: by pwi6 with SMTP id 6so5161086pwi.0
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:18:49 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:18:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 09/18] oom: add forkbomb penalty to badness heuristic
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a forkbomb penalty for processes that fork an excessively large
number of children to penalize that group of tasks and not others.  A
threshold is configurable from userspace to determine how many first-
generation execve children (those with their own address spaces) a task
may have before it is considered a forkbomb.  This can be tuned by
altering the value in /proc/sys/vm/oom_forkbomb_thres, which defaults to
1000.

When a task has more than 1000 first-generation children with different
address spaces than itself, a penalty of

	(average rss of children) * (# of 1st generation execve children)
	-----------------------------------------------------------------
			oom_forkbomb_thres

is assessed.  So, for example, using the default oom_forkbomb_thres of
1000, the penalty is twice the average rss of all its execve children if
there are 2000 such tasks.  A task is considered to count toward the
threshold if its total runtime is less than one second; for 1000 of such
tasks to exist, the parent process must be forking at an extremely high
rate either erroneously or maliciously.

Even though a particular task may be designated a forkbomb and selected as
the victim, the oom killer will still kill the 1st generation execve child
with the highest badness() score in its place.  The avoids killing
important servers or system daemons.  When a web server forks a very large
number of threads for client connections, for example, it is much better
to kill one of those threads than to kill the server and make it
unresponsive.

[oleg@redhat.com: optimize task_lock when iterating children]
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/filesystems/proc.txt |    7 +++-
 Documentation/sysctl/vm.txt        |   21 ++++++++++++
 include/linux/oom.h                |    3 ++
 kernel/sysctl.c                    |    8 +++++
 mm/oom_kill.c                      |   60 ++++++++++++++++++++++++++++++++++++
 5 files changed, 97 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1248,8 +1248,11 @@ may allocate from based on an estimation of its current memory and swap use.
 For example, if a task is using all allowed memory, its badness score will be
 1000.  If it is using half of its allowed memory, its score will be 500.
 
-There is an additional factor included in the badness score: root
-processes are given 3% extra memory over other tasks.
+There are a couple of additional factor included in the badness score: root
+processes are given 3% extra memory over other tasks, and tasks which forkbomb
+an excessive number of child processes are penalized by their average size.
+The number of child processes considered to be a forkbomb is configurable
+via /proc/sys/vm/oom_forkbomb_thres (see Documentation/sysctl/vm.txt).
 
 The amount of "allowed" memory depends on the context in which the oom killer
 was called.  If it is due to the memory assigned to the allocating task's cpuset
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -46,6 +46,7 @@ Currently, these files are in /proc/sys/vm:
 - nr_trim_pages         (only if CONFIG_MMU=n)
 - numa_zonelist_order
 - oom_dump_tasks
+- oom_forkbomb_thres
 - oom_kill_allocating_task
 - overcommit_memory
 - overcommit_ratio
@@ -515,6 +516,26 @@ The default value is 1 (enabled).
 
 ==============================================================
 
+oom_forkbomb_thres
+
+This value defines how many children with a seperate address space a specific
+task may have before being considered as a possible forkbomb.  Tasks with more
+children not sharing the same address space as the parent will be penalized by a
+quantity of memory equaling
+
+	(average rss of execve children) * (# of 1st generation execve children)
+	------------------------------------------------------------------------
+				oom_forkbomb_thres
+
+in the oom killer's badness heuristic.  Such tasks may be protected with a lower
+oom_adj value (see Documentation/filesystems/proc.txt) if necessary.
+
+A value of 0 will disable forkbomb detection.
+
+The default value is 1000.
+
+==============================================================
+
 oom_kill_allocating_task
 
 This enables or disables killing the OOM-triggering task in
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -16,6 +16,9 @@
 #define OOM_SCORE_ADJ_MIN	(-1000)
 #define OOM_SCORE_ADJ_MAX	1000
 
+/* See Documentation/sysctl/vm.txt */
+#define DEFAULT_OOM_FORKBOMB_THRES	1000
+
 #ifdef __KERNEL__
 
 #include <linux/sched.h>
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1001,6 +1001,14 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "oom_forkbomb_thres",
+		.data		= &sysctl_oom_forkbomb_thres,
+		.maxlen		= sizeof(sysctl_oom_forkbomb_thres),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -35,6 +35,7 @@
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
+int sysctl_oom_forkbomb_thres = DEFAULT_OOM_FORKBOMB_THRES;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
 /*
@@ -94,6 +95,64 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 	return false;
 }
 
+/*
+ * Tasks that fork a very large number of children with seperate address spaces
+ * may be the result of a bug, user error, malicious applications, or even those
+ * with a very legitimate purpose such as a webserver.  The oom killer assesses
+ * a penalty equaling
+ *
+ *	(average rss of children) * (# of 1st generation execve children)
+ *	-----------------------------------------------------------------
+ *			sysctl_oom_forkbomb_thres
+ *
+ * for such tasks to target the parent.  oom_kill_process() will attempt to
+ * first kill a child, so there's no risk of killing an important system daemon
+ * via this method.  A web server, for example, may fork a very large number of
+ * threads to respond to client connections; it's much better to kill a child
+ * than to kill the parent, making the server unresponsive.  The goal here is
+ * to give the user a chance to recover from the error rather than deplete all
+ * memory such that the system is unusable, it's not meant to effect a forkbomb
+ * policy.
+ */
+static unsigned long oom_forkbomb_penalty(struct task_struct *tsk)
+{
+	struct task_struct *child;
+	unsigned long child_rss = 0;
+	int forkcount = 0;
+
+	if (!sysctl_oom_forkbomb_thres)
+		return 0;
+	list_for_each_entry(child, &tsk->children, sibling) {
+		struct task_cputime task_time;
+		unsigned long runtime;
+		unsigned long rss;
+
+		task_lock(child);
+		if (!child->mm || child->mm == tsk->mm) {
+			task_unlock(child);
+			continue;
+		}
+		rss = get_mm_rss(child->mm);
+		task_unlock(child);
+
+		thread_group_cputime(child, &task_time);
+		runtime = cputime_to_jiffies(task_time.utime) +
+			  cputime_to_jiffies(task_time.stime);
+		/*
+		 * Only threads that have run for less than a second are
+		 * considered toward the forkbomb penalty, these threads rarely
+		 * get to execute at all in such cases anyway.
+		 */
+		if (runtime < HZ) {
+			child_rss += rss;
+			forkcount++;
+		}
+	}
+
+	return forkcount > sysctl_oom_forkbomb_thres ?
+				(child_rss / sysctl_oom_forkbomb_thres) : 0;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -143,6 +202,7 @@ unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 	points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
 			totalpages;
 	task_unlock(p);
+	points += oom_forkbomb_penalty(p);
 
 	/*
 	 * Root processes get 3% bonus, just like the __vm_enough_memory() used

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
