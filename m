Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0FC9D6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:13:33 -0400 (EDT)
Date: Mon, 14 May 2012 16:13:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
Message-Id: <20120514161330.def0ac52.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
	<alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <ffwll.ch@google.com>, Rob Clark <rob.clark@linaro.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 12 May 2012 04:59:56 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> The GMA500 GPU driver uses GEM shmem objects, but with a new twist:
> the backing RAM has to be below 4GB.  Not a problem while the boards
> supported only 4GB: but now Intel's D2700MUD boards support 8GB, and
> their GMA3600 is managed by the GMA500 driver.
> 
> shmem/tmpfs has never pretended to support hardware restrictions on
> the backing memory, but it might have appeared to do so before v3.1,
> and even now it works fine until a page is swapped out then back in.
> When read_cache_page_gfp() supplied a freshly allocated page for copy,
> that compensated for whatever choice might have been made by earlier
> swapin readahead; but swapoff was likely to destroy the illusion.
> 
> We'd like to continue to support GMA500, so now add a new
> shmem_should_replace_page() check on the zone when about to move
> a page from swapcache to filecache (in swapin and swapoff cases),
> with shmem_replace_page() to allocate and substitute a suitable page
> (given gma500/gem.c's mapping_set_gfp_mask GFP_KERNEL | __GFP_DMA32).
> 
> This does involve a minor extension to mem_cgroup_replace_page_cache()
> (the page may or may not have already been charged); and I've removed
> a comment and call to mem_cgroup_uncharge_cache_page(), which in fact
> is always a no-op while PageSwapCache.
> 
> Also removed optimization of an unlikely path in shmem_getpage_gfp(),
> now that we need to check PageSwapCache more carefully (a racing caller
> might already have made the copy).  And at one point shmem_unuse_inode()
> needs to use the hitherto private page_swapcount(), to guard against
> racing with inode eviction.
> 
> It would make sense to extend shmem_should_replace_page(), to cover
> cpuset and NUMA mempolicy restrictions too, but set that aside for
> now: needs a cleanup of shmem mempolicy handling, and more testing,
> and ought to handle swap faults in do_swap_page() as well as shmem.
> 
> ...
>
>  static int shmem_unuse_inode(struct shmem_inode_info *info,
> -			     swp_entry_t swap, struct page *page)
> +			     swp_entry_t swap, struct page **pagep)
>  {
>  	struct address_space *mapping = info->vfs_inode.i_mapping;
>  	void *radswap;
>  	pgoff_t index;
> -	int error;
> +	gfp_t gfp;
> +	int error = 0;
>  
>  	radswap = swp_to_radix_entry(swap);
>  	index = radix_tree_locate_item(&mapping->page_tree, radswap);
> @@ -625,22 +629,37 @@ static int shmem_unuse_inode(struct shme
>  	if (shmem_swaplist.next != &info->swaplist)
>  		list_move_tail(&shmem_swaplist, &info->swaplist);
>  
> +	gfp = mapping_gfp_mask(mapping);
> +	if (shmem_should_replace_page(*pagep, gfp)) {
> +		mutex_unlock(&shmem_swaplist_mutex);
> +		error = shmem_replace_page(pagep, gfp, info, index);
> +		mutex_lock(&shmem_swaplist_mutex);
> +		/*
> +		 * We needed to drop mutex to make that restrictive page
> +		 * allocation; but the inode might already be freed by now,
> +		 * and we cannot refer to inode or mapping or info to check.
> +		 * However, we do hold page lock on the PageSwapCache page,
> +		 * so can check if that still has our reference remaining.
> +		 */
> +		if (!page_swapcount(*pagep))
> +			error = -ENOENT;

This has my head spinning a bit.  What is "our reference"?  I'd expect
that to mean a temporary reference which was taken by this thread of
control.  But such a thing has no relevance when trying to determine
the state of the page and/or data structures which refer to it.

Also, what are we trying to determine here with this test?  Whether the
page was removed from swapcache under our feet?  Presumably not, as it
is locked.

So perhaps you could spell out in more detail what we're trying to do
here, and what contributes to page_swapcount() here?


> +	}
> +
>  	/*
>  	 * We rely on shmem_swaplist_mutex, not only to protect the swaplist,
>  	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
>  	 * beneath us (pagelock doesn't help until the page is in pagecache).
>  	 */
> -	error = shmem_add_to_page_cache(page, mapping, index,
> +	if (!error)
> +		error = shmem_add_to_page_cache(*pagep, mapping, index,
>  						GFP_NOWAIT, radswap);
> -	/* which does mem_cgroup_uncharge_cache_page on error */
> -
>  	if (error != -ENOMEM) {
>  		/*
>  		 * Truncation and eviction use free_swap_and_cache(), which
>  		 * only does trylock page: if we raced, best clean up here.
>  		 */
> -		delete_from_swap_cache(page);
> -		set_page_dirty(page);
> +		delete_from_swap_cache(*pagep);
> +		set_page_dirty(*pagep);
>  		if (!error) {
>  			spin_lock(&info->lock);
>  			info->swapped--;
> @@ -660,7 +679,14 @@ int shmem_unuse(swp_entry_t swap, struct
>  	struct list_head *this, *next;
>  	struct shmem_inode_info *info;
>  	int found = 0;
> -	int error;
> +	int error = 0;
> +
> +	/*
> +	 * There's a faint possibility that swap page was replaced before
> +	 * caller locked it: it will come back later with the right page.

So a caller locked the page then failed to check that it's still the
right sort of page?  Shouldn't the caller locally clean up its own mess
rather than requiring a callee to know about the caller's intricate
shortcomings?

> +	 */
> +	if (unlikely(!PageSwapCache(page)))
> +		goto out;
>  
>  	/*
>  	 * Charge page using GFP_KERNEL while we can wait, before taking
>
> ...
>
> @@ -856,6 +880,84 @@ static inline struct mempolicy *shmem_ge
>  #endif
>  
>  /*
> + * When a page is moved from swapcache to shmem filecache (either by the
> + * usual swapin of shmem_getpage_gfp(), or by the less common swapoff of
> + * shmem_unuse_inode()), it may have been read in earlier from swap, in
> + * ignorance of the mapping it belongs to.  If that mapping has special
> + * constraints (like the gma500 GEM driver, which requires RAM below 4GB),
> + * we may need to copy to a suitable page before moving to filecache.
> + *
> + * In a future release, this may well be extended to respect cpuset and
> + * NUMA mempolicy, and applied also to anonymous pages in do_swap_page();
> + * but for now it is a simple matter of zone.
> + */
> +static bool shmem_should_replace_page(struct page *page, gfp_t gfp)
> +{
> +	return page_zonenum(page) > gfp_zone(gfp);
> +}
> +
> +static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> +				struct shmem_inode_info *info, pgoff_t index)
> +{
> +	struct page *oldpage, *newpage;
> +	struct address_space *swap_mapping;
> +	pgoff_t swap_index;
> +	int error;
> +
> +	oldpage = *pagep;
> +	swap_index = page_private(oldpage);
> +	swap_mapping = page_mapping(oldpage);
> +
> +	/*
> +	 * We have arrived here because our zones are constrained, so don't
> +	 * limit chance of success by further cpuset and node constraints.
> +	 */
> +	gfp &= ~GFP_CONSTRAINT_MASK;
> +	newpage = shmem_alloc_page(gfp, info, index);
> +	if (!newpage)
> +		return -ENOMEM;
> +	VM_BUG_ON(shmem_should_replace_page(newpage, gfp));
> +
> +	*pagep = newpage;
> +	page_cache_get(newpage);
> +	copy_highpage(newpage, oldpage);

copy_highpage() doesn't do flush_dcache_page() - did we need copy_user_highpage()?

> +	VM_BUG_ON(!PageLocked(oldpage));
> +	__set_page_locked(newpage);
> +	VM_BUG_ON(!PageUptodate(oldpage));
> +	SetPageUptodate(newpage);
> +	VM_BUG_ON(!PageSwapBacked(oldpage));
> +	SetPageSwapBacked(newpage);
> +	VM_BUG_ON(!swap_index);
> +	set_page_private(newpage, swap_index);
> +	VM_BUG_ON(!PageSwapCache(oldpage));
> +	SetPageSwapCache(newpage);
> +
> +	/*
> +	 * Our caller will very soon move newpage out of swapcache, but it's
> +	 * a nice clean interface for us to replace oldpage by newpage there.
> +	 */
> +	spin_lock_irq(&swap_mapping->tree_lock);
> +	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
> +								   newpage);
> +	__inc_zone_page_state(newpage, NR_FILE_PAGES);
> +	__dec_zone_page_state(oldpage, NR_FILE_PAGES);
> +	spin_unlock_irq(&swap_mapping->tree_lock);
> +	BUG_ON(error);
> +
> +	mem_cgroup_replace_page_cache(oldpage, newpage);
> +	lru_cache_add_anon(newpage);
> +
> +	ClearPageSwapCache(oldpage);
> +	set_page_private(oldpage, 0);
> +
> +	unlock_page(oldpage);
> +	page_cache_release(oldpage);
> +	page_cache_release(oldpage);
> +	return 0;
> +}

shmem_replace_page() is a fairly generic and unexceptional sounding
thing.  Methinks shmem_substitute_page() would be a better name.

> +/*
>   * shmem_getpage_gfp - find page in cache, or get from swap, or allocate
>   *
>   * If we allocate a new one we do not mark it dirty. That's up to the
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
