Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 621166B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:57:42 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so16208184wma.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:57:42 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id o6si12089267wmi.105.2016.12.05.01.57.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:57:40 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 67043993DA
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 09:57:40 +0000 (UTC)
Date: Mon, 5 Dec 2016 09:57:39 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161205095739.i5ucbzspnjedupin@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
 <20161202090449.kxktmyf5sdp2sroh@techsingularity.net>
 <20161205030619.GA1378@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161205030619.GA1378@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, Dec 05, 2016 at 12:06:19PM +0900, Joonsoo Kim wrote:
> On Fri, Dec 02, 2016 at 09:04:49AM +0000, Mel Gorman wrote:
> > On Fri, Dec 02, 2016 at 03:03:46PM +0900, Joonsoo Kim wrote:
> > > > @@ -1132,14 +1134,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> > > >  			if (unlikely(isolated_pageblocks))
> > > >  				mt = get_pageblock_migratetype(page);
> > > >  
> > > > +			nr_freed += (1 << order);
> > > > +			count -= (1 << order);
> > > >  			if (bulkfree_pcp_prepare(page))
> > > >  				continue;
> > > >  
> > > > -			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> > > > -			trace_mm_page_pcpu_drain(page, 0, mt);
> > > > -		} while (--count && --batch_free && !list_empty(list));
> > > > +			__free_one_page(page, page_to_pfn(page), zone, order, mt);
> > > > +			trace_mm_page_pcpu_drain(page, order, mt);
> > > > +		} while (count > 0 && --batch_free && !list_empty(list));
> > > >  	}
> > > >  	spin_unlock(&zone->lock);
> > > > +	pcp->count -= nr_freed;
> > > >  }
> > > 
> > > I guess that this patch would cause following problems.
> > > 
> > > 1. If pcp->batch is too small, high order page will not be freed
> > > easily and survive longer. Think about following situation.
> > > 
> > > Batch count: 7
> > > MIGRATE_UNMOVABLE -> MIGRATE_MOVABLE -> MIGRATE_RECLAIMABLE -> order 1
> > > -> order 2...
> > > 
> > > free count: 1 + 1 + 1 + 2 + 4 = 9
> > > so order 3 would not be freed.
> > > 
> > 
> > You're relying on the batch count to be 7 where in a lot of cases it's
> > 31. Even if low batch counts are common on another platform or you adjusted
> > the other counts to be higher values until they equal 30, it would be for
> > this drain that no order-3 pages were freed. It's not a permanent situation.
> > 
> > When or if it gets freed depends on the allocation request stream but the
> > same applies to the existing caches. If a high-order request arrives, it'll
> > be used. If all the requests are for the other orders, then eventually
> > the frees will hit the high watermark enough that the round-robin batch
> > freeing fill free the order-3 entry in the cache.
> 
> I know that it isn't a permanent situation and it depends on workload.
> However, it is clearly an unfair situation. We don't have any good reason
> to cache higher order freepage longer. Even, batch count 7 means
> that it is a small system. In this kind of system, there is no reason
> to keep high order freepage longer in the cache.
> 

Without knowing the future allocation request stream, there is no reason
to favour one part of the per-cpu cache over another. To me, it's not
actually clear at all it's an unfair situation, particularly given that the
vanilla code is also unfair -- the vanilla code can artifically preserve
MIGRATE_UNMOVABLE without any clear indication that it is a universal win.
The only deciding factor there was a fault-intensive workload would mask
overhead of the page allocator due to page zeroing cost which UNMOVABLE
allocations may or may not require. Even that is vague considering that
page-table allocations are zeroing even if many kernel allocations are not.

> The other potential problem is that if we change
> PAGE_ALLOC_COSTLY_ORDER to 5 in the future, this 31 batch count also
> doesn't guarantee that free_pcppages_bulk() will work fairly and we
> will not notice it easily.
> 

In the event the high-order cache is increased, then the high watermark
would also need to be adjusted to account for that just as this patch
does.

> I think that it can be simply solved by maintaining a last pindex in
> pcp. How about it?
> 

