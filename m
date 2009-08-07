Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AA58B6B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 06:49:02 -0400 (EDT)
Date: Fri, 7 Aug 2009 11:49:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/6] tracing, page-allocator: Add trace events for page
	allocation and page freeing
Message-ID: <20090807104905.GA18134@csn.ul.ie>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-2-git-send-email-mel@csn.ul.ie> <20090807075030.GB20292@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090807075030.GB20292@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 07, 2009 at 09:50:30AM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > +TRACE_EVENT(mm_pagevec_free,
> 
> > +	TP_fast_assign(
> > +		__entry->page		= page;
> > +		__entry->order		= order;
> > +		__entry->cold		= cold;
> > +	),
> 
> > -	while (--i >= 0)
> > +	while (--i >= 0) {
> > +		trace_mm_pagevec_free(pvec->pages[i], 0, pvec->cold);
> >  		free_hot_cold_page(pvec->pages[i], pvec->cold);
> > +	}
> 
> Pagevec freeing has order 0 implicit, so you can further optimize 
> this by leaving out the 'order' field and using this format string:
> 
> +	TP_printk("page=%p pfn=%lu order=0 cold=%d",
> +                       __entry->page,
> +                       page_to_pfn(__entry->page),
> +                       __entry->cold)
> 
> the trace record becomes smaller by 4 bytes and the tracepoint 
> fastpath becomes shorter as well.
> 

Good point. It's fixed now.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
