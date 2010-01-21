Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC2A46B0078
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:36:00 -0500 (EST)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0LHW4o7007676
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:32:04 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0LHZp9i1495266
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:35:51 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0LHZoCR016095
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:35:51 -0500
Subject: Re: [PATCH 03 of 30] alter compound get_page/put_page
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <2c68e94d31d8c675a5e2.1264054827@v2.random>
References: <patchbomb.1264054824@v2.random>
	 <2c68e94d31d8c675a5e2.1264054827@v2.random>
Content-Type: text/plain
Date: Thu, 21 Jan 2010 09:35:46 -0800
Message-Id: <1264095346.32717.34452.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-21 at 07:20 +0100, Andrea Arcangeli wrote:
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
> @@ -43,6 +43,14 @@ static noinline int gup_pte_range(pmd_t 
>  		page = pte_page(pte);
>  		if (!page_cache_get_speculative(page))
>  			return 0;
> +		if (PageTail(page)) {
> +			/*
> +			 * __split_huge_page_refcount() cannot run
> +			 * from under us.
> +			 */
> +			VM_BUG_ON(atomic_read(&page->_count) < 0);
> +			atomic_inc(&page->_count);
> +		}
>  		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
>  			put_page(page);
>  			return 0;
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

Christoph kinda has a point here.  The gup code is going to be a pretty
hot path for some people, and this does add a bunch of atomics that some
people will have no need for.

It's also a decent place to put a helper function anyway.

void pin_huge_page_tail(struct page *page)
{
	/*
	 * This ensures that a __split_huge_page_refcount()
	 * running underneath us cannot 
	 */
	VM_BUG_ON(atomic_read(&page->_count) < 0);
	atomic_inc(&page->_count);
}

It'll keep us from putting the same comment in too many arches, I guess

>  static inline void get_page(struct page *page)
>  {
> -	page = compound_head(page);
> -	VM_BUG_ON(atomic_read(&page->_count) == 0);
> +	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));

Hmm.

	if 

>  	atomic_inc(&page->_count);
> +	if (unlikely(PageTail(page))) {
> +		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
> +		atomic_inc(&page->first_page->_count);
> +		/* __split_huge_page_refcount can't run under get_page */
> +		VM_BUG_ON(!PageTail(page));
> +	}
>  }

Are you hoping to catch a race in progress with the second VM_BUG_ON()
here?  Maybe the comment should say, "detect race with
__split_huge_page_refcount".

>  static inline struct page *virt_to_head_page(const void *x)
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -409,7 +409,8 @@ static inline void __ClearPageTail(struc
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
> +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> +	 1 << PG_compound_lock)

Nit: should probably go in the last patch.

>  /*
>   * Flags checked when a page is prepped for return by the page allocator.
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -55,17 +55,80 @@ static void __page_cache_release(struct 
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
> +			out_put_head:
> +				put_page(page_head);
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
> +			if (put_page_testzero(page_head))
> +				__put_compound_page(page_head);
> +			else
> +				compound_unlock(page_head);
> +			return;
> +		} else
> +			/* page_head is a dangling pointer */
> +			goto out_put_single;
> +	} else if (put_page_testzero(page)) {
> +		if (PageHead(page))
> +			__put_compound_page(page);
> +		else
> +			__put_single_page(page);
>  	}
>  }

That looks functional to me, although the code is pretty darn dense. :)
But, I'm not sure there's a better way to do it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
