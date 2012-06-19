Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2A31F6B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 05:00:21 -0400 (EDT)
Date: Tue, 19 Jun 2012 10:00:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cma: cached pageblock type fixup
Message-ID: <20120619090015.GE20467@suse.de>
References: <201205230922.00530.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201205230922.00530.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Wed, May 23, 2012 at 09:22:00AM +0200, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] cma: cached pageblock type fixup
> 
> CMA pages added to per-cpu pages lists in free_hot_cold_page()
> have private field set to MIGRATE_CMA pageblock type .  If this
> happes just before start_isolate_page_range() in alloc_contig_range()
> changes pageblock type of the page to MIGRATE_ISOLATE it may result
> in the cached pageblock type being stale in free_pcppages_bulk()
> (which may be triggered by drain_all_pages() in alloc_contig_range()),

So what?

The pages get freed to the MIGRATE_CMA region. At worst they will be
used for an allocation request that is compatible with being migrated by
CMA. This will delay the allocation time of alloc_contig_range() but is
hardly critical.

Your fix on the other hand adds another call to get_pageblock_type() to
free_pcppages_bulk which is expensive. The change made to
buffered_rmqueue() is horrific. It takes the per-cpu page allocation
path and adds a spin lock to it which completely defeats the purpose of
having the per-cpu allocation avoid taking locks. This will have a very
heavy impact on performance, particularly on parallel workloads.

As the impact of the race should be marginal and the cost of the fix is
so unbelivably high I'm nacking this patch. If this race is a problem then
it should be handled in alloc_contig_range() not in the allocator fast paths.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
