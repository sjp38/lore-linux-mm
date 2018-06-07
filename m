Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9E16B0283
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p16-v6so623266pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:33 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:31 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 03/10] x86/cet: Signal handling for shadow stack
Date: Thu,  7 Jun 2018 07:38:00 -0700
Message-Id: <20180607143807.3611-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Set and restore shadow stack pointer for signals.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/ia32/ia32_signal.c            |  5 ++++
 arch/x86/include/asm/cet.h             |  7 +++++
 arch/x86/include/uapi/asm/sigcontext.h |  4 +++
 arch/x86/kernel/cet.c                  | 51 ++++++++++++++++++++++++++++++++++
 arch/x86/kernel/signal.c               | 11 ++++++++
 5 files changed, 78 insertions(+)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index 86b1341cba9a..26a776baff7c 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -34,6 +34,7 @@
 #include <asm/sigframe.h>
 #include <asm/sighandling.h>
 #include <asm/smap.h>
+#include <asm/cet.h>
 
 /*
  * Do a signal return; undo the signal stack.
@@ -74,6 +75,7 @@ static int ia32_restore_sigcontext(struct pt_regs *regs,
 	unsigned int tmpflags, err = 0;
 	void __user *buf;
 	u32 tmp;
+	u32 ssp;
 
 	/* Always make any pending restarted system calls return -EINTR */
 	current->restart_block.fn = do_no_restart_syscall;
@@ -104,9 +106,11 @@ static int ia32_restore_sigcontext(struct pt_regs *regs,
 
 		get_user_ex(tmp, &sc->fpstate);
 		buf = compat_ptr(tmp);
+		get_user_ex(ssp, &sc->ssp);
 	} get_user_catch(err);
 
 	err |= fpu__restore_sig(buf, 1);
+	err |= cet_restore_signal((unsigned long)ssp);
 
 	force_iret();
 
