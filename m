Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 04C76828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:09:10 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id f1so115089124igr.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:09:10 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [125.16.236.1])
        by mx.google.com with ESMTPS id z69si4805680iod.189.2016.04.13.04.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 04:09:08 -0700 (PDT)
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 13 Apr 2016 16:39:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3DB95Ex13041946
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 16:39:05 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3DB8fsf010824
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 16:38:45 +0530
Message-ID: <570E28B6.708@linux.vnet.ibm.com>
Date: Wed, 13 Apr 2016 16:38:38 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] powerpc/hugetlb: Split the function 'huge_pte_alloc'
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com> <1460007464-26726-6-git-send-email-khandual@linux.vnet.ibm.com> <570BABD8.5080703@gmail.com>
In-Reply-To: <570BABD8.5080703@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 04/11/2016 07:21 PM, Balbir Singh wrote:
> 
> 
> On 07/04/16 15:37, Anshuman Khandual wrote:
>> Currently the function 'huge_pte_alloc' has got two versions, one for the
>> BOOK3S server and the other one for the BOOK3E embedded platforms. This
>> change splits only the BOOK3S server version into two parts, one for the
>> ARCH_WANT_GENERAL_HUGETLB config implementation and the other one for
>> everything else. This change is one of the prerequisites towards enabling
>> ARCH_WANT_GENERAL_HUGETLB config option on POWER platform.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/mm/hugetlbpage.c | 67 +++++++++++++++++++++++++++----------------
>>  1 file changed, 43 insertions(+), 24 deletions(-)
>>
>> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>> index d991b9e..e453918 100644
>> --- a/arch/powerpc/mm/hugetlbpage.c
>> +++ b/arch/powerpc/mm/hugetlbpage.c
>> @@ -59,6 +59,7 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
>>  	return __find_linux_pte_or_hugepte(mm->pgd, addr, NULL, NULL);
>>  }
>>  
>> +#ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
>>  static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>>  			   unsigned long address, unsigned pdshift, unsigned pshift)
>>  {
>> @@ -116,6 +117,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>>  	spin_unlock(&mm->page_table_lock);
>>  	return 0;
>>  }
>> +#endif /* !CONFIG_ARCH_WANT_GENERAL_HUGETLB */
>>  
>>  /*
>>   * These macros define how to determine which level of the page table holds
>> @@ -130,6 +132,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>>  #endif
>>  
>>  #ifdef CONFIG_PPC_BOOK3S_64
>> +#ifndef CONFIG_ARCH_WANT_GENERAL_HUGETLB
>>  /*
>>   * At this point we do the placement change only for BOOK3S 64. This would
>>   * possibly work on other subarchs.
>> @@ -145,32 +148,23 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
>>  
>>  	addr &= ~(sz-1);
>>  	pg = pgd_offset(mm, addr);
>> -
>> -	if (pshift == PGDIR_SHIFT)
>> -		/* 16GB huge page */
>> -		return (pte_t *) pg;
>> -	else if (pshift > PUD_SHIFT)
>> -		/*
>> -		 * We need to use hugepd table
>> -		 */
>> +	if (pshift > PUD_SHIFT) {
>>  		hpdp = (hugepd_t *)pg;
>> -	else {
>> -		pdshift = PUD_SHIFT;
>> -		pu = pud_alloc(mm, pg, addr);
>> -		if (pshift == PUD_SHIFT)
>> -			return (pte_t *)pu;
>> -		else if (pshift > PMD_SHIFT)
>> -			hpdp = (hugepd_t *)pu;
>> -		else {
>> -			pdshift = PMD_SHIFT;
>> -			pm = pmd_alloc(mm, pu, addr);
>> -			if (pshift == PMD_SHIFT)
>> -				/* 16MB hugepage */
>> -				return (pte_t *)pm;
>> -			else
>> -				hpdp = (hugepd_t *)pm;
>> -		}
>> +		goto hugepd_search;
>>  	}
>> +
>> +	pdshift = PUD_SHIFT;
>> +	pu = pud_alloc(mm, pg, addr);
>> +	if (pshift > PMD_SHIFT) {
>> +		hpdp = (hugepd_t *)pu;
>> +		goto hugepd_search;
>> +	}
>> +
>> +	pdshift = PMD_SHIFT;
>> +	pm = pmd_alloc(mm, pu, addr);
>> +	hpdp = (hugepd_t *)pm;
>> +
>> +hugepd_search:
>>  	if (!hpdp)
>>  		return NULL;
>>  
>> @@ -182,6 +176,31 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
>>  	return hugepte_offset(*hpdp, addr, pdshift);
>>  }
>>  
>> +#else /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
>> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> 
> This is confusing, aren't we using the one from mm/hugetlb.c?

We are using huge_pte_alloc() from mm/hugetlb.c only when we have
CONFIG_ARCH_WANT_GENERAL_HUGETLB enabled. For every thing else we
use the definition here for BOOK3S platforms.

> 
>> +{
>> +	pgd_t *pg;
>> +	pud_t *pu;
>> +	pmd_t *pm;
>> +	unsigned pshift = __ffs(sz);
>> +
>> +	addr &= ~(sz-1);
> 
> Am I reading this right? Shouldn't this be addr &= ~(1 << pshift - 1)

Both are same. __ffs() computes the __ilog2 of the size and arrives at
the page shift. Here we use the size directly instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
