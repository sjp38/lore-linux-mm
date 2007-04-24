Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3O2Cm6j014939
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 22:12:48 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3O2Cc04162836
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 20:12:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3O2Cbda027681
	for <linux-mm@kvack.org>; Mon, 23 Apr 2007 20:12:38 -0600
Subject: Re: [RFC 01/16] Free up page->private for compound pages
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070423064850.5458.64307.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
	 <20070423064850.5458.64307.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 23 Apr 2007 19:12:20 -0700
Message-Id: <1177380741.17122.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-04-22 at 23:48 -0700, Christoph Lameter wrote:
> If we add a new flag so that we can distinguish between the
> first page and the tail pages then we can avoid to use page->private
> in the first page. page->private == page for the first page, so there
> is no real information in there.

But, there _is_ real information there.  Without it, you need something
different to tell the head page from a tail page.

You're adding that something different, but you make it sound like that
information was completely superfluous before.  Thus, this patch really
does have a cost: the dedication of one more match flag.

OK, so the end result is that we're freeing up page->private for the
head page of compound pages, but not _all_ of them, right?  You might
want to make that a bit clearer in the patch description.

Can we be more clever about this, and not have to eat yet another page
flag?

static inline int page_is_tail(struct page *page)
{
	struct page *possible_head_page;
	if (!PageCompound(page))
		return 0;
	possible_head_page = (struct page *)page->private;
	/* need to make sure this comes out unsigned: */
	if ((page - possible_head_page) < MAX_ORDER_NR_PAGES)
		return 1;
	return 0;
}

The only thing we'd have to restrict was that pages couldn't be allowed
to have their ->private point to other things in the same max_order.
This could even be enforced in set_page_private().

>  static inline void get_page(struct page *page)
>  {
> -	if (unlikely(PageCompound(page)))
> -		page = (struct page *)page_private(page);
> +	page = compound_head(page);
>  	VM_BUG_ON(atomic_read(&page->_count) == 0);
>  	atomic_inc(&page->_count);
>  }
> @@ -314,6 +317,23 @@ static inline compound_page_dtor *get_co
>  	return (compound_page_dtor *)page[1].lru.next;
>  }
>  
> +static inline int compound_order(struct page *page)
> +{
> +	if (!PageCompound(page) || PageTail(page))
> +		return 0;
> +	return (unsigned long)page[1].lru.prev;
> +}
> +
> +static inline void set_compound_order(struct page *page, unsigned long order)
> +{
> +	page[1].lru.prev = (void *)order;
> +}
> +
> +static inline int base_pages(struct page *page)
> +{
> + 	return 1 << compound_order(page);
> +}

Perhaps base_pages_in_compound(), instead?  

