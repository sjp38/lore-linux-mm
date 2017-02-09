Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84B396B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 12:36:56 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e137so32214141itc.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 09:36:56 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0119.outbound.protection.outlook.com. [104.47.36.119])
        by mx.google.com with ESMTPS id 19si5505298iti.70.2017.02.09.09.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 09:36:55 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 09/14] mm: thp: check pmd migration entry in common
 path
Date: Thu, 9 Feb 2017 11:36:47 -0600
Message-ID: <30979A4A-4DFA-42B4-AD63-89261650544D@cs.rutgers.edu>
In-Reply-To: <20170209091616.GA15890@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-10-zi.yan@sent.com>
 <20170209091616.GA15890@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_9E427DA3-73D2-4C1D-AF5A-CD816ED9A7DB_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>

--=_MailMate_9E427DA3-73D2-4C1D-AF5A-CD816ED9A7DB_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 9 Feb 2017, at 3:16, Naoya Horiguchi wrote:

> On Sun, Feb 05, 2017 at 11:12:47AM -0500, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> If one of callers of page migration starts to handle thp,
>> memory management code start to see pmd migration entry, so we need
>> to prepare for it before enabling. This patch changes various code
>> point which checks the status of given pmds in order to prevent race
>> between thp migration and the pmd-related works.
>>
>> ChangeLog v1 -> v2:
>> - introduce pmd_related() (I know the naming is not good, but can't
>>   think up no better name. Any suggesntion is welcomed.)
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> ChangeLog v2 -> v3:
>> - add is_swap_pmd()
>> - a pmd entry should be is_swap_pmd(), pmd_trans_huge(), pmd_devmap(),=

>>   or pmd_none()
>
> (nitpick) ... or normal pmd pointing to pte pages?

Sure, I will add it.

