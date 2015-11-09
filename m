Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 65A796B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 17:59:41 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so213157185pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:59:41 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ah10si443400pad.118.2015.11.09.14.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 14:59:40 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so213156936pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 14:59:40 -0800 (PST)
Date: Mon, 9 Nov 2015 14:59:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/cma: add new tracepoint, test_pages_isolated
In-Reply-To: <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1511091457140.20636@chino.kir.corp.google.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com> <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 9 Nov 2015, Joonsoo Kim wrote:

> diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
> index d7cd961..82281b0 100644
> --- a/include/trace/events/cma.h
> +++ b/include/trace/events/cma.h
> @@ -60,6 +60,32 @@ TRACE_EVENT(cma_release,
>  		  __entry->count)
>  );
>  
> +TRACE_EVENT(test_pages_isolated,
> +
> +	TP_PROTO(
> +		unsigned long start_pfn,
> +		unsigned long end_pfn,
> +		unsigned long fin_pfn),
> +
> +	TP_ARGS(start_pfn, end_pfn, fin_pfn),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, start_pfn)
> +		__field(unsigned long, end_pfn)
> +		__field(unsigned long, fin_pfn)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->start_pfn = start_pfn;
> +		__entry->end_pfn = end_pfn;
> +		__entry->fin_pfn = fin_pfn;
> +	),
> +
> +	TP_printk("start_pfn=0x%lx end_pfn=0x%lx fin_pfn=0x%lx ret=%s",
> +		__entry->start_pfn, __entry->end_pfn, __entry->fin_pfn,
> +		__entry->end_pfn == __entry->fin_pfn ? "success" : "fail")
> +);
> +
>  #endif /* _TRACE_CMA_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 6f5ae96..bda0fea 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -7,6 +7,8 @@
>  #include <linux/pageblock-flags.h>
>  #include <linux/memory.h>
>  #include <linux/hugetlb.h>
> +#include <trace/events/cma.h>
> +
>  #include "internal.h"
>  
>  static int set_migratetype_isolate(struct page *page,
> @@ -268,6 +270,9 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  						skip_hwpoisoned_pages);
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  
> +#ifdef CONFIG_CMA
> +	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
> +#endif
>  	return (pfn < end_pfn) ? -EBUSY : 0;
>  }
>  

This is also used for memory offlining, so could we generalize the 
tracepoint to CONFIG_CMA || CONFIG_MEMORY_HOTREMOVE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
