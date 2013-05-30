Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BE63A6B0167
	for <linux-mm@kvack.org>; Thu, 30 May 2013 01:05:12 -0400 (EDT)
Message-ID: <51A6DDF5.2000406@synopsys.com>
Date: Thu, 30 May 2013 10:34:53 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: TLB and PTE coherency during munmap
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com> <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com> <51A45861.1010008@gmail.com> <20130529122728.GA27176@twins.programming.kicks-ass.net> <51A5F7A7.5020604@synopsys.com> <20130529175125.GJ12193@twins.programming.kicks-ass.net>
In-Reply-To: <20130529175125.GJ12193@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Max Filippov <jcmvbkbc@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

On 05/29/2013 11:21 PM, Peter Zijlstra wrote:
> What about something like this?
>
> ---
>  include/asm-generic/tlb.h | 11 ++++++++++-
>  mm/memory.c               | 17 ++++++++++++++++-
>  2 files changed, 26 insertions(+), 2 deletions(-)
>
> diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
> index b1b1fa6..651b1cf 100644
> --- a/include/asm-generic/tlb.h
> +++ b/include/asm-generic/tlb.h
> @@ -116,6 +116,7 @@ struct mmu_gather {
>  
>  static inline int tlb_fast_mode(struct mmu_gather *tlb)
>  {
> +#ifndef CONFIG_PREEMPT
>  #ifdef CONFIG_SMP
>  	return tlb->fast_mode;
>  #else
> @@ -124,7 +125,15 @@ static inline int tlb_fast_mode(struct mmu_gather *tlb)
>  	 * and page free order so much..
>  	 */
>  	return 1;
> -#endif
> +#endif /* CONFIG_SMP */
> +#else  /* CONFIG_PREEMPT */
> +	/*
> +	 * Since mmu_gather is preemptible, preemptible kernels are like SMP
> +	 * kernels, we must batch to make sure we invalidate TLBs before we
> +	 * free the pages.
> +	 */
> +	return 0;
> +#endif /* CONFIG_PREEMPT */
>  }

So this adds the page batching logic to small/simpler UP systems - but it's
necessary evil :-(

>  void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
> diff --git a/mm/memory.c b/mm/memory.c
> index 6dc1882..e915af2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -384,6 +384,21 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
>  
>  #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
>  
> +static inline void cond_resched_tlb(struct mmu_gather *tlb)
> +{
> +#ifndef CONFIG_PREEMPT
> +	/*
> +	 * For full preempt kernels we must do regular batching like
> +	 * SMP, see tlb_fast_mode(). For !PREEMPT we can 'cheat' and
> +	 * do a flush before our voluntary 'yield'.
> +	 */
> +	if (need_resched()) {

This is really neat: w/o this check, a @fullmm flush (exit/execve) would have
suffered multiple full TLB flushes in the loop, now you do that only if a
scheduling was needed - meaning only in the case when we have the potential race
condition which Max was seeing. Cool !

> +		tlb_flush_mmu(tlb);
> +		cond_resched();
> +	}
> +#endif
> +}
> +
>  /*
>   * If a p?d_bad entry is found while walking page tables, report
>   * the error, before resetting entry to p?d_none.  Usually (but
> @@ -1264,7 +1279,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>  			goto next;
>  		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
>  next:
> -		cond_resched();
> +		cond_resched_tlb(tlb);
>  	} while (pmd++, addr = next, addr != end);
>  
>  	return addr;

BTW, since we are on the topic, it seems that we are missing tlb_fast_mode() in
one spot - unless it is tied to rcu table free stuff.

-------------->
From: Vineet Gupta <vgupta@synopsys.com>
Date: Thu, 30 May 2013 10:25:30 +0530
Subject: [PATCH] mm: tlb_fast_mode check missing in tlb_finish_mmu()

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/memory.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index d9d5fd9..569ffe1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -269,6 +269,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long
start, unsigned long e
     /* keep the page table cache within bounds */
     check_pgt_cache();
 
+    if (tlb_fast_mode(tlb))
+        return;
+
     for (batch = tlb->local.next; batch; batch = next) {
         next = batch->next;
         free_pages((unsigned long)batch, 0);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