>
>> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear()
>> - flush_cache_range() while set_pmd_migration_entry()
>> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() retur=
n
>>   true on pmd_migration_entry, so that migration entries are not
>>   treated as pmd page table entries.
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  arch/x86/mm/gup.c             |  4 +--
>>  fs/proc/task_mmu.c            | 22 ++++++++-----
>>  include/asm-generic/pgtable.h | 71 ----------------------------------=
------
>>  include/linux/huge_mm.h       | 21 ++++++++++--
>>  include/linux/swapops.h       | 74 ++++++++++++++++++++++++++++++++++=
+++++++
>>  mm/gup.c                      | 20 ++++++++++--
>>  mm/huge_memory.c              | 76 ++++++++++++++++++++++++++++++++++=
++-------
>>  mm/madvise.c                  |  2 ++
>>  mm/memcontrol.c               |  2 ++
>>  mm/memory.c                   |  9 +++--
>>  mm/memory_hotplug.c           | 13 +++++++-
>>  mm/mempolicy.c                |  1 +
>>  mm/mprotect.c                 |  6 ++--
>>  mm/mremap.c                   |  2 +-
>>  mm/pagewalk.c                 |  2 ++
>>  15 files changed, 221 insertions(+), 104 deletions(-)
>>
>> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
>> index 0d4fb3ebbbac..78a153d90064 100644
>> --- a/arch/x86/mm/gup.c
>> +++ b/arch/x86/mm/gup.c
>> @@ -222,9 +222,9 @@ static int gup_pmd_range(pud_t pud, unsigned long =
addr, unsigned long end,
>>  		pmd_t pmd =3D *pmdp;
>>
>>  		next =3D pmd_addr_end(addr, end);
>> -		if (pmd_none(pmd))
>> +		if (!pmd_present(pmd))
>>  			return 0;
>> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
>> +		if (unlikely(pmd_large(pmd))) {
>>  			/*
>>  			 * NUMA hinting faults need to be handled in the GUP
>>  			 * slowpath for accounting purposes and so that they
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 6c07c7813b26..1e64d6898c68 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -596,7 +596,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned lo=
ng addr, unsigned long end,
>>
>>  	ptl =3D pmd_trans_huge_lock(pmd, vma);
>>  	if (ptl) {
>> -		smaps_pmd_entry(pmd, addr, walk);
>> +		if (pmd_present(*pmd))
>> +			smaps_pmd_entry(pmd, addr, walk);
>>  		spin_unlock(ptl);
>>  		return 0;
>>  	}
>> @@ -929,6 +930,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsign=
ed long addr,
>>  			goto out;
>>  		}
>>
>> +		if (!pmd_present(*pmd))
>> +			goto out;
>> +
>>  		page =3D pmd_page(*pmd);
>>
>>  		/* Clear accessed and referenced bits. */
>> @@ -1208,19 +1212,19 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsi=
gned long addr, unsigned long end,
>>  	if (ptl) {
>>  		u64 flags =3D 0, frame =3D 0;
>>  		pmd_t pmd =3D *pmdp;
>> +		struct page *page;
>>
>>  		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
>>  			flags |=3D PM_SOFT_DIRTY;
>>
>> -		/*
>> -		 * Currently pmd for thp is always present because thp
>> -		 * can not be swapped-out, migrated, or HWPOISONed
>> -		 * (split in such cases instead.)
>> -		 * This if-check is just to prepare for future implementation.
>> -		 */
>> -		if (pmd_present(pmd)) {
>> -			struct page *page =3D pmd_page(pmd);
>> +		if (is_pmd_migration_entry(pmd)) {
>> +			swp_entry_t entry =3D pmd_to_swp_entry(pmd);
>>
>> +			frame =3D swp_type(entry) |
>> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
>> +			page =3D migration_entry_to_page(entry);
>> +		} else if (pmd_present(pmd)) {
>> +			page =3D pmd_page(pmd);
>>  			if (page_mapcount(page) =3D=3D 1)
>>  				flags |=3D PM_MMAP_EXCLUSIVE;
>>
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtab=
le.h
>> index b71a431ed649..6cf9e9b5a7be 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -726,77 +726,6 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
>>  #ifndef arch_needs_pgtable_deposit
>>  #define arch_needs_pgtable_deposit() (false)
>>  #endif
>> -/*
>> - * This function is meant to be used by sites walking pagetables with=

>> - * the mmap_sem hold in read mode to protect against MADV_DONTNEED an=
d
>> - * transhuge page faults. MADV_DONTNEED can convert a transhuge pmd
>> - * into a null pmd and the transhuge page fault can convert a null pm=
d
>> - * into an hugepmd or into a regular pmd (if the hugepage allocation
>> - * fails). While holding the mmap_sem in read mode the pmd becomes
>> - * stable and stops changing under us only if it's not null and not a=

>> - * transhuge pmd. When those races occurs and this function makes a
>> - * difference vs the standard pmd_none_or_clear_bad, the result is
>> - * undefined so behaving like if the pmd was none is safe (because it=

>> - * can return none anyway). The compiler level barrier() is criticall=
y
>> - * important to compute the two checks atomically on the same pmdval.=

>> - *
>> - * For 32bit kernels with a 64bit large pmd_t this automatically take=
s
>> - * care of reading the pmd atomically to avoid SMP race conditions
>> - * against pmd_populate() when the mmap_sem is hold for reading by th=
e
>> - * caller (a special atomic read not done by "gcc" as in the generic
>> - * version above, is also needed when THP is disabled because the pag=
e
>> - * fault can populate the pmd from under us).
>> - */
>> -static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>> -{
>> -	pmd_t pmdval =3D pmd_read_atomic(pmd);
>> -	/*
>> -	 * The barrier will stabilize the pmdval in a register or on
>> -	 * the stack so that it will stop changing under the code.
>> -	 *
>> -	 * When CONFIG_TRANSPARENT_HUGEPAGE=3Dy on x86 32bit PAE,
>> -	 * pmd_read_atomic is allowed to return a not atomic pmdval
>> -	 * (for example pointing to an hugepage that has never been
>> -	 * mapped in the pmd). The below checks will only care about
>> -	 * the low part of the pmd with 32bit PAE x86 anyway, with the
>> -	 * exception of pmd_none(). So the important thing is that if
>> -	 * the low part of the pmd is found null, the high part will
>> -	 * be also null or the pmd_none() check below would be
>> -	 * confused.
>> -	 */
>> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> -	barrier();
>> -#endif
>> -	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
>> -		return 1;
>> -	if (unlikely(pmd_bad(pmdval))) {
>> -		pmd_clear_bad(pmd);
>> -		return 1;
>> -	}
>> -	return 0;
>> -}
>> -
>> -/*
>> - * This is a noop if Transparent Hugepage Support is not built into
>> - * the kernel. Otherwise it is equivalent to
>> - * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in=

>> - * places that already verified the pmd is not none and they want to
>> - * walk ptes while holding the mmap sem in read mode (write mode don'=
t
>> - * need this). If THP is not enabled, the pmd can't go away under the=

>> - * code even if MADV_DONTNEED runs, but if THP is enabled we need to
>> - * run a pmd_trans_unstable before walking the ptes after
>> - * split_huge_page_pmd returns (because it may have run when the pmd
>> - * become null, but then a page fault can map in a THP and not a
>> - * regular page).
>> - */
>> -static inline int pmd_trans_unstable(pmd_t *pmd)
>> -{
>> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> -	return pmd_none_or_trans_huge_or_clear_bad(pmd);
>> -#else
>> -	return 0;
>> -#endif
>> -}
>>
>>  #ifndef CONFIG_NUMA_BALANCING
>>  /*
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 83a8d42f9d55..c2e5a4eab84a 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -131,7 +131,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, =
pmd_t *pmd,
>>  #define split_huge_pmd(__vma, __pmd, __address)				\
>>  	do {								\
>>  		pmd_t *____pmd =3D (__pmd);				\
>> -		if (pmd_trans_huge(*____pmd)				\
>> +		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
>>  					|| pmd_devmap(*____pmd))	\
>>  			__split_huge_pmd(__vma, __pmd, __address,	\
>>  						false, NULL);		\
>> @@ -162,12 +162,18 @@ extern spinlock_t *__pmd_trans_huge_lock(pmd_t *=
pmd,
>>  		struct vm_area_struct *vma);
>>  extern spinlock_t *__pud_trans_huge_lock(pud_t *pud,
>>  		struct vm_area_struct *vma);
>> +
>> +static inline int is_swap_pmd(pmd_t pmd)
>> +{
>> +	return !pmd_none(pmd) && !pmd_present(pmd);
>> +}
>> +
>>  /* mmap_sem must be held on entry */
>>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>>  		struct vm_area_struct *vma)
>>  {
>>  	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
>> -	if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
>> +	if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd))
>>  		return __pmd_trans_huge_lock(pmd, vma);
>>  	else
>>  		return NULL;
>> @@ -192,6 +198,12 @@ struct page *follow_devmap_pmd(struct vm_area_str=
uct *vma, unsigned long addr,
>>  		pmd_t *pmd, int flags);
>>  struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned l=
ong addr,
>>  		pud_t *pud, int flags);
>> +static inline int hpage_order(struct page *page)
>> +{
>> +	if (unlikely(PageTransHuge(page)))
>> +		return HPAGE_PMD_ORDER;
>> +	return 0;
>> +}
>>
>>  extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd=
);
>>
>> @@ -232,6 +244,7 @@ static inline bool thp_migration_supported(void)
>>  #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })
>>
>>  #define hpage_nr_pages(x) 1
>> +#define hpage_order(x) 0
>>
>>  #define transparent_hugepage_enabled(__vma) 0
>>
>> @@ -274,6 +287,10 @@ static inline void vma_adjust_trans_huge(struct v=
m_area_struct *vma,
>>  					 long adjust_next)
>>  {
>>  }
>> +static inline int is_swap_pmd(pmd_t pmd)
>> +{
>> +	return 0;
>> +}
>>  static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
>>  		struct vm_area_struct *vma)
>>  {
>> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
>> index 6625bea13869..50e4aa7e7ff9 100644
>> --- a/include/linux/swapops.h
>> +++ b/include/linux/swapops.h
>> @@ -229,6 +229,80 @@ static inline int is_pmd_migration_entry(pmd_t pm=
d)
>>  }
>>  #endif
>>
>> +/*
>> + * This function is meant to be used by sites walking pagetables with=

>> + * the mmap_sem hold in read mode to protect against MADV_DONTNEED an=
d
>> + * transhuge page faults. MADV_DONTNEED can convert a transhuge pmd
>> + * into a null pmd and the transhuge page fault can convert a null pm=
d
>> + * into an hugepmd or into a regular pmd (if the hugepage allocation
>> + * fails). While holding the mmap_sem in read mode the pmd becomes
>> + * stable and stops changing under us only if it's not null and not a=

>> + * transhuge pmd. When those races occurs and this function makes a
>> + * difference vs the standard pmd_none_or_clear_bad, the result is
>> + * undefined so behaving like if the pmd was none is safe (because it=

>> + * can return none anyway). The compiler level barrier() is criticall=
y
>> + * important to compute the two checks atomically on the same pmdval.=

>> + *
>> + * For 32bit kernels with a 64bit large pmd_t this automatically take=
s
>> + * care of reading the pmd atomically to avoid SMP race conditions
>> + * against pmd_populate() when the mmap_sem is hold for reading by th=
e
>> + * caller (a special atomic read not done by "gcc" as in the generic
>> + * version above, is also needed when THP is disabled because the pag=
e
>> + * fault can populate the pmd from under us).
>> + */
>> +static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>> +{
>> +	pmd_t pmdval =3D pmd_read_atomic(pmd);
>> +	/*
>> +	 * The barrier will stabilize the pmdval in a register or on
>> +	 * the stack so that it will stop changing under the code.
>> +	 *
>> +	 * When CONFIG_TRANSPARENT_HUGEPAGE=3Dy on x86 32bit PAE,
>> +	 * pmd_read_atomic is allowed to return a not atomic pmdval
>> +	 * (for example pointing to an hugepage that has never been
>> +	 * mapped in the pmd). The below checks will only care about
>> +	 * the low part of the pmd with 32bit PAE x86 anyway, with the
>> +	 * exception of pmd_none(). So the important thing is that if
>> +	 * the low part of the pmd is found null, the high part will
>> +	 * be also null or the pmd_none() check below would be
>> +	 * confused.
>> +	 */
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	barrier();
>> +#endif
>> +	if (pmd_none(pmdval) || pmd_trans_huge(pmdval)
>> +			|| is_pmd_migration_entry(pmdval))
>> +		return 1;
>> +	if (unlikely(pmd_bad(pmdval))) {
>> +		pmd_clear_bad(pmd);
>> +		return 1;
>> +	}
>> +	return 0;
>> +}
>> +
>> +/*
>> + * This is a noop if Transparent Hugepage Support is not built into
>> + * the kernel. Otherwise it is equivalent to
>> + * pmd_none_or_trans_huge_or_clear_bad(), and shall only be called in=

>> + * places that already verified the pmd is not none and they want to
>> + * walk ptes while holding the mmap sem in read mode (write mode don'=
t
>> + * need this). If THP is not enabled, the pmd can't go away under the=

>> + * code even if MADV_DONTNEED runs, but if THP is enabled we need to
>> + * run a pmd_trans_unstable before walking the ptes after
>> + * split_huge_page_pmd returns (because it may have run when the pmd
>> + * become null, but then a page fault can map in a THP and not a
>> + * regular page).
>> + */
>> +static inline int pmd_trans_unstable(pmd_t *pmd)
>> +{
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	return pmd_none_or_trans_huge_or_clear_bad(pmd);
>> +#else
>> +	return 0;
>> +#endif
>> +}
>> +
>> +
>
> These functions are page table or thp matter, so putting them in swapop=
s.h
> looks weird to me. Maybe you can avoid this code transfer by using !pmd=
_present
> instead of is_pmd_migration_entry?
> And we have to consider renaming pmd_none_or_trans_huge_or_clear_bad(),=

