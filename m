Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 276106B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:02:45 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id j65-v6so8062613otc.5
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 01:02:45 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w50si211717oti.317.2018.10.12.01.02.44
        for <linux-mm@kvack.org>;
        Fri, 12 Oct 2018 01:02:44 -0700 (PDT)
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <20181009130421.bmus632ocurn275u@kshutemo-mobl1>
 <20181009131803.GH6248@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <fb0ee5dd-5799-f5af-891a-992dd9a16a9f@arm.com>
Date: Fri, 12 Oct 2018 13:32:39 +0530
MIME-Version: 1.0
In-Reply-To: <20181009131803.GH6248@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu



On 10/09/2018 06:48 PM, Will Deacon wrote:
> On Tue, Oct 09, 2018 at 04:04:21PM +0300, Kirill A. Shutemov wrote:
>> On Tue, Oct 09, 2018 at 09:28:58AM +0530, Anshuman Khandual wrote:
>>> A normal mapped THP page at PMD level should be correctly differentiated
>>> from a PMD migration entry while walking the page table. A mapped THP would
>>> additionally check positive for pmd_present() along with pmd_trans_huge()
>>> as compared to a PMD migration entry. This just adds a new conditional test
>>> differentiating the two while walking the page table.
>>>
>>> Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>> On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
>>> exclusive which makes the current conditional block work for both mapped
>>> and migration entries. This is not same with arm64 where pmd_trans_huge()
>>> returns positive for both mapped and migration entries. Could some one
>>> please explain why pmd_trans_huge() has to return false for migration
>>> entries which just install swap bits and its still a PMD ?
>>
>> I guess it's just a design choice. Any reason why arm64 cannot do the
>> same?
> 
> Anshuman, would it work to:
> 
> #define pmd_trans_huge(pmd)     (pmd_present(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
yeah this works but some how does not seem like the right thing to do
but can be the very last option.
