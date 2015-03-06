Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6146B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 02:26:17 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so47153867pdb.4
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 23:26:17 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bo12si13375550pdb.25.2015.03.05.23.26.15
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 23:26:16 -0800 (PST)
Date: Fri, 6 Mar 2015 16:26:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 00/16] Introduce ZONE_CMA
Message-ID: <20150306072649.GB15051@js1304-P5Q-DELUXE>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
 <54F88A13.4010003@suse.cz>
 <54F89702.8070405@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F89702.8070405@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>

On Thu, Mar 05, 2015 at 06:48:50PM +0100, Vlastimil Babka wrote:
> On 03/05/2015 05:53 PM, Vlastimil Babka wrote:
> > On 02/12/2015 08:32 AM, Joonsoo Kim wrote:
> >> 
> >> 1) Break non-overlapped zone assumption
> >> CMA regions could be spread to all memory range, so, to keep all of them
> >> into one zone, span of ZONE_CMA would be overlap to other zones'.
> > 
> > From patch 13/16 ut seems to me that indeed the ZONE_CMA spans the area of all
> > other zones. This seems very inefficient for e.g. compaction scanners, which
> > will repeatedly skip huge amounts of pageblocks that don't belong to ZONE_CMA.
> > Could you instead pick only a single zone on a node from which you steal the
> > pages? That would allow to keep the span low.

Hello, Vlastimil.

CMA is used for DMA now and it sometimes has memory range constraint
so we could not limit zone span as low. But, current implementatino
unnecessarilly set up ZONE_CMA's span from start_pfn of node to
end_pfn of node. I will change it to the range where we actually steal
pages. Maybe, most of usecase of CMA would use small, limited range of
memory so it doesn't impose critical performance problem on zone's pfn
iterator such as compaction scanners.

> > 
> > Another disadvantage I see is that to allocate from ZONE_CMA you will have now
> > to reclaim enough pages within the zone itself. I think think the cma allocation
> 
>                                                   I don't think...
> 
> > supports migrating pages from ZONE_CMA to the adjacent non-CMA zone, which would
> > be equivalent to migration from MIGRATE_CMA pageblocks to the rest of the zone?

I'm not sure I understand your question correctly.

cma allocation uses alloc_migrate_target() to get migration target
freepage and it doesn't impose any zone contraint so migrating pages
from ZONE_CMA to the adjacent non-CMA zone is possible. Am I
understading you question correctly? If I mis-understand, please let
me know.

Thanks.

> >> I'm not sure that there is an assumption about possibility of zone overlap
> >> But, if ZONE_CMA is introduced, this assumption becomes reality
> >> so we should deal with this situation. I investigated most of sites
> >> that iterates pfn on certain zone and found that they normally doesn't
> >> consider zone overlap. I tried to handle these cases by myself in the
> >> early of this series. I hope that there is no more site that depends on
> >> non-overlap zone assumption when iterating pfn on certain zone.
> >> 
> >> I passed boot test on x86, ARM32 and ARM64. I did some stress tests
> >> on x86 and there is no problem. Feel free to enjoy and please give me
> >> a feedback. :)
> >> 
> >> This patchset is based on v3.18.
> >> 
> >> Thanks.
> >> 
> >> [1] https://lkml.org/lkml/2014/5/28/64
> >> [2] https://lkml.org/lkml/2014/11/4/55 
> >> [3] https://lkml.org/lkml/2014/10/15/623
> >> [4] https://lkml.org/lkml/2014/5/30/320
> >> 
> >> 
> >> Joonsoo Kim (16):
> >>   mm/page_alloc: correct highmem memory statistics
> >>   mm/writeback: correct dirty page calculation for highmem
> >>   mm/highmem: make nr_free_highpages() handles all highmem zones by
> >>     itself
> >>   mm/vmstat: make node_page_state() handles all zones by itself
> >>   mm/vmstat: watch out zone range overlap
> >>   mm/page_alloc: watch out zone range overlap
> >>   mm/page_isolation: watch out zone range overlap
> >>   power: watch out zone range overlap
> >>   mm/cma: introduce cma_total_pages() for future use
> >>   mm/highmem: remove is_highmem_idx()
> >>   mm/page_alloc: clean-up free_area_init_core()
> >>   mm/cma: introduce new zone, ZONE_CMA
> >>   mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
> >>   mm/cma: print stealed page count
> >>   mm/cma: remove ALLOC_CMA
> >>   mm/cma: remove MIGRATE_CMA
> >> 
> >>  arch/x86/include/asm/sparsemem.h  |    2 +-
> >>  arch/x86/mm/highmem_32.c          |    3 +
> >>  include/linux/cma.h               |    9 ++
> >>  include/linux/gfp.h               |   31 +++---
> >>  include/linux/mempolicy.h         |    2 +-
> >>  include/linux/mm.h                |    1 +
> >>  include/linux/mmzone.h            |   58 +++++-----
> >>  include/linux/page-flags-layout.h |    2 +
> >>  include/linux/vm_event_item.h     |    8 +-
> >>  include/linux/vmstat.h            |   26 +----
> >>  kernel/power/snapshot.c           |   15 +++
> >>  lib/show_mem.c                    |    2 +-
> >>  mm/cma.c                          |   70 ++++++++++--
> >>  mm/compaction.c                   |    6 +-
> >>  mm/highmem.c                      |   12 +-
> >>  mm/hugetlb.c                      |    2 +-
> >>  mm/internal.h                     |    3 +-
> >>  mm/memory_hotplug.c               |    3 +
> >>  mm/mempolicy.c                    |    3 +-
> >>  mm/page-writeback.c               |    8 +-
> >>  mm/page_alloc.c                   |  223 +++++++++++++++++++++----------------
> >>  mm/page_isolation.c               |   14 ++-
> >>  mm/vmscan.c                       |    2 +-
> >>  mm/vmstat.c                       |   16 ++-
> >>  24 files changed, 317 insertions(+), 204 deletions(-)
> >> 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
