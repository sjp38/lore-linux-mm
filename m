Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 218356B006E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:12:05 -0500 (EST)
Date: Mon, 28 Nov 2011 20:06:55 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 2/5] uprobes: introduce uprobe_switch_to()
Message-ID: <20111128190655.GC4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128190614.GA4602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

Introduce uprobe_switch_to(), it is called by switch_to() paths if
the "next" task is going to execute the xol insn.

Currently we use TIF_SINGLESTEP (added to _TIF_WORK_CTXSW_NEXT) to
detect this case in __switch_to_xtra() and call uprobe_switch_to(),
may be we can add another flag.

uprobe_switch_to() verifies that this task is actually UTASK_SSTEP
and X86_EFLAGS_TF is set.

Finally uprobe_switch_to() does set_xol_ip(). Currently this is not
needed, but this means that set_xol_ip() is called every time the
UTASK_SSTEP task migrates to another CPU.

To ensure set_xol_ip() can't race with itself we add preempt_disable()
into another caller, uprobe_notify_resume().

Note! this patch assumes we can trust X86_EFLAGS_TF. I mean, afaiu
even if the single-stepping insn races with irq/exception, this flag
will be cleared if and only if this instruction was already executed.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/include/asm/thread_info.h |    4 ++++
 arch/x86/kernel/process.c          |    6 ++++++
 arch/x86/kernel/uprobes.c          |   14 ++++++++++++++
 include/linux/uprobes.h            |    1 +
 kernel/uprobes.c                   |    2 ++
 5 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index aeb3e04..af711a1 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -150,7 +150,11 @@ struct thread_info {
 	(_TIF_IO_BITMAP|_TIF_NOTSC|_TIF_BLOCKSTEP)
 
 #define _TIF_WORK_CTXSW_PREV (_TIF_WORK_CTXSW|_TIF_USER_RETURN_NOTIFY)
+#ifdef CONFIG_UPROBES
+#define _TIF_WORK_CTXSW_NEXT (_TIF_WORK_CTXSW|_TIF_DEBUG|_TIF_SINGLESTEP)
+#else
 #define _TIF_WORK_CTXSW_NEXT (_TIF_WORK_CTXSW|_TIF_DEBUG)
+#endif
 
 #define PREEMPT_ACTIVE		0x10000000
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index b9b3b1a..233bf20 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -229,6 +229,12 @@ void __switch_to_xtra(struct task_struct *prev_p, struct task_struct *next_p,
 		 */
 		memset(tss->io_bitmap, 0xff, prev->io_bitmap_max);
 	}
+
+#ifdef CONFIG_UPROBES
+	if (test_tsk_thread_flag(next_p, TIF_SINGLESTEP))
+		uprobe_switch_to(next_p);
+#endif
+
 	propagate_user_return_notify(prev_p, next_p);
 }
 
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index cd086be..4140137 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -452,6 +452,20 @@ int pre_xol(struct uprobe *uprobe, struct pt_regs *regs)
 }
 #endif
 
+void uprobe_switch_to(struct task_struct *curr)
+{
+	struct uprobe_task *utask = curr->utask;
+	struct pt_regs *regs = task_pt_regs(curr);
+
+	if (!utask || utask->state != UTASK_SSTEP)
+		return;
+
+	if (!(regs->flags & X86_EFLAGS_TF))
+		return;
+
+	set_xol_ip(regs);
+}
+
 /*
  * Called by post_xol() to adjust the return address pushed by a call
  * instruction executed out of line.
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index c9ff67a..d590d66 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -141,6 +141,7 @@ extern void uprobe_notify_resume(struct pt_regs *regs);
 extern bool uprobe_deny_signal(void);
 extern bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u);
 extern void __weak set_xol_ip(struct pt_regs *regs);
+extern void uprobe_switch_to(struct task_struct *);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index b596432..9c509dc 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1399,8 +1399,10 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			goto cleanup_ret;
 
 		user_enable_single_step(current);
+		preempt_disable();
 		utask->state = UTASK_SSTEP;
 		set_xol_ip(regs);
+		preempt_enable();
 	} else {
 		u = utask->active_uprobe;
 		if (utask->state == UTASK_SSTEP_ACK)
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
