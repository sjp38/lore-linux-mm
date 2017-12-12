Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 84D416B0266
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:49 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y15so12636258wrc.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:49 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 67si34400wmx.259.2017.12.12.09.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:48 -0800 (PST)
Message-Id: <20171212173334.176469949@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:32 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 11/16] x86/ldt: Force access bit for CS/SS
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=x86-ldt--Force-access-bit-for-CS-SS.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

When mapping the LDT RO the hardware will typically generate write faults
on first use. These faults can be trapped and the backing pages can be
modified by the kernel.

There is one exception; IRET will immediately load CS/SS and unrecoverably
#GP. To avoid this issue access the LDT descriptors used by CS/SS before
the IRET to userspace.

For this use LAR, which is a safe operation in that it will happily consume
an invalid LDT descriptor without traps. It gets the CPU to load the
descriptor and observes the (preset) ACCESS bit.

So far none of the obvious candidates like dosemu/wine/etc. do care about
the ACCESS bit at all, so it should be rather safe to enforce it.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/entry/common.c            |    8 ++++-
 arch/x86/include/asm/desc.h        |    2 +
 arch/x86/include/asm/mmu_context.h |   53 +++++++++++++++++++++++--------------
 arch/x86/include/asm/thread_info.h |    4 ++
 arch/x86/kernel/cpu/common.c       |    4 +-
 arch/x86/kernel/ldt.c              |   30 ++++++++++++++++++++
 arch/x86/mm/tlb.c                  |    2 -
 arch/x86/power/cpu.c               |    2 -
 8 files changed, 78 insertions(+), 27 deletions(-)

--- a/arch/x86/entry/common.c
+++ b/arch/x86/entry/common.c
@@ -30,6 +30,7 @@
 #include <asm/vdso.h>
 #include <linux/uaccess.h>
 #include <asm/cpufeature.h>
+#include <asm/mmu_context.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/syscalls.h>
@@ -130,8 +131,8 @@ static long syscall_trace_enter(struct p
 	return ret ?: regs->orig_ax;
 }
 
