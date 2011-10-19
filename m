Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 123796B002E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:56:48 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:52:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 9/X] uprobes: introduce UTASK_SSTEP_ACK state
Message-ID: <20111019215226.GC16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

Introduce the new state, UTASK_SSTEP_ACK. uprobe_post_notifier()
sets this state like uprobe_bkpt_notifier() sets UTASK_BP_HIT.

Change uprobe_notify_resume() to always do the post_xol() logic
if state != UTASK_BP_HIT and WARN() if the utask->state is wrong.

This makes the state transitions more explicit. The current code
returns silently if, say, state == UTASK_RUNNING. But this must
not happen, we should complain in this case. And, with the new
state we know for sure that DIE_DEBUG was triggered.
---
 include/linux/uprobes.h |    3 ++-
 kernel/uprobes.c        |   15 ++++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index a407d17..1591c7c 100644
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
index 135b9a2..5fd72b8 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1365,10 +1365,13 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		else
 			/* Cannot Singlestep; re-execute the instruction. */
 			goto cleanup_ret;
-	} else if (utask->state == UTASK_SSTEP) {
+	} else {
 		u = utask->active_uprobe;
 
-		post_xol(u, regs);	/* TODO: check result? */
+		if (utask->state == UTASK_SSTEP_ACK)
+			post_xol(u, regs);	/* TODO: check result? */
+		else
+			WARN_ON_ONCE(1);
 
 		put_uprobe(u);
 		utask->active_uprobe = NULL;
@@ -1416,15 +1419,13 @@ int uprobe_bkpt_notifier(struct pt_regs *regs)
  */
 int uprobe_post_notifier(struct pt_regs *regs)
 {
-	struct uprobe *uprobe;
-	struct uprobe_task *utask;
+	struct uprobe_task *utask = current->utask;
 
-	if (!current->mm || !current->utask || !current->utask->active_uprobe)
+	if (!current->mm || !utask || !utask->active_uprobe)
 		/* task is currently not uprobed */
 		return 0;
 
-	utask = current->utask;
-	uprobe = utask->active_uprobe;
+	utask->state = UTASK_SSTEP_ACK;
 	set_thread_flag(TIF_UPROBE);
 	return 1;
 }
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
