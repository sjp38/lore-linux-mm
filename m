Subject: Re: [PATCH 7/13] Drain per-cpu lists when high-order allocations
	fail
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <200709110105.25544.nickpiggin@yahoo.com.au>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
	 <20070910112231.3097.53548.sendpatchset@skynet.skynet.ie>
	 <200709110105.25544.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 10:34:27 +0100
Message-Id: <1189503267.32731.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-11 at 01:05 +1000, Nick Piggin wrote:
> On Monday 10 September 2007 21:22, Mel Gorman wrote:
> > Per-cpu pages can accidentally cause fragmentation because they are free,
> > but pinned pages in an otherwise contiguous block.  When this patch is
> > applied, the per-cpu caches are drained after the direct-reclaim is entered
> > if the requested order is greater than 0.  It simply reuses the code used
> > by suspend and hotplug.
> 
> Does this help? I have a more general version which could go in
> instead (independently of the anti fragmentation patches).


Yes, it does help. It's noticable when one is trying to get as much
memory in hugepages as possible. It reaches a certain point where
hugepages are free but pinned due to per-cpu pages. This "certain point"
depends on the number of CPUs as a ratio to the size of physical memory
as well as a certain degree of randomness as the location of per-cpu
pages is not predictable. Worst case is not being able to allocate
something like (NR_CPUS * pcp->high * 2) hugepages even if they are
otherwise free.

By all means if you have a general version, send it and I'll take a
look. If it's more general and nicer but still can be used to drain the
per-cpu lists when high-order allocations fail, I'm all for it.

Thanks Nick

> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> >  mm/page_alloc.c |   24 +++++++++++++++++++++++-
> >  1 file changed, 23 insertions(+), 1 deletion(-)
> >
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff
> > linux-2.6.23-rc5-006-group-short-lived-and-reclaimable-kernel-allocations/m
> >m/page_alloc.c
> > linux-2.6.23-rc5-007-drain-per-cpu-lists-when-high-order-allocations-fail/m
> >m/page_alloc.c ---
> > linux-2.6.23-rc5-006-group-short-lived-and-reclaimable-kernel-allocations/m
> >m/page_alloc.c	2007-09-02 16:20:31.000000000 +0100 +++
> > linux-2.6.23-rc5-007-drain-per-cpu-lists-when-high-order-allocations-fail/m
> >m/page_alloc.c	2007-09-02 16:20:48.000000000 +0100 @@ -852,6 +852,7 @@ void
> > mark_free_pages(struct zone *zone)
> >  	}
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> >  }
> > +#endif /* CONFIG_PM */
> >
> >  /*
> >   * Spill all of this CPU's per-cpu pages back into the buddy allocator.
> > @@ -864,7 +865,25 @@ void drain_local_pages(void)
> >  	__drain_pages(smp_processor_id());
> >  	local_irq_restore(flags);
> >  }
> > -#endif /* CONFIG_HIBERNATION */
> > +
> > +void smp_drain_local_pages(void *arg)
> > +{
> > +	drain_local_pages();
> > +}
> > +
> > +/*
> > + * Spill all the per-cpu pages from all CPUs back into the buddy allocator
> > + */
> > +void drain_all_local_pages(void)
> > +{
> > +	unsigned long flags;
> > +
> > +	local_irq_save(flags);
> > +	__drain_pages(smp_processor_id());
> > +	local_irq_restore(flags);
> > +
> > +	smp_call_function(smp_drain_local_pages, NULL, 0, 1);
> > +}
> >
> >  /*
> >   * Free a 0-order page
> > @@ -1452,6 +1471,9 @@ nofail_alloc:
> >
> >  	cond_resched();
> >
> > +	if (order != 0)
> > +		drain_all_local_pages();
> > +
> >  	if (likely(did_some_progress)) {
> >  		page = get_page_from_freelist(gfp_mask, order,
> >  						zonelist, alloc_flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
