Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25ACD6B002F
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:44:58 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9BHKd3V004478
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:20:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9BHio2B210466
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:44:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9BHikgl027119
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 13:44:50 -0400
Date: Tue, 11 Oct 2011 22:56:03 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
 thread is singlestepping.
Message-ID: <20111011172603.GD16268@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com>
 <1317128626.15383.61.camel@twins>
 <20110927131213.GE3685@linux.vnet.ibm.com>
 <20111005180139.GA5704@redhat.com>
 <20111006054710.GB17591@linux.vnet.ibm.com>
 <20111007165828.GA32319@redhat.com>
 <20111010122556.GB16268@linux.vnet.ibm.com>
 <20111010182535.GA6934@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111010182535.GA6934@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-10 20:25:35]:

> On 10/10, Srikar Dronamraju wrote:
> >
> > While we are here, do you suggest I re-use current->saved_sigmask and
> > hence use set_restore_sigmask() while resetting the sigmask?
> >
> > I see saved_sigmask being used just before task sleeps and restored when
> > task is scheduled back. So I dont see a case where using saved_sigmask
> > in uprobes could conflict with its current usage.
> 
> Yes, I think this is possible, and probably you do not even need
> set_restore_sigmask().
> 
> But. There are some problems with this approach too.
> 
> Firstly, even if you block all signals, there are other reasons for
> TIF_SIGPENDING which you can't control. For example, the task can be
> frozen or it can stop in UTASK_SSTEP state. Not good, if we have
> enough threads, this can lead to the "soft" deadlock. Say, a group
> stop can never finish because a thread sleeps in xol_wait_event()
> "forever".
> 

My idea was to block signals just across singlestep only. I.e 
we dont block signals while we contend for the slot. 

> Another problem is that it is not possible to block the "implicit"
> SIGKILL sent by exec/exit_group/etc. This mean the task can exit
> without sstep_complete/xol_free_insn_slot/etc. Mostly this is fine,
> we have free_uprobe_utask()->xol_free_insn_slot(). But in theory
> this can deadlock afaics. Suppose that the coredumping is in progress,
> the killed UTASK_SSTEP task hangs in exit_mm() waiting for other
> threads. If we have enough threads like this, we can deadlock with
> another thread sleeping in xol_wait_event().

Shouldnt the behaviour be the same as threads that did a
select,sigsuspend?

> 
> This can be fixed, we can move free_uprobe_utask() from
> put_task_struct() to mm_release(). Btw, imho this makes sense anyway,
> why should a zombie thread abuse a slot?
> 

Yes,, makes sense. Will make this change.

> However the first problem looks nasty, even if it is not very serious.
> And, otoh, it doesn't look right to block SIGKILL, the task can loop
> forever executing the xol insn (see below).
> 
> 
> 
> What do you think about the patch below? On top of 25/26, uncompiled,
> untested. With this patch the task simply refuses to react to
> TIF_SIGPENDING until sstep_complete().
> 

Your patch looks very simple and clean.
Will test this patch and revert. 

> This relies on the fact that do_notify_resume() calls
> uprobe_notify_resume() before do_signal(), I guess this is safe because
> we have other reasons for this order.
> 
> And, unless I missed something, this makes
> free_uprobe_utask()->xol_free_insn_slot() unnecessary.

What if a fatal (SIGKILL) signal was delivered only to that thread even
before it singlestepped? or a fatal signal for a thread-group but more
than one thread-group share the mm?
> 
> 
> 
> HOWEVER! I simply do not know what should we do if the probed insn
> is something like asm("1:; jmp 1b;"). IIUC, in this sstep_complete()
> never returns true. The patch also adds the fatal_signal_pending()
> check to make this task killlable, but the problem is: whatever we do,
> I do not think it is correct to disable/delay the signals in this case.
> With any approach.
> 
> What do you think? Maybe we should simply disallow to probe such insns?

Yes, we should disable such probes, but iam not sure we can detect such
probes with the current instruction analyzer.

Masami, can we detect them (instructions that jump back to the same
address as they are executing?)

> 
> Once again, the change in sstep_complete() is "off-topic", this is
> another problem we should solve somehow.
> 

Agree.

you have already commented why blocking signals is a problem, but I
still thought I will post the patch that I had to let you know what I
was thinking before I saw your patch.

While task is processing a singlestep due to uprobes breakpoint hit, 
block signals from the time it enables singlestep to the time it disables
singlestep.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/uprobes.c |   38 ++++++++++++++++++++++++++++++++------
 1 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 5067979..bc3e178 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1366,6 +1366,26 @@ static bool sstep_complete(struct uprobe *uprobe, struct pt_regs *regs)
 }
 
 /*
+ * While we are handling breakpoint / singlestep, ensure that a
+ * SIGTRAP is not delivered to the task.
+ */
+static void __clear_trap_flag(void)
+{
+	sigdelset(&current->pending.signal, SIGTRAP);
+	sigdelset(&current->signal->shared_pending.signal, SIGTRAP);
+}
+
+static void clear_trap_flag(void)
+{
+	if (!test_and_clear_thread_flag(TIF_SIGPENDING))
+		return;
+
+	spin_lock_irq(&current->sighand->siglock);
+	__clear_trap_flag();
+	spin_unlock_irq(&current->sighand->siglock);
+}
+
+/*
  * uprobe_notify_resume gets called in task context just before returning
  * to userspace.
  *
@@ -1380,6 +1400,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 	struct mm_struct *mm;
 	struct uprobe *u = NULL;
 	unsigned long probept;
+	sigset_t masksigs;
 
 	utask = current->utask;
 	mm = current->mm;
@@ -1401,13 +1422,18 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			if (!utask)
 				goto cleanup_ret;
 		}
-		/* TODO Start queueing signals. */
 		utask->active_uprobe = u;
 		handler_chain(u, regs);
 		utask->state = UTASK_SSTEP;
-		if (!pre_ssout(u, regs, probept))
+		if (!pre_ssout(u, regs, probept)) {
+			sigfillset(&masksigs);
+			sigdelsetmask(&masksigs,
+					sigmask(SIGKILL)|sigmask(SIGSTOP));
+			current->saved_sigmask = current->blocked;
+			set_current_blocked(&masksigs);
+			clear_trap_flag();
 			user_enable_single_step(current);
-		else
+		} else
 			/* Cannot Singlestep; re-execute the instruction. */
 			goto cleanup_ret;
 	} else if (utask->state == UTASK_SSTEP) {
@@ -1418,8 +1444,8 @@ void uprobe_notify_resume(struct pt_regs *regs)
 			utask->state = UTASK_RUNNING;
 			user_disable_single_step(current);
 			xol_free_insn_slot(current);
-
-			/* TODO Stop queueing signals. */
+			clear_trap_flag();
+			set_restore_sigmask();
 		}
 	}
 	return;
@@ -1433,7 +1459,7 @@ void uprobe_notify_resume(struct pt_regs *regs)
 		put_uprobe(u);
 		set_instruction_pointer(regs, probept);
 	} else
-		/*TODO Return SIGTRAP signal */
+		send_sig(SIGTRAP, current, 0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
