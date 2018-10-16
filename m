Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C14806B026A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:16:55 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d34so16799887otb.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:16:55 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g12si4536896otl.218.2018.10.16.06.16.54
        for <linux-mm@kvack.org>;
        Tue, 16 Oct 2018 06:16:54 -0700 (PDT)
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
 <20181009131803.GH6248@arm.com>
 <fb0ee5dd-5799-f5af-891a-992dd9a16a9f@arm.com>
 <4bf3951d-410f-fac4-dfb2-7dee5568e6ff@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7e11e5b0-fad5-01fb-6b01-66bbd50b6a2e@arm.com>
Date: Tue, 16 Oct 2018 18:46:48 +0530
MIME-Version: 1.0
In-Reply-To: <4bf3951d-410f-fac4-dfb2-7dee5568e6ff@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneeshkumar.opensource@gmail.com>, Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu



On 10/15/2018 02:02 PM, Aneesh Kumar K.V wrote:
> On 10/12/18 1:32 PM, Anshuman Khandual wrote:
>>
>>
>> On 10/09/2018 06:48 PM, Will Deacon wrote:
>>> On Tue, Oct 09, 2018 at 04:04:21PM +0300, Kirill A. Shutemov wrote:
>>>> On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
>>>>> A normal mapped THP page at PMD level should be correctly differentiated
>>>>> from a PMD migration entry while walking the page table. A mapped THP would
>>>>> additionally check positive for pmd_present() along with pmd_trans_huge()
>>>>> as compared to a PMD migration entry. This just adds a new conditional test
>>>>> differentiating the two while walking the page table.
>>>>>
>>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>>> ---
>>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>>>>> exclusive which makes the current conditional block work for both mapped
>>>>> and migration entries. This is not same with arm64 where pmd_trans_huge()
>>>>> returns positive for both mapped and migration entries. Could some one
>>>>> please explain why pmd_trans_huge() has to return false for migration
>>>>> entries which just install swap bits and its still a PMD ?
>>>>
>>>> I guess it's just a design choice. Any reason why arm64 cannot do the
>>>> same?
>>>
>>> Anshuman, would it work to:
>>>
>>> #define pmd_trans_huge(pmd)A A A A  (pmd_present(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
>> yeah this works but some how does not seem like the right thing to do
>> but can be the very last option.
>>
> 
> 
> There can be other code paths that makes that assumption. I ended up doing the below for pmd_trans_huge on ppc64.
>

Yeah, did see that in one of the previous proposals.

https://patchwork.kernel.org/patch/10544291/

But the existing semantics does not look right and makes vague assumptions.
Zi Yan has already asked Andrea for his input in this regard on the next
thread. So I guess while being here, its a good idea to revisit existing
semantics and it's assumptions before fixing it in arch specific helpers.

- Anshuman 


> /*
> A * Only returns true for a THP. False for pmd migration entry.
> A * We also need to return true when we come across a pte that
> A * in between a thp split. While splitting THP, we mark the pmd
> A * invalid (pmdp_invalidate()) before we set it with pte page
> A * address. A pmd_trans_huge() check against a pmd entry during that time
> A * should return true.
> A * We should not call this on a hugetlb entry. We should check for HugeTLB
> A * entry using vma->vm_flags
> A * The page table walk rule is explained in Documentation/vm/transhuge.rst
> A */
> static inline int pmd_trans_huge(pmd_t pmd)
> {
> A A A A if (!pmd_present(pmd))
> A A A A A A A  return false;
> 
> A A A A if (radix_enabled())
> A A A A A A A  return radix__pmd_trans_huge(pmd);
> A A A A return hash__pmd_trans_huge(pmd);
> }
> 
> -aneesh
> 
