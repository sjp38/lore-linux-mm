Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6146B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 11:07:55 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so19499424wjb.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 08:07:55 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id g29si1456659wra.149.2017.02.06.08.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 08:07:53 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id c85so22764282wmi.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 08:07:53 -0800 (PST)
Date: Mon, 6 Feb 2017 19:07:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Message-ID: <20170206160751.GA29962@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170205161252.85004-4-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, mgorman@techsingularity.net, riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
> 
> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
> This can cause pmd_protnone entry not being freed.
> 
> Because there are two steps in changing a pmd entry to a pmd_protnone
> entry. First, the pmd entry is cleared to a pmd_none entry, then,
> the pmd_none entry is changed into a pmd_protnone entry.
> The racy check, even with barrier, might only see the pmd_none entry
> in zap_pmd_range(), thus, the mapping is neither split nor zapped.

That's definately a good catch.

But I don't agree with the solution. Taking pmd lock on each
zap_pmd_range() is a significant hit by scalability of the code path.
Yes, split ptl lock helps, but it would be nice to avoid the lock in first
place.

Can we fix change_huge_pmd() instead? Is there a reason why we cannot
setup the pmd_protnone() atomically?

Mel? Rik?

> 
> Later, in free_pmd_range(), pmd_none_or_clear() will see the
> pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
> since the pmd_protnone entry is not properly freed, the corresponding
> deposited pte page table is not freed either.
> 
> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.
> 
> This patch relies on __split_huge_pmd_locked() and
> __zap_huge_pmd_locked().
> 
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  mm/memory.c | 24 +++++++++++-------------
>  1 file changed, 11 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 3929b015faf7..7cfdd5208ef5 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1233,33 +1233,31 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>  				struct zap_details *details)
>  {
>  	pmd_t *pmd;
> +	spinlock_t *ptl;
>  	unsigned long next;
>  
>  	pmd = pmd_offset(pud, addr);
> +	ptl = pmd_lock(vma->vm_mm, pmd);
>  	do {
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE) {
>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
> -				__split_huge_pmd(vma, pmd, addr, false, NULL);
> -			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
> -				goto next;
> +				__split_huge_pmd_locked(vma, pmd, addr, false);
> +			} else if (__zap_huge_pmd_locked(tlb, vma, pmd, addr))
> +				continue;
>  			/* fall through */
>  		}
> -		/*
> -		 * Here there can be other concurrent MADV_DONTNEED or
> -		 * trans huge page faults running, and if the pmd is
> -		 * none or trans huge it can change under us. This is
> -		 * because MADV_DONTNEED holds the mmap_sem in read
> -		 * mode.
> -		 */
> -		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> -			goto next;
> +
> +		if (pmd_none_or_clear_bad(pmd))
> +			continue;
> +		spin_unlock(ptl);
>  		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
> -next:
>  		cond_resched();
> +		spin_lock(ptl);
>  	} while (pmd++, addr = next, addr != end);
> +	spin_unlock(ptl);
>  
>  	return addr;
>  }
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
