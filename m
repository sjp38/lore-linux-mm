Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A66256B0389
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:19:53 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id v96so18145665ioi.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:19:53 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id n5si17336934iof.45.2017.02.09.01.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 01:19:52 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 09/14] mm: thp: check pmd migration entry in common
 path
Date: Thu, 9 Feb 2017 09:16:16 +0000
Message-ID: <20170209091616.GA15890@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-10-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-10-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8C60792A6CFDD14897F248AF5F16A804@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Sun, Feb 05, 2017 at 11:12:47AM -0500, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> If one of callers of page migration starts to handle thp,
> memory management code start to see pmd migration entry, so we need
> to prepare for it before enabling. This patch changes various code
> point which checks the status of given pmds in order to prevent race
> between thp migration and the pmd-related works.
>=20
> ChangeLog v1 -> v2:
> - introduce pmd_related() (I know the naming is not good, but can't
>   think up no better name. Any suggesntion is welcomed.)
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> ChangeLog v2 -> v3:
> - add is_swap_pmd()
> - a pmd entry should be is_swap_pmd(), pmd_trans_huge(), pmd_devmap(),
>   or pmd_none()

(nitpick) ... or normal pmd pointing to pte pages?

> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear()
> - flush_cache_range() while set_pmd_migration_entry()
> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() return
>   true on pmd_migration_entry, so that migration entries are not
>   treated as pmd page table entries.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/mm/gup.c             |  4 +--
>  fs/proc/task_mmu.c            | 22 ++++++++-----
>  include/asm-generic/pgtable.h | 71 -------------------------------------=
---
>  include/linux/huge_mm.h       | 21 ++++++++++--
>  include/linux/swapops.h       | 74 +++++++++++++++++++++++++++++++++++++=
++++
>  mm/gup.c                      | 20 ++++++++++--
>  mm/huge_memory.c              | 76 ++++++++++++++++++++++++++++++++++++-=
------
>  mm/madvise.c                  |  2 ++
>  mm/memcontrol.c               |  2 ++
>  mm/memory.c                   |  9 +++--
>  mm/memory_hotplug.c           | 13 +++++++-
>  mm/mempolicy.c                |  1 +
>  mm/mprotect.c                 |  6 ++--
>  mm/mremap.c                   |  2 +-
>  mm/pagewalk.c                 |  2 ++
>  15 files changed, 221 insertions(+), 104 deletions(-)
>=20
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 0d4fb3ebbbac..78a153d90064 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -222,9 +222,9 @@ static int gup_pmd_range(pud_t pud, unsigned long add=
r, unsigned long end,
>  		pmd_t pmd =3D *pmdp;
> =20
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> +		if (unlikely(pmd_large(pmd))) {
>  			/*
>  			 * NUMA hinting faults need to be handled in the GUP
>  			 * slowpath for accounting purposes and so that they
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6c07c7813b26..1e64d6898c68 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -596,7 +596,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long =
addr, unsigned long end,
> =20
>  	ptl =3D pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> -		smaps_pmd_entry(pmd, addr, walk);
> +		if (pmd_present(*pmd))
> +			smaps_pmd_entry(pmd, addr, walk);
>  		spin_unlock(ptl);
>  		return 0;
>  	}
> @@ -929,6 +930,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned =
long addr,
>  			goto out;
>  		}
> =20
> +		if (!pmd_present(*pmd))
> +			goto out;
> +
>  		page =3D pmd_page(*pmd);
> =20
>  		/* Clear accessed and referenced bits. */
> @@ -1208,19 +1212,19 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigne=
d long addr, unsigned long end,
>  	if (ptl) {
>  		u64 flags =3D 0, frame =3D 0;
>  		pmd_t pmd =3D *pmdp;
> +		struct page *page;
> =20
>  		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
>  			flags |=3D PM_SOFT_DIRTY;
> =20
> -		/*
> -		 * Currently pmd for thp is always present because thp
> -		 * can not be swapped-out, migrated, or HWPOISONed
> -		 * (split in such cases instead.)
> -		 * This if-check is just to prepare for future implementation.
> -		 */
> -		if (pmd_present(pmd)) {
> -			struct page *page =3D pmd_page(pmd);
> +		if (is_pmd_migration_entry(pmd)) {
> +			swp_entry_t entry =3D pmd_to_swp_entry(pmd);
> =20
> +			frame =3D swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +			page =3D migration_entry_to_page(entry);
> +		} else if (pmd_present(pmd)) {
> +			page =3D pmd_page(pmd);
>  			if (page_mapcount(page) =3D=3D 1)
>  				flags |=3D PM_MMAP_EXCLUSIVE;
> =20
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.=
h
> index b71a431ed649..6cf9e9b5a7be 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -726,77 +726,6 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
>  #ifndef arch_needs_pgtable_deposit
>  #define arch_needs_pgtable_deposit() (false)
>  #endif
> -/*
> - * This function is meant to be used by sites walking pagetables with
> - * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
> - * transhuge page faults. MADV_DONTNEED can convert a transhuge pmd
> - * into a null pmd and the transhuge page fault can convert a null pmd
> - * into an hugepmd or into a regular pmd (if the hugepage allocation
> - * fails). While holding the mmap_sem in read mode the pmd becomes
> - * stable and stops changing under us only if it's not null and not a
> - * transhuge pmd. When those races occurs and this function makes a
> - * difference vs the standard pmd_none_or_clear_bad, the result is
> - * undefined so behaving like if the pmd was none is safe (because it
> - * can return none anyway). The compiler level barrier() is critically
> - * important to compute the two checks atomically on the same pmdval.
> - *
> - * For 32bit kernels with a 64bit large pmd_t this automatically takes
> - * care of reading the pmd atomically to avoid SMP race conditions
> - * against pmd_populate() when the mmap_sem is hold for reading by the
> - * caller (a special atomic read not done by "gcc" as in the generic
> - * version above, is also needed when THP is disabled because the page
> - * fault can populate the pmd from under us).
> - */
> -static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
> -{
> -	pmd_t pmdval =3D pmd_read_atomic(pmd);
> -	/*
> -	 * The barrier will stabilize the pmdval in a register or on
> -	 * the stack so that it will stop changing under the code.
> -	 *
> -	 * When CONFIG_TRANSPARENT_HUGEPAGE=3Dy on x86 32bit PAE,
> -	 * pmd_read_atomic is allowed to return a not atomic pmdval
> -	 * (for example pointing to an hugepage that has never been
> -	 * mapped in the pmd). The below checks will only care about
> -	 * the low part of the pmd with 32bit PAE x86 anyway, with the
> -	 * exception of pmd_none(). So the important thing is that if
> -	 * the low part of the pmd is found null, the high part will
> -	 * be also null or the pmd_none() check below would be
> -	 * confused.
> -	 */
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	barrier();
> -#endif
> -	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
> -		return 1;
> -	if (unlikely(pmd_bad(pmdval))) {
> -		pmd_clear_bad(pmd);
> -		return 1;
> -	}
> -	return 0;
> -}
> -
> -/*
> - * This is a noop if Transparent Hugepage Support is not built into
> - * the kernel. Otherwise it is equivalent to
> - * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in
> - * places that already verified the pmd is not none and they want to
> - * walk ptes while holding the mmap sem in read mode (write mode don't
> - * need this). If THP is not enabled, the pmd can't go away under the
> - * code even if MADV_DONTNEED runs, but if THP is enabled we need to
> - * run a pmd_trans_unstable before walking the ptes after
> - * split_huge_page_pmd returns (because it may have run when the pmd
> - * become null, but then a page fault can map in a THP and not a
> - * regular page).
> - */
> -static inline int pmd_trans_unstable(pmd_t *pmd)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	return pmd_none_or_trans_huge_or_clear_bad(pmd);
> -#else
> -	return 0;
> -#endif
> -}
> =20
>  #ifndef CONFIG_NUMA_BALANCING
>  /*
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 83a8d42f9d55..c2e5a4eab84a 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -131,7 +131,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd=
_t *pmd,
>  #define split_huge_pmd(__vma, __pmd, __address)				\
>  	do {								\
>  		pmd_t *____pmd =3D (__pmd);				\
> -		if (pmd_trans_huge(*____pmd)				\
> +		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
>  					|| pmd_devmap(*____pmd))	\
>  			__split_huge_pmd(__vma, __pmd, __address,	\
>  						false, NULL);		\
> @@ -162,12 +162,18 @@ extern spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd=
,
>  		struct vm_area_struct *vma);
>  extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
>  		struct vm_area_struct *vma);
> +
> +static inline int is_swap_pmd(pmd_t pmd)
> +{
> +	return !pmd_none(pmd) && !pmd_present(pmd);
> +}
> +
>  /* mmap_sem must be held on entry */
>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
> -	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
> +	if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
>  		return __pmd_trans_huge_lock(pmd, vma);
>  	else
>  		return NULL;
> @@ -192,6 +198,12 @@ struct page *follow_devmap_pmd(struct vm_area_struct=
 *vma, unsigned long addr,
>  		pmd_t *pmd, int flags);
>  struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long=
 addr,
>  		pud_t *pud, int flags);
> +static inline int hpage_order(struct page *page)
> +{
> +	if (unlikely(PageTransHuge(page)))
> +		return HPAGE_PMD_ORDER;
> +	return 0;
> +}
> =20
>  extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
> =20
> @@ -232,6 +244,7 @@ static inline bool thp_migration_supported(void)
>  #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
> =20
>  #define hpage_nr_pages(x) 1
> +#define hpage_order(x) 0
> =20
>  #define transparent_hugepage_enabled(__vma) 0
> =20
> @@ -274,6 +287,10 @@ static inline void vma_adjust_trans_huge(struct vm_a=
rea_struct *vma,
>  					 long adjust_next)
>  {
>  }
> +static inline int is_swap_pmd(pmd_t pmd)
> +{
> +	return 0;
> +}
>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>  		struct vm_area_struct *vma)
>  {
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 6625bea13869..50e4aa7e7ff9 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -229,6 +229,80 @@ static inline int is_pmd_migration_entry(pmd_t pmd)
>  }
>  #endif
> =20
> +/*
> + * This function is meant to be used by sites walking pagetables with
> + * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
> + * transhuge page faults. MADV_DONTNEED can convert a transhuge pmd
> + * into a null pmd and the transhuge page fault can convert a null pmd
> + * into an hugepmd or into a regular pmd (if the hugepage allocation
> + * fails). While holding the mmap_sem in read mode the pmd becomes
> + * stable and stops changing under us only if it's not null and not a
> + * transhuge pmd. When those races occurs and this function makes a
> + * difference vs the standard pmd_none_or_clear_bad, the result is
> + * undefined so behaving like if the pmd was none is safe (because it
> + * can return none anyway). The compiler level barrier() is critically
> + * important to compute the two checks atomically on the same pmdval.
> + *
> + * For 32bit kernels with a 64bit large pmd_t this automatically takes
> + * care of reading the pmd atomically to avoid SMP race conditions
> + * against pmd_populate() when the mmap_sem is hold for reading by the
> + * caller (a special atomic read not done by "gcc" as in the generic
> + * version above, is also needed when THP is disabled because the page
> + * fault can populate the pmd from under us).
> + */
> +static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
> +{
> +	pmd_t pmdval =3D pmd_read_atomic(pmd);
> +	/*
> +	 * The barrier will stabilize the pmdval in a register or on
> +	 * the stack so that it will stop changing under the code.
> +	 *
> +	 * When CONFIG_TRANSPARENT_HUGEPAGE=3Dy on x86 32bit PAE,
> +	 * pmd_read_atomic is allowed to return a not atomic pmdval
> +	 * (for example pointing to an hugepage that has never been
> +	 * mapped in the pmd). The below checks will only care about
> +	 * the low part of the pmd with 32bit PAE x86 anyway, with the
> +	 * exception of pmd_none(). So the important thing is that if
> +	 * the low part of the pmd is found null, the high part will
> +	 * be also null or the pmd_none() check below would be
> +	 * confused.
> +	 */
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	barrier();
> +#endif
> +	if (pmd_none(pmdval) || pmd_trans_huge(pmdval)
> +			|| is_pmd_migration_entry(pmdval))
> +		return 1;
> +	if (unlikely(pmd_bad(pmdval))) {
> +		pmd_clear_bad(pmd);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * This is a noop if Transparent Hugepage Support is not built into
> + * the kernel. Otherwise it is equivalent to
> + * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in
> + * places that already verified the pmd is not none and they want to
> + * walk ptes while holding the mmap sem in read mode (write mode don't
> + * need this). If THP is not enabled, the pmd can't go away under the
> + * code even if MADV_DONTNEED runs, but if THP is enabled we need to
> + * run a pmd_trans_unstable before walking the ptes after
> + * split_huge_page_pmd returns (because it may have run when the pmd
> + * become null, but then a page fault can map in a THP and not a
> + * regular page).
> + */
> +static inline int pmd_trans_unstable(pmd_t *pmd)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	return pmd_none_or_trans_huge_or_clear_bad(pmd);
> +#else
> +	return 0;
> +#endif
> +}
> +
> +

These functions are page table or thp matter, so putting them in swapops.h
looks weird to me. Maybe you can avoid this code transfer by using !pmd_pre=
sent
instead of is_pmd_migration_entry?
And we have to consider renaming pmd_none_or_trans_huge_or_clear_bad(),
I like a simple name like __pmd_trans_unstable(), but if you have an idea,
that's great.

>  #ifdef CONFIG_MEMORY_FAILURE
> =20
>  extern atomic_long_t num_poisoned_pages __read_mostly;
> diff --git a/mm/gup.c b/mm/gup.c
> index 1e67461b2733..82e0304e5d29 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -274,6 +274,13 @@ struct page *follow_page_mask(struct vm_area_struct =
*vma,
>  	}
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		return no_page_table(vma, flags);
> +	if (!pmd_present(*pmd)) {
> +retry:
> +		if (likely(!(flags & FOLL_MIGRATION)))
> +			return no_page_table(vma, flags);
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry;
> +	}
>  	if (pmd_devmap(*pmd)) {
>  		ptl =3D pmd_lock(mm, pmd);
>  		page =3D follow_devmap_pmd(vma, address, pmd, flags);
> @@ -285,6 +292,15 @@ struct page *follow_page_mask(struct vm_area_struct =
*vma,
>  		return follow_page_pte(vma, address, pmd, flags);
> =20
>  	ptl =3D pmd_lock(mm, pmd);
> +	if (unlikely(!pmd_present(*pmd))) {
> +retry_locked:
> +		if (likely(!(flags & FOLL_MIGRATION))) {
> +			spin_unlock(ptl);
> +			return no_page_table(vma, flags);
> +		}
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry_locked;
> +	}
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>  		spin_unlock(ptl);
>  		return follow_page_pte(vma, address, pmd, flags);
> @@ -340,7 +356,7 @@ static int get_gate_page(struct mm_struct *mm, unsign=
ed long address,
>  	pud =3D pud_offset(pgd, address);
>  	BUG_ON(pud_none(*pud));
>  	pmd =3D pmd_offset(pud, address);
> -	if (pmd_none(*pmd))
> +	if (!pmd_present(*pmd))
>  		return -EFAULT;
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  	pte =3D pte_offset_map(pmd, address);
> @@ -1368,7 +1384,7 @@ static int gup_pmd_range(pud_t pud, unsigned long a=
ddr, unsigned long end,
>  		pmd_t pmd =3D READ_ONCE(*pmdp);
> =20
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd))
>  			return 0;
> =20
>  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fd54bbdc16cf..4ac923539372 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -897,6 +897,21 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct m=
m_struct *src_mm,
> =20
>  	ret =3D -EAGAIN;
>  	pmd =3D *src_pmd;
> +
> +	if (unlikely(is_pmd_migration_entry(pmd))) {
> +		swp_entry_t entry =3D pmd_to_swp_entry(pmd);
> +
> +		if (is_write_migration_entry(entry)) {
> +			make_migration_entry_read(&entry);
> +			pmd =3D swp_entry_to_pmd(entry);
> +			set_pmd_at(src_mm, addr, src_pmd, pmd);
> +		}
> +		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
> +		ret =3D 0;
> +		goto out_unlock;
> +	}
> +	WARN_ONCE(!pmd_present(pmd), "Uknown non-present format on pmd.\n");
> +
>  	if (unlikely(!pmd_trans_huge(pmd))) {
>  		pte_free(dst_mm, pgtable);
>  		goto out_unlock;
> @@ -1203,6 +1218,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t=
 orig_pmd)
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>  		goto out_unlock;
> =20
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +
>  	page =3D pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
> @@ -1337,7 +1355,15 @@ struct page *follow_trans_huge_pmd(struct vm_area_=
struct *vma,
>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>  		goto out;
> =20
> -	page =3D pmd_page(*pmd);
> +	if (is_pmd_migration_entry(*pmd)) {
> +		swp_entry_t entry;
> +
> +		entry =3D pmd_to_swp_entry(*pmd);
> +		page =3D pfn_to_page(swp_offset(entry));
> +		if (!is_migration_entry(entry))
> +			goto out;
> +	} else
> +		page =3D pmd_page(*pmd);
>  	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
>  	if (flags & FOLL_TOUCH)
>  		touch_pmd(vma, addr, pmd);
> @@ -1533,6 +1559,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, =
struct vm_area_struct *vma,
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto out;
> =20
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out;
> +
>  	page =3D pmd_page(orig_pmd);
>  	/*
>  	 * If other processes are mapping this page, we couldn't discard
> @@ -1659,7 +1688,8 @@ int __zap_huge_pmd_locked(struct mmu_gather *tlb, s=
truct vm_area_struct *vma,
>  			free_swap_and_cache(entry); /* waring in failure? */
>  			migration =3D 1;
>  		}
> -		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
> +		if (!migration)
> +			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>  	}
> =20
>  	return 1;
> @@ -1775,10 +1805,22 @@ int change_huge_pmd(struct vm_area_struct *vma, p=
md_t *pmd,
>  		 * data is likely to be read-cached on the local CPU and
>  		 * local/remote hits to the zero page are not interesting.
>  		 */
> -		if (prot_numa && is_huge_zero_pmd(*pmd)) {
> -			spin_unlock(ptl);
> -			return ret;
> -		}
> +		if (prot_numa && is_huge_zero_pmd(*pmd))
> +			goto unlock;
> +
> +		if (is_pmd_migration_entry(*pmd)) {
> +			swp_entry_t entry =3D pmd_to_swp_entry(*pmd);
> +
> +			if (is_write_migration_entry(entry)) {
> +				pmd_t newpmd;
> +
> +				make_migration_entry_read(&entry);
> +				newpmd =3D swp_entry_to_pmd(entry);
> +				set_pmd_at(mm, addr, pmd, newpmd);
> +			}
> +			goto unlock;
> +		} else if (!pmd_present(*pmd))
> +			WARN_ONCE(1, "Uknown non-present format on pmd.\n");
> =20
>  		if (!prot_numa || !pmd_protnone(*pmd)) {
>  			entry =3D pmdp_huge_get_and_clear_notify(mm, addr, pmd);
> @@ -1790,6 +1832,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd=
_t *pmd,
>  			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
>  					pmd_write(entry));
>  		}
> +unlock:
>  		spin_unlock(ptl);
>  	}
> =20
> @@ -1806,7 +1849,8 @@ spinlock_t *__pmd_trans_huge_lock(pmd_t *pmd, struc=
t vm_area_struct *vma)
>  {
>  	spinlock_t *ptl;
>  	ptl =3D pmd_lock(vma->vm_mm, pmd);
> -	if (likely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
> +	if (likely(is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) ||
> +			pmd_devmap(*pmd)))
>  		return ptl;
>  	spin_unlock(ptl);
>  	return NULL;
> @@ -1924,7 +1968,7 @@ void __split_huge_pmd_locked(struct vm_area_struct =
*vma, pmd_t *pmd,
>  	struct page *page;
>  	pgtable_t pgtable;
>  	pmd_t _pmd;
> -	bool young, write, dirty, soft_dirty;
> +	bool young, write, dirty, soft_dirty, pmd_migration;
>  	unsigned long addr;
>  	int i;
>  	unsigned long haddr =3D address & HPAGE_PMD_MASK;
> @@ -1932,7 +1976,8 @@ void __split_huge_pmd_locked(struct vm_area_struct =
*vma, pmd_t *pmd,
>  	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
>  	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
>  	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
> -	VM_BUG_ON(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd));
> +	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
> +				&& !pmd_devmap(*pmd));
> =20
>  	count_vm_event(THP_SPLIT_PMD);
> =20
> @@ -1960,7 +2005,14 @@ void __split_huge_pmd_locked(struct vm_area_struct=
 *vma, pmd_t *pmd,
>  		goto out;
>  	}
> =20
> -	page =3D pmd_page(*pmd);
> +	pmd_migration =3D is_pmd_migration_entry(*pmd);
> +	if (pmd_migration) {
> +		swp_entry_t entry;
> +
> +		entry =3D pmd_to_swp_entry(*pmd);
> +		page =3D pfn_to_page(swp_offset(entry));
> +	} else
> +		page =3D pmd_page(*pmd);
>  	VM_BUG_ON_PAGE(!page_count(page), page);
>  	page_ref_add(page, HPAGE_PMD_NR - 1);
>  	write =3D pmd_write(*pmd);
> @@ -1979,7 +2031,7 @@ void __split_huge_pmd_locked(struct vm_area_struct =
*vma, pmd_t *pmd,
>  		 * transferred to avoid any possibility of altering
>  		 * permissions across VMAs.
>  		 */
> -		if (freeze) {
> +		if (freeze || pmd_migration) {
>  			swp_entry_t swp_entry;
>  			swp_entry =3D make_migration_entry(page + i, write);
>  			entry =3D swp_entry_to_pte(swp_entry);
> @@ -2077,7 +2129,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, p=
md_t *pmd,
>  		page =3D pmd_page(*pmd);
>  		if (PageMlocked(page))
>  			clear_page_mlock(page);
> -	} else if (!pmd_devmap(*pmd))
> +	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
>  		goto out;
>  	__split_huge_pmd_locked(vma, pmd, address, freeze);
>  out:
> diff --git a/mm/madvise.c b/mm/madvise.c
> index e424a06e9f2b..0497a502351f 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -310,6 +310,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigne=
d long addr,
>  	unsigned long next;
> =20
>  	next =3D pmd_addr_end(addr, end);
> +	if (!pmd_present(*pmd))
> +		return 0;
>  	if (pmd_trans_huge(*pmd))
>  		if (madvise_free_huge_pmd(tlb, vma, pmd, addr, next))
>  			goto next;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 44fb1e80701a..09bce3f0d622 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4633,6 +4633,8 @@ static enum mc_target_type get_mctgt_type_thp(struc=
t vm_area_struct *vma,
>  	struct page *page =3D NULL;
>  	enum mc_target_type ret =3D MC_TARGET_NONE;
> =20
> +	if (unlikely(!pmd_present(pmd)))
> +		return ret;
>  	page =3D pmd_page(pmd);
>  	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
>  	if (!(mc.flags & MOVE_ANON))
> diff --git a/mm/memory.c b/mm/memory.c
> index 7cfdd5208ef5..bf10b19e02d3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -999,7 +999,8 @@ static inline int copy_pmd_range(struct mm_struct *ds=
t_mm, struct mm_struct *src
>  	src_pmd =3D pmd_offset(src_pud, addr);
>  	do {
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
> +		if (is_swap_pmd(*src_pmd) || pmd_trans_huge(*src_pmd)
> +			|| pmd_devmap(*src_pmd)) {
>  			int err;
>  			VM_BUG_ON_VMA(next-addr !=3D HPAGE_PMD_SIZE, vma);
>  			err =3D copy_huge_pmd(dst_mm, src_mm,
> @@ -1240,7 +1241,7 @@ static inline unsigned long zap_pmd_range(struct mm=
u_gather *tlb,
>  	ptl =3D pmd_lock(vma->vm_mm, pmd);
>  	do {
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> +		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr !=3D HPAGE_PMD_SIZE) {
>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
> @@ -3697,6 +3698,10 @@ static int __handle_mm_fault(struct vm_area_struct=
 *vma, unsigned long address,
>  		pmd_t orig_pmd =3D *vmf.pmd;
> =20
>  		barrier();
> +		if (unlikely(is_pmd_migration_entry(orig_pmd))) {
> +			pmd_migration_entry_wait(mm, vmf.pmd);
> +			return 0;
> +		}
>  		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
>  			vmf.flags |=3D FAULT_FLAG_SIZE_PMD;
>  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 19b460acb5e1..9cb4c83151a8 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c

Changes on mm/memory_hotplug.c should be with patch 14/14?
# If that's right, definition of hpage_order() also should go to 14/14.

Thanks,
Naoya Horiguchi

> @@ -1570,6 +1570,7 @@ static struct page *new_node_page(struct page *page=
, unsigned long private,
>  	int nid =3D page_to_nid(page);
>  	nodemask_t nmask =3D node_states[N_MEMORY];
>  	struct page *new_page =3D NULL;
> +	unsigned int order =3D 0;
> =20
>  	/*
>  	 * TODO: allocate a destination hugepage from a nearest neighbor node,
> @@ -1580,6 +1581,11 @@ static struct page *new_node_page(struct page *pag=
e, unsigned long private,
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					next_node_in(nid, nmask));
> =20
> +	if (thp_migration_supported() && PageTransHuge(page)) {
> +		order =3D hpage_order(page);
> +		gfp_mask |=3D GFP_TRANSHUGE;
> +	}
> +
>  	node_clear(nid, nmask);
> =20
>  	if (PageHighMem(page)
> @@ -1593,6 +1599,9 @@ static struct page *new_node_page(struct page *page=
, unsigned long private,
>  		new_page =3D __alloc_pages(gfp_mask, 0,
>  					node_zonelist(nid, gfp_mask));
> =20
> +	if (new_page && order =3D=3D hpage_order(page))
> +		prep_transhuge_page(new_page);
> +
>  	return new_page;
>  }
> =20
> @@ -1622,7 +1631,9 @@ do_migrate_range(unsigned long start_pfn, unsigned =
long end_pfn)
>  			if (isolate_huge_page(page, &source))
>  				move_pages -=3D 1 << compound_order(head);
>  			continue;
> -		}
> +		} else if (thp_migration_supported() && PageTransHuge(page))
> +			pfn =3D page_to_pfn(compound_head(page))
> +				+ hpage_nr_pages(page) - 1;
> =20
>  		if (!get_page_unless_zero(page))
>  			continue;
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 5cc6a99918ab..021ff13b9a7a 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -94,6 +94,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/printk.h>
> +#include <linux/swapops.h>
> =20
>  #include <asm/tlbflush.h>
>  #include <asm/uaccess.h>
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 98acf7d5cef2..bfbe66798a7a 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -150,7 +150,9 @@ static inline unsigned long change_pmd_range(struct v=
m_area_struct *vma,
>  		unsigned long this_pages;
> =20
>  		next =3D pmd_addr_end(addr, end);
> -		if (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
> +		if (!pmd_present(*pmd))
> +			continue;
> +		if (!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
>  				&& pmd_none_or_clear_bad(pmd))
>  			continue;
> =20
> @@ -160,7 +162,7 @@ static inline unsigned long change_pmd_range(struct v=
m_area_struct *vma,
>  			mmu_notifier_invalidate_range_start(mm, mni_start, end);
>  		}
> =20
> -		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> +		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr !=3D HPAGE_PMD_SIZE) {
>  				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  				if (pmd_trans_unstable(pmd))
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 8233b0105c82..5d537ce12adc 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -213,7 +213,7 @@ unsigned long move_page_tables(struct vm_area_struct =
*vma,
>  		new_pmd =3D alloc_new_pmd(vma->vm_mm, vma, new_addr);
>  		if (!new_pmd)
>  			break;
> -		if (pmd_trans_huge(*old_pmd)) {
> +		if (is_swap_pmd(*old_pmd) || pmd_trans_huge(*old_pmd)) {
>  			if (extent =3D=3D HPAGE_PMD_SIZE) {
>  				bool moved;
>  				/* See comment in move_ptes() */
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 03761577ae86..114fc2b5a370 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -2,6 +2,8 @@
>  #include <linux/highmem.h>
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> =20
>  static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long =
end,
>  			  struct mm_walk *walk)
> --=20
> 2.11.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
