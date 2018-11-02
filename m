Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFF806B000E
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 10:56:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n9-v6so1833427pfg.12
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 07:56:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4-v6sor18522433plh.23.2018.11.02.07.56.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 07:56:45 -0700 (PDT)
Date: Fri, 2 Nov 2018 17:56:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mremap: properly flush TLB before releasing the page
Message-ID: <20181102145638.gehn7eszv22lelh6@kshutemo-mobl1>
References: <1541164962-28533-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541164962-28533-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: Will Deacon <will.deacon@arm.com>, gregkh@linuxfoundation.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, jannh@google.com, mingo@kernel.org, peterz@infradead.org, linux-mm@kvack.org, mhocko@kernel.org, hughd@google.com

On Fri, Nov 02, 2018 at 01:22:42PM +0000, Will Deacon wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> 
> Commit eb66ae030829605d61fbef1909ce310e29f78821 upstream.

I have never seen the original patch on mailing lists, so I'll reply to
the backport.

> 
> This is a backport to stable 4.4.y.
> 
> Jann Horn points out that our TLB flushing was subtly wrong for the
> mremap() case.  What makes mremap() special is that we don't follow the
> usual "add page to list of pages to be freed, then flush tlb, and then
> free pages".  No, mremap() obviously just _moves_ the page from one page
> table location to another.
> 
> That matters, because mremap() thus doesn't directly control the
> lifetime of the moved page with a freelist: instead, the lifetime of the
> page is controlled by the page table locking, that serializes access to
> the entry.

I believe we do control the lifetime of the page with mmap_sem, don't we?

I mean any shoot down of the page from a mapping would require at least
down_read(mmap_sem) and we hold down_write(mmap_sem). Hm?

> As a result, we need to flush the TLB not just before releasing the lock
> for the source location (to avoid any concurrent accesses to the entry),
> but also before we release the destination page table lock (to avoid the
> TLB being flushed after somebody else has already done something to that
> page).
> 
> This also makes the whole "need_flush" logic unnecessary, since we now
> always end up flushing the TLB for every valid entry.
> 
> Reported-and-tested-by: Jann Horn <jannh@google.com>
> Acked-by: Will Deacon <will.deacon@arm.com>
> Tested-by: Ingo Molnar <mingo@kernel.org>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> [will: backport to 4.4 stable]
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  mm/huge_memory.c |  6 +++++-
>  mm/mremap.c      | 21 ++++++++++++++++-----
>  2 files changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c4ea57ee2fd1..465786cd6490 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1511,7 +1511,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  	spinlock_t *old_ptl, *new_ptl;
>  	int ret = 0;
>  	pmd_t pmd;
> -
> +	bool force_flush = false;
>  	struct mm_struct *mm = vma->vm_mm;
>  
>  	if ((old_addr & ~HPAGE_PMD_MASK) ||
> @@ -1539,6 +1539,8 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  		if (new_ptl != old_ptl)
>  			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
>  		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
> +		if (pmd_present(pmd))
> +			force_flush = true;
>  		VM_BUG_ON(!pmd_none(*new_pmd));
>  
>  		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
> @@ -1547,6 +1549,8 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
>  		}
>  		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
> +		if (force_flush)
> +			flush_tlb_range(vma, old_addr, old_addr + PMD_SIZE);
>  		if (new_ptl != old_ptl)
>  			spin_unlock(new_ptl);
>  		spin_unlock(old_ptl);
> diff --git a/mm/mremap.c b/mm/mremap.c
> index fe7b7f65f4f4..450b306d473e 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -96,6 +96,8 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	pte_t *old_pte, *new_pte, pte;
>  	spinlock_t *old_ptl, *new_ptl;
> +	bool force_flush = false;
> +	unsigned long len = old_end - old_addr;
>  
>  	/*
>  	 * When need_rmap_locks is true, we take the i_mmap_rwsem and anon_vma
> @@ -143,12 +145,26 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  		if (pte_none(*old_pte))
>  			continue;
>  		pte = ptep_get_and_clear(mm, old_addr, old_pte);
> +		/*
> +		 * If we are remapping a valid PTE, make sure
> +		 * to flush TLB before we drop the PTL for the PTE.
> +		 *
> +		 * NOTE! Both old and new PTL matter: the old one
> +		 * for racing with page_mkclean(), the new one to
> +		 * make sure the physical page stays valid until
> +		 * the TLB entry for the old mapping has been
> +		 * flushed.
> +		 */

Could you elaborate on the race with page_mkclean()?

I think the new logic is unnecessary strict (and slow).

Any barely sane userspace must not access the old mapping after
mremap(MREMAP_MAYMOVE) called and must not access the new mapping
before the mremap() returns.

The old logic *should* be safe if this argument valid.

Do I miss something?

> +		if (pte_present(pte))
> +			force_flush = true;
>  		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
>  		pte = move_soft_dirty_pte(pte);
>  		set_pte_at(mm, new_addr, new_pte, pte);
>  	}
>  
>  	arch_leave_lazy_mmu_mode();
> +	if (force_flush)
> +		flush_tlb_range(vma, old_end - len, old_end);
>  	if (new_ptl != old_ptl)
>  		spin_unlock(new_ptl);
>  	pte_unmap(new_pte - 1);
> @@ -168,7 +184,6 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  {
>  	unsigned long extent, next, old_end;
>  	pmd_t *old_pmd, *new_pmd;
> -	bool need_flush = false;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>  
> @@ -207,7 +222,6 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  					anon_vma_unlock_write(vma->anon_vma);
>  			}
>  			if (err > 0) {
> -				need_flush = true;
>  				continue;
>  			} else if (!err) {
>  				split_huge_page_pmd(vma, old_addr, old_pmd);
> @@ -224,10 +238,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  			extent = LATENCY_LIMIT;
>  		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
>  			  new_vma, new_pmd, new_addr, need_rmap_locks);
> -		need_flush = true;
>  	}
> -	if (likely(need_flush))
> -		flush_tlb_range(vma, old_end-len, old_addr);
>  
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, mmun_start, mmun_end);
>  
> -- 
> 2.1.4
> 

-- 
 Kirill A. Shutemov
