Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0DB6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:48:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so412578933pga.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:48:19 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id o21si58605686pgj.240.2016.11.28.22.48.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 22:48:17 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Date: Tue, 29 Nov 2016 06:46:14 +0000
Message-ID: <20161129064613.GA8686@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161117235624.GA8891@node>
In-Reply-To: <20161117235624.GA8891@node>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7A8D594F2FA2BF41BA10F070D2809902@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

# sorry for late reply ...

On Fri, Nov 18, 2016 at 02:56:24AM +0300, Kirill A. Shutemov wrote:
> On Tue, Nov 08, 2016 at 08:31:52AM +0900, Naoya Horiguchi wrote:
> > If one of callers of page migration starts to handle thp, memory manage=
ment code
> > start to see pmd migration entry, so we need to prepare for it before e=
nabling.
> > This patch changes various code point which checks the status of given =
pmds in
> > order to prevent race between thp migration and the pmd-related works.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> > ChangeLog v1 -> v2:
> > - introduce pmd_related() (I know the naming is not good, but can't thi=
nk up
> >   no better name. Any suggesntion is welcomed.)
> > ---
> >  arch/x86/mm/gup.c       |  4 +--
> >  fs/proc/task_mmu.c      | 23 +++++++------
> >  include/linux/huge_mm.h |  9 ++++-
> >  mm/gup.c                | 10 ++++--
> >  mm/huge_memory.c        | 88 ++++++++++++++++++++++++++++++++++++++++-=
--------
> >  mm/madvise.c            |  2 +-
> >  mm/memcontrol.c         |  2 ++
> >  mm/memory.c             |  6 +++-
> >  mm/mprotect.c           |  2 ++
> >  mm/mremap.c             |  2 +-
> >  10 files changed, 114 insertions(+), 34 deletions(-)
> >=20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/mm/gup.c v4.9-rc2-m=
motm-2016-10-27-18-27_patched/arch/x86/mm/gup.c
> > index 0d4fb3e..78a153d 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/mm/gup.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/mm/gup.c
> > @@ -222,9 +222,9 @@ static int gup_pmd_range(pud_t pud, unsigned long a=
ddr, unsigned long end,
> >  		pmd_t pmd =3D *pmdp;
> > =20
> >  		next =3D pmd_addr_end(addr, end);
> > -		if (pmd_none(pmd))
> > +		if (!pmd_present(pmd))
> >  			return 0;
> > -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> > +		if (unlikely(pmd_large(pmd))) {
> >  			/*
> >  			 * NUMA hinting faults need to be handled in the GUP
> >  			 * slowpath for accounting purposes and so that they
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c v4.9-rc2-=
mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
> > index 35b92d8..c1f9cf4 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/fs/proc/task_mmu.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/fs/proc/task_mmu.c
> > @@ -596,7 +596,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned lon=
g addr, unsigned long end,
> > =20
> >  	ptl =3D pmd_trans_huge_lock(pmd, vma);
> >  	if (ptl) {
> > -		smaps_pmd_entry(pmd, addr, walk);
> > +		if (pmd_present(*pmd))
> > +			smaps_pmd_entry(pmd, addr, walk);
> >  		spin_unlock(ptl);
> >  		return 0;
> >  	}
> > @@ -929,6 +930,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigne=
d long addr,
> >  			goto out;
> >  		}
> > =20
> > +		if (!pmd_present(*pmd))
> > +			goto out;
> > +
>=20
> Hm. Looks like clear_soft_dirty_pmd() should handle !present. It doesn't.
>=20
> Ah.. Found it in 08/12.
>=20
> >  		page =3D pmd_page(*pmd);
> > =20
> >  		/* Clear accessed and referenced bits. */
> > @@ -1208,19 +1212,18 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsig=
ned long addr, unsigned long end,
> >  	if (ptl) {
> >  		u64 flags =3D 0, frame =3D 0;
> >  		pmd_t pmd =3D *pmdp;
> > +		struct page *page;
> > =20
> >  		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
> >  			flags |=3D PM_SOFT_DIRTY;
> > =20
> > -		/*
> > -		 * Currently pmd for thp is always present because thp
> > -		 * can not be swapped-out, migrated, or HWPOISONed
> > -		 * (split in such cases instead.)
> > -		 * This if-check is just to prepare for future implementation.
> > -		 */
> > -		if (pmd_present(pmd)) {
> > -			struct page *page =3D pmd_page(pmd);
> > -
> > +		if (is_pmd_migration_entry(pmd)) {
> > +			swp_entry_t entry =3D pmd_to_swp_entry(pmd);
> > +			frame =3D swp_type(entry) |
> > +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> > +			page =3D migration_entry_to_page(entry);
> > +		} else if (pmd_present(pmd)) {
> > +			page =3D pmd_page(pmd);
> >  			if (page_mapcount(page) =3D=3D 1)
> >  				flags |=3D PM_MMAP_EXCLUSIVE;
> > =20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h v4.9=
-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
> > index fcbca51..3c252cd 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/include/linux/huge_mm.h
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/include/linux/huge_mm.h
> > @@ -125,12 +125,19 @@ extern void vma_adjust_trans_huge(struct vm_area_=
struct *vma,
> >  				    long adjust_next);
> >  extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd,
> >  		struct vm_area_struct *vma);
> > +
> > +static inline int pmd_related(pmd_t pmd)
> > +{
> > +	return !pmd_none(pmd) &&
> > +		(!pmd_present(pmd) || pmd_trans_huge(pmd) || pmd_devmap(pmd));
> > +}
> > +
>=20
> I would rather create is_swap_pmd() -- (!none && !present) and leave the
> reset open-codded.

OK, I do this.

>=20
> >  /* mmap_sem must be held on entry */
> >  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
> >  		struct vm_area_struct *vma)
> >  {
> >  	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
> > -	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
> > +	if (pmd_related(*pmd))
> >  		return __pmd_trans_huge_lock(pmd, vma);
> >  	else
> >  		return NULL;
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/gup.c v4.9-rc2-mmotm-2016=
-10-27-18-27_patched/mm/gup.c
> > index e50178c..2dc4978 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/gup.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/gup.c
> > @@ -267,6 +267,8 @@ struct page *follow_page_mask(struct vm_area_struct=
 *vma,
> >  	}
> >  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
> >  		return no_page_table(vma, flags);
> > +	if (!pmd_present(*pmd))
> > +		return no_page_table(vma, flags);
>=20
> Don't we need FOLL_MIGRATION, like on pte side?

That's better, applied.

> >  	if (pmd_devmap(*pmd)) {
> >  		ptl =3D pmd_lock(mm, pmd);
> >  		page =3D follow_devmap_pmd(vma, address, pmd, flags);
> > @@ -278,6 +280,10 @@ struct page *follow_page_mask(struct vm_area_struc=
t *vma,
> >  		return follow_page_pte(vma, address, pmd, flags);
> > =20
> >  	ptl =3D pmd_lock(mm, pmd);
> > +	if (unlikely(!pmd_present(*pmd))) {
> > +		spin_unlock(ptl);
> > +		return no_page_table(vma, flags);
> > +	}
>=20
> Ditto.
>=20
> >  	if (unlikely(!pmd_trans_huge(*pmd))) {
> >  		spin_unlock(ptl);
> >  		return follow_page_pte(vma, address, pmd, flags);
> > @@ -333,7 +339,7 @@ static int get_gate_page(struct mm_struct *mm, unsi=
gned long address,
> >  	pud =3D pud_offset(pgd, address);
> >  	BUG_ON(pud_none(*pud));
> >  	pmd =3D pmd_offset(pud, address);
> > -	if (pmd_none(*pmd))
> > +	if (!pmd_present(*pmd))
> >  		return -EFAULT;
> >  	VM_BUG_ON(pmd_trans_huge(*pmd));
> >  	pte =3D pte_offset_map(pmd, address);
> > @@ -1357,7 +1363,7 @@ static int gup_pmd_range(pud_t pud, unsigned long=
 addr, unsigned long end,
> >  		pmd_t pmd =3D READ_ONCE(*pmdp);
> > =20
> >  		next =3D pmd_addr_end(addr, end);
> > -		if (pmd_none(pmd))
> > +		if (!pmd_present(pmd))
> >  			return 0;
> > =20
> >  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c v4.9-rc2-mm=
otm-2016-10-27-18-27_patched/mm/huge_memory.c
> > index b3022b3..4e9090c 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/huge_memory.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/huge_memory.c
> > @@ -825,6 +825,20 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct=
 mm_struct *src_mm,
> > =20
> >  	ret =3D -EAGAIN;
> >  	pmd =3D *src_pmd;
> > +
> > +	if (unlikely(is_pmd_migration_entry(pmd))) {
> > +		swp_entry_t entry =3D pmd_to_swp_entry(pmd);
> > +
> > +		if (is_write_migration_entry(entry)) {
> > +			make_migration_entry_read(&entry);
> > +			pmd =3D swp_entry_to_pmd(entry);
> > +			set_pmd_at(src_mm, addr, src_pmd, pmd);
> > +		}
>=20
> I think we should put at least WARN_ONCE() in 'else' here. We don't want
> to miss such places when swap will be supported (or other swap entry type=
).

I guess that you mean 'else' branch of outer if-block, right?

> > +		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
> > +		ret =3D 0;
> > +		goto out_unlock;
> > +	}

Maybe inserting the below here seems OK.

        WARN_ONCE(!pmd_present(pmd), "Unknown non-present format on pmd.\n"=
);

> > +
> >  	if (unlikely(!pmd_trans_huge(pmd))) {
> >  		pte_free(dst_mm, pgtable);
> >  		goto out_unlock;
> > @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd=
_t orig_pmd)
> >  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
> >  		goto out_unlock;
> > =20
> > +	if (unlikely(!pmd_present(orig_pmd)))
> > +		goto out_unlock;
> > +
> >  	page =3D pmd_page(orig_pmd);
> >  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> >  	/*
> > @@ -1137,7 +1154,14 @@ struct page *follow_trans_huge_pmd(struct vm_are=
a_struct *vma,
> >  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
> >  		goto out;
> > =20
> > -	page =3D pmd_page(*pmd);
> > +	if (is_pmd_migration_entry(*pmd)) {
> > +		swp_entry_t entry;
> > +		entry =3D pmd_to_swp_entry(*pmd);
> > +		page =3D pfn_to_page(swp_offset(entry));
> > +		if (!is_migration_entry(entry))
> > +			goto out;
>=20
> follow_page_pte() does different thing: wait for page to be migrated and
> retry. Any reason you don't do the same?

No, just my self-check wasn't enough.

> > +	} else
> > +		page =3D pmd_page(*pmd);
> >  	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
> >  	if (flags & FOLL_TOUCH)
> >  		touch_pmd(vma, addr, pmd);
> > @@ -1332,6 +1356,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb=
, struct vm_area_struct *vma,
> >  	if (is_huge_zero_pmd(orig_pmd))
> >  		goto out;
> > =20
> > +	if (unlikely(!pmd_present(orig_pmd)))
> > +		goto out;
> > +
> >  	page =3D pmd_page(orig_pmd);
> >  	/*
> >  	 * If other processes are mapping this page, we couldn't discard
> > @@ -1410,20 +1437,35 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct=
 vm_area_struct *vma,
> >  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
> >  	} else {
> >  		struct page *page =3D pmd_page(orig_pmd);
> > -		page_remove_rmap(page, true);
> > -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> > -		VM_BUG_ON_PAGE(!PageHead(page), page);
> > -		if (PageAnon(page)) {
> > -			pgtable_t pgtable;
> > -			pgtable =3D pgtable_trans_huge_withdraw(tlb->mm, pmd);
> > -			pte_free(tlb->mm, pgtable);
> > -			atomic_long_dec(&tlb->mm->nr_ptes);
> > -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> > +		int migration =3D 0;
> > +
> > +		if (!is_pmd_migration_entry(orig_pmd)) {
> > +			page_remove_rmap(page, true);
> > +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> > +			VM_BUG_ON_PAGE(!PageHead(page), page);
> > +			if (PageAnon(page)) {
> > +				pgtable_t pgtable;
> > +				pgtable =3D pgtable_trans_huge_withdraw(tlb->mm,
> > +								      pmd);
> > +				pte_free(tlb->mm, pgtable);
> > +				atomic_long_dec(&tlb->mm->nr_ptes);
> > +				add_mm_counter(tlb->mm, MM_ANONPAGES,
> > +					       -HPAGE_PMD_NR);
> > +			} else {
> > +				add_mm_counter(tlb->mm, MM_FILEPAGES,
> > +					       -HPAGE_PMD_NR);
> > +			}
> >  		} else {
> > -			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> > +			swp_entry_t entry;
> > +
> > +			entry =3D pmd_to_swp_entry(orig_pmd);
> > +			free_swap_and_cache(entry); /* waring in failure? */
> > +			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> > +			migration =3D 1;
> >  		}
> >  		spin_unlock(ptl);
> > -		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
> > +		if (!migration)
> > +			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
> >  	}
> >  	return 1;
> >  }
> > @@ -1496,14 +1538,27 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
> >  		bool preserve_write =3D prot_numa && pmd_write(*pmd);
> >  		ret =3D 1;
> > =20
> > +		if (!pmd_present(*pmd))
> > +			goto unlock;
> >  		/*
> >  		 * Avoid trapping faults against the zero page. The read-only
> >  		 * data is likely to be read-cached on the local CPU and
> >  		 * local/remote hits to the zero page are not interesting.
> >  		 */
> > -		if (prot_numa && is_huge_zero_pmd(*pmd)) {
> > -			spin_unlock(ptl);
> > -			return ret;
> > +		if (prot_numa && is_huge_zero_pmd(*pmd))
> > +			goto unlock;
> > +
> > +		if (is_pmd_migration_entry(*pmd)) {
>=20
> Hm? But we filtered out !present above?

the !present check must come after this if-block with WARN_ONCE().

> > +			swp_entry_t entry =3D pmd_to_swp_entry(*pmd);
> > +
> > +			if (is_write_migration_entry(entry)) {
> > +				pmd_t newpmd;
> > +
> > +				make_migration_entry_read(&entry);
> > +				newpmd =3D swp_entry_to_pmd(entry);
> > +				set_pmd_at(mm, addr, pmd, newpmd);
> > +			}
> > +			goto unlock;
> >  		}
> > =20
> >  		if (!prot_numa || !pmd_protnone(*pmd)) {
> > @@ -1516,6 +1571,7 @@ int change_huge_pmd(struct vm_area_struct *vma, p=
md_t *pmd,
> >  			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
> >  					pmd_write(entry));
> >  		}
> > +unlock:
> >  		spin_unlock(ptl);
> >  	}
> > =20
> > @@ -1532,7 +1588,7 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, str=
uct vm_area_struct *vma)
> >  {
> >  	spinlock_t *ptl;
> >  	ptl =3D pmd_lock(vma->vm_mm, pmd);
> > -	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
> > +	if (likely(pmd_related(*pmd)))
> >  		return ptl;
> >  	spin_unlock(ptl);
> >  	return NULL;
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/madvise.c v4.9-rc2-mmotm-=
2016-10-27-18-27_patched/mm/madvise.c
> > index 0e3828e..eaa2b02 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/madvise.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/madvise.c
> > @@ -274,7 +274,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsig=
ned long addr,
> >  	unsigned long next;
> > =20
> >  	next =3D pmd_addr_end(addr, end);
> > -	if (pmd_trans_huge(*pmd))
> > +	if (pmd_related(*pmd))
>=20
> I don't see a point going for madvise_free_huge_pmd(), just to fall off o=
n
> !present inside.

Sorry, this code was wrong. I should've done like below simply:

+	if (!pmd_present(*pmd))
+		return 0;
 	if (pmd_trans_huge(*pmd))
 		...

> And is it safe for devmap?

I'm not sure, so let's keep it as-is.

Thanks,
Naoya Horiguchi

>=20
> >  		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
> >  			goto next;
> > =20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memcontrol.c v4.9-rc2-mmo=
tm-2016-10-27-18-27_patched/mm/memcontrol.c
> > index 91dfc7c..ebc2c42 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memcontrol.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memcontrol.c
> > @@ -4635,6 +4635,8 @@ static enum mc_target_type get_mctgt_type_thp(str=
uct vm_area_struct *vma,
> >  	struct page *page =3D NULL;
> >  	enum mc_target_type ret =3D MC_TARGET_NONE;
> > =20
> > +	if (unlikely(!pmd_present(pmd)))
> > +		return ret;
> >  	page =3D pmd_page(pmd);
> >  	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
> >  	if (!(mc.flags & MOVE_ANON))
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory.c v4.9-rc2-mmotm-2=
016-10-27-18-27_patched/mm/memory.c
> > index 94b5e2c..33fa439 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory.c
> > @@ -999,7 +999,7 @@ static inline int copy_pmd_range(struct mm_struct *=
dst_mm, struct mm_struct *src
> >  	src_pmd =3D pmd_offset(src_pud, addr);
> >  	do {
> >  		next =3D pmd_addr_end(addr, end);
> > -		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
> > +		if (pmd_related(*src_pmd)) {
> >  			int err;
> >  			VM_BUG_ON(next-addr !=3D HPAGE_PMD_SIZE);
> >  			err =3D copy_huge_pmd(dst_mm, src_mm,
> > @@ -3591,6 +3591,10 @@ static int __handle_mm_fault(struct vm_area_stru=
ct *vma, unsigned long address,
> >  		int ret;
> > =20
> >  		barrier();
> > +		if (unlikely(is_pmd_migration_entry(orig_pmd))) {
> > +			pmd_migration_entry_wait(mm, fe.pmd);
> > +			return 0;
> > +		}
> >  		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
> >  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
> >  				return do_huge_pmd_numa_page(&fe, orig_pmd);
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mprotect.c v4.9-rc2-mmotm=
-2016-10-27-18-27_patched/mm/mprotect.c
> > index c5ba2aa..81186e3 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mprotect.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mprotect.c
> > @@ -164,6 +164,8 @@ static inline unsigned long change_pmd_range(struct=
 vm_area_struct *vma,
> >  		unsigned long this_pages;
> > =20
> >  		next =3D pmd_addr_end(addr, end);
> > +		if (!pmd_present(*pmd))
> > +			continue;
> >  		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
> >  				&& pmd_none_or_clear_bad(pmd))
> >  			continue;
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mremap.c v4.9-rc2-mmotm-2=
016-10-27-18-27_patched/mm/mremap.c
> > index da22ad2..a94a698 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mremap.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mremap.c
> > @@ -194,7 +194,7 @@ unsigned long move_page_tables(struct vm_area_struc=
t *vma,
> >  		new_pmd =3D alloc_new_pmd(vma->vm_mm, vma, new_addr);
> >  		if (!new_pmd)
> >  			break;
> > -		if (pmd_trans_huge(*old_pmd)) {
> > +		if (pmd_related(*old_pmd)) {
> >  			if (extent =3D=3D HPAGE_PMD_SIZE) {
> >  				bool moved;
> >  				/* See comment in move_ptes() */
> > --=20
> > 2.7.0
> >=20
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
> --=20
>  Kirill A. Shutemov
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
