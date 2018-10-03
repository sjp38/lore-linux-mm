Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1026B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 02:58:38 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so2468424edc.2
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 23:58:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e1-v6si428951ejf.266.2018.10.02.23.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 23:58:36 -0700 (PDT)
Date: Wed, 3 Oct 2018 08:58:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
Message-ID: <20181003065833.GD18290@dhcp22.suse.cz>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <20181002123909.GS18290@dhcp22.suse.cz>
 <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Wed 03-10-18 07:46:27, Anshuman Khandual wrote:
> 
> 
> On 10/02/2018 06:09 PM, Michal Hocko wrote:
> > On Tue 02-10-18 17:45:28, Anshuman Khandual wrote:
> >> Architectures like arm64 have PUD level HugeTLB pages for certain configs
> >> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
> >> enabled for migration. It can be achieved through checking for PUD_SHIFT
> >> order based HugeTLB pages during migration.
> > 
> > Well a long term problem with hugepage_migration_supported is that it is
> > used in two different context 1) to bail out from the migration early
> > because the arch doesn't support migration at all and 2) to use movable
> > zone for hugetlb pages allocation. I am especially concerned about the
> > later because the mere support for migration is not really good enough.
> > Are you really able to find a different giga page during the runtime to
> > move an existing giga page out of the movable zone?
> 
> I pre-allocate them before trying to initiate the migration (soft offline
> in my experiments). Hence it should come from the pre-allocated HugeTLB
> pool instead from the buddy. I might be missing something here but do we
> ever allocate HugeTLB on the go when trying to migrate ? IIUC it always
> came from the pool (unless its something related to ovecommit/surplus).
> Could you please kindly explain regarding how migration target HugeTLB
> pages are allocated on the fly from movable zone.

Hotplug comes to mind. You usually do not pre-allocate to cover full
node going offline. And people would like to do that. Another example is
CMA. You would really like to move pages out of the way.

> But even if there are some chances of run time allocation failure from
> movable zone (as in point 2) that should not block the very initiation
> of migration itself. IIUC thats not the semantics for either THP or
> normal pages. Why should it be different here. If the allocation fails
> we should report and abort as always. Its the caller of migration taking
> the chances. why should we prevent that.

Yes I agree, hence the distinction between the arch support for
migrateability and the criterion on the movable zone placement.
 
> > 
> > So I guess we want to split this into two functions
> > arch_hugepage_migration_supported and hugepage_movable. The later would
> 
> So the set difference between arch_hugepage_migration_supported and 
> hugepage_movable still remains un-migratable ? Then what is the purpose
> for arch_hugepage_migration_supported page size set in the first place.
> Does it mean we allow the migration at the beginning and the abort later
> when the page size does not fall within the subset for hugepage_movable.
> Could you please kindly explain this in more detail.

The purpose of arch_hugepage_migration_supported is to tell whether it
makes any sense to even try to migration. The allocation placement is
completely independent on this choice. The later just says whether it is
feasible to place a hugepage to the zone movable. Sure regular 2MB pages
do not guarantee movability as well because of the memory fragmentation.
But allocating a 2MB is a completely different storage from 1G or even
larger huge pages, isn't it?

> > be a reasonably migrateable subset of the former. Without that this
> > patch migth introduce subtle regressions when somebody relies on movable
> > zone to be really movable.
> PUD based HugeTLB pages were never migratable, then how can there be any
> regression here ?

That means that they haven't been allocated from the movable zone
before. Which is going to change by this patch.

> At present we even support PGD based HugeTLB pages for
> migration.

And that is already wrong but nobody probably cares because those are
rarely used.

> Wondering how PUD based ones are going to be any different.

It is not different, PGD is dubious already.
-- 
Michal Hocko
SUSE Labs
