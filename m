Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5B2606B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:00:50 -0400 (EDT)
Date: Tue, 19 Jun 2012 13:00:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cma: cached pageblock type fixup
Message-ID: <20120619120044.GA8810@suse.de>
References: <201205230922.00530.b.zolnierkie@samsung.com>
 <20120619090015.GE20467@suse.de>
 <201206191328.50781.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201206191328.50781.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Jun 19, 2012 at 01:28:50PM +0200, Bartlomiej Zolnierkiewicz wrote:
> On Tuesday 19 June 2012 11:00:15 Mel Gorman wrote:
> > On Wed, May 23, 2012 at 09:22:00AM +0200, Bartlomiej Zolnierkiewicz wrote:
> > > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > > Subject: [PATCH] cma: cached pageblock type fixup
> > > 
> > > CMA pages added to per-cpu pages lists in free_hot_cold_page()
> > > have private field set to MIGRATE_CMA pageblock type .  If this
> > > happes just before start_isolate_page_range() in alloc_contig_range()
> > > changes pageblock type of the page to MIGRATE_ISOLATE it may result
> > > in the cached pageblock type being stale in free_pcppages_bulk()
> > > (which may be triggered by drain_all_pages() in alloc_contig_range()),
> > 
> > So what?
> 
> "page being added to MIGRATE_CMA free list instead of MIGRATE_ISOLATE
> one in __free_one_page() and (if the page is reused just before
> test_pages_isolated() check) causing alloc_contig_range() failure."
> 

And.... so what?

If it's on the wrong free list then it can still be isolated from that
list if it has not been allocated. If it has been allocated then it must
be a MIGRATE_CMA-compatible allocation so the page can be migrated and
the operation retried.

> > The pages get freed to the MIGRATE_CMA region. At worst they will be
> > used for an allocation request that is compatible with being migrated by
> > CMA. This will delay the allocation time of alloc_contig_range() but is
> > hardly critical.
> 
> There is no waiting on MIGRATE_CMA pages in alloc_contig_range() to
> become free again.  If the conversion to MIGRATE_ISOLATE fails then
> the whole alloc_contig_range() allocation fails on test_pages_isolated()
> check.
> 

Then retry the operation if alloc_contig_range() finds it raced.

> > Your fix on the other hand adds another call to get_pageblock_type() to
> > free_pcppages_bulk which is expensive. The change made to
> > buffered_rmqueue() is horrific. It takes the per-cpu page allocation
> > path and adds a spin lock to it which completely defeats the purpose of
> > having the per-cpu allocation avoid taking locks. This will have a very
> > heavy impact on performance, particularly on parallel workloads.
> > 
> > As the impact of the race should be marginal and the cost of the fix is
> > so unbelivably high I'm nacking this patch. If this race is a problem then
> > it should be handled in alloc_contig_range() not in the allocator fast paths.
> 
> Do you have any idea how this race can be handled in alloc_contig_range()?
> 

If the page is on the wrong free list, just isolate it or move it to the
MIGRATE_ISOLATE free list at that point. If it has been allocated then
migrate it and move the resulting free page to the MIGRATE_ISOLATE list.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
