Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DAC706B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 16:55:02 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so921959pdj.18
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:55:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id p3si11411214pbj.8.2014.01.22.13.55.00
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 13:55:01 -0800 (PST)
Date: Wed, 22 Jan 2014 13:54:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/mmu_notifier: restore set_pte_at_notify semantics
Message-Id: <20140122135459.120a50ecec95d0e3cf017586@linux-foundation.org>
In-Reply-To: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com>
References: <1389778834-21200-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Haggai Eran <haggaie@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, 15 Jan 2014 11:40:34 +0200 Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> Commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 (mm: wrap calls to
> set_pte_at_notify with invalidate_range_start and invalidate_range_end)
> breaks semantics of set_pte_at_notify. When calls to set_pte_at_notify
> are wrapped with mmu_notifier_invalidate_range_start and
> mmu_notifier_invalidate_range_end, KVM zaps pte during
> mmu_notifier_invalidate_range_start callback and set_pte_at_notify has
> no spte to update and therefore it's called for nothing.
> 
> As Andrea suggested (1), the problem is resolved by calling
> mmu_notifier_invalidate_page after PT lock has been released and only
> for mmu_notifiers that do not implement change_ptr callback.
> 
> (1) http://thread.gmane.org/gmane.linux.kernel.mm/111710/focus=111711

The changelog fails to describe the end-user visible effects of the
bug, so I (and others) will be unable to decide which kernel versions
need patching

Given that the bug has been around for 1.5 years I assume the priority
is low.

The patch appears to assume that a single call to
->invalidate_range_start()/->invalidate_range_end() is equivalent to a
series of per-page calls to ->invalidate_page(), yes?  I'd have
expected to see some discussion of this in the changelog.

I expect this change will make drivers/misc/sgi-gru/grutlbpurge.c run
slower, but I don't know how much.  And GRU will now be missing its
wake_up_all() during ->invalidate_range_all() - I don't know what
effect that will have.

I didn't review any other affected callers.  Please do this and
explain the expected impact.  Please also cc the affected developers
and ensure that enough information is provided so they can understand
the effect the patch has upon their code.

Generally, the patch is really ugly :( We have a nice consistent and
symmetrical pattern of calling
->invalidate_range_start()/->invalidate_range_end() and this patch
comes along and tears great holes in it by removing those calls from a
subset of places and replacing them with open-coded calls to
single-page ->invalidate_page().  Isn't there some (much) nicer way of
doing all this?


> @@ -283,9 +296,11 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>  	struct mm_struct *___mm = __mm;					\
>  	unsigned long ___address = __address;				\
>  	pte_t ___pte = __pte;						\
> +	int ___ret;							\
>  									\
> -	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
> +	___ret = mmu_notifier_change_pte(___mm, ___address, ___pte);	\
>  	set_pte_at(___mm, ___address, __ptep, ___pte);			\
> +	___ret;								\
>  })

set_pte_at_notify() used to be well-documented.  Now it is missing
documentation for its return value.

> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -131,14 +131,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  	pte_t *ptep;
>  	int err;
> -	/* For mmu_notifiers */
> -	const unsigned long mmun_start = addr;
> -	const unsigned long mmun_end   = addr + PAGE_SIZE;
> +	int notify_missing = 0;

Using a bool would be clearer.

The initialisation appears to be unnecessary.

>  	/* For try_to_free_swap() and munlock_vma_page() below */
>  	lock_page(page);
>  
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  	err = -EAGAIN;
>  	ptep = page_check_address(page, mm, addr, &ptl, 0);
>  	if (!ptep)
> @@ -154,20 +151,23 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>  	ptep_clear_flush(vma, addr, ptep);
> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> +	notify_missing = set_pte_at_notify(mm, addr, ptep,
> +					   mk_pte(kpage, vma->vm_page_prot));
>  
>  	page_remove_rmap(page);
>  	if (!page_mapped(page))
>  		try_to_free_swap(page);
>  	pte_unmap_unlock(ptep, ptl);
>  
> +	if (notify_missing)
> +		mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);

Some comments would be helpful here.  At least to explain to the reader
that we're pulling tricks to avoid calling the notifiers under
pte_offset_map_lock().

