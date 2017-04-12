Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF4246B0397
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:45:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p81so9707895pfd.12
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 22:45:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 193si10782095pgb.146.2017.04.11.22.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 22:45:27 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3C5hYmO083909
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:45:26 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29s91jat94-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:45:26 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Apr 2017 15:45:24 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3C5jE8M38076506
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 15:45:22 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3C5ioFq010526
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 15:44:50 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/9] mm/huge_memory: Use zap_deposited_table() more
In-Reply-To: <20170411174233.21902-2-oohall@gmail.com>
References: <20170411174233.21902-1-oohall@gmail.com> <20170411174233.21902-2-oohall@gmail.com>
Date: Wed, 12 Apr 2017 11:14:30 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <878tn6qiwx.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: arbab@linux.vnet.ibm.com, bsingharora@gmail.com, linux-nvdimm@lists.01.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

Oliver O'Halloran <oohall@gmail.com> writes:

> Depending flags of the PMD being zapped there may or may not be a
> deposited pgtable to be freed. In two of the three cases this is open
> coded while the third uses the zap_deposited_table() helper. This patch
> converts the others to use the helper to clean things up a bit.
>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> ---
> For reference:
>
> void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
> {
>         pgtable_t pgtable;
>
>         pgtable = pgtable_trans_huge_withdraw(mm, pmd);
>         pte_free(mm, pgtable);
>         atomic_long_dec(&mm->nr_ptes);
> }
> ---
>  mm/huge_memory.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b787c4cfda0e..aa01dd47cc65 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1615,8 +1615,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		if (is_huge_zero_pmd(orig_pmd))
>  			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>  	} else if (is_huge_zero_pmd(orig_pmd)) {
> -		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
> -		atomic_long_dec(&tlb->mm->nr_ptes);
> +		zap_deposited_table(tlb->mm, pmd);
>  		spin_unlock(ptl);
>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>  	} else {
> @@ -1625,10 +1624,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
>  		VM_BUG_ON_PAGE(!PageHead(page), page);
>  		if (PageAnon(page)) {
> -			pgtable_t pgtable;
> -			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
> -			pte_free(tlb->mm, pgtable);
> -			atomic_long_dec(&tlb->mm->nr_ptes);
> +			zap_deposited_table(tlb->mm, pmd);
>  			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
>  		} else {
>  			if (arch_needs_pgtable_deposit())
> -- 
> 2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
