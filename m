Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C6C286B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:56:27 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:52:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 8/X] uprobes: kill sstep_complete()
Message-ID: <20111019215206.GB16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

Kill sstep_complete(), change uprobe_notify_resume() to use post_xol()
unconditionally.

As we already discussed, it is wrong to assume that regs->ip always
changes after the step. rep or jmp/call to self for example. We know
that this task has already done the step, we can rely on DIE_DEBUG
notification.
---
 kernel/uprobes.c |   37 +++++++++----------------------------
 1 files changed, 9 insertions(+), 28 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index a323e0a..135b9a2 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1321,24 +1321,6 @@ static int pre_ssout(struct uprobe *uprobe, struct pt_regs *regs,
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
@@ -1374,7 +1356,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			if (!utask)
 				goto cleanup_ret;
 		}
-		/* TODO Start queueing signals. */
+
 		utask->active_uprobe = u;
 		handler_chain(u, regs);
 		utask->state = UTASK_SSTEP;
@@ -1385,15 +1367,14 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			goto cleanup_ret;
 	} else if (utask->state == UTASK_SSTEP) {
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
+
+		post_xol(u, regs);	/* TODO: check result? */
+
+		put_uprobe(u);
+		utask->active_uprobe = NULL;
+		utask->state = UTASK_RUNNING;
+		user_disable_single_step(current);
+		xol_free_insn_slot(current);
 	}
 	return;
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
