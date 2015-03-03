Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id EAE946B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:14:20 -0500 (EST)
Received: by padfa1 with SMTP id fa1so22318350pad.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:14:20 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id lk3si2317pbc.244.2015.03.03.01.14.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 01:14:20 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 3 Mar 2015 19:14:13 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DFB102CE804E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 20:14:09 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t239E13t21954616
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 20:14:09 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t239DYPv006239
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 20:13:34 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 1/4] mm: cma: add trace events to debug physically-contiguous memory allocations
In-Reply-To: <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 03 Mar 2015 14:43:00 +0530
Message-ID: <87sidma1gj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Stefan Strogin <s.strogin@partner.samsung.com> writes:

> Add trace events for cma_alloc() and cma_release().
>
> Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
> ---
>  include/trace/events/cma.h | 57 ++++++++++++++++++++++++++++++++++++++++++++++
>  mm/cma.c                   |  6 +++++
>  2 files changed, 63 insertions(+)
>  create mode 100644 include/trace/events/cma.h
>
> diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
> new file mode 100644
> index 0000000..3fe7a56
> --- /dev/null
> +++ b/include/trace/events/cma.h
> @@ -0,0 +1,57 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM cma
> +
> +#if !defined(_TRACE_CMA_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_CMA_H
> +
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(cma_alloc,
> +
> +	TP_PROTO(struct cma *cma, unsigned long pfn, int count),
> +
> +	TP_ARGS(cma, pfn, count),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, pfn)
> +		__field(unsigned long, count)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn = pfn;
> +		__entry->count = count;
> +	),
> +
> +	TP_printk("pfn=%lu page=%p count=%lu\n",
> +		  __entry->pfn,
> +		  pfn_to_page(__entry->pfn),
> +		  __entry->count)
> +);
> +
> +TRACE_EVENT(cma_release,
> +
> +	TP_PROTO(struct cma *cma, unsigned long pfn, int count),
> +
> +	TP_ARGS(cma, pfn, count),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, pfn)
> +		__field(unsigned long, count)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn = pfn;
> +		__entry->count = count;
> +	),
> +
> +	TP_printk("pfn=%lu page=%p count=%lu\n",
> +		  __entry->pfn,
> +		  pfn_to_page(__entry->pfn),
> +		  __entry->count)
> +);
> +
> +#endif /* _TRACE_CMA_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/mm/cma.c b/mm/cma.c
> index 9e3d44a..3a63c96 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -23,6 +23,7 @@
>  #  define DEBUG
>  #endif
>  #endif
> +#define CREATE_TRACE_POINTS
>
>  #include <linux/memblock.h>
>  #include <linux/err.h>
> @@ -34,6 +35,7 @@
>  #include <linux/cma.h>
>  #include <linux/highmem.h>
>  #include <linux/io.h>
> +#include <trace/events/cma.h>
>
>  #include "cma.h"
>
> @@ -408,6 +410,9 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
>  		start = bitmap_no + mask + 1;
>  	}
>
> +	if (page)
> +		trace_cma_alloc(cma, pfn, count);
> +
>  	pr_debug("%s(): returned %p\n", __func__, page);
>  	return page;
>  }
> @@ -440,6 +445,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
>
>  	free_contig_range(pfn, count);
>  	cma_clear_bitmap(cma, pfn, count);
> +	trace_cma_release(cma, pfn, count);
>
>  	return true;

Are we interested only in successful allocation and release ? Should we also
have the trace point carry information regarding failure ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
