Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5378D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 16:07:40 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:06:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12/20] mm: Extended batches for generic mmu_gather
Message-Id: <20110419130633.3d8cd5ae.akpm@linux-foundation.org>
In-Reply-To: <20110401121725.892956392@chello.nl>
References: <20110401121258.211963744@chello.nl>
	<20110401121725.892956392@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, 01 Apr 2011 14:13:10 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Instead of using a single batch (the small on-stack, or an allocated
> page), try and extend the batch every time it runs out and only flush
> once either the extend fails or we're done.

why?

>
> ...
>
> @@ -86,22 +86,48 @@ struct mmu_gather {
>  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
>  	struct mmu_table_batch	*batch;
>  #endif
> -	unsigned int		nr;	/* set to ~0U means fast mode */
> -	unsigned int		max;	/* nr < max */
> -	unsigned int		need_flush;/* Really unmapped some ptes? */
> -	unsigned int		fullmm; /* non-zero means full mm flush */
> -	struct page		**pages;
> -	struct page		*local[MMU_GATHER_BUNDLE];
> +	unsigned int		need_flush : 1,	/* Did free PTEs */
> +				fast_mode  : 1; /* No batching   */

mmu_gather.fast_mode gets modified in several places apparently without
locking to protect itself.  I don't think that these modifications will
accidentally trash need_flush, mainly by luck.

Please review the concurrency issues here and document them clearly.

> +	unsigned int		fullmm;
> +
> +	struct mmu_gather_batch *active;
> +	struct mmu_gather_batch	local;
> +	struct page		*__pages[MMU_GATHER_BUNDLE];
>  };
>  
> -static inline void __tlb_alloc_page(struct mmu_gather *tlb)
> +/*
> + * For UP we don't need to worry about TLB flush
> + * and page free order so much..
> + */
> +#ifdef CONFIG_SMP
> +  #define tlb_fast_mode(tlb) (tlb->fast_mode)
> +#else
> +  #define tlb_fast_mode(tlb) 1
> +#endif

Mutter.

Could have been written in C.

Will cause a compile error with, for example, tlb_fast_mode(tlb + 1).

> +static inline int tlb_next_batch(struct mmu_gather *tlb)
>  {
> -	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
> +	struct mmu_gather_batch *batch;
>  
> -	if (addr) {
> -		tlb->pages = (void *)addr;
> -		tlb->max = PAGE_SIZE / sizeof(struct page *);
> +	batch = tlb->active;
> +	if (batch->next) {
> +		tlb->active = batch->next;
> +		return 1;
>  	}
> +
> +	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);

A comment explaining the gfp_t decision would be useful.

> +	if (!batch)
> +		return 0;
> +
> +	batch->next = NULL;
> +	batch->nr   = 0;
> +	batch->max  = MAX_GATHER_BATCH;
> +
> +	tlb->active->next = batch;
> +	tlb->active = batch;
> +
> +	return 1;
>  }
>  
>  /* tlb_gather_mmu
> @@ -114,16 +140,13 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
>  {
>  	tlb->mm = mm;
>  
> -	tlb->max = ARRAY_SIZE(tlb->local);
> -	tlb->pages = tlb->local;
> -
> -	if (num_online_cpus() > 1) {
> -		tlb->nr = 0;
> -		__tlb_alloc_page(tlb);
> -	} else /* Use fast mode if only one CPU is online */
> -		tlb->nr = ~0U;
> -
> -	tlb->fullmm = fullmm;
> +	tlb->fullmm     = fullmm;
> +	tlb->need_flush = 0;
> +	tlb->fast_mode  = (num_possible_cpus() == 1);

The changelog didn't tell us why we switched from num_online_cpus() to
num_possible_cpus().

> +	tlb->local.next = NULL;
> +	tlb->local.nr   = 0;
> +	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
> +	tlb->active     = &tlb->local;
>  
>  #ifdef CONFIG_HAVE_RCU_TABLE_FREE
>  	tlb->batch = NULL;
>
> ...
>
> @@ -177,15 +205,24 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
>   */
>  static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>  {
> +	struct mmu_gather_batch *batch;
> +
>  	tlb->need_flush = 1;
> +
>  	if (tlb_fast_mode(tlb)) {
>  		free_page_and_swap_cache(page);
>  		return 1; /* avoid calling tlb_flush_mmu() */
>  	}
> -	tlb->pages[tlb->nr++] = page;
> -	VM_BUG_ON(tlb->nr > tlb->max);
>  
> -	return tlb->max - tlb->nr;
> +	batch = tlb->active;
> +	batch->pages[batch->nr++] = page;
> +	VM_BUG_ON(batch->nr > batch->max);
> +	if (batch->nr == batch->max) {
> +		if (!tlb_next_batch(tlb))
> +			return 0;
> +	}

Moving the VM_BUG_ON() down to after the if() would save a few cycles.

> +	return batch->max - batch->nr;
>  }
>  
>  /* tlb_remove_page
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
