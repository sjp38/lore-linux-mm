Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4AC6B0031
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 20:20:53 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so849576pbc.20
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 17:20:52 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id iy1si9050082pbb.115.2014.06.15.17.20.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Jun 2014 17:20:52 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so1181431pde.17
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 17:20:51 -0700 (PDT)
Date: Sun, 15 Jun 2014 17:19:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: fix copy_hugetlb_page_range() to handle
 migration/hwpoisoned entry
In-Reply-To: <1402081620-1247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1406151642020.25482@eggly.anvils>
References: <1402081620-1247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jun 2014, Naoya Horiguchi wrote:

> There's a race between fork() and hugepage migration, as a result we try to
> "dereference" a swap entry as a normal pte, causing kernel panic.
> The cause of the problem is that copy_hugetlb_page_range() can't handle "swap
> entry" family (migration entry and hwpoisoned entry,) so let's fix it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v2.6.36+

Seems a good catch.  But a few reservations...

> ---
>  include/linux/mm.h |  6 +++++
>  mm/hugetlb.c       | 72 ++++++++++++++++++++++++++++++++----------------------
>  mm/memory.c        |  5 ----
>  3 files changed, 49 insertions(+), 34 deletions(-)
> 
> diff --git v3.15-rc8.orig/include/linux/mm.h v3.15-rc8/include/linux/mm.h
> index d6777060449f..6b4fe9ec79ba 100644
> --- v3.15-rc8.orig/include/linux/mm.h
> +++ v3.15-rc8/include/linux/mm.h
> @@ -1924,6 +1924,12 @@ static inline struct vm_area_struct *find_exact_vma(struct mm_struct *mm,
>  	return vma;
>  }
>  
> +static inline bool is_cow_mapping(vm_flags_t flags)
> +{
> +	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> +}
> +
> +

This is an unrelated cleanup, which makes the patch unnecessarily larger,
needlessly touching include/linux/mm.h and mm/memory.c, making it more
likely not to apply to all the old releases you're asking for in the
stable line.

And 3.16-rc moves is_cow_mapping() to mm/internal.h not include/linux/mm.h.

>  #ifdef CONFIG_MMU
>  pgprot_t vm_get_page_prot(unsigned long vm_flags);
>  #else
> diff --git v3.15-rc8.orig/mm/hugetlb.c v3.15-rc8/mm/hugetlb.c
> index c82290b9c1fc..47ae7db288f7 100644
> --- v3.15-rc8.orig/mm/hugetlb.c
> +++ v3.15-rc8/mm/hugetlb.c
> @@ -2377,6 +2377,31 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
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
> @@ -2391,7 +2416,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  	unsigned long mmun_end;		/* For mmu_notifiers */
>  	int ret = 0;
>  
> -	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> +	cow = is_cow_mapping(vma->vm_flags);

So, just leave this out and it all becomes easier, no?

>  
>  	mmun_start = vma->vm_start;
>  	mmun_end = vma->vm_end;
> @@ -2416,10 +2441,25 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  		dst_ptl = huge_pte_lock(h, dst, dst_pte);
>  		src_ptl = huge_pte_lockptr(h, src, src_pte);
>  		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
> -		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> +		entry = huge_ptep_get(src_pte);
> +		if (huge_pte_none(entry)) { /* skip none entry */
> +			;

Not very pretty, but I would probably have made the same choice.

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
> +				set_pte_at(src, addr, src_pte, entry);
> +			}
> +			set_huge_pte_at(dst, addr, dst_pte, entry);

It's odd to see set_pte_at(src, addr, src_pte, entry)
followed by     set_huge_pte_at(dst, addr, dst_pte, entry).

Probably they should both say set_huge_pte_at().  But have you
consulted the relevant architectures to check whether set_huge_pte_at()
actually works on a migration or poisoned entry, rather than corrupting it?

My quick reading is that only s390 and sparc provide a set_huge_pte_at()
which differs from set_pte_at(), and that sparc does not have the
pmd_huge_support() needed for hugepage_migration_support(); but s390's
set_huge_pte_at() looks as if it would mess up the migration entry.

Ah, but you have recently restricted hugepage migration to x86_64 only,
to fix the follow_page problems, so this should be okay for now - though
you appear to be leaving a dangerous landmine for s390 in future.

Hold on, that restriction of hugepage migration was marked for stable
3.12+, whereas this is marked for stable 2.6.36+ (a glance at my old
trees suggests 2.6.37+, but you may know better - perhaps hugepage
migration got backported to 2.6.36-stable, though hardly seems
stable material).

Perhaps you marked the disablement as 3.12+ because its patch wouldn't
apply cleanly earlier? but it really should be disabled as far back as
needed.  Or was there some other subtlety, so that hugepage migration
never actually happened before 3.12?

Confused.
Hugh

> +		} else {
>  			if (cow)
>  				huge_ptep_set_wrprotect(src, addr, src_pte);
> -			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
>  			page_dup_rmap(ptepage);
> @@ -2435,32 +2475,6 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
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
> diff --git v3.15-rc8.orig/mm/memory.c v3.15-rc8/mm/memory.c
> index 037b812a9531..efc66b128976 100644
> --- v3.15-rc8.orig/mm/memory.c
> +++ v3.15-rc8/mm/memory.c
> @@ -698,11 +698,6 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
>  	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>  }
>  
> -static inline bool is_cow_mapping(vm_flags_t flags)
> -{
> -	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> -}
> -
>  /*
>   * vm_normal_page -- This function gets the "struct page" associated with a pte.
>   *
> -- 
> 1.9.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
