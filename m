Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D44DD6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 06:56:55 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 10 Jan 2012 17:26:47 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0ABuPop4116494
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 17:26:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0ABuNvs032341
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 22:56:24 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 10 Jan 2012 17:18:42 +0530
Message-Id: <20120110114842.17610.27081.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step exception.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


Uprobes uses exception notifiers to get to know if a thread hit a
breakpoint or singlestep exception.

When a thread hits a uprobe or is singlestepping post a uprobe hit,
the uprobe exception notifier, sets its TIF_UPROBE bit, which will
then be checked on its return to userspace path (do_notify_resume()
->uprobe_notify_resume()), where the consumers handlers are run
(in task context) based on the defined filters.

Uprobe hits are thread specific and hence we need to maintain
information about if a task hit a uprobe, what uprobe was hit, the slot
where the original instruction was copied for xol so that it can be
singlestepped with appropriate fixups.

In some cases, special care is needed for instructions that are
executed out of line (xol). These are architecture specific artefacts,
such as handling RIP relative instructions on x86_64.

Since the instruction at which the uprobe was inserted is executed out
of line, architecture specific fixups are added so that the thread
continues normal execution in the presence of a uprobe.

Postpone the signals until we execute the probed insn. post_xol()
path does a recalc_sigpending() before return to user-mode, this
ensures the signal can't be lost.

Uprobes relies on DIE_DEBUG notification to notify if a singlestep is
complete.

Adds x86 specific uprobe exception notifiers and appropriate hooks
needed to determine a uprobe hit and subsequent post processing.

Add requisite x86 fixups for xol for uprobes. Specific cases needing
fixups include relative jumps (x86_64), calls, etc.

Where possible, we check and skip singlestepping the breakpointed
instructions. For now we skip single byte as well as few multibyte
nop instructions. However this can be extended to other
instructions too.

Credits to Oleg Nesterov for suggestions/patches related to signal,
breakpoint, singlestep handling code.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
(Changelog (since v8))
- verify the vma returned by find_vma (suggested by Oleg). 

(Changelog (since v7)): Resolve comments from Dan Carpenter.
- add_utask returns NULL on error.
- Handles architecture agnostic parts of a uprobe breakpoint hit and
  subsequent xol singlestepping.

Changelog (since v6)
- added x86 specific hook for aborting xol.

