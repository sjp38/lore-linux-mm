Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DC76C6B00A8
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:07:40 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 00:37:36 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ7Wgn4350112
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 00:37:32 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ7VuN023788
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:07:32 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:12:37 +0530
Message-Id: <20111110184237.11361.87061.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 25/28]   uprobes: call post_xol() unconditionally
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
 kernel/uprobes.c        |   40 ++++++++++++----------------------------
 2 files changed, 14 insertions(+), 29 deletions(-)

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
index 9e73cef..13b1d68 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1316,24 +1316,6 @@ static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
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
@@ -1381,17 +1363,18 @@ void uprobe_notify_resume(struct pt_regs *regs)
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
-
-			/* TODO Stop queueing signals. */
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
 
@@ -1441,6 +1424,7 @@ int uprobe_post_notifier(struct pt_regs *regs)
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