> I like a simple name like __pmd_trans_unstable(), but if you have an id=
ea,
> that's great.

Yes. I will move it back.

I am not sure if it is OK to only use !pmd_present. We may miss some pmd_=
bad.

Kirill and Andrea, can you give some insight on this?


>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 19b460acb5e1..9cb4c83151a8 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>
> Changes on mm/memory_hotplug.c should be with patch 14/14?
> # If that's right, definition of hpage_order() also should go to 14/14.=


Got it. I will move it.


--
Best Regards
Yan Zi

--=_MailMate_9E427DA3-73D2-4C1D-AF5A-CD816ED9A7DB_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYnKivAAoJEEGLLxGcTqbMUdgH/3RNDlYfzA7jtpCQwBj+jHDA
3yLW4+oAZhZhpI5n8U+IUYxkBLFc5ho1BGFOUyZbKu5STaUmoPvSDeYv17z3ugK2
MBg+S4Y+1ameQSbDRqbOOhaRc5pynH5YiPnSPlWempZ/1hN2YlNok/dEwOybSJWv
IF5ww9LIBshyc5hIP6z7I7+pUY8rol5oW19VAWkMpZey8WPJIg2/11OCBGC7joDJ
dlRkIZ9NTO/5GUb9mAmyAuiWxG6l8xpFKyk4nRaswGHj59cWJUBHfccqIsNqThxb
yGxJIcqjrJUi7IOUT77/uigqJvgIYHzmw3y+CbfTgbXYT3EVdvl+FF6RAUZnAU4=
=MGaF
-----END PGP SIGNATURE-----

--=_MailMate_9E427DA3-73D2-4C1D-AF5A-CD816ED9A7DB_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
