Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E34B46B002E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:57:26 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:53:07 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 11/X] uprobes: x86: introduce xol_was_trapped()
Message-ID: <20111019215307.GE16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

After the previous patch, we postpone the signals until we execute
the probed insn. This is simply wrong if xol insn traps and generates
the signal itself. Say, SIGILL/SIGSEGV/etc.

This patch only adds xol_was_trapped() to detect this case. It assumes
that anything like do_page_fault/do_trap/etc sets thread.trap_no != -1.

We add uprobe_task_arch_info->saved_trap_no and change pre_xol/post_xol
to save/restore thread.trap_no, xol_was_trapped() simply checks that
->trap_no is not equal to UPROBE_TRAP_NO == -1 set by pre_xol().
---
 arch/x86/include/asm/uprobes.h |    2 ++
 arch/x86/kernel/uprobes.c      |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 1c30cfd..f0fbdab 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -39,6 +39,7 @@ struct uprobe_arch_info {
 
 struct uprobe_task_arch_info {
 	unsigned long saved_scratch_register;
+	unsigned long saved_trap_no;
 };
 #else
 struct uprobe_arch_info {};
@@ -49,6 +50,7 @@ extern int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe);
 extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
 extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
+extern bool xol_was_trapped(struct task_struct *tsk);
 extern int uprobe_exception_notify(struct notifier_block *self,
 				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index e2e7882..c861c27 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -395,6 +395,8 @@ void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr)
 	regs->ip = vaddr;
 }
 
+#define	UPROBE_TRAP_NO	-1ul
+
 /*
  * pre_xol - prepare to execute out of line.
  * @uprobe: the probepoint information.
@@ -410,6 +412,9 @@ int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
 {
 	struct uprobe_task_arch_info *tskinfo = &current->utask->tskinfo;
 
+	tskinfo->saved_trap_no = current->thread.trap_no;
+	current->thread.trap_no = UPROBE_TRAP_NO;
+
 	regs->ip = current->utask->xol_vaddr;
 	if (uprobe->fixups & UPROBES_FIX_RIP_AX) {
 		tskinfo->saved_scratch_register = regs->ax;
@@ -425,6 +430,11 @@ int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
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
@@ -493,6 +503,14 @@ static void handle_riprel_post_xol(struct uprobe *uprobe,
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
@@ -523,6 +541,8 @@ int post_xol(struct uprobe *uprobe, struct pt_regs *regs)
 	int result = 0;
 	long correction;
 
+	current->thread.trap_no = utask->tskinfo.saved_trap_no;
+
 	correction = (long)(utask->vaddr - utask->xol_vaddr);
 	handle_riprel_post_xol(uprobe, regs, &correction);
 	if (uprobe->fixups & UPROBES_FIX_IP)
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
