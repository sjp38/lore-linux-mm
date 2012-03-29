Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1012D6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 15:14:49 -0400 (EDT)
Date: Thu, 29 Mar 2012 12:14:01 -0700
Message-Id: <201203291914.q2TJE18K004920@terminus.zytor.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Subject: [GIT PULL] x86 cleanups for 3.4-rc1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Christoph Hellwig <hch@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Ingo Molnar <mingo@eltu.hu>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>

Hi Linus,

The following changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git x86-cleanups-for-linus

The head of this tree is ef334a20d84f52407a8a2afd02ddeaecbef0ad3d.

This tree is *on top of* the x86/x32 push (x86-x32-for-linus); I was
expecting to push it out after the x32 tree was upstream, but since
you have not yet pulled it I figure I would get this in your queue.

The biggest textual change is the cleanup to use symbolic constants
for x86 trap values.

The only *functional* change and the reason for the x86/x32 dependency
is the move of is_ia32_task() into <asm/thread_info.h> so that it can
be used in other code that needs to understand if a system call comes
from the compat entry point (and therefore uses i386 system call
numbers) or not.  One intended user for that is the BPF system call
filter.  Moving it out of <asm/compat.h> means we can define it
unconditionally, returning always true on i386.

Ingo Molnar (1):
      Merge branch 'x86/x32' into x86/cleanups

Kees Cook (1):
      x86: Use enum instead of literals for trap values

Srikar Dronamraju (2):
      x86: Rename trap_no to trap_nr in thread_struct
      x86: Move is_ia32_task to asm/thread_info.h from asm/compat.h

 arch/x86/ia32/ia32_signal.c        |    2 +-
 arch/x86/include/asm/compat.h      |    9 ---
 arch/x86/include/asm/processor.h   |    2 +-
 arch/x86/include/asm/thread_info.h |   12 +++
 arch/x86/include/asm/traps.h       |   25 +++++++
 arch/x86/kernel/dumpstack.c        |    2 +-
 arch/x86/kernel/irqinit.c          |    2 +-
 arch/x86/kernel/ptrace.c           |    3 +-
 arch/x86/kernel/signal.c           |    2 +-
 arch/x86/kernel/traps.c            |  133 +++++++++++++++++++-----------------
 arch/x86/kernel/vm86_32.c          |    2 +-
 arch/x86/kernel/vsyscall_64.c      |    2 +-
 arch/x86/math-emu/fpu_entry.c      |    5 +-
 arch/x86/mm/fault.c                |   10 ++--
 14 files changed, 124 insertions(+), 87 deletions(-)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index bc09ed2..45b4fdd 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -345,7 +345,7 @@ static int ia32_setup_sigcontext(struct sigcontext_ia32 __user *sc,
 		put_user_ex(regs->dx, &sc->dx);
 		put_user_ex(regs->cx, &sc->cx);
 		put_user_ex(regs->ax, &sc->ax);
-		put_user_ex(current->thread.trap_no, &sc->trapno);
+		put_user_ex(current->thread.trap_nr, &sc->trapno);
 		put_user_ex(current->thread.error_code, &sc->err);
 		put_user_ex(regs->ip, &sc->ip);
 		put_user_ex(regs->cs, (unsigned int __user *)&sc->cs);
diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index 355edc0..d680579 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -235,15 +235,6 @@ static inline void __user *arch_compat_alloc_user_space(long len)
 	return (void __user *)round_down(sp - len, 16);
 }
 
