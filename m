Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D54DE8D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 18:41:34 -0500 (EST)
Received: by pvg4 with SMTP id 4so122761pvg.14
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 15:41:30 -0800 (PST)
Date: Sun, 20 Feb 2011 08:41:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: optimize replace_page_cache_page
Message-ID: <20110219234121.GA2546@barrios-desktop>
References: <1297355626-5152-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1297355626-5152-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>

Resend.

he patch is based on mmotm-2011-02-04 + 
mm-add-replace_page_cache_page-function-add-freepage-hook.patch.

On Fri, Feb 11, 2011 at 01:33:46AM +0900, Minchan Kim wrote:
> This patch optmizes replace_page_cache_page.
> 
> 1) remove radix_tree_preload
> 2) single radix_tree_lookup_slot and replace radix tree slot
> 3) page accounting optimization if both pages are in same zone.
> 
> Cc: Miklos Szeredi <mszeredi@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/filemap.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 51 insertions(+), 10 deletions(-)
> 
> Hi Miklos,
> This patch is totally not tested.
> Could you test this patch?
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a25c898..918ef1e 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -148,6 +148,56 @@ void __remove_from_page_cache(struct page *page)
>  	}
>  }
>  
> +/*
> + * Replace a page from the page cache with a new one.
> + * Both the old and new page must be locked.
> + * The caller must hold the mapping's tree_lock.
> + */
> +void __replace_page_cache_page(struct page *old, struct page *new)
> +{
> +	void **pslot;
> +	struct address_space *mapping = old->mapping;
> +	struct zone *old_zone, *new_zone;
> +
> +	old_zone = page_zone(old);
> +	new_zone = page_zone(new);
> +	/*
> +	 * if we're uptodate, flush out into the cleancache, otherwise
> +	 * invalidate any existing cleancache entries.  We can't leave
> +	 * stale data around in the cleancache once our page is gone
> +	 */
> +	if (PageUptodate(old))
> +		cleancache_put_page(old);
> +	else
> +		cleancache_flush_page(mapping, old);
> +
> +	pslot = radix_tree_lookup_slot(&mapping->page_tree,
> +			page_index(old));
> +	get_page(new);      /* add cache reference */
> +	radix_tree_replace_slot(pslot, new);
> +	old->mapping = NULL;
> +	if (old_zone != new_zone) {
> +		__dec_zone_page_state(old, NR_FILE_PAGES);
> +		__inc_zone_page_state(new, NR_FILE_PAGES);
> +		if (PageSwapBacked(old)) {
> +			__dec_zone_page_state(old, NR_SHMEM);
> +			__inc_zone_page_state(new, NR_SHMEM);
> +		}
> +	}
> +	BUG_ON(page_mapped(old));
> +	/*
> +	 * Some filesystems seem to re-dirty the page even after
> +	 * the VM has canceled the dirty bit (eg ext3 journaling).
> +	 *
> +	 * Fix it up by doing a final dirty accounting check after
> +	 * having removed the page entirely.
> +	 */
> +	if (PageDirty(old) && mapping_cap_account_dirty(mapping)) {
> +		dec_zone_page_state(old, NR_FILE_DIRTY);
> +		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> +	}
> +}
> +
>  void remove_from_page_cache(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
> @@ -433,7 +483,6 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  	if (error)
>  		return error;
>  
> -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (!error) {
>  		struct address_space *mapping = old->mapping;
>  		void (*freepage)(struct page *);
> @@ -441,20 +490,12 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
>  		pgoff_t offset = old->index;
>  		freepage = mapping->a_ops->freepage;
>  
> -		page_cache_get(new);
>  		new->mapping = mapping;
>  		new->index = offset;
>  
>  		spin_lock_irq(&mapping->tree_lock);
> -		__remove_from_page_cache(old);
> -		error = radix_tree_insert(&mapping->page_tree, offset, new);
> -		BUG_ON(error);
> -		mapping->nrpages++;
> -		__inc_zone_page_state(new, NR_FILE_PAGES);
> -		if (PageSwapBacked(new))
> -			__inc_zone_page_state(new, NR_SHMEM);
> +		__replace_page_cache_page(old, new);
>  		spin_unlock_irq(&mapping->tree_lock);
> -		radix_tree_preload_end();
>  		if (freepage)
>  			freepage(old);
>  		page_cache_release(old);
> -- 
> 1.7.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
