Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBAC6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 04:04:52 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id o2so36523342wje.5
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 01:04:52 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id pl2si4304371wjb.86.2016.12.02.01.04.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 01:04:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 5B43B98E99
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:04:50 +0000 (UTC)
Date: Fri, 2 Dec 2016 09:04:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: page_alloc: High-order per-cpu page allocator v5
Message-ID: <20161202090449.kxktmyf5sdp2sroh@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-3-mgorman@techsingularity.net>
 <20161202060346.GA21434@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161202060346.GA21434@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 02, 2016 at 03:03:46PM +0900, Joonsoo Kim wrote:
> > @@ -1132,14 +1134,17 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			if (unlikely(isolated_pageblocks))
> >  				mt = get_pageblock_migratetype(page);
> >  
> > +			nr_freed += (1 << order);
> > +			count -= (1 << order);
> >  			if (bulkfree_pcp_prepare(page))
> >  				continue;
> >  
> > -			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> > -			trace_mm_page_pcpu_drain(page, 0, mt);
> > -		} while (--count && --batch_free && !list_empty(list));
> > +			__free_one_page(page, page_to_pfn(page), zone, order, mt);
> > +			trace_mm_page_pcpu_drain(page, order, mt);
> > +		} while (count > 0 && --batch_free && !list_empty(list));
> >  	}
> >  	spin_unlock(&zone->lock);
> > +	pcp->count -= nr_freed;
> >  }
> 
> I guess that this patch would cause following problems.
> 
> 1. If pcp->batch is too small, high order page will not be freed
> easily and survive longer. Think about following situation.
> 
> Batch count: 7
> MIGRATE_UNMOVABLE -> MIGRATE_MOVABLE -> MIGRATE_RECLAIMABLE -> order 1
> -> order 2...
> 
> free count: 1 + 1 + 1 + 2 + 4 = 9
> so order 3 would not be freed.
> 

You're relying on the batch count to be 7 where in a lot of cases it's
31. Even if low batch counts are common on another platform or you adjusted
the other counts to be higher values until they equal 30, it would be for
this drain that no order-3 pages were freed. It's not a permanent situation.

When or if it gets freed depends on the allocation request stream but the
same applies to the existing caches. If a high-order request arrives, it'll
be used. If all the requests are for the other orders, then eventually
the frees will hit the high watermark enough that the round-robin batch
freeing fill free the order-3 entry in the cache.

> 2. And, It seems that this logic penalties high order pages. One free
> to high order page means 1 << order pages free rather than just
> one page free. This logic do round-robin to choose the target page so
> amount of freed page will be different by the order. I think that it
> makes some sense because high order page are less important to cache
> in pcp than lower order but I'd like to know if it is intended or not.
> If intended, it deserves the comment.
> 

It's intended but I'm not sure what else you want me to explain outside
the code itself in this case. The round-robin nature of the bulk drain
already doesn't attach any special important to the migrate type of the
list and there is no good reason to assume that high-order pages in the
cache when the high watermark is reached deserve special protection.

> 3. I guess that order-0 file/anon page alloc/free is dominent in many
> workloads. If this case happen, it invalidates effect of high order
> cache in pcp since cached high order pages would be also freed to the
> buddy when burst order-0 free happens.
> 

A large burst of order-0 frees will free the high-order cache if it's not
being used but I don't see what your point is or why that is a problem.
It is pretty much guaranteed that there will be workloads that benefit
from protecting the high-order cache (SLUB-intensive alloc/free
intensive workloads) while others suffer (Fault-intensive map/unmap
workloads).

What's there at the moment behaves reasonably on a variety of workloads
across 8 machines.

> > @@ -2589,20 +2595,33 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> >  	struct page *page;
> >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> >  
> > -	if (likely(order == 0)) {
> > +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
> >  		struct per_cpu_pages *pcp;
> >  		struct list_head *list;
> >  
> >  		local_irq_save(flags);
> >  		do {
> > +			unsigned int pindex;
> > +
> > +			pindex = order_to_pindex(migratetype, order);
> >  			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > -			list = &pcp->lists[migratetype];
> > +			list = &pcp->lists[pindex];
> >  			if (list_empty(list)) {
> > -				pcp->count += rmqueue_bulk(zone, 0,
> > +				int nr_pages = rmqueue_bulk(zone, order,
> >  						pcp->batch, list,
> >  						migratetype, cold);
> 
> Maybe, you need to fix rmqueue_bulk(). rmqueue_bulk() allocates batch
> * (1 << order) pages and pcp->count can easily overflow pcp->high
> * because list empty here doesn't mean that pcp->count is zero.
> 

Potentially a refill can cause a drain on another list. However, I adjusted
the high watermark in pageset_set_batch to make it unlikely that a single
refill will cause a drain and added a comment about it. I say unlikely
because it's not guaranteed. A carefully created workload could potentially
bring all the order-0 and some of the high-order caches close to the
watermark and then trigger a drain due to a refill of order-3.  The impact
is marginal and in itself does not warrent increasing the high watermark
to guarantee that no single refill can cause a drain on the next free.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
