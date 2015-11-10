Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 548846B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 19:21:56 -0500 (EST)
Received: by padhx2 with SMTP id hx2so206613695pad.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 16:21:56 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id z3si899998pbt.96.2015.11.09.16.21.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Nov 2015 16:21:55 -0800 (PST)
Date: Tue, 10 Nov 2015 09:22:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/cma: add new tracepoint, test_pages_isolated
Message-ID: <20151110002220.GB13894@js1304-P5Q-DELUXE>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1511091457140.20636@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511091457140.20636@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 02:59:39PM -0800, David Rientjes wrote:
> On Mon, 9 Nov 2015, Joonsoo Kim wrote:
> 
> > diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
> > index d7cd961..82281b0 100644
> > --- a/include/trace/events/cma.h
> > +++ b/include/trace/events/cma.h
> > @@ -60,6 +60,32 @@ TRACE_EVENT(cma_release,
> >  		  __entry->count)
> >  );
> >  
> > +TRACE_EVENT(test_pages_isolated,
> > +
> > +	TP_PROTO(
> > +		unsigned long start_pfn,
> > +		unsigned long end_pfn,
> > +		unsigned long fin_pfn),
> > +
> > +	TP_ARGS(start_pfn, end_pfn, fin_pfn),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(unsigned long, start_pfn)
> > +		__field(unsigned long, end_pfn)
> > +		__field(unsigned long, fin_pfn)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->start_pfn = start_pfn;
> > +		__entry->end_pfn = end_pfn;
> > +		__entry->fin_pfn = fin_pfn;
> > +	),
> > +
> > +	TP_printk("start_pfn=0x%lx end_pfn=0x%lx fin_pfn=0x%lx ret=%s",
> > +		__entry->start_pfn, __entry->end_pfn, __entry->fin_pfn,
> > +		__entry->end_pfn == __entry->fin_pfn ? "success" : "fail")
> > +);
> > +
> >  #endif /* _TRACE_CMA_H */
> >  
> >  /* This part must be outside protection */
> > diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> > index 6f5ae96..bda0fea 100644
> > --- a/mm/page_isolation.c
> > +++ b/mm/page_isolation.c
> > @@ -7,6 +7,8 @@
> >  #include <linux/pageblock-flags.h>
> >  #include <linux/memory.h>
> >  #include <linux/hugetlb.h>
> > +#include <trace/events/cma.h>
> > +
> >  #include "internal.h"
> >  
> >  static int set_migratetype_isolate(struct page *page,
> > @@ -268,6 +270,9 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
> >  						skip_hwpoisoned_pages);
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> >  
> > +#ifdef CONFIG_CMA
> > +	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
> > +#endif
> >  	return (pfn < end_pfn) ? -EBUSY : 0;
> >  }
> >  
> 
> This is also used for memory offlining, so could we generalize the 
> tracepoint to CONFIG_CMA || CONFIG_MEMORY_HOTREMOVE?

Okay. I will make it enabled on CONFIG_MEMORY_ISOLATION so that
CONFIG_CMA || CONFIG_MEMORY_HOTREMOVE || CONFIG_MEMORY_FAILURE can
get benefit from it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
