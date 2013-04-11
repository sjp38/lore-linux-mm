Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 647516B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:18:53 -0400 (EDT)
Date: Thu, 11 Apr 2013 23:18:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 10/18] mm: teach truncate_inode_pages_range() to
 handle non page aligned ranges
Message-ID: <20130411211851.GD9379@quack.suse.cz>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-11-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365498867-27782-11-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On Tue 09-04-13 11:14:19, Lukas Czerner wrote:
> This commit changes truncate_inode_pages_range() so it can handle non
> page aligned regions of the truncate. Currently we can hit BUG_ON when
> the end of the range is not page aligned, but we can handle unaligned
> start of the range.
> 
> Being able to handle non page aligned regions of the page can help file
> system punch_hole implementations and save some work, because once we're
> holding the page we might as well deal with it right away.
> 
> In previous commits we've changed ->invalidatepage() prototype to accept
> 'length' argument to be able to specify range to invalidate. No we can
> use that new ability in truncate_inode_pages_range().
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> ---
>  mm/truncate.c |  104 ++++++++++++++++++++++++++++++++++++++++-----------------
>  1 files changed, 73 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index fdba083..e2e8a8a 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -203,35 +195,58 @@ int invalidate_inode_page(struct page *page)
>   * We pass down the cache-hot hint to the page freeing code.  Even if the
>   * mapping is large, it is probably the case that the final pages are the most
>   * recently touched, and freeing happens in ascending file offset order.
> + *
> + * Note that since ->invalidatepage() accepts range to invalidate
> + * truncate_inode_pages_range is able to handle cases where lend + 1 is not
> + * page aligned properly.
>   */
>  void truncate_inode_pages_range(struct address_space *mapping,
>  				loff_t lstart, loff_t lend)
>  {
> -	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
> -	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
> -	struct pagevec pvec;
> -	pgoff_t index;
> -	pgoff_t end;
> -	int i;
> +	pgoff_t		start;		/* inclusive */
> +	pgoff_t		end;		/* exclusive */
> +	unsigned int	partial_start;	/* inclusive */
> +	unsigned int	partial_end;	/* exclusive */
> +	struct pagevec	pvec;
> +	pgoff_t		index;
> +	int		i;
>  
>  	cleancache_invalidate_inode(mapping);
>  	if (mapping->nrpages == 0)
>  		return;
>  
> -	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
> -	end = (lend >> PAGE_CACHE_SHIFT);
> +	/* Offsets within partial pages */
> +	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
> +	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
> +
> +	/*
> +	 * 'start' and 'end' always covers the range of pages to be fully
> +	 * truncated. Partial pages are covered with 'partial_start' at the
> +	 * start of the range and 'partial_end' at the end of the range.
> +	 * Note that 'end' is exclusive while 'lend' is inclusive.
> +	 */
> +	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> +	if (lend == -1)
> +		/*
> +		 * lend == -1 indicates end-of-file so we have to set 'end'
> +		 * to the highest possible pgoff_t and since the type is
> +		 * unsigned we're using -1.
> +		 */
> +		end = -1;
> +	else
> +		end = (lend + 1) >> PAGE_CACHE_SHIFT;
>  
>  	pagevec_init(&pvec, 0);
>  	index = start;
> -	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +	while (index < end && pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
  So does this really work when end == -1 and file has ULONG_MAX pages?
Previously it did but now you seem of skip the last page... Otherwise the
patch looks good to me.

								Honza

>  		mem_cgroup_uncharge_start();
>  		for (i = 0; i < pagevec_count(&pvec); i++) {
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
>  			index = page->index;
> -			if (index > end)
> +			if (index >= end)
>  				break;
>  
>  			if (!trylock_page(page))
> @@ -250,27 +265,56 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  		index++;
>  	}
>  
> -	if (partial) {
> +	if (partial_start) {
>  		struct page *page = find_lock_page(mapping, start - 1);
>  		if (page) {
> +			unsigned int top = PAGE_CACHE_SIZE;
> +			if (start > end) {
> +				/* Truncation within a single page */
> +				top = partial_end;
> +				partial_end = 0;
> +			}
>  			wait_on_page_writeback(page);
> -			truncate_partial_page(page, partial);
> +			zero_user_segment(page, partial_start, top);
> +			cleancache_invalidate_page(mapping, page);
> +			if (page_has_private(page))
> +				do_invalidatepage(page, partial_start,
> +						  top - partial_start);
>  			unlock_page(page);
>  			page_cache_release(page);
>  		}
>  	}
> +	if (partial_end) {
> +		struct page *page = find_lock_page(mapping, end);
> +		if (page) {
> +			wait_on_page_writeback(page);
> +			zero_user_segment(page, 0, partial_end);
> +			cleancache_invalidate_page(mapping, page);
> +			if (page_has_private(page))
> +				do_invalidatepage(page, 0,
> +						  partial_end);
> +			unlock_page(page);
> +			page_cache_release(page);
> +		}
> +	}
> +	/*
> +	 * If the truncation happened within a single page no pages
> +	 * will be released, just zeroed, so we can bail out now.
> +	 */
> +	if (start >= end)
> +		return;
>  
>  	index = start;
>  	for ( ; ; ) {
>  		cond_resched();
>  		if (!pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
>  			if (index == start)
>  				break;
>  			index = start;
>  			continue;
>  		}
> -		if (index == start && pvec.pages[0]->index > end) {
> +		if (index == start && pvec.pages[0]->index >= end) {
>  			pagevec_release(&pvec);
>  			break;
>  		}
> @@ -280,7 +324,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  
>  			/* We rely upon deletion not changing page->index */
>  			index = page->index;
> -			if (index > end)
> +			if (index >= end)
>  				break;
>  
>  			lock_page(page);
> @@ -601,10 +645,8 @@ void truncate_pagecache_range(struct inode *inode, loff_t lstart, loff_t lend)
>  	 * This rounding is currently just for example: unmap_mapping_range
>  	 * expands its hole outwards, whereas we want it to contract the hole
>  	 * inwards.  However, existing callers of truncate_pagecache_range are
> -	 * doing their own page rounding first; and truncate_inode_pages_range
> -	 * currently BUGs if lend is not pagealigned-1 (it handles partial
> -	 * page at start of hole, but not partial page at end of hole).  Note
> -	 * unmap_mapping_range allows holelen 0 for all, and we allow lend -1.
> +	 * doing their own page rounding first.  Note that unmap_mapping_range
> +	 * allows holelen 0 for all, and we allow lend -1 for end of file.
>  	 */
>  
>  	/*
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
