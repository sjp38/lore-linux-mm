Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA1026B028F
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:21:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i81-v6so8148113pfj.1
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:21:01 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id bg10-v6si26471290plb.47.2018.10.11.08.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 08:21:00 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v5 24/27] x86/cet/shstk: Handle thread shadow stack
Date: Thu, 11 Oct 2018 08:15:20 -0700
Message-Id: <20181011151523.27101-25-yu-cheng.yu@intel.com>
In-Reply-To: <20181011151523.27101-1-yu-cheng.yu@intel.com>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The shadow stack for clone/fork is handled as the following:

(1) If ((clone_flags & (CLONE_VFORK | CLONE_VM)) == CLONE_VM),
    the kernel allocates (and frees on thread exit) a new SHSTK
    for the child.

    It is possible for the kernel to complete the clone syscall
    and set the child's SHSTK pointer to NULL and let the child
    thread allocate a SHSTK for itself.  There are two issues
    in this approach: It is not compatible with existing code
    that does inline syscall and it cannot handle signals before
    the child can successfully allocate a SHSTK.

(2) For (clone_flags & CLONE_VFORK), the child uses the existing
    SHSTK.

(3) For all other cases, the SHSTK is copied/reused whenever the
    parent or the child does a call/ret.

This patch handles cases (1) & (2).  Case (3) is handled in
the SHSTK page fault patches.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h         |  2 ++
 arch/x86/include/asm/mmu_context.h |  3 +++
 arch/x86/kernel/cet.c              | 34 ++++++++++++++++++++++++++++++
 arch/x86/kernel/process.c          |  1 +
 arch/x86/kernel/process_64.c       |  7 ++++++
 5 files changed, 47 insertions(+)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 3af544aed800..008b4651b5be 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -17,12 +17,14 @@ struct cet_status {
 
 #ifdef CONFIG_X86_INTEL_CET
 int cet_setup_shstk(void);
+int cet_setup_thread_shstk(struct task_struct *p);
 void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(unsigned long ssp);
 int cet_setup_signal(bool ia32, unsigned long rstor, unsigned long *new_ssp);
 #else
 static inline int cet_setup_shstk(void) { return -EINVAL; }
+static inline int cet_setup_thread_shstk(struct task_struct *p) { return -EINVAL; }
 static inline void cet_disable_shstk(void) {}
 static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(unsigned long ssp) { return -EINVAL; }
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index eeeb9289c764..8da7c999b7ee 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/cet.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -223,6 +224,8 @@ do {						\
 #else
 #define deactivate_mm(tsk, mm)			\
 do {						\
+	if (!tsk->vfork_done)			\
+		cet_disable_free_shstk(tsk);	\
 	load_gs_index(0);			\
 	loadsegment(fs, 0);			\
 } while (0)
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 2000e5e87f8f..51b26616ac20 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -145,6 +145,40 @@ int cet_setup_shstk(void)
 	return 0;
 }
 
+int cet_setup_thread_shstk(struct task_struct *tsk)
+{
+	unsigned long addr, size;
+	struct cet_user_state *state;
+
+	if (!current->thread.cet.shstk_enabled)
+		return 0;
+
+	state = get_xsave_addr(&tsk->thread.fpu.state.xsave,
+			       XFEATURE_MASK_SHSTK_USER);
+
+	if (!state)
+		return -EINVAL;
+
+	size = tsk->thread.cet.shstk_size;
+	if (size == 0)
+		size = rlimit(RLIMIT_STACK);
+
+	addr = do_mmap_locked(0, size, PROT_READ,
+			      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK);
+
+	if (addr >= TASK_SIZE_MAX) {
+		tsk->thread.cet.shstk_base = 0;
+		tsk->thread.cet.shstk_size = 0;
+		tsk->thread.cet.shstk_enabled = 0;
+		return -ENOMEM;
+	}
+
+	state->user_ssp = (u64)(addr + size - sizeof(u64));
+	tsk->thread.cet.shstk_base = addr;
+	tsk->thread.cet.shstk_size = size;
+	return 0;
+}
+
 void cet_disable_shstk(void)
 {
 	u64 r;
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 4a776da4c28c..440f012ef925 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -125,6 +125,7 @@ void exit_thread(struct task_struct *tsk)
 
 	free_vm86(t);
 
+	cet_disable_free_shstk(tsk);
 	fpu__drop(fpu);
 }
 
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index ea5ea850348d..9cdbd87bb908 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -325,6 +325,13 @@ int copy_thread_tls(unsigned long clone_flags, unsigned long sp,
 	if (sp)
 		childregs->sp = sp;
 
+	/* Allocate a new shadow stack for pthread */
+	if ((clone_flags & (CLONE_VFORK | CLONE_VM)) == CLONE_VM) {
+		err = cet_setup_thread_shstk(p);
+		if (err)
+			goto out;
+	}
+
 	err = -ENOMEM;
 	if (unlikely(test_tsk_thread_flag(me, TIF_IO_BITMAP))) {
 		p->thread.io_bitmap_ptr = kmemdup(me->thread.io_bitmap_ptr,
-- 
2.17.1
