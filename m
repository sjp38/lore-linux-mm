Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6996B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 01:22:38 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id a188-v6so690541oih.0
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 22:22:38 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s4-v6si15215104oib.72.2018.11.01.22.22.36
        for <linux-mm@kvack.org>;
        Thu, 01 Nov 2018 22:22:36 -0700 (PDT)
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
 <20181018021741.GA3603@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ec71f76a-a8a6-ce33-c1bd-aef474fcfcbf@arm.com>
Date: Fri, 2 Nov 2018 10:52:25 +0530
MIME-Version: 1.0
In-Reply-To: <20181018021741.GA3603@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "will.deacon@arm.com" <will.deacon@arm.com>

 

On 10/18/2018 07:47 AM, Naoya Horiguchi wrote:
> On Tue, Oct 16, 2018 at 10:31:50AM -0400, Zi Yan wrote:
>> On 15 Oct 2018, at 0:06, Anshuman Khandual wrote:
>>
>>> On 10/15/2018 06:23 AM, Zi Yan wrote:
>>>> On 12 Oct 2018, at 4:00, Anshuman Khandual wrote:
>>>>
>>>>> On 10/10/2018 06:13 PM, Zi Yan wrote:
>>>>>> On 10 Oct 2018, at 0:05, Anshuman Khandual wrote:
>>>>>>
>>>>>>> On 10/09/2018 07:28 PM, Zi Yan wrote:
>>>>>>>> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PSE for x86
>>>>>>>> PMD migration entry check)
>>>>>>>>
>>>>>>>> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
>>>>>>>>
>>>>>>>>> A normal mapped THP page at PMD level should be correctly differentiated
>>>>>>>>> from a PMD migration entry while walking the page table. A mapped THP would
>>>>>>>>> additionally check positive for pmd_present() along with pmd_trans_huge()
>>>>>>>>> as compared to a PMD migration entry. This just adds a new conditional test
>>>>>>>>> differentiating the two while walking the page table.
>>>>>>>>>
>>>>>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>>>>>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>>>>>>> ---
>>>>>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>>>>>>>>> exclusive which makes the current conditional block work for both mapped
>>>>>>>>> and migration entries. This is not same with arm64 where pmd_trans_huge()
>>>>>>>>
>>>>>>>> !pmd_present() && pmd_trans_huge() is used to represent THPs under splitting,
>>>>>>>
>>>>>>> Not really if we just look at code in the conditional blocks.
>>>>>>
>>>>>> Yeah, I explained it wrong above. Sorry about that.
>>>>>>
>>>>>> In x86, pmd_present() checks (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE),
>>>>>> thus, it returns true even if the present bit is cleared but PSE bit is set.
>>>>>
>>>>> Okay.
>>>>>
>>>>>> This is done so, because THPs under splitting are regarded as present in the kernel
>>>>>> but not present when a hardware page table walker checks it.
>>>>>
>>>>> Okay.
>>>>>
>>>>>>
>>>>>> For PMD migration entry, which should be regarded as not present, if PSE bit
>>>>>> is set, which makes pmd_trans_huge() returns true, like ARM64 does, all
>>>>>> PMD migration entries will be regarded as present
>>>>>
>>>>> Okay to make pmd_present() return false pmd_trans_huge() has to return false
>>>>> as well. Is there anything which can be done to get around this problem on
>>>>> X86 ? pmd_trans_huge() returning true for a migration entry sounds logical.
>>>>> Otherwise we would revert the condition block order to accommodate both the
>>>>> implementation for pmd_trans_huge() as suggested by Kirill before or just
>>>>> consider this patch forward.
>>>>>
>>>>> Because I am not really sure yet about the idea of getting pmd_present()
>>>>> check into pmd_trans_huge() on arm64 just to make it fit into this semantics
>>>>> as suggested by Will. If a PMD is trans huge page or not should not depend on
>>>>> whether it is present or not.
>>>>
>>>> In terms of THPs, we have three cases: a present THP, a THP under splitting,
>>>> and a THP under migration. pmd_present() and pmd_trans_huge() both return true
>>>> for a present THP and a THP under splitting, because they discover _PAGE_PSE bit
>>>
>>> Then how do we differentiate between a mapped THP and a splitting THP.
>>
>> AFAIK, in x86, there is no distinction between a mapped THP and a splitting THP
>> using helper functions.
>>
>> A mapped THP has _PAGE_PRESENT bit and _PAGE_PSE bit set, whereas a splitting THP
>> has only _PAGE_PSE bit set. But both pmd_present() and pmd_trans_huge() return
>> true as long as _PAGE_PSE bit is set.
>>
>>>
>>>> is set for both cases, whereas they both return false for a THP under migration.
>>>> You want to change them to make pmd_trans_huge() returns true for a THP under migration
>>>> instead of false to help ARM64’s support for THP migration.
>>> I am just trying to understand the rationale behind this semantics and see where
>>> it should be fixed.
>>>
>>> I think the fundamental problem here is that THP under split has been difficult
>>> to be re-presented through the available helper functions and in turn PTE bits.
>>>
>>> The following checks
>>>
>>> 1) pmd_present()
>>> 2) pmd_trans_huge()
>>>
>>> Represent three THP states
>>>
>>> 1) Mapped THP		(pmd_present && pmd_trans_huge)
>>> 2) Splitting THP	(pmd_present && pmd_trans_huge)
>>> 3) Migrating THP	(!pmd_present && !pmd_trans_huge)
>>>
>>> The problem is if we make pmd_trans_huge() return true for all the three states
>>> which sounds logical because they are all still trans huge PMD, then pmd_present()
>>> can only represent two states not three as required.
>>
>> We are on the same page about representing three THP states in x86.
>> I also agree with you that it is logical to use three distinct representations
>> for these three states, i.e. splitting THP could be changed to (!pmd_present && pmd_trans_huge).
> 
> I think that the behavior of pmd_trans_huge() for non-present pmd is
> undefined by its nature. IOW, it's no use determining whether it's thp or
> not for non-existing pages because it does not exist :)> 
> So I think that the right direction is to make sure that pmd_trans_huge() is
> never checked for non-present pmd, just like Kirill's suggestion.  And maybe
> we have some room for engineering to ensure it (rather than just commenting it).

Agreed, pmd_trans_huge() does not make sense for a migration or a swap entry
and should not be checked on them.
