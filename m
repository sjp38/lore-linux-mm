Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAA926B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:05:43 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id s128-v6so2710911ois.18
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 21:05:43 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 200-v6si10571421oic.153.2018.10.09.21.05.42
        for <linux-mm@kvack.org>;
        Tue, 09 Oct 2018 21:05:42 -0700 (PDT)
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
Date: Wed, 10 Oct 2018 09:35:37 +0530
MIME-Version: 1.0
In-Reply-To: <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>



On 10/09/2018 07:28 PM, Zi Yan wrote:
> cc: Naoya Horiguchi (who proposed to use !_PAGE_PRESENT && !_PAGE_PSE for x86
> PMD migration entry check)
> 
> On 8 Oct 2018, at 23:58, Anshuman Khandual wrote:
> 
>> A normal mapped THP page at PMD level should be correctly differentiated
>> from a PMD migration entry while walking the page table. A mapped THP would
>> additionally check positive for pmd_present() along with pmd_trans_huge()
>> as compared to a PMD migration entry. This just adds a new conditional test
>> differentiating the two while walking the page table.
>>
>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>> exclusive which makes the current conditional block work for both mapped
>> and migration entries. This is not same with arm64 where pmd_trans_huge()
> 
> !pmd_present() && pmd_trans_huge() is used to represent THPs under splitting,

Not really if we just look at code in the conditional blocks.

> since _PAGE_PRESENT is cleared during THP splitting but _PAGE_PSE is not.
> See the comment in pmd_present() for x86, in arch/x86/include/asm/pgtable.h


        if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
                pvmw->ptl = pmd_lock(mm, pvmw->pmd);
                if (likely(pmd_trans_huge(*pvmw->pmd))) {
                        if (pvmw->flags & PVMW_MIGRATION)
                                return not_found(pvmw);
                        if (pmd_page(*pvmw->pmd) != page)
                                return not_found(pvmw);
                        return true;
                } else if (!pmd_present(*pvmw->pmd)) {
                        if (thp_migration_supported()) {
                                if (!(pvmw->flags & PVMW_MIGRATION))
                                        return not_found(pvmw);
                                if (is_migration_entry(pmd_to_swp_entry(*pvmw->pmd))) {
                                        swp_entry_t entry = pmd_to_swp_entry(*pvmw->pmd);

                                        if (migration_entry_to_page(entry) != page)
                                                return not_found(pvmw);
                                        return true;
                                }
                        }
                        return not_found(pvmw);
                } else {
                        /* THP pmd was split under us: handle on pte level */
                        spin_unlock(pvmw->ptl);
                        pvmw->ptl = NULL;
                }
        } else if (!pmd_present(pmde)) { ---> Outer 'else if'
                return false;
        }

Looking at the above code, it seems the conditional check for a THP
splitting case would be (!pmd_trans_huge && pmd_present) instead as
it has skipped the first two conditions. But THP splitting must have
been initiated once it has cleared the outer check (else it would not
have cleared otherwise)

if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)).


BTW what PMD state does the outer 'else if' block identify which must
have cleared the following condition to get there.

(!pmd_present && !pmd_trans_huge && !is_pmd_migration_entry)
