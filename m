Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2DD76B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:39:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d186so43910442lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:39:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ia7si16273411wjb.123.2016.10.13.01.39.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 01:39:14 -0700 (PDT)
Date: Thu, 13 Oct 2016 09:39:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] Don't touch single threaded PTEs which are on the right
 node
Message-ID: <20161013083910.GC20573@suse.de>
References: <1476288949-20970-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1476288949-20970-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: peterz@infradead.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

On Wed, Oct 12, 2016 at 09:15:49AM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> We had some problems with pages getting unmapped in single threaded
> affinitized processes. It was tracked down to NUMA scanning.
> 
> In this case it doesn't make any sense to unmap pages if the
> process is single threaded and the page is already on the
> node the process is running on.
> 
> Add a check for this case into the numa protection code,
> and skip unmapping if true.
> 
> In theory the process could be migrated later, but we
> will eventually rescan and unmap and migrate then.
> 
> In theory this could be made more fancy: remembering this
> state per process or even whole mm. However that would
> need extra tracking and be more complicated, and the
> simple check seems to work fine so far.
> 
> v2: Only do it for private VMAs. Move most of check out of
> loop.
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Minor comments

> ---
>  mm/mprotect.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a4830f0325fe..e9473e7e1468 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -68,11 +68,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	pte_t *pte, oldpte;
>  	spinlock_t *ptl;
>  	unsigned long pages = 0;
> +	int target_node = -1;
>  

Proper convention is to use NUMA_NO_NODE instead of -1 although it's not
always adhered to.

>  	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
>  	if (!pte)
>  		return 0;
>  
> +	if (prot_numa &&
> +	    !(vma->vm_flags & VM_SHARED) &&
> +	    atomic_read(&vma->vm_mm->mm_users) == 1)
> +	    target_node = cpu_to_node(raw_smp_processor_id());
> +

Use numa_node_id() instead of open-coding this. A short comment probably
would not hurt even if git blame should make it obvious.

>  	arch_enter_lazy_mmu_mode();
>  	do {
>  		oldpte = *pte;
> @@ -94,6 +100,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				/* Avoid TLB flush if possible */
>  				if (pte_protnone(oldpte))
>  					continue;
> +
> +				/*
> +				 * Don't mess with PTEs if page is already on the node
> +				 * a single-threaded process is running on.
> +				 */
> +				if (target_node == page_to_nid(page))
> +					continue;
>  			}
>  

Check target_node != NUMA_NODE && target_node == page_to_nid(page) to
avoid unnecessary page->flag masking and shifts?

The last one will be fairly marginal, the others are taste so whether
you spin a v3 with the corrections or not;

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
