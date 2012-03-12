Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5431B6B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 05:29:31 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 12 Mar 2012 09:23:52 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2C9NUKx3575962
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 20:23:30 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2C9TDJm006493
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 20:29:14 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 12 Mar 2012 14:56:16 +0530
Message-Id: <20120312092616.5379.46623.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20120312092514.5379.36595.sendpatchset@srdronam.in.ibm.com>
References: <20120312092514.5379.36595.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v2 6/7] x86/trivial: Use is_ia32_compat_task
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

There are several instances in the arch/x86 code where we check if a task is
32 bit. However in most cases, this check has to be in #ifdef code.

This change provides a is_ia32_compat_task macro that can be called without
the #ifdef.

This is pure cleanup, no functional change intended.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/compat.h             |   31 +++++++++++++----------------
 arch/x86/include/asm/elf.h                |    9 +++-----
 arch/x86/include/asm/syscall.h            |    9 +++-----
 arch/x86/kernel/cpu/perf_event_intel_ds.c |    5 ++---
 arch/x86/kernel/process_64.c              |   13 +++++-------
 arch/x86/kernel/ptrace.c                  |   27 ++++++-------------------
 arch/x86/kernel/signal.c                  |   10 ++-------
 include/linux/compat.h                    |    4 +++-
 8 files changed, 38 insertions(+), 70 deletions(-)

diff --git a/arch/x86/include/asm/compat.h b/arch/x86/include/asm/compat.h
index ba9e9dc..2a73336 100644
--- a/arch/x86/include/asm/compat.h
+++ b/arch/x86/include/asm/compat.h
@@ -13,6 +13,12 @@
 #define COMPAT_USER_HZ		100
 #define COMPAT_UTS_MACHINE	"i686\0\0"
 
+#ifdef CONFIG_X86_32
+# define is_ia32_compat_task(t) 1
+#else
+# define is_ia32_compat_task(t) (test_tsk_thread_flag(t, TIF_IA32))
+#endif
+
 typedef u32		compat_size_t;
 typedef s32		compat_ssize_t;
 typedef s32		compat_time_t;
@@ -221,36 +227,25 @@ static inline compat_uptr_t ptr_to_compat(void __user *uptr)
 	return (u32)(unsigned long)uptr;
 }
 
-#ifdef CONFIG_x86_64
 static inline void __user *arch_compat_alloc_user_space(long len)
 {
 	compat_uptr_t sp;
 
-	if (test_thread_flag(TIF_IA32)) {
-		sp = task_pt_regs(current)->sp;
-	} else {
+	sp = task_pt_regs(current)->sp;
+#ifdef CONFIG_x86_64
+	if (!is_ia32_compat_task(current))
 		/* -128 for the x32 ABI redzone */
 		sp = percpu_read(old_rsp) - 128;
-	}
+#endif
 
 	return (void __user *)round_down(sp - len, 16);
 }
-#else
-
-static inline void __user *arch_compat_alloc_user_space(long len)
-{
-	struct pt_regs *regs = task_pt_regs(current);
-		return (void __user *)regs->sp - len;
-}
-
-#endif
 
 static inline bool is_ia32_task(void)
 {
-#ifdef CONFIG_IA32_EMULATION
-	if (current_thread_info()->status & TS_COMPAT)
+	if (is_ia32_compat_task(current))
 		return true;
-#endif
+
 	return false;
 }
 
@@ -263,6 +258,8 @@ static inline bool is_x32_task(void)
 	return false;
 }
 
