Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC3F56B7252
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 23:02:59 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id d11so14238466wrq.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 20:02:59 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q15si9381987wmf.199.2018.12.04.20.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 20:02:58 -0800 (PST)
Subject: Re: [PATCH V3 2/5] mm: update ptep_modify_prot_commit to take old pte
 value as arg
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
 <20181205030931.12037-3-aneesh.kumar@linux.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <f446afd3-a77d-cc5a-1ac8-3992090bcd7d@c-s.fr>
Date: Wed, 5 Dec 2018 05:02:56 +0100
MIME-Version: 1.0
In-Reply-To: <20181205030931.12037-3-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org



Le 05/12/2018 à 04:09, Aneesh Kumar K.V a écrit :
> Architectures like ppc64 requires to do a conditional tlb flush based on the old
> and new value of pte. Enable that by passing old pte value as the arg.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>   arch/s390/include/asm/pgtable.h | 3 ++-
>   arch/s390/mm/pgtable.c          | 2 +-
>   arch/x86/include/asm/paravirt.h | 2 +-
>   fs/proc/task_mmu.c              | 8 +++++---
>   include/asm-generic/pgtable.h   | 2 +-
>   mm/memory.c                     | 8 ++++----
>   mm/mprotect.c                   | 6 +++---
>   7 files changed, 17 insertions(+), 14 deletions(-)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 5d730199e37b..76dc344edb8c 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1070,7 +1070,8 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
>   
>   #define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
>   pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
> -void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long, pte_t *, pte_t);
> +void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
> +			     pte_t *, pte_t, pte_t);
>   
>   #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
>   static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index 29c0a21cd34a..b283b92722cc 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -322,7 +322,7 @@ pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
>   EXPORT_SYMBOL(ptep_modify_prot_start);
>   
>   void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> -			     pte_t *ptep, pte_t pte)
> +			     pte_t *ptep, pte_t old_pte, pte_t pte)
>   {
>   	pgste_t pgste;
>   	struct mm_struct *mm = vma->vm_mm;
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> index 1154f154025d..0d75a4f60500 100644
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -429,7 +429,7 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned
>   }
>   
>   static inline void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> -					   pte_t *ptep, pte_t pte)
> +					   pte_t *ptep, pte_t old_pte, pte_t pte)
>   {
>   	struct mm_struct *mm = vma->vm_mm;
>   
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 9952d7185170..8d62891d38a8 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -940,10 +940,12 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
>   	pte_t ptent = *pte;
>   
>   	if (pte_present(ptent)) {
> -		ptent = ptep_modify_prot_start(vma, addr, pte);
> -		ptent = pte_wrprotect(ptent);
> +		pte_t old_pte;
> +
> +		old_pte = ptep_modify_prot_start(vma, addr, pte);
> +		ptent = pte_wrprotect(old_pte);

This change doesn't seem to fit with the commit description. Why write 
protecting in addition to clearing dirty ?

Christophe

>   		ptent = pte_clear_soft_dirty(ptent);
> -		ptep_modify_prot_commit(vma, addr, pte, ptent);
> +		ptep_modify_prot_commit(vma, addr, pte, old_pte, ptent);
>   	} else if (is_swap_pte(ptent)) {
>   		ptent = pte_swp_clear_soft_dirty(ptent);
>   		set_pte_at(vma->vm_mm, addr, pte, ptent);
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index c9897dcc46c4..37039e918f17 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -619,7 +619,7 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma,
>    */
>   static inline void ptep_modify_prot_commit(struct vm_area_struct *vma,
>   					   unsigned long addr,
> -					   pte_t *ptep, pte_t pte)
> +					   pte_t *ptep, pte_t old_pte, pte_t pte)
>   {
>   	__ptep_modify_prot_commit(vma->vm_mm, addr, ptep, pte);
>   }
> diff --git a/mm/memory.c b/mm/memory.c
> index d36b0eaa7862..4f3ddaedc764 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3568,7 +3568,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
>   	int last_cpupid;
>   	int target_nid;
>   	bool migrated = false;
> -	pte_t pte;
> +	pte_t pte, old_pte;
>   	bool was_writable = pte_savedwrite(vmf->orig_pte);
>   	int flags = 0;
>   
> @@ -3588,12 +3588,12 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
>   	 * Make it present again, Depending on how arch implementes non
>   	 * accessible ptes, some can allow access by kernel mode.
>   	 */
> -	pte = ptep_modify_prot_start(vma, vmf->address, vmf->pte);
> -	pte = pte_modify(pte, vma->vm_page_prot);
> +	old_pte = ptep_modify_prot_start(vma, vmf->address, vmf->pte);
> +	pte = pte_modify(old_pte, vma->vm_page_prot);
>   	pte = pte_mkyoung(pte);
>   	if (was_writable)
>   		pte = pte_mkwrite(pte);
> -	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, pte);
> +	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, old_pte, pte);
>   	update_mmu_cache(vma, vmf->address, vmf->pte);
>   
>   	page = vm_normal_page(vma, vmf->address, pte);
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a301d4c83d3c..1b46b1b1248d 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -110,8 +110,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>   					continue;
>   			}
>   
> -			ptent = ptep_modify_prot_start(vma, addr, pte);
> -			ptent = pte_modify(ptent, newprot);
> +			oldpte = ptep_modify_prot_start(vma, addr, pte);
> +			ptent = pte_modify(oldpte, newprot);
>   			if (preserve_write)
>   				ptent = pte_mk_savedwrite(ptent);
>   
> @@ -121,7 +121,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>   					 !(vma->vm_flags & VM_SOFTDIRTY))) {
>   				ptent = pte_mkwrite(ptent);
>   			}
> -			ptep_modify_prot_commit(vma, addr, pte, ptent);
> +			ptep_modify_prot_commit(vma, addr, pte, oldpte, ptent);
>   			pages++;
>   		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
>   			swp_entry_t entry = pte_to_swp_entry(oldpte);
> 
