Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3FEE66B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 15:01:25 -0400 (EDT)
Date: Tue, 11 Oct 2011 20:56:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 26/26]   uprobes: queue signals while
	thread is singlestepping.
Message-ID: <20111011185653.GA10215@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120517.25326.57657.sendpatchset@srdronam.in.ibm.com> <1317128626.15383.61.camel@twins> <20110927131213.GE3685@linux.vnet.ibm.com> <20111005180139.GA5704@redhat.com> <20111006054710.GB17591@linux.vnet.ibm.com> <20111007165828.GA32319@redhat.com> <20111010122556.GB16268@linux.vnet.ibm.com> <20111010182535.GA6934@redhat.com> <20111011172603.GD16268@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111011172603.GD16268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On 10/11, Srikar Dronamraju wrote:
>
> * Oleg Nesterov <oleg@redhat.com> [2011-10-10 20:25:35]:
>
> > Yes, I think this is possible, and probably you do not even need
> > set_restore_sigmask().
> >
> > But. There are some problems with this approach too.
> >
> > Firstly, even if you block all signals, there are other reasons for
> > TIF_SIGPENDING which you can't control. For example, the task can be
> > frozen or it can stop in UTASK_SSTEP state. Not good, if we have
> > enough threads, this can lead to the "soft" deadlock. Say, a group
> > stop can never finish because a thread sleeps in xol_wait_event()
> > "forever".
> >
>
> My idea was to block signals just across singlestep only. I.e
> we dont block signals while we contend for the slot.

Yes, yes, I see. But, once again, this can only protect from kill().

The task can stop even if you block all signals, another thread
can initiate the group stop and set JOBCTL_STOP_PENDING + TIF_SIGPENDING.
And note that it can stop _before_ it returns to user mode to step
over the xol insn.

In theory the tasks like this can consume all slots, and if we have
yet another thread waiting in xol_wait_event(), we deadlock. Although
in this case SIGCONT helps, but this group stop can never finish.

> > Another problem is that it is not possible to block the "implicit"
> > SIGKILL sent by exec/exit_group/etc. This mean the task can exit
> > without sstep_complete/xol_free_insn_slot/etc. Mostly this is fine,
> > we have free_uprobe_utask()->xol_free_insn_slot(). But in theory
> > this can deadlock afaics. Suppose that the coredumping is in progress,
> > the killed UTASK_SSTEP task hangs in exit_mm() waiting for other
> > threads. If we have enough threads like this, we can deadlock with
> > another thread sleeping in xol_wait_event().
>
> Shouldnt the behaviour be the same as threads that did a
> select,sigsuspend?

Hmm. I don't understand... Could you explain?

Firstly, select/sigsuspend can't block SIGKILL, but this doesn't matter.
My point was, the task can exit in UTASK_SSTEP state, and without
xol_free_insn_slot(). And this (in theory) can lead to the "real"
deadlock.

> > However the first problem looks nasty, even if it is not very serious.
> > And, otoh, it doesn't look right to block SIGKILL, the task can loop
> > forever executing the xol insn (see below).
> >
> >
> >
> > What do you think about the patch below? On top of 25/26, uncompiled,
> > untested. With this patch the task simply refuses to react to
> > TIF_SIGPENDING until sstep_complete().
> >
>
> Your patch looks very simple and clean.
> Will test this patch and revert.

Great. I'll think a bit more and send you the "final" version tomorrow.
Assuming we can change sstep_complete() as we discussed, it doesn't need
fatal_signal_pending().

HOWEVER. There is yet another problem. Another thread can, say, unmap()
xol_vma. In this case we should ensure that the task can't fault in an
endless loop.

> > And, unless I missed something, this makes
> > free_uprobe_utask()->xol_free_insn_slot() unnecessary.
>
> What if a fatal (SIGKILL) signal was delivered only to that thread

this is not possible, in this case all threads are killed. But,

> or a fatal signal for a thread-group but more
> than one thread-group share the mm?

Yes, this is possible.

Sorry for confusion. Yes, if we have the fatal_signal_pending() check
in sstep_complete(), then we do need
free_uprobe_utask()->xol_free_insn_slot(). But this check was added
only to illustrate another problem with the self-repeating insns.

And. With "HOWEVER" above, we probably need this xol_free anyway.

> you have already commented why blocking signals is a problem, but I
> still thought I will post the patch that I had to let you know what I
> was thinking before I saw your patch.
>
> While task is processing a singlestep due to uprobes breakpoint hit,
> block signals from the time it enables singlestep to the time it disables
> singlestep.

OK, it is too late for me today, I'll take a look tomorrow.

This approach has some advantages too, perhaps we should make something
"in between".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
