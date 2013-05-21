Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 3BA996B0036
	for <linux-mm@kvack.org>; Tue, 21 May 2013 15:59:05 -0400 (EDT)
Message-ID: <519BD206.3040603@sr71.net>
Date: Tue, 21 May 2013 12:59:02 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 12/39] thp, mm: rewrite add_to_page_cache_locked() to
 support huge pages
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-13-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
> page for the specified index and HPAGE_CACHE_NR-1 tail pages for
> following indexes.

The really nice way to do these patches is refactor them, first, with no
behavior change, in one patch, the introduce the new support in the
second one.

> diff --git a/mm/filemap.c b/mm/filemap.c
> index 61158ac..b0c7c8c 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -460,39 +460,62 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
>  		pgoff_t offset, gfp_t gfp_mask)
>  {
>  	int error;
> +	int i, nr;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(PageSwapBacked(page));
>  
> +	/* memory cgroup controller handles thp pages on its side */
>  	error = mem_cgroup_cache_charge(page, current->mm,
>  					gfp_mask & GFP_RECLAIM_MASK);
>  	if (error)
> -		goto out;
> -
> -	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> -	if (error == 0) {
> -		page_cache_get(page);
> -		page->mapping = mapping;
> -		page->index = offset;
> +		return error;
>  
> -		spin_lock_irq(&mapping->tree_lock);
> -		error = radix_tree_insert(&mapping->page_tree, offset, page);
> -		if (likely(!error)) {
> -			mapping->nrpages++;
> -			__inc_zone_page_state(page, NR_FILE_PAGES);
> -			spin_unlock_irq(&mapping->tree_lock);
> -			trace_mm_filemap_add_to_page_cache(page);
> -		} else {
> -			page->mapping = NULL;
> -			/* Leave page->index set: truncation relies upon it */
> -			spin_unlock_irq(&mapping->tree_lock);
> -			mem_cgroup_uncharge_cache_page(page);
> -			page_cache_release(page);
> -		}
> -		radix_tree_preload_end();
> -	} else
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
> +		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
> +		nr = hpage_nr_pages(page);
> +	} else {
> +		BUG_ON(PageTransHuge(page));
> +		nr = 1;
> +	}

Why can't this just be

		nr = hpage_nr_pages(page);

Are you trying to optimize for the THP=y, but THP-pagecache=n case?

> +	error = radix_tree_preload_count(nr, gfp_mask & ~__GFP_HIGHMEM);
> +	if (error) {
>  		mem_cgroup_uncharge_cache_page(page);
> -out:
> +		return error;
> +	}
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	for (i = 0; i < nr; i++) {
> +		page_cache_get(page + i);
> +		page[i].index = offset + i;
> +		page[i].mapping = mapping;
> +		error = radix_tree_insert(&mapping->page_tree,
> +				offset + i, page + i);
> +		if (error)
> +			goto err;

I know it's not a super-common thing in the kernel, but could you call
this "insert_err" or something?

> +	}
> +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
> +	if (PageTransHuge(page))
> +		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
> +	mapping->nrpages += nr;
> +	spin_unlock_irq(&mapping->tree_lock);
> +	radix_tree_preload_end();
> +	trace_mm_filemap_add_to_page_cache(page);
> +	return 0;
> +err:
> +	if (i != 0)
> +		error = -ENOSPC; /* no space for a huge page */
> +	page_cache_release(page + i);
> +	page[i].mapping = NULL;

I guess it's a slight behaviour change (I think it's harmless) but if
you delay doing the page_cache_get() and page[i].mapping= until after
the radix tree insertion, you can avoid these two lines.

> +	for (i--; i >= 0; i--) {

I kinda glossed over that initial "i--".  It might be worth a quick
comment to call it out.

> +		/* Leave page->index set: truncation relies upon it */
> +		page[i].mapping = NULL;
> +		radix_tree_delete(&mapping->page_tree, offset + i);
> +		page_cache_release(page + i);
> +	}
> +	spin_unlock_irq(&mapping->tree_lock);
> +	radix_tree_preload_end();
> +	mem_cgroup_uncharge_cache_page(page);
>  	return error;
>  }

FWIW, I think you can move the radix_tree_preload_end() up a bit.  I
guess it won't make any practical difference since you're holding a
spinlock, but it at least makes the point that you're not depending on
it any more.

I'm also trying to figure out how and when you'd actually have to unroll
a partial-huge-page worth of radix_tree_insert().  In the small-page
case, you can collide with another guy inserting in to the page cache.
But, can that happen in the _middle_ of a THP?

Despite my nits, the code still looks correct here, so:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