-static inline bool is_ia32_task(void)
-{
-#ifdef CONFIG_IA32_EMULATION
-	if (current_thread_info()->status & TS_COMPAT)
-		return true;
-#endif
-	return false;
-}
-
 static inline bool is_x32_task(void)
 {
 #ifdef CONFIG_X86_X32_ABI
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 02ce0b3..f6d0d2e 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -453,7 +453,7 @@ struct thread_struct {
 	unsigned long           ptrace_dr7;
 	/* Fault info: */
 	unsigned long		cr2;
-	unsigned long		trap_no;
+	unsigned long		trap_nr;
 	unsigned long		error_code;
 	/* floating point and extended processor state */
 	struct fpu		fpu;
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index af1db7e..ad6df8c 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -266,6 +266,18 @@ static inline void set_restore_sigmask(void)
 	ti->status |= TS_RESTORE_SIGMASK;
 	set_bit(TIF_SIGPENDING, (unsigned long *)&ti->flags);
 }
+
+static inline bool is_ia32_task(void)
+{
+#ifdef CONFIG_X86_32
+	return true;
+#endif
+#ifdef CONFIG_IA32_EMULATION
+	if (current_thread_info()->status & TS_COMPAT)
+		return true;
+#endif
+	return false;
+}
 #endif	/* !__ASSEMBLY__ */
 
 #ifndef __ASSEMBLY__
diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index 0012d09..88eae2a 100644
--- a/arch/x86/include/asm/traps.h
+++ b/arch/x86/include/asm/traps.h
@@ -89,4 +89,29 @@ asmlinkage void smp_thermal_interrupt(void);
 asmlinkage void mce_threshold_interrupt(void);
 #endif
 
+/* Interrupts/Exceptions */
+enum {
+	X86_TRAP_DE = 0,	/*  0, Divide-by-zero */
+	X86_TRAP_DB,		/*  1, Debug */
+	X86_TRAP_NMI,		/*  2, Non-maskable Interrupt */
+	X86_TRAP_BP,		/*  3, Breakpoint */
+	X86_TRAP_OF,		/*  4, Overflow */
+	X86_TRAP_BR,		/*  5, Bound Range Exceeded */
+	X86_TRAP_UD,		/*  6, Invalid Opcode */
+	X86_TRAP_NM,		/*  7, Device Not Available */
+	X86_TRAP_DF,		/*  8, Double Fault */
+	X86_TRAP_OLD_MF,	/*  9, Coprocessor Segment Overrun */
+	X86_TRAP_TS,		/* 10, Invalid TSS */
+	X86_TRAP_NP,		/* 11, Segment Not Present */
+	X86_TRAP_SS,		/* 12, Stack Segment Fault */
+	X86_TRAP_GP,		/* 13, General Protection Fault */
+	X86_TRAP_PF,		/* 14, Page Fault */
+	X86_TRAP_SPURIOUS,	/* 15, Spurious Interrupt */
+	X86_TRAP_MF,		/* 16, x87 Floating-Point Exception */
+	X86_TRAP_AC,		/* 17, Alignment Check */
+	X86_TRAP_MC,		/* 18, Machine Check */
+	X86_TRAP_XF,		/* 19, SIMD Floating-Point Exception */
+	X86_TRAP_IRET = 32,	/* 32, IRET Exception */
+};
+
 #endif /* _ASM_X86_TRAPS_H */
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index 4025fe4..28f9870 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -265,7 +265,7 @@ int __kprobes __die(const char *str, struct pt_regs *regs, long err)
 #endif
 	printk("\n");
 	if (notify_die(DIE_OOPS, str, regs, err,
-			current->thread.trap_no, SIGSEGV) == NOTIFY_STOP)
+			current->thread.trap_nr, SIGSEGV) == NOTIFY_STOP)
 		return 1;
 
 	show_registers(regs);
diff --git a/arch/x86/kernel/irqinit.c b/arch/x86/kernel/irqinit.c
index 313fb5c..7b77062 100644
--- a/arch/x86/kernel/irqinit.c
+++ b/arch/x86/kernel/irqinit.c
@@ -61,7 +61,7 @@ static irqreturn_t math_error_irq(int cpl, void *dev_id)
 	outb(0, 0xF0);
 	if (ignore_fpu_irq || !boot_cpu_data.hard_math)
 		return IRQ_NONE;
-	math_error(get_irq_regs(), 0, 16);
+	math_error(get_irq_regs(), 0, X86_TRAP_MF);
 	return IRQ_HANDLED;
 }
 
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 93e7877a..6fb330a 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -33,6 +33,7 @@
 #include <asm/prctl.h>
 #include <asm/proto.h>
 #include <asm/hw_breakpoint.h>
+#include <asm/traps.h>
 
 #include "tls.h"
 
