Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 965326B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 12:50:30 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id b205so44791214wmb.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 09:50:30 -0800 (PST)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id mp15si4871502wjc.62.2016.02.24.09.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 09:50:29 -0800 (PST)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 24 Feb 2016 17:50:28 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id A7E381B0805F
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:50:46 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1OHoQCi63242332
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 17:50:26 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1OHoQRC031069
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:50:26 -0700
Date: Wed, 24 Feb 2016 18:50:25 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split
 vs. gup_fast
Message-ID: <20160224185025.65711ed6@thinkpad>
In-Reply-To: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 24 Feb 2016 18:59:21 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Previously, __split_huge_page_splitting() required serialization against
> gup_fast to make sure nobody can obtain new reference to the page after
> __split_huge_page_splitting() returns. This was a way to stabilize page
> references before starting to distribute them from head page to tail
> pages.
> 
> With new refcounting, we don't care about this. Splitting PMD is now
> decoupled from splitting underlying compound page. It's okay to get new
> pins after split_huge_pmd(). To stabilize page references during
> split_huge_page() we rely on setting up migration entries once all
> pmds are split into page tables.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/gup.c         | 11 +++--------
>  mm/huge_memory.c |  7 +++----
>  2 files changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 7bf19ffa2199..2f528fce3a62 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1087,8 +1087,7 @@ struct page *get_dump_page(unsigned long addr)
>   *
>   * get_user_pages_fast attempts to pin user pages by walking the page
>   * tables directly and avoids taking locks. Thus the walker needs to be
> - * protected from page table pages being freed from under it, and should
> - * block any THP splits.
> + * protected from page table pages being freed from under it.
>   *
>   * One way to achieve this is to have the walker disable interrupts, and
>   * rely on IPIs from the TLB flushing code blocking before the page table
> @@ -1097,9 +1096,8 @@ struct page *get_dump_page(unsigned long addr)
>   *
>   * Another way to achieve this is to batch up page table containing pages
>   * belonging to more than one mm_user, then rcu_sched a callback to free those
> - * pages. Disabling interrupts will allow the fast_gup walker to both block
> - * the rcu_sched callback, and an IPI that we broadcast for splitting THPs
> - * (which is a relatively rare event). The code below adopts this strategy.
> + * pages. Disabling interrupts will allow the fast_gup walker to block
> + * the rcu_sched callback. The code below adopts this strategy.
>   *
>   * Before activating this code, please be aware that the following assumptions
>   * are currently made:
> @@ -1391,9 +1389,6 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	 * With interrupts disabled, we block page table pages from being
>  	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
>  	 * for more details.
> -	 *
> -	 * We do not adopt an rcu_read_lock(.) here as we also want to
> -	 * block IPIs that come from THPs splitting.
>  	 */

Hmm, now that the IPI from THP splitting is not needed anymore, this
comment would suggest that we could use rcu_read_lock(_sched) for
fast_gup, instead of keeping the (probably more expensive) IRQ enable/
disable. That should be enough to synchronize against the
call_rcu_sched() from the batched tlb_table_flush, right?

So, if the comment is correct, removing it would also remove the hint
that we could use RCU instead if IRQ enable/disable.

> 
>  	local_irq_save(flags);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e10a4fee88d2..846fe173e04b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2930,10 +2930,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * for the same virtual address to be loaded simultaneously. So instead
>  	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
>  	 * current pmd notpresent (atomically because here the pmd_trans_huge
> -	 * and pmd_trans_splitting must remain set at all times on the pmd
> -	 * until the split is complete for this pmd), then we flush the SMP TLB
> -	 * and finally we write the non-huge version of the pmd entry with
> -	 * pmd_populate.
> +	 * must remain set at all times on the pmd until the split_huge_pmd()
> +	 * is complete, then we flush the SMP TLB and finally we write the
> +	 * non-huge version of the pmd entry with pmd_populate.
>  	 */
>  	pmdp_invalidate(vma, haddr, pmd);
>  	pmd_populate(mm, pmd, pgtable);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
