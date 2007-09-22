Date: Sat, 22 Sep 2007 10:47:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
In-Reply-To: <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adds a new sysctl, 'oom_dump_tasks', that dumps a list of all system tasks
(excluding kernel threads) and their pid, uid, tgid, vm size, rss cpu,
oom_adj score, and name.

Helpful for determining why an OOM condition occurred and what rogue task
caused it.

It is configurable so that large systems, such as those with several
thousand tasks, do not incur a performance penalty associated with data
they may not desire.

There currently do not appear to be any other generic kernel callers that
dump all this information.  Perhaps in the future it will be worthwhile
to construct a generic task dump interface based on passing a set of
flags that specify what per-task information shall be shown.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |   21 +++++++++++++++++++++
 kernel/sysctl.c             |    9 +++++++++
 mm/oom_kill.c               |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/vm:
 - min_unmapped_ratio
 - min_slab_ratio
 - panic_on_oom
+- oom_dump_tasks
 - oom_kill_allocating_task
 - mmap_min_address
 - numa_zonelist_order
@@ -223,6 +224,26 @@ according to your policy of failover.
 
 =============================================================
 
+oom_dump_tasks
+
+This enables a system-wide task dump (excluding kernel threads) that
+includes such information as pid, uid, tgid, vm size, rss, cpu,
+oom_adj score, and name.  This is helpful to determine why the OOM
+killer was invoked and to identify the rogue task that caused it.
+
+If this is set to zero, this information is suppressed.  On very
+large systems with thousands of tasks it may not be feasible to dump
+the memory state information for each one.  Such systems should not
+be forced to incur a performance penalty in OOM conditions when the
+information may not be desired.
+
+If this is set to non-zero, this information is shown whenever the
+OOM killer actually kills a memory-hogging task.
+
+The default value is 0.
+
+=============================================================
+
 oom_kill_allocating_task
 
 This enables or disables killing the OOM-triggering task in
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -64,6 +64,7 @@ extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
+extern int sysctl_oom_dump_tasks;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -807,6 +808,14 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "oom_dump_tasks",
+		.data		= &sysctl_oom_dump_tasks,
+		.maxlen		= sizeof(sysctl_oom_dump_tasks),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_OVERCOMMIT_RATIO,
 		.procname	= "overcommit_ratio",
 		.data		= &sysctl_overcommit_ratio,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -28,6 +28,7 @@
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
+int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_mutex);
 /* #define DEBUG */
 
@@ -266,6 +267,36 @@ static struct task_struct *select_bad_process(unsigned long *ppoints)
 }
 
 /**
+ * Dumps the current memory state of all system tasks, excluding kernel threads.
+ * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
+ * score, and name.
+ *
+ * Call with tasklist_lock read-locked.
+ */
+static void dump_tasks(void)
+{
+	struct task_struct *g, *p;
+
+	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
+	       "name\n");
+	do_each_thread(g, p) {
+		/*
+		 * total_vm and rss sizes do not exist for tasks with a
+		 * detached mm so there's no need to report them.
+		 */
+		if (!p->mm)
+			continue;
+
+		task_lock(p);
+		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
+		       p->pid, p->uid, p->tgid, p->mm->total_vm,
+		       get_mm_rss(p->mm), (int)task_cpu(p), p->oomkilladj,
+		       p->comm);
+		task_unlock(p);
+	} while_each_thread(g, p);
+}
+
+/**
  * Send SIGKILL to the selected  process irrespective of  CAP_SYS_RAW_IO
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
@@ -352,6 +383,8 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			current->comm, gfp_mask, order, current->oomkilladj);
 		dump_stack();
 		show_mem();
+		if (sysctl_oom_dump_tasks)
+			dump_tasks();
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
