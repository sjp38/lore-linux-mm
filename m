Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 223678D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 06:47:07 -0500 (EST)
Date: Fri, 26 Nov 2010 11:46:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 06 of 66] alter compound get_page/put_page
Message-ID: <20101126114648.GN26037@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <a5372413f6faf8c52784.1288798061@v2.random> <20101118123705.GK8135@csn.ul.ie> <20101125164916.GP6118@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101125164916.GP6118@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 25, 2010 at 05:49:16PM +0100, Andrea Arcangeli wrote:
> > > <SNIP>

The updates are fine.

> > > diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> > > --- a/arch/x86/mm/gup.c
> > > +++ b/arch/x86/mm/gup.c
> > > @@ -105,6 +105,16 @@ static inline void get_head_page_multipl
> > >  	atomic_add(nr, &page->_count);
> > >  }
> > >  
> > > +static inline void pin_huge_page_tail(struct page *page)
> > > +{
> > > +	/*
> > > +	 * __split_huge_page_refcount() cannot run
> > > +	 * from under us.
> > > +	 */
> > > +	VM_BUG_ON(atomic_read(&page->_count) < 0);
> > > +	atomic_inc(&page->_count);
> > > +}
> > > +
> > 
> > This is identical to the x86 implementation. Any possibility they can be
> > shared?
> 
> There is no place for me today to put gup_fast "equal" bits so I'd
> need to create it and just doing it for a single inline function
> sounds overkill. I could add a asm-generic/gup_fast.h add move that
> function there and include the asm-generic/gup_fast.h from
> asm*/include/gup_fast.h, is that what we want just for one function?
> With all #ifdefs included I would end up writing more code than the
> function itself. No problem with me in doing it though.
> 

Now that you've explained what is necessary, it's not worth it as part of the
series. It's sizable enough as it is for review. Consider it as a follow-up
patch maybe.

