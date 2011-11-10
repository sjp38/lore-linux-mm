Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1446C6B00AE
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:08:10 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:38:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ82dO3592198
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:38:02 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ81KE015523
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:08:02 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:13:07 +0530
Message-Id: <20111110184307.11361.8163.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 28/28]   uprobes: introduce UTASK_SSTEP_TRAPPED logic
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Add UTASK_SSTEP_TRAPPED state/code to handle the case when
xol insn itself triggers the signal.

In this case we should restart the original insn even if the task is
already SIGKILL'ed (say, the coredump should report the correct ip).
This is even more important if the task has a handler for SIGSEGV/etc,
The _same_ instruction should be repeated again after return from the
signal handler, and SSTEP can never finish in this case.

Change uprobe_deny_signal() to set UTASK_SSTEP_TRAPPED and TIF_UPROBE. It
also sets TIF_NOTIFY_RESUME.

When uprobe_notify_resume() sees UTASK_SSTEP_TRAPPED it does abort_xol()
instead of post_xol().

Original-patch-from: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    2 ++
 kernel/uprobes.c        |   18 +++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 8d12c06..cd522b8 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -76,6 +76,7 @@ enum uprobe_task_state {
 	UTASK_BP_HIT,
 	UTASK_SSTEP,
 	UTASK_SSTEP_ACK,
+	UTASK_SSTEP_TRAPPED,
 };
 
 /*
@@ -130,6 +131,7 @@ extern int uprobe_post_notifier(struct pt_regs *regs);
 extern int uprobe_bkpt_notifier(struct pt_regs *regs);
 extern void uprobe_notify_resume(struct pt_regs *regs);
 extern bool uprobe_deny_signal(void);
+extern void __weak abort_xol(struct pt_regs *regs, struct uprobe_task *utask);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index c7de542..a45089c 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1329,11 +1329,22 @@ bool uprobe_deny_signal(void)
 		spin_lock_irq(&tsk->sighand->siglock);
 		clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
 		spin_unlock_irq(&tsk->sighand->siglock);
+
+		if (__fatal_signal_pending(tsk) || xol_was_trapped(tsk)) {
+			utask->state = UTASK_SSTEP_TRAPPED;
+			set_tsk_thread_flag(tsk, TIF_UPROBE);
+			set_tsk_thread_flag(tsk, TIF_NOTIFY_RESUME);
+		}
 	}
 
 	return true;
 }
 
+void __weak abort_xol(struct pt_regs *regs, struct uprobe_task *utask)
+{
+	set_instruction_pointer(regs, utask->vaddr);
+}
+
 /*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
@@ -1386,6 +1397,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		u = utask->active_uprobe;
 		if (utask->state == UTASK_SSTEP_ACK)
 			post_xol(u, regs);
+		else if (utask->state == UTASK_SSTEP_TRAPPED)
+			abort_xol(regs, utask);
 		else
 			WARN_ON_ONCE(1);
 
@@ -1409,9 +1422,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 	if (u) {
 		put_uprobe(u);
 		set_instruction_pointer(regs, probept);
-	} else {
-		/*TODO Return SIGTRAP signal */
-	}
+	} else
+		send_sig(SIGTRAP, current, 0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
