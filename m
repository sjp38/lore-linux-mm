Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7A53A6B0002
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 23:14:31 -0400 (EDT)
Date: Fri, 29 Mar 2013 00:14:21 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch 3/4 v4]swap: fix races exposed by swap discard
Message-ID: <20130329031420.GC19721@optiplex.redhat.com>
References: <20130326053827.GC19646@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130326053827.GC19646@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com

On Tue, Mar 26, 2013 at 01:38:27PM +0800, Shaohua Li wrote:
> Last patch can expose races, according to Hugh:
> 
> swapoff was sometimes failing with "Cannot allocate memory", coming from
> try_to_unuse()'s -ENOMEM: it needs to allow for swap_duplicate() failing on a
> free entry temporarily SWAP_MAP_BAD while being discarded.
> 
> We should use ACCESS_ONCE() there, and whenever accessing swap_map locklessly;
> but rather than peppering it throughout try_to_unuse(), just declare *swap_map
> with volatile.
> 
> try_to_unuse() is accustomed to *swap_map going down racily, but not
> necessarily to it jumping up from 0 to SWAP_MAP_BAD: we'll be safer to prevent
> that transition once SWP_WRITEOK is switched off, when it's a waste of time to
> issue discards anyway (swapon can do a whole discard).
> 
> Another issue is:
> 
> In swapin_readahead(), read_swap_cache_async() can read a bad swap entry,
> because we don't check if readahead swap entry is bad. This doesn't break
> anything but such swapin page is wasteful and can only be freed at page
> reclaim. We avoid read such swap entry.
> 
> And next patch will mark a swap entry bad temporarily for discard. Without this
> patch, swap entry count will be messed.
> 
> Thanks Hugh to inspire swapin_readahead could use bad swap entry.
> 
> [include Hugh's patch 'swap: fix swapoff ENOMEMs from discard']
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>


>  mm/swapfile.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2013-03-22 17:28:06.000000000 +0800
> +++ linux/mm/swapfile.c	2013-03-22 17:40:51.580356594 +0800
> @@ -331,7 +331,8 @@ static inline void dec_cluster_info_page
>  		 * instead of free it immediately. The cluster will be freed
>  		 * after discard.
>  		 */
> -		if (p->flags & SWP_DISCARDABLE) {
> +		if ((p->flags & (SWP_WRITEOK | SWP_DISCARDABLE)) ==
> +				 (SWP_WRITEOK | SWP_DISCARDABLE)) {
>  			swap_cluster_schedule_discard(p, idx);
>  			return;
>  		}
> @@ -1228,7 +1229,7 @@ static unsigned int find_next_to_unuse(s
>  			else
>  				continue;
>  		}
> -		count = si->swap_map[i];
> +		count = ACCESS_ONCE(si->swap_map[i]);
>  		if (count && swap_count(count) != SWAP_MAP_BAD)
>  			break;
>  	}
> @@ -1248,7 +1249,7 @@ int try_to_unuse(unsigned int type, bool
>  {
>  	struct swap_info_struct *si = swap_info[type];
>  	struct mm_struct *start_mm;
> -	unsigned char *swap_map;
> +	volatile unsigned char *swap_map;	/* ACCESS_ONCE throughout */
>  	unsigned char swcount;
>  	struct page *page;
>  	swp_entry_t entry;
> @@ -1299,7 +1300,8 @@ int try_to_unuse(unsigned int type, bool
>  			 * reused since sys_swapoff() already disabled
>  			 * allocation from here, or alloc_page() failed.
>  			 */
> -			if (!*swap_map)
> +			swcount = *swap_map;
> +			if (!swcount || swcount == SWAP_MAP_BAD)
>  				continue;
>  			retval = -ENOMEM;
>  			break;
> @@ -2432,6 +2434,11 @@ static int __swap_duplicate(swp_entry_t
>  		goto unlock_out;
>  
>  	count = p->swap_map[offset];
> +	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
> +		err = -ENOENT;
> +		goto unlock_out;
> +	}
> +
>  	has_cache = count & SWAP_HAS_CACHE;
>  	count &= ~SWAP_HAS_CACHE;
>  	err = 0;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
