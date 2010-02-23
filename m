Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 332506B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:03:38 -0500 (EST)
Received: by fxm22 with SMTP id 22so4133394fxm.6
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 06:03:32 -0800 (PST)
Subject: Re: [patch 2/3] vmscan: drop page_mapping_inuse()
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1266868150-25984-3-git-send-email-hannes@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
	 <1266868150-25984-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Feb 2010 23:03:20 +0900
Message-ID: <1266933800.2723.24.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-02-22 at 20:49 +0100, Johannes Weiner wrote:
> page_mapping_inuse() is a historic predicate function for pages that
> are about to be reclaimed or deactivated.
> 
> According to it, a page is in use when it is mapped into page tables
> OR part of swap cache OR backing an mmapped file.
> 
> This function is used in combination with page_referenced(), which
> checks for young bits in ptes and the page descriptor itself for the
> PG_referenced bit.  Thus, checking for unmapped swap cache pages is
> meaningless as PG_referenced is not set for anonymous pages and
> unmapped pages do not have young ptes.  The test makes no difference.

Nice catch!

> 
> Protecting file pages that are not by themselves mapped but are part
> of a mapped file is also a historic leftover for short-lived things


I have been a question in the part.
You seem to solve my long question. :)
But I want to make sure it by any log.
Could you tell me where I find the discussion mail thread or git log at
that time?

Just out of curiosity. 

> like the exec() code in libc.  However, the VM now does reference
> accounting and activation of pages at unmap time and thus the special
> treatment on reclaim is obsolete.

It does make sense. 

> 
> This patch drops page_mapping_inuse() and switches the two callsites
> to use page_mapped() directly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |   25 ++-----------------------
>  1 files changed, 2 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c2db55b..a8e4cbe 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -262,27 +262,6 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  	return ret;
>  }
>  
> -/* Called without lock on whether page is mapped, so answer is unstable */
> -static inline int page_mapping_inuse(struct page *page)
> -{
> -	struct address_space *mapping;
> -
> -	/* Page is in somebody's page tables. */
> -	if (page_mapped(page))
> -		return 1;
> -
> -	/* Be more reluctant to reclaim swapcache than pagecache */
> -	if (PageSwapCache(page))
> -		return 1;
> -
> -	mapping = page_mapping(page);
> -	if (!mapping)
> -		return 0;
> -
> -	/* File is mmap'd by somebody? */
> -	return mapping_mapped(mapping);
> -}
> -
>  static inline int is_page_cache_freeable(struct page *page)
>  {
>  	/*
> @@ -603,7 +582,7 @@ static enum page_references page_check_references(struct page *page,
>  	if (vm_flags & VM_LOCKED)
>  		return PAGEREF_RECLAIM;
>  
> -	if (page_mapping_inuse(page))
> +	if (page_mapped(page))
>  		return PAGEREF_ACTIVATE;
>  
>  	/* Reclaim if clean, defer dirty pages to writeback */
> @@ -1378,7 +1357,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  		}
>  
>  		/* page_referenced clears PageReferenced */
> -		if (page_mapping_inuse(page) &&
> +		if (page_mapped(page) &&
>  		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
>  			nr_rotated++;
>  			/*

It's good to me.
But page_referenced already have been checked page_mapped. 
How about folding alone page_mapped check into page_referenced's inner?

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
