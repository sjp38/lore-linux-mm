Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D312C6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 05:33:57 -0400 (EDT)
Date: Mon, 13 Jul 2009 10:56:03 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] switch free memory back to MIGRATE_MOVABLE
Message-ID: <20090713095602.GA996@csn.ul.ie>
References: <20090713023030.GA27269@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090713023030.GA27269@sli10-desk.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 10:30:30AM +0800, Shaohua Li wrote:
> When page is back to buddy and its order is bigger than pageblock_order, we can
> switch its type to MIGRATE_MOVABLE. This can reduce fragmentation. The patch
> has obvious effect when read a block device and then drop caches.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

NAK.

There is no point making this check in the free path, it can be left at
whatever type it is. rmqueue fallback will already find blocks like this and
switch the type again if necessary. The only time you might care is memory
off-lining and at that point, you can check if a free page spans the
pageblock and if so, ignore the existing migrate type.

> ---
>  mm/page_alloc.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c	2009-07-10 11:36:07.000000000 +0800
> +++ linux/mm/page_alloc.c	2009-07-13 09:25:21.000000000 +0800
> @@ -475,6 +475,15 @@ static inline void __free_one_page(struc
>  		order++;
>  	}
>  	set_page_order(page, order);
> +
> +	if (order >= pageblock_order && migratetype != MIGRATE_MOVABLE) {
> +		int i;
> +
> +		migratetype = MIGRATE_MOVABLE;
> +		for (i = 0; i < (1 << (order - pageblock_order)); i++)
> +			set_pageblock_migratetype(page +
> +				i * pageblock_nr_pages, MIGRATE_MOVABLE);
> +	}
>  	list_add(&page->lru,
>  		&zone->free_area[order].free_list[migratetype]);
>  	zone->free_area[order].nr_free++;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
