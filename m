Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75269C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 424952085A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 424952085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CE986B0266; Tue, 13 Aug 2019 17:02:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0811C6B026B; Tue, 13 Aug 2019 17:02:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3B316B026A; Tue, 13 Aug 2019 17:02:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id B791A6B0266
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:02:42 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6073A180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:42 +0000 (UTC)
X-FDA: 75818628564.07.drain43_17861ed62e433
X-HE-Tag: drain43_17861ed62e433
X-Filterd-Recvd-Size: 8585
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:41 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:02:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="187901346"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 14:02:38 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v8 06/27] x86/cet: Add control protection exception handler
Date: Tue, 13 Aug 2019 13:52:04 -0700
Message-Id: <20190813205225.12032-7-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205225.12032-1-yu-cheng.yu@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index be9ca198c581..c45485dfb8a1 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -1035,7 +1035,7 @@ idtentry spurious_interrupt_bug		do_spurious_interrupt_bug	has_error_code=0
 idtentry coprocessor_error		do_coprocessor_error		has_error_code=0
 idtentry alignment_check		do_alignment_check		has_error_code=1
 idtentry simd_coprocessor_error		do_simd_coprocessor_error	has_error_code=0
-
+idtentry control_protection		do_control_protection		has_error_code=1
 
 	/*
 	 * Reload gs selector with exception handling
diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index b25e633033c3..8691261faeb0 100644
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
@@ -81,6 +82,7 @@ struct bad_iret_stack *fixup_bad_iret(struct bad_iret_stack *s);
 void __init trap_init(void);
 #endif
 dotraplinkage void do_general_protection(struct pt_regs *regs, long error_code);
+dotraplinkage void do_control_protection(struct pt_regs *regs, long error_code);
 dotraplinkage void do_page_fault(struct pt_regs *regs, unsigned long error_code, unsigned long address);
 dotraplinkage void do_spurious_interrupt_bug(struct pt_regs *regs, long error_code);
 dotraplinkage void do_coprocessor_error(struct pt_regs *regs, long error_code);
@@ -151,6 +153,7 @@ enum {
 	X86_TRAP_AC,		/* 17, Alignment Check */
 	X86_TRAP_MC,		/* 18, Machine Check */
 	X86_TRAP_XF,		/* 19, SIMD Floating-Point Exception */
+	X86_TRAP_CP = 21,	/* 21 Control Protection Fault */
 	X86_TRAP_IRET = 32,	/* 32, IRET Exception */
 };
 
diff --git a/arch/x86/kernel/idt.c b/arch/x86/kernel/idt.c
index 87ef69a72c52..8ed406f469e7 100644
--- a/arch/x86/kernel/idt.c
+++ b/arch/x86/kernel/idt.c
@@ -102,6 +102,10 @@ static const __initconst struct idt_data def_idts[] = {
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
index 4bb0f8447112..b7e8b340e08e 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -566,6 +566,63 @@ do_general_protection(struct pt_regs *regs, long error_code)
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
+			(void __user *)uprobe_get_trap_addr(regs));
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


