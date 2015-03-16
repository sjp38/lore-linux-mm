Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 868FE6B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:47:15 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so72054085pdb.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:47:15 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.230])
        by mx.google.com with ESMTP id ly16si25435778pab.129.2015.03.16.16.47.13
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 16:47:13 -0700 (PDT)
Date: Mon, 16 Mar 2015 19:47:50 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Message-ID: <20150316194750.04885ee7@grimm.local.home>
In-Reply-To: <550741BD.9080109@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
	<a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
	<550741BD.9080109@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Ingo Molnar <mingo@redhat.com>

On Mon, 16 Mar 2015 23:49:01 +0300
Stefan Strogin <s.strogin@partner.samsung.com> wrote:

> Oops... forgot to cc tracing maintainers. Sorry!

Thanks,

> 
> On 16/03/15 19:06, Stefan Strogin wrote:
> > Add trace events for cma_alloc() and cma_release().
> > 
> > Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
> > ---
> >  include/trace/events/cma.h | 57 ++++++++++++++++++++++++++++++++++++++++++++++
> >  mm/cma.c                   |  5 ++++
> >  2 files changed, 62 insertions(+)
> >  create mode 100644 include/trace/events/cma.h
> > 
> > diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
> > new file mode 100644
> > index 0000000..d88881b
> > --- /dev/null
> > +++ b/include/trace/events/cma.h
> > @@ -0,0 +1,57 @@
> > +#undef TRACE_SYSTEM
> > +#define TRACE_SYSTEM cma
> > +
> > +#if !defined(_TRACE_CMA_H) || defined(TRACE_HEADER_MULTI_READ)
> > +#define _TRACE_CMA_H
> > +
> > +#include <linux/types.h>
> > +#include <linux/tracepoint.h>
> > +
> > +TRACE_EVENT(cma_alloc,
> > +
> > +	TP_PROTO(struct cma *cma, struct page *page, int count),
> > +
> > +	TP_ARGS(cma, page, count),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(struct page *, page)
> > +		__field(unsigned long, count)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->page = page;
> > +		__entry->count = count;
> > +	),
> > +
> > +	TP_printk("page=%p pfn=%lu count=%lu",
> > +		  __entry->page,
> > +		  __entry->page ? page_to_pfn(__entry->page) : 0,

Can page_to_pfn(value) ever be different throughout the life of the
boot? That is, can it return a different result given the same value
(vmalloc area comes to mind).

> > +		  __entry->count)
> > +);
> > +
> > +TRACE_EVENT(cma_release,
> > +
> > +	TP_PROTO(struct cma *cma, unsigned long pfn, int count),
> > +
> > +	TP_ARGS(cma, pfn, count),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(unsigned long, pfn)
> > +		__field(unsigned long, count)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->pfn = pfn;
> > +		__entry->count = count;
> > +	),
> > +
> > +	TP_printk("pfn=%lu page=%p count=%lu",
> > +		  __entry->pfn,
> > +		  pfn_to_page(__entry->pfn),

Same here. Can pfn_to_page(value) ever return a different result with
the same value in a single boot?

-- Steve

> > +		  __entry->count)
> > +);
> > +
> > +#endif /* _TRACE_CMA_H */
> > +
> > +/* This part must be outside protection */
> > +#include <trace/define_trace.h>
> > diff --git a/mm/cma.c b/mm/cma.c
> > index 47203fa..63dfc0e 100644
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -23,6 +23,7 @@
> >  #  define DEBUG
> >  #endif
> >  #endif
> > +#define CREATE_TRACE_POINTS
> >  
> >  #include <linux/memblock.h>
> >  #include <linux/err.h>
> > @@ -34,6 +35,7 @@
> >  #include <linux/cma.h>
> >  #include <linux/highmem.h>
> >  #include <linux/io.h>
> > +#include <trace/events/cma.h>
> >  
> >  #include "cma.h"
> >  
> > @@ -414,6 +416,8 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
> >  		start = bitmap_no + mask + 1;
> >  	}
> >  
> > +	trace_cma_alloc(cma, page, count);
> > +
> >  	pr_debug("%s(): returned %p\n", __func__, page);
> >  	return page;
> >  }
> > @@ -446,6 +450,7 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
> >  
> >  	free_contig_range(pfn, count);
> >  	cma_clear_bitmap(cma, pfn, count);
> > +	trace_cma_release(cma, pfn, count);
> >  
> >  	return true;
> >  }
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
