Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 737A76B0010
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:10:52 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id s2so5453524ote.13
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:10:52 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x142-v6si1927021oix.79.2018.10.25.01.10.50
        for <linux-mm@kvack.org>;
        Thu, 25 Oct 2018 01:10:50 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
 <796cb545-7376-16a2-db3e-bc9a6ca9894d@arm.com>
 <5A0A88EF-4B86-4173-A506-DE19BDB786B8@cs.rutgers.edu>
Message-ID: <dcd972a6-a508-1fab-4ba9-04043ca9992c@arm.com>
Date: Thu, 25 Oct 2018 13:40:39 +0530
MIME-Version: 1.0
In-Reply-To: <5A0A88EF-4B86-4173-A506-DE19BDB786B8@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>



On 10/16/2018 08:01 PM, Zi Yan wrote:
> On 15 Oct 2018, at 0:06, Anshuman Khandual wrote:
> 
>> On 10/15/2018 06:23 AM, Zi Yan wrote:
>>> On 12 Oct 2018, at 4:00, Anshuman Khandual wrote:
>>>
>>>> On 10/10/2018 06:13 PM, Zi Yan wrote:
>>>>> On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:
>>>>>
>>>>>> On 10/09/2018 07:28 PM, Zi Yan wrote:
>>>>>>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PSE for x86
>>>>>>> PMD migration entry check)
>>>>>>>
>>>>>>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
>>>>>>>
>>>>>>>> A normal mapped THP page at PMD level should be correctly differentiated
>>>>>>>> from a PMD migration entry while walking the page table. A mapped THP would
>>>>>>>> additionally check positive for pmd_present() along with pmd_trans_huge()
>>>>>>>> as compared to a PMD migration entry. This just adds a new conditional test
>>>>>>>> differentiating the two while walking the page table.
>>>>>>>>
>>>>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>>>>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>>>>>> ---
>>>>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>>>>>>>> exclusive which makes the current conditional block work for both mapped
>>>>>>>> and migration entries. This is not same with arm64 where pmd_trans_huge()
>>>>>>>
>>>>>>> !pmd_present() && pmd_trans_huge() is used to represent THPs under splitting,
>>>>>>
>>>>>> Not really if we just look at code in the conditional blocks.
>>>>>
>>>>> Yeah, I explained it wrong above. Sorry about that.
>>>>>
>>>>> In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE),
>>>>> thus, it returns true even if the present bit is cleared but PSE bit is set.
>>>>
>>>> Okay.
>>>>
>>>>> This is done so, because THPs under splitting are regarded as present in the kernel
>>>>> but not present when a hardware page table walker checks it.
>>>>
>>>> Okay.
>>>>
>>>>>
>>>>> For PMD migration entry, which should be regarded as not present, if PSE bit
>>>>> is set, which makes pmd_trans_huge() returns true, like ARM64 does, all
>>>>> PMD migration entries will be regarded as present
>>>>
>>>> Okay to make pmd_present() return false pmd_trans_huge() has to return false
>>>> as well. Is there anything which can be done to get around this problem on
>>>> X86 ? pmd_trans_huge() returning true for a migration entry sounds logical.
>>>> Otherwise we would revert the condition block order to accommodate both the
>>>> implementation for pmd_trans_huge() as suggested by Kirill before or just
>>>> consider this patch forward.
>>>>
>>>> Because I am not really sure yet about the idea of getting pmd_present()
>>>> check into pmd_trans_huge() on arm64 just to make it fit into this semantics
>>>> as suggested by Will. If a PMD is trans huge page or not should not depend on
>>>> whether it is present or not.
>>>
>>> In terms of THPs, we have three cases: a present THP, a THP under splitting,
>>> and a THP under migration. pmd_present() and pmd_trans_huge() both return true
>>> for a present THP and a THP under splitting, because they discover _PAGE_PSE bit
>>
>> Then how do we differentiate between a mapped THP and a splitting THP.
> 
> AFAIK, in x86, there is no distinction between a mapped THP and a splitting THP
> using helper functions.
> 
> A mapped THP has _PAGE_PRESENT bit and _PAGE_PSE bit set, whereas a splitting THP
> has only _PAGE_PSE bit set. But both pmd_present() and pmd_trans_huge() return
> true as long as _PAGE_PSE bit is set.

I understand that. What I was wondering was since there is a need to differentiate
between a mapped THP and a splitting THP at various places in generic THP, we would
need to way to identify each of them unambiguously some how. Is that particular
assumption wrong ? Dont we need to differentiate between a mapped THP and THP under
splitting ?

