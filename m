Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1F46B0038
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 17:16:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i12so557568qka.15
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 14:16:29 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h9si1961597qtc.28.2017.09.29.14.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 14:16:28 -0700 (PDT)
Subject: Re: [PATCH] mm, hugetlb: fix "treat_as_movable" condition in
 htlb_alloc_mask
References: <20170929151339.GA4398@gmail.com> <20170929204321.GA593@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e085bc8c-6614-5c9b-6702-5ed477bc856c@oracle.com>
Date: Fri, 29 Sep 2017 14:16:10 -0700
MIME-Version: 1.0
In-Reply-To: <20170929204321.GA593@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>, akpm@linux-foundation.org, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, gerald.schaefer@de.ibm.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

Adding Anshuman

On 09/29/2017 01:43 PM, Alexandru Moise wrote:
> On Fri, Sep 29, 2017 at 05:13:39PM +0200, Alexandru Moise wrote:
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 424b0ef08a60..ab28de0122af 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -926,7 +926,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>>  /* Movability of hugepages depends on migration support. */
>>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>>  {
>> -	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
>> +	if (hugepages_treat_as_movable && hugepage_migration_supported(h))
>>  		return GFP_HIGHUSER_MOVABLE;
>>  	else
>>  		return GFP_HIGHUSER;
>> -- 
>> 2.14.2
>>
> 
> I seem to have terribly misunderstood the semantics of this flag wrt hugepages,
> please ignore this for now.

That is Okay, it made me look at this code more closely.

static inline bool hugepage_migration_supported(struct hstate *h)
{
#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
        if ((huge_page_shift(h) == PMD_SHIFT) ||
                (huge_page_shift(h) == PGDIR_SHIFT))
                return true;
        else
                return false;
#else
        return false;
#endif
}

So, hugepage_migration_supported() can only return true if
ARCH_ENABLE_HUGEPAGE_MIGRATION is defined.  Commit c177c81e09e5
restricts hugepage_migration_support to x86_64.  So,
ARCH_ENABLE_HUGEPAGE_MIGRATION is only defined for x86_64.

Commit 94310cbcaa3c added the ability to migrate gigantic hugetlb pages
at the PGD level.  This added the check for PGD level pages to
hugepage_migration_supported(), which is only there if
ARCH_ENABLE_HUGEPAGE_MIGRATION is defined.  IIUC, this functionality
was added for powerpc.  Yet, powerpc does not define
ARCH_ENABLE_HUGEPAGE_MIGRATION (unless I am missing something).

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
