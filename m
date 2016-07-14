Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5876B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 21:10:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u186so124409881ita.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 18:10:04 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n9si19577672itn.14.2016.07.13.18.10.02
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 18:10:03 -0700 (PDT)
Date: Thu, 14 Jul 2016 10:11:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix pgalloc_stall on unpopulated zone
Message-ID: <20160714011119.GA23512@bbox>
References: <1468376653-26561-1-git-send-email-minchan@kernel.org>
 <20160713092504.GJ11400@suse.de>
MIME-Version: 1.0
In-Reply-To: <20160713092504.GJ11400@suse.de>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 13, 2016 at 10:25:04AM +0100, Mel Gorman wrote:
> On Wed, Jul 13, 2016 at 11:24:13AM +0900, Minchan Kim wrote:
> > If we use sc->reclaim_idx for accounting pgstall, it can increase
> > the count on unpopulated zone, for example, movable zone(but
> > my system doesn't have movable zone) if allocation request were
> > GFP_HIGHUSER_MOVABLE. It doesn't make no sense.
> > 
> 
> I wanted to track the highest zone allowed by each allocation regardless
> of what the zone population state was. Otherwise, consider the following
> on a NUMA system
> 
> 1. An allocation request arrives for GFP_HIGHUSER_MOVABLE that stalls
> 2. System has two nodes, node 0 with ZONE_NORMAL, node 1 with ZONE_HIGHMEM
> 3. If the allocating process is on node 0, the stall is accounted on ZONE_NORMAL
> 4. If the allocatinn process is on node 1, the stall is accounted on ZONE_HIGHMEM
> 
> Multiple runs of the same workload on the same machine will see stall
> statistics on different zones and renders the stat useless. This is
> difficult to analyse because stalls accounted for on ZONE_NORMAL may or
> may not be zone-constrained allocations.

Fair enough.
For the allocstall, it would be better to show the requested zone.

> 
> The patch means that the vmstat accounting and tracepoint data is also
> out of sync. One thing I wanted to be able to do was
> 
> 1. Observe that there are alloc stalls on DMA32 or some other low zone
> 2. Activate mm_vmscan_direct_reclaim_begin, filter on classzone_idx ==
>    DMA32 and identify the source of the lowmem allocations
> 
> If your patch is applied, I cannot depend on the stall stats any more
> and the tracepoint is required to determine if there really any
> zone-contrained allocations. It can be *inferred* from the skip stats
> but only if such skips occurred and that is not guaranteed.

Just a nit:

Hmm, can't we omit classzone_idx in mm_vm_scan_direct_begin_template?
Because every functions already have gfp_flags so that we can classzone_idx
via gfp_zone(gfp_flags) without passing it.


> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
