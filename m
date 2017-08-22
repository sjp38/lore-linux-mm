Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A30702806E4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 11:32:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q3so112464993pgr.3
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:32:44 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z9si8903702pgo.45.2017.08.22.08.32.42
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 08:32:42 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2] mm/hugetlb.c: make huge_pte_offset() consistent and document behaviour
References: <20170725154114.24131-2-punit.agrawal@arm.com>
	<20170818145415.7588-1-punit.agrawal@arm.com>
	<3de49294-f6f8-2623-1778-56a3b092f2a5@oracle.com>
	<20170821180741.4ns2s4wp3t2r6mpi@armageddon.cambridge.arm.com>
	<b64b8eb3-3fe5-5bad-eb01-1bc8a87378d5@oracle.com>
Date: Tue, 22 Aug 2017 16:32:39 +0100
In-Reply-To: <b64b8eb3-3fe5-5bad-eb01-1bc8a87378d5@oracle.com> (Mike Kravetz's
	message of "Mon, 21 Aug 2017 14:30:33 -0700")
Message-ID: <87shgjmxd4.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>

Hi Mike,

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 08/21/2017 11:07 AM, Catalin Marinas wrote:
>> On Fri, Aug 18, 2017 at 02:29:18PM -0700, Mike Kravetz wrote:
>>> On 08/18/2017 07:54 AM, Punit Agrawal wrote:
>>>> When walking the page tables to resolve an address that points to
>>>> !p*d_present() entry, huge_pte_offset() returns inconsistent values
>>>> depending on the level of page table (PUD or PMD).
>>>>
>>>> It returns NULL in the case of a PUD entry while in the case of a PMD
>>>> entry, it returns a pointer to the page table entry.
>>>>
>>>> A similar inconsitency exists when handling swap entries - returns NULL
>>>> for a PUD entry while a pointer to the pte_t is retured for the PMD entry.
>>>>
>>>> Update huge_pte_offset() to make the behaviour consistent - return a
>>>> pointer to the pte_t for hugepage or swap entries. Only return NULL in
>>>> instances where we have a p*d_none() entry and the size parameter
>>>> doesn't match the hugepage size at this level of the page table.
>>>>
>>>> Document the behaviour to clarify the expected behaviour of this function.
>>>> This is to set clear semantics for architecture specific implementations
>>>> of huge_pte_offset().
>>>>
>>>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>>>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>> Cc: Steve Capper <steve.capper@arm.com>
>>>> Cc: Will Deacon <will.deacon@arm.com>
>>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>>>> ---
>>>>
>>>> Hi Andrew,
>>>>
>>>> From discussions on the arm64 implementation of huge_pte_offset()[0]
>>>> we realised that there is benefit from returning a pte_t* in the case
>>>> of p*d_none().
>>>>
>>>> The fault handling code in hugetlb_fault() can handle p*d_none()
>>>> entries and saves an extra round trip to huge_pte_alloc(). Other
>>>> callers of huge_pte_offset() should be ok as well.
>>>
>>> Yes, this change would eliminate that call to huge_pte_alloc() in
>>> hugetlb_fault().  However, huge_pte_offset() is now returning a pointer
>>> to a p*d_none() pte in some instances where it would have previously
>>> returned NULL.  Correct?
>> 
>> Yes (whether it was previously the right thing to return is a different
>> matter; that's what we are trying to clarify in the generic code so that
>> we can have similar semantics on arm64).
>> 
>>> I went through the callers, and like you am fairly confident that they
>>> can handle this situation.  But, returning  p*d_none() instead of NULL
>>> does change the execution path in several routines such as
>>> copy_hugetlb_page_range, __unmap_hugepage_range hugetlb_change_protection,
>>> and follow_hugetlb_page.  If huge_pte_alloc() returns NULL to these
>>> routines, they do a quick continue, exit, etc.  If they are returned
>>> a pointer, they typically lock the page table(s) and then check for
>>> p*d_none() before continuing, exiting, etc.  So, it appears that these
>>> routines could potentially slow down a bit with this change (in the specific
>>> case of p*d_none).
>> 
>> Arguably (well, my interpretation), it should return a NULL only if the
>> entry is a table entry, potentially pointing to a next level (pmd). In
>> the pud case, this means that sz < PUD_SIZE.
>> 
>> If the pud is a last level huge page entry (either present or !present),
>> huge_pte_offset() should return the pointer to it and never NULL. If the
>> entry is a swap or migration one (pte_present() == false) with the
>> current code we don't even enter the corresponding checks in
>> copy_hugetlb_page_range().
>> 
>> I also assume that the ptl __unmap_hugepage_range() is taken to avoid
>> some race when the entry is a huge page (present or not). If such race
>> doesn't exist, we could as well check the huge_pte_none() outside the
>> locked region (which is what the current huge_pte_offset() does with
>> !pud_present()).
>> 
>> IMHO, while the current generic huge_pte_offset() avoids some code paths
>> in the functions you mentioned, the results are not always correct
>> (missing swap/migration entries or potentially racy).
>
> Thanks Catalin,
>
> The more I look at this code and think about it, the more I like it.  As
> Michal previously mentioned, changes in this area can break things in subtle
> ways.  That is why I was cautious and asked for more people to look at it.
> My primary concerns with these changes in this area were:
> - Any potential changes in behavior.  I think this has been sufficiently
>   explored.  While there may be small differences in behavior (for the
>   better), this change should not introduce any bugs/breakage.
> - Other arch specific implementations are not aligned with the new
>   behavior.  Again, this should not cause any issues.  Punit (and I) have
>   looked at the arch specific implementations for issues and found none.
>   In addition, since we are not changing any of the 'calling code', no
>   issues should be introduced for arch specific implementations.
>
> I like the new semantics and did not find any issues.
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks for reviewing the updated semantics against existing usage. I'll
monitor the lists for any reported breakage but please do shout out if
you notice any issues.

Thanks,
Punit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
