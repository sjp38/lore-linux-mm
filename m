Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B05616B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 00:09:18 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id hz10so747839vcb.10
        for <linux-mm@kvack.org>; Thu, 30 May 2013 21:09:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130529175125.GJ12193@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
	<CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
	<51A45861.1010008@gmail.com>
	<20130529122728.GA27176@twins.programming.kicks-ass.net>
	<51A5F7A7.5020604@synopsys.com>
	<20130529175125.GJ12193@twins.programming.kicks-ass.net>
Date: Fri, 31 May 2013 08:09:17 +0400
Message-ID: <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

Hi Peter,

On Wed, May 29, 2013 at 9:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> What about something like this?

With that patch I still get mtest05 firing my TLB/PTE incoherency check
in the UP PREEMPT_VOLUNTARY configuration. This happens after
zap_pte_range completion in the end of unmap_region because of
rescheduling called in the following call chain:

unmap_region
  free_pgtables
    unlink_anon_vmas
      lock_anon_vma_root
        down_write
          might_sleep
            might_resched
              _cond_resched


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
>         return tlb->fast_mode;
>  #else
> @@ -124,7 +125,15 @@ static inline int tlb_fast_mode(struct mmu_gather *tlb)
>          * and page free order so much..
>          */
>         return 1;
> -#endif
> +#endif /* CONFIG_SMP */
> +#else  /* CONFIG_PREEMPT */
> +       /*
> +        * Since mmu_gather is preemptible, preemptible kernels are like SMP
> +        * kernels, we must batch to make sure we invalidate TLBs before we
> +        * free the pages.
> +        */
> +       return 0;
> +#endif /* CONFIG_PREEMPT */
>  }
>
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
> +       /*
> +        * For full preempt kernels we must do regular batching like
> +        * SMP, see tlb_fast_mode(). For !PREEMPT we can 'cheat' and
> +        * do a flush before our voluntary 'yield'.
> +        */
> +       if (need_resched()) {
> +               tlb_flush_mmu(tlb);
> +               cond_resched();
> +       }
> +#endif
> +}
> +
>  /*
>   * If a p?d_bad entry is found while walking page tables, report
>   * the error, before resetting entry to p?d_none.  Usually (but
> @@ -1264,7 +1279,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>                         goto next;
>                 next = zap_pte_range(tlb, vma, pmd, addr, next, details);
>  next:
> -               cond_resched();
> +               cond_resched_tlb(tlb);
>         } while (pmd++, addr = next, addr != end);
>
>         return addr;
>
>



-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
