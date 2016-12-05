Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 37A4C6B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 22:02:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so336536070pgc.5
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 19:02:53 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y1si13019165pfd.3.2016.12.04.19.02.51
        for <linux-mm@kvack.org>;
        Sun, 04 Dec 2016 19:02:52 -0800 (PST)
Date: Mon, 5 Dec 2016 12:06:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161205030619.GA1378@js1304-P5Q-DELUXE>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
 <20161202090449.kxktmyf5sdp2sroh@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202090449.kxktmyf5sdp2sroh@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 02, 2016 at 09:04:49AM +0000, Mel Gorman wrote:
> On Fri, Dec 02, 2016 at 03:03:46PM +0900, Joonsoo Kim wrote:
> > > @@ -1132,14 +1134,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> > >  			if (unlikely(isolated_pageblocks))
> > >  				mt = get_pageblock_migratetype(page);
> > >  
> > > +			nr_freed += (1 << order);
> > > +			count -= (1 << order);
> > >  			if (bulkfree_pcp_prepare(page))
> > >  				continue;
> > >  
> > > -			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> > > -			trace_mm_page_pcpu_drain(page, 0, mt);
> > > -		} while (--count && --batch_free && !list_empty(list));
> > > +			__free_one_page(page, page_to_pfn(page), zone, order, mt);
> > > +			trace_mm_page_pcpu_drain(page, order, mt);
> > > +		} while (count > 0 && --batch_free && !list_empty(list));
> > >  	}
> > >  	spin_unlock(&zone->lock);
> > > +	pcp->count -= nr_freed;
> > >  }
> > 
> > I guess that this patch would cause following problems.
> > 
> > 1. If pcp->batch is too small, high order page will not be freed
> > easily and survive longer. Think about following situation.
> > 
> > Batch count: 7
> > MIGRATE_UNMOVABLE -> MIGRATE_MOVABLE -> MIGRATE_RECLAIMABLE -> order 1
> > -> order 2...
> > 
> > free count: 1 + 1 + 1 + 2 + 4 = 9
> > so order 3 would not be freed.
> > 
> 
> You're relying on the batch count to be 7 where in a lot of cases it's
> 31. Even if low batch counts are common on another platform or you adjusted
> the other counts to be higher values until they equal 30, it would be for
> this drain that no order-3 pages were freed. It's not a permanent situation.
> 
> When or if it gets freed depends on the allocation request stream but the
> same applies to the existing caches. If a high-order request arrives, it'll
> be used. If all the requests are for the other orders, then eventually
> the frees will hit the high watermark enough that the round-robin batch
> freeing fill free the order-3 entry in the cache.

I know that it isn't a permanent situation and it depends on workload.
However, it is clearly an unfair situation. We don't have any good reason
to cache higher order freepage longer. Even, batch count 7 means
that it is a small system. In this kind of system, there is no reason
to keep high order freepage longer in the cache.

The other potential problem is that if we change
PAGE_ALLOC_COSTLY_ORDER to 5 in the future, this 31 batch count also
doesn't guarantee that free_pcppages_bulk() will work fairly and we
will not notice it easily.

I think that it can be simply solved by maintaining a last pindex in
pcp. How about it?

> 
> > 2. And, It seems that this logic penalties high order pages. One free
> > to high order page means 1 << order pages free rather than just
> > one page free. This logic do round-robin to choose the target page so
> > amount of freed page will be different by the order. I think that it
> > makes some sense because high order page are less important to cache
> > in pcp than lower order but I'd like to know if it is intended or not.
> > If intended, it deserves the comment.
> > 
> 
> It's intended but I'm not sure what else you want me to explain outside
> the code itself in this case. The round-robin nature of the bulk drain
> already doesn't attach any special important to the migrate type of the
> list and there is no good reason to assume that high-order pages in the
> cache when the high watermark is reached deserve special protection.

Non-trivial part is that round-robin approach penalties high-order
pages caching. We usually think that round-robin is fair, but, in this
case, it isn't. Some people can notice that amount of freepage in turn is
different but some may not. It is a different situation in the past that
amount of freepage in turn is same even if migratetype is different. I
think that it deserve some comment but I don't feel it strongly.

> > 3. I guess that order-0 file/anon page alloc/free is dominent in many
> > workloads. If this case happen, it invalidates effect of high order
> > cache in pcp since cached high order pages would be also freed to the
> > buddy when burst order-0 free happens.
> > 
> 
> A large burst of order-0 frees will free the high-order cache if it's not
> being used but I don't see what your point is or why that is a problem.
> It is pretty much guaranteed that there will be workloads that benefit
> from protecting the high-order cache (SLUB-intensive alloc/free
> intensive workloads) while others suffer (Fault-intensive map/unmap
> workloads).
> 
> What's there at the moment behaves reasonably on a variety of workloads
> across 8 machines.

Yes, I see that this patch improves some workloads. What I like to say
is that I find some weakness and if it is fixed, we can get better
result. This patch implement unified pcp cache for migratetype and
high-order but if we separate them and manage number of cached items
separately, we would not have above problem. Could you teach me the
reason not to implement the separate cache for high order?

> 
> > > @@ -2589,20 +2595,33 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> > >  	struct page *page;
> > >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> > >  
> > > -	if (likely(order == 0)) {
> > > +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
> > >  		struct per_cpu_pages *pcp;
> > >  		struct list_head *list;
> > >  
> > >  		local_irq_save(flags);
> > >  		do {
> > > +			unsigned int pindex;
> > > +
> > > +			pindex = order_to_pindex(migratetype, order);
> > >  			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > > -			list = &pcp->lists[migratetype];
> > > +			list = &pcp->lists[pindex];
> > >  			if (list_empty(list)) {
> > > -				pcp->count += rmqueue_bulk(zone, 0,
> > > +				int nr_pages = rmqueue_bulk(zone, order,
> > >  						pcp->batch, list,
> > >  						migratetype, cold);
> > 
> > Maybe, you need to fix rmqueue_bulk(). rmqueue_bulk() allocates batch
> > * (1 << order) pages and pcp->count can easily overflow pcp->high
> > * because list empty here doesn't mean that pcp->count is zero.
> > 
> 
> Potentially a refill can cause a drain on another list. However, I adjusted
> the high watermark in pageset_set_batch to make it unlikely that a single
> refill will cause a drain and added a comment about it. I say unlikely
> because it's not guaranteed. A carefully created workload could potentially
> bring all the order-0 and some of the high-order caches close to the
> watermark and then trigger a drain due to a refill of order-3.  The impact
> is marginal and in itself does not warrent increasing the high watermark
> to guarantee that no single refill can cause a drain on the next free.

Hmm... What makes me wonder is that alloc/free isn't symmetric.
Free in free_pcppages_bulk() are done until number of freed pages
becomes the batch. High order pages are counted as 1 << order. But, in
refill here, counting high order pages is single one rather than
1 << order. This asymmetric alloc/free is intended? Why do we cache same
number of high order page with the number of order-0 page in one
batch?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
