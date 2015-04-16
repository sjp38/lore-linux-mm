Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 501F26B006E
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 14:57:24 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so98919363pab.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:57:24 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id nw9si13310679pdb.195.2015.04.16.11.57.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 11:57:23 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so101493143pdb.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:57:23 -0700 (PDT)
Date: Thu, 16 Apr 2015 11:57:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
In-Reply-To: <1429179766-26711-5-git-send-email-mgorman@suse.de>
Message-ID: <alpine.LSU.2.11.1504161148270.17733@eggly.anvils>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Apr 2015, Mel Gorman wrote:

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
>  mm/migrate.c  | 6 +++++-
>  mm/vmscan.c   | 2 +-
>  3 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 35aba439c275..c2481574b41a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -436,10 +436,15 @@ struct tlbflush_unmap_batch;
>  
>  #ifdef CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH
>  void try_to_unmap_flush(void);
> +void alloc_tlb_ubc(void);
>  #else
>  static inline void try_to_unmap_flush(void)
>  {
>  }
>  
> +static inline void alloc_tlb_ubc(void)
> +{
> +}
> +
>  #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 85e042686031..fda7b320ac00 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -879,7 +879,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	/* Establish migration ptes or remove ptes */
>  	if (page_mapped(page)) {
>  		try_to_unmap(page,
> -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|TTU_BATCH_FLUSH);
>  		page_was_mapped = 1;
>  	}
>  
> @@ -1098,6 +1098,8 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  	if (!swapwrite)
>  		current->flags |= PF_SWAPWRITE;
>  
> +	alloc_tlb_ubc();
> +
>  	for(pass = 0; pass < 10 && retry; pass++) {
>  		retry = 0;
>  
> @@ -1144,6 +1146,8 @@ out:
>  	if (!swapwrite)
>  		current->flags &= ~PF_SWAPWRITE;
>  
> +	try_to_unmap_flush();

This is the right place to aim to flush, but I think you have to make
more changes before it is safe to do so here.

The putback_lru_page(page) in unmap_and_move() is commented "A page
that has been migrated has all references removed and will be freed".

If you leave TLB flushing until after the page has been freed, then
there's a risk that userspace will see, not the data it expects at
whatever virtual address, but data placed in there by the next user
of this freed page.

So you'll need to do a little restructuring first.

> +
>  	return rc;
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8dde281652a..361bf59e0594 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2771,7 +2771,7 @@ out:
>   * failure is harmless as the reclaimer will send IPIs where necessary.
>   * If the allocation size changes then update BATCH_TLBFLUSH_SIZE.
>   */
> -static inline void alloc_tlb_ubc(void)
> +void alloc_tlb_ubc(void)
>  {
>  	if (current->tlb_ubc)
>  		return;
> -- 
> 2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
