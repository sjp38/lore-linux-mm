Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8891D6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:41:29 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so4450450pdi.32
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:41:29 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id yv3si13744280pac.77.2014.06.16.06.41.28
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 06:41:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
References: <1402676778-27174-1-git-send-email-chris@chris-wilson.co.uk>
Subject: RE: [PATCH 1/2] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Content-Transfer-Encoding: 7bit
Message-Id: <20140616134124.0ED73E00A2@blue.fi.intel.com>
Date: Mon, 16 Jun 2014 16:41:24 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Chris Wilson wrote:
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

I think you need at least remove entries you've setup if the check failed not
at first iteration.

And nobody propagate your -EBUSY back to remap_pfn_range(): caller will
see -ENOMEM, which is not what you want, I believe.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