>  	if (vma->vm_flags & VM_LOCKED)
>  		munlock_vma_page(page);
>  	put_page(page);
>  
>  	err = 0;
>   unlock:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  	unlock_page(page);
>  	return err;
>  }
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 175fff7..42e8254 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -861,8 +861,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  	spinlock_t *ptl;
>  	int swapped;
>  	int err = -EFAULT;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	int notify_missing = 0;

bool?

Here the initialisation appears to be needed.

>  	addr = page_address_in_vma(page, vma);
>  	if (addr == -EFAULT)
> @@ -870,13 +869,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  
>  	BUG_ON(PageTransCompound(page));
>  
> -	mmun_start = addr;
> -	mmun_end   = addr + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> -
>  	ptep = page_check_address(page, mm, addr, &ptl, 0);
>  	if (!ptep)
> -		goto out_mn;
> +		goto out;
>  
>  	if (pte_write(*ptep) || pte_dirty(*ptep)) {
>  		pte_t entry;
> @@ -904,15 +899,15 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
>  		if (pte_dirty(entry))
>  			set_page_dirty(page);
>  		entry = pte_mkclean(pte_wrprotect(entry));
> -		set_pte_at_notify(mm, addr, ptep, entry);
> +		notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
>  	}
>  	*orig_pte = *ptep;
>  	err = 0;
>  
>  out_unlock:
>  	pte_unmap_unlock(ptep, ptl);
> -out_mn:
> -	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	if (notify_missing)
> +		mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
>  out:
>  	return err;
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index 6768ce9..596d4c3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2611,8 +2611,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret = 0;
>  	int page_mkwrite = 0;
>  	struct page *dirty_page = NULL;
> -	unsigned long mmun_start = 0;	/* For mmu_notifiers */
> -	unsigned long mmun_end = 0;	/* For mmu_notifiers */
> +	int notify_missing = 0;

dittoes.

>  	old_page = vm_normal_page(vma, address, orig_pte);
>  	if (!old_page) {
> @@ -2798,10 +2797,6 @@ gotten:
>  	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
>  		goto oom_free_new;
>  
> -	mmun_start  = address & PAGE_MASK;
> -	mmun_end    = mmun_start + PAGE_SIZE;
> -	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
> -
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> @@ -2830,7 +2825,8 @@ gotten:
>  		 * mmu page tables (such as kvm shadow page tables), we want the
>  		 * new page to be mapped directly into the secondary page table.
>  		 */
> -		set_pte_at_notify(mm, address, page_table, entry);
> +		notify_missing = set_pte_at_notify(mm, address, page_table,
> +						   entry);
>  		update_mmu_cache(vma, address, page_table);
>  		if (old_page) {
>  			/*
> @@ -2868,8 +2864,8 @@ gotten:
>  		page_cache_release(new_page);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> -	if (mmun_end > mmun_start)
> -		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> +	if (notify_missing)
> +		mmu_notifier_invalidate_page_if_missing_change_pte(mm, address);
>  	if (old_page) {
>  		/*
>  		 * Don't let another task, with possibly unlocked vma,
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 93e6089..5fc5bc2 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -122,18 +122,23 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
>  	return young;
>  }
>  
> -void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
> -			       pte_t pte)
> +int __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
> +			      pte_t pte)

return bool?

Document the return value (at least).

>  {
>  	struct mmu_notifier *mn;
>  	int id;
> +	int ret = 0;
>  
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->change_pte)
>  			mn->ops->change_pte(mn, mm, address, pte);
> +		else
> +			ret = 1;
>  	}
>  	srcu_read_unlock(&srcu, id);
> +
> +	return ret;
>  }
>  
>  void __mmu_notifier_invalidate_page(struct mm_struct *mm,
> @@ -180,6 +185,21 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
>  
> +void __mmu_notifier_invalidate_page_if_missing_change_pte(struct mm_struct *mm,
> +							  unsigned long address)
> +{
> +	struct mmu_notifier *mn;
> +	int id;
> +
> +	id = srcu_read_lock(&srcu);
> +	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> +		if (mn->ops->invalidate_page && !mn->ops->change_pte)
> +			mn->ops->invalidate_page(mn, mm, address);
> +	}
> +	srcu_read_unlock(&srcu, id);
> +}
> +EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_page_if_missing_change_pte);

Definitely needs thorough documenting, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
