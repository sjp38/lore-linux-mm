Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2A56B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:17:03 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j65-v6so5269960otc.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:17:03 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d15si9688402oti.61.2018.10.10.20.17.01
        for <linux-mm@kvack.org>;
        Wed, 10 Oct 2018 20:17:01 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <20181003065833.GD18290@dhcp22.suse.cz>
 <7f0488b5-053f-0954-9b95-8c0890ef5597@arm.com>
 <20181003105926.GA4714@dhcp22.suse.cz>
 <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
 <20181003114842.GD4714@dhcp22.suse.cz>
 <d42cc88b-6bab-797c-f263-2dce650ea3ab@arm.com>
 <20181003133609.GG4714@dhcp22.suse.cz>
 <5dc1dc4d-de60-43b9-aab6-3b3bb6a22a4b@arm.com>
 <20181009141442.GT8528@dhcp22.suse.cz>
 <b722d14e-d14f-f45d-5722-685d4f21f6e4@arm.com>
 <20181010093907.GF5873@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4127aad2-e8f4-3fcf-ffe3-7a23147885ce@arm.com>
Date: Thu, 11 Oct 2018 08:46:55 +0530
MIME-Version: 1.0
In-Reply-To: <20181010093907.GF5873@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/10/2018 03:09 PM, Michal Hocko wrote:
> On Wed 10-10-18 08:39:22, Anshuman Khandual wrote:
> [...]
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 9df1d59..4bcbf1e 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -504,6 +504,16 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>>         return arch_hugetlb_migration_supported(h);
>>  }
>>  
>> +static inline bool hugepage_movable_supported(struct hstate *h)
>> +{
>> +       if (!hugepage_migration_supported(h)) --> calls arch override restricting the set
>> +               return false;
>> +
>> +       if (hstate_is_gigantic(h)	--------> restricts the set further
>> +               return false;
>> +       return true;
>> +}
>> +
>>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>>                                            struct mm_struct *mm, pte_t *pte)
>>  {
>> @@ -600,6 +610,11 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>>         return false;
>>  }
>>  
>> +static inline bool hugepage_movable_supported(struct hstate *h)
>> +{
>> +       return false;
>> +}
>> +
>>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>>                                            struct mm_struct *mm, pte_t *pte)
>>  {
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 3c21775..a5a111d 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -919,7 +919,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>>  /* Movability of hugepages depends on migration support. */
>>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>>  {
>> -       if (hugepage_migration_supported(h))
>> +       if (hugepage_movable_supported(h))
>>                 return GFP_HIGHUSER_MOVABLE;
>>         else
>>                 return GFP_HIGHUSER;
> 
> Exactly what I've had in mind. It would be great to have a comment in
> hugepage_movable_supported to explain why we are not supporting giga
> pages even though they are migrateable and why we need that distinction.
sure, will do.

> 
>> The above patch is in addition to the following later patch in the series.
> [...]
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 9c1b77f..9df1d59 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -479,18 +479,29 @@ static inline pgoff_t basepage_index(struct page *page)
>>  extern int dissolve_free_huge_page(struct page *page);
>>  extern int dissolve_free_huge_pages(unsigned long start_pfn,
>>                                     unsigned long end_pfn);
>> -static inline bool hugepage_migration_supported(struct hstate *h)
>> -{
>> +
>>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>> +#ifndef arch_hugetlb_migration_supported
>> +static inline bool arch_hugetlb_migration_supported(struct hstate *h)
>> +{
>>         if ((huge_page_shift(h) == PMD_SHIFT) ||
>>                 (huge_page_shift(h) == PUD_SHIFT) ||
>>                         (huge_page_shift(h) == PGDIR_SHIFT))
>>                 return true;
>>         else
>>                 return false;
>> +}
>> +#endif
>>  #else
>> +static inline bool arch_hugetlb_migration_supported(struct hstate *h)
>> +{
>>         return false;
>> +}
>>  #endif
>> +
>> +static inline bool hugepage_migration_supported(struct hstate *h)
>> +{
>> +       return arch_hugetlb_migration_supported(h);
>>  }
> 
> Yes making hugepage_migration_supported to have an arch override is
> definitely the right thing to do. Whether the above approach rather than
> a weak symbol is better is a matter of taste and I do not feel strongly
> about that.
Okay then, will carry this forward and re-spin the patch series. Thank you
for your detailed review till now.
