Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id B55406B0035
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:34:59 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so3075073wes.32
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:34:59 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id gg4si7471611wjd.15.2014.06.13.09.34.57
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:34:58 -0700 (PDT)
Date: Fri, 13 Jun 2014 17:34:54 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 1/2] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Message-ID: <20140613163454.GM6451@nuc-i3427.alporthouse.com>
References: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri, Jun 13, 2014 at 05:26:17PM +0100, Chris Wilson wrote:
> When using remap_pfn_range() from a fault handler, we are exposed to
> races between concurrent faults. Rather than hitting a BUG, report the
> error back to the caller, like vm_insert_pfn().
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> ---
>  mm/memory.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 037b812a9531..6603a9e6a731 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2306,19 +2306,23 @@ static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
>  {
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	int ret = 0;
>  
>  	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte)
>  		return -ENOMEM;
>  	arch_enter_lazy_mmu_mode();
>  	do {
> -		BUG_ON(!pte_none(*pte));
> +		if (!pte_none(*pte)) {
> +			ret = -EBUSY;
> +			break;
> +		}
>  		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
>  		pfn++;
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);

Oh. That will want the EBUSY path to increment pte or we will try to
unmap the wrong page.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
