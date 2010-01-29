Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A85E6B0071
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 16:08:53 -0500 (EST)
Date: Fri, 29 Jan 2010 13:08:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFP 3/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-Id: <20100129130820.1544eb1f.akpm@linux-foundation.org>
In-Reply-To: <20100128195634.798620000@alcatraz.americas.sgi.com>
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
	<20100128195634.798620000@alcatraz.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010 13:56:30 -0600
Robin Holt <holt@sgi.com> wrote:

> 
> Make the truncate case handle the need to sleep.  We accomplish this
> by failing the mmu_notifier_invalidate_range_start(... atomic==1)
> case which inturn falls back to unmap_mapping_range_vma() with the
> restart_address == start_address.  In that case, we make an additional
> callout to mmu_notifier_invalidate_range_start(... atomic==0) after the
> i_mmap_lock has been released.

This is a mushroom patch.  This patch (and the rest of the patchset)
fails to provide any reason for making any change to anything.

I understand that it has something to do with xpmem?  That needs to be
spelled out in some detail please, so we understand the requirements
and perhaps can suggest alternatives.  If we have enough information we
can perhaps even suggest alternatives _within xpmem_.  But right now, we
have nothing.

> ===================================================================
> --- mmu_notifiers_sleepable_v1.orig/include/linux/mmu_notifier.h	2010-01-28 13:43:26.000000000 -0600
> +++ mmu_notifiers_sleepable_v1/include/linux/mmu_notifier.h	2010-01-28 13:43:26.000000000 -0600
> @@ -170,8 +170,8 @@ extern void __mmu_notifier_change_pte(st
>  				      unsigned long address, pte_t pte);
>  extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
>  					  unsigned long address);
> -extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end);
> +extern int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> +			    unsigned long start, unsigned long end, int atomic);

Perhaps `atomic' could be made bool.

> ...
>
> @@ -1018,12 +1019,17 @@ unsigned long unmap_vmas(struct mmu_gath
>  	unsigned long start = start_addr;
>  	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
>  	struct mm_struct *mm = vma->vm_mm;
> +	int ret;
>  
>  	/*
>  	 * mmu_notifier_invalidate_range_start can sleep. Don't initialize
>  	 * mmu_gather until it completes
>  	 */
> -	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> +	ret = mmu_notifier_invalidate_range_start(mm, start_addr,
> +					end_addr, (i_mmap_lock == NULL));
> +	if (ret)
> +		goto out;
> +

afaict, `ret' doesn't get used for anything.

>  	*tlbp = tlb_gather_mmu(mm, fullmm);
>  	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
>  		unsigned long end;
> @@ -1107,7 +1113,7 @@ unsigned long zap_page_range(struct vm_a
>  		unsigned long size, struct zap_details *details)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	struct mmu_gather *tlb;
> +	struct mmu_gather *tlb == NULL;

This statement doesn't do what you thought it did.  Didn't the compiler warn?

>  	unsigned long end = address + size;
>  	unsigned long nr_accounted = 0;
>  
> @@ -1908,7 +1914,7 @@ int apply_to_page_range(struct mm_struct
>  	int err;
>  
>  	BUG_ON(addr >= end);
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> +	mmu_notifier_invalidate_range_start(mm, start, end, 0);
>  	pgd = pgd_offset(mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
> @@ -2329,6 +2335,7 @@ static int unmap_mapping_range_vma(struc
>  {
>  	unsigned long restart_addr;
>  	int need_break;
> +	int need_unlocked_invalidate;
>  
>  	/*
>  	 * files that support invalidating or truncating portions of the
> @@ -2350,7 +2357,9 @@ again:
>  
>  	restart_addr = zap_page_range(vma, start_addr,
>  					end_addr - start_addr, details);
> -	need_break = need_resched() || spin_needbreak(details->i_mmap_lock);
> +	need_unlocked_invalidate = (restart_addr == start_addr);
> +	need_break = need_resched() || spin_needbreak(details->i_mmap_lock) ||
> +					need_unlocked_invalidate;
>  
>  	if (restart_addr >= end_addr) {
>  		/* We have now completed this vma: mark it so */
> @@ -2365,6 +2374,10 @@ again:
>  	}
>  
>  	spin_unlock(details->i_mmap_lock);
> +	if (need_unlocked_invalidate) {
> +		mmu_notifier_invalidate_range_start(vma->mm, start, end, 0);
> +		mmu_notifier_invalidate_range_end(vma->mm, start, end);
> +	}

This is the appropriate place at which to add a comment explaining to
the reader what the code is doing.

> -void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -				  unsigned long start, unsigned long end)
> +int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> +			     unsigned long start, unsigned long end, int atomic)

The implementation would be considerably less ugly if we could do away
with the `atomic' thing altogether and just assume `atomic=false'
throughout?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
