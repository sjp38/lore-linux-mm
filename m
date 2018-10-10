Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4C4D6B0003
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 23:09:29 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v188-v6so2721445oie.3
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 20:09:29 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h82-v6si10957339oic.89.2018.10.09.20.09.28
        for <linux-mm@kvack.org>;
        Tue, 09 Oct 2018 20:09:28 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <20181002123909.GS18290@dhcp22.suse.cz>
 <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
 <20181003065833.GD18290@dhcp22.suse.cz>
 <7f0488b5-053f-0954-9b95-8c0890ef5597@arm.com>
 <20181003105926.GA4714@dhcp22.suse.cz>
 <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
 <20181003114842.GD4714@dhcp22.suse.cz>
 <d42cc88b-6bab-797c-f263-2dce650ea3ab@arm.com>
 <20181003133609.GG4714@dhcp22.suse.cz>
 <5dc1dc4d-de60-43b9-aab6-3b3bb6a22a4b@arm.com>
 <20181009141442.GT8528@dhcp22.suse.cz>
Message-ID: <b722d14e-d14f-f45d-5722-685d4f21f6e4@arm.com>
Date: Wed, 10 Oct 2018 08:39:22 +0530
MIME-Version: 1.0
In-Reply-To: <20181009141442.GT8528@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/09/2018 07:44 PM, Michal Hocko wrote:
> On Fri 05-10-18 13:04:43, Anshuman Khandual wrote:
>> Does the following sound close enough to what you are looking for ?
> 
> I do not think so

Okay.

> 
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 9df1d59..070c419 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -504,6 +504,13 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>>         return arch_hugetlb_migration_supported(h);
>>  }
>>  
>> +static inline bool hugepage_movable_required(struct hstate *h)
>> +{
>> +       if (hstate_is_gigantic(h))
>> +               return true;
>> +       return false;
>> +}
>> +
> 
> Apart from naming (hugepage_movable_supported?) the above doesn't do the
> most essential thing to query whether the hugepage migration is
> supported at all. Apart from that i would expect the logic to be revers.

My assumption was hugepage_migration_supported() should only be called from
unmap_and_move_huge_page() but we can add that here as well to limit the
set further.

> We do not really support giga pages migration enough to support them in
> movable zone.

Reversing the logic here would change gfp_t for a large number of huge pages.
Current implementation is very liberal in assigning __GFP_MOVABLE for multiple
huge page sizes (all most all of them when migration is enabled). But I guess
it should be okay because after all we are tying to control which all sizes
should be movable and which all should not be.

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

static inline gfp_t htlb_alloc_mask(struct hstate *h)
{
        if (hugepage_migration_supported(h))
                return GFP_HIGHUSER_MOVABLE;
        else
                return GFP_HIGHUSER;
}

>> @@ -1652,6 +1655,9 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>>  {
>>         gfp_t gfp_mask = htlb_alloc_mask(h);
>>  
>> +       if (hugepage_movable_required(h))
>> +               gfp_mask |= __GFP_MOVABLE;
>> +
> 
> And besides that this really want to live in htlb_alloc_mask because
> this is really an allocation policy. It would be unmap_and_move_huge_page
> to call hugepage_migration_supported. The later is the one to allow for
> an arch specific override.
> 
> Makes sense?
> 

hugepage_migration_supported() will be checked inside hugepage_movable_supported().
A changed version ....

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 9df1d59..4bcbf1e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -504,6 +504,16 @@ static inline bool hugepage_migration_supported(struct hstate *h)
        return arch_hugetlb_migration_supported(h);
 }
 
+static inline bool hugepage_movable_supported(struct hstate *h)
+{
+       if (!hugepage_migration_supported(h)) --> calls arch override restricting the set
+               return false;
+
+       if (hstate_is_gigantic(h)	--------> restricts the set further
+               return false;
+       return true;
+}
+
 static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
                                           struct mm_struct *mm, pte_t *pte)
 {
@@ -600,6 +610,11 @@ static inline bool hugepage_migration_supported(struct hstate *h)
        return false;
 }
 
+static inline bool hugepage_movable_supported(struct hstate *h)
+{
+       return false;
+}
+
 static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
                                           struct mm_struct *mm, pte_t *pte)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3c21775..a5a111d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -919,7 +919,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 /* Movability of hugepages depends on migration support. */
 static inline gfp_t htlb_alloc_mask(struct hstate *h)
 {
-       if (hugepage_migration_supported(h))
+       if (hugepage_movable_supported(h))
                return GFP_HIGHUSER_MOVABLE;
        else
                return GFP_HIGHUSER;


The above patch is in addition to the following later patch in the series.

    mm/hugetlb: Enable arch specific huge page size support for migration
    
    Architectures like arm64 have HugeTLB page sizes which are different than
    generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
    At present these special size HugeTLB pages cannot be identified through
    macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.
    
    Enabling migration support for these special HugeTLB page sizes along with
    the generic ones (PMD|PUD|PGD) would require identifying all of them on a
    given platform. A platform specific hook can precisely enumerate all huge
    page sizes supported for migration. Instead of comparing against standard
    huge page orders let hugetlb_migration_support() function call a platform
    hook arch_hugetlb_migration_support(). Default definition for the platform
    hook maintains existing semantics which checks standard huge page order.
    But an architecture can choose to override the default and provide support
    for a comprehensive set of huge page sizes.
    
    Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 9c1b77f..9df1d59 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -479,18 +479,29 @@ static inline pgoff_t basepage_index(struct page *page)
 extern int dissolve_free_huge_page(struct page *page);
 extern int dissolve_free_huge_pages(unsigned long start_pfn,
                                    unsigned long end_pfn);
-static inline bool hugepage_migration_supported(struct hstate *h)
-{
+
 #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+#ifndef arch_hugetlb_migration_supported
+static inline bool arch_hugetlb_migration_supported(struct hstate *h)
+{
        if ((huge_page_shift(h) == PMD_SHIFT) ||
                (huge_page_shift(h) == PUD_SHIFT) ||
                        (huge_page_shift(h) == PGDIR_SHIFT))
                return true;
        else
                return false;
+}
+#endif
 #else
+static inline bool arch_hugetlb_migration_supported(struct hstate *h)
+{
        return false;
+}
 #endif
+
+static inline bool hugepage_migration_supported(struct hstate *h)
+{
+       return arch_hugetlb_migration_supported(h);
 }