Changelog (since v5)
- Use srcu_raw instead of synchronize_sched
- Introduce per task srcu_id to store the srcu_id
- Modified comments.
- No more do a i386 specific enable interrupts. (Its not part of another
  patch posted separately)

 arch/x86/include/asm/thread_info.h |    2 
 arch/x86/include/asm/uprobes.h     |   17 ++
 arch/x86/kernel/signal.c           |    6 +
 arch/x86/kernel/uprobes.c          |  272 ++++++++++++++++++++++++++++++++++++
 include/linux/sched.h              |    4 +
 include/linux/uprobes.h            |   46 ++++++
 kernel/fork.c                      |    7 +
 kernel/signal.c                    |    3 
 kernel/uprobes.c                   |  275 ++++++++++++++++++++++++++++++++++++
 9 files changed, 630 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index a1fe5c1..aeb3e04 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -84,6 +84,7 @@ struct thread_info {
 #define TIF_SECCOMP		8	/* secure computing */
 #define TIF_MCE_NOTIFY		10	/* notify userspace of an MCE */
 #define TIF_USER_RETURN_NOTIFY	11	/* notify kernel of userspace return */
+#define TIF_UPROBE		12	/* breakpointed or singlestepping */
 #define TIF_NOTSC		16	/* TSC is not accessible in userland */
 #define TIF_IA32		17	/* 32bit process */
 #define TIF_FORK		18	/* ret_from_fork */
@@ -107,6 +108,7 @@ struct thread_info {
 #define _TIF_SECCOMP		(1 << TIF_SECCOMP)
 #define _TIF_MCE_NOTIFY		(1 << TIF_MCE_NOTIFY)
 #define _TIF_USER_RETURN_NOTIFY	(1 << TIF_USER_RETURN_NOTIFY)
+#define _TIF_UPROBE		(1 << TIF_UPROBE)
 #define _TIF_NOTSC		(1 << TIF_NOTSC)
 #define _TIF_IA32		(1 << TIF_IA32)
 #define _TIF_FORK		(1 << TIF_FORK)
diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 8208234..475563b 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -23,6 +23,8 @@
  *	Jim Keniston
  */
 
+#include <linux/notifier.h>
+
 typedef u8 uprobe_opcode_t;
 #define MAX_UINSN_BYTES 16
 #define UPROBES_XOL_SLOT_BYTES	128	/* to keep it cache aligned */
@@ -37,6 +39,21 @@ struct uprobe_arch_info {
 #endif
 };
 
+struct uprobe_task_arch_info {
+	unsigned long saved_trap_no;
+#ifdef CONFIG_X86_64
+	unsigned long saved_scratch_register;
+#endif
+};
+
 struct uprobe;
+
 extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
+extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
+extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern bool xol_was_trapped(struct task_struct *tsk);
+extern int uprobe_exception_notify(struct notifier_block *self,
+				       unsigned long val, void *data);
+extern void abort_xol(struct pt_regs *regs, struct uprobe *uprobe);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 54ddaeb..4fdf470 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -20,6 +20,7 @@
 #include <linux/personality.h>
 #include <linux/uaccess.h>
 #include <linux/user-return-notifier.h>
+#include <linux/uprobes.h>
 
 #include <asm/processor.h>
 #include <asm/ucontext.h>
@@ -820,6 +821,11 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
 		mce_notify_process();
 #endif /* CONFIG_X86_64 && CONFIG_X86_MCE */
 
+	if (thread_info_flags & _TIF_UPROBE) {
+		clear_thread_flag(TIF_UPROBE);
+		uprobe_notify_resume(regs);
+	}
+
 	/* deal with pending signal delivery */
 	if (thread_info_flags & _TIF_SIGPENDING)
 		do_signal(regs);
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index a980d1e..e4e0dfd 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -25,10 +25,17 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <linux/uprobes.h>
+#include <linux/uaccess.h>
 
 #include <linux/kdebug.h>
 #include <asm/insn.h>
 
+#ifdef CONFIG_X86_32
+#define is_32bit_app(tsk) 1
+#else
+#define is_32bit_app(tsk) (test_tsk_thread_flag(tsk, TIF_IA32))
+#endif
+
 /* Post-execution fixups. */
 
 /* No fixup needed */
@@ -401,3 +408,268 @@ int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe)
 	prepare_fixups(uprobe, &insn);
 	return 0;
 }