@@ -1425,7 +1426,7 @@ static void fill_sigtrap_info(struct task_struct *tsk,
 				int error_code, int si_code,
 				struct siginfo *info)
 {
-	tsk->thread.trap_no = 1;
+	tsk->thread.trap_nr = X86_TRAP_DB;
 	tsk->thread.error_code = error_code;
 
 	memset(info, 0, sizeof(*info));
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index c3846b6..9c73acc 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -150,7 +150,7 @@ int setup_sigcontext(struct sigcontext __user *sc, void __user *fpstate,
 		put_user_ex(regs->r15, &sc->r15);
 #endif /* CONFIG_X86_64 */
 
-		put_user_ex(current->thread.trap_no, &sc->trapno);
+		put_user_ex(current->thread.trap_nr, &sc->trapno);
 		put_user_ex(current->thread.error_code, &sc->err);
 		put_user_ex(regs->ip, &sc->ip);
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 4bbe04d..c6d17ad 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -119,7 +119,7 @@ do_trap(int trapnr, int signr, char *str, struct pt_regs *regs,
 		 * traps 0, 1, 3, 4, and 5 should be forwarded to vm86.
 		 * On nmi (interrupt 2), do_trap should not be called.
 		 */
-		if (trapnr < 6)
+		if (trapnr < X86_TRAP_UD)
 			goto vm86_trap;
 		goto trap_signal;
 	}
@@ -132,7 +132,7 @@ do_trap(int trapnr, int signr, char *str, struct pt_regs *regs,
 trap_signal:
 #endif
 	/*
-	 * We want error_code and trap_no set for userspace faults and
+	 * We want error_code and trap_nr set for userspace faults and
 	 * kernelspace faults which result in die(), but not
 	 * kernelspace faults which are fixed up.  die() gives the
 	 * process no chance to handle the signal and notice the
@@ -141,7 +141,7 @@ trap_signal:
 	 * delivered, faults.  See also do_general_protection below.
 	 */
 	tsk->thread.error_code = error_code;
-	tsk->thread.trap_no = trapnr;
+	tsk->thread.trap_nr = trapnr;
 
 #ifdef CONFIG_X86_64
 	if (show_unhandled_signals && unhandled_signal(tsk, signr) &&
@@ -164,7 +164,7 @@ trap_signal:
 kernel_trap:
 	if (!fixup_exception(regs)) {
 		tsk->thread.error_code = error_code;
-		tsk->thread.trap_no = trapnr;
+		tsk->thread.trap_nr = trapnr;
 		die(str, regs, error_code);
 	}
 	return;
@@ -203,27 +203,31 @@ dotraplinkage void do_##name(struct pt_regs *regs, long error_code)	\
 	do_trap(trapnr, signr, str, regs, error_code, &info);		\
 }
 
-DO_ERROR_INFO(0, SIGFPE, "divide error", divide_error, FPE_INTDIV, regs->ip)
-DO_ERROR(4, SIGSEGV, "overflow", overflow)
-DO_ERROR(5, SIGSEGV, "bounds", bounds)
-DO_ERROR_INFO(6, SIGILL, "invalid opcode", invalid_op, ILL_ILLOPN, regs->ip)
-DO_ERROR(9, SIGFPE, "coprocessor segment overrun", coprocessor_segment_overrun)
-DO_ERROR(10, SIGSEGV, "invalid TSS", invalid_TSS)
-DO_ERROR(11, SIGBUS, "segment not present", segment_not_present)
+DO_ERROR_INFO(X86_TRAP_DE, SIGFPE, "divide error", divide_error, FPE_INTDIV,
+		regs->ip)
+DO_ERROR(X86_TRAP_OF, SIGSEGV, "overflow", overflow)
+DO_ERROR(X86_TRAP_BR, SIGSEGV, "bounds", bounds)
+DO_ERROR_INFO(X86_TRAP_UD, SIGILL, "invalid opcode", invalid_op, ILL_ILLOPN,
+		regs->ip)
+DO_ERROR(X86_TRAP_OLD_MF, SIGFPE, "coprocessor segment overrun",
+		coprocessor_segment_overrun)
+DO_ERROR(X86_TRAP_TS, SIGSEGV, "invalid TSS", invalid_TSS)
+DO_ERROR(X86_TRAP_NP, SIGBUS, "segment not present", segment_not_present)
 #ifdef CONFIG_X86_32
-DO_ERROR(12, SIGBUS, "stack segment", stack_segment)
+DO_ERROR(X86_TRAP_SS, SIGBUS, "stack segment", stack_segment)
 #endif
-DO_ERROR_INFO(17, SIGBUS, "alignment check", alignment_check, BUS_ADRALN, 0)
+DO_ERROR_INFO(X86_TRAP_AC, SIGBUS, "alignment check", alignment_check,
+		BUS_ADRALN, 0)
 
 #ifdef CONFIG_X86_64
 /* Runs on IST stack */
 dotraplinkage void do_stack_segment(struct pt_regs *regs, long error_code)
 {
 	if (notify_die(DIE_TRAP, "stack segment", regs, error_code,
-			12, SIGBUS) == NOTIFY_STOP)
+			X86_TRAP_SS, SIGBUS) == NOTIFY_STOP)
 		return;
 	preempt_conditional_sti(regs);
-	do_trap(12, SIGBUS, "stack segment", regs, error_code, NULL);
+	do_trap(X86_TRAP_SS, SIGBUS, "stack segment", regs, error_code, NULL);
 	preempt_conditional_cli(regs);
 }
 
@@ -233,10 +237,10 @@ dotraplinkage void do_double_fault(struct pt_regs *regs, long error_code)
 	struct task_struct *tsk = current;
 
 	/* Return not checked because double check cannot be ignored */
-	notify_die(DIE_TRAP, str, regs, error_code, 8, SIGSEGV);
+	notify_die(DIE_TRAP, str, regs, error_code, X86_TRAP_DF, SIGSEGV);
 
 	tsk->thread.error_code = error_code;
-	tsk->thread.trap_no = 8;
+	tsk->thread.trap_nr = X86_TRAP_DF;
 
 	/*
 	 * This is always a kernel trap and never fixable (and thus must
@@ -264,7 +268,7 @@ do_general_protection(struct pt_regs *regs, long error_code)
 		goto gp_in_kernel;
 
 	tsk->thread.error_code = error_code;
-	tsk->thread.trap_no = 13;
+	tsk->thread.trap_nr = X86_TRAP_GP;
 
 	if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
 			printk_ratelimit()) {
@@ -291,9 +295,9 @@ gp_in_kernel:
 		return;
 
 	tsk->thread.error_code = error_code;
-	tsk->thread.trap_no = 13;
-	if (notify_die(DIE_GPF, "general protection fault", regs,
-				error_code, 13, SIGSEGV) == NOTIFY_STOP)
+	tsk->thread.trap_nr = X86_TRAP_GP;
+	if (notify_die(DIE_GPF, "general protection fault", regs, error_code,
+			X86_TRAP_GP, SIGSEGV) == NOTIFY_STOP)
 		return;
 	die("general protection fault", regs, error_code);
 }
@@ -302,13 +306,13 @@ gp_in_kernel:
 dotraplinkage void __kprobes do_int3(struct pt_regs *regs, long error_code)
 {
 #ifdef CONFIG_KGDB_LOW_LEVEL_TRAP
-	if (kgdb_ll_trap(DIE_INT3, "int3", regs, error_code, 3, SIGTRAP)
-			== NOTIFY_STOP)
+	if (kgdb_ll_trap(DIE_INT3, "int3", regs, error_code, X86_TRAP_BP,
+				SIGTRAP) == NOTIFY_STOP)
 		return;
 #endif /* CONFIG_KGDB_LOW_LEVEL_TRAP */
 
-	if (notify_die(DIE_INT3, "int3", regs, error_code, 3, SIGTRAP)
-			== NOTIFY_STOP)
+	if (notify_die(DIE_INT3, "int3", regs, error_code, X86_TRAP_BP,
+			SIGTRAP) == NOTIFY_STOP)
 		return;
 
 	/*
@@ -317,7 +321,7 @@ dotraplinkage void __kprobes do_int3(struct pt_regs *regs, long error_code)
 	 */
 	debug_stack_usage_inc();
 	preempt_conditional_sti(regs);
-	do_trap(3, SIGTRAP, "int3", regs, error_code, NULL);
+	do_trap(X86_TRAP_BP, SIGTRAP, "int3", regs, error_code, NULL);
 	preempt_conditional_cli(regs);
 	debug_stack_usage_dec();
 }
