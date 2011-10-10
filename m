Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A48D16B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 14:30:12 -0400 (EDT)
Date: Mon, 10 Oct 2011 20:25:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
	thread is singlestepping.
Message-ID: <20111010182535.GA6934@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com> <1317128626.15383.61.camel@twins> <20110927131213.GE3685@linux.vnet.ibm.com> <20111005180139.GA5704@redhat.com> <20111006054710.GB17591@linux.vnet.ibm.com> <20111007165828.GA32319@redhat.com> <20111010122556.GB16268@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111010122556.GB16268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 10/10, Srikar Dronamraju wrote:
>
> While we are here, do you suggest I re-use current->saved_sigmask and
> hence use set_restore_sigmask() while resetting the sigmask?
>
> I see saved_sigmask being used just before task sleeps and restored when
> task is scheduled back. So I dont see a case where using saved_sigmask
> in uprobes could conflict with its current usage.

Yes, I think this is possible, and probably you do not even need
set_restore_sigmask().

But. There are some problems with this approach too.

Firstly, even if you block all signals, there are other reasons for
TIF_SIGPENDING which you can't control. For example, the task can be
frozen or it can stop in UTASK_SSTEP state. Not good, if we have
enough threads, this can lead to the "soft" deadlock. Say, a group
stop can never finish because a thread sleeps in xol_wait_event()
"forever".

Another problem is that it is not possible to block the "implicit"
SIGKILL sent by exec/exit_group/etc. This mean the task can exit
without sstep_complete/xol_free_insn_slot/etc. Mostly this is fine,
we have free_uprobe_utask()->xol_free_insn_slot(). But in theory
this can deadlock afaics. Suppose that the coredumping is in progress,
the killed UTASK_SSTEP task hangs in exit_mm() waiting for other
threads. If we have enough threads like this, we can deadlock with
another thread sleeping in xol_wait_event().

This can be fixed, we can move free_uprobe_utask() from
put_task_struct() to mm_release(). Btw, imho this makes sense anyway,
why should a zombie thread abuse a slot?

However the first problem looks nasty, even if it is not very serious.
And, otoh, it doesn't look right to block SIGKILL, the task can loop
forever executing the xol insn (see below).



What do you think about the patch below? On top of 25/26, uncompiled,
untested. With this patch the task simply refuses to react to
TIF_SIGPENDING until sstep_complete().

This relies on the fact that do_notify_resume() calls
uprobe_notify_resume() before do_signal(), I guess this is safe because
we have other reasons for this order.

And, unless I missed something, this makes
free_uprobe_utask()->xol_free_insn_slot() unnecessary.



HOWEVER! I simply do not know what should we do if the probed insn
is something like asm("1:; jmp 1b;"). IIUC, in this sstep_complete()
never returns true. The patch also adds the fatal_signal_pending()
check to make this task killlable, but the problem is: whatever we do,
I do not think it is correct to disable/delay the signals in this case.
With any approach.

What do you think? Maybe we should simply disallow to probe such insns?

Once again, the change in sstep_complete() is "off-topic", this is
another problem we should solve somehow.

Oleg.

--- x/kernel/signal.c
+++ x/kernel/signal.c
@@ -2141,6 +2141,15 @@ int get_signal_to_deliver(siginfo_t *inf
 	struct signal_struct *signal = current->signal;
 	int signr;
 
+#ifdef CONFIG_UPROBES
+	if (unlikely(current->utask &&
+			current->utask->state != UTASK_RUNNING)) {
+		WARN_ON_ONCE(current->utask->state != UTASK_SSTEP);
+		clear_thread_flag(TIF_SIGPENDING);
+		return 0;
+	}
+#endif
+
 relock:
 	/*
 	 * We'll jump back here after any time we were stopped in TASK_STOPPED.
--- x/kernel/uprobes.c
+++ x/kernel/uprobes.c
@@ -1331,7 +1331,8 @@ static bool sstep_complete(struct uprobe
 	 * If we have executed out of line, Instruction pointer
 	 * cannot be same as virtual address of XOL slot.
 	 */
-	if (vaddr == current->utask->xol_vaddr)
+	if (vaddr == current->utask->xol_vaddr &&
+			!__fatal_signal_pending(current))
 		return false;
 	post_xol(uprobe, regs);
 	return true;
@@ -1390,8 +1391,7 @@ void uprobe_notify_resume(struct pt_regs
 			utask->state = UTASK_RUNNING;
 			user_disable_single_step(current);
 			xol_free_insn_slot(current);
-
-			/* TODO Stop queueing signals. */
+			recalc_sigpending();
 		}
 	}
 	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
