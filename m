Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA8566B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 07:00:07 -0400 (EDT)
Date: Fri, 7 Aug 2009 12:00:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] tracing, page-allocator: Add trace event for page
	traffic related to the buddy lists
Message-ID: <20090807110004.GC18134@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-4-git-send-email-mel@csn.ul.ie> <4A7BE015.6030002@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4A7BE015.6030002@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 04:04:37PM +0800, Li Zefan wrote:
> > +TRACE_EVENT(mm_page_alloc_zone_locked,
> > +
> > +	TP_PROTO(struct page *page, unsigned int order,
> > +				int migratetype, int percpu_refill),
> > +
> > +	TP_ARGS(page, order, migratetype, percpu_refill),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(	struct page *,	page		)
> > +		__field(	unsigned int,	order		)
> > +		__field(	int,		migratetype	)
> > +		__field(	int,		percpu_refill	)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +		__entry->migratetype	= migratetype;
> > +		__entry->percpu_refill	= percpu_refill;
> > +	),
> > +
> > +	TP_printk("page=%p pfn=%lu order=%u migratetype=%d cpu=%d percpu_refill=%d",
> > +		__entry->page,
> > +		page_to_pfn(__entry->page),
> > +		__entry->order,
> > +		__entry->migratetype,
> > +		smp_processor_id(),
> 
> This is the cpu when printk() is called, but not the cpu when
> this event happens.
> 
> And this information has already been stored, and is printed
> if context-info option is set, which is set by default.
> 

/me slaps self

I even know the CPU column was there in the trace output. What was I
thinking :/

Thanks

> > +		__entry->percpu_refill)
> > +);
> > +
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
> 
> ditto
> 
> > +		__entry->migratetype)
> > +);
> > +
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