+#undef is_compat_task
+
 static inline bool is_compat_task(void)
 {
 	return is_ia32_task() || is_x32_task();
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 1e40634..d9805c6 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -9,6 +9,7 @@
 #include <asm/ptrace.h>
 #include <asm/user.h>
 #include <asm/auxvec.h>
+#include <asm/compat.h>
 
 typedef unsigned long elf_greg_t;
 
@@ -345,13 +346,9 @@ extern unsigned long arch_randomize_brk(struct mm_struct *mm);
  */
 static inline int mmap_is_ia32(void)
 {
-#ifdef CONFIG_X86_32
-	return 1;
-#endif
-#ifdef CONFIG_IA32_EMULATION
-	if (test_thread_flag(TIF_ADDR32))
+	if (is_ia32_compat_task(current))
 		return 1;
-#endif
+
 	return 0;
 }
 
diff --git a/arch/x86/include/asm/syscall.h b/arch/x86/include/asm/syscall.h
index 386b786..fabcd0e 100644
--- a/arch/x86/include/asm/syscall.h
+++ b/arch/x86/include/asm/syscall.h
@@ -17,6 +17,7 @@
 #include <linux/err.h>
 #include <asm/asm-offsets.h>	/* For NR_syscalls */
 #include <asm/unistd.h>
+#include <asm/compat.h>
 
 extern const unsigned long sys_call_table[];
 
@@ -95,8 +96,7 @@ static inline void syscall_get_arguments(struct task_struct *task,
 					 unsigned int i, unsigned int n,
 					 unsigned long *args)
 {
-# ifdef CONFIG_IA32_EMULATION
-	if (task_thread_info(task)->status & TS_COMPAT)
+	if (is_ia32_compat_task(task))
 		switch (i) {
 		case 0:
 			if (!n--) break;
@@ -123,7 +123,6 @@ static inline void syscall_get_arguments(struct task_struct *task,
 			break;
 		}
 	else
-# endif
 		switch (i) {
 		case 0:
 			if (!n--) break;
@@ -156,8 +155,7 @@ static inline void syscall_set_arguments(struct task_struct *task,
 					 unsigned int i, unsigned int n,
 					 const unsigned long *args)
 {
-# ifdef CONFIG_IA32_EMULATION
-	if (task_thread_info(task)->status & TS_COMPAT)
+	if (is_ia32_compat_task(task))
 		switch (i) {
 		case 0:
 			if (!n--) break;
@@ -184,7 +182,6 @@ static inline void syscall_set_arguments(struct task_struct *task,
 			break;
 		}
 	else
-# endif
 		switch (i) {
 		case 0:
 			if (!n--) break;
diff --git a/arch/x86/kernel/cpu/perf_event_intel_ds.c b/arch/x86/kernel/cpu/perf_event_intel_ds.c
index 7f64df1..14ab22e 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_ds.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_ds.c
@@ -4,6 +4,7 @@
 
 #include <asm/perf_event.h>
 #include <asm/insn.h>
+#include <asm/compat.h>
 
 #include "perf_event.h"
 
@@ -528,9 +529,7 @@ static int intel_pmu_pebs_fixup_ip(struct pt_regs *regs)
 		} else
 			kaddr = (void *)to;
 
-#ifdef CONFIG_X86_64
-		is_64bit = kernel_ip(to) || !test_thread_flag(TIF_IA32);
-#endif
+		is_64bit = kernel_ip(to) || !is_ia32_compat_task(current);
 		insn_init(&insn, kaddr, is_64bit);
 		insn_get_length(&insn);
 		to += insn.length;
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 1deb467..37a7715 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -53,6 +53,7 @@
 #include <asm/syscalls.h>
 #include <asm/debugreg.h>
 #include <asm/nmi.h>
+#include <asm/compat.h>
 
 asmlinkage extern void ret_from_fork(void);
 
@@ -295,7 +296,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	savesegment(es, p->thread.es);
 	savesegment(ds, p->thread.ds);
 
-	err = -ENOMEM;
+	err = 0;
 	memset(p->thread.ptrace_bps, 0, sizeof(p->thread.ptrace_bps));
 
 	if (unlikely(test_tsk_thread_flag(me, TIF_IO_BITMAP))) {
@@ -312,18 +313,14 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	 * Set a new TLS for the child thread?
 	 */
 	if (clone_flags & CLONE_SETTLS) {
-#ifdef CONFIG_IA32_EMULATION
-		if (test_thread_flag(TIF_IA32))
+		if (is_ia32_compat_task(current))
 			err = do_set_thread_area(p, -1,
 				(struct user_desc __user *)childregs->si, 0);
 		else
-#endif
 			err = do_arch_prctl(p, ARCH_SET_FS, childregs->r8);
-		if (err)
-			goto out;
+
 	}
-	err = 0;
-out:
+
 	if (err && p->thread.io_bitmap_ptr) {
 		kfree(p->thread.io_bitmap_ptr);
 		p->thread.io_bitmap_max = 0;
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 52c06b1..76b5194 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -35,6 +35,7 @@
 #include <asm/proto.h>
 #include <asm/hw_breakpoint.h>
 #include <asm/traps.h>
+#include <asm/compat.h>
 
 #include "tls.h"
 
@@ -333,18 +334,14 @@ static int set_segment_reg(struct task_struct *task,
 	case offsetof(struct user_regs_struct,cs):
 		if (unlikely(value == 0))
 			return -EIO;
-#ifdef CONFIG_IA32_EMULATION
-		if (test_tsk_thread_flag(task, TIF_IA32))
+		if (is_ia32_compat_task(task))
 			task_pt_regs(task)->cs = value;
-#endif
 		break;
 	case offsetof(struct user_regs_struct,ss):
 		if (unlikely(value == 0))
 			return -EIO;
-#ifdef CONFIG_IA32_EMULATION
-		if (test_tsk_thread_flag(task, TIF_IA32))
+		if (is_ia32_compat_task(task))
 			task_pt_regs(task)->ss = value;
-#endif
 		break;
 	}
 
@@ -1411,13 +1408,10 @@ void update_regset_xstate_info(unsigned int size, u64 xstate_mask)
 
 const struct user_regset_view *task_user_regset_view(struct task_struct *task)
 {
-#ifdef CONFIG_IA32_EMULATION
-	if (test_tsk_thread_flag(task, TIF_IA32))
-#endif
+	if (is_ia32_compat_task(task))
 #if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
 		return &user_x86_32_view;
-#endif
-#ifdef CONFIG_X86_64
+#else
 	return &user_x86_64_view;
 #endif
 }
@@ -1453,15 +1447,6 @@ void send_sigtrap(struct task_struct *tsk, struct pt_regs *regs,
 	force_sig_info(SIGTRAP, &info, tsk);
 }
 
-
-#ifdef CONFIG_X86_32
-# define IS_IA32	1
-#elif defined CONFIG_IA32_EMULATION
-# define IS_IA32	is_compat_task()
-#else
-# define IS_IA32	0
-#endif
-
 /*
  * We must return the syscall number to actually look up in the table.
  * This can be -1L to skip running any syscall at all.
@@ -1493,7 +1478,7 @@ long syscall_trace_enter(struct pt_regs *regs)
 	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
 		trace_sys_enter(regs, regs->orig_ax);
 
-	if (IS_IA32)
+	if (is_ia32_compat_task(current))
 		audit_syscall_entry(AUDIT_ARCH_I386,
 				    regs->orig_ax,
 				    regs->bx, regs->cx,
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 115eac4..30108c1 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -37,6 +37,7 @@
 #include <asm/syscalls.h>
 
 #include <asm/sigframe.h>
+#include <asm/compat.h>
 
 #ifdef CONFIG_X86_32
 # define FIX_EFLAGS	(__FIX_EFLAGS | X86_EFLAGS_RF)
@@ -622,18 +623,11 @@ static int signr_convert(int sig)
 
 #ifdef CONFIG_X86_32
 
-#define is_ia32	1
 #define ia32_setup_frame	__setup_frame
 #define ia32_setup_rt_frame	__setup_rt_frame
 
 #else /* !CONFIG_X86_32 */
 
-#ifdef CONFIG_IA32_EMULATION
-#define is_ia32	test_thread_flag(TIF_IA32)
-#else /* !CONFIG_IA32_EMULATION */
-#define is_ia32	0
-#endif /* CONFIG_IA32_EMULATION */
-
 #ifdef CONFIG_X86_X32_ABI
 #define is_x32	test_thread_flag(TIF_X32)
 
@@ -663,7 +657,7 @@ setup_rt_frame(int sig, struct k_sigaction *ka, siginfo_t *info,
 		set = &current->saved_sigmask;
 
 	/* Set up the stack frame */
-	if (is_ia32) {
+	if (is_ia32_compat_task(current)) {
 		if (ka->sa.sa_flags & SA_SIGINFO)
 			ret = ia32_setup_rt_frame(usig, ka, info, set, regs);
 		else
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 710446f..bc298f0 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -583,7 +583,9 @@ asmlinkage ssize_t compat_sys_process_vm_writev(compat_pid_t pid,
 
 #else
 
-#define is_compat_task() (0)
+#ifndef is_compat_task
+# define is_compat_task() (0)
+#endif
 
 #endif /* CONFIG_COMPAT */
 #endif /* _LINUX_COMPAT_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
