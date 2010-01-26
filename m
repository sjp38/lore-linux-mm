Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 88BF46003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 13:02:51 -0500 (EST)
Date: Tue, 26 Jan 2010 18:02:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03 of 31] alter compound get_page/put_page
Message-ID: <20100126180234.GH16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <936cd613e4ae2d20c62b.1264513918@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <936cd613e4ae2d20c62b.1264513918@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:51:58PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Alter compound get_page/put_page to keep references on subpages too, in order
> to allow __split_huge_page_refcount to split an hugepage even while subpages
> have been pinned by one of the get_user_pages() variants.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
> --- a/arch/powerpc/mm/gup.c
> +++ b/arch/powerpc/mm/gup.c
> @@ -47,6 +47,14 @@ static noinline int gup_pte_range(pmd_t 
>  			put_page(page);
>  			return 0;
>  		}
> +		if (PageTail(page)) {
> +			/*
> +			 * __split_huge_page_refcount() cannot run
> +			 * from under us.
> +			 */
> +			VM_BUG_ON(atomic_read(&page->_count) < 0);
> +			atomic_inc(&page->_count);
> +		}

Is it worth considering making some of these VM_BUG_ON's BUG_ON's? None
of them will trigger in production setups. While you have tested heavily
on your own machines, there might be some wacky corner case.  I know the
downside is two atomics in there instead of one in there but it might be
worth it for a year anyway.

Also, Dave had suggested making this a helper in a previous revision to
avoid duplicating the comment if nothing else. It wouldn't hurt.

