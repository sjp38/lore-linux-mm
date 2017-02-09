Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA0E56B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:19:03 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id w107so16831680ota.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:19:03 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id h20si4414212oib.88.2017.02.09.01.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 01:19:02 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 08/14] mm: thp: enable thp migration in generic path
Date: Thu, 9 Feb 2017 09:15:29 +0000
Message-ID: <20170209091528.GB15649@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-9-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-9-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5B16B48F351C804596FCEC8BC9D6205D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Sun, Feb 05, 2017 at 11:12:46AM -0500, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> This patch adds thp migration's core code, including conversions
> between a PMD entry and a swap entry, setting PMD migration entry,
> removing PMD migration entry, and waiting on PMD migration entries.
>=20
> This patch makes it possible to support thp migration.
> If you fail to allocate a destination page as a thp, you just split
> the source thp as we do now, and then enter the normal page migration.
> If you succeed to allocate destination thp, you enter thp migration.
> Subsequent patches actually enable thp migration for each caller of
> page migration by allowing its get_new_page() callback to
> allocate thps.
>=20
> ChangeLog v1 -> v2:
> - support pte-mapped thp, doubly-mapped thp
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> ChangeLog v2 -> v3:
> - use page_vma_mapped_walk()
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/include/asm/pgtable_64.h |   2 +
>  include/linux/swapops.h           |  70 +++++++++++++++++-
>  mm/huge_memory.c                  | 151 ++++++++++++++++++++++++++++++++=
++----
>  mm/migrate.c                      |  29 +++++++-
>  mm/page_vma_mapped.c              |  13 +++-
>  mm/pgtable-generic.c              |   3 +-
>  mm/rmap.c                         |  14 +++-
>  7 files changed, 259 insertions(+), 23 deletions(-)
>=20
...
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 6893c47428b6..fd54bbdc16cf 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1613,20 +1613,51 @@ int __zap_huge_pmd_locked(struct mmu_gather *tlb,=
 struct vm_area_struct *vma,
>  		atomic_long_dec(&tlb->mm->nr_ptes);
>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>  	} else {
> -		struct page *page =3D pmd_page(orig_pmd);
> -		page_remove_rmap(page, true);
> -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> -		VM_BUG_ON_PAGE(!PageHead(page), page);
> -		if (PageAnon(page)) {
> -			pgtable_t pgtable;
> -			pgtable =3D pgtable_trans_huge_withdraw(tlb->mm, pmd);
> -			pte_free(tlb->mm, pgtable);
> -			atomic_long_dec(&tlb->mm->nr_ptes);
> -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +		struct page *page;
> +		int migration =3D 0;
> +
> +		if (!is_pmd_migration_entry(orig_pmd)) {
> +			page =3D pmd_page(orig_pmd);
> +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> +			VM_BUG_ON_PAGE(!PageHead(page), page);
> +			page_remove_rmap(page, true);

> +			if (PageAnon(page)) {
> +				pgtable_t pgtable;
> +
> +				pgtable =3D pgtable_trans_huge_withdraw(tlb->mm,
> +								      pmd);
> +				pte_free(tlb->mm, pgtable);
> +				atomic_long_dec(&tlb->mm->nr_ptes);
> +				add_mm_counter(tlb->mm, MM_ANONPAGES,
> +					       -HPAGE_PMD_NR);
> +			} else {
> +				if (arch_needs_pgtable_deposit())
> +					zap_deposited_table(tlb->mm, pmd);
> +				add_mm_counter(tlb->mm, MM_FILEPAGES,
> +					       -HPAGE_PMD_NR);
> +			}

This block is exactly equal to the one in else block below,
So you can factor out into some function.

>  		} else {
> -			if (arch_needs_pgtable_deposit())
> -				zap_deposited_table(tlb->mm, pmd);
> -			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +			swp_entry_t entry;
> +
> +			entry =3D pmd_to_swp_entry(orig_pmd);
> +			page =3D pfn_to_page(swp_offset(entry));

> +			if (PageAnon(page)) {
> +				pgtable_t pgtable;
> +
> +				pgtable =3D pgtable_trans_huge_withdraw(tlb->mm,
> +								      pmd);
> +				pte_free(tlb->mm, pgtable);
> +				atomic_long_dec(&tlb->mm->nr_ptes);
> +				add_mm_counter(tlb->mm, MM_ANONPAGES,
> +					       -HPAGE_PMD_NR);
> +			} else {
> +				if (arch_needs_pgtable_deposit())
> +					zap_deposited_table(tlb->mm, pmd);
> +				add_mm_counter(tlb->mm, MM_FILEPAGES,
> +					       -HPAGE_PMD_NR);
> +			}

> +			free_swap_and_cache(entry); /* waring in failure? */
> +			migration =3D 1;
>  		}
>  		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>  	}
> @@ -2634,3 +2665,97 @@ static int __init split_huge_pages_debugfs(void)
>  }
>  late_initcall(split_huge_pages_debugfs);
>  #endif
> +
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
> +		struct page *page)
> +{
> +	struct vm_area_struct *vma =3D pvmw->vma;
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	unsigned long address =3D pvmw->address;
> +	pmd_t pmdval;
> +	swp_entry_t entry;
> +
> +	if (pvmw->pmd && !pvmw->pte) {
> +		pmd_t pmdswp;
> +
> +		mmu_notifier_invalidate_range_start(mm, address,
> +				address + HPAGE_PMD_SIZE);

Don't you have to put mmu_notifier_invalidate_range_* outside this if block=
?

Thanks,
Naoya Horiguchi

> +
> +		flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
> +		pmdval =3D pmdp_huge_clear_flush(vma, address, pvmw->pmd);
> +		if (pmd_dirty(pmdval))
> +			set_page_dirty(page);
> +		entry =3D make_migration_entry(page, pmd_write(pmdval));
> +		pmdswp =3D swp_entry_to_pmd(entry);
> +		set_pmd_at(mm, address, pvmw->pmd, pmdswp);
> +		page_remove_rmap(page, true);
> +		put_page(page);
> +
> +		mmu_notifier_invalidate_range_end(mm, address,
> +				address + HPAGE_PMD_SIZE);
> +	} else { /* pte-mapped thp */
> +		pte_t pteval;
> +		struct page *subpage =3D page - page_to_pfn(page) + pte_pfn(*pvmw->pte=
);
> +		pte_t swp_pte;
> +
> +		pteval =3D ptep_clear_flush(vma, address, pvmw->pte);
> +		if (pte_dirty(pteval))
> +			set_page_dirty(subpage);
> +		entry =3D make_migration_entry(subpage, pte_write(pteval));
> +		swp_pte =3D swp_entry_to_pte(entry);
> +		set_pte_at(mm, address, pvmw->pte, swp_pte);
> +		page_remove_rmap(subpage, false);
> +		put_page(subpage);
> +	}
> +}
> +
> +void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page=
 *new)