> > >  static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> > >  		unsigned long end, int write, struct page **pages, int *nr)
> > >  {
> > > @@ -128,6 +138,8 @@ static noinline int gup_huge_pmd(pmd_t p
> > >  	do {
> > >  		VM_BUG_ON(compound_head(page) != head);
> > >  		pages[*nr] = page;
> > > +		if (PageTail(page))
> > > +			pin_huge_page_tail(page);
> > >  		(*nr)++;
> > >  		page++;
> > >  		refs++;
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -351,9 +351,17 @@ static inline int page_count(struct page
> > >  
> > >  static inline void get_page(struct page *page)
> > >  {
> > > -	page = compound_head(page);
> > > -	VM_BUG_ON(atomic_read(&page->_count) == 0);
> > > +	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
> > 
> > Oof, this might need a comment. It's saying that getting a normal page or the
> > head of a compound page must already have an elevated reference count. If
> > we are getting a tail page, the reference count is stored in both the head
> > and the tail so the BUG check does not apply.
> 
> Ok.
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -353,8 +353,20 @@ static inline int page_count(struct page
>  
>  static inline void get_page(struct page *page)
>  {
> +	/*
> +	 * Getting a normal page or the head of a compound page
> +	 * requires to already have an elevated page->_count. Only if
> +	 * we're getting a tail page, the elevated page->_count is
> +	 * required only in the head page, so for tail pages the
> +	 * bugcheck only verifies that the page->_count isn't
> +	 * negative.
> +	 */
>  	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
>  	atomic_inc(&page->_count);
> +	/*
> +	 * Getting a tail page will elevate both the head and tail
> +	 * page->_count(s).
> +	 */
>  	if (unlikely(PageTail(page))) {
>  		/*
>  		 * This is safe only because

Much better.

> 
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -56,17 +56,83 @@ static void __page_cache_release(struct 
> > >  		del_page_from_lru(zone, page);
> > >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > >  	}
> > > +}
> > > +
> > > +static void __put_single_page(struct page *page)
> > > +{
> > > +	__page_cache_release(page);
> > >  	free_hot_cold_page(page, 0);
> > >  }
> > >  
> > > +static void __put_compound_page(struct page *page)
> > > +{
> > > +	compound_page_dtor *dtor;
> > > +
> > > +	__page_cache_release(page);
> > > +	dtor = get_compound_page_dtor(page);
> > > +	(*dtor)(page);
> > > +}
> > > +
> > >  static void put_compound_page(struct page *page)
> > >  {
> > > -	page = compound_head(page);
> > > -	if (put_page_testzero(page)) {
> > > -		compound_page_dtor *dtor;
> > > -
> > > -		dtor = get_compound_page_dtor(page);
> > > -		(*dtor)(page);
> > > +	if (unlikely(PageTail(page))) {
> > > +		/* __split_huge_page_refcount can run under us */
> > 
> > So what? The fact you check PageTail twice is a hint as to what is
> > happening and that we are depending on the order of when the head and
> > tails bits get cleared but it's hard to be certain of that.
> 
> This is correct, we depend on the split_huge_page_refcount to clear
> PageTail before overwriting first_page.
> 
> +	 	/*
> +		 * 1) clear PageTail before overwriting first_page
> +		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
> +		 */
> +		smp_wmb();
> 

This helps. Less guesswork involved :)

> The first PageTail check is just to define the fast path and skip
> reading page->first_page and doing smb_rmb() for the much more common
> head pages (we're in unlikely branch).
> 
> So then we read first_page, we smb_rmb() and if pagetail is still set
> after that, we can be sure first_page isn't a dangling pointer.
> 
> > 
> > > +		struct page *page_head = page->first_page;
> > > +		smp_rmb();
> > > +		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
> > > +			unsigned long flags;
> > > +			if (unlikely(!PageHead(page_head))) {
> > > +				/* PageHead is cleared after PageTail */
> > > +				smp_rmb();
> > > +				VM_BUG_ON(PageTail(page));
> > > +				goto out_put_head;
> > > +			}
> > > +			/*
> > > +			 * Only run compound_lock on a valid PageHead,
> > > +			 * after having it pinned with
> > > +			 * get_page_unless_zero() above.
> > > +			 */
> > > +			smp_mb();
> > > +			/* page_head wasn't a dangling pointer */
> > > +			compound_lock_irqsave(page_head, &flags);
> > > +			if (unlikely(!PageTail(page))) {
> > > +				/* __split_huge_page_refcount run before us */
> > > +				compound_unlock_irqrestore(page_head, flags);
> > > +				VM_BUG_ON(PageHead(page_head));
> > > +			out_put_head:
> > > +				if (put_page_testzero(page_head))
> > > +					__put_single_page(page_head);
> > > +			out_put_single:
> > > +				if (put_page_testzero(page))
> > > +					__put_single_page(page);
> > > +				return;
> > > +			}
> > > +			VM_BUG_ON(page_head != page->first_page);
> > > +			/*
> > > +			 * We can release the refcount taken by
> > > +			 * get_page_unless_zero now that
> > > +			 * split_huge_page_refcount is blocked on the
> > > +			 * compound_lock.
> > > +			 */
> > > +			if (put_page_testzero(page_head))
> > > +				VM_BUG_ON(1);
> > > +			/* __split_huge_page_refcount will wait now */
> > > +			VM_BUG_ON(atomic_read(&page->_count) <= 0);
> > > +			atomic_dec(&page->_count);
> > > +			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
> > > +			compound_unlock_irqrestore(page_head, flags);
> > > +			if (put_page_testzero(page_head))
> > > +				__put_compound_page(page_head);
> > > +		} else {
> > > +			/* page_head is a dangling pointer */
> > > +			VM_BUG_ON(PageTail(page));
> > > +			goto out_put_single;
> > > +		}
> > > +	} else if (put_page_testzero(page)) {
> > > +		if (PageHead(page))
> > > +			__put_compound_page(page);
> > > +		else
> > > +			__put_single_page(page);
> > >  	}
> > >  }
> > >  
> > > @@ -75,7 +141,7 @@ void put_page(struct page *page)
> > >  	if (unlikely(PageCompound(page)))
> > >  		put_compound_page(page);
> > >  	else if (put_page_testzero(page))
> > > -		__page_cache_release(page);
> > > +		__put_single_page(page);
> > >  }
> > >  EXPORT_SYMBOL(put_page);
> > >  
> > 
> > Functionally, I don't see a problem so
> > 
> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> > 
> > but some expansion on the leader and the comment, even if done as a
> > follow-on patch, would be nice.
> 
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -79,8 +79,18 @@ static void put_compound_page(struct pag
>  		/* __split_huge_page_refcount can run under us */
>  		struct page *page_head = page->first_page;
>  		smp_rmb();
> +		/*
> +		 * If PageTail is still set after smp_rmb() we can be sure
> +		 * that the page->first_page we read wasn't a dangling pointer.
> +		 * See __split_huge_page_refcount() smp_wmb().
> +		 */
>  		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
>  			unsigned long flags;
> +			/*
> +			 * Verify that our page_head wasn't converted
> +			 * to a a regular page before we got a
> +			 * reference on it.
> +			 */
>  			if (unlikely(!PageHead(page_head))) {
>  				/* PageHead is cleared after PageTail */
>  				smp_rmb();
> 

Thanks

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
