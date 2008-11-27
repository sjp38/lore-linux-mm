Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081127101837.GJ28285@wotan.suse.de>
References: <20081127093401.GE28285@wotan.suse.de>
	 <84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
	 <20081127101837.GJ28285@wotan.suse.de>
Date: Thu, 27 Nov 2008 12:28:57 +0200
Message-Id: <1227781737.25160.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-11-27 at 11:18 +0100, Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 11:52:40AM +0200, Pekka Enberg wrote:
> > > -               err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
> > > +               err = add_to_page_cache_lru(page, mapping, index,
> > > +                       (gfp_mask & (__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_HIGH)));
> > 
> > Can we use GFP_RECLAIM_MASK here? I mean, surely we need to pass
> > __GFP_NOFAIL, for example, down to radix_tree_preload() et al?
> 
> Updated patch.
> 
> --
> Frustratingly, gfp_t is really divided into two classes of flags. One are the
> context dependent ones (can we sleep? can we enter filesystem? block subsystem?
> should we use some extra reserves, etc.). The other ones are the type of memory
> required and depend on how the algorithm is implemented rather than the point
> at which the memory is allocated (highmem? dma memory? etc).
> 
> Some of functions which allocate a page and add it to page cache take a gfp_t,
> but sometimes those functions or their callers aren't really doing the right
> thing: when allocating pagecache page, the memory type should be
> mapping_gfp_mask(mapping). When allocating radix tree nodes, the memory type
> should be kernel mapped (not highmem) memory. The gfp_t argument should only
> really be needed for context dependent options.
> 
> This patch doesn't really solve that tangle in a nice way, but it does attempt
> to fix a couple of bugs. find_or_create_page changes its radix-tree allocation
> to only include the main context dependent flags in order so the pagecache
> page may be allocated from arbitrary types of memory without affecting the
> radix-tree. Then grab_cache_page_nowait() is changed to allocate radix-tree
> nodes with GFP_NOFS, because it is not supposed to reenter the filesystem.
> 
> Filesystems should be careful about exactly what semantics they want and what
> they get when fiddling with gfp_t masks to allocate pagecache. One should be
> as liberal as possible with the type of memory that can be used, and same
> for the the context specific flags.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Looks good to me.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c
> +++ linux-2.6/mm/filemap.c
> @@ -741,7 +741,14 @@ repeat:
>  		page = __page_cache_alloc(gfp_mask);
>  		if (!page)
>  			return NULL;
> -		err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
> +		/*
> +		 * We want a regular kernel memory (not highmem or DMA etc)
> +		 * allocation for the radix tree nodes, but we need to honour
> +		 * the context-specific requirements the caller has asked for.
> +		 * GFP_RECLAIM_MASK collects those requirements.
> +		 */
> +		err = add_to_page_cache_lru(page, mapping, index,
> +			(gfp_mask & GFP_RECLAIM_MASK));
>  		if (unlikely(err)) {
>  			page_cache_release(page);
>  			page = NULL;
> @@ -950,7 +957,7 @@ grab_cache_page_nowait(struct address_sp
>  		return NULL;
>  	}
>  	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
> -	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
> +	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
>  		page_cache_release(page);
>  		page = NULL;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
