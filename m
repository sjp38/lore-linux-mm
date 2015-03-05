Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id E5C3E6B0071
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:53:49 -0500 (EST)
Received: by lbjf15 with SMTP id f15so24647371lbj.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:53:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si1481400wik.54.2015.03.05.08.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 08:53:47 -0800 (PST)
Message-ID: <54F88A13.4010003@suse.cz>
Date: Thu, 05 Mar 2015 17:53:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 00/16] Introduce ZONE_CMA
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>

On 02/12/2015 08:32 AM, Joonsoo Kim wrote:
> 
> 1) Break non-overlapped zone assumption
> CMA regions could be spread to all memory range, so, to keep all of them
> into one zone, span of ZONE_CMA would be overlap to other zones'.

>From patch 13/16 ut seems to me that indeed the ZONE_CMA spans the area of all
other zones. This seems very inefficient for e.g. compaction scanners, which
will repeatedly skip huge amounts of pageblocks that don't belong to ZONE_CMA.
Could you instead pick only a single zone on a node from which you steal the
pages? That would allow to keep the span low.

Another disadvantage I see is that to allocate from ZONE_CMA you will have now
to reclaim enough pages within the zone itself. I think think the cma allocation
supports migrating pages from ZONE_CMA to the adjacent non-CMA zone, which would
be equivalent to migration from MIGRATE_CMA pageblocks to the rest of the zone?

> I'm not sure that there is an assumption about possibility of zone overlap
> But, if ZONE_CMA is introduced, this assumption becomes reality
> so we should deal with this situation. I investigated most of sites
> that iterates pfn on certain zone and found that they normally doesn't
> consider zone overlap. I tried to handle these cases by myself in the
> early of this series. I hope that there is no more site that depends on
> non-overlap zone assumption when iterating pfn on certain zone.
> 
> I passed boot test on x86, ARM32 and ARM64. I did some stress tests
> on x86 and there is no problem. Feel free to enjoy and please give me
> a feedback. :)
> 
> This patchset is based on v3.18.
> 
> Thanks.
> 
> [1] https://lkml.org/lkml/2014/5/28/64
> [2] https://lkml.org/lkml/2014/11/4/55 
> [3] https://lkml.org/lkml/2014/10/15/623
> [4] https://lkml.org/lkml/2014/5/30/320
> 
> 
> Joonsoo Kim (16):
>   mm/page_alloc: correct highmem memory statistics
>   mm/writeback: correct dirty page calculation for highmem
>   mm/highmem: make nr_free_highpages() handles all highmem zones by
>     itself
>   mm/vmstat: make node_page_state() handles all zones by itself
>   mm/vmstat: watch out zone range overlap
>   mm/page_alloc: watch out zone range overlap
>   mm/page_isolation: watch out zone range overlap
>   power: watch out zone range overlap
>   mm/cma: introduce cma_total_pages() for future use
>   mm/highmem: remove is_highmem_idx()
>   mm/page_alloc: clean-up free_area_init_core()
>   mm/cma: introduce new zone, ZONE_CMA
>   mm/cma: populate ZONE_CMA and use this zone when GFP_HIGHUSERMOVABLE
>   mm/cma: print stealed page count
>   mm/cma: remove ALLOC_CMA
>   mm/cma: remove MIGRATE_CMA
> 
>  arch/x86/include/asm/sparsemem.h  |    2 +-
>  arch/x86/mm/highmem_32.c          |    3 +
>  include/linux/cma.h               |    9 ++
>  include/linux/gfp.h               |   31 +++---
>  include/linux/mempolicy.h         |    2 +-
>  include/linux/mm.h                |    1 +
>  include/linux/mmzone.h            |   58 +++++-----
>  include/linux/page-flags-layout.h |    2 +
>  include/linux/vm_event_item.h     |    8 +-
>  include/linux/vmstat.h            |   26 +----
>  kernel/power/snapshot.c           |   15 +++
>  lib/show_mem.c                    |    2 +-
>  mm/cma.c                          |   70 ++++++++++--
>  mm/compaction.c                   |    6 +-
>  mm/highmem.c                      |   12 +-
>  mm/hugetlb.c                      |    2 +-
>  mm/internal.h                     |    3 +-
>  mm/memory_hotplug.c               |    3 +
>  mm/mempolicy.c                    |    3 +-
>  mm/page-writeback.c               |    8 +-
>  mm/page_alloc.c                   |  223 +++++++++++++++++++++----------------
>  mm/page_isolation.c               |   14 ++-
>  mm/vmscan.c                       |    2 +-
>  mm/vmstat.c                       |   16 ++-
>  24 files changed, 317 insertions(+), 204 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
