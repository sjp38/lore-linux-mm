Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 734A682F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 08:12:58 -0400 (EDT)
Received: by padfb7 with SMTP id fb7so2336882pad.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 05:12:58 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id de4si36574073pbb.51.2015.10.17.05.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Oct 2015 05:12:57 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 17 Oct 2015 17:42:54 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 902E0E0056
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 17:42:50 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9HCCojr60162132
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 17:42:50 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9HCCnIW030753
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 17:42:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm: clearing pte in clear_soft_dirty()
In-Reply-To: <8352032008c7d9f1eee8d39599888a4cbe570bf7.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com> <8352032008c7d9f1eee8d39599888a4cbe570bf7.1444995096.git.ldufour@linux.vnet.ibm.com>
Date: Sat, 17 Oct 2015 17:42:49 +0530
Message-ID: <87fv19itha.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org
Cc: criu@openvz.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> As mentioned in the commit 56eecdb912b5 ("mm: Use ptep/pmdp_set_numa()
> for updating _PAGE_NUMA bit"), architecture like ppc64 doesn't do
> tlb flush in set_pte/pmd functions.
>
> So when dealing with existing pte in clear_soft_dirty, the pte must
> be cleared before being modified.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> ---
>  fs/proc/task_mmu.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index e2d46adb54b4..c9454ee39b28 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -753,19 +753,20 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
>  	pte_t ptent = *pte;
>
>  	if (pte_present(ptent)) {
> +		ptent = ptep_modify_prot_start(vma->vm_mm, addr, pte);
>  		ptent = pte_wrprotect(ptent);
>  		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
> +		ptep_modify_prot_commit(vma->vm_mm, addr, pte, ptent);
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
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
