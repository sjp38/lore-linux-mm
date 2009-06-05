Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B1EF36B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:22:04 -0400 (EDT)
Date: Fri, 5 Jun 2009 19:05:54 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH][mmtom] remove file arguement of swap_readpage
In-Reply-To: <1244212423-18629-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <Pine.LNX.4.64.0906051904060.14826@sister.anvils>
References: <1244212423-18629-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009, Minchan Kim wrote:

> The file argument resulted from address_space's readpage
> long time ago.
> 
> Now we don't use it any more. Let's remove unnecessary
> argement.
> 
> This patch cleans up swap_readpage.
> It doesn't affect behavior of function.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Rik van Riel <riel@redhat.com>

Okay, yes: but don't be surprised if someone sends in a patch
to put it back, as in the other readpage()s.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
>  include/linux/swap.h |    2 +-
>  mm/page_io.c         |    2 +-
>  mm/swap_state.c      |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2dedc2d..c88b366 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -256,7 +256,7 @@ extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
>  
>  #ifdef CONFIG_SWAP
>  /* linux/mm/page_io.c */
> -extern int swap_readpage(struct file *, struct page *);
> +extern int swap_readpage(struct page *);
>  extern int swap_writepage(struct page *page, struct writeback_control *wbc);
>  extern void end_swap_bio_read(struct bio *bio, int err);
>  
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 3023c47..c6f3e50 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -120,7 +120,7 @@ out:
>  	return ret;
>  }
>  
> -int swap_readpage(struct file *file, struct page *page)
> +int swap_readpage(struct page *page)
>  {
>  	struct bio *bio;
>  	int ret = 0;
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index b62e7f5..42cd38e 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -313,7 +313,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  			 * Initiate read into locked page and return.
>  			 */
>  			lru_cache_add_anon(new_page);
> -			swap_readpage(NULL, new_page);
> +			swap_readpage(new_page);
>  			return new_page;
>  		}
>  		ClearPageSwapBacked(new_page);
> -- 
> 1.5.6.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
