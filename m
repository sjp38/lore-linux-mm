Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF7336B00A9
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:38:12 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 11:36:19 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBc2B15341410
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:02 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBc0rW010396
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:02 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:41:54 +0530
Message-Id: <20111118111154.10512.39486.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 26/30] uprobes: introduce uprobe_deny_signal()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


A not-UTASK_RUNNING task obviously can't handle the signals, neither
it should stop/freeze/etc. It must not even exit if it was
SIGKILL'ed

This patch adds the new hook, uprobe_deny_signal(), called by
get_signal_to_deliver(). It simply clears TIF_SIGPENDING to ensure
that this thread can do nothing connected to signals until it
becomes UTASK_RUNNING.

We also change post_xol() path to do recalc_sigpending() before
return to user-mode, this ensures the signal can't be lost.

Original-patch-from: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    5 +++++
 kernel/signal.c         |    3 +++
 kernel/uprobes.c        |   23 +++++++++++++++++++++++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 70d639c..8d12c06 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -129,6 +129,7 @@ extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
 extern int uprobe_post_notifier(struct pt_regs *regs);
 extern int uprobe_bkpt_notifier(struct pt_regs *regs);
 extern void uprobe_notify_resume(struct pt_regs *regs);
+extern bool uprobe_deny_signal(void);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -149,6 +150,10 @@ static inline void munmap_uprobe(struct vm_area_struct *vma)
 static inline void uprobe_notify_resume(struct pt_regs *regs)
 {
 }
+static inline bool uprobe_deny_signal(void)
+{
+	return false;
+}
 static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
 {
 	return 0;
diff --git a/kernel/signal.c b/kernel/signal.c
index b3f78d0..5d68510 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2149,6 +2149,9 @@ int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
 	struct signal_struct *signal = current->signal;
 	int signr;
 
+	if (unlikely(uprobe_deny_signal()))
+		return 0;
+
 relock:
 	/*
 	 * We'll jump back here after any time we were stopped in TASK_STOPPED.
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 50cde86..3e7c4c5 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1312,6 +1312,25 @@ static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
 	return -EFAULT;
 }
 
+bool uprobe_deny_signal(void)
+{
+	struct task_struct *tsk = current;
+	struct uprobe_task *utask = tsk->utask;
+
+	if (likely(!utask || !utask->active_uprobe))
+		return false;
+
+	WARN_ON_ONCE(utask->state != UTASK_SSTEP);
+
+	if (signal_pending(tsk)) {
+		spin_lock_irq(&tsk->sighand->siglock);
+		clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
+		spin_unlock_irq(&tsk->sighand->siglock);
+	}
+
+	return true;
+}
+
 /*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
@@ -1371,6 +1390,10 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		utask->state = UTASK_RUNNING;
 		user_disable_single_step(current);
 		xol_free_insn_slot(current);
+
+		spin_lock_irq(&current->sighand->siglock);
+		recalc_sigpending(); /* see uprobe_deny_signal() */
+		spin_unlock_irq(&current->sighand->siglock);
 	}
 	return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
