Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B10C76B004D
	for <linux-mm@kvack.org>; Sat,  6 Jun 2009 06:01:35 -0400 (EDT)
Subject: [patch] procfs: provide stack information for threads V0.6
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090401193135.GA12316@elte.hu>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu>
Content-Type: text/plain
Date: Sat, 06 Jun 2009 12:01:12 +0200
Message-Id: <1244282472.5042.30.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is the newest version of the formaly named "detailed stack info"
patch which give you a better overview of the userland application stack
usage, especially for embedded linux.

Currently you are only able to dump the main process/thread stack usage
which is showed in /proc/pid/status by the "VmStk" Value. But you get no
information about the consumed stack memory of the the threads.

There is an enhancement in the /proc/<pid>/{task/*,}/*maps and which
marks the vm mapping where the thread stack pointer reside with "[thread
stack xxxxxxxx]". xxxxxxxx is the start address of the stack. This is a
value information, because libpthread doesn't set the start of the stack
to the top of the mapped area, depending of the pthread usage.

A sample output of /proc/<pid>/task/<tid>/maps looks like:

08048000-08049000 r-xp 00000000 03:00 8312       /opt/z
08049000-0804a000 rw-p 00001000 03:00 8312       /opt/z
0804a000-0806b000 rw-p 00000000 00:00 0          [heap]
a7d12000-a7d13000 ---p 00000000 00:00 0 
a7d13000-a7f13000 rw-p 00000000 00:00 0          [thread stack: a7f124b4]
a7f13000-a7f14000 ---p 00000000 00:00 0 
a7f14000-a7f36000 rw-p 00000000 00:00 0 
a7f36000-a8069000 r-xp 00000000 03:00 4222       /lib/libc.so.6
a8069000-a806b000 r--p 00133000 03:00 4222       /lib/libc.so.6
a806b000-a806c000 rw-p 00135000 03:00 4222       /lib/libc.so.6
a806c000-a806f000 rw-p 00000000 00:00 0 
a806f000-a8083000 r-xp 00000000 03:00 14462      /lib/libpthread.so.0
a8083000-a8084000 r--p 00013000 03:00 14462      /lib/libpthread.so.0
a8084000-a8085000 rw-p 00014000 03:00 14462      /lib/libpthread.so.0
a8085000-a8088000 rw-p 00000000 00:00 0 
a8088000-a80a4000 r-xp 00000000 03:00 8317       /lib/ld-linux.so.2
a80a4000-a80a5000 r--p 0001b000 03:00 8317       /lib/ld-linux.so.2
a80a5000-a80a6000 rw-p 0001c000 03:00 8317       /lib/ld-linux.so.2
afaf5000-afb0a000 rw-p 00000000 00:00 0          [stack]
ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]

 
Also there is a new entry "stack usage" in /proc/<pid>/{task/*,}/status
which will you give the current stack usage in kb.

A sample output of /proc/self/status looks like:

Name:	cat
State:	R (running)
Tgid:	507
Pid:	507
.
.
.
CapBnd:	fffffffffffffeff
voluntary_ctxt_switches:	0
nonvoluntary_ctxt_switches:	0
Stack usage:	12 kB

I also fixed stack base address in /proc/<pid>/{task/*,}/stat to the
base address of the associated thread stack and not the one of the main
process. This makes more sense.

Changes since last posting:

 - Fix missing mm->mmap_sem locking in function task_show_stack_usage()
 - Code cleanup

The patch is against 2.6.30-rc7 and tested with on intel and ppc
architectures.

The update of the Documentations/filesystems/procfs.txt will follow in a
future patch, because it is outdated and a want to fix the entry for the
status, stat, maps and smaps entries.
 
ChangeLog:
 20. Jan 2009 V0.1
  - First Version for Kernel 2.6.28.1
 31. Mar 2009 V0.2
  - Ported to Kernel 2.6.29
 03. Jun 2009 V0.3
  - Ported to Kernel 2.6.30
  - Redesigned what was suggested by Ingo Molnar 
  - the thread watch monitor is gone
  - the /proc/stackmon entry is also gone
  - slim down
 04. Jun 2009 V0.4
  - Redesigned everything that was suggested by Andrew Morton 
  - slim down 
 04. Jun 2009 V0.5
  - Code cleanup
 
 fs/exec.c             |    2 +
 fs/proc/array.c       |   51 +++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/proc/task_mmu.c    |   14 +++++++++++++
 include/linux/sched.h |    1 
 kernel/fork.c         |    2 +
 5 files changed, 69 insertions(+), 1 deletion(-)

Signed-off-by: Stefani Seibold <stefani@seibold.net>

diff -u -N -r linux-2.6.30.orig/fs/exec.c linux-2.6.30/fs/exec.c
--- linux-2.6.30.orig/fs/exec.c	2009-06-04 09:29:47.000000000 +0200
+++ linux-2.6.30/fs/exec.c	2009-06-04 09:32:35.000000000 +0200
@@ -1328,6 +1328,8 @@
 	if (retval < 0)
 		goto out;
 
+	current->stack_start = current->mm->start_stack;
+
 	/* execve succeeded */
 	current->fs->in_exec = 0;
 	current->in_execve = 0;
diff -u -N -r linux-2.6.30.orig/fs/proc/array.c linux-2.6.30/fs/proc/array.c
--- linux-2.6.30.orig/fs/proc/array.c	2009-06-04 09:29:47.000000000 +0200
+++ linux-2.6.30/fs/proc/array.c	2009-06-05 21:13:30.000000000 +0200
@@ -321,6 +321,54 @@
 			p->nivcsw);
 }
 
