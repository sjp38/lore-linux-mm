Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A816E8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:45:01 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p31Diu6X006788
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 19:14:56 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EisJl2736200
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:14:54 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EirnZ020838
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:44:54 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:05:17 +0530
Message-Id: <20110401143517.15455.88373.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 14/26] 14: x86: x86 specific probe handling
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>


Provides x86 specific implementations for setting the current
instruction pointer, pre single-step and post-singlestep handling,
enabling and disabling singlestep.

This patch also introduces TIF_UPROBE which is set by uprobes notifier
code. TIF_UPROBE indicates that there is pending work that needs to be
done at do_notify_resume time.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/thread_info.h |    2 
 arch/x86/include/asm/uprobes.h     |    5 +
 arch/x86/kernel/uprobes.c          |  171 ++++++++++++++++++++++++++++++++++++
 3 files changed, 178 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index 1f2e61e..2dc1921 100644
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
index e38950f..0c9c8b6 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -44,4 +44,9 @@ struct uprobe_task_arch_info {};
 #endif
 struct uprobe;
 extern int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe);
+extern void set_ip(struct pt_regs *regs, unsigned long vaddr);
+extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern void arch_uprobe_enable_sstep(struct pt_regs *regs);
+extern void arch_uprobe_disable_sstep(struct pt_regs *regs);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index f81e940..bf98841 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -25,6 +25,7 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <linux/uprobes.h>
+#include <linux/uaccess.h>
 
 #include <linux/kdebug.h>
 #include <asm/insn.h>
@@ -412,3 +413,173 @@ int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe)
 	prepare_fixups(uprobe, &insn);
 	return 0;
 }
+
+/*
+ * @reg: reflects the saved state of the task
+ * @vaddr: the virtual address to jump to.
+ * Return 0 on success or a -ve number on error.
+ */
+void set_ip(struct pt_regs *regs, unsigned long vaddr)
+{
+	regs->ip = vaddr;
+}
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
+	regs->ip = current->utask->xol_vaddr;
+	if (uprobe->fixups & UPROBES_FIX_RIP_AX) {
+		tskinfo->saved_scratch_register = regs->ax;
+		regs->ax = current->utask->vaddr;
+		regs->ax += uprobe->arch_info.rip_rela_target_address;
+	} else if (uprobe->fixups & UPROBES_FIX_RIP_CX) {
+		tskinfo->saved_scratch_register = regs->cx;
+		regs->cx = current->utask->vaddr;
+		regs->cx += uprobe->arch_info.rip_rela_target_address;
+	}
+	return 0;
+}
+#else
+int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
+{
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
+	ncopied = copy_from_user(&ra, (void __user *) sp, rasize);
+	if (unlikely(ncopied))
+		goto fail;
+	ra += correction;
+	ncopied = copy_to_user((void __user *) sp, &ra, rasize);
+	if (unlikely(ncopied))
+		goto fail;
+	return 0;
+
+fail:
+	printk(KERN_ERR
+		"uprobes: Failed to adjust return address after"
+		" single-stepping call instruction;"
+		" pid=%d, sp=%#lx\n", current->pid, sp);
+	return -EFAULT;
+}
+
+#ifdef CONFIG_X86_64
+static bool is_riprel_insn(struct uprobe *uprobe)
+{
+	return ((uprobe->fixups &
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
+		if (uprobe->fixups & UPROBES_FIX_RIP_AX)
+			regs->ax = tskinfo->saved_scratch_register;
+		else
+			regs->cx = tskinfo->saved_scratch_register;
+		/*
+		 * The original instruction includes a displacement, and so
+		 * is 4 bytes longer than what we've just single-stepped.
+		 * Fall through to handle stuff like "jmpq *...(%rip)" and
+		 * "callq *...(%rip)".
+		 */
+		*correction += 4;
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
+	correction = (long)(utask->vaddr - utask->xol_vaddr);
+	handle_riprel_post_xol(uprobe, regs, &correction);
+	if (uprobe->fixups & UPROBES_FIX_IP)
+		regs->ip += correction;
+	if (uprobe->fixups & UPROBES_FIX_CALL)
+		result = adjust_ret_addr(regs->sp, correction);
+	return result;
+}
+
+void arch_uprobe_enable_sstep(struct pt_regs *regs)
+{
+	/*
+	 * Enable single-stepping by
+	 * - Set TF on stack
+	 * - Set TIF_SINGLESTEP: Guarantees that TF is set when
+	 *	returning to user mode.
+	 *  - Indicate that TF is set by us.
+	 */
+	regs->flags |= X86_EFLAGS_TF;
+	set_thread_flag(TIF_SINGLESTEP);
+	set_thread_flag(TIF_FORCED_TF);
+}
+
+void arch_uprobe_disable_sstep(struct pt_regs *regs)
+{
+	/* Disable single-stepping by clearing what we set */
+	clear_thread_flag(TIF_SINGLESTEP);
+	clear_thread_flag(TIF_FORCED_TF);
+	regs->flags &= ~X86_EFLAGS_TF;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
