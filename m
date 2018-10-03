Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D47AB6B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:37:20 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d23-v6so3393190oib.6
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:37:20 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z65-v6si534942oia.159.2018.10.03.04.37.19
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 04:37:19 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <20181002123909.GS18290@dhcp22.suse.cz>
 <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
 <20181003065833.GD18290@dhcp22.suse.cz>
 <7f0488b5-053f-0954-9b95-8c0890ef5597@arm.com>
 <20181003105926.GA4714@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
Date: Wed, 3 Oct 2018 17:07:13 +0530
MIME-Version: 1.0
In-Reply-To: <20181003105926.GA4714@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/03/2018 04:29 PM, Michal Hocko wrote:
> On Wed 03-10-18 15:28:23, Anshuman Khandual wrote:
>>
>>
>> On 10/03/2018 12:28 PM, Michal Hocko wrote:
>>> On Wed 03-10-18 07:46:27, Anshuman Khandual wrote:
>>>>
>>>>
>>>> On 10/02/2018 06:09 PM, Michal Hocko wrote:
>>>>> On Tue 02-10-18 17:45:28, Anshuman Khandual wrote:
>>>>>> Architectures like arm64 have PUD level HugeTLB pages for certain configs
>>>>>> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
>>>>>> enabled for migration. It can be achieved through checking for PUD_SHIFT
>>>>>> order based HugeTLB pages during migration.
>>>>>
>>>>> Well a long term problem with hugepage_migration_supported is that it is
>>>>> used in two different context 1) to bail out from the migration early
>>>>> because the arch doesn't support migration at all and 2) to use movable
>>>>> zone for hugetlb pages allocation. I am especially concerned about the
>>>>> later because the mere support for migration is not really good enough.
>>>>> Are you really able to find a different giga page during the runtime to
>>>>> move an existing giga page out of the movable zone?
>>>>
>>>> I pre-allocate them before trying to initiate the migration (soft offline
>>>> in my experiments). Hence it should come from the pre-allocated HugeTLB
>>>> pool instead from the buddy. I might be missing something here but do we
>>>> ever allocate HugeTLB on the go when trying to migrate ? IIUC it always
>>>> came from the pool (unless its something related to ovecommit/surplus).
>>>> Could you please kindly explain regarding how migration target HugeTLB
>>>> pages are allocated on the fly from movable zone.
>>>
>>> Hotplug comes to mind. You usually do not pre-allocate to cover full
>>> node going offline. And people would like to do that. Another example is
>>> CMA. You would really like to move pages out of the way.
>>
>> You are right.
>>
>> Hotplug migration:
>>
>> __offline_pages
>>    do_migrate_range
>> 	migrate_pages(...new_node_page...)
>>
>> new_node_page
>>    new_page_nodemask
>> 	alloc_huge_page_nodemask
>> 	   dequeue_huge_page_nodemask (Getting from pool)
>> 	or
>> 	   alloc_migrate_huge_page    (Getting from buddy - non-gigantic)
>> 		alloc_fresh_huge_page
>> 		    alloc_buddy_huge_page
>> 			__alloc_pages_nodemask ----> goes into buddy
>>
>> CMA allocation:
>>
>> cma_alloc
>>    alloc_contig_range
>> 	__alloc_contig_migrate_range
>> 		migrate_pages(...alloc_migrate_target...)
>>
>> alloc_migrate_target
>>    new_page_nodemask -> __alloc_pages_nodemask ---> goes into buddy
>>
>> But this is not applicable for gigantic pages for which it backs off way
>> before going into buddy.
> 
> This is an implementation detail - mostly a missing or an incomplete
> hugetlb overcommit implementation IIRC. The primary point remains the
> same. Being able to migrate in principle and feasible enough to migrate
> to be placed in zone movable are two distinct things.

I agree. They are two distinct things.

> [...]
>>>> But even if there are some chances of run time allocation failure from
>>>> movable zone (as in point 2) that should not block the very initiation
>>>> of migration itself. IIUC thats not the semantics for either THP or
>>>> normal pages. Why should it be different here. If the allocation fails
>>>> we should report and abort as always. Its the caller of migration taking
>>>> the chances. why should we prevent that.
>>>
>>> Yes I agree, hence the distinction between the arch support for
>>> migrateability and the criterion on the movable zone placement.
>> movable zone placement sounds very tricky here. How can the platform
>> (through the hook huge_movable) before hand say whether destination
>> page could be allocated from the ZONE_MOVABLE without looking into the
>> state of buddy at migration (any sort attempt to do this is going to
>> be expensive) or it merely indicates the desire to live with possible
>> consequence (unable to hot unplug/CMA going forward) for a migration
>> which might end up in an unmovable area.
> 
> I do not follow. The whole point of zone_movable is to provide a
> physical memory range which is more or less movable. That means that
> pages allocated from this zone can be migrated away should there be a
> reason for that.

I understand this.

> 
>>>>> So I guess we want to split this into two functions
>>>>> arch_hugepage_migration_supported and hugepage_movable. The later would
>>>>
>>>> So the set difference between arch_hugepage_migration_supported and 
>>>> hugepage_movable still remains un-migratable ? Then what is the purpose
>>>> for arch_hugepage_migration_supported page size set in the first place.
>>>> Does it mean we allow the migration at the beginning and the abort later
>>>> when the page size does not fall within the subset for hugepage_movable.
>>>> Could you please kindly explain this in more detail.
>>>
>>> The purpose of arch_hugepage_migration_supported is to tell whether it
>>> makes any sense to even try to migration. The allocation placement is
>>
>> Which kind of matches what we have right now and being continued with this
>> proposal in the series.
> 
> Except you only go half way there. Because you still consider "able to
> migrate" and "feasible to migrate" as the same thing.

Okay.

> 
>>
>>> completely independent on this choice. The later just says whether it is
>>> feasible to place a hugepage to the zone movable. Sure regular 2MB pages
>>
>> What do you exactly mean by feasible ? Wont it depend on the state of the
>> buddy allocator (ZONE_MOVABLE in particular) and it's ability to accommodate
>> a given huge page. How can the platform decide on it ?
> 
> It is not the platform that decides. That is the whole point of the
> distinction. It is us to say what is feasible and what we want to
> support. Do we want to support giga pages in zone_movable? Under which
> conditions? See my point?

So huge_movable() is going to be a generic MM function deciding on the
feasibility for allocating a huge page of 'size' from movable zone during
migration. If the feasibility turns out to be negative, then migration
process is aborted there.

huge_movable() will do something like these:

- Return positive right away on smaller size huge pages
- Measure movable allocation feasibility for bigger huge pages
	- Look out for free_pages in the huge page order in movable areas
	- if (order > (MAX_ORDER - 1))
		- Scan the PFN ranges in movable zone for possible allocation
	- etc
	- etc

Did I get this right ?

> 
>> Or as I mentioned
>> before it's platform's willingness to live with unmovable huge pages (of
>> certain sizes) as a consequence of migration.
> 
> No, the platform has no saying in that. The platform only says that it
> supports migrating those pages in principle.
I understand this now.
