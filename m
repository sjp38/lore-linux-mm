Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id C846E6B0118
	for <linux-mm@kvack.org>; Thu,  8 May 2014 16:07:29 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so3069730wes.0
        for <linux-mm@kvack.org>; Thu, 08 May 2014 13:07:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si2398524eer.267.2014.05.08.13.07.27
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 13:07:28 -0700 (PDT)
Message-ID: <536BE351.1050005@redhat.com>
Date: Thu, 08 May 2014 16:04:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] mm: support madvise(MADV_FREE)
References: <1398045368-2586-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1398045368-2586-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

On 04/20/2014 09:56 PM, Minchan Kim wrote:

> In summary, MADV_FREE is about 2 time faster than MADV_DONTNEED.

This is awesome.

I have a few nitpicks with the patch, though :)

> +static long madvise_lazyfree(struct vm_area_struct *vma,
> +			     struct vm_area_struct **prev,
> +			     unsigned long start, unsigned long end)
> +{
> +	*prev = vma;
> +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> +		return -EINVAL;
> +
> +	/* MADV_FREE works for only anon vma at the moment */
> +	if (vma->vm_file)
> +		return -EINVAL;
> +
> +	lazyfree_range(vma, start, end - start);
> +	return 0;
> +}

This code checks whether lazyfree_range would work on
the VMA...

> diff --git a/mm/memory.c b/mm/memory.c
> index c4b5bc250820..ca427f258204 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1270,6 +1270,104 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>   	return addr;
>   }
>
> +static unsigned long lazyfree_pte_range(struct mmu_gather *tlb,
> +				struct vm_area_struct *vma, pmd_t *pmd,
> +				unsigned long addr, unsigned long end)
> +{
> +	struct mm_struct *mm = tlb->mm;
> +	spinlock_t *ptl;
> +	pte_t *start_pte;
> +	pte_t *pte;
> +
> +	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	pte = start_pte;
> +	arch_enter_lazy_mmu_mode();
> +	do {
> +		pte_t ptent = *pte;
> +
> +		if (pte_none(ptent))
> +			continue;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		ptent = pte_mkold(ptent);
> +		ptent = pte_mkclean(ptent);
> +		set_pte_at(mm, addr, pte, ptent);
> +		tlb_remove_tlb_entry(tlb, pte, addr);

This may not work on PPC, which has a weird hash table for
its TLB. You will find that tlb_remove_tlb_entry does
nothing for PPC64, and set_pte_at does not remove the hash
table entry either.

> @@ -1370,6 +1485,31 @@ void unmap_vmas(struct mmu_gather *tlb,
>   }
>
>   /**
> + * lazyfree_range - clear dirty bit of pte in a given range
> + * @vma: vm_area_struct holding the applicable pages
> + * @start: starting address of pages
> + * @size: number of bytes to do lazyfree
> + *
> + * Caller must protect the VMA list
> + */
> +void lazyfree_range(struct vm_area_struct *vma, unsigned long start,
> +		unsigned long size)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_gather tlb;
> +	unsigned long end = start + size;
> +
> +	lru_add_drain();
> +	tlb_gather_mmu(&tlb, mm, start, end);
> +	update_hiwater_rss(mm);
> +	mmu_notifier_invalidate_range_start(mm, start, end);
> +	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
> +		lazyfree_single_vma(&tlb, vma, start, end);
> +	mmu_notifier_invalidate_range_end(mm, start, end);
> +	tlb_finish_mmu(&tlb, start, end);
> +}

This function, called by madvise_lazyfree, can iterate
over multiple VMAs.

However, madvise_lazyfree only checked one of them.

What should happen when the code encounters a VMA where
MADV_FREE does not work?  Should it return an error?
Should it skip over it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
