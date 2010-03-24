Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE226B01E2
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:26:11 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:26:03 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] shrink_page_list: save page_mapped() to local val
Message-ID: <20100324132603.GB20640@cmpxchg.org>
References: <1269432687-1580-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269432687-1580-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 24, 2010 at 08:11:27PM +0800, Bob Liu wrote:
> In funtion shrink_page_list(), page_mapped() is called several
> times,save it to local val to reduce atomic_read.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/vmscan.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 79c8098..08cc3ac 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -637,6 +637,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		struct address_space *mapping;
>  		struct page *page;
>  		int may_enter_fs;
> +		int page_mapcount;
>  
>  		cond_resched();
>  
> @@ -653,11 +654,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (unlikely(!page_evictable(page, NULL)))
>  			goto cull_mlocked;
>  
> -		if (!sc->may_unmap && page_mapped(page))
> +		page_mapcount = page_mapped(page);
> +		if (!sc->may_unmap && page_mapcount)
>  			goto keep_locked;
>  
>  		/* Double the slab pressure for mapped and swapcache pages */
> -		if (page_mapped(page) || PageSwapCache(page))
> +		if (page_mapcount || PageSwapCache(page))
>  			sc->nr_scanned++;

Note that the mapcount is unstable and might very well drop while this code
runs.

The first two instances are close enough together that a change is unlikely,
but between them and the below check before try_to_unmap() we might be even
waiting for writeback to complete.

try_to_unmap() will figure it out, but it would lock the mapping first and
then read the mapcount.

I am unsure whether the change is worth it.

>  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> @@ -707,7 +709,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.
>  		 */
> -		if (page_mapped(page) && mapping) {
> +		if (page_mapcount && mapping) {
>  			switch (try_to_unmap(page, TTU_UNMAP)) {
>  			case SWAP_FAIL:
>  				goto activate_locked;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
