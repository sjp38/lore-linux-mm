Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 23B28600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 13:35:04 -0400 (EDT)
Date: Mon, 28 Jun 2010 19:33:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: uninterruptible CLONE_VFORK (Was: oom: Make coredump
	interruptible)
Message-ID: <20100628173306.GA20039@redhat.com>
References: <20100604112721.GA12582@redhat.com> <20100609195309.GA6899@redhat.com> <20100613175547.616F.A69D9226@jp.fujitsu.com> <20100613155354.GA8428@redhat.com> <20100613171337.GA12159@redhat.com> <20100614005608.0D006408C1@magilla.sf.frob.com> <20100614163304.GA21313@redhat.com> <20100614191710.18C0E403B2@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100614191710.18C0E403B2@magilla.sf.frob.com>
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/14, Roland McGrath wrote:
>
> > Hmm. Even without debugger, the parent doesn't react to SIGSTOP.
>
> Yes.  It's been a long time since I thought about the vfork stuff much.
> But I now recall thinking about the SIGSTOP/SIGTSTP issue too.  It does
> seem bad.  OTOH, it has lurked there for many years now without complaints.
>
> Note that supporting stop/fatal signals in the normal way means that the
> call has to return and pass the syscall-exit tracing point first.  This
> means a change in the order of events seen by a debugger.  It also
> complicates the subject of PTRACE_EVENT_VFORK_DONE reports, which today
> happen before syscall-exit or signal stuff is possible.  For proper
> stopping in the normal way, the vfork-wait would be restarted via
> sys_restart_syscall or something.

Yes. I was thinking about this too.

The parent can play with real_blocked or saved_sigmask to block all
signals except STOP and KILL, use TASK_INTERRUPTIBLE for wait, and
just return ERESTART each time it gets the signal (it should clear
child->vfork_done if fatal_signal_pending).

We should also check PF_KTHREAD though, there are in kernel users
of CLONE_VFORK.

> Bu the way that happens ordinarily is
> to get all the way back to user mode and reenter with a normal syscall.
> That doesn't touch the user stack itself, but it sure makes one nervous.

me too. Especially because I do not really know how !x86 machines
implement this all.

We should also verify that the exiting/stopping parent can never write
to its ->mm. For example, exit_mm() does put_user(tsk->clear_child_tid).
Fortunately we can rely on PF_SIGNALED flag in this case.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
