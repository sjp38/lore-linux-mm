Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 8B1CA6B003B
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:00:35 -0400 (EDT)
Date: Tue, 14 May 2013 16:00:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH 2/7] make 'struct page' and swp_entry_t variants of
 swapcache_free().
Message-ID: <20130514150032.GT11497@suse.de>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507211957.603799B2@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130507211957.603799B2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:19:57PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> swapcache_free() takes two arguments:
> 
> 	void swapcache_free(swp_entry_t entry, struct page *page)
> 
> Most of its callers (5/7) are from error handling paths haven't even
> instantiated a page, so they pass page=NULL.  Both of the callers
> that call in with a 'struct page' create and pass in a temporary
> swp_entry_t.
> 
> Now that we are deferring clearing page_private() until after
> swapcache_free() has been called, we can just create a variant
> that takes a 'struct page' and does the temporary variable in
> the helper.
> 
> That leaves all the other callers doing
> 
> 	swapcache_free(entry, NULL)
> 
> so create another helper for them that makes it clear that they
> need only pass in a swp_entry_t.
> 
> One downside here is that delete_from_swap_cache() now does
> an extra swap_address_space() call.  But, those are pretty
> cheap (just some array index arithmetic).
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  linux.git-davehans/drivers/staging/zcache/zcache-main.c |    2 +-
>  linux.git-davehans/include/linux/swap.h                 |    3 ++-
>  linux.git-davehans/mm/shmem.c                           |    2 +-
>  linux.git-davehans/mm/swap_state.c                      |   13 +++++--------
>  linux.git-davehans/mm/swapfile.c                        |   13 ++++++++++++-
>  linux.git-davehans/mm/vmscan.c                          |    3 +--
>  6 files changed, 22 insertions(+), 14 deletions(-)
> 
> diff -puN drivers/staging/zcache/zcache-main.c~make-page-and-swp_entry_t-variants drivers/staging/zcache/zcache-main.c
> --- linux.git/drivers/staging/zcache/zcache-main.c~make-page-and-swp_entry_t-variants	2013-05-07 13:48:13.963056205 -0700
> +++ linux.git-davehans/drivers/staging/zcache/zcache-main.c	2013-05-07 13:48:13.975056737 -0700
> @@ -961,7 +961,7 @@ static int zcache_get_swap_cache_page(in
>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>  		 * clear SWAP_HAS_CACHE flag.
>  		 */
> -		swapcache_free(entry, NULL);
> +		swapcache_free_entry(entry);
>  		/* FIXME: is it possible to get here without err==-ENOMEM?
>  		 * If not, we can dispense with the do loop, use goto retry */
>  	} while (err != -ENOMEM);
> diff -puN include/linux/swap.h~make-page-and-swp_entry_t-variants include/linux/swap.h
> --- linux.git/include/linux/swap.h~make-page-and-swp_entry_t-variants	2013-05-07 13:48:13.964056249 -0700
> +++ linux.git-davehans/include/linux/swap.h	2013-05-07 13:48:13.975056737 -0700
> @@ -382,7 +382,8 @@ extern void swap_shmem_alloc(swp_entry_t
>  extern int swap_duplicate(swp_entry_t);
>  extern int swapcache_prepare(swp_entry_t);
>  extern void swap_free(swp_entry_t);
> -extern void swapcache_free(swp_entry_t, struct page *page);
> +extern void swapcache_free_entry(swp_entry_t entry);
> +extern void swapcache_free_page_entry(struct page *page);
>  extern int free_swap_and_cache(swp_entry_t);
>  extern int swap_type_of(dev_t, sector_t, struct block_device **);
>  extern unsigned int count_swap_pages(int, int);
> diff -puN mm/shmem.c~make-page-and-swp_entry_t-variants mm/shmem.c
> --- linux.git/mm/shmem.c~make-page-and-swp_entry_t-variants	2013-05-07 13:48:13.966056339 -0700
> +++ linux.git-davehans/mm/shmem.c	2013-05-07 13:48:13.976056781 -0700
> @@ -871,7 +871,7 @@ static int shmem_writepage(struct page *
>  	}
>  
>  	mutex_unlock(&shmem_swaplist_mutex);
> -	swapcache_free(swap, NULL);
> +	swapcache_free_entry(swap);
>  redirty:
>  	set_page_dirty(page);
>  	if (wbc->for_reclaim)
> diff -puN mm/swapfile.c~make-page-and-swp_entry_t-variants mm/swapfile.c
> --- linux.git/mm/swapfile.c~make-page-and-swp_entry_t-variants	2013-05-07 13:48:13.968056427 -0700
> +++ linux.git-davehans/mm/swapfile.c	2013-05-07 13:48:13.977056825 -0700
> @@ -637,7 +637,7 @@ void swap_free(swp_entry_t entry)
>  /*
>   * Called after dropping swapcache to decrease refcnt to swap entries.
>   */
> -void swapcache_free(swp_entry_t entry, struct page *page)
> +static void __swapcache_free(swp_entry_t entry, struct page *page)
>  {
>  	struct swap_info_struct *p;
>  	unsigned char count;
> @@ -651,6 +651,17 @@ void swapcache_free(swp_entry_t entry, s
>  	}
>  }
>  
> +void swapcache_free_entry(swp_entry_t entry)
> +{
> +	__swapcache_free(entry, NULL);
> +}
> +
> +void swapcache_free_page_entry(struct page *page)
> +{
> +	swp_entry_t entry = { .val = page_private(page) };
> +	__swapcache_free(entry, page);
> +}

Patch one moved the clearing of private_private and ClearPageSwapCache
from __delete_from_swap_cache to two callers. Now that you have split
the function, it would be a lot tidier if this helper looked like

void swapcache_free_page_entry(struct page *page)
{
	swp_entry_t entry = { .val = page_private(page) };
	__swapcache_free(entry, page);
	set_page_private(page, 0);
	ClearPageSwapCache(page);
}

and the callers were no longer responsible again. I suspect this would
have been more obvious if patch 1 & 2 were collapsed together. Otherwise,
independent of the rest of the series, this looks like a reasonable cleanup.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