+
+/*
+ * @reg: reflects the saved state of the task
+ * @vaddr: the virtual address to jump to.
+ * Return 0 on success or a -ve number on error.
+ */
+void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
+{
+	regs->ip = vaddr;
+}
+
+#define	UPROBE_TRAP_NO		UINT_MAX
+
+/*
+ * pre_xol - prepare to execute out of line.
+ * @uprobe: the probepoint information.
+ * @regs: reflects the saved user state of @tsk.
+ *
+ * If we're emulating a rip-relative instruction, save the contents
+ * of the scratch register and store the target address in that register.
+ *
+ * Returns true if @uprobe->opcode is @bkpt_insn.
+ */
+#ifdef CONFIG_X86_64
+int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_task_arch_info *tskinfo = &current->utask->tskinfo;
+
+	tskinfo->saved_trap_no = current->thread.trap_no;
+	current->thread.trap_no = UPROBE_TRAP_NO;
+
+	regs->ip = current->utask->xol_vaddr;
+	if (uprobe->arch_info.fixups & UPROBES_FIX_RIP_AX) {
+		tskinfo->saved_scratch_register = regs->ax;
+		regs->ax = current->utask->vaddr;
+		regs->ax += uprobe->arch_info.rip_rela_target_address;
+	} else if (uprobe->arch_info.fixups & UPROBES_FIX_RIP_CX) {
+		tskinfo->saved_scratch_register = regs->cx;
+		regs->cx = current->utask->vaddr;
+		regs->cx += uprobe->arch_info.rip_rela_target_address;
+	}
+	return 0;
+}
+#else
+int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_task_arch_info *tskinfo = &current->utask->tskinfo;
+
+	tskinfo->saved_trap_no = current->thread.trap_no;
+	current->thread.trap_no = UPROBE_TRAP_NO;
+
+	regs->ip = current->utask->xol_vaddr;
+	return 0;
+}
+#endif
+
+/*
+ * Called by post_xol() to adjust the return address pushed by a call
+ * instruction executed out of line.
+ */
+static int adjust_ret_addr(unsigned long sp, long correction)
+{
+	int rasize, ncopied;
+	long ra = 0;
+
+	if (is_32bit_app(current))
+		rasize = 4;
+	else
+		rasize = 8;
+
+	ncopied = copy_from_user(&ra, (void __user *)sp, rasize);
+	if (unlikely(ncopied))
+		return -EFAULT;
+
+	ra += correction;
+	ncopied = copy_to_user((void __user *)sp, &ra, rasize);
+	if (unlikely(ncopied))
+		return -EFAULT;
+
+	return 0;
+}
+
+#ifdef CONFIG_X86_64
+static bool is_riprel_insn(struct uprobe *uprobe)
+{
+	return ((uprobe->arch_info.fixups &
+			(UPROBES_FIX_RIP_AX | UPROBES_FIX_RIP_CX)) != 0);
+}
+
+static void handle_riprel_post_xol(struct uprobe *uprobe,
+			struct pt_regs *regs, long *correction)
+{
+	if (is_riprel_insn(uprobe)) {
+		struct uprobe_task_arch_info *tskinfo;
+		tskinfo = &current->utask->tskinfo;
+
+		if (uprobe->arch_info.fixups & UPROBES_FIX_RIP_AX)
+			regs->ax = tskinfo->saved_scratch_register;
+		else
+			regs->cx = tskinfo->saved_scratch_register;
+		/*
+		 * The original instruction includes a displacement, and so
+		 * is 4 bytes longer than what we've just single-stepped.
+		 * Fall through to handle stuff like "jmpq *...(%rip)" and
+		 * "callq *...(%rip)".
+		 */
+		if (correction)
+			*correction += 4;
+	}
+}
+#else
+static void handle_riprel_post_xol(struct uprobe *uprobe,
+			struct pt_regs *regs, long *correction)
+{
+}
+#endif
+
+/*
+ * If xol insn itself traps and generates a signal(Say,
+ * SIGILL/SIGSEGV/etc), then detect the case where a singlestepped
+ * instruction jumps back to its own address. It is assumed that anything
+ * like do_page_fault/do_trap/etc sets thread.trap_no != -1.
+ *
+ * pre_xol/post_xol save/restore thread.trap_no, xol_was_trapped() simply
+ * checks that ->trap_no is not equal to UPROBE_TRAP_NO == -1 set by
+ * pre_xol().
+ */
+bool xol_was_trapped(struct task_struct *tsk)
+{
+	if (tsk->thread.trap_no != UPROBE_TRAP_NO)
+		return true;
+
+	return false;
+}
+
+/*
+ * Called after single-stepping. To avoid the SMP problems that can
+ * occur when we temporarily put back the original opcode to
+ * single-step, we single-stepped a copy of the instruction.
+ *
+ * This function prepares to resume execution after the single-step.
+ * We have to fix things up as follows:
+ *
+ * Typically, the new ip is relative to the copied instruction.  We need
+ * to make it relative to the original instruction (FIX_IP).  Exceptions
+ * are return instructions and absolute or indirect jump or call instructions.
+ *
+ * If the single-stepped instruction was a call, the return address that
+ * is atop the stack is the address following the copied instruction.  We
+ * need to make it the address following the original instruction (FIX_CALL).
+ *
+ * If the original instruction was a rip-relative instruction such as
+ * "movl %edx,0xnnnn(%rip)", we have instead executed an equivalent
+ * instruction using a scratch register -- e.g., "movl %edx,(%rax)".
+ * We need to restore the contents of the scratch register and adjust
+ * the ip, keeping in mind that the instruction we executed is 4 bytes
+ * shorter than the original instruction (since we squeezed out the offset
+ * field).  (FIX_RIP_AX or FIX_RIP_CX)
+ */
+int post_xol(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_task *utask = current->utask;
+	int result = 0;
+	long correction;
+
+	WARN_ON_ONCE(current->thread.trap_no != UPROBE_TRAP_NO);
+
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
+	correction = (long)(utask->vaddr - utask->xol_vaddr);
+	handle_riprel_post_xol(uprobe, regs, &correction);
+	if (uprobe->arch_info.fixups & UPROBES_FIX_IP)
+		regs->ip += correction;
+	if (uprobe->arch_info.fixups & UPROBES_FIX_CALL)
+		result = adjust_ret_addr(regs->sp, correction);
+	return result;
+}
+
+/*
+ * Wrapper routine for handling exceptions.
+ */
+int uprobe_exception_notify(struct notifier_block *self,
+				       unsigned long val, void *data)
+{
+	struct die_args *args = data;
+	struct pt_regs *regs = args->regs;
+	int ret = NOTIFY_DONE;
+
+	/* We are only interested in userspace traps */
+	if (regs && !user_mode_vm(regs))
+		return NOTIFY_DONE;
+
+	switch (val) {
+	case DIE_INT3:
+		/* Run your handler here */
+		if (uprobe_bkpt_notifier(regs))
+			ret = NOTIFY_STOP;
+		break;
+	case DIE_DEBUG:
+		if (uprobe_post_notifier(regs))
+			ret = NOTIFY_STOP;
+	default:
+		break;
+	}
+	return ret;
+}
+
+/*
+ * xol insn either trapped or thread has a fatal signal, so reset the
+ * instruction pointer to its probed address.
+ */
+void abort_xol(struct pt_regs *regs, struct uprobe *uprobe)
+{
+	struct uprobe_task *utask = current->utask;
+
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
+	handle_riprel_post_xol(uprobe, regs, NULL);
+	set_instruction_pointer(regs, utask->vaddr);
+}
+
+/*
+ * Skip these instructions:
+ *
+ * 0f 19 90 90 90 90 90		nopl   -0x6f6f6f70(%rax)
+ * 0f 1f 00			nopl (%rax)
+ * 0f 1f 40 00			nopl 0x0(%rax)
+ * 0f 1f 44 00 00		nopl 0x0(%rax,%rax,1)
+ * 0f 1f 80 00 00 00 00		nopl 0x0(%rax)
+ * 0f 1f 84 00 00 00 00		nopl 0x0(%rax,%rax,1)
+ * 66 0f 1f 44 00 00 00		nopw 0x0(%rax,%rax,1)
+ * 66 0f 1f 84 00 00 00		nopw 0x0(%rax,%rax,1)
+ * 66 87 c0			xchg %eax,%eax
+ * 66 90			nop
+ * 87 c0			xchg %eax,%eax
+ * 90 				nop
+ */
+
+bool can_skip_xol(struct pt_regs *regs, struct uprobe *u)
+{
+	int i;
+
+	for (i = 0; i < MAX_UINSN_BYTES; i++) {
+		if ((u->insn[i] == 0x66))
+			continue;
+
+		if (u->insn[i] == 0x90)
+			return true;
+
+		if (i == (MAX_UINSN_BYTES - 1))
+			break;
+
+		if ((u->insn[i] == 0x0f) && (u->insn[i+1] == 0x1f))
+			return true;
+
+		if ((u->insn[i] == 0x0f) && (u->insn[i+1] == 0x19))
+			return true;
+
+		if ((u->insn[i] == 0x87) && (u->insn[i+1] == 0xc0))
+			return true;
+
+		break;
+	}
+
+	u->flags &= ~UPROBES_SKIP_SSTEP;
+	return false;
+}
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1c4f3e9..bab3da7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1572,6 +1572,10 @@ struct task_struct {
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
 #endif
+#ifdef CONFIG_UPROBES
+	struct uprobe_task *utask;
+	int uprobes_srcu_id;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index f1d13fd..41037e9 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -33,7 +33,7 @@ struct vm_area_struct;
 
 typedef u8 uprobe_opcode_t;
 struct uprobe_arch_info {};
-
+struct uprobe_task_arch_info {};	/* arch specific task info */
 #define MAX_UINSN_BYTES 4
 #endif
 
@@ -44,6 +44,8 @@ struct uprobe_arch_info {};
 #define UPROBES_COPY_INSN	0x1
 /* Dont run handlers when first register/ last unregister in progress*/
 #define UPROBES_RUN_HANDLER	0x2
+/* Can skip singlestep */
+#define UPROBES_SKIP_SSTEP	0x4
 
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
@@ -69,6 +71,27 @@ struct uprobe {
 	u8			insn[MAX_UINSN_BYTES];
 };
 
+enum uprobe_task_state {
+	UTASK_RUNNING,
+	UTASK_BP_HIT,
+	UTASK_SSTEP,
+	UTASK_SSTEP_ACK,
+	UTASK_SSTEP_TRAPPED,
+};
+
+/*
+ * uprobe_task: Metadata of a task while it singlesteps.
+ */
+struct uprobe_task {
+	unsigned long xol_vaddr;
+	unsigned long vaddr;
+
+	enum uprobe_task_state state;
+	struct uprobe_task_arch_info tskinfo;
+
+	struct uprobe *active_uprobe;
+};
+
 #ifdef CONFIG_UPROBES
 extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
 							unsigned long vaddr);
