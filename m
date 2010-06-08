Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A46E76B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:47:45 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o58IlOIN008371
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:47:24 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe12.cbf.corp.google.com with ESMTP id o58IlJao015160
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:47:23 -0700
Received: by pxi19 with SMTP id 19so2324335pxi.17
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:47:23 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:47:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it
 has been killed
In-Reply-To: <20100608203216.765D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081145560.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com> <20100608203216.765D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > It's possible to livelock the page allocator if a thread has mm->mmap_sem
> > and fails to make forward progress because the oom killer selects another
> > thread sharing the same ->mm to kill that cannot exit until the semaphore
> > is dropped.
> > 
> > The oom killer will not kill multiple tasks at the same time; each oom
> > killed task must exit before another task may be killed.  Thus, if one
> > thread is holding mm->mmap_sem and cannot allocate memory, all threads
> > sharing the same ->mm are blocked from exiting as well.  In the oom kill
> > case, that means the thread holding mm->mmap_sem will never free
> > additional memory since it cannot get access to memory reserves and the
> > thread that depends on it with access to memory reserves cannot exit
> > because it cannot acquire the semaphore.  Thus, the page allocators
> > livelocks.
> > 
> > When the oom killer is called and current happens to have a pending
> > SIGKILL, this patch automatically gives it access to memory reserves and
> > returns.  Upon returning to the page allocator, its allocation will
> > hopefully succeed so it can quickly exit and free its memory.  If not, the
> > page allocator will fail the allocation if it is not __GFP_NOFAIL.
> > 
> > Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |   10 ++++++++++
> >  1 files changed, 10 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -650,6 +650,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  		/* Got some memory back in the last second. */
> >  		return;
> >  
> > +	/*
> > +	 * If current has a pending SIGKILL, then automatically select it.  The
> > +	 * goal is to allow it to allocate so that it may quickly exit and free
> > +	 * its memory.
> > +	 */
> > +	if (fatal_signal_pending(current)) {
> > +		set_thread_flag(TIF_MEMDIE);
> > +		return;
> > +	}
> > +
> >  	if (sysctl_panic_on_oom == 2) {
> >  		dump_header(NULL, gfp_mask, order, NULL);
> >  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
> 
> Sorry, I had found this patch works incorrect. I don't pulled.
> 

You're taking back your ack?

Why does this not work?  It's not killing a potentially immune task, the 
task is already dying.  We're simply giving it access to memory reserves 
so that it may quickly exit and die.  OOM_DISABLE does not imply that a 
task cannot exit on its own or be killed by another application or user, 
we simply don't want to needlessly kill another task when current is dying 
in the first place without being able to allocate memory.

Please reconsider your thought.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
