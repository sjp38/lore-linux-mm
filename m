Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 55BD46B00E9
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 04:26:24 -0500 (EST)
Date: Wed, 12 Jan 2011 09:25:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mmotm hangs on compaction lock_page
Message-ID: <20110112092558.GG11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie> <20110110172609.GA11932@csn.ul.ie> <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com> <20110111114521.GD11932@csn.ul.ie> <20110111124551.f8d0522c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110111124551.f8d0522c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 12:45:51PM -0800, Andrew Morton wrote:
> On Tue, 11 Jan 2011 11:45:21 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1809,12 +1809,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  	bool sync_migration)
> >  {
> >  	struct page *page;
> > +	struct task_struct *p = current;
> >  
> >  	if (!order || compaction_deferred(preferred_zone))
> >  		return NULL;
> >  
> > +	p->flags |= PF_MEMALLOC;
> >  	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
> >  						nodemask, sync_migration);
> > +	p->flags &= ~PF_MEMALLOC;
> 
> Thus accidentally wiping out PF_MEMALLOC if it was already set.
> 

Subtle but we can't have reached here if PF_MEMALLOC was previous set.
It gets caught by

        /* Avoid recursion of direct reclaim */
        if (p->flags & PF_MEMALLOC)
                goto nopage;

> It's risky, and general bad practice.  The default operation here
> should be to push the old value and to later restore it.
> 

Arguably we would do this in case that check was ever removed but I
can't imagine why we would allow direct reclaim or compaction to recurse
into direct reclaim or compaction.

> If it is safe to micro-optimise that operation then we need to make
> sure that it's really really safe and that there is no risk of
> accidentally breaking things later on as code evolves.
> 

If the code evolves in that direction, it's pretty dangerous.

> One way of doing that would be to add a WARN_ON(p->flags & PF_MEMALLOC)
> on entry.
> 

That would be reasonable.

> Oh, and since when did we use `p' to identify task_structs?
> 

It's pretty stupid all right but it was the name chosen for other parts
of page_alloc.c. A patch that either removed all local caching or
renamed p to tsk throughout page_alloc.c would be reasonable.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
