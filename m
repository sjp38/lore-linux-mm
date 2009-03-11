Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DDAB96B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 07:55:08 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
Date: Wed, 11 Mar 2009 22:54:56 +1100
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
In-Reply-To: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903112254.56764.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 11 March 2009 20:55:48 Daniel Lowengrub wrote:
> Use the linked list defined list.h for the list of vmas that's stored
> in the mm_struct structure.  Wrapper functions "vma_next" and
> "vma_prev" are also implemented.  Functions that operate on more than
> one vma are now given a list of vmas as input.

I'd love to be able to justify having a doubly linked list for vmas...
It's easier than managing singly linked lists by hand :) So if you have
such a good increase with lookups, it might be a good idea. I wouldn't
like to see vm_area_struct go above 192 bytes on any config if possible
though.


>
> Signed-off-by: Daniel Lowengrub
> ---
> diff -uNr linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c
> linux-2.6.28.7/arch/alpha/kernel/osf_sys.c
> --- linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c	2008-12-25
> 01:26:37.000000000 +0200
> +++ linux-2.6.28.7/arch/alpha/kernel/osf_sys.c	2009-02-28
> 23:34:42.000000000 +0200
> @@ -1197,7 +1197,7 @@
>  		if (!vma || addr + len <= vma->vm_start)
>  			return addr;
>  		addr = vma->vm_end;
> -		vma = vma->vm_next;
> +		vma = vma_next(vma);
>  	}
>  }
>
> diff -uNr linux-2.6.28.7.vanilla/arch/arm/mm/mmap.c
> linux-2.6.28.7/arch/arm/mm/mmap.c
> --- linux-2.6.28.7.vanilla/arch/arm/mm/mmap.c	2008-12-25
> 01:26:37.000000000 +0200
> +++ linux-2.6.28.7/arch/arm/mm/mmap.c	2009-02-28 23:35:31.000000000 +0200
> @@ -86,7 +86,7 @@
>  	else
>  		addr = PAGE_ALIGN(addr);
>
> -	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
> +	for (vma = find_vma(mm, addr); ; vma = vma->vma_next(vma)) {
>  		/* At this point:  (!vma || addr < vma->vm_end). */
>  		if (TASK_SIZE - len < addr) {
>  			/*

Careful with your replacements. I'd suggest a mechanical search &
replace might be less error prone.


> linux-2.6.28.7/include/linux/mm.h
> --- linux-2.6.28.7.vanilla/include/linux/mm.h	2009-03-06
> 15:32:58.000000000 +0200
> +++ linux-2.6.28.7/include/linux/mm.h	2009-03-11 10:51:28.000000000 +0200
> @@ -35,7 +35,7 @@
>  #endif
>
>  extern unsigned long mmap_min_addr;
> -
> +#include <linux/sched.h>
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
> @@ -212,6 +212,40 @@
>  		const nodemask_t *to, unsigned long flags);
>  #endif
>  };
> +/* Interface for the list_head prev and next pointers.  They
> + * don't let you wrap around the vm_list.
> + */
> +static inline struct vm_area_struct *
> +__vma_next(struct list_head *head, struct vm_area_struct *vma)
> +{
> +	if (unlikely(!vma))
> +		vma = container_of(head, struct vm_area_struct, vm_list);
> +	if (vma->vm_list.next == head)
> +		return NULL;
> +	return list_entry(vma->vm_list.next, struct vm_area_struct, vm_list);
> +}
> +
> +static inline struct vm_area_struct *
> +vma_next(struct vm_area_struct *vma)
> +{
> +	return __vma_next(&vma->vm_mm->mm_vmas, vma);
> +}
> +
> +static inline struct vm_area_struct *
> +__vma_prev(struct list_head *head, struct vm_area_struct *vma)
> +{
> +	if (unlikely(!vma))
> +		vma = container_of(head, struct vm_area_struct, vm_list);
> +	if (vma->vm_list.prev == head)
> +		return NULL;
> +	return list_entry(vma->vm_list.prev, struct vm_area_struct, vm_list);
> +}
> +
> +static inline struct vm_area_struct *
> +vma_prev(struct vm_area_struct *vma)
> +{
> +	return __vma_prev(&vma->vm_mm->mm_vmas, vma);
> +}

Hmm, I don't think these are really appropriate replacements for
vma->vm_next. 2 branches and a lot of extra icache.

A non circular list like hlist might work better, but I suspect if
callers are converted properly to have conditions ensuring that it
doesn't wrap and doesn't get NULL vmas passed in, then it could
avoid both those branches and just be a wrapper around
list_entry(vma->vm_list.next)


>  struct mmu_gather;
>  struct inode;
> @@ -747,7 +781,7 @@
>  		unsigned long size);
>  unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long
> address, unsigned long size, struct zap_details *);
> -unsigned long unmap_vmas(struct mmu_gather **tlb,
> +unsigned long unmap_vmas(struct mmu_gather **tlb, struct list_head *vmas,
>  		struct vm_area_struct *start_vma, unsigned long start_addr,
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *);
> diff -uNr linux-2.6.28.7.vanilla/include/linux/mm_types.h
> linux-2.6.28.7/include/linux/mm_types.h
> --- linux-2.6.28.7.vanilla/include/linux/mm_types.h	2008-12-25
> 01:26:37.000000000 +0200
> +++ linux-2.6.28.7/include/linux/mm_types.h	2009-02-27 12:14:25.000000000
> +0200 @@ -109,7 +109,7 @@
>  					   within vm_mm. */
>
>  	/* linked list of VM areas per task, sorted by address */
> -	struct vm_area_struct *vm_next;
> +	struct list_head vm_list;

While we're at it, can it just be named vma_list?

....

>  	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
>  	unsigned long vm_flags;		/* Flags, see mm.h. */
> @@ -171,7 +171,7 @@
>  };
>
>  struct mm_struct {
> -	struct vm_area_struct * mmap;		/* list of VMAs */
> +	struct list_head mm_vmas;		/* list of VMAs */

.... like this nice name change ;)


> -unsigned long unmap_vmas(struct mmu_gather **tlbp,
> +unsigned long unmap_vmas(struct mmu_gather **tlbp, struct list_head *vmas,
>  		struct vm_area_struct *vma, unsigned long start_addr,
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *details)
> @@ -902,7 +903,7 @@
>  	struct mm_struct *mm = vma->vm_mm;
>
>  	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> -	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
> +	for ( ; vma && vma->vm_start < end_addr; vma = __vma_next(vmas, vma)) {
>  		unsigned long end;
>
>  		start = max(vma->vm_start, start_addr);
> @@ -988,7 +989,8 @@
>  	lru_add_drain();
>  	tlb = tlb_gather_mmu(mm, 0);
>  	update_hiwater_rss(mm);
> -	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
> +	end = unmap_vmas(&tlb, &mm->mm_vmas, vma, address, end,
> +			&nr_accounted, details);

Why do you change this if the caller knows where the list head is
anyway, and extracts it from the mm? I'd prefer to keep changes to
calling convention to a minimum (and I hope with the changes to
vma_next I suggested then it wouldn't be needed to carry the list
head around everywhere anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
