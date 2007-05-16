Date: Wed, 16 May 2007 13:34:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Fix page allocation flags in grow_dev_page()
Message-Id: <20070516133416.9d730d08.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705152111380.5192@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705152111380.5192@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, hugh@veritas.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007 21:12:41 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Grow dev page simply passes GFP_NOFS to find_or_create_page. This means the
> allocation of radix tree nodes is done with GFP_NOFS and the allocation
> of a new page is done using GFP_NOFS.
> 
> The mapping has a flags field that contains the necessary allocation flags for
> the page cache allocation. These need to be consulted in order to get DMA
> and HIGHMEM allocations etc right. And yes a blockdev could be allowing
> Highmem allocations if its a ramdisk.
> 
> Cc: Hugh Dickins <hugh@veritas.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/buffer.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: vps/fs/buffer.c
> ===================================================================
> --- vps.orig/fs/buffer.c	2007-05-15 15:47:32.000000000 -0700
> +++ vps/fs/buffer.c	2007-05-15 15:48:36.000000000 -0700
> @@ -981,7 +981,8 @@ grow_dev_page(struct block_device *bdev,
>  	struct page *page;
>  	struct buffer_head *bh;
>  
> -	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
> +	page = find_or_create_page(inode->i_mapping, index,
> +		mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS);
>  	if (!page)
>  		return NULL;
>  

erk.  When I fixed this up against Mel's stuff I ended up with:

        page = find_or_create_page(inode->i_mapping, index,
                (mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS) |
                        __GFP_RECLAIMABLE);

which led to zillions of these:

static inline int allocflags_to_migratetype(gfp_t gfp_flags)
{
	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);

so I assume that mapping_gfp_mask() already had __GFP_MOVABLE set.


So... which is it to be?

<looks at the comments>

#define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
#define __GFP_MOVABLE   ((__force gfp_t)0x100000u)  /* Page is movable */

well these pages are both reclaimable and moveable.  Sigh.

I'll just remove the __GFP_RECLAIMABLE from the above, see what that does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