>  		pages[*nr] = page;
>  		(*nr)++;
>  
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -128,6 +128,14 @@ static noinline int gup_huge_pmd(pmd_t p
>  	do {
>  		VM_BUG_ON(compound_head(page) != head);
>  		pages[*nr] = page;
> +		if (PageTail(page)) {
> +			/*
> +			 * __split_huge_page_refcount() cannot run
> +			 * from under us.
> +			 */
> +			VM_BUG_ON(atomic_read(&page->_count) < 0);
> +			atomic_inc(&page->_count);
> +		}
>  		(*nr)++;
>  		page++;
>  		refs++;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -297,12 +297,16 @@ static inline int is_vmalloc_or_module_a
>  
>  static inline void compound_lock(struct page *page)
>  {
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	bit_spin_lock(PG_compound_lock, &page->flags);
> +#endif
>  }
>  
>  static inline void compound_unlock(struct page *page)
>  {
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	bit_spin_unlock(PG_compound_lock, &page->flags);
> +#endif
>  }
>  
>  static inline struct page *compound_head(struct page *page)
> @@ -319,9 +323,17 @@ static inline int page_count(struct page
>  
>  static inline void get_page(struct page *page)
>  {
> -	page = compound_head(page);
> -	VM_BUG_ON(atomic_read(&page->_count) == 0);
> +	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
>  	atomic_inc(&page->_count);
> +	if (unlikely(PageTail(page))) {
> +		/*
> +		 * This is safe only because
> +		 * __split_huge_page_refcount can't run under
> +		 * get_page().
> +		 */
> +		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
> +		atomic_inc(&page->first_page->_count);
> +	}
>  }
>  
>  static inline struct page *virt_to_head_page(const void *x)
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -108,7 +108,9 @@ enum pageflags {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	PG_compound_lock,
> +#endif
>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
> @@ -400,6 +402,12 @@ static inline void __ClearPageTail(struc
>  #define __PG_MLOCKED		0
>  #endif
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
> +#else
> +#define __PG_COMPOUND_LOCK		0
> +#endif
> +
>  /*
>   * Flags checked when a page is freed.  Pages being freed should not have
>   * these flags set.  It they are, there is a problem.
> @@ -409,7 +417,8 @@ static inline void __ClearPageTail(struc
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
> +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> +	 1 << __PG_COMPOUND_LOCK)


#define __PG_COMPOUND_LOCK           (1 << PG_compound_lock)

and 1 << __PG_COMPOUND_LOCK

so __PG_COMPOUND_LOCK is already shifted. Is that intentional? Unless I am
missing something obvious, it looks like it should be

 +      1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
 +      __PG_COMPOUND_LOCK)

If it is not intentional, it should be harmless at runtime because the impact
is not checking a flag is properly clear.

>  
>  /*
>   * Flags checked when a page is prepped for return by the page allocator.
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -55,17 +55,82 @@ static void __page_cache_release(struct 
>  		del_page_from_lru(zone, page);
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	}
> +}
> +
> +static void __put_single_page(struct page *page)
> +{
> +	__page_cache_release(page);
>  	free_hot_page(page);
>  }
>  
> +static void __put_compound_page(struct page *page)
> +{
> +	compound_page_dtor *dtor;
> +
> +	__page_cache_release(page);
> +	dtor = get_compound_page_dtor(page);
> +	(*dtor)(page);
> +}
> +
>  static void put_compound_page(struct page *page)
>  {
> -	page = compound_head(page);
> -	if (put_page_testzero(page)) {
> -		compound_page_dtor *dtor;
> -
> -		dtor = get_compound_page_dtor(page);
> -		(*dtor)(page);
> +	if (unlikely(PageTail(page))) {
> +		/* __split_huge_page_refcount can run under us */
> +		struct page *page_head = page->first_page;
> +		smp_rmb();

Can you explain why the barrier is needed and why this is sufficient? It
looks like you are checking for races before compound_lock() is called but
I'm not seeing how the window is fully closed if that is the case.

> +		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
> +			if (unlikely(!PageHead(page_head))) {
> +				/* PageHead is cleared after PageTail */
> +				smp_rmb();
> +				VM_BUG_ON(PageTail(page));
> +				goto out_put_head;
> +			}
> +			/*
> +			 * Only run compound_lock on a valid PageHead,
> +			 * after having it pinned with
> +			 * get_page_unless_zero() above.
> +			 */
> +			smp_mb();
> +			/* page_head wasn't a dangling pointer */
> +			compound_lock(page_head);
> +			if (unlikely(!PageTail(page))) {
> +				/* __split_huge_page_refcount run before us */
> +				compound_unlock(page_head);
> +				VM_BUG_ON(PageHead(page_head));
> +			out_put_head:
> +				if (put_page_testzero(page_head))
> +					__put_single_page(page_head);
> +			out_put_single:
> +				if (put_page_testzero(page))
> +					__put_single_page(page);
> +				return;
> +			}
> +			VM_BUG_ON(page_head != page->first_page);
> +			/*
> +			 * We can release the refcount taken by
> +			 * get_page_unless_zero now that
> +			 * split_huge_page_refcount is blocked on the
> +			 * compound_lock.
> +			 */
> +			if (put_page_testzero(page_head))
> +				VM_BUG_ON(1);
> +			/* __split_huge_page_refcount will wait now */
> +			VM_BUG_ON(atomic_read(&page->_count) <= 0);
> +			atomic_dec(&page->_count);
> +			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
> +			compound_unlock(page_head);
> +			if (put_page_testzero(page_head))
> +				__put_compound_page(page_head);
> +		} else {
> +			/* page_head is a dangling pointer */
> +			VM_BUG_ON(PageTail(page));
> +			goto out_put_single;
> +		}
> +	} else if (put_page_testzero(page)) {
> +		if (PageHead(page))
> +			__put_compound_page(page);
> +		else
> +			__put_single_page(page);
>  	}
>  }
>  
> @@ -74,7 +139,7 @@ void put_page(struct page *page)
>  	if (unlikely(PageCompound(page)))
>  		put_compound_page(page);
>  	else if (put_page_testzero(page))
> -		__page_cache_release(page);
> +		__put_single_page(page);
>  }
>  EXPORT_SYMBOL(put_page);
>  
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
