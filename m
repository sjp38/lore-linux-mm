Received: from mail.ccr.net (ccr@alogconduit1ah.ccr.net [208.130.159.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA26859
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 23:30:25 -0500
Subject: Re: vfork & co bugfix
References: <Pine.LNX.3.95.990110100157.7668A-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 Jan 1999 22:32:26 -0600
In-Reply-To: Linus Torvalds's message of "Sun, 10 Jan 1999 10:04:25 -0800 (PST)"
Message-ID: <m1ogo64eg5.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 10 Jan 1999, Eric W. Biederman wrote:
>> 
>> Looking at vfork in 2.2.0-pre6 I was struck by how badly 
>> looking at current, (to release a process) hacks up mmput.
>> 
>> It took a little while but eventually a case where
>> this really goes wrong.

LT> Note that the pre6 version has a number of cases where it can really screw
LT> up, don't even look at them too closely. I think I've fixed them all - it
LT> was really simple, but there was a few things I hadn't originally thought
LT> of. 

Darn it I missed the easy bug (All children waking up the parent),
and found the hard one (waking up the parent if fork fails).

The problem in summary is that mmput gets called on error where we keep
the old mm, but get rid of the new one.

This introduces a second function that only gets called upon success.

Question.  Why don't we let CLONE_VFORK be a standard clone flag?

Eric

diff -uNrX linux-ignore-files linux-pre-7/arch/i386/kernel/process.c linux-pre-7.eb1/arch/i386/kernel/process.c
--- linux-pre-7/arch/i386/kernel/process.c	Sun Jan 10 22:44:04 1999
+++ linux-pre-7.eb1/arch/i386/kernel/process.c	Sun Jan 10 22:46:08 1999
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
diff -uNrX linux-ignore-files linux-pre-7/fs/exec.c linux-pre-7.eb1/fs/exec.c
--- linux-pre-7/fs/exec.c	Fri Dec 25 17:43:18 1998
+++ linux-pre-7.eb1/fs/exec.c	Sun Jan 10 22:46:08 1999
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
diff -uNrX linux-ignore-files linux-pre-7/include/asm-alpha/processor.h linux-pre-7.eb1/include/asm-alpha/processor.h
--- linux-pre-7/include/asm-alpha/processor.h	Fri Dec 25 17:41:47 1998
+++ linux-pre-7.eb1/include/asm-alpha/processor.h	Sun Jan 10 22:46:08 1999
@@ -113,6 +113,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /* NOTE: The task struct and the stack go together!  */
 #define alloc_task_struct() \
diff -uNrX linux-ignore-files linux-pre-7/include/asm-arm/processor.h linux-pre-7.eb1/include/asm-arm/processor.h
--- linux-pre-7/include/asm-arm/processor.h	Sun Oct 11 14:16:42 1998
+++ linux-pre-7.eb1/include/asm-arm/processor.h	Sun Jan 10 22:46:08 1999
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
diff -uNrX linux-ignore-files linux-pre-7/include/asm-i386/processor.h linux-pre-7.eb1/include/asm-i386/processor.h
--- linux-pre-7/include/asm-i386/processor.h	Wed Jan  6 23:51:10 1999
+++ linux-pre-7.eb1/include/asm-i386/processor.h	Sun Jan 10 22:46:08 1999
@@ -281,6 +281,7 @@
 /* Copy and release all segment info associated with a VM */
 extern void copy_segments(int nr, struct task_struct *p, struct mm_struct * mm);
 extern void release_segments(struct mm_struct * mm);
+extern void forget_segments(struct task_struct * tsk);
 
 /*
  * FPU lazy state save handling..
diff -uNrX linux-ignore-files linux-pre-7/include/asm-m68k/processor.h linux-pre-7.eb1/include/asm-m68k/processor.h
--- linux-pre-7/include/asm-m68k/processor.h	Sun Oct 11 14:09:34 1998
+++ linux-pre-7.eb1/include/asm-m68k/processor.h	Sun Jan 10 22:46:08 1999
@@ -74,6 +74,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * Free current thread data structures etc..
diff -uNrX linux-ignore-files linux-pre-7/include/asm-mips/processor.h linux-pre-7.eb1/include/asm-mips/processor.h
--- linux-pre-7/include/asm-mips/processor.h	Fri Dec 25 17:41:48 1998
+++ linux-pre-7.eb1/include/asm-mips/processor.h	Sun Jan 10 22:46:08 1999
@@ -178,6 +178,7 @@
 /* Copy and release all segment info associated with a VM */
 #define copy_segments(nr, p, mm) do { } while(0)
 #define release_segments(mm) do { } while(0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * Return saved PC of a blocked thread.
diff -uNrX linux-ignore-files linux-pre-7/include/asm-ppc/processor.h linux-pre-7.eb1/include/asm-ppc/processor.h
--- linux-pre-7/include/asm-ppc/processor.h	Sun Oct 11 14:18:12 1998
+++ linux-pre-7.eb1/include/asm-ppc/processor.h	Sun Jan 10 22:46:08 1999
@@ -299,6 +299,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 /*
  * NOTE! The task struct and the stack go together
diff -uNrX linux-ignore-files linux-pre-7/include/asm-sparc/processor.h linux-pre-7.eb1/include/asm-sparc/processor.h
--- linux-pre-7/include/asm-sparc/processor.h	Sun Oct 11 14:13:51 1998
+++ linux-pre-7.eb1/include/asm-sparc/processor.h	Sun Jan 10 22:46:08 1999
@@ -148,6 +148,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 #ifdef __KERNEL__
 
diff -uNrX linux-ignore-files linux-pre-7/include/asm-sparc64/processor.h linux-pre-7.eb1/include/asm-sparc64/processor.h
--- linux-pre-7/include/asm-sparc64/processor.h	Fri Dec 25 17:42:26 1998
+++ linux-pre-7.eb1/include/asm-sparc64/processor.h	Sun Jan 10 22:46:08 1999
@@ -208,6 +208,7 @@
 
 #define copy_segments(nr, tsk, mm)	do { } while (0)
 #define release_segments(mm)		do { } while (0)
+#define forget_segments(tsk)		do { } while (0)
 
 #ifdef __KERNEL__
 /* Allocation and freeing of task_struct and kernel stack. */
diff -uNrX linux-ignore-files linux-pre-7/include/linux/sched.h linux-pre-7.eb1/include/linux/sched.h
--- linux-pre-7/include/linux/sched.h	Sun Jan 10 22:44:11 1999
+++ linux-pre-7.eb1/include/linux/sched.h	Sun Jan 10 22:51:41 1999
@@ -33,7 +33,7 @@
 #define CLONE_SIGHAND	0x00000800	/* set if signal handlers shared */
 #define CLONE_PID	0x00001000	/* set if pid shared */
 #define CLONE_PTRACE	0x00002000	/* set if we want to let tracing continue on the child too */
-#define CLONE_VFORK	0x00004000	/* set if the parent wants the child to wake it up on mmput */
+#define CLONE_VFORK	0x00004000	/* set if the parent wants the child to wake it up on mm_release */
 
 /*
  * These are the constant used to fake the fixed-point load-average
@@ -321,7 +321,7 @@
 #define PF_DUMPCORE	0x00000200	/* dumped core */
 #define PF_SIGNALED	0x00000400	/* killed by a signal */
 #define PF_MEMALLOC	0x00000800	/* Allocating memory */
-#define PF_VFORK	0x00001000	/* Wake up parent in mmput */
+#define PF_VFORK	0x00001000	/* Wake up parent in mm_release */
 
 #define PF_USEDFPU	0x00100000	/* task used FPU this quantum (SMP) */
 #define PF_DTRACE	0x00200000	/* delayed trace (used on m68k, i386) */
@@ -608,6 +608,8 @@
 	atomic_inc(&mm->count);
 }
 extern void mmput(struct mm_struct *);
+/* Remove the current tasks stale references to the old mm_struct */
+extern void mm_release(struct task_struct *);
 
 extern int  copy_thread(int, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
 extern void flush_thread(void);
diff -uNrX linux-ignore-files linux-pre-7/kernel/exit.c linux-pre-7.eb1/kernel/exit.c
--- linux-pre-7/kernel/exit.c	Sun Jan 10 22:42:27 1999
+++ linux-pre-7.eb1/kernel/exit.c	Sun Jan 10 22:46:09 1999
@@ -259,6 +259,7 @@
 		tsk->swappable = 0;
 		SET_PAGE_DIR(tsk, swapper_pg_dir);
 		mmput(mm);
+		mm_release(tsk);
 	}
 }
 
