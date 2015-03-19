Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2346B006E
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 16:18:27 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so85985336pdb.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:18:27 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id kt1si5195712pdb.20.2015.03.19.13.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Mar 2015 13:18:26 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLH008IT79F7Y70@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Mar 2015 20:22:27 +0000 (GMT)
Message-id: <550B2F0A.3010909@partner.samsung.com>
Date: Thu, 19 Mar 2015 23:18:18 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
 <550741BD.9080109@partner.samsung.com>
 <20150316194750.04885ee7@grimm.local.home>
In-reply-to: <20150316194750.04885ee7@grimm.local.home>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Ingo Molnar <mingo@redhat.com>


On 17/03/15 02:47, Steven Rostedt wrote:
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
> 
> Can page_to_pfn(value) ever be different throughout the life of the
> boot? That is, can it return a different result given the same value
> (vmalloc area comes to mind).
> 
>>> +	TP_printk("pfn=%lu page=%p count=%lu",
>>> +		  __entry->pfn,
>>> +		  pfn_to_page(__entry->pfn),
> 
> Same here. Can pfn_to_page(value) ever return a different result with
> the same value in a single boot?
> 

Thank you for the reply, Steven.
I supposed that page_to_pfn() cannot change after mem_map
initialization, can it? I'm not sure about such things as memory hotplug
though...
Also cma_alloc() calls alloc_contig_range() which returns pfn, then it's
converted to struct page * and cma_alloc() returns struct page *, and
vice versa in cma_release() (receives struct page * and passes pfn to
free_contig_rage()).
Do you mean that printing pfn (or struct page *) in trace event is
redundant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
