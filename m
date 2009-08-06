Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6546B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 21:57:41 -0400 (EDT)
Date: Wed, 5 Aug 2009 18:52:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] page-allocator: Remove dead function free_cold_page()
Message-Id: <20090805185247.86766d80.akpm@linux-foundation.org>
In-Reply-To: <20090805102817.GE21950@csn.ul.ie>
References: <20090805102817.GE21950@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Aug 2009 11:28:17 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> The function free_cold_page() has no callers so delete it.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  include/linux/gfp.h |    1 -
>  mm/page_alloc.c     |    5 -----
>  2 files changed, 6 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 7c777a0..c32bfa8 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -326,7 +326,6 @@ void free_pages_exact(void *virt, size_t size);
>  extern void __free_pages(struct page *page, unsigned int order);
>  extern void free_pages(unsigned long addr, unsigned int order);
>  extern void free_hot_page(struct page *page);
> -extern void free_cold_page(struct page *page);
>  
>  #define __free_page(page) __free_pages((page), 0)
>  #define free_page(addr) free_pages((addr),0)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d052abb..36758db 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1065,11 +1065,6 @@ void free_hot_page(struct page *page)
>  	free_hot_cold_page(page, 0);
>  }
>  	
> -void free_cold_page(struct page *page)
> -{
> -	free_hot_cold_page(page, 1);
> -}
> -
>  /*
>   * split_page takes a non-compound higher-order page, and splits it into
>   * n (1<<order) sub-pages: page[0..n]

Well I spose so.  But the function is valid and might need to be
resurrected at any stage.  We could `#if 0' it to save a few bytes of
text, perhaps.

I wonder how many free_page() callers should really be calling
free_cold_page().  c'mon, write a thingy to work it out ;) You can
query a page's hotness by timing how long it takes to read all its
cachelines.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