> +{
> +	struct vm_area_struct *vma =3D pvmw->vma;
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	unsigned long address =3D pvmw->address;
> +	swp_entry_t entry;
> +
> +	/* PMD-mapped THP  */
> +	if (pvmw->pmd && !pvmw->pte) {
> +		unsigned long mmun_start =3D address & HPAGE_PMD_MASK;
> +		unsigned long mmun_end =3D mmun_start + HPAGE_PMD_SIZE;
> +		pmd_t pmde;
> +
> +		entry =3D pmd_to_swp_entry(*pvmw->pmd);
> +		get_page(new);
> +		pmde =3D pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
> +		if (is_write_migration_entry(entry))
> +			pmde =3D maybe_pmd_mkwrite(pmde, vma);
> +
> +		flush_cache_range(vma, mmun_start, mmun_end);
> +		page_add_anon_rmap(new, vma, mmun_start, true);
> +		pmdp_huge_clear_flush_notify(vma, mmun_start, pvmw->pmd);
> +		set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
> +		flush_tlb_range(vma, mmun_start, mmun_end);
> +		if (vma->vm_flags & VM_LOCKED)
> +			mlock_vma_page(new);
> +		update_mmu_cache_pmd(vma, address, pvmw->pmd);
> +
> +	} else { /* pte-mapped thp */
> +		pte_t pte;
> +		pte_t *ptep =3D pvmw->pte;
> +
> +		entry =3D pte_to_swp_entry(*pvmw->pte);
> +		get_page(new);
> +		pte =3D pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
> +		if (pte_swp_soft_dirty(*pvmw->pte))
> +			pte =3D pte_mksoft_dirty(pte);
> +		if (is_write_migration_entry(entry))
> +			pte =3D maybe_mkwrite(pte, vma);
> +		flush_dcache_page(new);
> +		set_pte_at(mm, address, ptep, pte);
> +		if (PageAnon(new))
> +			page_add_anon_rmap(new, vma, address, false);
> +		else
> +			page_add_file_rmap(new, false);
> +		update_mmu_cache(vma, address, ptep);
> +	}
> +}
> +#endif
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 95e8580dc902..84181a3668c6 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -214,6 +214,12 @@ static int remove_migration_pte(struct page *page, s=
truct vm_area_struct *vma,
>  		new =3D page - pvmw.page->index +
>  			linear_page_index(vma, pvmw.address);
> =20
> +		/* PMD-mapped THP migration entry */
> +		if (!PageHuge(page) && PageTransCompound(page)) {
> +			remove_migration_pmd(&pvmw, new);
> +			continue;
> +		}
> +
>  		get_page(new);
>  		pte =3D pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
>  		if (pte_swp_soft_dirty(*pvmw.pte))
> @@ -327,6 +333,27 @@ void migration_entry_wait_huge(struct vm_area_struct=
 *vma,
>  	__migration_entry_wait(mm, pte, ptl);
>  }
> =20
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
> +{
> +	spinlock_t *ptl;
> +	struct page *page;
> +
> +	ptl =3D pmd_lock(mm, pmd);
> +	if (!is_pmd_migration_entry(*pmd))
> +		goto unlock;
> +	page =3D migration_entry_to_page(pmd_to_swp_entry(*pmd));
> +	if (!get_page_unless_zero(page))
> +		goto unlock;
> +	spin_unlock(ptl);
> +	wait_on_page_locked(page);
> +	put_page(page);
> +	return;
> +unlock:
> +	spin_unlock(ptl);
> +}
> +#endif
> +
>  #ifdef CONFIG_BLOCK
>  /* Returns true if all buffers are successfully locked */
>  static bool buffer_migrate_lock_buffers(struct buffer_head *head,
> @@ -1085,7 +1112,7 @@ static ICE_noinline int unmap_and_move(new_page_t g=
et_new_page,
>  		goto out;
>  	}
> =20
> -	if (unlikely(PageTransHuge(page))) {
> +	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
>  		lock_page(page);
>  		rc =3D split_huge_page(page);
>  		unlock_page(page);
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index a23001a22c15..0ed3aee62d50 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -137,16 +137,23 @@ bool page_vma_mapped_walk(struct page_vma_mapped_wa=
lk *pvmw)
>  	if (!pud_present(*pud))
>  		return false;
>  	pvmw->pmd =3D pmd_offset(pud, pvmw->address);
> -	if (pmd_trans_huge(*pvmw->pmd)) {
> +	if (pmd_trans_huge(*pvmw->pmd) || is_pmd_migration_entry(*pvmw->pmd)) {
>  		pvmw->ptl =3D pmd_lock(mm, pvmw->pmd);
> -		if (!pmd_present(*pvmw->pmd))
> -			return not_found(pvmw);
>  		if (likely(pmd_trans_huge(*pvmw->pmd))) {
>  			if (pvmw->flags & PVMW_MIGRATION)
>  				return not_found(pvmw);
>  			if (pmd_page(*pvmw->pmd) !=3D page)
>  				return not_found(pvmw);
>  			return true;
> +		} else if (!pmd_present(*pvmw->pmd)) {
> +			if (unlikely(is_migration_entry(pmd_to_swp_entry(*pvmw->pmd)))) {
> +				swp_entry_t entry =3D pmd_to_swp_entry(*pvmw->pmd);
> +
> +				if (migration_entry_to_page(entry) !=3D page)
> +					return not_found(pvmw);
> +				return true;
> +			}
> +			return not_found(pvmw);
>  		} else {
>  			/* THP pmd was split under us: handle on pte level */
>  			spin_unlock(pvmw->ptl);
> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
> index 4ed5908c65b0..9d550a8a0c71 100644
> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vm=
a, unsigned long address,
>  {
>  	pmd_t pmd;
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
> +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
> +		  !pmd_devmap(*pmdp));
>  	pmd =3D pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
>  	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>  	return pmd;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 16789b936e3a..b33216668fa4 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1304,6 +1304,7 @@ static int try_to_unmap_one(struct page *page, stru=
ct vm_area_struct *vma,
>  	struct rmap_private *rp =3D arg;
>  	enum ttu_flags flags =3D rp->flags;
> =20
> +
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>  		return SWAP_AGAIN;
> @@ -1314,12 +1315,19 @@ static int try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  	}
> =20
>  	while (page_vma_mapped_walk(&pvmw)) {
> +		/* THP migration */
> +		if (flags & TTU_MIGRATION) {
> +			if (!PageHuge(page) && PageTransCompound(page)) {
> +				set_pmd_migration_entry(&pvmw, page);
> +				continue;
> +			}
> +		}
> +		/* Unexpected PMD-mapped THP */
> +		VM_BUG_ON_PAGE(!pvmw.pte, page);
> +
>  		subpage =3D page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>  		address =3D pvmw.address;
> =20
> -		/* Unexpected PMD-mapped THP? */
> -		VM_BUG_ON_PAGE(!pvmw.pte, page);
> -
>  		/*
>  		 * If the page is mlock()d, we cannot swap it out.
>  		 * If it's recently referenced (perhaps page_referenced
> --=20
> 2.11.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
