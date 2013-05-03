Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A12A86B02EB
	for <linux-mm@kvack.org>; Fri,  3 May 2013 14:49:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 May 2013 04:39:46 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 97E1E2CE804A
	for <linux-mm@kvack.org>; Sat,  4 May 2013 04:49:16 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r43In77723199882
	for <linux-mm@kvack.org>; Sat, 4 May 2013 04:49:09 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r43InD0K030092
	for <linux-mm@kvack.org>; Sat, 4 May 2013 04:49:13 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 08/10] powerpc/THP: Enable THP on PPC64
In-Reply-To: <20130503051528.GT13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367178711-8232-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130503051528.GT13041@truffula.fritz.box>
Date: Sat, 04 May 2013 00:19:03 +0530
Message-ID: <87r4hn5274.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Mon, Apr 29, 2013 at 01:21:49AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We enable only if the we support 16MB page size.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/pgtable-ppc64.h |  3 +--
>>  arch/powerpc/mm/pgtable_64.c             | 28 ++++++++++++++++++++++++++++
>>  2 files changed, 29 insertions(+), 2 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
>> index 97fc839..d65534b 100644
>> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
>> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
>> @@ -426,8 +426,7 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
>>  	return pmd_val(pmd) >> PTE_RPN_SHIFT;
>>  }
>>  
>> -/* We will enable it in the last patch */
>> -#define has_transparent_hugepage() 0
>> +extern int has_transparent_hugepage(void);
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>  
>>  static inline int pmd_young(pmd_t pmd)
>> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
>> index 54216c1..b742d6f 100644
>> --- a/arch/powerpc/mm/pgtable_64.c
>> +++ b/arch/powerpc/mm/pgtable_64.c
>> @@ -754,6 +754,34 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
>>  	return;
>>  }
>>  
>> +int has_transparent_hugepage(void)
>> +{
>> +	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
>> +		return 0;
>> +	/*
>> +	 * We support THP only if HPAGE_SHIFT is 16MB.
>> +	 */
>> +	if (!HPAGE_SHIFT || (HPAGE_SHIFT != mmu_psize_defs[MMU_PAGE_16M].shift))
>> +		return 0;
>
> Again, THP should not be dependent on the value of HPAGE_SHIFT.  Just
> checking that mmu_psize_defsz[MMU_PAGE_16M].shift == 24 should be
> sufficient (i.e. that 16M hugepages are supported).

done

+	/*
+	 * We support THP only if PMD_SIZE is 16MB.
+	 */
+	if (mmu_psize_defs[MMU_PAGE_16M].shift != PMD_SHIFT)
+		return 0;
+	/*


>
>> +	/*
>> +	 * We need to make sure that we support 16MB hugepage in a segement
>> +	 * with base page size 64K or 4K. We only enable THP with a PAGE_SIZE
>> +	 * of 64K.
>> +	 */
>> +	/*
>> +	 * If we have 64K HPTE, we will be using that by default
>> +	 */
>> +	if (mmu_psize_defs[MMU_PAGE_64K].shift &&
>> +	    (mmu_psize_defs[MMU_PAGE_64K].penc[MMU_PAGE_16M] == -1))
>> +		return 0;
>> +	/*
>> +	 * Ok we only have 4K HPTE
>> +	 */
>> +	if (mmu_psize_defs[MMU_PAGE_4K].penc[MMU_PAGE_16M] == -1)
>> +		return 0;
>
> Except you don't actually support THP on 4K base page size yet.


That is 64K linux page size and 4K HPTE . We do support that. The Linux
page size part is taken care by Kconfig. 

>
>> +
>> +	return 1;
>> +}
>>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>  
>>  pmd_t pmdp_get_and_clear(struct mm_struct *mm,
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
