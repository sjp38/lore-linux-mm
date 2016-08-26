Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13604830BE
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:16:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id i144so272752321oib.0
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:16:25 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50102.outbound.protection.outlook.com. [40.107.5.102])
        by mx.google.com with ESMTPS id w63si16418622otb.162.2016.08.26.10.15.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:15:59 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Date: Fri, 26 Aug 2016 20:13:17 +0300
Message-ID: <20160826171317.3944-7-dsafonov@virtuozzo.com>
In-Reply-To: <20160826171317.3944-1-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Introduce new flags that defines which ABI to use on creating sigframe.
Those flags kernel will set according to sigaction syscall ABI,
which set handler for the signal being delivered.

So that will drop the dependency on TIF_IA32/TIF_X32 flags on signal deliver.
Those flags will be used only under CONFIG_COMPAT.

Similar way ARM uses sa_flags to differ in which mode deliver signal
for 26-bit applications (look at SA_THIRYTWO).

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/ia32/ia32_signal.c       |  2 +-
 arch/x86/include/asm/fpu/signal.h |  6 ++++++
 arch/x86/include/asm/signal.h     |  4 ++++
 arch/x86/kernel/signal.c          | 20 +++++++++++---------
 arch/x86/kernel/signal_compat.c   | 34 +++++++++++++++++++++++++++++++---
 kernel/signal.c                   |  7 +++++++
 6 files changed, 60 insertions(+), 13 deletions(-)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index 2f29f4e407c3..cb13c0564ea7 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -378,7 +378,7 @@ int ia32_setup_rt_frame(int sig, struct ksignal *ksig,
 		put_user_ex(*((u64 *)&code), (u64 __user *)frame->retcode);
 	} put_user_catch(err);
 
-	err |= copy_siginfo_to_user32(&frame->info, &ksig->info);
+	err |= __copy_siginfo_to_user32(&frame->info, &ksig->info, false);
 	err |= ia32_setup_sigcontext(&frame->uc.uc_mcontext, fpstate,
 				     regs, set->sig[0]);
 	err |= __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
