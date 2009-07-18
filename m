Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E74DF6B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 20:41:29 -0400 (EDT)
Date: Fri, 17 Jul 2009 17:41:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add gfp mask checking for __get_free_pages()
Message-Id: <20090717174128.36d00972.akpm@linux-foundation.org>
In-Reply-To: <20090704020949.GA3047@localhost.localdomain>
References: <20090704020949.GA3047@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Jul 2009 11:09:50 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> __get_free_pages() with __GFP_HIGHMEM is not safe because the return
> address cannot represent a highmem page. get_zeroed_page() already has
> such a debug checking.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> ---
>  mm/page_alloc.c |   24 +++++++++---------------
>  1 files changed, 9 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e0f2cdf..4a1a374 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1903,31 +1903,25 @@ EXPORT_SYMBOL(__alloc_pages_nodemask);
>   */
>  unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
>  {
> -	struct page * page;
> +	struct page *page;
> +
> +	/*
> +	 * __get_free_pages() returns a 32-bit address, which cannot represent
> +	 * a highmem page
> +	 */
> +	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> +
>  	page = alloc_pages(gfp_mask, order);
>  	if (!page)
>  		return 0;
>  	return (unsigned long) page_address(page);
>  }
> -
>  EXPORT_SYMBOL(__get_free_pages);
>  
>  unsigned long get_zeroed_page(gfp_t gfp_mask)
>  {
> -	struct page * page;
> -
> -	/*
> -	 * get_zeroed_page() returns a 32-bit address, which cannot represent
> -	 * a highmem page
> -	 */
> -	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> -
> -	page = alloc_pages(gfp_mask | __GFP_ZERO, 0);
> -	if (page)
> -		return (unsigned long) page_address(page);
> -	return 0;
> +	return __get_free_pages(gfp_mask | __GFP_ZERO, 0);
>  }
> -
>  EXPORT_SYMBOL(get_zeroed_page);
>  
>  void __pagevec_free(struct pagevec *pvec)

Fair enough.

I suspect we could just delete that VM_BUG_ON() - we can't go and do
runtime checking for every darn programmer error, and this would be a
pretty dumb one.


Your patch turns get_zeroed_page() into a simple one-liner wrapper
around __get_free_pages().  We could perhaps save some .text, some
kernel stack and some CPU cycles by inlining get_zeroed_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
