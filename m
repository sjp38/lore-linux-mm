Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF0CD6B011E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 13:05:53 -0400 (EDT)
Date: Wed, 13 May 2009 18:05:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/8] mm: introduce PageHuge() for testing huge/gigantic
	pages
Message-ID: <20090513170552.GB18006@csn.ul.ie>
References: <20090508105320.316173813@intel.com> <20090508111030.264063904@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090508111030.264063904@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry to join the game so late.

On Fri, May 08, 2009 at 06:53:21PM +0800, Wu Fengguang wrote:
> Introduce PageHuge(), which identifies huge/gigantic pages
> by their dedicated compound destructor functions.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/mm.h |   24 ++++++++++++++++++++++++
>  mm/hugetlb.c       |    2 +-
>  mm/page_alloc.c    |   11 ++++++++++-
>  3 files changed, 35 insertions(+), 2 deletions(-)
> 
> --- linux.orig/mm/page_alloc.c
> +++ linux/mm/page_alloc.c
> @@ -299,13 +299,22 @@ void prep_compound_page(struct page *pag
>  }
>  
>  #ifdef CONFIG_HUGETLBFS
> +/*
> + * This (duplicated) destructor function distinguishes gigantic pages from
> + * normal compound pages.
> + */
> +void free_gigantic_page(struct page *page)
> +{
> +	__free_pages_ok(page, compound_order(page));
> +}
> +
>  void prep_compound_gigantic_page(struct page *page, unsigned long order)
>  {
>  	int i;
>  	int nr_pages = 1 << order;
>  	struct page *p = page + 1;
>  
> -	set_compound_page_dtor(page, free_compound_page);
> +	set_compound_page_dtor(page, free_gigantic_page);
>  	set_compound_order(page, order);

This made me raise an eyebrow. gigantic pages can never end up back in the
page allocator.  It should cause bugs all over the place so I looked closer
and this free_gigantic_page() looks unnecessary.

This is what happens for gigantic pages at boot-time

gather_bootmem_prealloc() called at boot-time to gather gigantic pages
  -> Find the boot allocated pages and call prep_compound_huge_page()
    -> For gigantic pages, call prep_compound_gigantic_page(), sets destructor to free_compound_page()
    -> Call prep_new_huge_page(), sets destructor to free_huge_page()

So, free_gigantic_page() should never used as such in reality and you can
just check free_huge_page(). If a gigantic page was really freed that way,
it would be really bad.

Does that make sense?


>  	__SetPageHead(page);
>  	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -550,7 +550,7 @@ struct hstate *size_to_hstate(unsigned l
>  	return NULL;
>  }
>  
> -static void free_huge_page(struct page *page)
> +void free_huge_page(struct page *page)
>  {
>  	/*
>  	 * Can't pass hstate in here because it is called from the
> --- linux.orig/include/linux/mm.h
> +++ linux/include/linux/mm.h
> @@ -355,6 +355,30 @@ static inline void set_compound_order(st
>  	page[1].lru.prev = (void *)order;
>  }
>  
> +#ifdef CONFIG_HUGETLBFS
> +void free_huge_page(struct page *page);
> +void free_gigantic_page(struct page *page);
> +
> +static inline int PageHuge(struct page *page)
> +{
> +	compound_page_dtor *dtor;
> +
> +	if (!PageCompound(page))
> +		return 0;
> +
> +	page = compound_head(page);
> +	dtor = get_compound_page_dtor(page);
> +
> +	return  dtor == free_huge_page ||
> +		dtor == free_gigantic_page;
> +}
> +#else
> +static inline int PageHuge(struct page *page)
> +{
> +	return 0;
> +}
> +#endif

That is fairly hefty function to be inline and it exports free_huge_page
and free_gigantic_page.  The latter of which is dead code and the former
which was previously a static function.

At least make PageHuge a non-inlined function contained in mm/hugetlb.c and
expose it via mm/internal.h if possible or include/linux/hugetlb.h otherwise.

> +
>  /*
>   * Multiple processes may "see" the same page. E.g. for untouched
>   * mappings of /dev/null, all processes see the same page full of
> 
> -- 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
