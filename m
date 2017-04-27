Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6706F6B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 22:52:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p133so409689wmd.17
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 19:52:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j19si1230299wra.238.2017.04.26.19.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 19:52:20 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3R2nCsY133725
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 22:52:19 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a2xenevwe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 22:52:19 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 12:52:16 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3R2q5F254984780
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:52:13 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3R2pZow031272
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 12:51:36 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] powerpc/mm/hugetlb: Add support for 1G huge pages
In-Reply-To: <2ccc1911-ff33-d0fd-195d-44ed4b8d1fb3@linux.vnet.ibm.com>
References: <1492449255-29062-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <2ccc1911-ff33-d0fd-195d-44ed4b8d1fb3@linux.vnet.ibm.com>
Date: Thu, 27 Apr 2017 08:21:17 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87o9vi1s2i.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:

> On 04/17/2017 10:44 PM, Aneesh Kumar K.V wrote:
>> POWER9 supports hugepages of size 2M and 1G in radix MMU mode. This patch
>> enables the usage of 1G page size for hugetlbfs. This also update the helper
>> such we can do 1G page allocation at runtime.
>> 
>> Since we can do this only when radix translation mode is enabled, we can't use
>> the generic gigantic_page_supported helper. Hence provide a way for architecture
>> to override gigantic_page_supported helper.
>> 
>> We still don't enable 1G page size on DD1 version. This is to avoid doing
>> workaround mentioned in commit: 6d3a0379ebdc8 (powerpc/mm: Add
>> radix__tlb_flush_pte_p9_dd1()
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/include/asm/book3s/64/hugetlb.h | 13 +++++++++++++
>>  arch/powerpc/mm/hugetlbpage.c                |  7 +++++--
>>  arch/powerpc/platforms/Kconfig.cputype       |  1 +
>>  mm/hugetlb.c                                 |  4 ++++
>>  4 files changed, 23 insertions(+), 2 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> index 6666cd366596..86f27cc8ec61 100644
>> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>> @@ -50,4 +50,17 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>>  	else
>>  		return entry;
>>  }
>> +
>> +#if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) &&				\
>> +	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
>> +	 defined(CONFIG_CMA))
>> +#define gigantic_page_supported gigantic_page_supported
>
> As I have mentioned in later part of the reply, it does not really
> make sense to have both arch call back as well as generic config
> option checking to decide on whether a feature is enabled or not.
>
>> +static inline bool gigantic_page_supported(void)
>> +{
>> +	if (radix_enabled())
>> +		return true;
>> +	return false;
>> +}
>> +#endif
>> +
>>  #endif
>> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>> index a4f33de4008e..80f6d2ed551a 100644
>> --- a/arch/powerpc/mm/hugetlbpage.c
>> +++ b/arch/powerpc/mm/hugetlbpage.c
>> @@ -763,8 +763,11 @@ static int __init add_huge_page_size(unsigned long long size)
>>  	 * Hash: 16M and 16G
>>  	 */
>>  	if (radix_enabled()) {
>> -		if (mmu_psize != MMU_PAGE_2M)
>> -			return -EINVAL;
>> +		if (mmu_psize != MMU_PAGE_2M) {
>> +			if (cpu_has_feature(CPU_FTR_POWER9_DD1) ||
>> +			    (mmu_psize != MMU_PAGE_1G))
>> +				return -EINVAL;
>> +		}
>>  	} else {
>>  		if (mmu_psize != MMU_PAGE_16M && mmu_psize != MMU_PAGE_16G)
>>  			return -EINVAL;
>> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
>> index ef4c4b8fc547..f4ba4bf0d762 100644
>> --- a/arch/powerpc/platforms/Kconfig.cputype
>> +++ b/arch/powerpc/platforms/Kconfig.cputype
>> @@ -343,6 +343,7 @@ config PPC_STD_MMU_64
>>  config PPC_RADIX_MMU
>>  	bool "Radix MMU Support"
>>  	depends on PPC_BOOK3S_64
>> +	select ARCH_HAS_GIGANTIC_PAGE
>>  	default y
>>  	help
>
> As we are already checking for radix_enabled() test inside function
> gigantic_page_supported(), do we still need to conditionally enable
> this on Radix based platforms only ?
>
>
>>  	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 3d0aab9ee80d..2c090189f314 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1158,7 +1158,11 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
>>  	return 0;
>>  }
>>  
>> +#ifndef gigantic_page_supported
>>  static inline bool gigantic_page_supported(void) { return true; }
>> +#define gigantic_page_supported gigantic_page_supported
>> +#endif
>
> As seen above, now that arch's decision to support this feature is not
> based solely on ARCH_HAS_GIGANTIC_PAGE config option but also on the
> availability of platform features like radix, is it a good time to have
> an arch call back deciding on gigantic_page_supported() test instead of
> just checking presence of config options like 
>
> #if defined(CONFIG_ARCH_HAS_GIGANTIC_PAGE) && \
> 	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
> 	defined(CONFIG_CMA))
>
> We should not have both as proposed. I mean CONFIG_ARCH_HAS_GIGANTIC_PAGE
> should not be enabled unless we have MEMORY_ISOLATION && COMPACTION && CMA
> and once enabled we should have arch_gigantic_page_supported() deciding for
> gigantic_page_supported().

I will update the patch. I guess I can also fixup other arch that enable
GIGANTIC_PAGE accordingly.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