> 
>>
>>> is set for both cases, whereas they both return false for a THP under migration.
>>> You want to change them to make pmd_trans_huge() returns true for a THP under migration
>>> instead of false to help ARM64a??s support for THP migration.
>> I am just trying to understand the rationale behind this semantics and see where
>> it should be fixed.
>>
>> I think the fundamental problem here is that THP under split has been difficult
>> to be re-presented through the available helper functions and in turn PTE bits.
>>
>> The following checks
>>
>> 1) pmd_present()
>> 2) pmd_trans_huge()
>>
>> Represent three THP states
>>
>> 1) Mapped THP		(pmd_present && pmd_trans_huge)
>> 2) Splitting THP	(pmd_present && pmd_trans_huge)
>> 3) Migrating THP	(!pmd_present && !pmd_trans_huge)
>>
>> The problem is if we make pmd_trans_huge() return true for all the three states
>> which sounds logical because they are all still trans huge PMD, then pmd_present()
>> can only represent two states not three as required.
> 
> We are on the same page about representing three THP states in x86.
> I also agree with you that it is logical to use three distinct representations
> for these three states, i.e. splitting THP could be changed to (!pmd_present && pmd_trans_huge

Right. Also we need clear wrapper around them in line with is_pmd_migration_entry() to
represent three states all of which calling pmd_present() and pmd_trans_huge() which
are exported by various architectures with exact same semantics without any ambiguity.

1) is_pmd_mapped_entry()
2) is_pmd_splitting_entry()
3) is_pmd_migration_entry()

> 
> 
>>>
>>> For x86, this change requires:
>>> 1. changing the condition in pmd_trans_huge(), so that it returns true for
>>> PMD migration entries;
>>> 2. changing the code, which calls pmd_trans_huge(), to match the new logic.
>> Can those be fixed with an additional check for pmd_present() as suggested here
>> in this patch ? Asking because in case we could not get common semantics for
>> these helpers on all arch that would be a fall back option for the moment.
> 
> It would be OK for x86, since pmd_trans_huge() implies pmd_present() and hence
> adding pmd_present() to pmd_trans_huge() makes no difference. But for ARM64,
> from my understanding of the code described below, adding pmd_present() to
> pmd_trans_huge() seems to exclude splitting THPs from the original semantic.
> 
> 
>>>
>>> Another problem I see is that x86a??s pmd_present() returns true for a THP under
>>> splitting but ARM64a??s pmd_present() returns false for a THP under splitting.
>>
>> But how did you conclude this ? I dont see any explicit helper for splitting
>> THP. Could you please point me in the code ?
> 
> From the code I read for ARM64
> (https://elixir.bootlin.com/linux/v4.19-rc8/source/arch/arm64/include/asm/pgtable.h#L360
> and https://elixir.bootlin.com/linux/v4.19-rc8/source/arch/arm64/include/asm/pgtable.h#L86),
> pmd_present() only checks _PAGE_PRESENT and _PAGE_PROTONE. During a THP splitting,

These are PTE_VALID and PTE_PROT_NONE instead on arm64. But yes, they are equivalent
to __PAGE_PRESENT and __PAGE_PROTNONE on other archs.

#define pmd_present(pmd)        pte_present(pmd_pte(pmd))
#define pte_present(pte)        (!!(pte_val(pte) & (PTE_VALID | PTE_PROT_NONE)))

> pmdp_invalidate() clears _PAGE_PRESENT (https://elixir.bootlin.com/linux/v4.19-rc8/source/mm/huge_memory.c#L2130). So pmd_present() returns false in ARM64. Let me know
> if I got anything wrong.
>

old_pmd = pmdp_invalidate(vma, haddr, pmd);

__split_huge_pmd_locked -> pmdp_invalidate (the above mentioned instance)
pmdp_invalidate -> pmd_mknotpresent

#define pmd_mknotpresent(pmd)   (__pmd(pmd_val(pmd) & ~PMD_SECT_VALID)

Generic pmdp invalidation removes PMD_SECT_VALID from a mapped PMD entry.
PMD_SECT_VALID is similar to PTE_VALID through identified separately. So you
are right, on arm64 pmd_present() return false for THP under splitting.

> 
> 
>>> I do not know if there is any correctness issue with this. So I copy Andrea
>>> here, since he made x86a??s pmd_present() returns true for a THP under splitting
>>> as an optimization. I want to understand more about it and potentially make
>>> x86 and ARM64 (maybe all other architectures, too) return the same value
>>> for all three cases mentioned above.
>>
>> I agree. Fixing the semantics is the right thing to do. I am kind of wondering if
>> it would be a good idea to have explicit helpers for (1) mapped THP, (2) splitting
>> THP like the one for (3) migrating THP (e.g is_pmd_migration_entry) and use them
>> in various conditional blocks instead of looking out for multiple checks like
>> pmd_trans_huge(), pmd_present() etc. It will help unify the semantics as well.
>>
> 
> I agree that explicit and distinct helpers for all three THP states would be helpful.
> 

Right.

>>>
>>>
>>> Hi Andrea, what is the purpose/benefit of making x86a??s pmd_present() returns true
>>> for a THP under splitting? Does it cause problems when ARM64a??s pmd_present()
>>> returns false in the same situation?
>>>
>>>
>>>>>
>>>>> My concern is that if ARM64a??s pmd_trans_huge() returns true for migration
>>>>> entries, unlike x86, there might be bugs triggered in the kernel when
>>>>> THP migration is enabled in ARM64.
>>>>
>>>> Right and that is exactly what we are trying to fix with this patch.
>>>>
>>>
>>> I am not sure this patch can fix the problem in ARM64, because many other places
>>> in the kernel, pmd_trans_huge() still returns false for a THP under migration.
>>> We may need more comprehensive fixes for ARM64.
>> Are there more places where semantics needs to be fixed than what was originally
>> added through 616b8371539a ("mm: thp: enable thp migration in generic path").
> 
> I guess not, but it would be safer to grep for all pmd_trans_huge() and pmd_present().
Sure.