@@ -422,8 +426,8 @@ dotraplinkage void __kprobes do_debug(struct pt_regs *regs, long error_code)
 	preempt_conditional_sti(regs);
 
 	if (regs->flags & X86_VM_MASK) {
-		handle_vm86_trap((struct kernel_vm86_regs *) regs,
-				error_code, 1);
+		handle_vm86_trap((struct kernel_vm86_regs *) regs, error_code,
+					X86_TRAP_DB);
 		preempt_conditional_cli(regs);
 		debug_stack_usage_dec();
 		return;
@@ -460,7 +464,8 @@ void math_error(struct pt_regs *regs, int error_code, int trapnr)
 	struct task_struct *task = current;
 	siginfo_t info;
 	unsigned short err;
-	char *str = (trapnr == 16) ? "fpu exception" : "simd exception";
+	char *str = (trapnr == X86_TRAP_MF) ? "fpu exception" :
+						"simd exception";
 
 	if (notify_die(DIE_TRAP, str, regs, error_code, trapnr, SIGFPE) == NOTIFY_STOP)
 		return;
@@ -470,7 +475,7 @@ void math_error(struct pt_regs *regs, int error_code, int trapnr)
 	{
 		if (!fixup_exception(regs)) {
 			task->thread.error_code = error_code;
-			task->thread.trap_no = trapnr;
+			task->thread.trap_nr = trapnr;
 			die(str, regs, error_code);
 		}
 		return;
@@ -480,12 +485,12 @@ void math_error(struct pt_regs *regs, int error_code, int trapnr)
 	 * Save the info for the exception handler and clear the error.
 	 */
 	save_init_fpu(task);
-	task->thread.trap_no = trapnr;
+	task->thread.trap_nr = trapnr;
 	task->thread.error_code = error_code;
 	info.si_signo = SIGFPE;
 	info.si_errno = 0;
 	info.si_addr = (void __user *)regs->ip;
-	if (trapnr == 16) {
+	if (trapnr == X86_TRAP_MF) {
 		unsigned short cwd, swd;
 		/*
 		 * (~cwd & swd) will mask out exceptions that are not set to unmasked
@@ -529,10 +534,11 @@ void math_error(struct pt_regs *regs, int error_code, int trapnr)
 		info.si_code = FPE_FLTRES;
 	} else {
 		/*
-		 * If we're using IRQ 13, or supposedly even some trap 16
-		 * implementations, it's possible we get a spurious trap...
+		 * If we're using IRQ 13, or supposedly even some trap
+		 * X86_TRAP_MF implementations, it's possible
+		 * we get a spurious trap, which is not an error.
 		 */
-		return;		/* Spurious trap, no error */
+		return;
 	}
 	force_sig_info(SIGFPE, &info, task);
 }
@@ -543,13 +549,13 @@ dotraplinkage void do_coprocessor_error(struct pt_regs *regs, long error_code)
 	ignore_fpu_irq = 1;
 #endif
 
-	math_error(regs, error_code, 16);
+	math_error(regs, error_code, X86_TRAP_MF);
 }
 
 dotraplinkage void
 do_simd_coprocessor_error(struct pt_regs *regs, long error_code)
 {
-	math_error(regs, error_code, 19);
+	math_error(regs, error_code, X86_TRAP_XF);
 }
 
 dotraplinkage void
@@ -643,20 +649,21 @@ dotraplinkage void do_iret_error(struct pt_regs *regs, long error_code)
 	info.si_errno = 0;
 	info.si_code = ILL_BADSTK;
 	info.si_addr = NULL;
-	if (notify_die(DIE_TRAP, "iret exception",
-			regs, error_code, 32, SIGILL) == NOTIFY_STOP)
+	if (notify_die(DIE_TRAP, "iret exception", regs, error_code,
+			X86_TRAP_IRET, SIGILL) == NOTIFY_STOP)
 		return;
-	do_trap(32, SIGILL, "iret exception", regs, error_code, &info);
+	do_trap(X86_TRAP_IRET, SIGILL, "iret exception", regs, error_code,
+		&info);
 }
 #endif
 
 /* Set of traps needed for early debugging. */
 void __init early_trap_init(void)
 {
-	set_intr_gate_ist(1, &debug, DEBUG_STACK);
+	set_intr_gate_ist(X86_TRAP_DB, &debug, DEBUG_STACK);
 	/* int3 can be called from all */
-	set_system_intr_gate_ist(3, &int3, DEBUG_STACK);
-	set_intr_gate(14, &page_fault);
+	set_system_intr_gate_ist(X86_TRAP_BP, &int3, DEBUG_STACK);
+	set_intr_gate(X86_TRAP_PF, &page_fault);
 	load_idt(&idt_descr);
 }
 
