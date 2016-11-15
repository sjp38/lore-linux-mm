Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D55BC6B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 23:59:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so91444137pgc.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 20:59:41 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id mk10si13974293pab.214.2016.11.14.20.59.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 20:59:40 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd
 migration
Date: Tue, 15 Nov 2016 04:57:15 +0000
Message-ID: <20161115045714.GB8738@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161114114503.GA9231@node.shutemov.name>
In-Reply-To: <20161114114503.GA9231@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CB041306BC7E534AB83CC61623E516E6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Nov 14, 2016 at 02:45:03PM +0300, Kirill A. Shutemov wrote:
> On Tue, Nov 08, 2016 at 08:31:50AM +0900, Naoya Horiguchi wrote:
> > This patch prepares thp migration's core code. These code will be open =
when
> > unmap_and_move() stops unconditionally splitting thp and get_new_page()=
 starts
> > to allocate destination thps.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> > ChangeLog v1 -> v2:
> > - support pte-mapped thp, doubly-mapped thp
> > ---
> >  arch/x86/include/asm/pgtable_64.h |   2 +
> >  include/linux/swapops.h           |  61 +++++++++++++++
> >  mm/huge_memory.c                  | 154 ++++++++++++++++++++++++++++++=
++++++++
> >  mm/migrate.c                      |  44 ++++++++++-
> >  mm/pgtable-generic.c              |   3 +-
> >  5 files changed, 262 insertions(+), 2 deletions(-)
> >=20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable=
_64.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_=
64.h
> > index 1cc82ec..3a1b48e 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_64.h
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtabl=
e_64.h
> > @@ -167,7 +167,9 @@ static inline int pgd_large(pgd_t pgd) { return 0; =
}
> >  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
> >  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
> >  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
> > +#define __pmd_to_swp_entry(pte)		((swp_entry_t) { pmd_val((pmd)) })
> >  #define __swp_entry_to_pte(x)		((pte_t) { .pte =3D (x).val })
> > +#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd =3D (x).val })
> > =20
> >  extern int kern_addr_valid(unsigned long addr);
> >  extern void cleanup_highmap(void);
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h v4.9=
-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
> > index 5c3a5f3..b6b22a2 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/swapops.h
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/swapops.h
> > @@ -163,6 +163,67 @@ static inline int is_write_migration_entry(swp_ent=
ry_t entry)
> > =20
> >  #endif
> > =20
> > +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> > +extern void set_pmd_migration_entry(struct page *page,
> > +		struct vm_area_struct *vma, unsigned long address);
> > +
> > +extern int remove_migration_pmd(struct page *new, pmd_t *pmd,
> > +		struct vm_area_struct *vma, unsigned long addr, void *old);
> > +
> > +extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)=
;
> > +
> > +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> > +{
> > +	swp_entry_t arch_entry;
> > +
> > +	arch_entry =3D __pmd_to_swp_entry(pmd);
> > +	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
> > +}
> > +
> > +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> > +{
> > +	swp_entry_t arch_entry;
> > +
> > +	arch_entry =3D __swp_entry(swp_type(entry), swp_offset(entry));
> > +	return __swp_entry_to_pmd(arch_entry);
> > +}
> > +
> > +static inline int is_pmd_migration_entry(pmd_t pmd)
> > +{
> > +	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd))=
;
> > +}
> > +#else
> > +static inline void set_pmd_migration_entry(struct page *page,
> > +			struct vm_area_struct *vma, unsigned long address)
> > +{
>=20
> VM_BUG()? Or BUILD_BUG()?

These should be compiled out, so BUILD_BUG() seems better to me.
3 routines below will be done in the same manner.

> > +}
> > +
> > +static inline int remove_migration_pmd(struct page *new, pmd_t *pmd,
> > +		struct vm_area_struct *vma, unsigned long addr, void *old)
> > +{
> > +	return 0;
>=20
> Ditto.
>=20
> > +}
> > +
> > +static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_t=
 *p) { }
