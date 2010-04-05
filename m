Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 68E276B0222
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 06:48:14 -0400 (EDT)
Date: Mon, 5 Apr 2010 11:47:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100405104752.GB21207@csn.ul.ie>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100402101711.GC12886@csn.ul.ie> <alpine.DEB.2.00.1004041616280.7198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004041616280.7198@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, anfei <anfei.zhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 04, 2010 at 04:26:38PM -0700, David Rientjes wrote:
> On Fri, 2 Apr 2010, Mel Gorman wrote:
> 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1610,13 +1610,21 @@ try_next_zone:
> > >  }
> > >  
> > >  static inline int
> > > -should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> > > +should_alloc_retry(struct task_struct *p, gfp_t gfp_mask, unsigned int order,
> > >  				unsigned long pages_reclaimed)
> > >  {
> > >  	/* Do not loop if specifically requested */
> > >  	if (gfp_mask & __GFP_NORETRY)
> > >  		return 0;
> > >  
> > > +	/* Loop if specifically requested */
> > > +	if (gfp_mask & __GFP_NOFAIL)
> > > +		return 1;
> > > +
> > 
> > Meh, you could have preserved the comment but no biggie.
> > 
> 
> I'll remember to preserve it when it's proposed.
> 
> > > +	/* Task is killed, fail the allocation if possible */
> > > +	if (fatal_signal_pending(p))
> > > +		return 0;
> > > +
> > 
> > Seems reasonable. This will be checked on every major loop in the
> > allocator slow patch.
> > 
> > >  	/*
> > >  	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> > >  	 * means __GFP_NOFAIL, but that may not be true in other
> > > @@ -1635,13 +1643,6 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> > >  	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
> > >  		return 1;
> > >  
> > > -	/*
> > > -	 * Don't let big-order allocations loop unless the caller
> > > -	 * explicitly requests that.
> > > -	 */
> > > -	if (gfp_mask & __GFP_NOFAIL)
> > > -		return 1;
> > > -
> > >  	return 0;
> > >  }
> > >  
> > > @@ -1798,6 +1799,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > >  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> > >  		if (!in_interrupt() &&
> > >  		    ((p->flags & PF_MEMALLOC) ||
> > > +		     (fatal_signal_pending(p) && (gfp_mask & __GFP_NOFAIL)) ||
> > 
> > This is a lot less clear. GFP_NOFAIL is rare so this is basically saying
> > that all threads with a fatal signal pending can ignore watermarks. This
> > is dangerous because if 1000 threads get killed, there is a possibility
> > of deadlocking the system.
> > 
> 
> I don't quite understand the comment, this is only for __GFP_NOFAIL 
> allocations, which you say are rare, so a large number of threads won't be 
> doing this simultaneously.
> 
> > Why not obey the watermarks and just not retry the loop later and fail
> > the allocation?
> > 
> 
> The above check for (fatal_signal_pending(p) && (gfp_mask & __GFP_NOFAIL)) 
> essentially oom kills p without invoking the oom killer before direct 
> reclaim is invoked.  We know it has a pending SIGKILL and wants to exit, 
> so we allow it to allocate beyond the min watermark to avoid costly 
> reclaim or needlessly killing another task.
> 

Sorry, I typod.

GFP_NOFAIL is rare but this is basically saying that all threads with a
fatal signal and using NOFAIL can ignore watermarks.

I don't think there is any caller in an exit path will be using GFP_NOFAIL
as it's most common user is file-system related but it still feels unnecssary
to check this case on every call to the slow path.

> > >  		     unlikely(test_thread_flag(TIF_MEMDIE))))
> > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > >  	}
> > > @@ -1812,6 +1814,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  	int migratetype)
> > >  {
> > >  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > > +	const gfp_t nofail = gfp_mask & __GFP_NOFAIL;
> > >  	struct page *page = NULL;
> > >  	int alloc_flags;
> > >  	unsigned long pages_reclaimed = 0;
> > > @@ -1876,7 +1879,7 @@ rebalance:
> > >  		goto nopage;
> > >  
> > >  	/* Avoid allocations with no watermarks from looping endlessly */
> > > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > > +	if (test_thread_flag(TIF_MEMDIE) && !nofail)
> > >  		goto nopage;
> > >  
> > >  	/* Try direct reclaim and then allocating */
> > > @@ -1888,6 +1891,10 @@ rebalance:
> > >  	if (page)
> > >  		goto got_pg;
> > >  
> > > +	/* Task is killed, fail the allocation if possible */
> > > +	if (fatal_signal_pending(p) && !nofail)
> > > +		goto nopage;
> > > +
> > 
> > Again, I would expect this to be caught by should_alloc_retry().
> > 
> 
> It is, but only after the oom killer is called.  We don't want to 
> needlessly kill another task here when p has already been killed but may 
> not be PF_EXITING yet.
> 

Fair point. How about just checking before __alloc_pages_may_oom() is
called then? This check will be then in a slower path.
I recognise this means that it is also only checked when direct reclaim
is failing but there is at least one good reason for it.

With this change, processes that have been sigkilled may now fail allocations
that they might not have failed before. It would be difficult to trigger
but here is one possible problem with this change;

1. System was borderline with some trashing
2. User starts program that gobbles up lots of memory on page faults,
   trashing the system further and annoying the user
3. User sends SIGKILL
4. Process was faulting and returns NULL because fatal signal was pending
5. Fault path returns VM_FAULT_OOM
6. Arch-specific path (on x86 anyway) calls out_of_memory again because
   VM_FAULT_OOM was returned.

Ho hum, I haven't thought about this before but it's also possible that
a process that is fauling that gets oom-killed will trigger a cascading
OOM kill. If the system was heavily trashing, it might mean a large
number of processes get killed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
