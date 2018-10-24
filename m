Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6EE6B0005
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 09:54:57 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id be11-v6so2711909plb.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 06:54:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f185-v6si4607924pgc.339.2018.10.24.06.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 06:54:55 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:54:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 1/5] mm/hugetlb: Distinguish between migratability and
 movability
Message-ID: <20181024135452.GG18839@dhcp22.suse.cz>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540299721-26484-2-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Tue 23-10-18 18:31:57, Anshuman Khandual wrote:
> During huge page allocation it's migratability is checked to determine if
> it should be placed under movable zones with GFP_HIGHUSER_MOVABLE. But the
> movability aspect of the huge page could depend on other factors than just
> migratability. Movability in itself is a distinct property which should not
> be tied with migratability alone.
> 
> This differentiates these two and implements an enhanced movability check
> which also considers huge page size to determine if it is feasible to be
> placed under a movable zone. At present it just checks for gigantic pages
> but going forward it can incorporate other enhanced checks.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/hugetlb.h | 30 ++++++++++++++++++++++++++++++
>  mm/hugetlb.c            |  2 +-
>  mm/migrate.c            |  2 +-
>  3 files changed, 32 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 087fd5f4..1b858d7 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -506,6 +506,31 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>  #endif
>  }
>  
> +/*
> + * Movability check is different as compared to migration check.
> + * It determines whether or not a huge page should be placed on
> + * movable zone or not. Movability of any huge page should be
> + * required only if huge page size is supported for migration.
> + * There wont be any reason for the huge page to be movable if
> + * it is not migratable to start with. Also the size of the huge
> + * page should be large enough to be placed under a movable zone
> + * and still feasible enough to be migratable. Just the presence
> + * in movable zone does not make the migration feasible.
> + *
> + * So even though large huge page sizes like the gigantic ones
> + * are migratable they should not be movable because its not
> + * feasible to migrate them from movable zone.
> + */
> +static inline bool hugepage_movable_supported(struct hstate *h)
> +{
> +	if (!hugepage_migration_supported(h))
> +		return false;
> +
> +	if (hstate_is_gigantic(h))
> +		return false;
> +	return true;
> +}
> +
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  					   struct mm_struct *mm, pte_t *pte)
>  {
> @@ -602,6 +627,11 @@ static inline bool hugepage_migration_supported(struct hstate *h)
>  	return false;
>  }
>  
> +static inline bool hugepage_movable_supported(struct hstate *h)
> +{
> +	return false;
> +}
> +
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  					   struct mm_struct *mm, pte_t *pte)
>  {
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 5c390f5..f810cf0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -919,7 +919,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>  /* Movability of hugepages depends on migration support. */
>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> -	if (hugepage_migration_supported(h))
> +	if (hugepage_movable_supported(h))
>  		return GFP_HIGHUSER_MOVABLE;
>  	else
>  		return GFP_HIGHUSER;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 84381b5..bfda9e4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1272,7 +1272,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	struct anon_vma *anon_vma = NULL;
>  
>  	/*
> -	 * Movability of hugepages depends on architectures and hugepage size.
> +	 * Migratability of hugepages depends on architectures and their size.
>  	 * This check is necessary because some callers of hugepage migration
>  	 * like soft offline and memory hotremove don't walk through page
>  	 * tables or check whether the hugepage is pmd-based or not before
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
