Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8006B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 03:40:32 -0400 (EDT)
Received: by wggv3 with SMTP id v3so1290043wgg.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 00:40:31 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id y9si22100455wjq.2.2015.03.17.00.40.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 00:40:30 -0700 (PDT)
Received: by wibdy8 with SMTP id dy8so55988116wib.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 00:40:29 -0700 (PDT)
Date: Tue, 17 Mar 2015 08:40:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Message-ID: <20150317074025.GA27548@gmail.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
 <550741BD.9080109@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <550741BD.9080109@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>


* Stefan Strogin <s.strogin@partner.samsung.com> wrote:

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
> > +		  __entry->count)

So I'm wondering, the fast-assign side is not equivalent to the 
TP_printk() side:

> > +		__entry->page = page;
> > +		  __entry->page ? page_to_pfn(__entry->page) : 0,

to me it seems it would be useful if MM tracing standardized on pfn 
printing. Just like you did for trace_cma_release().

Also:

> > +		  __entry->page ? page_to_pfn(__entry->page) : 0,

pfn 0 should probably be reserved for the true 0th pfn - those exist 
in some machines. Returning -1ll could be the 'no such pfn' condition?

> > +	TP_STRUCT__entry(
> > +		__field(unsigned long, pfn)

Btw., does pfn always fit into 32 bits on 32-bit platforms?

> > +		__field(unsigned long, count)

Does this have to be 64-bit on 64-bit platforms?

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
> > +		  __entry->count)

So here you print more in the TP_printk() line than in the fast-assign 
side.

Again I'd double check the various boundary conditions.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
