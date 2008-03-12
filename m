Date: Wed, 12 Mar 2008 14:08:31 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: grow_dev_page's __GFP_MOVABLE
Message-ID: <20080312140831.GD6072@csn.ul.ie>
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803112116380.18085@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (11/03/08 21:33), Hugh Dickins didst pronounce:
> Hi Mel,
> 
> I'm (slightly) worried by your __GFP_MOVABLE in grow_dev_page:
> is it valid, given that we come here for filesystem metadata pages
> - don't we? 

This is a tricky one and the second time it's come up. The pages allocated
here end up on the page cache and had a similar life-cycle to other LRU-pages
in the majority of cases when I checked at the time. The allocations are
labeled MOVABLE, but in this case they can be cleaned and moved to disk
rather than movable by page migration.  Strictly, one would argue that
they could be marked RECLAIMABLE but it increases the number of pageblocks
used by RECLAIMABLE allocations quite considerably and they have a very
different lifecycle which in itself is bad (spreads difficult to reclaim
allocations wider than necessary). Similarly, leaving them GFP_NOFS would
scatter allocations like page table pages wider than expected.

> If it is valid, then wouldn't adding __GFP_HIGHMEM
> be valid there also?  It'd be very nice to have __GFP_MOVABLE and
> __GFP_HIGHMEM on all blockdev pages, but we've concluded in the
> past that __GFP_HIGHMEM cannot be allowed without large kmapping
> mods throughout the filesystems.  Go back to GFP_NOFS there?
> 

I'd prefer not because the current way keeps most LRU pages together,
even if some of them must be allocated from ZONE_NORMAL instead of
ZONE_HIGHMEM but I'm open to being convinced this was a mistake.

Even if we decide to leave this as-is, I should write a patch commenting
on this.

> Hugh
> 
> --- 2.6.25-rc5/fs/buffer.c	2008-03-05 10:47:40.000000000 +0000
> +++ linux/fs/buffer.c	2008-03-11 21:21:10.000000000 +0000
> @@ -1029,8 +1029,7 @@ grow_dev_page(struct block_device *bdev,
>  	struct page *page;
>  	struct buffer_head *bh;
>  
> -	page = find_or_create_page(inode->i_mapping, index,
> -		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
> +	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
>  	if (!page)
>  		return NULL;
>  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
