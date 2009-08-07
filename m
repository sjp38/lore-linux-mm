Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADA916B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 07:09:14 -0400 (EDT)
Date: Fri, 7 Aug 2009 12:09:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] tracing, page-allocator: Add trace event for page
	traffic related to the buddy lists
Message-ID: <20090807110915.GD18134@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-4-git-send-email-mel@csn.ul.ie> <20090807075317.GC20292@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807075317.GC20292@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 09:53:17AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +TRACE_EVENT(mm_page_pcpu_drain,
> > +
> > +	TP_PROTO(struct page *page, int order, int migratetype),
> > +
> > +	TP_ARGS(page, order, migratetype),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	struct page *,	page		)
> > +		__field(	int,		order		)
> > +		__field(	int,		migratetype	)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +		__entry->migratetype	= migratetype;
> > +	),
> > +
> > +	TP_printk("page=%p pfn=%lu order=%d cpu=%d migratetype=%d",
> > +		__entry->page,
> > +		page_to_pfn(__entry->page),
> > +		__entry->order,
> > +		smp_processor_id(),
> > +		__entry->migratetype)
> 
> > +	trace_mm_page_alloc_zone_locked(page, order, migratetype, order == 0);
> 
> This can be optimized further by omitting the migratetype field and 
> adding something like this:
> 
> 	TP_printk("page=%p pfn=%lu order=%d cpu=%d migratetype=%d",
> 		__entry->page,
> 		page_to_pfn(__entry->page),
> 		__entry->order,
> 		smp_processor_id(),
> 		__entry->order == 0);
> 
> The advantage is 4 bytes less in the record and a shorter tracepoint 
> fast-path - while still having the same output.
> 

Knowing you meant percpu_refill, it's now been figured out in TP_printk
instead of in the code.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
