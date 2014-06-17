Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 20B046B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:35:57 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so5844569pdi.4
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:35:56 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id gn5si15335434pbb.200.2014.06.17.11.35.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 11:35:56 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so4170999pad.23
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:35:55 -0700 (PDT)
Date: Tue, 17 Jun 2014 11:34:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] hugetlb: fix copy_hugetlb_page_range() to handle
 migration/hwpoisoned entry
In-Reply-To: <1403012995-538-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1406171049150.2862@eggly.anvils>
References: <alpine.LSU.2.11.1406161750520.1190@eggly.anvils> <1403012995-538-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 Jun 2014, Naoya Horiguchi wrote:

> There's a race between fork() and hugepage migration, as a result we try to
> "dereference" a swap entry as a normal pte, causing kernel panic.
> The cause of the problem is that copy_hugetlb_page_range() can't handle "swap
> entry" family (migration entry and hwpoisoned entry,) so let's fix it.
> 
> ChangeLog v2:
> - stop applying is_cow_mapping() in copy_hugetlb_page_range()
> - use set_huge_pte_at() in hugepage code
> - fix stable version
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v2.6.37+

Acked-by: Hugh Dickins <hughd@google.com>

But I do hope that you have made an unmissable note somewhere, that
the s390 and sparc set_huge_pte_at() will probably need fixing to handle
this non-present case, before hugepage migration can be allowed on them.

There's probably an easy patch for s390. but not so obvious for sparc
(which did not pretend to support hugepage migration before anyway).

And a followup not-for-stable cleanup to this patch would be nice:
testing is_hugetlb_entry_migration() and is_huge_tlb_entry_hwpoisoned()
separately, when they're doing almost the same thing, seems a bit daft.

Hmm, but maybe that should be part of a larger job: the handling of
non-swap swap-entries is tiresome in lots of places, I wonder if
there's a more convenient way of handling them everywhere.

Hugh

> ---
>  mm/hugetlb.c | 70 ++++++++++++++++++++++++++++++++++++------------------------
>  1 file changed, 42 insertions(+), 28 deletions(-)
> 
> diff --git v3.16-rc1.orig/mm/hugetlb.c v3.16-rc1/mm/hugetlb.c
> index 226910cb7c9b..a3f6349ab5b5 100644
> --- v3.16-rc1.orig/mm/hugetlb.c
> +++ v3.16-rc1/mm/hugetlb.c
> @@ -2520,6 +2520,31 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
>  		update_mmu_cache(vma, address, ptep);
>  }
>  
> +static int is_hugetlb_entry_migration(pte_t pte)
> +{
> +	swp_entry_t swp;
> +
> +	if (huge_pte_none(pte) || pte_present(pte))
> +		return 0;
> +	swp = pte_to_swp_entry(pte);
> +	if (non_swap_entry(swp) && is_migration_entry(swp))
> +		return 1;
> +	else
> +		return 0;
> +}
> +
> +static int is_hugetlb_entry_hwpoisoned(pte_t pte)
> +{
> +	swp_entry_t swp;
> +
> +	if (huge_pte_none(pte) || pte_present(pte))
> +		return 0;
> +	swp = pte_to_swp_entry(pte);
> +	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
> +		return 1;
> +	else
> +		return 0;
> +}
>  
>  int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  			    struct vm_area_struct *vma)
> @@ -2559,10 +2584,25 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  		dst_ptl = huge_pte_lock(h, dst, dst_pte);
>  		src_ptl = huge_pte_lockptr(h, src, src_pte);
>  		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
> -		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> +		entry = huge_ptep_get(src_pte);
> +		if (huge_pte_none(entry)) { /* skip none entry */
> +			;
> +		} else if (unlikely(is_hugetlb_entry_migration(entry) ||
> +				    is_hugetlb_entry_hwpoisoned(entry))) {
> +			swp_entry_t swp_entry = pte_to_swp_entry(entry);
> +			if (is_write_migration_entry(swp_entry) && cow) {
> +				/*
> +				 * COW mappings require pages in both
> +				 * parent and child to be set to read.
> +				 */
> +				make_migration_entry_read(&swp_entry);
> +				entry = swp_entry_to_pte(swp_entry);
> +				set_huge_pte_at(src, addr, src_pte, entry);
> +			}
> +			set_huge_pte_at(dst, addr, dst_pte, entry);
> +		} else {
>  			if (cow)
>  				huge_ptep_set_wrprotect(src, addr, src_pte);
> -			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
>  			page_dup_rmap(ptepage);
> @@ -2578,32 +2618,6 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	return ret;
>  }
>  
> -static int is_hugetlb_entry_migration(pte_t pte)
> -{
> -	swp_entry_t swp;
> -
> -	if (huge_pte_none(pte) || pte_present(pte))
> -		return 0;
> -	swp = pte_to_swp_entry(pte);
> -	if (non_swap_entry(swp) && is_migration_entry(swp))
> -		return 1;
> -	else
> -		return 0;
> -}
> -
> -static int is_hugetlb_entry_hwpoisoned(pte_t pte)
> -{
> -	swp_entry_t swp;
> -
> -	if (huge_pte_none(pte) || pte_present(pte))
> -		return 0;
> -	swp = pte_to_swp_entry(pte);
> -	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
> -		return 1;
> -	else
> -		return 0;
> -}
> -
>  void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			    unsigned long start, unsigned long end,
>  			    struct page *ref_page)
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
