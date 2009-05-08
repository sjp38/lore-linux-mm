Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 031476B0047
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:40:00 -0400 (EDT)
Date: Fri, 8 May 2009 13:40:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/8] mm: introduce PageHuge() for testing huge/gigantic
	pages
Message-ID: <20090508114018.GA17129@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111030.264063904@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508111030.264063904@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

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

Hm, this function is _way_ too large to be inlined.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
