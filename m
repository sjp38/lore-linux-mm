Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 55A936B006E
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 16:22:16 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so85614088pac.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:22:16 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id os6si5071067pdb.81.2015.03.19.13.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Mar 2015 13:22:14 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLH00AL57FLKD70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Mar 2015 20:26:09 +0000 (GMT)
Message-id: <550B2FEF.7060204@partner.samsung.com>
Date: Thu, 19 Mar 2015 23:22:07 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
 <550741BD.9080109@partner.samsung.com> <20150317074025.GA27548@gmail.com>
In-reply-to: <20150317074025.GA27548@gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>


On 17/03/15 10:40, Ingo Molnar wrote:
> 
> * Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> 
>>> +TRACE_EVENT(cma_alloc,
>>> +
>>> +	TP_PROTO(struct cma *cma, struct page *page, int count),
>>> +
>>> +	TP_ARGS(cma, page, count),
>>> +
>>> +	TP_STRUCT__entry(
>>> +		__field(struct page *, page)
>>> +		__field(unsigned long, count)
>>> +	),
>>> +
>>> +	TP_fast_assign(
>>> +		__entry->page = page;
>>> +		__entry->count = count;
>>> +	),
>>> +
>>> +	TP_printk("page=%p pfn=%lu count=%lu",
>>> +		  __entry->page,
>>> +		  __entry->page ? page_to_pfn(__entry->page) : 0,
>>> +		  __entry->count)
> 
> So I'm wondering, the fast-assign side is not equivalent to the 
> TP_printk() side:
> 
>>> +		__entry->page = page;
>>> +		  __entry->page ? page_to_pfn(__entry->page) : 0,
> 
> to me it seems it would be useful if MM tracing standardized on pfn 
> printing. Just like you did for trace_cma_release().
> 

Hello Ingo, thank you for the reply.
I afraid there is no special sense in printing both struct page * and
pfn. But cma_alloc() returns struct page *, cma_release receives struct
page *, and pr_debugs in these functions print struct page *. Maybe it
would be better to print the same here too?

> Also:
> 
>>> +		  __entry->page ? page_to_pfn(__entry->page) : 0,
> 
> pfn 0 should probably be reserved for the true 0th pfn - those exist 
> in some machines. Returning -1ll could be the 'no such pfn' condition?
> 

I took this from trace_mm_page_alloc() and other trace events from
trace/events/kmem.h. If we return -1 here to indicate "no such pfn",
should we change do this in kmem.h too?

>>> +	TP_STRUCT__entry(
>>> +		__field(unsigned long, pfn)
> 
> Btw., does pfn always fit into 32 bits on 32-bit platforms?
> 

Well, I think it does. cma_release() uses 'unsigned long' on all platforms.

>>> +		__field(unsigned long, count)
> 
> Does this have to be 64-bit on 64-bit platforms?
> 

Oops! I'm terribly wrong.
+		__field(unsigned int, count)

I guess it shouldn't be 64-bit on 64-bit platforms. It's the number of
pages being freed, and in cma_release() 'unsigned int' is used for it.

>>> +	),
>>> +
>>> +	TP_fast_assign(
>>> +		__entry->pfn = pfn;
>>> +		__entry->count = count;
>>> +	),
>>> +
>>> +	TP_printk("pfn=%lu page=%p count=%lu",
>>> +		  __entry->pfn,
>>> +		  pfn_to_page(__entry->pfn),
>>> +		  __entry->count)
> 
> So here you print more in the TP_printk() line than in the fast-assign 
> side.
> 

See above, I think it's the same case as in trace_cma_alloc() TP_printk().

> Again I'd double check the various boundary conditions.
> 

Sorry, I don't quite understand. Boundary conditions are already [should
be] checked in cma_alloc()/cma_release, we should only pass to a trace
event the information we want to be known, isn't it so?

I again terribly sorry, I also completely forgot about struct cma *
being passed to trace event. I think either it should be used somehow
(e.g. to print the number of CMA region) or shouldn't be passed...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
