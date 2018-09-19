Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 765B68E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 08:39:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x19-v6so2772938pfh.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 05:39:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j15-v6si20156858pfn.366.2018.09.19.05.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 05:39:02 -0700 (PDT)
Date: Wed, 19 Sep 2018 14:38:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] s390/tlb: convert to generic mmu_gather
Message-ID: <20180919123849.GF24124@hirez.programming.kicks-ass.net>
References: <20180918125151.31744-1-schwidefsky@de.ibm.com>
 <20180918125151.31744-3-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180918125151.31744-3-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Sep 18, 2018 at 02:51:51PM +0200, Martin Schwidefsky wrote:
> +#define pte_free_tlb pte_free_tlb
> +#define pmd_free_tlb pmd_free_tlb
> +#define p4d_free_tlb p4d_free_tlb
> +#define pud_free_tlb pud_free_tlb

> @@ -121,9 +62,18 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
>   * page table from the tlb.
>   */
>  static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
> +                                unsigned long address)
>  {
> +	__tlb_adjust_range(tlb, address, PAGE_SIZE);
> +	tlb->mm->context.flush_mm = 1;
> +	tlb->freed_tables = 1;
> +	tlb->cleared_ptes = 1;
> +	/*
> +	 * page_table_free_rcu takes care of the allocation bit masks
> +	 * of the 2K table fragments in the 4K page table page,
> +	 * then calls tlb_remove_table.
> +	 */
> +        page_table_free_rcu(tlb, (unsigned long *) pte, address);

(whitespace damage, fixed)

Also, could you perhaps explain the need for that
page_table_alloc/page_table_free code? That is, I get the comment about
using 2K page-table fragments out of 4k physical page, but why this
custom allocator instead of kmem_cache? It feels like there's a little
extra complication, but it's not immediately obvious what.

>  }

We _could_ use __pte_free_tlb() here I suppose, but...

>  /*
> @@ -139,6 +89,10 @@ static inline void pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
>  	if (tlb->mm->context.asce_limit <= _REGION3_SIZE)
>  		return;
>  	pgtable_pmd_page_dtor(virt_to_page(pmd));
> +	__tlb_adjust_range(tlb, address, PAGE_SIZE);
> +	tlb->mm->context.flush_mm = 1;
> +	tlb->freed_tables = 1;
> +	tlb->cleared_puds = 1;
>  	tlb_remove_table(tlb, pmd);
>  }
>  
> @@ -154,6 +108,10 @@ static inline void p4d_free_tlb(struct mmu_gather *tlb, p4d_t *p4d,
>  {
>  	if (tlb->mm->context.asce_limit <= _REGION1_SIZE)
>  		return;
> +	__tlb_adjust_range(tlb, address, PAGE_SIZE);
> +	tlb->mm->context.flush_mm = 1;
> +	tlb->freed_tables = 1;
> +	tlb->cleared_p4ds = 1;
>  	tlb_remove_table(tlb, p4d);
>  }
>  
> @@ -169,19 +127,11 @@ static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
>  {
>  	if (tlb->mm->context.asce_limit <= _REGION2_SIZE)
>  		return;
> +	tlb->mm->context.flush_mm = 1;
> +	tlb->freed_tables = 1;
> +	tlb->cleared_puds = 1;
>  	tlb_remove_table(tlb, pud);
>  }

It's that ASCE limit that makes it impossible to use the generic
helpers, right?