diff --git a/arch/x86/include/asm/fpu/signal.h b/arch/x86/include/asm/fpu/signal.h
index 0e970d00dfcd..20a1fbf7fe4e 100644
--- a/arch/x86/include/asm/fpu/signal.h
+++ b/arch/x86/include/asm/fpu/signal.h
@@ -19,6 +19,12 @@ int ia32_setup_frame(int sig, struct ksignal *ksig,
 # define ia32_setup_rt_frame	__setup_rt_frame
 #endif
 
+#ifdef CONFIG_COMPAT
+int __copy_siginfo_to_user32(compat_siginfo_t __user *to,
+		const siginfo_t *from, bool x32_ABI);
+#endif
+
+
 extern void convert_from_fxsr(struct user_i387_ia32_struct *env,
 			      struct task_struct *tsk);
 extern void convert_to_fxsr(struct task_struct *tsk,
diff --git a/arch/x86/include/asm/signal.h b/arch/x86/include/asm/signal.h
index dd1e7d6387ab..8af22be0fe61 100644
--- a/arch/x86/include/asm/signal.h
+++ b/arch/x86/include/asm/signal.h
@@ -23,6 +23,10 @@ typedef struct {
 	unsigned long sig[_NSIG_WORDS];
 } sigset_t;
 
+/* non-uapi in-kernel SA_FLAGS for those indicates ABI for a signal frame */
+#define SA_IA32_ABI	0x02000000u
+#define SA_X32_ABI	0x01000000u
+
 #ifndef CONFIG_COMPAT
 typedef sigset_t compat_sigset_t;
 #endif
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 04cb3212db2d..b1a5d252d482 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -42,6 +42,7 @@
 #include <asm/syscalls.h>
 
 #include <asm/sigframe.h>
+#include <asm/signal.h>
 
 #define COPY(x)			do {			\
 	get_user_ex(regs->x, &sc->x);			\
@@ -547,7 +548,7 @@ static int x32_setup_rt_frame(struct ksignal *ksig,
 		return -EFAULT;
 
 	if (ksig->ka.sa.sa_flags & SA_SIGINFO) {
-		if (copy_siginfo_to_user32(&frame->info, &ksig->info))
+		if (__copy_siginfo_to_user32(&frame->info, &ksig->info, true))
 			return -EFAULT;
 	}
 
@@ -660,20 +661,21 @@ badframe:
 	return 0;
 }
 
-static inline int is_ia32_compat_frame(void)
+static inline int is_ia32_compat_frame(struct ksignal *ksig)
 {
 	return IS_ENABLED(CONFIG_IA32_EMULATION) &&
-	       test_thread_flag(TIF_IA32);
+		ksig->ka.sa.sa_flags & SA_IA32_ABI;
 }
 
-static inline int is_ia32_frame(void)
+static inline int is_ia32_frame(struct ksignal *ksig)
 {
-	return IS_ENABLED(CONFIG_X86_32) || is_ia32_compat_frame();
+	return IS_ENABLED(CONFIG_X86_32) || is_ia32_compat_frame(ksig);
 }
 
-static inline int is_x32_frame(void)
+static inline int is_x32_frame(struct ksignal *ksig)
 {
-	return IS_ENABLED(CONFIG_X86_X32_ABI) && test_thread_flag(TIF_X32);
+	return IS_ENABLED(CONFIG_X86_X32_ABI) &&
+		ksig->ka.sa.sa_flags & SA_X32_ABI;
 }
 
 static int
@@ -684,12 +686,12 @@ setup_rt_frame(struct ksignal *ksig, struct pt_regs *regs)
 	compat_sigset_t *cset = (compat_sigset_t *) set;
 
 	/* Set up the stack frame */
-	if (is_ia32_frame()) {
+	if (is_ia32_frame(ksig)) {
 		if (ksig->ka.sa.sa_flags & SA_SIGINFO)
 			return ia32_setup_rt_frame(usig, ksig, cset, regs);
 		else
 			return ia32_setup_frame(usig, ksig, cset, regs);
-	} else if (is_x32_frame()) {
+	} else if (is_x32_frame(ksig)) {
 		return x32_setup_rt_frame(ksig, cset, regs);
 	} else {
 		return __setup_rt_frame(ksig->sig, ksig, set, regs);
diff --git a/arch/x86/kernel/signal_compat.c b/arch/x86/kernel/signal_compat.c
index b44564bf86a8..40df33753bae 100644
--- a/arch/x86/kernel/signal_compat.c
+++ b/arch/x86/kernel/signal_compat.c
@@ -1,5 +1,6 @@
 #include <linux/compat.h>
 #include <linux/uaccess.h>
+#include <linux/ptrace.h>
 
 /*
  * The compat_siginfo_t structure and handing code is very easy
@@ -92,10 +93,31 @@ static inline void signal_compat_build_tests(void)
 	/* any new si_fields should be added here */
 }
 
-int copy_siginfo_to_user32(compat_siginfo_t __user *to, const siginfo_t *from)
+void sigaction_compat_abi(struct k_sigaction *act, struct k_sigaction *oact)
+{
+	/* Don't leak in-kernel non-uapi flags to user-space */
+	if (oact)
+		oact->sa.sa_flags &= ~(SA_IA32_ABI | SA_X32_ABI);
+
+	if (!act)
+		return;
+
+	/* Don't let flags to be set from userspace */
+	act->sa.sa_flags &= ~(SA_IA32_ABI | SA_X32_ABI);
+
+	if (user_64bit_mode(current_pt_regs()))
+		return;
+
+	if (in_ia32_syscall())
+		act->sa.sa_flags |= SA_IA32_ABI;
+	if (in_x32_syscall())
+		act->sa.sa_flags |= SA_X32_ABI;
+}
+
+int __copy_siginfo_to_user32(compat_siginfo_t __user *to, const siginfo_t *from,
+		bool x32_ABI)
 {
 	int err = 0;
-	bool ia32 = test_thread_flag(TIF_IA32);
 
 	signal_compat_build_tests();
 
@@ -146,7 +168,7 @@ int copy_siginfo_to_user32(compat_siginfo_t __user *to, const siginfo_t *from)
 				put_user_ex(from->si_arch, &to->si_arch);
 				break;
 			case __SI_CHLD >> 16:
-				if (ia32) {
+				if (!x32_ABI) {
 					put_user_ex(from->si_utime, &to->si_utime);
 					put_user_ex(from->si_stime, &to->si_stime);
 				} else {
@@ -180,6 +202,12 @@ int copy_siginfo_to_user32(compat_siginfo_t __user *to, const siginfo_t *from)
 	return err;
 }
 
+/* from syscall's path, where we know the ABI */
+int copy_siginfo_to_user32(compat_siginfo_t __user *to, const siginfo_t *from)
+{
+	return __copy_siginfo_to_user32(to, from, in_x32_syscall());
+}
+
 int copy_siginfo_from_user32(siginfo_t *to, compat_siginfo_t __user *from)
 {
 	int err = 0;
diff --git a/kernel/signal.c b/kernel/signal.c
index af21afc00d08..75761acc77cf 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3044,6 +3044,11 @@ void kernel_sigaction(int sig, __sighandler_t action)
 }
 EXPORT_SYMBOL(kernel_sigaction);
 
+void __weak sigaction_compat_abi(struct k_sigaction *act,
+		struct k_sigaction *oact)
+{
+}
+
 int do_sigaction(int sig, struct k_sigaction *act, struct k_sigaction *oact)
 {
 	struct task_struct *p = current, *t;
@@ -3059,6 +3064,8 @@ int do_sigaction(int sig, struct k_sigaction *act, struct k_sigaction *oact)
 	if (oact)
 		*oact = *k;
 
+	sigaction_compat_abi(act, oact);
+
 	if (act) {
 		sigdelsetmask(&act->sa.sa_mask,
 			      sigmask(SIGKILL) | sigmask(SIGSTOP));
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
