Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA17704
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 01:54:13 -0500
Subject: vfork & co bugfix
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 Jan 1999 00:48:06 -0600
Message-ID: <m14spz8vyx.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Looking at vfork in 2.2.0-pre6 I was struck by how badly 
looking at current, (to release a process) hacks up mmput.

It took a little while but eventually a case where
this really goes wrong.

In:
kernel/fork.c:copy_mm
fs/exec.c/exec_mmap

If the we can't allocate page tables, we currently erroneously
wake up a vfork waiter, and clear our segments, and set the ldt
to that of init.

To correct this I've added a companion function mm_release
that we call to remove any dangling references to the old
mm_struct of the current process.

This also ensures that segment and ldt clearing happen for every x86
process.  Not just when the previous memory area was totally freed.

Eric

diff -uNrX linux-ignore-files linux-2.2.0-pre6/arch/i386/kernel/process.c linux-2.2.0-pre6.eb1/arch/i386/kernel/process.c
--- linux-2.2.0-pre6/arch/i386/kernel/process.c	Sat Jan  9 13:33:02 1999
+++ linux-2.2.0-pre6.eb1/arch/i386/kernel/process.c	Sun Jan 10 01:26:17 1999
@@ -475,22 +475,25 @@
 
 void release_segments(struct mm_struct *mm)
 {
-	/* forget local segments */
-	__asm__ __volatile__("movl %w0,%%fs ; movl %w0,%%gs"
-		: /* no outputs */
-		: "r" (0));
 	if (mm->segments) {
 		void * ldt = mm->segments;
-
-		/*
-		 * Get the LDT entry from init_task.
-		 */
-		current->tss.ldt = _LDT(0);
-		load_ldt(0);
-
 		mm->segments = NULL;
 		vfree(ldt);
 	}
+}
+
+void forget_segments(struct task_struct *tsk)
+{
+	/* forget local segments */
+	__asm__ __volatile__("movl %w0,%%fs ; movl %w0,%%gs"
+		: /* no outputs */
+		: "r" (0));
+
+	/*
+	 * Get the LDT entry from init_task.
+	 */
+	tsk->tss.ldt = _LDT(0);
+	load_ldt(0);
 }
 
 /*
diff -uNrX linux-ignore-files linux-2.2.0-pre6/fs/exec.c linux-2.2.0-pre6.eb1/fs/exec.c
--- linux-2.2.0-pre6/fs/exec.c	Fri Dec 25 17:43:18 1998
+++ linux-2.2.0-pre6.eb1/fs/exec.c	Sun Jan 10 01:41:20 1999
@@ -383,6 +383,7 @@
 		exit_mmap(current->mm);
 		clear_page_tables(current);
 		flush_tlb_mm(current->mm);
+		mm_release(current);
 		return 0;
 	}
 
@@ -413,6 +414,7 @@
 	activate_context(current);
 	up(&mm->mmap_sem);
 	mmput(old_mm);
+	mm_release(current);
 	return 0;
 
 	/*
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-alpha/processor.h linux-2.2.0-pre6.eb1/include/asm-alpha/processor.h
--- linux-2.2.0-pre6/include/asm-alpha/processor.h	Fri Dec 25 17:41:47 1998
+++ linux-2.2.0-pre6.eb1/include/asm-alpha/processor.h	Sun Jan 10 00:38:50 1999
@@ -113,6 +113,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /* NOTE: The task struct and the stack go together!  */
 #define alloc_task_struct() \
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-arm/processor.h linux-2.2.0-pre6.eb1/include/asm-arm/processor.h
--- linux-2.2.0-pre6/include/asm-arm/processor.h	Sun Oct 11 14:16:42 1998
+++ linux-2.2.0-pre6.eb1/include/asm-arm/processor.h	Sun Jan 10 01:15:50 1999
@@ -53,11 +53,9 @@
 extern void release_thread(struct task_struct *);
 
 /* Copy and release all segment info associated with a VM */
-extern void copy_segments(int nr, struct task_struct *p, struct mm_struct * mm);
-extern void release_segments(struct mm_struct * mm);
-
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 #define init_task	(init_task_union.task)
 #define init_stack	(init_task_union.stack)
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-i386/processor.h linux-2.2.0-pre6.eb1/include/asm-i386/processor.h
--- linux-2.2.0-pre6/include/asm-i386/processor.h	Wed Jan  6 23:51:10 1999
+++ linux-2.2.0-pre6.eb1/include/asm-i386/processor.h	Sun Jan 10 01:16:30 1999
@@ -281,6 +281,7 @@
 /* Copy and release all segment info associated with a VM */
 extern void copy_segments(int nr, struct task_struct *p, struct mm_struct * mm);
 extern void release_segments(struct mm_struct * mm);
