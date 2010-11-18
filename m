Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E43146B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 07:37:23 -0500 (EST)
Date: Thu, 18 Nov 2010 12:37:05 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06 of 66] alter compound get_page/put_page
Message-ID: <20101118123705.GK8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <a5372413f6faf8c52784.1288798061@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a5372413f6faf8c52784.1288798061@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:27:41PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Alter compound get_page/put_page to keep references on subpages too, in order
> to allow __split_huge_page_refcount to split an hugepage even while subpages
> have been pinned by one of the get_user_pages() variants.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
> diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
> --- a/arch/powerpc/mm/gup.c
> +++ b/arch/powerpc/mm/gup.c
> @@ -16,6 +16,16 @@
>  
>  #ifdef __HAVE_ARCH_PTE_SPECIAL
>  
> +static inline void pin_huge_page_tail(struct page *page)
> +{

Minor nit, but get_huge_page_tail?

Even though "pin" is what it does, pin isn't used elsewhere in naming.

> +	/*
> +	 * __split_huge_page_refcount() cannot run
> +	 * from under us.
> +	 */
> +	VM_BUG_ON(atomic_read(&page->_count) < 0);
> +	atomic_inc(&page->_count);
> +}
> +
>  /*
>   * The performance critical leaf functions are made noinline otherwise gcc
>   * inlines everything into a single function which results in too much
> @@ -47,6 +57,8 @@ static noinline int gup_pte_range(pmd_t 
>  			put_page(page);
>  			return 0;
>  		}
> +		if (PageTail(page))
> +			pin_huge_page_tail(page);
>  		pages[*nr] = page;
>  		(*nr)++;
>  
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -105,6 +105,16 @@ static inline void get_head_page_multipl
>  	atomic_add(nr, &page->_count);
>  }
>  
> +static inline void pin_huge_page_tail(struct page *page)
> +{
> +	/*
> +	 * __split_huge_page_refcount() cannot run
> +	 * from under us.
> +	 */
> +	VM_BUG_ON(atomic_read(&page->_count) < 0);
> +	atomic_inc(&page->_count);
> +}
> +

This is identical to the x86 implementation. Any possibility they can be
shared?

>  static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
>  		unsigned long end, int write, struct page **pages, int *nr)
>  {
> @@ -128,6 +138,8 @@ static noinline int gup_huge_pmd(pmd_t p
>  	do {
>  		VM_BUG_ON(compound_head(page) != head);
>  		pages[*nr] = page;
> +		if (PageTail(page))
> +			pin_huge_page_tail(page);
>  		(*nr)++;
>  		page++;
>  		refs++;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -351,9 +351,17 @@ static inline int page_count(struct page
>  
>  static inline void get_page(struct page *page)
>  {
> -	page = compound_head(page);
> -	VM_BUG_ON(atomic_read(&page->_count) == 0);
> +	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));

Oof, this might need a comment. It's saying that getting a normal page or the
head of a compound page must already have an elevated reference count. If
we are getting a tail page, the reference count is stored in both the head
and the tail so the BUG check does not apply.

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
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -56,17 +56,83 @@ static void __page_cache_release(struct 
>  		del_page_from_lru(zone, page);
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	}
> +}
> +
> +static void __put_single_page(struct page *page)
> +{
> +	__page_cache_release(page);
>  	free_hot_cold_page(page, 0);
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

So what? The fact you check PageTail twice is a hint as to what is
happening and that we are depending on the order of when the head and
tails bits get cleared but it's hard to be certain of that.

> +		struct page *page_head = page->first_page;
> +		smp_rmb();
> +		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
> +			unsigned long flags;
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
> +			compound_lock_irqsave(page_head, &flags);
> +			if (unlikely(!PageTail(page))) {
> +				/* __split_huge_page_refcount run before us */
> +				compound_unlock_irqrestore(page_head, flags);
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
> +			compound_unlock_irqrestore(page_head, flags);
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
> @@ -75,7 +141,7 @@ void put_page(struct page *page)
>  	if (unlikely(PageCompound(page)))
>  		put_compound_page(page);
>  	else if (put_page_testzero(page))
> -		__page_cache_release(page);
> +		__put_single_page(page);
>  }
>  EXPORT_SYMBOL(put_page);
>  

Functionally, I don't see a problem so

Acked-by: Mel Gorman <mel@csn.ul.ie>

but some expansion on the leader and the comment, even if done as a
follow-on patch, would be nice.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
