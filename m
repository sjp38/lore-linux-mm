Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 90BB36B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:58:32 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x3so5866032qcv.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 12:58:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id h5si17462170qas.73.2014.04.22.12.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 12:58:31 -0700 (PDT)
Date: Tue, 22 Apr 2014 09:54:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140422075459.GD11182@twins.programming.kicks-ass.net>
References: <1398032742.19682.11.camel@pasglop>
 <CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>
 <1398054064.19682.32.camel@pasglop>
 <1398057630.19682.38.camel@pasglop>
 <CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
 <53558507.9050703@zytor.com>
 <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
 <53559F48.8040808@intel.com>
 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
 <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Mon, Apr 21, 2014 at 05:44:45PM -0700, Linus Torvalds wrote:
> From d26515fe19d5850aa69881ee6ae193e068f22ba1 Mon Sep 17 00:00:00 2001
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 21 Apr 2014 17:35:35 -0700
> Subject: [PATCH 2/2] mm: make the generic TLB flush batching correctly dirty
>  the page at the end
> 
> When unmapping dirty shared mappings, the page should be dirtied after
> doing the TLB flush.  This does that by hiding the dirty bit in the low
> bit of the "struct page" pointer in the TLB gather batching array, and
> teaching free_pages_and_swap_cache() to mark the pages dirty at the end.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Peter Anvin <hpa@zytor.com>

Acked-by: Peter Zijlstra <peterz@infradead.org>

> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: linux-arch@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  mm/memory.c     |  5 +----
>  mm/swap.c       |  8 +++++++-
>  mm/swap_state.c | 14 ++++++++++++--
>  3 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 62fdcd1995f4..174542ab2b90 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -283,11 +283,8 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page, bool dirty)
>  
>  	VM_BUG_ON(!tlb->need_flush);
>  
> -	/* FIXME! This needs to be batched too */
> -	if (dirty)
> -		set_page_dirty(page);
>  	batch = tlb->active;
> -	batch->pages[batch->nr++] = page;
> +	batch->pages[batch->nr++] = (void *) (dirty + (unsigned long)page);

Space between cast and expression.

>  	if (batch->nr == batch->max) {
>  		if (!tlb_next_batch(tlb))
>  			return 0;
> diff --git a/mm/swap.c b/mm/swap.c
> index 9ce43ba4498b..1a58c58c7f41 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -821,8 +821,14 @@ void release_pages(struct page **pages, int nr, int cold)
>  	struct lruvec *lruvec;
>  	unsigned long uninitialized_var(flags);
>  
> +	/*
> +	 * NOTE! The low bit of the struct page pointer in
> +	 * the "pages[]" array is used as a dirty bit, so
> +	 * we ignore it
> +	 */
>  	for (i = 0; i < nr; i++) {
> -		struct page *page = pages[i];
> +		unsigned long pageval = (unsigned long)pages[i];
> +		struct page *page = (void *)(~1ul & pageval);

No space between cast and expression.

Should we create some pointer bitops helpers? We do this casting all
over the place, maybe its time to make it pretty?

static inline void *ptr_or(void *ptr, unsigned long val)
{
	WARN_ON(val & ~0x03); /* too bad __alignof__ is 'broken' */
	return (void *)((unsigned long)ptr | val);
}

static inline void *ptr_mask(void *ptr)
{
	return (void *)((unsigned long)ptr & ~0x03);
}

static inline unsigned long ptr_and(void *ptr, unsigned long val)
{
	WARN_ON(val & ~0x03);
	return (unsigned long)ptr & val;
}

>  		if (unlikely(PageCompound(page))) {
>  			if (zone) {
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index e76ace30d436..bb0b2d675a82 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -258,6 +258,11 @@ void free_page_and_swap_cache(struct page *page)
>  /*
>   * Passed an array of pages, drop them all from swapcache and then release
>   * them.  They are removed from the LRU and freed if this is their last use.
> + *
> + * NOTE! The low bit of the "struct page" pointers passed in is a dirty
> + * indicator, saying that the page needs to be marked dirty before freeing.
> + *
> + * release_pages() itself ignores that bit.
>   */
>  void free_pages_and_swap_cache(struct page **pages, int nr)
>  {
> @@ -268,8 +273,13 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
>  		int todo = min(nr, PAGEVEC_SIZE);
>  		int i;
>  
> -		for (i = 0; i < todo; i++)
> -			free_swap_cache(pagep[i]);
> +		for (i = 0; i < todo; i++) {
> +			unsigned long pageval = (unsigned long) pagep[i];
> +			struct page *page = (void *)(~1ul & pageval);
> +			if (pageval & 1)
> +				set_page_dirty(page);
> +			free_swap_cache(page);
> +		}
>  		release_pages(pagep, todo, 0);
>  		pagep += todo;
>  		nr -= todo;

So PAGE_FLAGS_CHECK_AT_FREE doesn't include PG_dirty, so while we now
properly mark the page dirty, we could continue and simply free the
thing?

I suppose the pagecache has a ref on and there's no window where we
could drop that before doing this free (didn't check).

But my main point was; should we check for the dirty bit when freeing
the page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
