Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE816B2A5B
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:40:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w194-v6so3330742oiw.5
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:40:58 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c78-v6si2500104oib.369.2018.08.23.06.40.57
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 06:40:57 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:40:53 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 1/2] mm: move tlb_table_flush to tlb_flush_mmu_free
Message-ID: <20180823134052.GC1496@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823084709.19717-2-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org

On Thu, Aug 23, 2018 at 06:47:08PM +1000, Nicholas Piggin wrote:
> There is no need to call this from tlb_flush_mmu_tlbonly, it
> logically belongs with tlb_flush_mmu_free. This allows some
> code consolidation with a subsequent fix.
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  mm/memory.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Looks good to me, thanks:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

> diff --git a/mm/memory.c b/mm/memory.c
> index 19f47d7b9b86..7c58310734eb 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -245,9 +245,6 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
>  
>  	tlb_flush(tlb);
>  	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
> -#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> -	tlb_table_flush(tlb);
> -#endif
>  	__tlb_reset_range(tlb);
>  }
>  
> @@ -255,6 +252,9 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
>  {
>  	struct mmu_gather_batch *batch;
>  
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> +	tlb_table_flush(tlb);
> +#endif
>  	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
>  		free_pages_and_swap_cache(batch->pages, batch->nr);
>  		batch->nr = 0;
> -- 
> 2.17.0
> 
