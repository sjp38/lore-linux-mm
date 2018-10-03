Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 646C06B0005
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 22:16:35 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q12-v6so2780042otf.20
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 19:16:35 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y20-v6si3205495oix.91.2018.10.02.19.16.33
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 19:16:33 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <20181002123909.GS18290@dhcp22.suse.cz>
Message-ID: <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
Date: Wed, 3 Oct 2018 07:46:27 +0530
MIME-Version: 1.0
In-Reply-To: <20181002123909.GS18290@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/02/2018 06:09 PM, Michal Hocko wrote:
> On Tue 02-10-18 17:45:28, Anshuman Khandual wrote:
>> Architectures like arm64 have PUD level HugeTLB pages for certain configs
>> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
>> enabled for migration. It can be achieved through checking for PUD_SHIFT
>> order based HugeTLB pages during migration.
> 
> Well a long term problem with hugepage_migration_supported is that it is
> used in two different context 1) to bail out from the migration early
> because the arch doesn't support migration at all and 2) to use movable
> zone for hugetlb pages allocation. I am especially concerned about the
> later because the mere support for migration is not really good enough.
> Are you really able to find a different giga page during the runtime to
> move an existing giga page out of the movable zone?

I pre-allocate them before trying to initiate the migration (soft offline
in my experiments). Hence it should come from the pre-allocated HugeTLB
pool instead from the buddy. I might be missing something here but do we
ever allocate HugeTLB on the go when trying to migrate ? IIUC it always
came from the pool (unless its something related to ovecommit/surplus).
Could you please kindly explain regarding how migration target HugeTLB
pages are allocated on the fly from movable zone.

But even if there are some chances of run time allocation failure from
movable zone (as in point 2) that should not block the very initiation
of migration itself. IIUC thats not the semantics for either THP or
normal pages. Why should it be different here. If the allocation fails
we should report and abort as always. Its the caller of migration taking
the chances. why should we prevent that.

> 
> So I guess we want to split this into two functions
> arch_hugepage_migration_supported and hugepage_movable. The later would

So the set difference between arch_hugepage_migration_supported and 
hugepage_movable still remains un-migratable ? Then what is the purpose
for arch_hugepage_migration_supported page size set in the first place.
Does it mean we allow the migration at the beginning and the abort later
when the page size does not fall within the subset for hugepage_movable.
Could you please kindly explain this in more detail.

> be a reasonably migrateable subset of the former. Without that this
> patch migth introduce subtle regressions when somebody relies on movable
> zone to be really movable.
PUD based HugeTLB pages were never migratable, then how can there be any
regression here ? At present we even support PGD based HugeTLB pages for
migration. Wondering how PUD based ones are going to be any different.
