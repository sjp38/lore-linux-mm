Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 024B76B00AC
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:07:57 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id pAAJ7qDq011542
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:37:52 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ7qGX4169876
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:37:52 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ7pri028353
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:07:52 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:12:57 +0530
Message-Id: <20111110184257.11361.74052.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 27/28]   uprobes: x86: introduce xol_was_trapped()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Postpone the signals until we execute the probed insn. This is
simply wrong if xol insn traps and generates the signal itself. Say,
SIGILL/SIGSEGV/etc.

Adds xol_was_trapped() to detect this case. It assumes that anything
like do_page_fault/do_trap/etc sets thread.trap_no != -1.

We add uprobe_task_arch_info->saved_trap_no and change
pre_xol/post_xol to save/restore thread.trap_no, xol_was_trapped()
simply checks that ->trap_no is not equal to UPROBE_TRAP_NO == -1
set by pre_xol().

Original-patch-from: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/uprobes.h |    6 +++++-
 arch/x86/kernel/uprobes.c      |   21 +++++++++++++++++++++
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 99d7d4b..78e0007 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -39,16 +39,20 @@ struct uprobe_arch_info {
 
 struct uprobe_task_arch_info {
 	unsigned long saved_scratch_register;
+	unsigned long saved_trap_no;
 };
 #else
 struct uprobe_arch_info {};
-struct uprobe_task_arch_info {};
+struct uprobe_task_arch_info {
+	unsigned long saved_trap_no;
+};
 #endif
 struct uprobe;
 extern int analyze_insn(struct mm_struct *mm, struct uprobe *uprobe);
 extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
 extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern bool xol_was_trapped(struct task_struct *tsk);
 extern int uprobe_exception_notify(struct notifier_block *self,
 				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 0792fc8..f5b0841 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -409,6 +409,8 @@ void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
 	regs->ip = vaddr;
 }
 
+#define	UPROBE_TRAP_NO	-1ul
+
 /*
  * pre_xol - prepare to execute out of line.
  * @uprobe: the probepoint information.
@@ -424,6 +426,9 @@ int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
 {
 	struct uprobe_task_arch_info *tskinfo = &current->utask->tskinfo;
 
+	tskinfo->saved_trap_no = current->thread.trap_no;
+	current->thread.trap_no = UPROBE_TRAP_NO;
+
 	regs->ip = current->utask->xol_vaddr;
 	if (uprobe->fixups & UPROBES_FIX_RIP_AX) {
 		tskinfo->saved_scratch_register = regs->ax;
@@ -439,6 +444,11 @@ int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
 #else
 int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
 {
+	struct uprobe_task_arch_info *tskinfo = &current->utask->tskinfo;
+
+	tskinfo->saved_trap_no = current->thread.trap_no;
+	current->thread.trap_no = UPROBE_TRAP_NO;
+
 	regs->ip = current->utask->xol_vaddr;
 	return 0;
 }
@@ -504,6 +514,14 @@ static void handle_riprel_post_xol(struct uprobe *uprobe,
 }
 #endif
 
+bool xol_was_trapped(struct task_struct *tsk)
+{
+	if (tsk->thread.trap_no != UPROBE_TRAP_NO)
+		return true;
+
+	return false;
+}
+
 /*
  * Called after single-stepping. To avoid the SMP problems that can
  * occur when we temporarily put back the original opcode to
@@ -534,6 +552,9 @@ int post_xol(struct uprobe *uprobe, struct pt_regs *regs)
 	int result = 0;
 	long correction;
 
+	WARN_ON_ONCE(current->thread.trap_no != UPROBE_TRAP_NO);
+
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
 	correction = (long)(utask->vaddr - utask->xol_vaddr);
 	handle_riprel_post_xol(uprobe, regs, &correction);
 	if (uprobe->fixups & UPROBES_FIX_IP)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
