Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 040CB6B026A
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:39:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e7-v6so1129455edb.23
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:39:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1-v6si1604435ejg.144.2018.10.02.05.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 05:39:10 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:39:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
Message-ID: <20181002123909.GS18290@dhcp22.suse.cz>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Tue 02-10-18 17:45:28, Anshuman Khandual wrote:
> Architectures like arm64 have PUD level HugeTLB pages for certain configs
> (1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
> enabled for migration. It can be achieved through checking for PUD_SHIFT
> order based HugeTLB pages during migration.

Well a long term problem with hugepage_migration_supported is that it is
used in two different context 1) to bail out from the migration early
because the arch doesn't support migration at all and 2) to use movable
zone for hugetlb pages allocation. I am especially concerned about the
later because the mere support for migration is not really good enough.
Are you really able to find a different giga page during the runtime to
move an existing giga page out of the movable zone?

So I guess we want to split this into two functions
arch_hugepage_migration_supported and hugepage_movable. The later would
be a reasonably migrateable subset of the former. Without that this
patch migth introduce subtle regressions when somebody relies on movable
zone to be really movable.

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  include/linux/hugetlb.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 6b68e34..9c1b77f 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>  {
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	if ((huge_page_shift(h) == PMD_SHIFT) ||
> -		(huge_page_shift(h) == PGDIR_SHIFT))
> +		(huge_page_shift(h) == PUD_SHIFT) ||
> +			(huge_page_shift(h) == PGDIR_SHIFT))
>  		return true;
>  	else
>  		return false;
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
