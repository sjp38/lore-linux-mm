Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0CB6B0006
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:06:47 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p23-v6so3622043otl.23
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:06:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f139-v6si651579oib.184.2018.10.03.06.06.45
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 06:06:46 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <20181002123909.GS18290@dhcp22.suse.cz>
 <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
 <20181003065833.GD18290@dhcp22.suse.cz>
 <7f0488b5-053f-0954-9b95-8c0890ef5597@arm.com>
 <20181003105926.GA4714@dhcp22.suse.cz>
 <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
 <20181003114842.GD4714@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d42cc88b-6bab-797c-f263-2dce650ea3ab@arm.com>
Date: Wed, 3 Oct 2018 18:36:39 +0530
MIME-Version: 1.0
In-Reply-To: <20181003114842.GD4714@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/03/2018 05:18 PM, Michal Hocko wrote:
> On Wed 03-10-18 17:07:13, Anshuman Khandual wrote:
>>
>>
>> On 10/03/2018 04:29 PM, Michal Hocko wrote:
> [...]
>>> It is not the platform that decides. That is the whole point of the
>>> distinction. It is us to say what is feasible and what we want to
>>> support. Do we want to support giga pages in zone_movable? Under which
>>> conditions? See my point?
>>
>> So huge_movable() is going to be a generic MM function deciding on the
>> feasibility for allocating a huge page of 'size' from movable zone during
>> migration.
> 
> Yeah, this might be a more complex logic than just the size check. If
> there is a sufficient pre-allocated pool to migrate the page off it
> might be pre-reserved for future migration etc... Nothing to be done
> right now of course.

If the huge page has a pre-allocated pool, then it gets consumed first
through the current allocator logic (new_page_nodemask). Hence testing
for feasibility by looking into pool and (buddy / zone) together is not
going to change the policy unless there is also a new allocator which
goes and consumes (from reserved pool or buddy/zone) huge pages as
envisioned by the feasibility checker. But I understand your point.
That path can be explored as well.

> 
>> If the feasibility turns out to be negative, then migration
>> process is aborted there.
> 
> You are still confusing allocation and migration here I am afraid. The
> whole "feasible to migrate" is for the _allocation_ time when we decide
> whether the new page should be placed in zone_movable or not.

migrate_pages() -> platform specific arch_hugetlb_migration(in principle) ->
generic huge_movable() feasibility check while trying to allocate the
destination page -> move source to destination -> complete !

So we have two checks here

1) platform specific arch_hugetlb_migration -> In principle go ahead

2) huge_movable() during allocation

	- If huge page does not have to be placed on movable zone

		- Allocate any where successfully and done !
 
	- If huge page *should* be placed on a movable zone

		- Try allocating on movable zone

			- Successfull and done !

		- If the new page could not be allocated on movable zone
		
			- Abort the migration completely

					OR

			- Warn and fall back to non-movable


There is an important point to note here.

- Whether a huge size should be on movable zone can be determined
  looking into size and other parameters during feasibility test

- But whether a huge size can be allocated in actual on movable zone
  might not be determined without really allocating it which will
  further delay the decision to successfully complete the migration,
  warning about it or aborting it at this allocation phase itself

> 
>> huge_movable() will do something like these:
>>
>> - Return positive right away on smaller size huge pages
>> - Measure movable allocation feasibility for bigger huge pages
>> 	- Look out for free_pages in the huge page order in movable areas
>> 	- if (order > (MAX_ORDER - 1))
>> 		- Scan the PFN ranges in movable zone for possible allocation
>> 	- etc
>> 	- etc
>>
>> Did I get this right ?
> 
> Well, not really. I was thinking of something like this for the
> beginning
> 	if (!arch_hugepage_migration_supporte())
> 		return false;

First check: Platform check in principle as you mentioned before

> 	if (hstate_is_gigantic(h))
> 		return false;

Second check: Simplistic generic allocation feasibility check looking just at size

> 	return true;
> 
> further changes might be done on top of this.
Right.