@@ -79,7 +102,14 @@ extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
+extern void free_uprobe_utask(struct task_struct *tsk);
 extern int mmap_uprobe(struct vm_area_struct *vma);
+extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
+extern int uprobe_post_notifier(struct pt_regs *regs);
+extern int uprobe_bkpt_notifier(struct pt_regs *regs);
+extern void uprobe_notify_resume(struct pt_regs *regs);
+extern bool uprobe_deny_signal(void);
+extern bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -94,5 +124,19 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 {
 	return 0;
 }
+static inline void uprobe_notify_resume(struct pt_regs *regs)
+{
+}
+static inline bool uprobe_deny_signal(void)
+{
+	return false;
+}
+static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return 0;
+}
+static inline void free_uprobe_utask(struct task_struct *tsk)
+{
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index da4a6a1..7a0b7d7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -66,6 +66,7 @@
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
 #include <linux/khugepaged.h>
+#include <linux/uprobes.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -677,6 +678,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 		exit_pi_state_list(tsk);
 #endif
 
+	free_uprobe_utask(tsk);
+
 	/* Get rid of any cached register state */
 	deactivate_mm(tsk, mm);
 
@@ -1272,6 +1275,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	INIT_LIST_HEAD(&p->pi_state_list);
 	p->pi_state_cache = NULL;
 #endif
+#ifdef CONFIG_UPROBES
+	p->utask = NULL;
+	p->uprobes_srcu_id = -1;
+#endif
 	/*
 	 * sigaltstack should be cleared when sharing the same VM
 	 */
diff --git a/kernel/signal.c b/kernel/signal.c
index 2065515..a9d8a50 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2147,6 +2147,9 @@ int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 	struct signal_struct *signal = current->signal;
 	int signr;
 
+	if (unlikely(uprobe_deny_signal()))
+		return 0;
+
 relock:
 	/*
 	 * We'll jump back here after any time we were stopped in TASK_STOPPED.
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 72e8bb3..674d6da 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -29,8 +29,11 @@
 #include <linux/rmap.h>		/* anon_vma_prepare */
 #include <linux/mmu_notifier.h>	/* set_pte_at_notify */
 #include <linux/swap.h>		/* try_to_free_swap */
+#include <linux/ptrace.h>	/* user_enable_single_step */
+#include <linux/kdebug.h>	/* notifier mechanism */
 #include <linux/uprobes.h>
 
+static struct srcu_struct uprobes_srcu;
 static struct rb_root uprobes_tree = RB_ROOT;
 static DEFINE_SPINLOCK(uprobes_treelock);	/* serialize rbtree access */
 
@@ -460,6 +463,9 @@ static struct uprobe *insert_uprobe(struct uprobe *uprobe)
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	u = __insert_uprobe(uprobe);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
+
+	/* For now assume that the instruction need not be single-stepped */
+	uprobe->flags |= UPROBES_SKIP_SSTEP;
 	return u;
 }
 