+extern void forget_segments(struct task_struct * tsk);
 
 /*
  * FPU lazy state save handling..
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-m68k/processor.h linux-2.2.0-pre6.eb1/include/asm-m68k/processor.h
--- linux-2.2.0-pre6/include/asm-m68k/processor.h	Sun Oct 11 14:09:34 1998
+++ linux-2.2.0-pre6.eb1/include/asm-m68k/processor.h	Sun Jan 10 00:41:10 1999
@@ -74,6 +74,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * Free current thread data structures etc..
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-mips/processor.h linux-2.2.0-pre6.eb1/include/asm-mips/processor.h
--- linux-2.2.0-pre6/include/asm-mips/processor.h	Fri Dec 25 17:41:48 1998
+++ linux-2.2.0-pre6.eb1/include/asm-mips/processor.h	Sun Jan 10 00:42:10 1999
@@ -178,6 +178,7 @@
 /* Copy and release all segment info associated with a VM */
 #define copy_segments(nr, p, mm) do { } while(0)
 #define release_segments(mm) do { } while(0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * Return saved PC of a blocked thread.
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-ppc/processor.h linux-2.2.0-pre6.eb1/include/asm-ppc/processor.h
--- linux-2.2.0-pre6/include/asm-ppc/processor.h	Sun Oct 11 14:18:12 1998
+++ linux-2.2.0-pre6.eb1/include/asm-ppc/processor.h	Sun Jan 10 00:42:32 1999
@@ -299,6 +299,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * NOTE! The task struct and the stack go together
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-sparc/processor.h linux-2.2.0-pre6.eb1/include/asm-sparc/processor.h
--- linux-2.2.0-pre6/include/asm-sparc/processor.h	Sun Oct 11 14:13:51 1998
+++ linux-2.2.0-pre6.eb1/include/asm-sparc/processor.h	Sun Jan 10 00:43:45 1999
@@ -148,6 +148,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 #ifdef __KERNEL__
 
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/asm-sparc64/processor.h linux-2.2.0-pre6.eb1/include/asm-sparc64/processor.h
--- linux-2.2.0-pre6/include/asm-sparc64/processor.h	Fri Dec 25 17:42:26 1998
+++ linux-2.2.0-pre6.eb1/include/asm-sparc64/processor.h	Sun Jan 10 00:44:37 1999
@@ -208,6 +208,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 #ifdef __KERNEL__
 /* Allocation and freeing of task_struct and kernel stack. */
diff -uNrX linux-ignore-files linux-2.2.0-pre6/include/linux/sched.h linux-2.2.0-pre6.eb1/include/linux/sched.h
--- linux-2.2.0-pre6/include/linux/sched.h	Sat Jan  9 13:33:21 1999
+++ linux-2.2.0-pre6.eb1/include/linux/sched.h	Sun Jan 10 01:16:53 1999
@@ -609,6 +609,8 @@
 	atomic_inc(&mm->count);
 }
 extern void mmput(struct mm_struct *);
+/* Remove the current tasks stale references to the old mm_struct */
+extern void mm_release(struct task_struct *);
 
 extern int  copy_thread(int, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
 extern void flush_thread(void);
diff -uNrX linux-ignore-files linux-2.2.0-pre6/kernel/exit.c linux-2.2.0-pre6.eb1/kernel/exit.c
--- linux-2.2.0-pre6/kernel/exit.c	Sat Jan  9 13:33:22 1999
+++ linux-2.2.0-pre6.eb1/kernel/exit.c	Sun Jan 10 00:19:03 1999
@@ -259,6 +259,7 @@
 		tsk->swappable = 0;
 		SET_PAGE_DIR(tsk, swapper_pg_dir);
 		mmput(mm);
+		mm_release(tsk);
 	}
 }
 
diff -uNrX linux-ignore-files linux-2.2.0-pre6/kernel/fork.c linux-2.2.0-pre6.eb1/kernel/fork.c
--- linux-2.2.0-pre6/kernel/fork.c	Sat Jan  9 13:33:22 1999
+++ linux-2.2.0-pre6.eb1/kernel/fork.c	Sun Jan 10 01:20:06 1999
@@ -278,14 +278,19 @@
 	return mm;
 }
 
+void mm_release(struct task_struct *tsk)
+{
+	forget_segments(tsk);
+	/* Notify parent sleeping on vfork().
+	 */
+	wake_up(&tsk->p_opptr->vfork_sleep);
+}
+
 /*
  * Decrement the use count and release all resources for an mm.
  */
 void mmput(struct mm_struct *mm)
 {
-	/* notify parent sleeping on vfork() */
-	wake_up(&current->p_opptr->vfork_sleep);
-
 	if (atomic_dec_and_test(&mm->count)) {
 		release_segments(mm);
 		exit_mmap(mm);

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
