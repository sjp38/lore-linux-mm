Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 877766B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 03:09:14 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d123so139266812pfd.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:09:14 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id a3si3315452pln.255.2017.02.07.00.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 00:09:13 -0800 (PST)
Subject: Re: [PATCH] mm/autonuma: don't use set_pte_at when updating protnone
 ptes
References: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <def8ae31-0a03-7e0d-06fc-48c4d946820c@nvidia.com>
Date: Tue, 7 Feb 2017 00:09:12 -0800
MIME-Version: 1.0
In-Reply-To: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/06/2017 09:06 AM, Aneesh Kumar K.V wrote:
> Architectures like ppc64, use privilege access bit to mark pte non accessible.
> This implies that kernel can do a copy_to_user to an address marked for numa fault.
> This also implies that there can be a parallel hardware update for the pte.
> set_pte_at cannot be used in such scenarios. Hence switch the pte
> update to use ptep_get_and_clear and set_pte_at combination.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/pgtable.c |  7 +------
>  mm/memory.c               | 18 +++++++++---------
>  2 files changed, 10 insertions(+), 15 deletions(-)
>
> diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
> index cb39c8bd2436..b8ac81a16389 100644
> --- a/arch/powerpc/mm/pgtable.c
> +++ b/arch/powerpc/mm/pgtable.c
> @@ -186,12 +186,7 @@ static pte_t set_access_flags_filter(pte_t pte, struct vm_area_struct *vma,
>  void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
>  		pte_t pte)
>  {
> -	/*
> -	 * When handling numa faults, we already have the pte marked
> -	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
> -	 * Hence we can use set_pte_at for them.
> -	 */
> -	VM_WARN_ON(pte_present(*ptep) && !pte_protnone(*ptep));
> +	VM_WARN_ON(pte_present(*ptep));
>
>  	/*
>  	 * Add the pte bit when tryint set a pte
> diff --git a/mm/memory.c b/mm/memory.c
> index 6bf2b471e30c..e78bf72f30dd 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3387,32 +3387,32 @@ static int do_numa_page(struct vm_fault *vmf)
>  	int last_cpupid;
>  	int target_nid;
>  	bool migrated = false;
> -	pte_t pte = vmf->orig_pte;
> -	bool was_writable = pte_write(pte);
> +	pte_t pte;
> +	bool was_writable = pte_write(vmf->orig_pte);
>  	int flags = 0;
>
>  	/*
>  	* The "pte" at this point cannot be used safely without
>  	* validation through pte_unmap_same(). It's of NUMA type but
>  	* the pfn may be screwed if the read is non atomic.

The entire comment is now stale, so maybe it's best to delete the above lines (and 
thus the entire comment block). "pte" refers, at this point, to an uninitialized 
variable.

> -	*
> -	* We can safely just do a "set_pte_at()", because the old
> -	* page table entry is not accessible, so there would be no
> -	* concurrent hardware modifications to the PTE.
>  	*/
>  	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
>  	spin_lock(vmf->ptl);
> -	if (unlikely(!pte_same(*vmf->pte, pte))) {
> +	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>  		goto out;
>  	}
>
> -	/* Make it present again */
> +	/*
> +	 * Make it present again, Depending on how arch implementes non
> +	 * accessible ptes, some can allow access by kernel mode.

I'd be inclined to leave the original comment unchanged. But if you wanted more, 
hHow about this wording, instead:

	/*
	 * Make it present again. Because some architectures allow hardware to
	 * change the pte here, wrap the pte changes in a read-modify-write
	 * transaction that protects against asynchronous hardware modifications
	 * to the pte.
	 */

...which is nearly the same wording as you'll find in the documentation for 
ptep_modify_prot_start, which brings us back to: maybe the extended comment is 
unnecessary.


thanks,
john h

> +	 */
> +	pte = ptep_modify_prot_start(vma->vm_mm, vmf->address, vmf->pte);
>  	pte = pte_modify(pte, vma->vm_page_prot);
>  	pte = pte_mkyoung(pte);
>  	if (was_writable)
>  		pte = pte_mkwrite(pte);
> -	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
> +	ptep_modify_prot_commit(vma->vm_mm, vmf->address, vmf->pte, pte);
>  	update_mmu_cache(vma, vmf->address, vmf->pte);
>
>  	page = vm_normal_page(vma, vmf->address, pte);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
