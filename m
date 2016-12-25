Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8452D6B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 00:13:59 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id l192so565894422oih.2
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 21:13:59 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id b207si5804929oii.47.2016.12.24.21.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 21:13:58 -0800 (PST)
Received: by mail-oi0-x22c.google.com with SMTP id 128so107975390oig.0
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 21:13:58 -0800 (PST)
Date: Sat, 24 Dec 2016 21:13:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid when
 PageSwapBacked
In-Reply-To: <20161225030030.23219-2-npiggin@gmail.com>
Message-ID: <alpine.LSU.2.11.1612242105500.7382@eggly.anvils>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Sun, 25 Dec 2016, Nicholas Piggin wrote:

> A page is not added to the swap cache without being swap backed,
> so PageSwapBacked mappings can use PG_owner_priv_1 for PageSwapCache.
> 
> Acked-by: Hugh Dickins <hughd@google.com>

Yes, confirmed, Acked-by: Hugh Dickins <hughd@google.com>
I checked through your migrate and memory-failure additions,
and both look correct to me.  I still think that more should
be done for KPF_SWAPCACHE, to exclude the new false positives;
but as I said before, no urgency, that can be a later followup.

> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  include/linux/page-flags.h     | 24 ++++++++++++++++--------
>  include/trace/events/mmflags.h |  1 -
>  mm/memory-failure.c            |  4 +---
>  mm/migrate.c                   | 14 ++++++++------
>  4 files changed, 25 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74e4dda91238..a57c909a15e4 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -87,7 +87,6 @@ enum pageflags {
>  	PG_private_2,		/* If pagecache, has fs aux data */
>  	PG_writeback,		/* Page is under writeback */
>  	PG_head,		/* A head page */
> -	PG_swapcache,		/* Swap page: swp_entry_t in private */
>  	PG_mappedtodisk,	/* Has blocks allocated on-disk */
>  	PG_reclaim,		/* To be reclaimed asap */
>  	PG_swapbacked,		/* Page is backed by RAM/swap */
> @@ -110,6 +109,9 @@ enum pageflags {
>  	/* Filesystems */
>  	PG_checked = PG_owner_priv_1,
>  
> +	/* SwapBacked */
> +	PG_swapcache = PG_owner_priv_1,	/* Swap page: swp_entry_t in private */
> +
>  	/* Two page bits are conscripted by FS-Cache to maintain local caching
>  	 * state.  These bits are set on pages belonging to the netfs's inodes
>  	 * when those inodes are being locally cached.
> @@ -314,7 +316,13 @@ PAGEFLAG_FALSE(HighMem)
>  #endif
>  
>  #ifdef CONFIG_SWAP
> -PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
> +static __always_inline int PageSwapCache(struct page *page)
> +{
> +	return PageSwapBacked(page) && test_bit(PG_swapcache, &page->flags);
> +
> +}
> +SETPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
> +CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
>  #else
>  PAGEFLAG_FALSE(SwapCache)
>  #endif
> @@ -701,12 +709,12 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
>   * Flags checked when a page is freed.  Pages being freed should not have
>   * these flags set.  It they are, there is a problem.
>   */
> -#define PAGE_FLAGS_CHECK_AT_FREE \
> -	(1UL << PG_lru	 | 1UL << PG_locked    | \
> -	 1UL << PG_private | 1UL << PG_private_2 | \
> -	 1UL << PG_writeback | 1UL << PG_reserved | \
> -	 1UL << PG_slab	 | 1UL << PG_swapcache | 1UL << PG_active | \
> -	 1UL << PG_unevictable | __PG_MLOCKED)
> +#define PAGE_FLAGS_CHECK_AT_FREE				\
> +	(1UL << PG_lru		| 1UL << PG_locked	|	\
> +	 1UL << PG_private	| 1UL << PG_private_2	|	\
> +	 1UL << PG_writeback	| 1UL << PG_reserved	|	\
> +	 1UL << PG_slab		| 1UL << PG_active 	|	\
> +	 1UL << PG_unevictable	| __PG_MLOCKED)
>  
>  /*
>   * Flags checked when a page is prepped for return by the page allocator.
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 5a81ab48a2fb..30c2adbdebe8 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -95,7 +95,6 @@
>  	{1UL << PG_private_2,		"private_2"	},		\
>  	{1UL << PG_writeback,		"writeback"	},		\
>  	{1UL << PG_head,		"head"		},		\
> -	{1UL << PG_swapcache,		"swapcache"	},		\
>  	{1UL << PG_mappedtodisk,	"mappedtodisk"	},		\
>  	{1UL << PG_reclaim,		"reclaim"	},		\
>  	{1UL << PG_swapbacked,		"swapbacked"	},		\
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 19e796d36a62..f283c7e0a2a3 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -764,12 +764,11 @@ static int me_huge_page(struct page *p, unsigned long pfn)
>   */
>  
>  #define dirty		(1UL << PG_dirty)
> -#define sc		(1UL << PG_swapcache)
> +#define sc		((1UL << PG_swapcache) | (1UL << PG_swapbacked))
>  #define unevict		(1UL << PG_unevictable)
>  #define mlock		(1UL << PG_mlocked)
>  #define writeback	(1UL << PG_writeback)
>  #define lru		(1UL << PG_lru)
> -#define swapbacked	(1UL << PG_swapbacked)
>  #define head		(1UL << PG_head)
>  #define slab		(1UL << PG_slab)
>  #define reserved	(1UL << PG_reserved)
> @@ -819,7 +818,6 @@ static struct page_state {
>  #undef mlock
>  #undef writeback
>  #undef lru
> -#undef swapbacked
>  #undef head
>  #undef slab
>  #undef reserved
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 0ed24b1fa77b..87f4d0f81819 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -466,13 +466,15 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 */
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
> -	if (PageSwapBacked(page))
> -		__SetPageSwapBacked(newpage);
> -
>  	get_page(newpage);	/* add cache reference */
> -	if (PageSwapCache(page)) {
> -		SetPageSwapCache(newpage);
> -		set_page_private(newpage, page_private(page));
> +	if (PageSwapBacked(page)) {
> +		__SetPageSwapBacked(newpage);
> +		if (PageSwapCache(page)) {
> +			SetPageSwapCache(newpage);
> +			set_page_private(newpage, page_private(page));
> +		}
> +	} else {
> +		VM_BUG_ON_PAGE(PageSwapCache(page), page);
>  	}
>  
>  	/* Move dirty while page refs frozen and newpage not yet exposed */
> -- 
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