@@ -194,6 +198,7 @@ static int ia32_setup_sigcontext(struct sigcontext_32 __user *sc,
 		put_user_ex(current->thread.trap_nr, &sc->trapno);
 		put_user_ex(current->thread.error_code, &sc->err);
 		put_user_ex(regs->ip, &sc->ip);
+		put_user_ex((u32)cet_get_shstk_ptr(), &sc->ssp);
 		put_user_ex(regs->cs, (unsigned int __user *)&sc->cs);
 		put_user_ex(regs->flags, &sc->flags);
 		put_user_ex(regs->sp, &sc->sp_at_signal);
diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 9d5bc1efc9b7..5507469cb803 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -17,14 +17,21 @@ struct cet_stat {
 
 #ifdef CONFIG_X86_INTEL_CET
 unsigned long cet_get_shstk_ptr(void);
+int cet_push_shstk(int ia32, unsigned long ssp, unsigned long val);
 int cet_setup_shstk(void);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
+int cet_restore_signal(unsigned long ssp);
+int cet_setup_signal(int ia32, unsigned long addr);
 #else
 static inline unsigned long cet_get_shstk_ptr(void) { return 0; }
+static inline int cet_push_shstk(int ia32, unsigned long ssp,
+				 unsigned long val) { return 0; }
 static inline int cet_setup_shstk(void) { return 0; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
+static inline int cet_restore_signal(unsigned long ssp) { return 0; }
+static inline int cet_setup_signal(int ia32, unsigned long addr) { return 0; }
 #endif
 
 #endif /* __ASSEMBLY__ */
diff --git a/arch/x86/include/uapi/asm/sigcontext.h b/arch/x86/include/uapi/asm/sigcontext.h
index 844d60eb1882..6c8997a0156a 100644
--- a/arch/x86/include/uapi/asm/sigcontext.h
+++ b/arch/x86/include/uapi/asm/sigcontext.h
@@ -230,6 +230,7 @@ struct sigcontext_32 {
 	__u32				fpstate; /* Zero when no FPU/extended context */
 	__u32				oldmask;
 	__u32				cr2;
+	__u32				ssp;
 };
 
 /*
@@ -262,6 +263,7 @@ struct sigcontext_64 {
 	__u64				trapno;
 	__u64				oldmask;
 	__u64				cr2;
+	__u64				ssp;
 
 	/*
 	 * fpstate is really (struct _fpstate *) or (struct _xstate *)
@@ -320,6 +322,7 @@ struct sigcontext {
 	struct _fpstate __user		*fpstate;
 	__u32				oldmask;
 	__u32				cr2;
+	__u32				ssp;
 };
 # else /* __x86_64__: */
 struct sigcontext {
@@ -377,6 +380,7 @@ struct sigcontext {
 	__u64				trapno;
 	__u64				oldmask;
 	__u64				cr2;
+	__u64				ssp;
 	struct _fpstate __user		*fpstate;	/* Zero when no FPU context */
 #  ifdef __ILP32__
 	__u32				__fpstate_pad;
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 8abbfd44322a..6f445ce94c83 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -17,6 +17,7 @@
 #include <asm/fpu/xstate.h>
 #include <asm/fpu/types.h>
 #include <asm/cet.h>
+#include <asm/special_insns.h>
 
 #define SHSTK_SIZE (0x8000 * (test_thread_flag(TIF_IA32) ? 4 : 8))
 
@@ -47,6 +48,24 @@ unsigned long cet_get_shstk_ptr(void)
 	return ptr;
 }
 
+int cet_push_shstk(int ia32, unsigned long ssp, unsigned long val)
+{
+	if (val >= TASK_SIZE)
+		return -EINVAL;
+
+	if (IS_ENABLED(CONFIG_IA32_EMULATION) && ia32) {
+		if (!IS_ALIGNED(ssp, 4))
+			return -EINVAL;
+		cet_set_shstk_ptr(ssp);
+		return write_user_shstk_32(ssp, (unsigned int)val);
+	} else {
+		if (!IS_ALIGNED(ssp, 8))
+			return -EINVAL;
+		cet_set_shstk_ptr(ssp);
+		return write_user_shstk_64(ssp, val);
+	}
+}
+
 static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
 {
 	struct mm_struct *mm = current->mm;
@@ -121,3 +140,35 @@ void cet_disable_free_shstk(struct task_struct *tsk)
 
 	tsk->thread.cet.shstk_enabled = 0;
 }
+
+int cet_restore_signal(unsigned long ssp)
+{
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+	return cet_set_shstk_ptr(ssp);
+}
+
+int cet_setup_signal(int ia32, unsigned long rstor_addr)
+{
+	unsigned long ssp;
+	struct cet_stat *cet = &current->thread.cet;
+
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+
+	ssp = cet_get_shstk_ptr();
+
+	/*
+	 * Put the restorer address on the shstk
+	 */
+	if (ia32)
+		ssp -= sizeof(u32);
+	else
+		ssp -= sizeof(rstor_addr);
+
+	if (ssp >= (cet->shstk_base + cet->shstk_size) ||
+	    ssp < cet->shstk_base)
+		return -EINVAL;
+
+	return cet_push_shstk(ia32, ssp, rstor_addr);
+}
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index da270b95fe4d..86fb897cae19 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -46,6 +46,7 @@
 
 #include <asm/sigframe.h>
 #include <asm/signal.h>
+#include <asm/cet.h>
 
 #define COPY(x)			do {			\
 	get_user_ex(regs->x, &sc->x);			\
@@ -102,6 +103,7 @@ static int restore_sigcontext(struct pt_regs *regs,
 	void __user *buf;
 	unsigned int tmpflags;
 	unsigned int err = 0;
+	unsigned long ssp = 0;
 
 	/* Always make any pending restarted system calls return -EINTR */
 	current->restart_block.fn = do_no_restart_syscall;
@@ -148,9 +150,11 @@ static int restore_sigcontext(struct pt_regs *regs,
 
 		get_user_ex(buf_val, &sc->fpstate);
 		buf = (void __user *)buf_val;
+		get_user_ex(ssp, &sc->ssp);
 	} get_user_catch(err);
 
 	err |= fpu__restore_sig(buf, IS_ENABLED(CONFIG_X86_32));
+	err |= cet_restore_signal(ssp);
 
 	force_iret();
 
@@ -193,6 +197,7 @@ int setup_sigcontext(struct sigcontext __user *sc, void __user *fpstate,
 		put_user_ex(current->thread.trap_nr, &sc->trapno);
 		put_user_ex(current->thread.error_code, &sc->err);
 		put_user_ex(regs->ip, &sc->ip);
+		put_user_ex(cet_get_shstk_ptr(), &sc->ssp);
 #ifdef CONFIG_X86_32
 		put_user_ex(regs->cs, (unsigned int __user *)&sc->cs);
 		put_user_ex(regs->flags, &sc->flags);
@@ -742,6 +747,12 @@ handle_signal(struct ksignal *ksig, struct pt_regs *regs)
 		user_disable_single_step(current);
 
 	failed = (setup_rt_frame(ksig, regs) < 0);
+	if (!failed) {
+		unsigned long rstor = (unsigned long)ksig->ka.sa.sa_restorer;
+		int ia32 = is_ia32_frame(ksig);
+
+		failed = cet_setup_signal(ia32, rstor);
+	}
 	if (!failed) {
 		/*
 		 * Clear the direction flag as per the ABI for function entry.
-- 
2.15.1
