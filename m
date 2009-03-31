Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC8F6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:52:28 -0400 (EDT)
Subject: Detailed Stack Information Patch [1/3]
From: Stefani Seibold <stefani@seibold.net>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 16:58:25 +0200
Message-Id: <1238511505.364.61.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

diff -u -N -r linux-2.6.29.orig/fs/exec.c linux-2.6.29/fs/exec.c
--- linux-2.6.29.orig/fs/exec.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/fs/exec.c	2009-03-31 16:02:55.000000000 +0200
@@ -1336,6 +1336,10 @@
 	if (retval < 0)
 		goto out;
 
+#ifdef CONFIG_PROC_STACK
+	current->stack_start = current->mm->start_stack;
+#endif
+
 	/* execve succeeded */
 	mutex_unlock(&current->cred_exec_mutex);
 	acct_update_integrals(current);
diff -u -N -r linux-2.6.29.orig/fs/proc/array.c linux-2.6.29/fs/proc/array.c
--- linux-2.6.29.orig/fs/proc/array.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/fs/proc/array.c	2009-03-31 16:00:19.000000000 +0200
@@ -320,6 +320,25 @@
 			p->nivcsw);
 }
 
+#ifdef CONFIG_PROC_STACK
+static inline void task_show_stack_usage(struct seq_file *m,
+						struct task_struct *p)
+{
+	unsigned long		cur_stack;
+	unsigned long		base_page;
+
+	base_page = KSTK_ESP(p) >> PAGE_SHIFT;
+
+#ifdef CONFIG_STACK_GROWSUP
+	cur_stack = base_page-(p->stack_start >> PAGE_SHIFT);
+#else
+	cur_stack = (p->stack_start >> PAGE_SHIFT)-base_page;
+#endif
+	seq_printf(m,	"stack usage:\t%lu kB\n",
+		(cur_stack + 1) << (PAGE_SHIFT-10));
+}
+#endif
+
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
@@ -339,6 +358,9 @@
 	task_show_regs(m, task);
 #endif
 	task_context_switch_counts(m, task);
+#ifdef CONFIG_PROC_STACK
+	task_show_stack_usage(m, task);
+#endif
 	return 0;
 }
 
diff -u -N -r linux-2.6.29.orig/fs/proc/task_mmu.c linux-2.6.29/fs/proc/task_mmu.c
--- linux-2.6.29.orig/fs/proc/task_mmu.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/fs/proc/task_mmu.c	2009-03-31 16:00:19.000000000 +0200
@@ -240,6 +240,18 @@
 				} else if (vma->vm_start <= mm->start_stack &&
 					   vma->vm_end >= mm->start_stack) {
 					name = "[stack]";
+#ifdef CONFIG_PROC_STACK
+				} else {
+					unsigned long stack_start;
+
+					stack_start =
+						((struct proc_maps_private *)
+						 m->private)->task->stack_start;
+
+					if (vma->vm_start <= stack_start && 
+					    vma->vm_end >= stack_start)
+						name="[thread stack]";
+#endif
 				}
 			} else {
 				name = "[vdso]";
diff -u -N -r linux-2.6.29.orig/include/linux/sched.h linux-2.6.29/include/linux/sched.h
--- linux-2.6.29.orig/include/linux/sched.h	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/include/linux/sched.h	2009-03-31 16:00:45.000000000 +0200
@@ -1417,6 +1417,9 @@
 	/* state flags for use by tracers */
 	unsigned long trace;
 #endif
+#ifdef CONFIG_PROC_STACK
+	unsigned long stack_start;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff -u -N -r linux-2.6.29.orig/init/Kconfig linux-2.6.29/init/Kconfig
--- linux-2.6.29.orig/init/Kconfig	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/init/Kconfig	2009-03-31 16:00:19.000000000 +0200
@@ -952,6 +952,18 @@
 
 source "arch/Kconfig"
 
+config PROC_STACK
+ 	default y
+	depends on PROC_FS && MMU
+	bool "Enable /proc/<pid> stack monitoring" if EMBEDDED
+ 	help
+	  This enables monitoring of process and thread stack utilization.
+
+	  The /proc/pid/maps, /proc/pid/smaps, /proc/pid/status and the
+	  /proc/pid/task/pid pedants will be extended by the stack information.
+	  Disabling these interfaces will reduce the size of the kernel by
+	  approximately 1kb.
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT
diff -u -N -r linux-2.6.29.orig/kernel/fork.c linux-2.6.29/kernel/fork.c
--- linux-2.6.29.orig/kernel/fork.c	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/kernel/fork.c	2009-03-31 16:00:19.000000000 +0200
@@ -1098,6 +1098,11 @@
 	if (unlikely(current->ptrace))
 		ptrace_fork(p, clone_flags);
 
+#ifdef CONFIG_PROC_STACK
+	p->stack_start = (stack_start == KSTK_ESP(current)) ?
+		current->stack_start : stack_start;
+#endif
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	sched_fork(p, clone_flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
