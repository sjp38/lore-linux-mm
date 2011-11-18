Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 702BA6B00AB
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:38:31 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:08:27 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBcMwS2642016
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:08:22 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBcL3f026500
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:22 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:42:19 +0530
Message-Id: <20111118111219.10512.2502.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 28/30] uprobes: introduce UTASK_SSTEP_TRAPPED logic
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
Changelog (since v6)
-	abort_xol moved to previous patch.

 include/linux/uprobes.h |    1 +
 kernel/uprobes.c        |   13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 8d12c06..6a84332 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -76,6 +76,7 @@ enum uprobe_task_state {
 	UTASK_BP_HIT,
 	UTASK_SSTEP,
 	UTASK_SSTEP_ACK,
+	UTASK_SSTEP_TRAPPED,
 };
 
 /*
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 3e7c4c5..f8c0f7c 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1326,6 +1326,12 @@ bool uprobe_deny_signal(void)
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
@@ -1382,6 +1388,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		u = utask->active_uprobe;
 		if (utask->state == UTASK_SSTEP_ACK)
 			post_xol(u, regs);
+		else if (utask->state == UTASK_SSTEP_TRAPPED)
+			abort_xol(regs, u);
 		else
 			WARN_ON_ONCE(1);
 
@@ -1405,9 +1413,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
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
