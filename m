Date: Fri, 7 Sep 2007 01:17:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: add verbose_oom sysctl to dump tasklist
Message-ID: <alpine.DEB.0.9999.0709070115130.19525@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adds 'verbose_oom' sysctl to dump the tasklist and pertinent memory usage
information on an OOM killing.  Information included is pid, uid, tgid,
VM size, RSS, last cpu, oom_adj score, and name.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Applied on top of the OOM killer patchset posted to linux-mm by
 Andrea Arcangeli on August 22, 2007.

 Documentation/sysctl/vm.txt |   13 +++++++++++++
 include/linux/sysctl.h      |    1 +
 kernel/sysctl.c             |    9 +++++++++
 mm/oom_kill.c               |   26 ++++++++++++++++++++++++++
 4 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/vm:
 - min_unmapped_ratio
 - min_slab_ratio
 - panic_on_oom
+- verbose_oom
 - mmap_min_address
 - numa_zonelist_order
 
@@ -222,6 +223,18 @@ according to your policy of failover.
 
 ==============================================================
 
+verbose_oom
+
+This enables or disables extra verbosity of the OOM killer.
+
+If this is set to non-zero, the tasklist will be printed along with
+various information about each task such as pid, uid, tgid, VM size, RSS,
+last cpu, oom_adj score, and its name.
+
+The default value is 0.
+
+==============================================================
+
 mmap_min_addr
 
 This file indicates the amount of address space  which a user process will
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -207,6 +207,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_VERBOSE_OOM=36,	/* OOM killer verbosity */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -63,6 +63,7 @@ extern int print_fatal_signals;
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern int sysctl_panic_on_oom;
+extern int sysctl_verbose_oom;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -790,6 +791,14 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= VM_VERBOSE_OOM,
+		.procname	= "verbose_oom",
+		.data		= &sysctl_verbose_oom,
+		.maxlen		= sizeof(sysctl_verbose_oom),
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
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 
 int sysctl_panic_on_oom;
+int sysctl_verbose_oom;
 /* #define DEBUG */
 
 unsigned long VM_is_OOM;
@@ -146,6 +147,29 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 	return points;
 }
 
+static inline void dump_tasks(void)
+{
+	struct task_struct *g, *p;
+
+	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj name\n");
+	do_each_thread(g, p) {
+		/*
+		 * total_vm and rss sizes do not exist for tasks with a
+		 * detached mm so there's no need to report them.  They are
+		 * not eligible for OOM killing anyway.
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
 /*
  * Types of limitations to the nodes from which allocations may occur
  */
@@ -250,6 +274,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 		return;
 	}
 
+	if (sysctl_verbose_oom)
+		dump_tasks();
 	if (verbose)
 		printk(KERN_ERR "Killed process %d (%s)\n", p->pid, p->comm);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
