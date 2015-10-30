Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 31DA582F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 12:49:40 -0400 (EDT)
Received: by iody8 with SMTP id y8so85519590iod.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 09:49:40 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id l85si8354825iod.195.2015.10.30.09.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 09:49:39 -0700 (PDT)
Received: by pasz6 with SMTP id z6so79167248pas.2
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 09:49:39 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:49:37 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH 1/8] mm: support madvise(MADV_FREE)
Message-ID: <20151030164937.GA44946@kernel.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446188504-28023-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

On Fri, Oct 30, 2015 at 04:01:37PM +0900, Minchan Kim wrote:
> +static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +
> +{
> +	struct mmu_gather *tlb = walk->private;
> +	struct mm_struct *mm = tlb->mm;
> +	struct vm_area_struct *vma = walk->vma;
> +	spinlock_t *ptl;
> +	pte_t *pte, ptent;
> +	struct page *page;
> +
> +	split_huge_page_pmd(vma, addr, pmd);
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	arch_enter_lazy_mmu_mode();
> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		ptent = *pte;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, ptent);
> +		if (!page)
> +			continue;
> +
> +		if (PageSwapCache(page)) {
> +			if (!trylock_page(page))
> +				continue;
> +
> +			if (!try_to_free_swap(page)) {
> +				unlock_page(page);
> +				continue;
> +			}
> +
> +			ClearPageDirty(page);
> +			unlock_page(page);
> +		}
> +
> +		/*
> +		 * Some of architecture(ex, PPC) don't update TLB
> +		 * with set_pte_at and tlb_remove_tlb_entry so for
> +		 * the portability, remap the pte with old|clean
> +		 * after pte clearing.
> +		 */
> +		ptent = ptep_get_and_clear_full(mm, addr, pte,
> +						tlb->fullmm);
> +		ptent = pte_mkold(ptent);
> +		ptent = pte_mkclean(ptent);
> +		set_pte_at(mm, addr, pte, ptent);
> +		tlb_remove_tlb_entry(tlb, pte, addr);

The orginal ptent might not be dirty. In that case, the tlb_remove_tlb_entry
is unnecessary, so please add a check. In practice, I saw more TLB flush with
FREE compared to DONTNEED because of this issue.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
