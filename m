Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1ED66B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:50:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k68so5899416wmd.14
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 03:50:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q30si10272314wra.202.2017.07.27.03.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 03:50:34 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RAmgYx078549
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:50:32 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bycygd7e7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:50:32 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 06:50:32 -0400
Subject: Re: [RFC PATCH 3/3] mm/hugetlb: Remove pmd_huge_split_prepare
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727083756.32217-3-aneesh.kumar@linux.vnet.ibm.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 16:20:25 +0530
MIME-Version: 1.0
In-Reply-To: <20170727083756.32217-3-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <912dcb7d-4dff-979a-3777-2e9e13a7adda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



On 07/27/2017 02:07 PM, Aneesh Kumar K.V wrote:

> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index 8c8fb6fbdabe..b856e130c678 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -164,8 +164,6 @@ extern pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma,
>   extern void hash__pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>   					 pgtable_t pgtable);
>   extern pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
> -extern void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
> 
> @@ -1956,14 +1956,39 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   		return __split_huge_zero_page_pmd(vma, haddr, pmd);
>   	}
> 


....

> +	 */
> +	old_pmd = pmdp_invalidate(vma, haddr, pmd);
> +
> +	page = pmd_page(old_pmd);
>   	VM_BUG_ON_PAGE(!page_count(page), page);
>   	page_ref_add(page, HPAGE_PMD_NR - 1);
> -	write = pmd_write(*pmd);
> -	young = pmd_young(*pmd);
> -	soft_dirty = pmd_soft_dirty(*pmd);
> -
> -	pmdp_huge_split_prepare(vma, haddr, pmd);
> +	write = pmd_write(old_pmd);
> +	young = pmd_young(old_pmd);
> +	dirty = pmd_dirty(*pmd);

This should be

	dirty = pmd_dirty(old_pmd);


> +	soft_dirty = pmd_soft_dirty(old_pmd);
> +	/*
> +	 * withdraw the table only after we mark the pmd entry invalid
> +	 */
>   	pgtable = pgtable_trans_huge_withdraw(mm, pmd);

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
