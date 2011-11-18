Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 53E3B6B00B3
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:39:38 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:09:31 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBcCJ84071468
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:08:12 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBcAbc027382
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:11 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:42:09 +0530
Message-Id: <20111118111209.10512.44161.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 27/30] uprobes: x86: introduce xol_was_trapped()
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

Changelog (since v6)
- added x86 specific hook for aborting xol.

 arch/x86/include/asm/uprobes.h |    7 ++++++-
 arch/x86/kernel/uprobes.c      |   33 ++++++++++++++++++++++++++++++++-
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 99d7d4b..6a47024 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -39,16 +39,21 @@ struct uprobe_arch_info {
 
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
+extern void abort_xol(struct pt_regs *regs, struct uprobe *uprobe);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 0792fc8..3f0eb4e 100644
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
@@ -494,7 +504,8 @@ static void handle_riprel_post_xol(struct uprobe *uprobe,
 		 * Fall through to handle stuff like "jmpq *...(%rip)" and
 		 * "callq *...(%rip)".
 		 */
-		*correction += 4;
+		if (correction)
+			*correction += 4;
 	}
 }
 #else
@@ -504,6 +515,14 @@ static void handle_riprel_post_xol(struct uprobe *uprobe,
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
@@ -534,6 +553,9 @@ int post_xol(struct uprobe *uprobe, struct pt_regs *regs)
 	int result = 0;
 	long correction;
 
+	WARN_ON_ONCE(current->thread.trap_no != UPROBE_TRAP_NO);
+
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
 	correction = (long)(utask->vaddr - utask->xol_vaddr);
 	handle_riprel_post_xol(uprobe, regs, &correction);
 	if (uprobe->fixups & UPROBES_FIX_IP)
@@ -571,3 +593,12 @@ int uprobe_exception_notify(struct notifier_block *self,
 	}
 	return ret;
 }
+
+void abort_xol(struct pt_regs *regs, struct uprobe *uprobe)
+{
+	struct uprobe_task *utask = current->utask;
+
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
+	handle_riprel_post_xol(uprobe, regs, NULL);
+	set_instruction_pointer(regs, utask->vaddr);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
