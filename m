Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 45FE56B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:26:24 -0500 (EST)
Received: by wmdw130 with SMTP id w130so149864314wmd.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:26:23 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id c9si17925865wje.210.2015.11.12.03.26.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 03:26:23 -0800 (PST)
Received: by wmec201 with SMTP id c201so86742356wme.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 03:26:22 -0800 (PST)
Date: Thu, 12 Nov 2015 13:26:20 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Message-ID: <20151112112620.GB22481@node.shutemov.name>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447302793-5376-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

On Thu, Nov 12, 2015 at 01:32:57PM +0900, Minchan Kim wrote:
> @@ -256,6 +260,125 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
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

Could you put VM_BUG_ON_PAGE(PageTransCompound(page), page) here?
Just in case.

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

Hm. Do we handle pages shared over fork() here?
Souldn't we ignore pages with mapcount > 0?

> +		}
> +
> +		if (pte_young(ptent) || pte_dirty(ptent)) {
> +			/*
> +			 * Some of architecture(ex, PPC) don't update TLB
> +			 * with set_pte_at and tlb_remove_tlb_entry so for
> +			 * the portability, remap the pte with old|clean
> +			 * after pte clearing.
> +			 */
> +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> +							tlb->fullmm);
> +
> +			ptent = pte_mkold(ptent);
> +			ptent = pte_mkclean(ptent);
> +			set_pte_at(mm, addr, pte, ptent);
> +			tlb_remove_tlb_entry(tlb, pte, addr);
> +		}
> +	}
> +
> +	arch_leave_lazy_mmu_mode();
> +	pte_unmap_unlock(pte - 1, ptl);
> +	cond_resched();
> +	return 0;
> +}
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
