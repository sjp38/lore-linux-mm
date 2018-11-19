Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66AF16B1C8D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:54:19 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so20210839pgq.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:54:19 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o12-v6si32492543plg.114.2018.11.19.13.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:54:18 -0800 (PST)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v6 06/26] x86/cet: Add control protection exception handler
Date: Mon, 19 Nov 2018 13:47:49 -0800
Message-Id: <20181119214809.6086-7-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214809.6086-1-yu-cheng.yu@intel.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

A control protection exception is triggered when a control flow transfer
attempt violated shadow stack or indirect branch tracking constraints.
For example, the return address for a RET instruction differs from the
safe copy on the shadow stack; or a JMP instruction arrives at a non-
ENDBR instruction.

The control protection exception handler works in a similar way as the
general protection fault handler.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/entry/entry_64.S          |  2 +-
 arch/x86/include/asm/traps.h       |  3 ++
 arch/x86/kernel/idt.c              |  4 +++
 arch/x86/kernel/signal_compat.c    |  2 +-
 arch/x86/kernel/traps.c            | 57 ++++++++++++++++++++++++++++++
 include/uapi/asm-generic/siginfo.h |  3 +-
 6 files changed, 68 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index ce25d84023c0..660b56706d91 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -976,7 +976,7 @@ idtentry spurious_interrupt_bug		do_spurious_interrupt_bug	has_error_code=0
 idtentry coprocessor_error		do_coprocessor_error		has_error_code=0
 idtentry alignment_check		do_alignment_check		has_error_code=1
 idtentry simd_coprocessor_error		do_simd_coprocessor_error	has_error_code=0
-
+idtentry control_protection		do_control_protection		has_error_code=1
 
 	/*
 	 * Reload gs selector with exception handling
diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index 3de69330e6c5..20841d301e93 100644
--- a/arch/x86/include/asm/traps.h
+++ b/arch/x86/include/asm/traps.h
@@ -26,6 +26,7 @@ asmlinkage void invalid_TSS(void);
 asmlinkage void segment_not_present(void);
 asmlinkage void stack_segment(void);
 asmlinkage void general_protection(void);
+asmlinkage void control_protection(void);
 asmlinkage void page_fault(void);
 asmlinkage void async_page_fault(void);
 asmlinkage void spurious_interrupt_bug(void);
@@ -77,6 +78,7 @@ dotraplinkage void do_stack_segment(struct pt_regs *, long);
 dotraplinkage void do_double_fault(struct pt_regs *, long);
 #endif
 dotraplinkage void do_general_protection(struct pt_regs *, long);
+dotraplinkage void do_control_protection(struct pt_regs *regs, long error_code);
 dotraplinkage void do_page_fault(struct pt_regs *, unsigned long);
 dotraplinkage void do_spurious_interrupt_bug(struct pt_regs *, long);
 dotraplinkage void do_coprocessor_error(struct pt_regs *, long);
@@ -142,6 +144,7 @@ enum {
 	X86_TRAP_AC,		/* 17, Alignment Check */
 	X86_TRAP_MC,		/* 18, Machine Check */
 	X86_TRAP_XF,		/* 19, SIMD Floating-Point Exception */
+	X86_TRAP_CP = 21,	/* 21 Control Protection Fault */
 	X86_TRAP_IRET = 32,	/* 32, IRET Exception */
 };
 
diff --git a/arch/x86/kernel/idt.c b/arch/x86/kernel/idt.c
index 01adea278a71..66ebc8cb16e2 100644
--- a/arch/x86/kernel/idt.c
+++ b/arch/x86/kernel/idt.c
@@ -104,6 +104,10 @@ static const __initconst struct idt_data def_idts[] = {
 #elif defined(CONFIG_X86_32)
 	SYSG(IA32_SYSCALL_VECTOR,	entry_INT80_32),
 #endif
+
+#ifdef CONFIG_X86_64
+	INTG(X86_TRAP_CP,		control_protection),
+#endif
 };
 
 /*
diff --git a/arch/x86/kernel/signal_compat.c b/arch/x86/kernel/signal_compat.c
index 9ccbf0576cd0..c572a3de1037 100644
--- a/arch/x86/kernel/signal_compat.c
+++ b/arch/x86/kernel/signal_compat.c
@@ -27,7 +27,7 @@ static inline void signal_compat_build_tests(void)
 	 */
 	BUILD_BUG_ON(NSIGILL  != 11);
 	BUILD_BUG_ON(NSIGFPE  != 15);
