Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D1D8C6B020E
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 19:26:46 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o34NQgm2010264
	for <linux-mm@kvack.org>; Sun, 4 Apr 2010 16:26:42 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz29.hot.corp.google.com with ESMTP id o34NQfpU032734
	for <linux-mm@kvack.org>; Sun, 4 Apr 2010 16:26:41 -0700
Received: by pzk5 with SMTP id 5so2309885pzk.0
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 16:26:41 -0700 (PDT)
Date: Sun, 4 Apr 2010 16:26:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <20100402101711.GC12886@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004041616280.7198@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100402101711.GC12886@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Oleg Nesterov <oleg@redhat.com>, anfei <anfei.zhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2010, Mel Gorman wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1610,13 +1610,21 @@ try_next_zone:
> >  }
> >  
> >  static inline int
> > -should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> > +should_alloc_retry(struct task_struct *p, gfp_t gfp_mask, unsigned int order,
> >  				unsigned long pages_reclaimed)
> >  {
> >  	/* Do not loop if specifically requested */
> >  	if (gfp_mask & __GFP_NORETRY)
> >  		return 0;
> >  
> > +	/* Loop if specifically requested */
> > +	if (gfp_mask & __GFP_NOFAIL)
> > +		return 1;
> > +
> 
> Meh, you could have preserved the comment but no biggie.
> 

I'll remember to preserve it when it's proposed.

> > +	/* Task is killed, fail the allocation if possible */
> > +	if (fatal_signal_pending(p))
> > +		return 0;
> > +
> 
> Seems reasonable. This will be checked on every major loop in the
> allocator slow patch.
> 
> >  	/*
> >  	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
> >  	 * means __GFP_NOFAIL, but that may not be true in other
> > @@ -1635,13 +1643,6 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
> >  		return 1;
> >  
> > -	/*
> > -	 * Don't let big-order allocations loop unless the caller
> > -	 * explicitly requests that.
> > -	 */
> > -	if (gfp_mask & __GFP_NOFAIL)
> > -		return 1;
> > -
> >  	return 0;
> >  }
> >  
> > @@ -1798,6 +1799,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> >  		if (!in_interrupt() &&
> >  		    ((p->flags & PF_MEMALLOC) ||
> > +		     (fatal_signal_pending(p) && (gfp_mask & __GFP_NOFAIL)) ||
> 
> This is a lot less clear. GFP_NOFAIL is rare so this is basically saying
> that all threads with a fatal signal pending can ignore watermarks. This
> is dangerous because if 1000 threads get killed, there is a possibility
> of deadlocking the system.
> 

I don't quite understand the comment, this is only for __GFP_NOFAIL 
allocations, which you say are rare, so a large number of threads won't be 
doing this simultaneously.

> Why not obey the watermarks and just not retry the loop later and fail
> the allocation?
> 

The above check for (fatal_signal_pending(p) && (gfp_mask & __GFP_NOFAIL)) 
essentially oom kills p without invoking the oom killer before direct 
reclaim is invoked.  We know it has a pending SIGKILL and wants to exit, 
so we allow it to allocate beyond the min watermark to avoid costly 
reclaim or needlessly killing another task.

> >  		     unlikely(test_thread_flag(TIF_MEMDIE))))
> >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> >  	}
> > @@ -1812,6 +1814,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	int migratetype)
> >  {
> >  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +	const gfp_t nofail = gfp_mask & __GFP_NOFAIL;
> >  	struct page *page = NULL;
> >  	int alloc_flags;
> >  	unsigned long pages_reclaimed = 0;
> > @@ -1876,7 +1879,7 @@ rebalance:
> >  		goto nopage;
> >  
> >  	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > +	if (test_thread_flag(TIF_MEMDIE) && !nofail)
> >  		goto nopage;
> >  
> >  	/* Try direct reclaim and then allocating */
> > @@ -1888,6 +1891,10 @@ rebalance:
> >  	if (page)
> >  		goto got_pg;
> >  
> > +	/* Task is killed, fail the allocation if possible */
> > +	if (fatal_signal_pending(p) && !nofail)
> > +		goto nopage;
> > +
> 
> Again, I would expect this to be caught by should_alloc_retry().
> 

It is, but only after the oom killer is called.  We don't want to 
needlessly kill another task here when p has already been killed but may 
not be PF_EXITING yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
