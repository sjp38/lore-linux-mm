Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 5E6776B0033
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 05:16:11 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 2/3] x86: Move fpu_counter into ARCH specific thread_struct
Date: Mon, 9 Sep 2013 14:45:22 +0530
Message-ID: <1378718123-7372-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1378718123-7372-1-git-send-email-vgupta@synopsys.com>
References: <1378718123-7372-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Suresh Siddha <suresh.b.siddha@intel.com>, Borislav Petkov <bp@suse.de>, Vincent Palatin <vpalatin@chromium.org>, Len Brown <len.brown@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Paul Gortmaker <paul.gortmaker@windriver.com>, Pekka Riikonen <priikone@iki.fi>, Andrew  Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Only a couple of arches (sh/x86) use fpu_counter in task_struct so it
can be moved out into ARCH specific thread_struct, reducing the size of
task_struct for other arches.

Compile tested i386_defconfig + gcc 4.7.3

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Vincent Palatin <vpalatin@chromium.org>
Cc: Len Brown <len.brown@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Pekka Riikonen <priikone@iki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/x86/include/asm/fpu-internal.h | 10 +++++-----
 arch/x86/include/asm/processor.h    |  9 +++++++++
 arch/x86/kernel/i387.c              |  2 +-
 arch/x86/kernel/process_32.c        |  4 ++--
 arch/x86/kernel/process_64.c        |  2 +-
 arch/x86/kernel/traps.c             |  2 +-
 6 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/fpu-internal.h b/arch/x86/include/asm/fpu-internal.h
index 4d0bda7..c49a613 100644
--- a/arch/x86/include/asm/fpu-internal.h
+++ b/arch/x86/include/asm/fpu-internal.h
@@ -365,7 +365,7 @@ static inline void drop_fpu(struct task_struct *tsk)
 	 * Forget coprocessor state..
 	 */
 	preempt_disable();
-	tsk->fpu_counter = 0;
+	tsk->thread.fpu_counter = 0;
 	__drop_fpu(tsk);
 	clear_used_math();
 	preempt_enable();
@@ -424,7 +424,7 @@ static inline fpu_switch_t switch_fpu_prepare(struct task_struct *old, struct ta
 	 * or if the past 5 consecutive context-switches used math.
 	 */
 	fpu.preload = tsk_used_math(new) && (use_eager_fpu() ||
-					     new->fpu_counter > 5);
+					     new->thread.fpu_counter > 5);
 	if (__thread_has_fpu(old)) {
 		if (!__save_init_fpu(old))
 			cpu = ~0;
@@ -433,16 +433,16 @@ static inline fpu_switch_t switch_fpu_prepare(struct task_struct *old, struct ta
 
 		/* Don't change CR0.TS if we just switch! */
 		if (fpu.preload) {
-			new->fpu_counter++;
+			new->thread.fpu_counter++;
 			__thread_set_has_fpu(new);
 			prefetch(new->thread.fpu.state);
 		} else if (!use_eager_fpu())
 			stts();
 	} else {
-		old->fpu_counter = 0;
+		old->thread.fpu_counter = 0;
 		old->thread.fpu.last_cpu = ~0;
 		if (fpu.preload) {
-			new->fpu_counter++;
+			new->thread.fpu_counter++;
 			if (!use_eager_fpu() && fpu_lazy_restore(new, cpu))
 				fpu.preload = 0;
 			else
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 24cf5ae..e331f3a 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -488,6 +488,15 @@ struct thread_struct {
 	unsigned long		iopl;
 	/* Max allowed port in the bitmap, in bytes: */
 	unsigned		io_bitmap_max;
+	/*
+	 * fpu_counter contains the number of consecutive context switches
+	 * that the FPU is used. If this is over a threshold, the lazy fpu
+	 * saving becomes unlazy to save the trap. This is an unsigned char
+	 * so that after 256 times the counter wraps and the behavior turns
+	 * lazy again; this to deal with bursty apps that only use FPU for
+	 * a short time
+	 */
+	unsigned char fpu_counter;
 };
 
 /*
diff --git a/arch/x86/kernel/i387.c b/arch/x86/kernel/i387.c
index 5d576ab..e8368c6 100644
--- a/arch/x86/kernel/i387.c
+++ b/arch/x86/kernel/i387.c
@@ -100,7 +100,7 @@ void unlazy_fpu(struct task_struct *tsk)
 		__save_init_fpu(tsk);
 		__thread_fpu_end(tsk);
 	} else
-		tsk->fpu_counter = 0;
+		tsk->thread.fpu_counter = 0;
 	preempt_enable();
 }
 EXPORT_SYMBOL(unlazy_fpu);
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index f8adefc..4de6e36 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -153,7 +153,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 		childregs->orig_ax = -1;
 		childregs->cs = __KERNEL_CS | get_kernel_rpl();
 		childregs->flags = X86_EFLAGS_IF | X86_EFLAGS_FIXED;
-		p->fpu_counter = 0;
+		p->thread.fpu_counter = 0;
 		p->thread.io_bitmap_ptr = NULL;
 		memset(p->thread.ptrace_bps, 0, sizeof(p->thread.ptrace_bps));
 		return 0;
@@ -166,7 +166,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	p->thread.ip = (unsigned long) ret_from_fork;
 	task_user_gs(p) = get_user_gs(current_pt_regs());
 
-	p->fpu_counter = 0;
+	p->thread.fpu_counter = 0;
 	p->thread.io_bitmap_ptr = NULL;
 	tsk = current;
 	err = -ENOMEM;
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 05646ba..9b97949 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -163,7 +163,7 @@ int copy_thread(unsigned long clone_flags, unsigned long sp,
 	p->thread.sp = (unsigned long) childregs;
 	p->thread.usersp = me->thread.usersp;
 	set_tsk_thread_flag(p, TIF_FORK);
-	p->fpu_counter = 0;
+	p->thread.fpu_counter = 0;
 	p->thread.io_bitmap_ptr = NULL;
 
 	savesegment(gs, p->thread.gsindex);
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 1b23a1c..f350d7e 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -649,7 +649,7 @@ void math_state_restore(void)
 		return;
 	}
 
-	tsk->fpu_counter++;
+	tsk->thread.fpu_counter++;
 }
 EXPORT_SYMBOL_GPL(math_state_restore);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
