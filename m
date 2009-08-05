Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D23446B00AE
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:40:18 -0400 (EDT)
Date: Wed, 5 Aug 2009 10:40:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] tracing, page-allocator: Add trace events for page
	allocation and page freeing
Message-ID: <20090805094019.GB21950@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-2-git-send-email-mel@csn.ul.ie> <20090805165302.5BC8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090805165302.5BC8.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 06:13:09PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> sorry for the delayed review.
> 
> > This patch adds trace events for the allocation and freeing of pages,
> > including the freeing of pagevecs.  Using the events, it will be known what
> > struct page and pfns are being allocated and freed and what the call site
> > was in many cases.
> > 
> > The page alloc tracepoints be used as an indicator as to whether the workload
> > was heavily dependant on the page allocator or not. You can make a guess based
> > on vmstat but you can't get a per-process breakdown. Depending on the call
> > path, the call_site for page allocation may be __get_free_pages() instead
> > of a useful callsite. Instead of passing down a return address similar to
> > slab debugging, the user should enable the stacktrace and seg-addr options
> > to get a proper stack trace.
> > 
> > The pagevec free tracepoint has a different usecase. It can be used to get
> > a idea of how many pages are being dumped off the LRU and whether it is
> > kswapd doing the work or a process doing direct reclaim.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> >  include/trace/events/kmem.h |   86 +++++++++++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c             |    6 ++-
> >  2 files changed, 91 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> > index 1493c54..57bf13c 100644
> > --- a/include/trace/events/kmem.h
> > +++ b/include/trace/events/kmem.h
> > @@ -225,6 +225,92 @@ TRACE_EVENT(kmem_cache_free,
> >  
> >  	TP_printk("call_site=%lx ptr=%p", __entry->call_site, __entry->ptr)
> >  );
> > +
> > +TRACE_EVENT(mm_page_free_direct,
> > +
> > +	TP_PROTO(unsigned long call_site, const void *page, unsigned int order),
> > +
> > +	TP_ARGS(call_site, page, order),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	unsigned long,	call_site	)
> > +		__field(	const void *,	page		)
> 
> Why void? Is there any benefit?
> 

No real benefit, I'll switch to struct page *. I thought at one point it was
failing to compile as struct page * was not in scope but that must have been
my imagination.

> > +		__field(	unsigned int,	order		)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->call_site	= call_site;
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +	),
> > +
> > +	TP_printk("call_site=%lx page=%p pfn=%lu order=%d",
> > +			__entry->call_site,
> > +			__entry->page,
> > +			page_to_pfn((struct page *)__entry->page),
> > +			__entry->order)
> > +);
> > +
> > +TRACE_EVENT(mm_pagevec_free,
> > +
> > +	TP_PROTO(unsigned long call_site, const void *page, int order, int cold),
> > +
> > +	TP_ARGS(call_site, page, order, cold),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	unsigned long,	call_site	)
> > +		__field(	const void *,	page		)
> > +		__field(	int,		order		)
> > +		__field(	int,		cold		)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->call_site	= call_site;
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +		__entry->cold		= cold;
> > +	),
> > +
> > +	TP_printk("call_site=%lx page=%p pfn=%lu order=%d cold=%d",
> > +			__entry->call_site,
> > +			__entry->page,
> > +			page_to_pfn((struct page *)__entry->page),
> > +			__entry->order,
> > +			__entry->cold)
> > +);
> > +
> > +TRACE_EVENT(mm_page_alloc,
> > +
> > +	TP_PROTO(unsigned long call_site, const void *page, unsigned int order,
> > +			gfp_t gfp_flags, int migratetype),
> > +
> > +	TP_ARGS(call_site, page, order, gfp_flags, migratetype),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	unsigned long,	call_site	)
> > +		__field(	const void *,	page		)
> > +		__field(	unsigned int,	order		)
> > +		__field(	gfp_t,		gfp_flags	)
> > +		__field(	int,		migratetype	)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->call_site	= call_site;
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +		__entry->gfp_flags	= gfp_flags;
> > +		__entry->migratetype	= migratetype;
> > +	),
> > +
> > +	TP_printk("call_site=%lx page=%p pfn=%lu order=%d migratetype=%d gfp_flags=%s",
> > +		__entry->call_site,
> > +		__entry->page,
> > +		page_to_pfn((struct page *)__entry->page),
> > +		__entry->order,
> > +		__entry->migratetype,
> > +		show_gfp_flags(__entry->gfp_flags))
> > +);
> > +
> >  #endif /* _TRACE_KMEM_H */
> >  
> >  /* This part must be outside protection */
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index d052abb..843bdec 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1905,6 +1905,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  				zonelist, high_zoneidx, nodemask,
> >  				preferred_zone, migratetype);
> >  
> > +	trace_mm_page_alloc(_RET_IP_, page, order, gfp_mask, migratetype);
> >  	return page;
> >  }
> 
> In almost case, __alloc_pages_nodemask() is called from alloc_pages_current().
> Can you add call_site argument? (likes slab_alloc)
> 

In the NUMA case, this will be true but addressing it involves passing down
an additional argument in the non-tracing case which I wanted to avoid.
As the stacktrace option is available to ftrace, I think I'll drop call_site
altogether as anyone who really needs that information has options.

> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> > @@ -1945,13 +1946,16 @@ void __pagevec_free(struct pagevec *pvec)
> >  {
> >  	int i = pagevec_count(pvec);
> >  
> > -	while (--i >= 0)
> > +	while (--i >= 0) {
> > +		trace_mm_pagevec_free(_RET_IP_, pvec->pages[i], 0, pvec->cold);
> >  		free_hot_cold_page(pvec->pages[i], pvec->cold);
> > +	}
> >  }
> 
> This _RET_IP_ assume pagevec_free() is inlined function. Then,
> pagevec_free() sould also change always_inline?
> 

There is an assumption being made about the inlining all right.

> Yeah, I agree this is theoretical issue. but it improve readability and
> studying author's intention. 
> 

If call_site persists, I'll do this but the next version of the patchset
is likely to drop call_site.

> >  void __free_pages(struct page *page, unsigned int order)
> >  {
> >  	if (put_page_testzero(page)) {
> > +		trace_mm_page_free_direct(_RET_IP_, page, order);
> >  		if (order == 0)
> >  			free_hot_page(page);
> >  		else
> 
> This patch covered free_pages() and __pagevec_free() case.
> but it doesn't cover free_hot_page() direct call.
> 
> (Fortunately, there is no free_cold_page() caller)
> 

Good spot. free_cold_page() is dead code but I'll duplicate the
trace_mm_page_free_direct event for now and look at cleaning out
free_cold_page(). Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