@@ -495,6 +501,24 @@ static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
 	return uprobe;
 }
 
+static void handler_chain(struct uprobe *uprobe, struct pt_regs *regs)
+{
+	struct uprobe_consumer *consumer;
+
+	if (!(uprobe->flags & UPROBES_RUN_HANDLER))
+		return;
+
+	down_read(&uprobe->consumer_rwsem);
+	consumer = uprobe->consumers;
+	for (consumer = uprobe->consumers; consumer;
+					consumer = consumer->next) {
+		if (!consumer->filter ||
+				consumer->filter(consumer, current))
+			consumer->handler(consumer, regs);
+	}
+	up_read(&uprobe->consumer_rwsem);
+}
+
 /* Returns the previous consumer */
 static struct uprobe_consumer *add_consumer(struct uprobe *uprobe,
 				struct uprobe_consumer *consumer)
@@ -630,10 +654,21 @@ static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
 	set_orig_insn(mm, uprobe, (unsigned long)vaddr, true);
 }
 
+/*
+ * There could be threads that have hit the breakpoint and are entering the
+ * notifier code and trying to acquire the uprobes_treelock. The thread
+ * calling delete_uprobe() that is removing the uprobe from the rb_tree can
+ * race with these threads and might acquire the uprobes_treelock compared
+ * to some of the breakpoint hit threads. In such a case, the breakpoint hit
+ * threads will not find the uprobe. Hence wait till the current breakpoint
+ * hit threads acquire the uprobes_treelock before the uprobe is removed
+ * from the rbtree.
+ */
 static void delete_uprobe(struct uprobe *uprobe)
 {
 	unsigned long flags;
 
+	synchronize_srcu(&uprobes_srcu);
 	spin_lock_irqsave(&uprobes_treelock, flags);
 	rb_erase(&uprobe->rb_node, &uprobes_tree);
 	spin_unlock_irqrestore(&uprobes_treelock, flags);
@@ -957,6 +992,243 @@ int mmap_uprobe(struct vm_area_struct *vma)
 	return ret;
 }
 
