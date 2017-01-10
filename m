Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCB9E6B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 03:34:02 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id l1so10909555wja.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 00:34:02 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id y4si1003325wjc.180.2017.01.10.00.34.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Jan 2017 00:34:01 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id ECCFC99295
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 08:34:00 +0000 (UTC)
Date: Tue, 10 Jan 2017 08:34:00 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Message-ID: <20170110083400.xuek45j3djhc5qli@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
 <20170109163518.6001-5-mgorman@techsingularity.net>
 <01e001d26af6$146295f0$3d27c1d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <01e001d26af6$146295f0$3d27c1d0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Tue, Jan 10, 2017 at 12:00:27PM +0800, Hillf Danton wrote:
> > It shows a roughly 50-60% reduction in the cost of allocating pages.
> > The free paths are not improved as much but relatively little can be batched
> > there. It's not quite as fast as it could be but taking further shortcuts
> > would require making a lot of assumptions about the state of the page and
> > the context of the caller.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > ---
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> 

Thanks.

> > @@ -2485,7 +2485,7 @@ void free_hot_cold_page(struct page *page, bool cold)
> >  }
> > 
> >  /*
> > - * Free a list of 0-order pages
> > + * Free a list of 0-order pages whose reference count is already zero.
> >   */
> >  void free_hot_cold_page_list(struct list_head *list, bool cold)
> >  {
> > @@ -2495,7 +2495,28 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
> >  		trace_mm_page_free_batched(page, cold);
> >  		free_hot_cold_page(page, cold);
> >  	}
> > +
> > +	INIT_LIST_HEAD(list);
> 
> Nit: can we cut this overhead off?

Yes, but note that any caller of free_hot_cold_page_list() is then
required to reinit the list themselves or it'll cause corruption. It's
unlikely that a user of the bulk interface will handle the refcounts and
be able to use this interface properly but if they do, they need to
either reinit this or add the hunk back in.

It happens that all callers currently don't care.

> >  /*
> >   * split_page takes a non-compound higher-order page, and splits it into
> > @@ -3887,6 +3908,99 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> > 
> >  /*
> > + * This is a batched version of the page allocator that attempts to
> > + * allocate nr_pages quickly from the preferred zone and add them to list.
> > + * Note that there is no guarantee that nr_pages will be allocated although
> > + * every effort will be made to allocate at least one. Unlike the core
> > + * allocator, no special effort is made to recover from transient
> > + * failures caused by changes in cpusets. It should only be used from !IRQ
> > + * context. An attempt to allocate a batch of patches from an interrupt
> > + * will allocate a single page.
> > + */
> > +unsigned long
> > +__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
> > +			struct zonelist *zonelist, nodemask_t *nodemask,
> > +			unsigned long nr_pages, struct list_head *alloc_list)
> > +{
> > +	struct page *page;
> > +	unsigned long alloced = 0;
> > +	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> > +	struct zone *zone;
> > +	struct per_cpu_pages *pcp;
> > +	struct list_head *pcp_list;
> > +	int migratetype;
> > +	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
> > +	struct alloc_context ac = { };
> > +	bool cold = ((gfp_mask & __GFP_COLD) != 0);
> > +
> > +	/* If there are already pages on the list, don't bother */
> > +	if (!list_empty(alloc_list))
> > +		return 0;
> 
> Nit: can we move the check to the call site?

Yes, but it makes the API slightly more hazardous to use.

> > +
> > +	/* Only handle bulk allocation of order-0 */
> > +	if (order || in_interrupt())
> > +		goto failed;
> 
> Ditto
> 

Same, if the caller is in interrupt context, there is a slight risk that
they'll corrupt the list in a manner that will be tricky to catch. The
checks are to minimise the risk of being surprising.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
