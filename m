Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3D76B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 10:04:24 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so48382253wib.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 07:04:24 -0700 (PDT)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com. [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id nj9si11837489wic.88.2015.03.23.07.04.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 07:04:22 -0700 (PDT)
Received: by wgdm6 with SMTP id m6so146862034wgd.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 07:04:22 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:04:17 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Message-ID: <20150323140417.GD25233@gmail.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
 <550741BD.9080109@partner.samsung.com>
 <20150317074025.GA27548@gmail.com>
 <550B2FEF.7060204@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <550B2FEF.7060204@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>


* Stefan Strogin <s.strogin@partner.samsung.com> wrote:

> 
> On 17/03/15 10:40, Ingo Molnar wrote:
> > 
> > * Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> > 
> >>> +TRACE_EVENT(cma_alloc,
> >>> +
> >>> +	TP_PROTO(struct cma *cma, struct page *page, int count),
> >>> +
> >>> +	TP_ARGS(cma, page, count),
> >>> +
> >>> +	TP_STRUCT__entry(
> >>> +		__field(struct page *, page)
> >>> +		__field(unsigned long, count)
> >>> +	),
> >>> +
> >>> +	TP_fast_assign(
> >>> +		__entry->page = page;
> >>> +		__entry->count = count;
> >>> +	),
> >>> +
> >>> +	TP_printk("page=%p pfn=%lu count=%lu",
> >>> +		  __entry->page,
> >>> +		  __entry->page ? page_to_pfn(__entry->page) : 0,
> >>> +		  __entry->count)
> > 
> > So I'm wondering, the fast-assign side is not equivalent to the 
> > TP_printk() side:
> > 
> >>> +		__entry->page = page;
> >>> +		  __entry->page ? page_to_pfn(__entry->page) : 0,
> > 
> > to me it seems it would be useful if MM tracing standardized on pfn 
> > printing. Just like you did for trace_cma_release().
> > 
> 
> Hello Ingo, thank you for the reply.
> I afraid there is no special sense in printing both struct page * and
> pfn. But cma_alloc() returns struct page *, cma_release receives struct
> page *, and pr_debugs in these functions print struct page *. Maybe it
> would be better to print the same here too?

So will the tracepoints primarily log 'struct page *'?

If yes, my question is: why not log pfn? pfn is much more informative 
(it's a hardware property of the page, not a kernel-internal 
descriptor like 'struct page *') , and it tells us (without knowing 
the layout of the kernel) which NUMA node a given area lies on, etc.

Or do other mm tracepoints already (mistakenly) use 'struct page *'?

> > Again I'd double check the various boundary conditions.
> > 
> 
> Sorry, I don't quite understand. Boundary conditions are already 
> [should be] checked in cma_alloc()/cma_release, we should only pass 
> to a trace event the information we want to be known, isn't it so?

No, I mean tracing info boundary conditions: what is returned when no 
such page is allocated, what is returned when pfn #0 is allocated, 
etc.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
