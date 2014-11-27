Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D291D6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 10:49:25 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l2so6818172wgh.27
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 07:49:25 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id d6si13661224wiz.67.2014.11.27.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 07:49:24 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so6805948wgh.34
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 07:49:24 -0800 (PST)
Date: Thu, 27 Nov 2014 16:49:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 7/7] mm: Don't split THP page when syscall is called
Message-ID: <20141127154921.GA11051@dhcp22.suse.cz>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413799924-17946-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 20-10-14 19:12:04, Minchan Kim wrote:
> We don't need to split THP page when MADV_FREE syscall is
> called. It could be done when VM decide really frees it so
> we could avoid unnecessary THP split.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Other than a minor comment below
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/huge_mm.h |  4 ++++
>  mm/huge_memory.c        | 35 +++++++++++++++++++++++++++++++++++
>  mm/madvise.c            | 21 ++++++++++++++++++++-
>  mm/rmap.c               |  8 ++++++--
>  mm/vmscan.c             | 28 ++++++++++++++++++----------
>  5 files changed, 83 insertions(+), 13 deletions(-)
> 
[...]
> diff --git a/mm/madvise.c b/mm/madvise.c
> index a21584235bb6..84badee5f46d 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -271,8 +271,26 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	spinlock_t *ptl;
>  	pte_t *pte, ptent;
>  	struct page *page;
> +	unsigned long next;
> +
> +	next = pmd_addr_end(addr, end);
> +	if (pmd_trans_huge(*pmd)) {
> +		if (next - addr != HPAGE_PMD_SIZE) {
> +#ifdef CONFIG_DEBUG_VM
> +			if (!rwsem_is_locked(&mm->mmap_sem)) {
> +				pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
> +					__func__, addr, end,
> +					vma->vm_start,
> +					vma->vm_end);
> +				BUG();
> +			}
> +#endif

Why is this code here? madvise_free_pte_range is called only from the
madvise path and we are holding mmap_sem and relying on that for regular
pages as well.

> +			split_huge_page_pmd(vma, addr, pmd);
> +		} else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
> +			goto next;
> +		/* fall through */
> +	}
>  
> -	split_huge_page_pmd(vma, addr, pmd);
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
>  
> @@ -316,6 +334,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	}
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
> +next:
>  	cond_resched();
>  	return 0;
>  }
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