>  /*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
> Index: linux-2.6.21-rc7/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.21-rc7.orig/include/linux/page-flags.h	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/include/linux/page-flags.h	2007-04-21 20:52:15.000000000 -0700
> @@ -91,6 +91,8 @@
>  #define PG_nosave_free		18	/* Used for system suspend/resume */
>  #define PG_buddy		19	/* Page is free, on buddy lists */
>  
> +#define PG_tail			20	/* Page is tail of a compound page */
> +
>  /* PG_owner_priv_1 users should have descriptive aliases */
>  #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
>  
> @@ -241,6 +243,10 @@ static inline void SetPageUptodate(struc
>  #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
>  #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
>  
> +#define PageTail(page)	test_bit(PG_tail, &(page)->flags)
> +#define __SetPageTail(page)	__set_bit(PG_tail, &(page)->flags)
> +#define __ClearPageTail(page)	__clear_bit(PG_tail, &(page)->flags)
>
>  #ifdef CONFIG_SWAP
>  #define PageSwapCache(page)	test_bit(PG_swapcache, &(page)->flags)
>  #define SetPageSwapCache(page)	set_bit(PG_swapcache, &(page)->flags)
> Index: linux-2.6.21-rc7/mm/internal.h
> ===================================================================
> --- linux-2.6.21-rc7.orig/mm/internal.h	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/mm/internal.h	2007-04-21 20:52:15.000000000 -0700
> @@ -24,7 +24,7 @@ static inline void set_page_count(struct
>   */
>  static inline void set_page_refcounted(struct page *page)
>  {
> -	VM_BUG_ON(PageCompound(page) && page_private(page) != (unsigned long)page);
> +	VM_BUG_ON(PageTail(page));
>  	VM_BUG_ON(atomic_read(&page->_count));
>  	set_page_count(page, 1);
>  }
> Index: linux-2.6.21-rc7/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/mm/page_alloc.c	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/mm/page_alloc.c	2007-04-21 20:58:32.000000000 -0700
> @@ -227,7 +227,7 @@ static void bad_page(struct page *page)
>  
>  static void free_compound_page(struct page *page)
>  {
> -	__free_pages_ok(page, (unsigned long)page[1].lru.prev);
> +	__free_pages_ok(page, compound_order(page));
>  }

These substitutions are great, even outside of this patch set.  Nice.

>  static void prep_compound_page(struct page *page, unsigned long order)
> @@ -236,12 +236,14 @@ static void prep_compound_page(struct pa
>  	int nr_pages = 1 << order;
>  
>  	set_compound_page_dtor(page, free_compound_page);
> -	page[1].lru.prev = (void *)order;
> -	for (i = 0; i < nr_pages; i++) {
> +	set_compound_order(page, order);
> +	__SetPageCompound(page);
> +	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
>  
> +		__SetPageTail(p);
>  		__SetPageCompound(p);
> -		set_page_private(p, (unsigned long)page);
> +		p->private = (unsigned long)page;
>  	}
>  }
>  
> @@ -250,15 +252,19 @@ static void destroy_compound_page(struct
>  	int i;
>  	int nr_pages = 1 << order;
>  
> -	if (unlikely((unsigned long)page[1].lru.prev != order))
> +	if (unlikely(compound_order(page) != order))
>  		bad_page(page);
>  
> -	for (i = 0; i < nr_pages; i++) {
> +	if (unlikely(!PageCompound(page)))
> +			bad_page(page);
> +	__ClearPageCompound(page);
> +	for (i = 1; i < nr_pages; i++) {
>  		struct page *p = page + i;
>  
> -		if (unlikely(!PageCompound(p) |
> -				(page_private(p) != (unsigned long)page)))
> +		if (unlikely(!PageCompound(p) | !PageTail(p) |
> +				((struct page *)p->private != page)))

Should there be a compound_page_head() function to get rid of these
open-coded references?

I guess it doesn't matter, but it might be nice to turn those binary |'s
into logical ||'s.

>  			bad_page(page);
> +		__ClearPageTail(p);
>  		__ClearPageCompound(p);
>  	}
>  }
> @@ -1438,8 +1444,17 @@ void __pagevec_free(struct pagevec *pvec
>  {
>  	int i = pagevec_count(pvec);
>  
> -	while (--i >= 0)
> -		free_hot_cold_page(pvec->pages[i], pvec->cold);
> +	while (--i >= 0) {
> +		struct page *page = pvec->pages[i];
> +
> +		if (PageCompound(page)) {
> +			compound_page_dtor *dtor;
> +
> +			dtor = get_compound_page_dtor(page);
> +			(*dtor)(page);
> +		} else
> +			free_hot_cold_page(page, pvec->cold);
> +	}
>  }
>  
>  fastcall void __free_pages(struct page *page, unsigned int order)
> Index: linux-2.6.21-rc7/mm/slab.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/mm/slab.c	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/mm/slab.c	2007-04-21 20:52:15.000000000 -0700
> @@ -592,8 +592,7 @@ static inline void page_set_cache(struct
>  
>  static inline struct kmem_cache *page_get_cache(struct page *page)
>  {
> -	if (unlikely(PageCompound(page)))
> -		page = (struct page *)page_private(page);
> +	page = compound_head(page);
>  	BUG_ON(!PageSlab(page));
>  	return (struct kmem_cache *)page->lru.next;
>  }
> @@ -605,8 +604,7 @@ static inline void page_set_slab(struct 
>  
>  static inline struct slab *page_get_slab(struct page *page)
>  {
> -	if (unlikely(PageCompound(page)))
> -		page = (struct page *)page_private(page);
> +	page = compound_head(page);
>  	BUG_ON(!PageSlab(page));
>  	return (struct slab *)page->lru.prev;
>  }
> Index: linux-2.6.21-rc7/mm/swap.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/mm/swap.c	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/mm/swap.c	2007-04-21 21:02:59.000000000 -0700
> @@ -55,7 +55,7 @@ static void fastcall __page_cache_releas
>  
>  static void put_compound_page(struct page *page)
>  {
> -	page = (struct page *)page_private(page);
> +	page = compound_head(page);
>  	if (put_page_testzero(page)) {
>  		compound_page_dtor *dtor;
>  
> @@ -263,7 +263,23 @@ void release_pages(struct page **pages, 
>  	for (i = 0; i < nr; i++) {
>  		struct page *page = pages[i];
>  
> -		if (unlikely(PageCompound(page))) {
> +		/*
> +		 * There is a conflict here between handling a compound
> +		 * page as a single big page or a set of smaller pages.
> +		 *
> +		 * Direct I/O wants us to treat them separately. Variable
> +		 * Page Size support means we need to treat then as
> +		 * a single unit.
> +		 *
> +		 * So we compromise here. Tail pages are handled as a
> +		 * single page (for direct I/O) but head pages are
> +		 * handled as full pages (for Variable Page Size
> +		 * Support).
> +		 *
> +		 * FIXME: That breaks direct I/O for the head page.
> +		 */
> +		if (unlikely(PageTail(page))) {
> +			/* Must treat as a single page */
>  			if (zone) {
>  				spin_unlock_irq(&zone->lru_lock);
>  				zone = NULL;
> Index: linux-2.6.21-rc7/arch/ia64/mm/init.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/arch/ia64/mm/init.c	2007-04-21 20:52:07.000000000 -0700
> +++ linux-2.6.21-rc7/arch/ia64/mm/init.c	2007-04-21 20:52:15.000000000 -0700
> @@ -121,7 +121,7 @@ lazy_mmu_prot_update (pte_t pte)
>  		return;				/* i-cache is already coherent with d-cache */
>  
>  	if (PageCompound(page)) {
> -		order = (unsigned long) (page[1].lru.prev);
> +		order = compound_order(page);
>  		flush_icache_range(addr, addr + (1UL << order << PAGE_SHIFT));
>  	}
>  	else
-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