+/**
+ * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
+ * @regs: Reflects the saved state of the task after it has hit a breakpoint
+ * instruction.
+ * Return the address of the breakpoint instruction.
+ */
+unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
+}
+
+/*
+ * Called with no locks held.
+ * Called in context of a exiting or a exec-ing thread.
+ */
+void free_uprobe_utask(struct task_struct *tsk)
+{
+	struct uprobe_task *utask = tsk->utask;
+
+	if (tsk->uprobes_srcu_id != -1)
+		srcu_read_unlock_raw(&uprobes_srcu, tsk->uprobes_srcu_id);
+
+	if (!utask)
+		return;
+
+	if (utask->active_uprobe)
+		put_uprobe(utask->active_uprobe);
+
+	kfree(utask);
+	tsk->utask = NULL;
+}
+
+/*
+ * Allocate a uprobe_task object for the task.
+ * Called when the thread hits a breakpoint for the first time.
+ *
+ * Returns:
+ * - pointer to new uprobe_task on success
+ * - NULL otherwise
+ */
+static struct uprobe_task *add_utask(void)
+{
+	struct uprobe_task *utask;
+
+	utask = kzalloc(sizeof *utask, GFP_KERNEL);
+	if (unlikely(utask == NULL))
+		return NULL;
+
+	utask->active_uprobe = NULL;
+	current->utask = utask;
+	return utask;
+}
+
+/* Prepare to single-step probed instruction out of line. */
+static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
+				unsigned long vaddr)
+{
+	return -EFAULT;
+}
+
+/*
+ * If we are singlestepping, then ensure this thread is not connected to
+ * non-fatal signals until completion of singlestep.  When xol insn itself
+ * triggers the signal,  restart the original insn even if the task is
+ * already SIGKILL'ed (since coredump should report the correct ip).  This
+ * is even more important if the task has a handler for SIGSEGV/etc, The
+ * _same_ instruction should be repeated again after return from the signal
+ * handler, and SSTEP can never finish in this case.
+ */
+bool uprobe_deny_signal(void)
+{
+	struct task_struct *tsk = current;
+	struct uprobe_task *utask = tsk->utask;
+
+	if (likely(!utask || !utask->active_uprobe))
+		return false;
+
+	WARN_ON_ONCE(utask->state != UTASK_SSTEP);
+
+	if (signal_pending(tsk)) {
+		spin_lock_irq(&tsk->sighand->siglock);
+		clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
+		spin_unlock_irq(&tsk->sighand->siglock);
+
+		if (__fatal_signal_pending(tsk) || xol_was_trapped(tsk)) {
+			utask->state = UTASK_SSTEP_TRAPPED;
+			set_tsk_thread_flag(tsk, TIF_UPROBE);
+			set_tsk_thread_flag(tsk, TIF_NOTIFY_RESUME);
+		}
+	}
+
+	return true;
+}
+
+bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u)
+{
+	u->flags &= ~UPROBES_SKIP_SSTEP;
+	return false;
+}
+
+/*
+ * On breakpoint hit, breakpoint notifier sets the TIF_UPROBE flag.  (and on
+ * subsequent probe hits on the thread sets the state to UTASK_BP_HIT) and
+ * allows the thread to return from interrupt.  While returning to
+ * userspace, thread noticies the TIF_UPROBE flag and calls
+ * uprobe_notify_resume(). uprobe_notify_resume will run the handler and ask
+ * the thread to singlestep.
+ *
+ * On subsequent singlestep exception, singlestep notifier sets the
+ * TIF_UPROBE flag and also sets the state to UTASK_SSTEP_ACK and allows the
+ * thread to return from interrupt. While returning to userspace, thread
+ * notices the TIF_UPROBE and calls uprobe_notify_resume().
+ * uprobe_notify_resume disables singlestep and performs the required
+ * fix-ups.
+ *
+ * All non-fatal signals cannot interrupt thread while the thread singlesteps.
+ */
+void uprobe_notify_resume(struct pt_regs *regs)
+{
+	struct vm_area_struct *vma;
+	struct uprobe_task *utask;
+	struct mm_struct *mm;
+	struct uprobe *u = NULL;
+	unsigned long probept;
+
+	utask = current->utask;
+	mm = current->mm;
+	if (!utask || utask->state == UTASK_BP_HIT) {
+		probept = get_uprobe_bkpt_addr(regs);
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, probept);
+		if (vma && vma->vm_start <= probept && valid_vma(vma, false))
+			u = find_uprobe(vma->vm_file->f_mapping->host,
+					probept - vma->vm_start +
+					(vma->vm_pgoff << PAGE_SHIFT));
+
+		srcu_read_unlock_raw(&uprobes_srcu,
+					current->uprobes_srcu_id);
+		current->uprobes_srcu_id = -1;
+		up_read(&mm->mmap_sem);
+		if (!u)
+			/* No matching uprobe; signal SIGTRAP. */
+			goto cleanup_ret;
+		if (!utask) {
+			utask = add_utask();
+			/* Cannot Allocate; re-execute the instruction. */
+			if (!utask)
+				goto cleanup_ret;
+		}
+		utask->active_uprobe = u;
+		handler_chain(u, regs);
+
+		if (u->flags & UPROBES_SKIP_SSTEP && can_skip_xol(regs, u))
+			goto cleanup_ret;
+
+		utask->state = UTASK_SSTEP;
+		if (!pre_ssout(u, regs, probept))
+			user_enable_single_step(current);
+		else
+			/* Cannot Singlestep; re-execute the instruction. */
+			goto cleanup_ret;
+	} else {
+		u = utask->active_uprobe;
+		if (utask->state == UTASK_SSTEP_ACK)
+			post_xol(u, regs);
+		else if (utask->state == UTASK_SSTEP_TRAPPED)
+			abort_xol(regs, u);
+		else
+			WARN_ON_ONCE(1);
+
+		put_uprobe(u);
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+		user_disable_single_step(current);
+
+		spin_lock_irq(&current->sighand->siglock);
+		recalc_sigpending(); /* see uprobe_deny_signal() */
+		spin_unlock_irq(&current->sighand->siglock);
+	}
+	return;
+
+cleanup_ret:
+	if (utask) {
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+	}
+	if (u) {
+		if (!(u->flags & UPROBES_SKIP_SSTEP))
+			set_instruction_pointer(regs, probept);
+
+		put_uprobe(u);
+	} else
+		send_sig(SIGTRAP, current, 0);
+}
+
+/*
+ * uprobe_bkpt_notifier gets called from interrupt context as part of
+ * notifier mechanism. Set TIF_UPROBE flag and indicate breakpoint hit.
+ */
+int uprobe_bkpt_notifier(struct pt_regs *regs)
+{
+	struct uprobe_task *utask;
+
+	if (!current->mm)
+		return 0;
+
+	utask = current->utask;
+	if (utask)
+		utask->state = UTASK_BP_HIT;
+
+	set_thread_flag(TIF_UPROBE);
+	current->uprobes_srcu_id = srcu_read_lock_raw(&uprobes_srcu);
+	return 1;
+}
+
+/*
+ * uprobe_post_notifier gets called in interrupt context as part of notifier
+ * mechanism. Set TIF_UPROBE flag and indicate completion of singlestep.
+ */
+int uprobe_post_notifier(struct pt_regs *regs)
+{
+	struct uprobe_task *utask = current->utask;
+
+	if (!current->mm || !utask || !utask->active_uprobe)
+		/* task is currently not uprobed */
+		return 0;
+
+	utask->state = UTASK_SSTEP_ACK;
+	set_thread_flag(TIF_UPROBE);
+	return 1;
+}
+
+struct notifier_block uprobe_exception_nb = {
+	.notifier_call = uprobe_exception_notify,
+	.priority = INT_MAX - 1,	/* notified after kprobes, kgdb */
+};
+
 static int __init init_uprobes(void)
 {
 	int i;
@@ -965,7 +1237,8 @@ static int __init init_uprobes(void)
 		mutex_init(&uprobes_mutex[i]);
 		mutex_init(&uprobes_mmap_mutex[i]);
 	}
-	return 0;
+	init_srcu_struct(&uprobes_srcu);
+	return register_die_notifier(&uprobe_exception_nb);
 }
 
 static void __exit exit_uprobes(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