+static inline unsigned long get_stack_usage_in_bytes(struct vm_area_struct *vma,
+					struct task_struct *p)
+{
+	unsigned long	i;
+	struct page	*page;
+	unsigned long	stkpage;
+
+	stkpage = KSTK_ESP(p) & PAGE_MASK;
+
+#ifdef CONFIG_STACK_GROWSUP
+	for (i = vma->vm_end; i-PAGE_SIZE > stkpage; i -= PAGE_SIZE) {
+
+		page = follow_page(vma, i-PAGE_SIZE, 0);
+
+		if (!IS_ERR(page) && page)
+			break;
+	}
+	return i - (p->stack_start & PAGE_MASK);
+#else
+	for (i = vma->vm_start; i+PAGE_SIZE <= stkpage; i += PAGE_SIZE) {
+
+		page = follow_page(vma, i, 0);
+
+		if (!IS_ERR(page) && page)
+			break;
+	}
+	return (p->stack_start & PAGE_MASK) - i + PAGE_SIZE;
+#endif
+}
+
+static inline void task_show_stack_usage(struct seq_file *m,
+						struct task_struct *task)
+{
+	struct vm_area_struct	*vma;
+	struct mm_struct	*mm = get_task_mm(task);
+
+	if (mm) {
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, task->stack_start);
+		if (vma)
+			seq_printf(m, "Stack usage:\t%lu kB\n",
+				get_stack_usage_in_bytes(vma, task) >> 10);
+
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+}
+
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
@@ -340,6 +388,7 @@
 	task_show_regs(m, task);
 #endif
 	task_context_switch_counts(m, task);
+	task_show_stack_usage(m, task);
 	return 0;
 }
 
@@ -481,7 +530,7 @@
 		rsslim,
 		mm ? mm->start_code : 0,
 		mm ? mm->end_code : 0,
-		(permitted && mm) ? mm->start_stack : 0,
+		(permitted) ? task->stack_start : 0,
 		esp,
 		eip,
 		/* The signal information here is obsolete.
diff -u -N -r linux-2.6.30.orig/fs/proc/task_mmu.c linux-2.6.30/fs/proc/task_mmu.c
--- linux-2.6.30.orig/fs/proc/task_mmu.c	2009-06-04 09:29:47.000000000 +0200
+++ linux-2.6.30/fs/proc/task_mmu.c	2009-06-04 22:10:47.000000000 +0200
@@ -242,6 +242,20 @@
 				} else if (vma->vm_start <= mm->start_stack &&
 					   vma->vm_end >= mm->start_stack) {
 					name = "[stack]";
+				} else {
+					unsigned long stack_start;
+					struct proc_maps_private *pmp;
+
+					pmp = m->private;
+					stack_start = pmp->task->stack_start;
+
+					if (vma->vm_start <= stack_start &&
+					    vma->vm_end >= stack_start) {
+						pad_len_spaces(m, len);
+						seq_printf(m,
+						 "[thread stack: %08lx]",
+						 stack_start);
+					}
 				}
 			} else {
 				name = "[vdso]";
diff -u -N -r linux-2.6.30.orig/include/linux/sched.h linux-2.6.30/include/linux/sched.h
--- linux-2.6.30.orig/include/linux/sched.h	2009-06-04 09:29:47.000000000 +0200
+++ linux-2.6.30/include/linux/sched.h	2009-06-04 09:32:35.000000000 +0200
@@ -1429,6 +1429,7 @@
 	/* state flags for use by tracers */
 	unsigned long trace;
 #endif
+	unsigned long stack_start;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff -u -N -r linux-2.6.30.orig/kernel/fork.c linux-2.6.30/kernel/fork.c
--- linux-2.6.30.orig/kernel/fork.c	2009-06-04 09:29:47.000000000 +0200
+++ linux-2.6.30/kernel/fork.c	2009-06-04 13:15:35.000000000 +0200
@@ -1092,6 +1092,8 @@
 	if (unlikely(current->ptrace))
 		ptrace_fork(p, clone_flags);
 
+	p->stack_start = stack_start;
+
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	sched_fork(p, clone_flags);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