@@ -672,30 +679,30 @@ void __init trap_init(void)
 	early_iounmap(p, 4);
 #endif
 
-	set_intr_gate(0, &divide_error);
-	set_intr_gate_ist(2, &nmi, NMI_STACK);
+	set_intr_gate(X86_TRAP_DE, &divide_error);
+	set_intr_gate_ist(X86_TRAP_NMI, &nmi, NMI_STACK);
 	/* int4 can be called from all */
-	set_system_intr_gate(4, &overflow);
-	set_intr_gate(5, &bounds);
-	set_intr_gate(6, &invalid_op);
-	set_intr_gate(7, &device_not_available);
+	set_system_intr_gate(X86_TRAP_OF, &overflow);
+	set_intr_gate(X86_TRAP_BR, &bounds);
+	set_intr_gate(X86_TRAP_UD, &invalid_op);
+	set_intr_gate(X86_TRAP_NM, &device_not_available);
 #ifdef CONFIG_X86_32
-	set_task_gate(8, GDT_ENTRY_DOUBLEFAULT_TSS);
+	set_task_gate(X86_TRAP_DF, GDT_ENTRY_DOUBLEFAULT_TSS);
 #else
-	set_intr_gate_ist(8, &double_fault, DOUBLEFAULT_STACK);
+	set_intr_gate_ist(X86_TRAP_DF, &double_fault, DOUBLEFAULT_STACK);
 #endif
