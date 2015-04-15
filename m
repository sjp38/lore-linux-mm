Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 565BB6B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 17:06:28 -0400 (EDT)
Received: by pdea3 with SMTP id a3so65695398pde.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:06:28 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id im3si5648666pbb.55.2015.04.15.14.06.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 14:06:27 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so63783059pab.3
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:06:27 -0700 (PDT)
Date: Wed, 15 Apr 2015 14:06:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
In-Reply-To: <1429094576-5877-5-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.11.1504151302490.13387@eggly.anvils>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de> <1429094576-5877-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 15 Apr 2015, Mel Gorman wrote:

> Page reclaim batches multiple TLB flushes into one IPI and this patch teaches
> page migration to also batch any necessary flushes. MMtests has a THP scale
> microbenchmark that deliberately fragments memory and then allocates THPs
> to stress compaction. It's not a page reclaim benchmark and recent kernels
> avoid excessive compaction but this patch reduced system CPU usage
> 
>                4.0.0       4.0.0
>             baseline batchmigrate-v1
> User          970.70     1012.24
> System       2067.48     1840.00
> Elapsed      1520.63     1529.66
> 
> Note that this particular workload was not TLB flush intensive with peaks
> in interrupts during the compaction phase. The 4.0 kernel peaked at 345K
> interrupts/second, the kernel that batches reclaim TLB entries peaked at
> 13K interrupts/second and this patch peaked at 10K interrupts/second.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/internal.h | 5 +++++
>  mm/migrate.c  | 8 +++++++-
>  mm/vmscan.c   | 6 +-----
>  3 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index fe69dd159e34..cb70555a7291 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -436,10 +436,15 @@ struct unmap_batch;
>  
>  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
>  void try_to_unmap_flush(void);
> +void alloc_ubc(void);
>  #else
>  static inline void try_to_unmap_flush(void)
>  {
>  }
>  
> +static inline void alloc_ubc(void)
> +{
> +}
> +
>  #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 85e042686031..973d8befe528 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -789,6 +789,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		if (current->flags & PF_MEMALLOC)
>  			goto out;
>  
> +		try_to_unmap_flush();

I have a vested interest in minimizing page migration overhead,
enthusiastic for more batching if it can be done, so took a quick
look at this patch (the earliers not so much); but am mystified by
your placement of the try_to_unmap_flush()s.

Why would one be needed here, yet not before the trylock_page() above?
Oh, when might sleep?  Though I still don't grasp why that's necessary,
and try_to_unmap() below may itself sleep.

>  		lock_page(page);
>  	}
>  
> @@ -805,6 +806,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  		if (!force)
>  			goto out_unlock;
> +		try_to_unmap_flush();
>  		wait_on_page_writeback(page);
>  	}
>  	/*
> @@ -879,7 +881,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	/* Establish migration ptes or remove ptes */
>  	if (page_mapped(page)) {
>  		try_to_unmap(page,
> -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);

But isn't this the only place for the try_to_unmap_flush(), unless you
make much more change to the way page migration works?  Would batch
together the TLB flushes from multiple mappings of the same page,
though that's not a very ambitious goal.

Delayed much later than this point, and user modifications to the old
page could continue while we're copying it into the new page and after,
so the new page receives only some undefined part of the modifications.

Or perhaps this is the last minute point you were making about
page lock in the 0/4, though page lock not so relevant here. 

Or your paragraph in the 0/4 "If a clean page is unmapped and not
immediately flushed..." but I don't see where that is being enforced.

I can imagine more optimization possible on !pte_write pages than
on pte_write pages, but don't see any sign of that.

Or am I just skimming this series too carelessly, and making a fool of
myself by missing the important bits?  Sorry if I'm wasting your time.

>  		page_was_mapped = 1;
>  	}
>  
> @@ -1098,6 +1100,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  	if (!swapwrite)
>  		current->flags |= PF_SWAPWRITE;
>  
> +	alloc_ubc();
> +
>  	for(pass = 0; pass < 10 && retry; pass++) {
>  		retry = 0;
>  
> @@ -1144,6 +1148,8 @@ out:
>  	if (!swapwrite)
>  		current->flags &= ~PF_SWAPWRITE;
>  
> +	try_to_unmap_flush();
> +
>  	return rc;
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 68bcc0b73a76..d659e3655575 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2767,7 +2767,7 @@ out:
>  }
>  
>  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
> -static inline void alloc_ubc(void)
> +void alloc_ubc(void)

Looking at this patch first, I wondered what on earth a ubc is.
The letters "tlb" in the name might help people to locate its
place in the world better.

And then curious that it works with pfns rather than page pointers,
as its natural cousin mmu_gather does (oops, no "tlb" there either,
though that's compensated by naming its pointer "tlb" everywhere).

pfns: are you thinking ahead to struct page-less persistent memory
considerations?  Though would they ever arrive here?  I'd have
thought it better to carry on with struct pages at least for now -
or are they becoming unfashionable?  (I think some tracing struct
page pointers were converted to pfns recently.)  But no big deal.

>  {
>  	if (current->ubc)
>  		return;
> @@ -2784,10 +2784,6 @@ static inline void alloc_ubc(void)
>  	cpumask_clear(&current->ubc->cpumask);
>  	current->ubc->nr_pages = 0;
>  }
> -#else
> -static inline void alloc_ubc(void)
> -{
> -}
>  #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
>  
>  unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> -- 
> 2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
