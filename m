Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9E5046B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 13:31:22 -0400 (EDT)
Date: Fri, 7 Aug 2009 18:31:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] tracing, page-allocator: Add trace events for page
	allocation and page freeing
Message-ID: <20090807173118.GA10446@csn.ul.ie>
References: <20090805165302.5BC8.A69D9226@jp.fujitsu.com> <20090805094019.GB21950@csn.ul.ie> <20090807100502.5BDC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807100502.5BDC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 10:17:57AM +0900, KOSAKI Motohiro wrote:
> 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index d052abb..843bdec 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1905,6 +1905,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> > > >  				zonelist, high_zoneidx, nodemask,
> > > >  				preferred_zone, migratetype);
> > > >  
> > > > +	trace_mm_page_alloc(_RET_IP_, page, order, gfp_mask, migratetype);
> > > >  	return page;
> > > >  }
> > > 
> > > In almost case, __alloc_pages_nodemask() is called from alloc_pages_current().
> > > Can you add call_site argument? (likes slab_alloc)
> > > 
> > 
> > In the NUMA case, this will be true but addressing it involves passing down
> > an additional argument in the non-tracing case which I wanted to avoid.
> > As the stacktrace option is available to ftrace, I think I'll drop call_site
> > altogether as anyone who really needs that information has options.
> 
> Insted, can we move this tracepoint to alloc_pages_current(), alloc_pages_node() et al ?
> On page tracking case, call_site information is one of most frequently used one.
> if we need multiple trace combination, it become hard to use and reduce usefulness a bit.
> 

Ok, lets think about that. The potential points that would need
annotation are

	o alloc_pages_current
	o alloc_page_vma
	o alloc_pages_node
	o alloc_pages_exact_node

The inlined functions that call those and should preserve the call_site
are

	o alloc_pages

The slightly lower functions they call are as follows. These cannot
trigger a tracepoint event because it would look like a duplicate.

	o __alloc_pages_nodemask
		- called by __alloc_pages
	o __alloc_pages
		- called by alloc_page_interleave() but event logged
		- called by alloc_pages_node but event logged
		- called by alloc_pages_exact_node but event logged

The more problematic ones are

	o __get_free_pages
	o get_zeroed_page
	o alloc_pages_exact

The are all real functions that call down to functions that would log
events already based on your suggestion - alloc_pages_current() in
particularly.

Looking at it, it would appear the page allocator API would need a fair
amount of reschuffling to preserve call_site and not duplicate events or
else to pass call_site down through the API even in the non-tracing case.
Minimally, that makes it a standalone patch but it would also need a good
explanation as to why capturing the stack trace on the event is not enough
to track the page for things like catching memory leaks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