-	set_intr_gate(9, &coprocessor_segment_overrun);
-	set_intr_gate(10, &invalid_TSS);
-	set_intr_gate(11, &segment_not_present);
-	set_intr_gate_ist(12, &stack_segment, STACKFAULT_STACK);
-	set_intr_gate(13, &general_protection);
-	set_intr_gate(15, &spurious_interrupt_bug);
-	set_intr_gate(16, &coprocessor_error);
-	set_intr_gate(17, &alignment_check);
+	set_intr_gate(X86_TRAP_OLD_MF, &coprocessor_segment_overrun);
+	set_intr_gate(X86_TRAP_TS, &invalid_TSS);
+	set_intr_gate(X86_TRAP_NP, &segment_not_present);
+	set_intr_gate_ist(X86_TRAP_SS, &stack_segment, STACKFAULT_STACK);
+	set_intr_gate(X86_TRAP_GP, &general_protection);
+	set_intr_gate(X86_TRAP_SPURIOUS, &spurious_interrupt_bug);
+	set_intr_gate(X86_TRAP_MF, &coprocessor_error);
+	set_intr_gate(X86_TRAP_AC, &alignment_check);
 #ifdef CONFIG_X86_MCE
-	set_intr_gate_ist(18, &machine_check, MCE_STACK);
+	set_intr_gate_ist(X86_TRAP_MC, &machine_check, MCE_STACK);
 #endif
-	set_intr_gate(19, &simd_coprocessor_error);
+	set_intr_gate(X86_TRAP_XF, &simd_coprocessor_error);
 
 	/* Reserve all the builtin and the syscall vector: */
 	for (i = 0; i < FIRST_EXTERNAL_VECTOR; i++)
@@ -720,7 +727,7 @@ void __init trap_init(void)
 
 #ifdef CONFIG_X86_64
 	memcpy(&nmi_idt_table, &idt_table, IDT_ENTRIES * 16);
-	set_nmi_gate(1, &debug);
-	set_nmi_gate(3, &int3);
+	set_nmi_gate(X86_TRAP_DB, &debug);
+	set_nmi_gate(X86_TRAP_BP, &int3);
 #endif
 }
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index b466cab..a1315ab 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -567,7 +567,7 @@ int handle_vm86_trap(struct kernel_vm86_regs *regs, long error_code, int trapno)
 	}
 	if (trapno != 1)
 		return 1; /* we let this handle by the calling routine */
