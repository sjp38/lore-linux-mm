Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id A376D82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:00:23 -0400 (EDT)
Received: by vkaw128 with SMTP id w128so69790933vka.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:00:23 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id t200si4902979vke.171.2015.10.16.08.00.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Oct 2015 08:00:20 -0700 (PDT)
Message-ID: <1445007605.24309.25.camel@kernel.crashing.org>
Subject: Re: [PATCH 1/3] mm: clearing pte in clear_soft_dirty()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 16 Oct 2015 20:30:05 +0530
In-Reply-To: <8352032008c7d9f1eee8d39599888a4cbe570bf7.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
	 <8352032008c7d9f1eee8d39599888a4cbe570bf7.1444995096.git.ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org
Cc: criu@openvz.org

On Fri, 2015-10-16 at 14:07 +0200, Laurent Dufour wrote:
> As mentioned in the commit 56eecdb912b5 ("mm: Use
> ptep/pmdp_set_numa()
> for updating _PAGE_NUMA bit"), architecture like ppc64 doesn't do
> tlb flush in set_pte/pmd functions.
> 
> So when dealing with existing pte in clear_soft_dirty, the pte must
> be cleared before being modified.

Note that this is true of more than powerpc afaik. There's is a general
rule that we don't "restrict" a PTE access permissions without first
clearing it, due to various races.

> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/proc/task_mmu.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index e2d46adb54b4..c9454ee39b28 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -753,19 +753,20 @@ static inline void clear_soft_dirty(struct
> vm_area_struct *vma,
>  	pte_t ptent = *pte;
>  
>  	if (pte_present(ptent)) {
> +		ptent = ptep_modify_prot_start(vma->vm_mm, addr,
> pte);
>  		ptent = pte_wrprotect(ptent);
>  		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
> +		ptep_modify_prot_commit(vma->vm_mm, addr, pte,
> ptent);
>  	} else if (is_swap_pte(ptent)) {
>  		ptent = pte_swp_clear_soft_dirty(ptent);
> +		set_pte_at(vma->vm_mm, addr, pte, ptent);
>  	}
> -
> -	set_pte_at(vma->vm_mm, addr, pte, ptent);
>  }
>  
>  static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
>  		unsigned long addr, pmd_t *pmdp)
>  {
> -	pmd_t pmd = *pmdp;
> +	pmd_t pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
>  
>  	pmd = pmd_wrprotect(pmd);
>  	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
