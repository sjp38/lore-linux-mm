Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id A594A6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:50:50 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id z60so81114qgd.19
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 04:50:50 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id u47si250603qgd.10.2014.08.27.04.50.49
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 04:50:49 -0700 (PDT)
Date: Wed, 27 Aug 2014 12:50:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATH V2 3/6] arm: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140827115010.GJ6968@arm.com>
References: <1408635812-31584-1-git-send-email-steve.capper@linaro.org>
 <1408635812-31584-4-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408635812-31584-4-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Thu, Aug 21, 2014 at 04:43:29PM +0100, Steve Capper wrote:
> --- a/arch/arm/include/asm/tlb.h
> +++ b/arch/arm/include/asm/tlb.h
> @@ -35,12 +35,39 @@
>  
>  #define MMU_GATHER_BUNDLE	8
>  
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> +static inline void __tlb_remove_table(void *_table)
> +{
> +	free_page_and_swap_cache((struct page *)_table);
> +}
> +
> +struct mmu_table_batch {
> +	struct rcu_head		rcu;
> +	unsigned int		nr;
> +	void			*tables[0];
> +};
> +
> +#define MAX_TABLE_BATCH		\
> +	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
> +
> +extern void tlb_table_flush(struct mmu_gather *tlb);
> +extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
> +
> +#define tlb_remove_entry(tlb, entry)	tlb_remove_table(tlb, entry)
> +#else
> +#define tlb_remove_entry(tlb, entry)	tlb_remove_page(tlb, entry)
> +#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
> +
>  /*
>   * TLB handling.  This allows us to remove pages from the page
>   * tables, and efficiently handle the TLB issues.
>   */
>  struct mmu_gather {
>  	struct mm_struct	*mm;
> +#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> +	struct mmu_table_batch	*batch;
> +	unsigned int		need_flush;
> +#endif

We add need_flush here just because it is set by tlb_remove_table() but
it won't actually be checked by anything since arch/arm uses its own
version of tlb_flush_mmu(). But I wouldn't go for #ifdefs in the core
code either.

We should (as a separate patchset) convert arch/arm to generic
mmu_gather. I know Russell had objections in the past but mmu_gather has
evolved since and it's not longer inefficient (I think the only case is
shift_arg_pages but that's pretty much lost in the noise).

For this patch:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
