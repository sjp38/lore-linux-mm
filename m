Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 09C696B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:24:07 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o53NO3Ij019973
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 16:24:03 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by kpbe18.cbf.corp.google.com with ESMTP id o53NO1n5028094
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 16:24:01 -0700
Received: by pvg2 with SMTP id 2so184266pvg.22
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 16:24:01 -0700 (PDT)
Date: Thu, 3 Jun 2010 16:23:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
In-Reply-To: <20100603221145.GB8511@redhat.com>
Message-ID: <alpine.DEB.2.00.1006031618230.30302@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152436.7262.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com> <20100603140008.GA3548@redhat.com> <alpine.DEB.2.00.1006031313040.10856@chino.kir.corp.google.com>
 <20100603221145.GB8511@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, Oleg Nesterov wrote:

> > > > > Currently, PF_EXITING check is completely broken. because 1) It only
> > > > > care main-thread and ignore sub-threads
> > > >
> > > > Then check the subthreads.
> > > >
> >
> > Did you want to respond to this?
> 
> Please explain what you mean. There were already a lot of discussions
> about mt issues, I do not know what you have in mind.
> 

Can you check the subthreads to see if they are not PF_EXITING?

> > I'm guessing at the relevancy here because the changelog is extremely
> > poorly worded (if I were Andrew I would have no idea how important this
> > patch is based on the description other than the alarmist words of "... is
> > completely broken)", but if we're concerned about the coredumper not being
> > able to find adequate resources to allocate memory from, we can give it
> > access to reserves specifically,
> 
> I don't think so. If oom-kill wants to kill the task which dumps the
> code, it should stop the coredumping and exit.
> 

That's a coredump change, not an oom killer change.  If the coredumper 
needs memory and runs into the oom killer, this PF_EXITING check, which 
you want to remove, gives it access to memory reserves by setting 
TIF_MEMDIE so it can quickly finish and die.  This allows it to exit 
without oom killing anything else because the tasklist scan in the oom 
killer is not preempted by finding a TIF_MEMDIE task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
