Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 159C66B01B6
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 15:17:35 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: uninterruptible CLONE_VFORK (Was: oom: Make coredump
	interruptible)
In-Reply-To: Oleg Nesterov's message of  Monday, 14 June 2010 18:33:05 +0200 <20100614163304.GA21313@redhat.com>
References: <20100604112721.GA12582@redhat.com>
	<20100609195309.GA6899@redhat.com>
	<20100613175547.616F.A69D9226@jp.fujitsu.com>
	<20100613155354.GA8428@redhat.com>
	<20100613171337.GA12159@redhat.com>
	<20100614005608.0D006408C1@magilla.sf.frob.com>
	<20100614163304.GA21313@redhat.com>
Message-Id: <20100614191710.18C0E403B2@magilla.sf.frob.com>
Date: Mon, 14 Jun 2010 12:17:10 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> But note that oom_kill_process() doesn't kill the children with the
> same ->mm. I never understood this code.

Yes, odd.  This is the first time I've really looked at oom_kill.

> Anyway I agree. Even if I am right, this is not very serious problem
> from oom-kill pov. To me, the uninterruptible CLONE_VFORK is bad by
> itself.

Agreed.

> Yes sure. That is why wait_for_completion_killable(), not _interrutpible.

Right, your code was fine.  I was just being pedantic for the record since
you said "interruptible" in the text.

> But I assume you didn't mean that only SIGKILL should interrupt the
> parent, any sig_fatal() signal should.

Yes.

> Agreed. This needs auditing. And CLONE_VFORK can be used with/without all
> other CLONE_ flags... Probably we should mostly worry about vfork ==
> CLONE_VM | CLONE_VFORK case.

Yes.  I hope it is fine to make clone refuse CLONE_VFORK set without
CLONE_VM in the future as a sanity check.  I don't think any use of
CLONE_VFORK other than the actual vfork use is something we ever intended
to support.

> Anyway. ->vfork_done is per-thread. This means that without any changes
> do_fork(CLONE_VFORK) can return (to user-mode) before the child's thread
> group exits/execs. Perhaps this means we shouldn't worry too much.

You mean some other thread in the parent's group can run in user mode.
Yes.  The real reason for the vfork wait is just that the parent/child will
share the user stack memory, so in practice it's fine if other threads with
other stacks are touching other memory (i.e. it's just the user's problem).

> Hmm. Even without debugger, the parent doesn't react to SIGSTOP. 

Yes.  It's been a long time since I thought about the vfork stuff much.
But I now recall thinking about the SIGSTOP/SIGTSTP issue too.  It does
seem bad.  OTOH, it has lurked there for many years now without complaints.

Note that supporting stop/fatal signals in the normal way means that the
call has to return and pass the syscall-exit tracing point first.  This
means a change in the order of events seen by a debugger.  It also
complicates the subject of PTRACE_EVENT_VFORK_DONE reports, which today
happen before syscall-exit or signal stuff is possible.  For proper
stopping in the normal way, the vfork-wait would be restarted via
sys_restart_syscall or something.  But the way that happens ordinarily is
to get all the way back to user mode and reenter with a normal syscall.
That doesn't touch the user stack itself, but it sure makes one nervous.
It's hard to see how we could ever do that and then prevent normal signals
from being handled before the restart.  (Instead, we'd have the actual
blocking done inside get_signal_to_deliver so we just never get to user
mode until the vfork hold is released, and not actually need to restart.)
So there are multiple cans of worms cascading from a change, even though
the actual work to do the block in a new way might not be very complex.

It all seems kind of doable, at least if we accept a change in the userland
debugger experience of which ptrace reports a vfork parent might make in
what order.  But plenty of hair to worry about.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
