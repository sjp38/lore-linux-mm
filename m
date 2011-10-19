Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DCAA66B0030
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:57:42 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:53:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 12/X] uprobes: x86: introduce abort_xol()
Message-ID: <20111019215326.GF16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

A separate "patch", just to emphasize that I do not know what
actually abort_xol() should do! I do not understand this asm
magic.

This patch simply changes regs->ip back to the probed insn,
obviously this is not enough to handle UPROBES_FIX_*. Please
take care.

If it is not clear, abort_xol() is needed when we should
re-execute the original insn (replaced with int3), see the
next patch.
---
 arch/x86/include/asm/uprobes.h |    1 +
 arch/x86/kernel/uprobes.c      |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index f0fbdab..6209da1 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -51,6 +51,7 @@ extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);
 extern int pre_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern int post_xol(struct uprobe *uprobe, struct pt_regs *regs);
 extern bool xol_was_trapped(struct task_struct *tsk);
+extern void abort_xol(struct pt_regs *regs);
 extern int uprobe_exception_notify(struct notifier_block *self,
 				       unsigned long val, void *data);
 #endif	/* _ASM_UPROBES_H */
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index c861c27..bc11a89 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -511,6 +511,15 @@ bool xol_was_trapped(struct task_struct *tsk)
 	return false;
 }
 
+void abort_xol(struct pt_regs *regs)
+{
+	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+	// !!! Dear Srikar and Ananth, please implement me !!!
+	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
+	struct uprobe_task *utask = current->utask;
+	regs->ip = utask->vaddr;
+}
+
 /*
  * Called after single-stepping. To avoid the SMP problems that can
  * occur when we temporarily put back the original opcode to
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
