Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06E546B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 18:13:07 -0400 (EDT)
Date: Fri, 4 Jun 2010 00:11:45 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
Message-ID: <20100603221145.GB8511@redhat.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152436.7262.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com> <20100603140008.GA3548@redhat.com> <alpine.DEB.2.00.1006031313040.10856@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006031313040.10856@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/03, David Rientjes wrote:
>
> On Thu, 3 Jun 2010, Oleg Nesterov wrote:
>
> > On 06/02, David Rientjes wrote:
> > >
> > > On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:
> > >
> > > > Currently, PF_EXITING check is completely broken. because 1) It only
> > > > care main-thread and ignore sub-threads
> > >
> > > Then check the subthreads.
> > >
>
> Did you want to respond to this?

Please explain what you mean. There were already a lot of discussions
about mt issues, I do not know what you have in mind.

> > > It may ignore SIGKILL, but does not ignore fatal_signal_pending() being
> > > true
> >
> > Wrong.
> >
> > Unless the oom victim is exactly the thread which dumps the core,
> > fatal_signal_pending() won't be true for the dumper. Even if the
> > victim and the dumper are from the same group, this thread group
> > already has SIGNAL_GROUP_EXIT. And if they do not belong to the
> > same group, SIGKILL has even less effect.
> >
>
> I'm guessing at the relevancy here because the changelog is extremely
> poorly worded (if I were Andrew I would have no idea how important this
> patch is based on the description other than the alarmist words of "... is
> completely broken)", but if we're concerned about the coredumper not being
> able to find adequate resources to allocate memory from, we can give it
> access to reserves specifically,

I don't think so. If oom-kill wants to kill the task which dumps the
code, it should stop the coredumping and exit.

> we don't need to go killing additional
> tasks which may have their own coredumpers.

Sorry, can't understand.

> That's an alternative solution as well, but I'm disagreeing with the
> approach here because this enforces absolutely no guarantee that the next
> task to be oom killed will be the coredumper, its much more likely that
> we're just going to kill yet another task for the coredump.  That task may
> have a coredumper too.  Who knows.

Again, please explain this to me.

> > > Nacked-by: David Rientjes <rientjes@google.com>
> >
> > Kosaki removes the code which only pretends to work, but it doesn't
> > and leads to problems.
> >
>
> LOL, this code doesn't pretend to work,
> ...
> certain code doesn't do a complete job in certain cases or it can
> introduce a deadlock in situations

OK, agreed. It is not that it never works.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