-	current->thread.trap_no = trapno;
+	current->thread.trap_nr = trapno;
 	current->thread.error_code = error_code;
 	force_sig(SIGTRAP, current);
 	return 0;
diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index b07ba93..327509b 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -153,7 +153,7 @@ static bool write_ok_or_segv(unsigned long ptr, size_t size)
 
 		thread->error_code	= 6;  /* user fault, no page, write */
 		thread->cr2		= ptr;
-		thread->trap_no		= 14;
+		thread->trap_nr		= X86_TRAP_PF;
 
 		memset(&info, 0, sizeof(info));
 		info.si_signo		= SIGSEGV;
diff --git a/arch/x86/math-emu/fpu_entry.c b/arch/x86/math-emu/fpu_entry.c
index 7718541..9b86812 100644
--- a/arch/x86/math-emu/fpu_entry.c
+++ b/arch/x86/math-emu/fpu_entry.c
@@ -28,6 +28,7 @@
 #include <linux/regset.h>
 
 #include <asm/uaccess.h>
+#include <asm/traps.h>
 #include <asm/desc.h>
 #include <asm/user.h>
 #include <asm/i387.h>
@@ -269,7 +270,7 @@ void math_emulate(struct math_emu_info *info)
 			FPU_EIP = FPU_ORIG_EIP;	/* Point to current FPU instruction. */
 
 			RE_ENTRANT_CHECK_OFF;
-			current->thread.trap_no = 16;
+			current->thread.trap_nr = X86_TRAP_MF;
 			current->thread.error_code = 0;
 			send_sig(SIGFPE, current, 1);
 			return;
@@ -662,7 +663,7 @@ static int valid_prefix(u_char *Byte, u_char __user **fpu_eip,
 void math_abort(struct math_emu_info *info, unsigned int signal)
 {
 	FPU_EIP = FPU_ORIG_EIP;
-	current->thread.trap_no = 16;
+	current->thread.trap_nr = X86_TRAP_MF;
 	current->thread.error_code = 0;
 	send_sig(signal, current, 1);
 	RE_ENTRANT_CHECK_OFF;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f0b4caf..3ecfd1a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -615,7 +615,7 @@ pgtable_bad(struct pt_regs *regs, unsigned long error_code,
 	dump_pagetable(address);
 
 	tsk->thread.cr2		= address;
-	tsk->thread.trap_no	= 14;
+	tsk->thread.trap_nr	= X86_TRAP_PF;
 	tsk->thread.error_code	= error_code;
 
 	if (__die("Bad pagetable", regs, error_code))
@@ -636,7 +636,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 	/* Are we prepared to handle this kernel fault? */
 	if (fixup_exception(regs)) {
 		if (current_thread_info()->sig_on_uaccess_error && signal) {
-			tsk->thread.trap_no = 14;
+			tsk->thread.trap_nr = X86_TRAP_PF;
 			tsk->thread.error_code = error_code | PF_USER;
 			tsk->thread.cr2 = address;
 
@@ -676,7 +676,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 		printk(KERN_EMERG "Thread overran stack, or stack corrupted\n");
 
 	tsk->thread.cr2		= address;
-	tsk->thread.trap_no	= 14;
+	tsk->thread.trap_nr	= X86_TRAP_PF;
 	tsk->thread.error_code	= error_code;
 
 	sig = SIGKILL;
@@ -754,7 +754,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
 		/* Kernel addresses are always protection faults: */
 		tsk->thread.cr2		= address;
 		tsk->thread.error_code	= error_code | (address >= TASK_SIZE);
-		tsk->thread.trap_no	= 14;
+		tsk->thread.trap_nr	= X86_TRAP_PF;
 
 		force_sig_info_fault(SIGSEGV, si_code, address, tsk, 0);
 
@@ -838,7 +838,7 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 
 	tsk->thread.cr2		= address;
 	tsk->thread.error_code	= error_code;
-	tsk->thread.trap_no	= 14;
+	tsk->thread.trap_nr	= X86_TRAP_PF;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (fault & (VM_FAULT_HWPOISON|VM_FAULT_HWPOISON_LARGE)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
