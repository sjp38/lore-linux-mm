Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB436B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:26:10 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oB87Q7df030696
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 23:26:07 -0800
Received: from iwn6 (iwn6.prod.google.com [10.241.68.70])
	by kpbe13.cbf.corp.google.com with ESMTP id oB87OUgx010817
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 23:26:06 -0800
Received: by iwn6 with SMTP id 6so980729iwn.29
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 23:26:05 -0800 (PST)
Date: Tue, 7 Dec 2010 23:26:04 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 7/7] Prevent activation of page in madvise_dontneed
In-Reply-To: <AANLkTindkfPJxxjR-nVy+Tmu6Q=fs2c=KOmdOQyfXaCP@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1012072258420.5260@sister.anvils>
References: <cover.1291568905.git.minchan.kim@gmail.com> <ca25c4e33beceeb3a96e8437671e5e0a188602fa.1291568905.git.minchan.kim@gmail.com> <alpine.LSU.2.00.1012062027100.8572@tigran.mtv.corp.google.com>
 <AANLkTindkfPJxxjR-nVy+Tmu6Q=fs2c=KOmdOQyfXaCP@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010, Minchan Kim wrote:
> 
> How about this? Although it doesn't remove null dependency, it meet my
> goal without big overhead.
> It's just quick patch.

Roughly, yes; by "just quick patch" I take you to mean that I should
not waste time on all the minor carelessnesses scattered through it.

> If you agree, I will resend this version as formal patch.
> (If you suffered from seeing below word-wrapped source, see the
> attachment. I asked to google two time to support text-plain mode in
> gmail web but I can't receive any response until now. ;(. Lots of
> kernel developer in google. Please support this mode for us who can't
> use SMTP although it's a very small VOC)

Tiresome.  Seems not to be high on gmail's priorities.
It's sad to see even Linus attaching patches these days.

> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e097df6..14ae918 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -771,6 +771,7 @@ struct zap_details {
>         pgoff_t last_index;                     /* Highest page->index
> to unmap */
>         spinlock_t *i_mmap_lock;                /* For unmap_mapping_range: */
>         unsigned long truncate_count;           /* Compare vm_truncate_count */
> +       int ignore_reference;
>  };
> 
>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 319528b..fdb0253 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -162,18 +162,22 @@ static long madvise_dontneed(struct vm_area_struct * vma,
>                              struct vm_area_struct ** prev,
>                              unsigned long start, unsigned long end)
>  {
> +       struct zap_details details ;
> +
>         *prev = vma;
>         if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>                 return -EINVAL;
> 
>         if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
> -               struct zap_details details = {
> -                       .nonlinear_vma = vma,
> -                       .last_index = ULONG_MAX,
> -               };
> -               zap_page_range(vma, start, end - start, &details);
> -       } else
> -               zap_page_range(vma, start, end - start, NULL);
> +               details.nonlinear_vma = vma;
> +               details.last_index = ULONG_MAX;
> +       } else {
> +               details.nonlinear_vma = NULL;
> +               details.last_index = NULL;
> +       }
> +
> +       details.ignore_references = true;
> +       zap_page_range(vma, start, end - start, &details);
>         return 0;
>  }
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ebfeedf..d46ac42 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -897,9 +897,15 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>         pte_t *pte;
>         spinlock_t *ptl;
>         int rss[NR_MM_COUNTERS];
> -
> +       bool ignore_reference = false;
>         init_rss_vec(rss);
> 
> +       if (details && ((!details->check_mapping && !details->nonlinear_vma)
> +                                        || !details->ignore_reference))
> +               details = NULL;
> +

	bool mark_accessed = true;

	if (VM_SequentialReadHint(vma) ||
	    (details && details->ignore_reference))
		mark_accessed = false;
	if (details && !details->check_mapping && !details->nonlinear_vma)
		details = NULL;
     

>         pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
>         arch_enter_lazy_mmu_mode();
>         do {
> @@ -949,7 +955,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>                                 if (pte_dirty(ptent))
>                                         set_page_dirty(page);
>                                 if (pte_young(ptent) &&
> -                                   likely(!VM_SequentialReadHint(vma)))
> +                                   likely(!VM_SequentialReadHint(vma)) &&
> +                                   likely(!ignore_reference))
>                                         mark_page_accessed(page);

				if (pte_young(ptent) && mark_accessed)
					mark_page_accessed(page);


>                                 rss[MM_FILEPAGES]--;
>                         }
> @@ -1038,8 +1045,6 @@ static unsigned long unmap_page_range(struct
> mmu_gather *tlb,
>         pgd_t *pgd;
>         unsigned long next;
> 
> -       if (details && !details->check_mapping && !details->nonlinear_vma)
> -               details = NULL;
> 
>         BUG_ON(addr >= end);
>         mem_cgroup_uncharge_start();
> @@ -1102,7 +1107,8 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
>         unsigned long tlb_start = 0;    /* For tlb_finish_mmu */
>         int tlb_start_valid = 0;
>         unsigned long start = start_addr;
> -       spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
> +       spinlock_t *i_mmap_lock = details ?
> +               (detais->check_mapping ? details->i_mmap_lock: NULL) : NULL;

Why that change?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
