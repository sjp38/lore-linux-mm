Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7DD6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:47:10 -0400 (EDT)
Received: by wgez8 with SMTP id z8so29053749wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:47:09 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id y20si16231778wjq.3.2015.06.10.00.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 00:47:08 -0700 (PDT)
Received: by wifx6 with SMTP id x6so38129336wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:47:08 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:47:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610074704.GA18049@gmail.com>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433871118-15207-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1289,6 +1289,18 @@ enum perf_event_task_context {
>  	perf_nr_task_contexts,
>  };
>  
> +/* Track pages that require TLB flushes */
> +struct tlbflush_unmap_batch {
> +	/*
> +	 * Each bit set is a CPU that potentially has a TLB entry for one of
> +	 * the PFNs being flushed. See set_tlb_ubc_flush_pending().
> +	 */
> +	struct cpumask cpumask;
> +
> +	/* True if any bit in cpumask is set */
> +	bool flush_required;
> +};
> +
>  struct task_struct {
>  	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
>  	void *stack;
> @@ -1648,6 +1660,10 @@ struct task_struct {
>  	unsigned long numa_pages_migrated;
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> +#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
> +	struct tlbflush_unmap_batch *tlb_ubc;
> +#endif

Please embedd this constant size structure in task_struct directly so that the 
whole per task allocation overhead goes away:

> +#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
> +/*
> + * Allocate the control structure for batch TLB flushing. An allocation
> + * failure is harmless as the reclaimer will send IPIs where necessary.
> + * A GFP_KERNEL allocation from this context is normally not advised but
> + * we are depending on PF_MEMALLOC (set by direct reclaim or kswapd) to
> + * limit the depth of the call.
> + */
> +static void alloc_tlb_ubc(void)
> +{
> +	if (!current->tlb_ubc)
> +		current->tlb_ubc = kzalloc(sizeof(struct tlbflush_unmap_batch),
> +						GFP_KERNEL | __GFP_NOWARN);
> +}
> +#else
> +static inline void alloc_tlb_ubc(void)
> +{
> +}
> +#endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
> +
>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> @@ -2152,6 +2174,8 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
>  	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
>  			 sc->priority == DEF_PRIORITY);
>  
> +	alloc_tlb_ubc();
> +
>  	blk_start_plug(&plug);
>  	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
>  					nr[LRU_INACTIVE_FILE]) {

the whole patch series will become even simpler.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
