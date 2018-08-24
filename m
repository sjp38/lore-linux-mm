Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14ECD6B2E76
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:58:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id v26-v6so3313173eds.9
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:58:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si3186538edp.145.2018.08.24.00.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 00:58:16 -0700 (PDT)
Date: Fri, 24 Aug 2018 09:58:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetlb: filter out hugetlb pages if HUGEPAGE
 migration is not supported.
Message-ID: <20180824075815.GA29735@dhcp22.suse.cz>
References: <20180824063314.21981-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824063314.21981-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri 24-08-18 12:03:14, Aneesh Kumar K.V wrote:
> When scanning for movable pages, filter out Hugetlb pages if hugepage migration
> is not supported. Without this we hit infinte loop in __offline pages where we
> do
> 	pfn = scan_movable_pages(start_pfn, end_pfn);
> 	if (pfn) { /* We have movable pages */
> 		ret = do_migrate_range(pfn, end_pfn);
> 		goto repeat;
> 	}
> 
> We do support hugetlb migration ony if the hugetlb pages are at pmd level. Here
> we just check for Kernel config. The gigantic page size check is done in
> page_huge_active.

Well, this is a bit misleading. I would say that

Fix this by checking hugepage_migration_supported both in has_unmovable_pages
which is the primary backoff mechanism for page offlining and for
consistency reasons also into scan_movable_pages because it doesn't make
any sense to return a pfn to non-migrateable huge page.

> Acked-by: Michal Hocko <mhocko@suse.com>
> Reported-by: Haren Myneni <haren@linux.vnet.ibm.com>
> CC: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

I would add
Fixes: 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")

Not because the bug has been introduced by that commit but rather
because the issue would be latent before that commit.

My Acked-by still holds.

> ---
>  mm/memory_hotplug.c | 3 ++-
>  mm/page_alloc.c     | 4 ++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9eea6e809a4e..38d94b703e9d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1333,7 +1333,8 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  			if (__PageMovable(page))
>  				return pfn;
>  			if (PageHuge(page)) {
> -				if (page_huge_active(page))
> +				if (hugepage_migration_supported(page_hstate(page)) &&
> +				    page_huge_active(page))
>  					return pfn;
>  				else
>  					pfn = round_up(pfn + 1,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c677c1506d73..b8d91f59b836 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7709,6 +7709,10 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		 * handle each tail page individually in migration.
>  		 */
>  		if (PageHuge(page)) {
> +
> +			if (!hugepage_migration_supported(page_hstate(page)))
> +				goto unmovable;
> +
>  			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
>  			continue;
>  		}
> -- 
> 2.17.1

-- 
Michal Hocko
SUSE Labs