-	BUILD_BUG_ON(NSIGSEGV != 7);
+	BUILD_BUG_ON(NSIGSEGV != 8);
 	BUILD_BUG_ON(NSIGBUS  != 5);
 	BUILD_BUG_ON(NSIGTRAP != 5);
 	BUILD_BUG_ON(NSIGCHLD != 6);
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 9b7c4ca8f0a7..0bef2e914d5f 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -569,6 +569,63 @@ do_general_protection(struct pt_regs *regs, long error_code)
 }
 NOKPROBE_SYMBOL(do_general_protection);
 
+static const char *control_protection_err[] = {
+	"unknown",
+	"near-ret",
+	"far-ret/iret",
+	"endbranch",
+	"rstorssp",
+	"setssbsy",
+};
+
+/*
+ * When a control protection exception occurs, send a signal
+ * to the responsible application.  Currently, control
+ * protection is only enabled for the user mode.  This
+ * exception should not come from the kernel mode.
+ */
+dotraplinkage void
+do_control_protection(struct pt_regs *regs, long error_code)
+{
+	struct task_struct *tsk;
+
+	RCU_LOCKDEP_WARN(!rcu_is_watching(), "entry code didn't wake RCU");
+	if (notify_die(DIE_TRAP, "control protection fault", regs,
+		       error_code, X86_TRAP_CP, SIGSEGV) == NOTIFY_STOP)
+		return;
+	cond_local_irq_enable(regs);
+
+	if (!user_mode(regs))
+		die("kernel control protection fault", regs, error_code);
+
+	if (!static_cpu_has(X86_FEATURE_SHSTK) &&
+	    !static_cpu_has(X86_FEATURE_IBT))
+		WARN_ONCE(1, "CET is disabled but got control protection fault\n");
+
+	tsk = current;
+	tsk->thread.error_code = error_code;
+	tsk->thread.trap_nr = X86_TRAP_CP;
+
+	if (show_unhandled_signals && unhandled_signal(tsk, SIGSEGV) &&
+	    printk_ratelimit()) {
+		unsigned int max_err;
+
+		max_err = ARRAY_SIZE(control_protection_err) - 1;
+		if ((error_code < 0) || (error_code > max_err))
+			error_code = 0;
+		pr_info("%s[%d] control protection ip:%lx sp:%lx error:%lx(%s)",
+			tsk->comm, task_pid_nr(tsk),
+			regs->ip, regs->sp, error_code,
+			control_protection_err[error_code]);
+		print_vma_addr(KERN_CONT " in ", regs->ip);
+		pr_cont("\n");
+	}
+
+	force_sig_fault(SIGSEGV, SEGV_CPERR,
+			(void __user *)uprobe_get_trap_addr(regs), tsk);
+}
+NOKPROBE_SYMBOL(do_control_protection);
+
 dotraplinkage void notrace do_int3(struct pt_regs *regs, long error_code)
 {
 #ifdef CONFIG_DYNAMIC_FTRACE
diff --git a/include/uapi/asm-generic/siginfo.h b/include/uapi/asm-generic/siginfo.h
index cb3d6c267181..693071dbe641 100644
--- a/include/uapi/asm-generic/siginfo.h
+++ b/include/uapi/asm-generic/siginfo.h
@@ -229,7 +229,8 @@ typedef struct siginfo {
 #define SEGV_ACCADI	5	/* ADI not enabled for mapped object */
 #define SEGV_ADIDERR	6	/* Disrupting MCD error */
 #define SEGV_ADIPERR	7	/* Precise MCD exception */
-#define NSIGSEGV	7
+#define SEGV_CPERR	8
+#define NSIGSEGV	8
 
 /*
  * SIGBUS si_codes
-- 
2.17.1
