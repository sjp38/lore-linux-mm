Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id F1A5F6B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:58:01 -0400 (EDT)
Date: Wed, 19 Oct 2011 23:53:44 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 13/X] uprobes: introduce UTASK_SSTEP_TRAPPED logic
Message-ID: <20111019215344.GG16395@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com> <20111019215139.GA16395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111019215139.GA16395@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

Finally, add UTASK_SSTEP_TRAPPED state/code to handle the case when
xol insn itself triggers the signal.

In this case we should restart the original insn even if the task is
already SIGKILL'ed (say, the coredump should report the correct ip).
This is even more important if the task has a handler for SIGSEGV/etc,
The _same_ instruction should be repeated again after return from the
signal handler, and SSTEP can never finish in this case.

So this patch changes uprobe_deny_signal() to set UTASK_SSTEP_TRAPPED
and TIF_UPROBE. It also sets TIF_NOTIFY_RESUME, _afaics_ TIF_UPROBE
alone is not enough to trigger do_notify_resume() in this case.

When uprobe_notify_resume() sees UTASK_SSTEP_TRAPPED it does abort_xol()
instead of post_xol().
---
 arch/x86/kernel/uprobes.c |    1 +
 include/linux/uprobes.h   |    1 +
 kernel/uprobes.c          |    8 ++++++++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index bc11a89..73f58ad 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -550,6 +550,7 @@ int post_xol(struct uprobe *uprobe, struct pt_regs *regs)
 	int result = 0;
 	long correction;
 
+	WARN_ON_ONCE(current->thread.trap_no != UPROBE_TRAP_NO);
 	current->thread.trap_no = utask->tskinfo.saved_trap_no;
 
 	correction = (long)(utask->vaddr - utask->xol_vaddr);
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 27928e5..2b4bc8c 100644
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
index d6f4508..aa5492a 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1334,6 +1334,12 @@ bool uprobe_deny_signal(void)
 		spin_lock_irq(&tsk->sighand->siglock);
 		clear_tsk_thread_flag(tsk, TIF_SIGPENDING);
 		spin_unlock_irq(&tsk->sighand->siglock);
+
+		if (xol_was_trapped(tsk)) {
+			utask->state = UTASK_SSTEP_TRAPPED;
+			set_tsk_thread_flag(tsk, TIF_UPROBE);
+			set_tsk_thread_flag(tsk, TIF_NOTIFY_RESUME);
+		}
 	}
 
 	return true;
@@ -1389,6 +1395,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 
 		if (utask->state == UTASK_SSTEP_ACK)
 			post_xol(u, regs);	/* TODO: check result? */
+		else if (utask->state == UTASK_SSTEP_TRAPPED)
+			abort_xol(regs);
 		else
 			WARN_ON_ONCE(1);
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
