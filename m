Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B49F46B037C
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:55:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b1so478240416pgc.5
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 11:55:33 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id m68si31760958pga.16.2016.12.22.11.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 11:55:32 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id i5so35993957pgh.2
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 11:55:32 -0800 (PST)
Date: Thu, 22 Dec 2016 11:55:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid when
 PageSwapBacked
In-Reply-To: <20161221151951.16396-2-npiggin@gmail.com>
Message-ID: <alpine.LSU.2.11.1612221130520.4215@eggly.anvils>
References: <20161221151951.16396-1-npiggin@gmail.com> <20161221151951.16396-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, 22 Dec 2016, Nicholas Piggin wrote:

I agree with every word of that changelog ;)

And I'll stamp this with
Acked-by: Hugh Dickins <hughd@google.com>

The thing that Peter remembers I commented on (which 0day caught too),
was to remove PG_swapcache from PAGE_FLAGS_CHECK_AT_FREE: you've done
that now, so this is good.  (Note in passing: wouldn't it be good to
add PG_waiters to PAGE_FLAGS_CHECK_AT_FREE in the 2/2?)

Though I did yesterday notice a few more problematic uses of
PG_swapcache, which you'll probably need to refine to exclude
other uses of PG_owner_priv_1; though no great hurry for those,
so not necessarily in this same patch.  Do your own grep, but

fs/proc/page.c derives its KPF_SWAPCACHE from PG_swapcache,
needs refining.

kernel/kexec_core.c says VMCOREINFO_NUMBER(PG_swapcache):
I haven't looked into what that's about, it will probably just
have to be commented as now including other uses of the same bit.

mm/memory-failure.c has an error_states[] table that involves
testing PG_swapcache as "sc", but looks as if it can be changed
to factor in "swapbacked" too.

Hugh

> ---
>  include/linux/page-flags.h     | 24 ++++++++++++++++--------
>  include/trace/events/mmflags.h |  1 -
>  2 files changed, 16 insertions(+), 9 deletions(-)
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
> -- 
> 2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
