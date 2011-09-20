Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B65DC9000C9
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 08:17:12 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id p8KCH1Fu004640
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:47:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KCGvVT1347746
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:46:57 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KCGuJr023709
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 22:16:57 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 20 Sep 2011 17:33:25 +0530
Message-Id: <20110920120325.25326.11641.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v5 3.1.0-rc4-tip 17/26]   x86: arch specific hooks for pre/post singlestep handling.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>


Hooks for handling pre singlestepping and post singlestepping.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/uprobes.h |    2 +
 arch/x86/kernel/uprobes.c      |  138 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 140 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 2ad2c71..1c30cfd 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -47,6 +47,8 @@ struct uprobe_task_arch_info {};
 struct uprobe;
 extern int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe);
 extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
+extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int uprobe_exception_notify(struct notifier_block *self,
 				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 8ec759a..da1bc12 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -25,6 +25,7 @@
 #include <linux/sched.h>
 #include <linux/ptrace.h>
 #include <linux/uprobes.h>
+#include <linux/uaccess.h>
 
 #include <linux/kdebug.h>
 #include <asm/insn.h>
@@ -395,6 +396,143 @@ void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
 }
 
 /*
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
+	pr_warn_once("uprobes: Failed to adjust return address after"
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
+/*
  * Wrapper routine for handling exceptions.
  */
 int uprobe_exception_notify(struct notifier_block *self,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
