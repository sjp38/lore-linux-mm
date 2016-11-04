Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4372A6B029A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 22:20:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rf5so31852074pab.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:20:32 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id i76si13063446pgd.27.2016.11.03.19.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 19:20:31 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id d2so42002005pfd.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:20:31 -0700 (PDT)
Date: Thu, 3 Nov 2016 19:20:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid when
 PageSwapBacked
In-Reply-To: <20161102070346.12489-2-npiggin@gmail.com>
Message-ID: <alpine.LSU.2.11.1611031806520.4958@eggly.anvils>
References: <20161102070346.12489-1-npiggin@gmail.com> <20161102070346.12489-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@intel.com>

On Wed, 2 Nov 2016, Nicholas Piggin wrote:

> Can we do this? Seems too easy, I must be missing something.

I have not tried running with it, which might show up a few more
adjustments, but no showstoppers: I think you can well do this.

I'll be sorry to see "owner_priv_1" in my pageflags output,
but oh well.

The only thing I think you miss is PAGE_FLAGS_CHECK_AT_FREE:
that includes PG_swapcache, but not PG_owner_priv_1 or its
synonyms PG_checked, PG_pinned, PG_foreign (I wish we didn't
do those PG_synonyms!) - so, we've been making sure that a page
is never freed with the swapcache bit set, but nobody has cared
about the others, so you might hit somewhere they're not cleared
before freeing a page.

Easily remedied by removing PG_swapcache from the list,
I don't remember that PG_swapcache check ever being important.

shmem_replace_page() looks wrong to me currently (where do
PageLocked and PageSwapBacked get set?), but that's just
something noticed in considering your patch (it's reassuring
if SwapBacked is always set before SwapCache), not a problem
with your patch.

When mucking with pageflags, two easily overlooked places worth
checking are mm/huge_memory.c __split_huge_page_tail() (no
problem there) and mm/migrate.c migrate_page_move_mapping()
and migrate_page_copy() (look okay, though some repetition).

> 
> ---
>  include/linux/page-flags.h     | 12 ++++++++++--
>  include/trace/events/mmflags.h |  1 -
>  2 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74e4dda..58d30b8 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -87,7 +87,6 @@ enum pageflags {
>  	PG_private_2,		/* If pagecache, has fs aux data */
>  	PG_writeback,		/* Page is under writeback */
>  	PG_head,		/* A head page */
> -	PG_swapcache,		/* Swap page: swp_entry_t in private */
>  	PG_mappedtodisk,	/* Has blocks allocated on-disk */

Did you consider using PG_mappedtodisk instead of PG_owner_priv_1?
I think it's an even better candidate, actually having a relevant
name, and also only used on file pages before now, I believe.

But you may have found a good reason not to use it, or at least
enough doubt to avoid it (tmpfs does not call cleancache_init_fs():
I believe that's enough to make __delete_from_page_cache() safe).

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

The people interested in swapping THPs might want to be warned of that,
let's Cc them in case.

Don't expect any comment from me on the meatier 2/2 patch to
unlock_page(): I'll leave that to you and Linus and Peter.

Hugh

>  #else
>  PAGEFLAG_FALSE(SwapCache)
>  #endif
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 5a81ab4..30c2adb 100644
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
> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
