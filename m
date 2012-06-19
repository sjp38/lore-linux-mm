Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 131756B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 07:29:33 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5V0090P3X47T90@mailout1.samsung.com> for
 linux-mm@kvack.org; Tue, 19 Jun 2012 20:29:31 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5V0039A3X6CZ20@mmp1.samsung.com> for linux-mm@kvack.org;
 Tue, 19 Jun 2012 20:29:31 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH] cma: cached pageblock type fixup
Date: Tue, 19 Jun 2012 13:28:50 +0200
References: <201205230922.00530.b.zolnierkie@samsung.com>
 <20120619090015.GE20467@suse.de>
In-reply-to: <20120619090015.GE20467@suse.de>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201206191328.50781.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tuesday 19 June 2012 11:00:15 Mel Gorman wrote:
> On Wed, May 23, 2012 at 09:22:00AM +0200, Bartlomiej Zolnierkiewicz wrote:
> > From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Subject: [PATCH] cma: cached pageblock type fixup
> > 
> > CMA pages added to per-cpu pages lists in free_hot_cold_page()
> > have private field set to MIGRATE_CMA pageblock type .  If this
> > happes just before start_isolate_page_range() in alloc_contig_range()
> > changes pageblock type of the page to MIGRATE_ISOLATE it may result
> > in the cached pageblock type being stale in free_pcppages_bulk()
> > (which may be triggered by drain_all_pages() in alloc_contig_range()),
> 
> So what?

"page being added to MIGRATE_CMA free list instead of MIGRATE_ISOLATE
one in __free_one_page() and (if the page is reused just before
test_pages_isolated() check) causing alloc_contig_range() failure."

> The pages get freed to the MIGRATE_CMA region. At worst they will be
> used for an allocation request that is compatible with being migrated by
> CMA. This will delay the allocation time of alloc_contig_range() but is
> hardly critical.

There is no waiting on MIGRATE_CMA pages in alloc_contig_range() to
become free again.  If the conversion to MIGRATE_ISOLATE fails then
the whole alloc_contig_range() allocation fails on test_pages_isolated()
check.

> Your fix on the other hand adds another call to get_pageblock_type() to
> free_pcppages_bulk which is expensive. The change made to
> buffered_rmqueue() is horrific. It takes the per-cpu page allocation
> path and adds a spin lock to it which completely defeats the purpose of
> having the per-cpu allocation avoid taking locks. This will have a very
> heavy impact on performance, particularly on parallel workloads.
> 
> As the impact of the race should be marginal and the cost of the fix is
> so unbelivably high I'm nacking this patch. If this race is a problem then
> it should be handled in alloc_contig_range() not in the allocator fast paths.

Do you have any idea how this race can be handled in alloc_contig_range()?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
