Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 390B96B01D8
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:35:12 -0400 (EDT)
Date: Mon, 14 Jun 2010 18:33:05 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: uninterruptible CLONE_VFORK (Was: oom: Make coredump
	interruptible)
Message-ID: <20100614163304.GA21313@redhat.com>
References: <20100604112721.GA12582@redhat.com> <20100609195309.GA6899@redhat.com> <20100613175547.616F.A69D9226@jp.fujitsu.com> <20100613155354.GA8428@redhat.com> <20100613171337.GA12159@redhat.com> <20100614005608.0D006408C1@magilla.sf.frob.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100614005608.0D006408C1@magilla.sf.frob.com>
Sender: owner-linux-mm@kvack.org
To: Roland McGrath <roland@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/13, Roland McGrath wrote:
>
> > Oh. And another problem, vfork() is not interruptible too. This means
> > that the user can hide the memory hog from oom-killer.
>
> I'm not sure there is really any danger like that, because of the
> oom_kill_process "Try to kill a child first" logic.

But note that oom_kill_process() doesn't kill the children with the
same ->mm. I never understood this code.

Anyway I agree. Even if I am right, this is not very serious problem
from oom-kill pov. To me, the uninterruptible CLONE_VFORK is bad by
itself.

> > But let's forget about oom.
>
> Sure, but it reminds me to mention that vfork mm sharing is another reason
> that having oom_kill set some persistent state in the mm seems wrong.

Yes, yes, this was already discussed a bit. Only if the core dump is in
progress we can touch ->mm or (probably better but needs a bit more locking)
mm->core_state to signal the coredumping thread and (perhaps) for something
else.

> > Roland, any reason it should be uninterruptible? This doesn't look good
> > in any case. Perhaps the pseudo-patch below makes sense?
>
> I've long thought that we should make a vfork parent SIGKILL-able.

Good ;)

> (Of
> course the vfork wait can't be made interruptible by other signals, since
> it must never do anything userish

Yes sure. That is why wait_for_completion_killable(), not _interrutpible.
But I assume you didn't mean that only SIGKILL should interrupt the
parent, any sig_fatal() signal should.

> I don't know off hand of any problem with your
> straightforward change.  But I don't have much confidence that there isn't
> any strange gotcha waiting there due to some other kind of implicit
> assumption about vfork parent blocks that we are overlooking at the moment.
> So I wouldn't change this without more thorough auditing and thinking about
> everything related to vfork.

Agreed. This needs auditing. And CLONE_VFORK can be used with/without all
other CLONE_ flags... Probably we should mostly worry about vfork ==
CLONE_VM | CLONE_VFORK case.

Anyway. ->vfork_done is per-thread. This means that without any changes
do_fork(CLONE_VFORK) can return (to user-mode) before the child's thread
group exits/execs. Perhaps this means we shouldn't worry too much.

> Personally, what I've really been interested in is changing the vfork wait
> to use some different kind of blocking entirely.  My real motivation for
> that is to let a vfork wait be morphed into and out of TASK_TRACED,

I see. I never thought about this, but I think you are right.

Hmm. Even without debugger, the parent doesn't react to SIGSTOP. Say,

	int main(voif)
	{
		if (!vfork())
			pause();
	}

and ^Z won't work obviously. Not good.

This is not trivail I guess. Needs thinking...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
