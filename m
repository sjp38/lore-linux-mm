Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1F04C6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 17:47:47 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p0EMliIq000885
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 14:47:44 -0800
Received: from gwj20 (gwj20.prod.google.com [10.200.10.20])
	by hpaq14.eem.corp.google.com with ESMTP id p0EMlJTH016696
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 14:47:43 -0800
Received: by gwj20 with SMTP id 20so1355349gwj.36
        for <linux-mm@kvack.org>; Fri, 14 Jan 2011 14:47:38 -0800 (PST)
Date: Fri, 14 Jan 2011 14:47:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swap : check the return value of swap_readpage()
In-Reply-To: <1294997421-8971-1-git-send-email-b32955@freescale.com>
Message-ID: <alpine.LSU.2.00.1101141445070.5406@sister.anvils>
References: <1294997421-8971-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, b20596@freescale.com
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2011, Huang Shijie wrote:
> The read_swap_cache_async() does not check the return value
> of swap_readpage().
> 

Thanks, we may want to fix that.


> If swap_readpage() returns -ENOMEM, the read_swap_cache_async()
> still returns the `new_page` which has nothing. The caller will
> do some wrong operations on the `new_page` such as copy.
> 

But what's really wrong is not to be checking PageUptodate.
Looks like swapoff's try_to_unuse() never checked it (I'm largely
guilty of that), and my ksm_does_need_to_copy() would blindly copy
(from a !PageUptodate to a PageUptodate), averting the PageUptodate
check which comes later in do_swap_page().


> The patch fixs the problem.
> 

It may fix a part of the problem, but - forgive me for saying! -
your patch is not so beautiful that I want to push it as is.

I'm more worried by the cases when the read gets an error and fails:
we ought to be looking at what filemap.c does in it !PageUptodate case,
and following a similar strategy (perhaps we shall want to distinguish
the ENOMEM case, perhaps not: depends on the implementation).

Is this ENOMEM case something you noticed by looking at the source,
or something that has hit you in practice?  If the latter, then it's
more urgent to fix it: but I'd be wondering how it comes about that
bio's mempools have let you down, and even their GFP_KERNEL allocation
is failing?


> Also remove the unlock_ page() in swap_readpage() in the wrong case
> , since __delete_from_swap_cache() needs a locked page.

That change is only required because we're not checking PageUptodate
properly everywhere.

Hugh

> 
> Signed-off-by: Huang Shijie <b32955@freescale.com>
> ---
>  mm/page_io.c    |    1 -
>  mm/swap_state.c |   12 +++++++-----
>  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 2dee975..5c759f2 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -124,7 +124,6 @@ int swap_readpage(struct page *page)
>  	VM_BUG_ON(PageUptodate(page));
>  	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
>  	if (bio == NULL) {
> -		unlock_page(page);
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 5c8cfab..3bd7238 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -331,16 +331,18 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		__set_page_locked(new_page);
>  		SetPageSwapBacked(new_page);
>  		err = __add_to_swap_cache(new_page, entry);
> +		radix_tree_preload_end();
>  		if (likely(!err)) {
> -			radix_tree_preload_end();
>  			/*
>  			 * Initiate read into locked page and return.
>  			 */
> -			lru_cache_add_anon(new_page);
> -			swap_readpage(new_page);
> -			return new_page;
> +			err = swap_readpage(new_page);
> +			if (likely(!err)) {
> +				lru_cache_add_anon(new_page);
> +				return new_page;
> +			}
> +			__delete_from_swap_cache(new_page);
>  		}
> -		radix_tree_preload_end();
>  		ClearPageSwapBacked(new_page);
>  		__clear_page_locked(new_page);
>  		/*
> -- 
> 1.7.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
