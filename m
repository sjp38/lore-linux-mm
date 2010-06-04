Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C83DC6B01B7
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:05:40 -0400 (EDT)
Date: Fri, 4 Jun 2010 12:04:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
Message-ID: <20100604100416.GB8569@redhat.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152436.7262.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com> <20100603140008.GA3548@redhat.com> <alpine.DEB.2.00.1006031313040.10856@chino.kir.corp.google.com> <20100603221145.GB8511@redhat.com> <alpine.DEB.2.00.1006031618230.30302@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006031618230.30302@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/03, David Rientjes wrote:
>
> On Fri, 4 Jun 2010, Oleg Nesterov wrote:
>
> > > > > > Currently, PF_EXITING check is completely broken. because 1) It only
> > > > > > care main-thread and ignore sub-threads
> > > > >
> > > > > Then check the subthreads.
> > > > >
> > >
> > > Did you want to respond to this?
> >
> > Please explain what you mean. There were already a lot of discussions
> > about mt issues, I do not know what you have in mind.
>
> Can you check the subthreads to see if they are not PF_EXITING?

To detect the process with the dead group leader?

Yes, we can. We already discussed this. Probably it is better to check
PF_EXITING and signal_group_exit().

> > > I'm guessing at the relevancy here because the changelog is extremely
> > > poorly worded (if I were Andrew I would have no idea how important this
> > > patch is based on the description other than the alarmist words of "... is
> > > completely broken)", but if we're concerned about the coredumper not being
> > > able to find adequate resources to allocate memory from, we can give it
> > > access to reserves specifically,
> >
> > I don't think so. If oom-kill wants to kill the task which dumps the
> > code, it should stop the coredumping and exit.
>
> That's a coredump change, not an oom killer change.

Yes. do_coredump() should be fixed. This is not trivial (and needs the
subtle changes outside of fs/exec.c), we are looking for the simple fix
for now.

> If the coredumper
> needs memory and runs into the oom killer, this PF_EXITING check, which
> you want to remove, gives it access to memory reserves by setting
> TIF_MEMDIE so it can quickly finish and die.  This allows it to exit
> without oom killing anything else because the tasklist scan in the oom
> killer is not preempted by finding a TIF_MEMDIE task.

David, sorry. I already tried to explain (at least twice) that TIF_MEMDIE
(or SIGKILL even if do_coredump() was interruptible) can not help unless
you find the right thread, this is not trivial even if we forget about
CLONE_VM tasks.

And personally I disagree that it should use memory reserves, but this
doesn't matter.


Let's stop this. You shouldn't convince me. I am not the author of this
patch, and I said many times that I do not pretend I understand oom-kill
needs. I jumped into this discussion because your initial objection
(fatal_signal_pending() should fix the problems) was technically wrong.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