diff -uNrX linux-ignore-files linux-pre-7/kernel/fork.c linux-pre-7.eb1/kernel/fork.c
--- linux-pre-7/kernel/fork.c	Sun Jan 10 22:44:11 1999
+++ linux-pre-7.eb1/kernel/fork.c	Sun Jan 10 22:58:20 1999
@@ -278,17 +278,34 @@
 	return mm;
 }
 
-/*
- * Decrement the use count and release all resources for an mm.
+/* Please note the differences between mmput and mm_release.
+ * mmput is called whenever we stop holding onto a mm_struct,
+ * error success whatever.
+ *
+ * mm_release is called after a mm_struct has been removed
+ * from the current process.
+ *
+ * This difference is important for error handling, when we
+ * only half set up a mm_struct for a new process and need to restore
+ * the old one.  Because we mmput the new mm_struct before
+ * restoring the old one. . .
+ * Eric Biederman 10 January 1998
  */
-void mmput(struct mm_struct *mm)
+void mm_release(struct task_struct *tsk)
 {
+	forget_segments(tsk);
 	/* notify parent sleeping on vfork() */
-	if (current->flags & PF_VFORK) {
+	if (tsk->flags & PF_VFORK) {
 		current->flags &= ~PF_VFORK;
 		up(current->p_opptr->vfork_sem);
 	}
+}
 
+/*
+ * Decrement the use count and release all resources for an mm.
+ */
+void mmput(struct mm_struct *mm)
+{
 	if (atomic_dec_and_test(&mm->count)) {
 		release_segments(mm);
 		exit_mmap(mm);
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
