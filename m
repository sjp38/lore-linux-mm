Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE1238D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 18:03:34 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p37M3Vwt001808
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 15:03:31 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by hpaq11.eem.corp.google.com with ESMTP id p37M3SVf018006
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 15:03:29 -0700
Received: by pxi2 with SMTP id 2so1499497pxi.10
        for <linux-mm@kvack.org>; Thu, 07 Apr 2011 15:03:28 -0700 (PDT)
Date: Thu, 7 Apr 2011 15:03:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] make new alloc_pages_exact()
In-Reply-To: <20110407172105.831B9A0A@kernel>
Message-ID: <alpine.DEB.2.00.1104071452070.14967@chino.kir.corp.google.com>
References: <20110407172104.1F8B7329@kernel> <20110407172105.831B9A0A@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 7 Apr 2011, Dave Hansen wrote:

> 
> What I really wanted in the end was a highmem-capable alloc_pages_exact(),
> so here it is.
> 

Perhaps expand upon how the new alloc_pages_exact() works and what it will 
be used for instead of only talking about how it's named?

> It's a bit unfortunate that we have __free_pages_exact() and
> free_pages_exact(), but that mess already exists with __free_pages()
> vs. free_pages_exact().  So, at worst, this mirrors the mess that we
> already have.
> 
> I'm also a bit worried that I've not put in something named
> alloc_pages_exact(), but that behaves differently than it did before this
> set.  I got all of the in-tree cases, but I'm a bit worried about
> stragglers elsewhere.  So, I'm calling this __alloc_pages_exact() for
> the moment.  We can take out the __ some day if it bothers people.
> 
> Note that the __get_free_pages() has a !GFP_HIGHMEM check.  Now that
> we are using alloc_pages_exact() instead of __get_free_pages() for
> get_free_pages_exact(), we had to add a new check in
> get_free_pages_exact().
> 
> This has been compile and boot tested, and I checked that
> 
> 	echo 2 > /sys/kernel/profiling
> 
> still works, since it uses get_free_pages_exact().
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6.git-dave/drivers/video/pxafb.c |    4 -
>  linux-2.6.git-dave/include/linux/gfp.h   |    4 +
>  linux-2.6.git-dave/kernel/profile.c      |    4 -
>  linux-2.6.git-dave/mm/page_alloc.c       |   81 +++++++++++++++++++++++--------
>  4 files changed, 69 insertions(+), 24 deletions(-)
> 
> diff -puN include/linux/gfp.h~make_new_alloc_pages_exact include/linux/gfp.h
> --- linux-2.6.git/include/linux/gfp.h~make_new_alloc_pages_exact	2011-04-07 08:41:08.158387017 -0700
> +++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-07 08:41:08.174387016 -0700
> @@ -351,6 +351,10 @@ extern struct page *alloc_pages_vma(gfp_
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>  
> +/* 'struct page' version */
> +struct page *__alloc_pages_exact(gfp_t, size_t);
> +void __free_pages_exact(struct page *, size_t);

They're not required, but these should have the names of the arguments 
like the other prototypes in this file.

> +/* virtual address version */
>  void *get_free_pages_exact(gfp_t gfp_mask, size_t size);
>  void free_pages_exact(void *virt, size_t size);
>  
> diff -puN mm/page_alloc.c~make_new_alloc_pages_exact mm/page_alloc.c
> --- linux-2.6.git/mm/page_alloc.c~make_new_alloc_pages_exact	2011-04-07 08:41:08.162387016 -0700
> +++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-07 09:44:33.937537711 -0700
> @@ -2318,36 +2318,83 @@ void free_pages(unsigned long addr, unsi
>  EXPORT_SYMBOL(free_pages);
>  
>  /**
> - * get_free_pages_exact - allocate an exact number physically-contiguous pages.
> + * __alloc_pages_exact - allocate an exact number physically-contiguous pages.
>   * @gfp_mask: GFP flags for the allocation
>   * @size: the number of bytes to allocate
> + * returns: struct page for allocated memory
>   *
> - * This function is similar to __get_free_pages(), except that it allocates the
> - * minimum number of pages to satisfy the request.  get_free_pages() can only
> + * This function is similar to alloc_pages(), except that it allocates the
> + * minimum number of pages to satisfy the request.  alloc_pages() can only
>   * allocate memory in power-of-two pages.
>   *
>   * This function is also limited by MAX_ORDER.
>   *
>   * Memory allocated by this function must be released by free_pages_exact().
>   */
> -void *get_free_pages_exact(gfp_t gfp_mask, size_t size)
> +struct page *__alloc_pages_exact(gfp_t gfp_mask, size_t size)
>  {
>  	unsigned int order = get_order(size);
> -	unsigned long addr;
> +	struct page *page;
>  
> -	addr = __get_free_pages(gfp_mask, order);
> -	if (addr) {
> -		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> -		unsigned long used = addr + PAGE_ALIGN(size);
> +	page = alloc_pages(gfp_mask, order);
> +	if (page) {
> +		struct page *alloc_end = page + (1 << order);
> +		struct page *used = page + PAGE_ALIGN(size)/PAGE_SIZE;

Wouldn't it better to call this "unused" rather than "used" since it 
represents a cursor over pages that we want to free?

>  
> -		split_page(virt_to_page((void *)addr), order);
> +		split_page(page, order);
>  		while (used < alloc_end) {
> -			free_page(used);
> -			used += PAGE_SIZE;
> +			__free_page(used);
> +			used++;
>  		}
>  	}
>  
> -	return (void *)addr;
> +	return page;
> +}
> +EXPORT_SYMBOL(__alloc_pages_exact);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
