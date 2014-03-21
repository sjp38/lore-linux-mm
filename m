Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 707126B0283
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 18:24:21 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id k14so1969456wgh.11
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 15:24:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ef5si2770448wib.79.2014.03.21.15.24.19
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 15:24:20 -0700 (PDT)
Message-ID: <532CBC0C.1080403@redhat.com>
Date: Fri, 21 Mar 2014 18:24:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: numa: Recheck for transhuge pages under lock during
 protection changes
References: <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de> <531F3F15.8050206@oracle.com> <531F4128.8020109@redhat.com> <531F48CC.303@oracle.com> <20140311180652.GM10663@suse.de> <531F616A.7060300@oracle.com> <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org> <20140312103602.GN10663@suse.de> <5323C5D9.2070902@oracle.com> <20140319143831.GA4751@suse.de>
In-Reply-To: <20140319143831.GA4751@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/19/2014 10:38 AM, Mel Gorman wrote:
> On Fri, Mar 14, 2014 at 11:15:37PM -0400, Sasha Levin wrote:
>> On 03/12/2014 06:36 AM, Mel Gorman wrote:
>>> Andrew, this should go with the patches
>>> mmnuma-reorganize-change_pmd_range.patch
>>> mmnuma-reorganize-change_pmd_range-fix.patch
>>> move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
>>> in mmotm please.
>>>
>>> Thanks.
>>>
>>> ---8<---
>>> From: Mel Gorman<mgorman@suse.de>
>>> Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes
>>>
>>> Sasha Levin reported the following bug using trinity
>>
>> I'm seeing a different issue with this patch. A NULL ptr deref occurs in the
>> pte_offset_map_lock() macro right before the new recheck code:
>>
> 
> This on top?
> 
> I tried testing it but got all sorts of carnage that trinity throw up
> in the mix and ordinary testing does not trigger the race. I've no idea
> which of the current mess of trinity-exposed bugs you've encountered and
> got fixed already.

Eeeep indeed.  If we re-test the transhuge status, we need to
take the pmd lock, and not the potentially non-existent pte
lock.

Good catch.

> ---8<---
> From: Mel Gorman <mgorman@suse.de>
> Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes -fix
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

> ---
>  mm/mprotect.c | 40 ++++++++++++++++++++++++++++++----------
>  1 file changed, 30 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 66973db..c43d557 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -36,6 +36,34 @@ static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
>  }
>  #endif
>  
> +/*
> + * For a prot_numa update we only hold mmap_sem for read so there is a
> + * potential race with faulting where a pmd was temporarily none. This
> + * function checks for a transhuge pmd under the appropriate lock. It
> + * returns a pte if it was successfully locked or NULL if it raced with
> + * a transhuge insertion.
> + */
> +static pte_t *lock_pte_protection(struct vm_area_struct *vma, pmd_t *pmd,
> +			unsigned long addr, int prot_numa, spinlock_t **ptl)
> +{
> +	pte_t *pte;
> +	spinlock_t *pmdl;
> +
> +	/* !prot_numa is protected by mmap_sem held for write */
> +	if (!prot_numa)
> +		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
> +
> +	pmdl = pmd_lock(vma->vm_mm, pmd);
> +	if (unlikely(pmd_trans_huge(*pmd) || pmd_none(*pmd))) {
> +		spin_unlock(pmdl);
> +		return NULL;
> +	}
> +
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
> +	spin_unlock(pmdl);
> +	return pte;
> +}
> +
>  static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
>  		int dirty_accountable, int prot_numa)
> @@ -45,17 +73,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	spinlock_t *ptl;
>  	unsigned long pages = 0;
>  
> -	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> -
> -	/*
> -	 * For a prot_numa update we only hold mmap_sem for read so there is a
> -	 * potential race with faulting where a pmd was temporarily none so
> -	 * recheck it under the lock and bail if we race
> -	 */
> -	if (prot_numa && unlikely(pmd_trans_huge(*pmd))) {
> -		pte_unmap_unlock(pte, ptl);
> +	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
> +	if (!pte)
>  		return 0;
> -	}
>  
>  	arch_enter_lazy_mmu_mode();
>  	do {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