That would rely on the previous allocation stream to drive the freeing
which is slightly related to the fact the per-cpu cache contents are
related to the previous request stream. It's still not guaranteed to be
related to the future request stream.

Adding a new pindex cache adds complexity to the free path without any
guarantee it benefits anything. The use of such a heuristic should be
driven by a workload demonstrating it's a problem. Granted, half of the
cost of a free operations is due to irq enable/disable but there is no
reason to make it unnecessarily expensive.

> > > 3. I guess that order-0 file/anon page alloc/free is dominent in many
> > > workloads. If this case happen, it invalidates effect of high order
> > > cache in pcp since cached high order pages would be also freed to the
> > > buddy when burst order-0 free happens.
> > > 
> > 
> > A large burst of order-0 frees will free the high-order cache if it's not
> > being used but I don't see what your point is or why that is a problem.
> > It is pretty much guaranteed that there will be workloads that benefit
> > from protecting the high-order cache (SLUB-intensive alloc/free
> > intensive workloads) while others suffer (Fault-intensive map/unmap
> > workloads).
> > 
> > What's there at the moment behaves reasonably on a variety of workloads
> > across 8 machines.
> 
> Yes, I see that this patch improves some workloads. What I like to say
> is that I find some weakness and if it is fixed, we can get better
> result. This patch implement unified pcp cache for migratetype and
> high-order but if we separate them and manage number of cached items
> separately, we would not have above problem. Could you teach me the
> reason not to implement the separate cache for high order?
> 

It's additional complexity and a separate cache that would require separate
batch counts and high watermarks for order-0 and high-order for a problem
that is not demonstrated as being necessary by a workload on any platform.

> > 
> > > > @@ -2589,20 +2595,33 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> > > >  	struct page *page;
> > > >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> > > >  
> > > > -	if (likely(order == 0)) {
> > > > +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
> > > >  		struct per_cpu_pages *pcp;
> > > >  		struct list_head *list;
> > > >  
> > > >  		local_irq_save(flags);
> > > >  		do {
> > > > +			unsigned int pindex;
> > > > +
> > > > +			pindex = order_to_pindex(migratetype, order);
> > > >  			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > > > -			list = &pcp->lists[migratetype];
> > > > +			list = &pcp->lists[pindex];
> > > >  			if (list_empty(list)) {
> > > > -				pcp->count += rmqueue_bulk(zone, 0,
> > > > +				int nr_pages = rmqueue_bulk(zone, order,
> > > >  						pcp->batch, list,
> > > >  						migratetype, cold);
> > > 
> > > Maybe, you need to fix rmqueue_bulk(). rmqueue_bulk() allocates batch
> > > * (1 << order) pages and pcp->count can easily overflow pcp->high
> > > * because list empty here doesn't mean that pcp->count is zero.
> > > 
> > 
> > Potentially a refill can cause a drain on another list. However, I adjusted
> > the high watermark in pageset_set_batch to make it unlikely that a single
> > refill will cause a drain and added a comment about it. I say unlikely
> > because it's not guaranteed. A carefully created workload could potentially
> > bring all the order-0 and some of the high-order caches close to the
> > watermark and then trigger a drain due to a refill of order-3.  The impact
> > is marginal and in itself does not warrent increasing the high watermark
> > to guarantee that no single refill can cause a drain on the next free.
> 
> Hmm... What makes me wonder is that alloc/free isn't symmetric.
> Free in free_pcppages_bulk() are done until number of freed pages
> becomes the batch. High order pages are counted as 1 << order.
> But, in refill here, counting high order pages is single one rather than
> 1 << order. This asymmetric alloc/free is intended? Why do we cache same
> number of high order page with the number of order-0 page in one
> batch?
> 

Because on the alloc side, we're batching the number of operations done
under the lock and on the free side, we're concerned with how much memory
is pinned by the per-cpu cache. There are different options that could
be taken such as accounting for the number of list elements instead of
order-0 pages but that will make the size of the per-cpu cache variable
without necessarily being beneficial. Pretty much anything related to the
per-cpu cache is an optimistic heuristic on what is beneficial to cache
and when with the view to reducing operations taken under the zone->lock.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
