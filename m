Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D69A6B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:42:30 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 30-v6so1054630ots.12
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:42:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i5si9172854otd.274.2018.10.09.06.42.26
        for <linux-mm@kvack.org>;
        Tue, 09 Oct 2018 06:42:26 -0700 (PDT)
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c0a81be1-4734-2ff8-4167-6d5e219008e6@arm.com>
Date: Tue, 9 Oct 2018 19:12:21 +0530
MIME-Version: 1.0
In-Reply-To: <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu, will.deacon@arm.com



On 10/09/2018 06:34 PM, Kirill A. Shutemov wrote:
> On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
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
>> returns positive for both mapped and migration entries. Could some one
>> please explain why pmd_trans_huge() has to return false for migration
>> entries which just install swap bits and its still a PMD ?
> 
> I guess it's just a design choice. Any reason why arm64 cannot do the
> same?
>
I think probably it can do. I am happy to look into these in detail what
will make pmd_trans_huge() return false on migration entries but it does
not quite sound like a right semantic at the moment.

>> Nonetheless pmd_present() seems to be a better check to distinguish
>> between mapped and (non-mapped non-present) migration entries without
>> any ambiguity.
> 
> Can we instead reverse order of check:
> 
> if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
> 	pvmw->ptl = pmd_lock(mm, pvmw->pmd);
> 	if (!pmd_present(*pvmw->pmd)) {
> 		...
> 	} else if (likely(pmd_trans_huge(*pvmw->pmd))) {
> 		...
> 	} else {
> 		...
> 	}
> ...
> 
> This should cover both imeplementations of pmd_trans_huge().

Yeah it does cover and I have tested it first before proposing the current
patch. The only problem is that the order saves the code :) Having another
reasonable check like pmd_present() prevents it from being broken if the
code block moves around for some reason. But I am happy to do either way.
