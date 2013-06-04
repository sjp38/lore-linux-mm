Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0F1026B0070
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 03:11:17 -0400 (EDT)
Date: Tue, 4 Jun 2013 16:11:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in
 __zone_watermark_ok()
Message-ID: <20130604071116.GG14719@blaptop>
References: <518B5556.4010005@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <518B5556.4010005@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: linux-mm@kvack.org, =?utf-8?B?J+uwleqyveuvvCc=?= <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On Thu, May 09, 2013 at 09:50:46AM +0200, Tomasz Stanislawski wrote:
> The watermark check consists of two sub-checks.
> The first one is:
> 
> 	if (free_pages <= min + lowmem_reserve)
> 		return false;
> 
> The check assures that there is minimal amount of RAM in the zone.  If CMA is
> used then the free_pages is reduced by the number of free pages in CMA prior
> to the over-mentioned check.
> 
> 	if (!(alloc_flags & ALLOC_CMA))
> 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
> 
> This prevents the zone from being drained from pages available for non-movable
> allocations.

The description is rather confusing.
It was not to prevent the zone from being drained but for considering a right
number of allocatable pages from the zone because !ALLOC_CMA pages couldn't be
allocated from CMA migrate type from the zone so if we didn't have such patch,
zone_watermark_ok could return true but allocation couldn't allocate a page.

> 
> The second check prevents the zone from getting too fragmented.
> 
> 	for (o = 0; o < order; o++) {
> 		free_pages -= z->free_area[o].nr_free << o;
> 		min >>= 1;
> 		if (free_pages <= min)
> 			return false;
> 	}
> 
> The field z->free_area[o].nr_free is equal to the number of free pages
> including free CMA pages.  Therefore the CMA pages are subtracted twice.  This

Right.

> may cause a false positive fail of __zone_watermark_ok() if the CMA area gets
> strongly fragmented.  In such a case there are many 0-order free pages located
> in CMA. Those pages are subtracted twice therefore they will quickly drain
> free_pages during the check against fragmentation.  The test fails even though

> there are many free non-cma pages in the zone.

How about this?

  The !ALLOC_CMA higher order allocation fails even though there are many
  free high order pages in the zone.

This patch should go to stable so I'd like to include description with detail
numbers of zone's stat to describe the situation when the higher allocation
is failed so stable maintainers and other distro maintainers could parse the
problem easily.

> 
> This patch fixes this issue by subtracting CMA pages only for a purpose of
> (free_pages <= min + lowmem_reserve) check.


> 
> Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Otherwise, looks good to me.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
