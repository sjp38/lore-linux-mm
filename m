From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH mm] mm: speculative page references fix add_to_page_cache
Date: Mon, 14 Jul 2008 14:57:42 +1000
References: <Pine.LNX.4.64.0807140031220.30686@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0807140031220.30686@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807141457.43179.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ah, thanks Hugh. I was surprised that nothing had appeared to blow up
from my pulling the lockless pagecache out of my usual series... I had
missed this case though :(

On Monday 14 July 2008 09:38, Hugh Dickins wrote:
> The speculative page references patch actually depends on another patch
> of Nick's which he hasn't supplied this time around: an atomic-avoiding
> __set_page_locked patch: see http://lkml.org/lkml/2007/11/10/5
>
> This showed up when shmem_unuse_inode's add_to_page_cache failed: the
> page was passed in locked and should remain locked, but speculative's
> add_to_page_cache had unlocked it already, so the subsequent unlock_page
> BUGged.  add_to_page_cache indeed should set and clear the page lock, but
> shmem/tmpfs needs an add_to_page_cache_locked entry point to avoid that.
>
> This fix patch below extracts and updates what's needed from Nick's
> original, including his comments, but leaving out the atomic-avoidance.
>
> (Do speculative page references actually need the page locked before
> it's entered into the page cache?  I'm not sure myself, suspect that
> if everywhere else handled PageUptodate and PageError correctly then
> it might not be necessary; but we're pretty sure there are gaps in
> that error handling, so I agree with Nick that we should lock before.
> He may well be able to supply a stronger reason why it's necessary.)

Right, I'm not sure, I'm not sure whether I could point to a real
bug if we add it unlocked, but I figure it is better to try retaining
pre-lockless-pagecache semantics where possible rather than try to
weaken them at the same time as lockless pagecache.

> I apologize for not finding this sooner, my testing coverage weaker
> than I'd thought: only hit this in checking the swap priority patch.
>
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Thanks,
Acked-by: Nick Piggin <npiggin@suse.de>


> ---
> Should follow mmotm's mm-speculative-page-references-hugh-fix3.patch
>
>  include/linux/pagemap.h |   18 +++++++++++++++++-
>  mm/filemap.c            |   19 +++++++++----------
>  mm/shmem.c              |    4 ++--
>  mm/swap_state.c         |    2 +-
>  4 files changed, 29 insertions(+), 14 deletions(-)
>
> --- mmotm.orig/include/linux/pagemap.h	2008-07-12 21:36:26.000000000 +0100
> +++ mmotm/include/linux/pagemap.h	2008-07-12 21:36:40.000000000 +0100
> @@ -227,7 +227,7 @@ static inline struct page *read_mapping_
>  	return read_cache_page(mapping, index, filler, data);
>  }
>
> -int add_to_page_cache(struct page *page, struct address_space *mapping,
> +int add_to_page_cache_locked(struct page *page, struct address_space
> *mapping, pgoff_t index, gfp_t gfp_mask);
>  int add_to_page_cache_lru(struct page *page, struct address_space
> *mapping, pgoff_t index, gfp_t gfp_mask);
> @@ -235,6 +235,22 @@ extern void remove_from_page_cache(struc
>  extern void __remove_from_page_cache(struct page *page);
>
>  /*
> + * Like add_to_page_cache_locked, but used to add newly allocated pages:
> + * the page is new, so we can just run SetPageLocked() against it.
> + */
> +static inline int add_to_page_cache(struct page *page,
> +		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
> +{
> +	int error;
> +
> +	SetPageLocked(page);
> +	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
> +	if (unlikely(error))
> +		ClearPageLocked(page);
> +	return error;
> +}
> +
> +/*
>   * Return byte-offset into filesystem object for page.
>   */
>  static inline loff_t page_offset(struct page *page)
> --- mmotm.orig/mm/filemap.c	2008-07-12 21:36:26.000000000 +0100
> +++ mmotm/mm/filemap.c	2008-07-12 21:36:40.000000000 +0100
> @@ -442,22 +442,23 @@ int filemap_write_and_wait_range(struct
>  }
>
>  /**
> - * add_to_page_cache - add newly allocated pagecache pages
> + * add_to_page_cache_locked - add newly allocated pagecache pages
>   * @page:	page to add
>   * @mapping:	the page's address_space
>   * @offset:	page index
>   * @gfp_mask:	page allocation mode
>   *
> - * This function is used to add newly allocated pagecache pages;
> - * the page is new, so we can just run SetPageLocked() against it.
> - * The other page state flags were set by rmqueue().
> - *
> + * This function is used to add a page to the pagecache. It must be
> locked. * This function does not add the page to the LRU.  The caller must
> do that. */
> -int add_to_page_cache(struct page *page, struct address_space *mapping,
> +int add_to_page_cache_locked(struct page *page, struct address_space
> *mapping, pgoff_t offset, gfp_t gfp_mask)
>  {
> -	int error = mem_cgroup_cache_charge(page, current->mm,
> +	int error;
> +
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	error = mem_cgroup_cache_charge(page, current->mm,
>  					gfp_mask & ~__GFP_HIGHMEM);
>  	if (error)
>  		goto out;
> @@ -465,7 +466,6 @@ int add_to_page_cache(struct page *page,
>  	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>  	if (error == 0) {
>  		page_cache_get(page);
> -		SetPageLocked(page);
>  		page->mapping = mapping;
>  		page->index = offset;
>
> @@ -476,7 +476,6 @@ int add_to_page_cache(struct page *page,
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
>  		} else {
>  			page->mapping = NULL;
> -			ClearPageLocked(page);
>  			mem_cgroup_uncharge_cache_page(page);
>  			page_cache_release(page);
>  		}
> @@ -488,7 +487,7 @@ int add_to_page_cache(struct page *page,
>  out:
>  	return error;
>  }
> -EXPORT_SYMBOL(add_to_page_cache);
> +EXPORT_SYMBOL(add_to_page_cache_locked);
>
>  int add_to_page_cache_lru(struct page *page, struct address_space
> *mapping, pgoff_t offset, gfp_t gfp_mask)
> --- mmotm.orig/mm/shmem.c	2008-07-12 21:25:56.000000000 +0100
> +++ mmotm/mm/shmem.c	2008-07-12 21:36:40.000000000 +0100
> @@ -936,7 +936,7 @@ found:
>  	spin_lock(&info->lock);
>  	ptr = shmem_swp_entry(info, idx, NULL);
>  	if (ptr && ptr->val == entry.val) {
> -		error = add_to_page_cache(page, inode->i_mapping,
> +		error = add_to_page_cache_locked(page, inode->i_mapping,
>  						idx, GFP_NOWAIT);
>  		/* does mem_cgroup_uncharge_cache_page on error */
>  	} else	/* we must compensate for our precharge above */
> @@ -1301,7 +1301,7 @@ repeat:
>  			SetPageUptodate(filepage);
>  			set_page_dirty(filepage);
>  			swap_free(swap);
> -		} else if (!(error = add_to_page_cache(
> +		} else if (!(error = add_to_page_cache_locked(
>  				swappage, mapping, idx, GFP_NOWAIT))) {
>  			info->flags |= SHMEM_PAGEIN;
>  			shmem_swp_set(info, entry, 0);
> --- mmotm.orig/mm/swap_state.c	2008-07-12 21:36:26.000000000 +0100
> +++ mmotm/mm/swap_state.c	2008-07-12 21:36:40.000000000 +0100
> @@ -64,7 +64,7 @@ void show_swap_cache_info(void)
>  }
>
>  /*
> - * add_to_swap_cache resembles add_to_page_cache on swapper_space,
> + * add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
>   * but sets SwapCache flag and private instead of mapping and index.
>   */
>  int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t
> gfp_mask)
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
