Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16FFF6B0269
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:32:55 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u43-v6so6097054pgn.4
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 01:32:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p72-v6sor440200pfk.73.2018.10.15.01.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 01:32:54 -0700 (PDT)
From: "Aneesh Kumar K.V" <aneeshkumar.opensource@gmail.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
 <20181009131803.GH6248@arm.com>
 <fb0ee5dd-5799-f5af-891a-992dd9a16a9f@arm.com>
Message-ID: <4bf3951d-410f-fac4-dfb2-7dee5568e6ff@linux.ibm.com>
Date: Mon, 15 Oct 2018 14:02:48 +0530
MIME-Version: 1.0
In-Reply-To: <fb0ee5dd-5799-f5af-891a-992dd9a16a9f@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu

On 10/12/18 1:32 PM, Anshuman Khandual wrote:
> 
> 
> On 10/09/2018 06:48 PM, Will Deacon wrote:
>> On Tue, Oct 09, 2018 at 04:04:21PM +0300, Kirill A. Shutemov wrote:
>>> On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
>>>> A normal mapped THP page at PMD level should be correctly differentiated
>>>> from a PMD migration entry while walking the page table. A mapped THP would
>>>> additionally check positive for pmd_present() along with pmd_trans_huge()
>>>> as compared to a PMD migration entry. This just adds a new conditional test
>>>> differentiating the two while walking the page table.
>>>>
>>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>> ---
>>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>>>> exclusive which makes the current conditional block work for both mapped
>>>> and migration entries. This is not same with arm64 where pmd_trans_huge()
>>>> returns positive for both mapped and migration entries. Could some one
>>>> please explain why pmd_trans_huge() has to return false for migration
>>>> entries which just install swap bits and its still a PMD ?
>>>
>>> I guess it's just a design choice. Any reason why arm64 cannot do the
>>> same?
>>
>> Anshuman, would it work to:
>>
>> #define pmd_trans_huge(pmd)     (pmd_present(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
> yeah this works but some how does not seem like the right thing to do
> but can be the very last option.
> 


There can be other code paths that makes that assumption. I ended up 
doing the below for pmd_trans_huge on ppc64.

/*
  * Only returns true for a THP. False for pmd migration entry.
  * We also need to return true when we come across a pte that
  * in between a thp split. While splitting THP, we mark the pmd
  * invalid (pmdp_invalidate()) before we set it with pte page
  * address. A pmd_trans_huge() check against a pmd entry during that time
  * should return true.
  * We should not call this on a hugetlb entry. We should check for HugeTLB
  * entry using vma->vm_flags
  * The page table walk rule is explained in Documentation/vm/transhuge.rst
  */
static inline int pmd_trans_huge(pmd_t pmd)
{
	if (!pmd_present(pmd))
		return false;

	if (radix_enabled())
		return radix__pmd_trans_huge(pmd);
	return hash__pmd_trans_huge(pmd);
}

-aneesh