-#define EXIT_TO_USERMODE_LOOP_FLAGS				\
-	(_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_UPROBE |	\
+#define EXIT_TO_USERMODE_LOOP_FLAGS					\
+	(_TIF_SIGPENDING | _TIF_NOTIFY_RESUME | _TIF_UPROBE | _TIF_LDT |\
 	 _TIF_NEED_RESCHED | _TIF_USER_RETURN_NOTIFY | _TIF_PATCH_PENDING)
 
 static void exit_to_usermode_loop(struct pt_regs *regs, u32 cached_flags)
@@ -171,6 +172,9 @@ static void exit_to_usermode_loop(struct
 		/* Disable IRQs and retry */
 		local_irq_disable();
 
+		if (cached_flags & _TIF_LDT)
+			ldt_exit_user(regs);
+
 		cached_flags = READ_ONCE(current_thread_info()->flags);
 
 		if (!(cached_flags & EXIT_TO_USERMODE_LOOP_FLAGS))
--- a/arch/x86/include/asm/desc.h
+++ b/arch/x86/include/asm/desc.h
@@ -20,6 +20,8 @@ static inline void fill_ldt(struct desc_
 
 	desc->type		= (info->read_exec_only ^ 1) << 1;
 	desc->type	       |= info->contents << 2;
+	/* Set ACCESS bit */
+	desc->type	       |= 1;
 
 	desc->s			= 1;
 	desc->dpl		= 0x3;
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -57,24 +57,34 @@ struct ldt_struct {
 /*
  * Used for LDT copy/destruction.
  */
-static inline void init_new_context_ldt(struct mm_struct *mm)
+static inline void init_new_context_ldt(struct task_struct *task,
+					struct mm_struct *mm)
 {
 	mm->context.ldt = NULL;
 	init_rwsem(&mm->context.ldt_usr_sem);
+	/*
+	 * Set the TIF flag unconditonally as in ldt_dup_context() the new
+	 * task pointer is not available. In case there is no LDT this is a
+	 * nop on the first exit to user space.
+	 */
+	set_tsk_thread_flag(task, TIF_LDT);
 }
 int ldt_dup_context(struct mm_struct *oldmm, struct mm_struct *mm);
+void ldt_exit_user(struct pt_regs *regs);
 void destroy_context_ldt(struct mm_struct *mm);
 #else	/* CONFIG_MODIFY_LDT_SYSCALL */
-static inline void init_new_context_ldt(struct mm_struct *mm) { }
+static inline void init_new_context_ldt(struct task_struct *task,
+					struct mm_struct *mm) { }
 static inline int ldt_dup_context(struct mm_struct *oldmm,
 				  struct mm_struct *mm)
 {
 	return 0;
 }
-static inline void destroy_context_ldt(struct mm_struct *mm) {}
+static inline void ldt_exit_user(struct pt_regs *regs) { }
+static inline void destroy_context_ldt(struct mm_struct *mm) { }
 #endif
 
-static inline void load_mm_ldt(struct mm_struct *mm)
+static inline void load_mm_ldt(struct mm_struct *mm, struct task_struct *tsk)
 {
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
@@ -83,28 +93,31 @@ static inline void load_mm_ldt(struct mm
 	ldt = READ_ONCE(mm->context.ldt);
 
 	/*
-	 * Any change to mm->context.ldt is followed by an IPI to all
-	 * CPUs with the mm active.  The LDT will not be freed until
-	 * after the IPI is handled by all such CPUs.  This means that,
-	 * if the ldt_struct changes before we return, the values we see
-	 * will be safe, and the new values will be loaded before we run
-	 * any user code.
+	 * Clear LDT if the mm does not have it set or if this is a kernel
+	 * thread which might temporarily use the mm of a user process via
+	 * use_mm(). If the next task uses LDT then set it up and set
+	 * TIF_LDT so it will touch the new LDT on exit to user space.
 	 *
-	 * NB: don't try to convert this to use RCU without extreme care.
-	 * We would still need IRQs off, because we don't want to change
-	 * the local LDT after an IPI loaded a newer value than the one
-	 * that we can see.
+	 * This code is run with interrupts disabled so it is serialized
+	 * against the IPI from ldt_install_mm().
 	 */
-	if (unlikely(ldt && !(current->flags & PF_KTHREAD))
-		set_ldt(ldt->entries, ldt->nr_entries);
-	else
+	if (likely(!ldt || (tsk->flags & PF_KTHREAD))) {
 		clear_LDT();
+	} else {
+		set_ldt(ldt->entries, ldt->nr_entries);
+		set_tsk_thread_flag(tsk, TIF_LDT);
+	}
 #else
+	/*
+	 * FIXME: This wants a comment why this actually does anything at
+	 * all when the syscall is disabled.
+	 */
 	clear_LDT();
 #endif
 }
 
-static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next)
+static inline void switch_ldt(struct mm_struct *prev, struct mm_struct *next,
+			      struct task_struct *tsk)
 {
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	/*
@@ -126,7 +139,7 @@ static inline void switch_ldt(struct mm_
 	 */
 	if (unlikely((unsigned long)prev->context.ldt |
 		     (unsigned long)next->context.ldt))
-		load_mm_ldt(next);
+		load_mm_ldt(next, tsk);
 #endif
 
 	DEBUG_LOCKS_WARN_ON(preemptible());
@@ -150,7 +163,7 @@ static inline int init_new_context(struc
 		mm->context.execute_only_pkey = -1;
 	}
 #endif
-	init_new_context_ldt(mm);
+	init_new_context_ldt(tsk, mm);
 	return 0;
 }
 static inline void destroy_context(struct mm_struct *mm)
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -83,6 +83,7 @@ struct thread_info {
 #define TIF_SYSCALL_EMU		6	/* syscall emulation active */
 #define TIF_SYSCALL_AUDIT	7	/* syscall auditing active */
 #define TIF_SECCOMP		8	/* secure computing */
+#define TIF_LDT			9	/* Populate LDT after fork */
 #define TIF_USER_RETURN_NOTIFY	11	/* notify kernel of userspace return */
 #define TIF_UPROBE		12	/* breakpointed or singlestepping */
 #define TIF_PATCH_PENDING	13	/* pending live patching update */
@@ -109,6 +110,7 @@ struct thread_info {
 #define _TIF_SYSCALL_EMU	(1 << TIF_SYSCALL_EMU)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1 << TIF_SECCOMP)
+#define _TIF_LDT		(1 << TIF_LDT)
 #define _TIF_USER_RETURN_NOTIFY	(1 << TIF_USER_RETURN_NOTIFY)
 #define _TIF_UPROBE		(1 << TIF_UPROBE)
 #define _TIF_PATCH_PENDING	(1 << TIF_PATCH_PENDING)
@@ -141,7 +143,7 @@ struct thread_info {
 	 _TIF_NEED_RESCHED | _TIF_SINGLESTEP | _TIF_SYSCALL_EMU |	\
 	 _TIF_SYSCALL_AUDIT | _TIF_USER_RETURN_NOTIFY | _TIF_UPROBE |	\
 	 _TIF_PATCH_PENDING | _TIF_NOHZ | _TIF_SYSCALL_TRACEPOINT |	\
-	 _TIF_FSCHECK)
+	 _TIF_FSCHECK | _TIF_LDT)
 
 /* flags to check in __switch_to() */
 #define _TIF_WORK_CTXSW							\
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1602,7 +1602,7 @@ void cpu_init(void)
 	set_tss_desc(cpu, t);
 	load_TR_desc();
 
-	load_mm_ldt(&init_mm);
+	load_mm_ldt(&init_mm, current);
 
 	clear_all_debug_regs();
 	dbg_restore_debug_regs();
@@ -1660,7 +1660,7 @@ void cpu_init(void)
 	set_tss_desc(cpu, t);
 	load_TR_desc();
 
-	load_mm_ldt(&init_mm);
+	load_mm_ldt(&init_mm, current);
 
 	t->x86_tss.io_bitmap_base = offsetof(struct tss_struct, io_bitmap);
 
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -164,6 +164,36 @@ int ldt_dup_context(struct mm_struct *ol
 }
 
 /*
+ * Touching the LDT entries with LAR makes sure that the CPU "caches" the
+ * ACCESSED bit in the LDT entry which is already set when the entry is
+ * stored.
+ */
+static inline void ldt_touch_seg(unsigned long seg)
+{
+	u16 ar, sel = (u16)seg & ~SEGMENT_RPL_MASK;
+
+	if (!(seg & SEGMENT_LDT))
+		return;
+
+	asm volatile ("lar %[sel], %[ar]"
+			: [ar] "=R" (ar)
+			: [sel] "R" (sel));
+}
+
+void ldt_exit_user(struct pt_regs *regs)
+{
+	struct mm_struct *mm = current->mm;
+
+	clear_tsk_thread_flag(current, TIF_LDT);
+
+	if (!mm || !mm->context.ldt)
+		return;
+
+	ldt_touch_seg(regs->cs);
+	ldt_touch_seg(regs->ss);
+}
+
+/*
  * No need to lock the MM as we are the last user
  *
  * 64bit: Don't touch the LDT register - we're already in the next thread.
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -219,7 +219,7 @@ void switch_mm_irqs_off(struct mm_struct
 	}
 
 	load_mm_cr4(next);
-	switch_ldt(real_prev, next);
+	switch_ldt(real_prev, next, tsk);
 }
 
 /*
--- a/arch/x86/power/cpu.c
+++ b/arch/x86/power/cpu.c
@@ -180,7 +180,7 @@ static void fix_processor_context(void)
 	syscall_init();				/* This sets MSR_*STAR and related */
 #endif
 	load_TR_desc();				/* This does ltr */
-	load_mm_ldt(current->active_mm);	/* This does lldt */
+	load_mm_ldt(current->active_mm, current);
 	initialize_tlbstate_and_flush();
 
 	fpu__resume_cpu();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
