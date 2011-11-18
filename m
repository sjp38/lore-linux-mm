Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCA56B00A7
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:37:53 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 11:36:04 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBblJP5365952
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:37:47 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBbjQL008556
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:37:47 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:41:39 +0530
Message-Id: <20111118111139.10512.21445.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 25/30] uprobes: call post_xol() unconditionally
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Kill sstep_complete(), change uprobe_notify_resume() to use
post_xol() unconditionally.

It is wrong to assume that regs->ip always changes after the step.
rep or jmp/call to self for example. We know that this task has
already done the step, we can rely on DIE_DEBUG notification.

Original-patch-from: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |    3 ++-
 kernel/uprobes.c        |   38 ++++++++++++--------------------------
 2 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index add5222..70d639c 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -74,7 +74,8 @@ struct uprobe {
 enum uprobe_task_state {
 	UTASK_RUNNING,
 	UTASK_BP_HIT,
-	UTASK_SSTEP
+	UTASK_SSTEP,
+	UTASK_SSTEP_ACK,
 };
 
 /*
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index b440acd..50cde86 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1313,24 +1313,6 @@ static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
 }
 
 /*
- * Verify from Instruction Pointer if singlestep has indeed occurred.
- * If Singlestep has occurred, then do post singlestep fix-ups.
- */
-static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
-{
-	unsigned long vaddr = instruction_pointer(regs);
-
-	/*
-	 * If we have executed out of line, Instruction pointer
-	 * cannot be same as virtual address of XOL slot.
-	 */
-	if (vaddr == current->utask->xol_vaddr)
-		return false;
-	post_xol(uprobe, regs);
-	return true;
-}
-
-/*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
  *
@@ -1377,15 +1359,18 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		else
 			/* Cannot Singlestep; re-execute the instruction. */
 			goto cleanup_ret;
-	} else if (utask->state == UTASK_SSTEP) {
+	} else {
 		u = utask->active_uprobe;
-		if (sstep_complete(u, regs)) {
-			put_uprobe(u);
-			utask->active_uprobe = NULL;
-			utask->state = UTASK_RUNNING;
-			user_disable_single_step(current);
-			xol_free_insn_slot(current);
-		}
+		if (utask->state == UTASK_SSTEP_ACK)
+			post_xol(u, regs);
+		else
+			WARN_ON_ONCE(1);
+
+		put_uprobe(u);
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+		user_disable_single_step(current);
+		xol_free_insn_slot(current);
 	}
 	return;
 
@@ -1435,6 +1420,7 @@ int uprobe_post_notifier(struct pt_regs *regs)
 		/* task is currently not uprobed */
 		return 0;
 
+	utask->state = UTASK_SSTEP_ACK;
 	set_thread_flag(TIF_UPROBE);
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
