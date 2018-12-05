Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09C886B724E
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 22:58:02 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so14233023wrq.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 19:58:01 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x2si13277258wrg.450.2018.12.04.19.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 19:58:00 -0800 (PST)
Subject: Re: [PATCH V3 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for
 hugetlb mprotect RW upgrade
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
 <20181205030931.12037-6-aneesh.kumar@linux.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <3b87e008-eb08-f41c-ef70-1986360c5df9@c-s.fr>
Date: Wed, 5 Dec 2018 04:57:58 +0100
MIME-Version: 1.0
In-Reply-To: <20181205030931.12037-6-aneesh.kumar@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org



Le 05/12/2018 à 04:09, Aneesh Kumar K.V a écrit :
> NestMMU requires us to mark the pte invalid and flush the tlb when we do a
> RW upgrade of pte. We fixed a variant of this in the fault path in commit
> Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>   arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++
>   arch/powerpc/mm/hugetlbpage-radix.c          | 17 ++++++++++++
>   arch/powerpc/mm/hugetlbpage.c                | 29 ++++++++++++++++++++
>   3 files changed, 58 insertions(+)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 5b0177733994..66c1e4f88d65 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -13,6 +13,10 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>   				unsigned long len, unsigned long pgoff,
>   				unsigned long flags);
>   
> +extern void radix__huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
> +						unsigned long addr, pte_t *ptep,
> +						pte_t old_pte, pte_t pte);
> +
>   static inline int hstate_get_psize(struct hstate *hstate)
>   {
>   	unsigned long shift;
> @@ -42,4 +46,12 @@ static inline bool gigantic_page_supported(void)
>   /* hugepd entry valid bit */
>   #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
>   
> +#define huge_ptep_modify_prot_start huge_ptep_modify_prot_start
> +extern pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
> +					 unsigned long addr, pte_t *ptep);
> +
> +#define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
> +extern void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
> +					 unsigned long addr, pte_t *ptep,
> +					 pte_t old_pte, pte_t new_pte);
>   #endif
> diff --git a/arch/powerpc/mm/hugetlbpage-radix.c b/arch/powerpc/mm/hugetlbpage-radix.c
> index 2486bee0f93e..11d9ea28a816 100644
> --- a/arch/powerpc/mm/hugetlbpage-radix.c
> +++ b/arch/powerpc/mm/hugetlbpage-radix.c
> @@ -90,3 +90,20 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>   
>   	return vm_unmapped_area(&info);
>   }
> +
> +void radix__huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
> +					 unsigned long addr, pte_t *ptep,
> +					 pte_t old_pte, pte_t pte)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	/*
> +	 * To avoid NMMU hang while relaxing access we need to flush the tlb before
> +	 * we set the new value.
> +	 */
> +	if (is_pte_rw_upgrade(pte_val(old_pte), pte_val(pte)) &&
> +	    (atomic_read(&mm->context.copros) > 0))
> +		radix__flush_hugetlb_page(vma, addr);
> +
> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 8cf035e68378..39d33a3d0dc6 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -912,3 +912,32 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
>   
>   	return 1;
>   }
> +
> +#ifdef CONFIG_PPC_BOOK3S_64

Could this go in hugetlbpage-hash64.c instead to avoid the #ifdef sequence ?

Christophe

> +pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
> +				  unsigned long addr, pte_t *ptep)
> +{
> +	unsigned long pte_val;
> +	/*
> +	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
> +	 * possible. Also keep the pte_present true so that we don't take
> +	 * wrong fault.
> +	 */
> +	pte_val = pte_update(vma->vm_mm, addr, ptep,
> +			     _PAGE_PRESENT, _PAGE_INVALID, 1);
> +
> +	return __pte(pte_val);
> +}
> +EXPORT_SYMBOL(huge_ptep_modify_prot_start);
> +
> +void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> +				  pte_t *ptep, pte_t old_pte, pte_t pte)
> +{
> +
> +	if (radix_enabled())
> +		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
> +							   old_pte, pte);
> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> +EXPORT_SYMBOL(huge_ptep_modify_prot_commit);
> +#endif
> 
