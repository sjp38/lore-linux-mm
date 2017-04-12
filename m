Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C489F6B0397
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:51:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p97so1835418wrb.20
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 22:51:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w101si825535wrc.161.2017.04.11.22.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 22:51:46 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3C5mXes142219
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:51:45 -0400
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29ru2u23eb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:51:44 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Apr 2017 11:21:41 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3C5oId115859900
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 11:20:18 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3C5pc80012552
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 11:21:38 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/9] mm/huge_memory: Deposit a pgtable for DAX PMD faults when required
In-Reply-To: <20170411174233.21902-3-oohall@gmail.com>
References: <20170411174233.21902-1-oohall@gmail.com> <20170411174233.21902-3-oohall@gmail.com>
Date: Wed, 12 Apr 2017 11:21:35 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8760iaqil4.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: arbab@linux.vnet.ibm.com, bsingharora@gmail.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org

Oliver O'Halloran <oohall@gmail.com> writes:

> Although all architectures use a deposited page table for THP on anonymous VMAs
> some architectures (s390 and powerpc) require the deposited storage even for
> file backed VMAs due to quirks of their MMUs. This patch adds support for
> depositing a table in DAX PMD fault handling path for archs that require it.
> Other architectures should see no functional changes.
>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


> ---
>  mm/huge_memory.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index aa01dd47cc65..a84909cf20d3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -715,7 +715,8 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
>  }
>
>  static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> -		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write)
> +		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write,
> +		pgtable_t pgtable)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pmd_t entry;
> @@ -729,6 +730,12 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		entry = pmd_mkyoung(pmd_mkdirty(entry));
>  		entry = maybe_pmd_mkwrite(entry, vma);
>  	}
> +
> +	if (pgtable) {
> +		pgtable_trans_huge_deposit(mm, pmd, pgtable);
> +		atomic_long_inc(&mm->nr_ptes);
> +	}
> +
>  	set_pmd_at(mm, addr, pmd, entry);
>  	update_mmu_cache_pmd(vma, addr, pmd);
>  	spin_unlock(ptl);
> @@ -738,6 +745,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  			pmd_t *pmd, pfn_t pfn, bool write)
>  {
>  	pgprot_t pgprot = vma->vm_page_prot;
> +	pgtable_t pgtable = NULL;
>  	/*
>  	 * If we had pmd_special, we could avoid all these restrictions,
>  	 * but we need to be consistent with PTEs and architectures that
> @@ -752,9 +760,15 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  	if (addr < vma->vm_start || addr >= vma->vm_end)
>  		return VM_FAULT_SIGBUS;
>
> +	if (arch_needs_pgtable_deposit()) {
> +		pgtable = pte_alloc_one(vma->vm_mm, addr);
> +		if (!pgtable)
> +			return VM_FAULT_OOM;
> +	}
> +
>  	track_pfn_insert(vma, &pgprot, pfn);
>
> -	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
> +	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write, pgtable);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(vmf_insert_pfn_pmd);
> @@ -1611,6 +1625,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			tlb->fullmm);
>  	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>  	if (vma_is_dax(vma)) {
> +		if (arch_needs_pgtable_deposit())
> +			zap_deposited_table(tlb->mm, pmd);
>  		spin_unlock(ptl);
>  		if (is_huge_zero_pmd(orig_pmd))
>  			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
> -- 
> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