> > +
> > +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
> > +{
> > +	return swp_entry(0, 0);
>=20
> Ditto.
>=20
> > +}
> > +
> > +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
> > +{
> > +	pmd_t pmd =3D {};
>=20
> Ditto.
>=20
> > +	return pmd;
> > +}
> > +
> > +static inline int is_pmd_migration_entry(pmd_t pmd)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  #ifdef CONFIG_MEMORY_FAILURE
> > =20
> >  extern atomic_long_t num_poisoned_pages __read_mostly;
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mm=
otm-2016-10-27-18-27_patched/mm/huge_memory.c
> > index 0509d17..b3022b3 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> > @@ -2310,3 +2310,157 @@ static int __init split_huge_pages_debugfs(void=
)
> >  }
> >  late_initcall(split_huge_pages_debugfs);
> >  #endif
> > +
> > +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> > +void set_pmd_migration_entry(struct page *page, struct vm_area_struct =
*vma,
> > +				unsigned long addr)
> > +{
> > +	struct mm_struct *mm =3D vma->vm_mm;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pmd_t pmdval;
> > +	swp_entry_t entry;
> > +	spinlock_t *ptl;
> > +
> > +	pgd =3D pgd_offset(mm, addr);
> > +	if (!pgd_present(*pgd))
> > +		return;
> > +	pud =3D pud_offset(pgd, addr);
> > +	if (!pud_present(*pud))
> > +		return;
> > +	pmd =3D pmd_offset(pud, addr);
> > +	pmdval =3D *pmd;
> > +	barrier();
> > +	if (!pmd_present(pmdval))
> > +		return;
> > +
> > +	mmu_notifier_invalidate_range_start(mm, addr, addr + HPAGE_PMD_SIZE);
> > +	if (pmd_trans_huge(pmdval)) {
> > +		pmd_t pmdswp;
> > +
> > +		ptl =3D pmd_lock(mm, pmd);
> > +		if (!pmd_present(*pmd))
> > +			goto unlock_pmd;
> > +		if (unlikely(!pmd_trans_huge(*pmd)))
> > +			goto unlock_pmd;
>=20
> Just check *pmd =3D=3D pmdval?

OK.

>=20
> > +		if (pmd_page(*pmd) !=3D page)
> > +			goto unlock_pmd;
> > +
> > +		pmdval =3D pmdp_huge_get_and_clear(mm, addr, pmd);
> > +		if (pmd_dirty(pmdval))
> > +			set_page_dirty(page);
> > +		entry =3D make_migration_entry(page, pmd_write(pmdval));
> > +		pmdswp =3D swp_entry_to_pmd(entry);
> > +		pmdswp =3D pmd_mkhuge(pmdswp);
> > +		set_pmd_at(mm, addr, pmd, pmdswp);
> > +		page_remove_rmap(page, true);
> > +		put_page(page);
> > +unlock_pmd:
> > +		spin_unlock(ptl);
> > +	} else { /* pte-mapped thp */
> > +		pte_t *pte;
> > +		pte_t pteval;
> > +		struct page *tmp =3D compound_head(page);
> > +		unsigned long address =3D addr & HPAGE_PMD_MASK;
> > +		pte_t swp_pte;
> > +		int i;
> > +
> > +		pte =3D pte_offset_map(pmd, address);
> > +		ptl =3D pte_lockptr(mm, pmd);
> > +		spin_lock(ptl);
>=20
> pte_offset_map_lock() ?

Right.

> > +		for (i =3D 0; i < HPAGE_PMD_NR; i++, pte++, tmp++) {
> > +			if (!(pte_present(*pte) &&
> > +			      page_to_pfn(tmp) =3D=3D pte_pfn(*pte)))
>=20
> 			if (!pte_present(*pte) || pte_page(*pte) !=3D tmp) ?

Yes, this is shorter/simpler.

>=20
> > +				continue;
> > +			pteval =3D ptep_clear_flush(vma, address, pte);
> > +			if (pte_dirty(pteval))
> > +				set_page_dirty(tmp);
> > +			entry =3D make_migration_entry(tmp, pte_write(pteval));
> > +			swp_pte =3D swp_entry_to_pte(entry);
> > +			set_pte_at(mm, address, pte, swp_pte);
> > +			page_remove_rmap(tmp, false);
> > +			put_page(tmp);
> > +		}
> > +		pte_unmap_unlock(pte, ptl);
> > +	}
> > +	mmu_notifier_invalidate_range_end(mm, addr, addr + HPAGE_PMD_SIZE);
> > +	return;
> > +}
> > +
> > +int remove_migration_pmd(struct page *new, pmd_t *pmd,
> > +		struct vm_area_struct *vma, unsigned long addr, void *old)
> > +{
> > +	struct mm_struct *mm =3D vma->vm_mm;
> > +	spinlock_t *ptl;
> > +	pmd_t pmde;
> > +	swp_entry_t entry;
> > +
> > +	pmde =3D *pmd;
> > +	barrier();
> > +
> > +	if (!pmd_present(pmde)) {
> > +		if (is_migration_entry(pmd_to_swp_entry(pmde))) {
>=20
> 		if (!is_migration_entry(pmd_to_swp_entry(pmde)))
> 			return SWAP_AGAIN;
>=20
> And one level less indentation below.

OK.

> > +			unsigned long mmun_start =3D addr & HPAGE_PMD_MASK;
> > +			unsigned long mmun_end =3D mmun_start + HPAGE_PMD_SIZE;
> > +
> > +			ptl =3D pmd_lock(mm, pmd);
> > +			entry =3D pmd_to_swp_entry(*pmd);
> > +			if (migration_entry_to_page(entry) !=3D old)
> > +				goto unlock_ptl;
> > +			get_page(new);
> > +			pmde =3D pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
> > +			if (is_write_migration_entry(entry))
> > +				pmde =3D maybe_pmd_mkwrite(pmde, vma);
> > +			flush_cache_range(vma, mmun_start, mmun_end);
> > +			page_add_anon_rmap(new, vma, mmun_start, true);
> > +			pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
> > +			set_pmd_at(mm, mmun_start, pmd, pmde);
> > +			flush_tlb_range(vma, mmun_start, mmun_end);
> > +			if (vma->vm_flags & VM_LOCKED)
> > +				mlock_vma_page(new);
> > +			update_mmu_cache_pmd(vma, addr, pmd);
> > +unlock_ptl:
> > +			spin_unlock(ptl);
>=20
> 			return SWAP_AGAIN;
>=20
> And one level less indentation below.
>=20
> > +		}
> > +	} else { /* pte-mapped thp */
> > +		pte_t *ptep;
> > +		pte_t pte;
> > +		int i;
> > +		struct page *tmpnew =3D compound_head(new);
> > +		struct page *tmpold =3D compound_head((struct page *)old);
> > +		unsigned long address =3D addr & HPAGE_PMD_MASK;
> > +
> > +		ptep =3D pte_offset_map(pmd, addr);
> > +		ptl =3D pte_lockptr(mm, pmd);
> > +		spin_lock(ptl);
>=20
> pte_offset_map_lock() ?
>=20
> > +
> > +		for (i =3D 0; i < HPAGE_PMD_NR;
> > +		     i++, ptep++, tmpnew++, tmpold++, address +=3D PAGE_SIZE) {
> > +			pte =3D *ptep;
> > +			if (!is_swap_pte(pte))
> > +				continue;
> > +			entry =3D pte_to_swp_entry(pte);
> > +			if (!is_migration_entry(entry) ||
> > +			    migration_entry_to_page(entry) !=3D tmpold)
> > +				continue;
> > +			get_page(tmpnew);
> > +			pte =3D pte_mkold(mk_pte(tmpnew,
> > +					       READ_ONCE(vma->vm_page_prot)));
>=20
> READ_ONCE()? Do we get here under mmap_sem, right?

Some callers of page migration (mbind, move_pages, migrate_pages, cpuset)
do get mmap_sem, but others (memory hotremove, soft offline) don't.
For this part, I borrowed some code from remove_migration_pte() which was
updated at the following commit:

  commit 6d2329f8872f23e46a19d240930571510ce525eb
  Author: Andrea Arcangeli <aarcange@redhat.com>
  Date:   Fri Oct 7 17:01:22 2016 -0700
 =20
      mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE


Thank you for reviewing in detail!

Naoya Horiguchi

> > +			if (pte_swp_soft_dirty(*ptep))
> > +				pte =3D pte_mksoft_dirty(pte);
> > +			if (is_write_migration_entry(entry))
> > +				pte =3D maybe_mkwrite(pte, vma);
> > +			flush_dcache_page(tmpnew);
> > +			set_pte_at(mm, address, ptep, pte);
> > +			if (PageAnon(new))
> > +				page_add_anon_rmap(tmpnew, vma, address, false);
> > +			else
> > +				page_add_file_rmap(tmpnew, false);
> > +			update_mmu_cache(vma, address, ptep);
> > +		}
> > +		pte_unmap_unlock(ptep, ptl);
> > +	}
> > +	return SWAP_AGAIN;
> > +}
> > +#endif
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c v4.9-rc2-mmotm-=
2016-10-27-18-27_patched/mm/migrate.c
> > index 66ce6b4..54f2eb6 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/migrate.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/migrate.c
> > @@ -198,6 +198,8 @@ static int remove_migration_pte(struct page *new, s=
truct vm_area_struct *vma,
> >  {
> >  	struct mm_struct *mm =3D vma->vm_mm;
> >  	swp_entry_t entry;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> >   	pmd_t *pmd;
> >  	pte_t *ptep, pte;
> >   	spinlock_t *ptl;
> > @@ -208,10 +210,29 @@ static int remove_migration_pte(struct page *new,=
 struct vm_area_struct *vma,
> >  			goto out;
> >  		ptl =3D huge_pte_lockptr(hstate_vma(vma), mm, ptep);
> >  	} else {
> > -		pmd =3D mm_find_pmd(mm, addr);
> > +		pmd_t pmde;
> > +
> > +		pgd =3D pgd_offset(mm, addr);
> > +		if (!pgd_present(*pgd))
> > +			goto out;
> > +		pud =3D pud_offset(pgd, addr);
> > +		if (!pud_present(*pud))
> > +			goto out;
> > +		pmd =3D pmd_offset(pud, addr);
> >  		if (!pmd)
> >  			goto out;
> > =20
> > +		if (PageTransCompound(new)) {
> > +			remove_migration_pmd(new, pmd, vma, addr, old);
> > +			goto out;
> > +		}
> > +
> > +		pmde =3D *pmd;
> > +		barrier();
> > +
> > +		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
> > +			goto out;
> > +
> >  		ptep =3D pte_offset_map(pmd, addr);
> > =20
> >  		/*
> > @@ -344,6 +365,27 @@ void migration_entry_wait_huge(struct vm_area_stru=
ct *vma,
> >  	__migration_entry_wait(mm, pte, ptl);
> >  }
> > =20
> > +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> > +void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
> > +{
> > +	spinlock_t *ptl;
> > +	struct page *page;
> > +
> > +	ptl =3D pmd_lock(mm, pmd);
> > +	if (!is_pmd_migration_entry(*pmd))
> > +		goto unlock;
> > +	page =3D migration_entry_to_page(pmd_to_swp_entry(*pmd));
> > +	if (!get_page_unless_zero(page))
> > +		goto unlock;
> > +	spin_unlock(ptl);
> > +	wait_on_page_locked(page);
> > +	put_page(page);
> > +	return;
> > +unlock:
> > +	spin_unlock(ptl);
> > +}
> > +#endif
> > +
> >  #ifdef CONFIG_BLOCK
> >  /* Returns true if all buffers are successfully locked */
> >  static bool buffer_migrate_lock_buffers(struct buffer_head *head,
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c v4.9-rc=
2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> > index 71c5f91..6012343 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> > @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *=
vma, unsigned long address,
> >  {
> >  	pmd_t pmd;
> >  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> > -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
> > +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
> > +		  !pmd_devmap(*pmdp));
> >  	pmd =3D pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
> >  	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> >  	return pmd;
> > --=20
> > 2.7.0
> >=20
>=20
> --=20
>  Kirill A. Shutemov
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
