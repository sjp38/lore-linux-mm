Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAE76B0400
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:37:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l87so50017130qki.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:37:33 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id v65si4247960qkb.91.2017.06.21.07.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 07:37:32 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v7 05/10] mm: thp: enable thp migration in generic path
Date: Wed, 21 Jun 2017 10:37:30 -0400
Message-ID: <4A34E00E-C36A-437A-BEC1-05BAA9E99EA2@sent.com>
In-Reply-To: <20170621112329.uc6ejsnicujchjrh@node.shutemov.name>
References: <20170620230715.81590-1-zi.yan@sent.com>
 <20170620230715.81590-6-zi.yan@sent.com>
 <20170621112329.uc6ejsnicujchjrh@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_58907586-27F1-4105-B304-2A969056335B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_58907586-27F1-4105-B304-2A969056335B_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 21 Jun 2017, at 7:23, Kirill A. Shutemov wrote:

> On Tue, Jun 20, 2017 at 07:07:10PM -0400, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> This patch adds thp migration's core code, including conversions
>> between a PMD entry and a swap entry, setting PMD migration entry,
>> removing PMD migration entry, and waiting on PMD migration entries.
>>
>> This patch makes it possible to support thp migration.
>> If you fail to allocate a destination page as a thp, you just split
>> the source thp as we do now, and then enter the normal page migration.=

>> If you succeed to allocate destination thp, you enter thp migration.
>> Subsequent patches actually enable thp migration for each caller of
>> page migration by allowing its get_new_page() callback to
>> allocate thps.
>>
>> ChangeLog v1 -> v2:
>> - support pte-mapped thp, doubly-mapped thp
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> ChangeLog v2 -> v3:
>> - use page_vma_mapped_walk()
>> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear() in
>>   set_pmd_migration_entry()
>>
>> ChangeLog v3 -> v4:
>> - factor out the code of removing pte pgtable page in zap_huge_pmd()
>>
>> ChangeLog v4 -> v5:
>> - remove unnecessary PTE-mapped THP code in remove_migration_pmd()
>>   and set_pmd_migration_entry()
>> - restructure the code in zap_huge_pmd() to avoid factoring out
>>   the pte pgtable page code
>> - in zap_huge_pmd(), check that PMD swap entries are migration entries=

>> - change author information
>>
>> ChangeLog v5 -> v7
>> - use macro to disable the code when thp migration is not enabled
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  arch/x86/include/asm/pgtable_64.h |  2 +
>>  include/linux/swapops.h           | 69 +++++++++++++++++++++++++++++-=

>>  mm/huge_memory.c                  | 88 ++++++++++++++++++++++++++++++=
++++++---
>>  mm/migrate.c                      | 32 +++++++++++++-
>>  mm/page_vma_mapped.c              | 17 ++++++--
>>  mm/pgtable-generic.c              |  3 +-
>>  mm/rmap.c                         | 13 ++++++
>>  7 files changed, 212 insertions(+), 12 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/=
pgtable_64.h
>> index 45b7a4094de0..eac7f8cf4ae0 100644
>> --- a/arch/x86/include/asm/pgtable_64.h
>> +++ b/arch/x86/include/asm/pgtable_64.h
>> @@ -208,7 +208,9 @@ static inline int pgd_large(pgd_t pgd) { return 0;=
 }
>>  					 ((type) << (SWP_TYPE_FIRST_BIT)) \
>>  					 | ((offset) << SWP_OFFSET_FIRST_BIT) })
>>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
>> +#define __pmd_to_swp_entry(pmd)		((swp_entry_t) { pmd_val((pmd)) })
>>  #define __swp_entry_to_pte(x)		((pte_t) { .pte =3D (x).val })
>> +#define __swp_entry_to_pmd(x)		((pmd_t) { .pmd =3D (x).val })
>>
>>  extern int kern_addr_valid(unsigned long addr);
>>  extern void cleanup_highmap(void);
>> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
>> index c5ff7b217ee6..ae0c5fc18788 100644
>> --- a/include/linux/swapops.h
>> +++ b/include/linux/swapops.h
>> @@ -103,7 +103,8 @@ static inline void *swp_to_radix_entry(swp_entry_t=
 entry)
>>  #ifdef CONFIG_MIGRATION
>>  static inline swp_entry_t make_migration_entry(struct page *page, int=
 write)
>>  {
>> -	BUG_ON(!PageLocked(page));
>> +	BUG_ON(!PageLocked(compound_head(page)));
>> +
>>  	return swp_entry(write ? SWP_MIGRATION_WRITE : SWP_MIGRATION_READ,
>>  			page_to_pfn(page));
>>  }
>> @@ -126,7 +127,7 @@ static inline struct page *migration_entry_to_page=
(swp_entry_t entry)
>>  	 * Any use of migration entries may only occur while the
>>  	 * corresponding page is locked
>>  	 */
>> -	BUG_ON(!PageLocked(p));
>> +	BUG_ON(!PageLocked(compound_head(p)));
>>  	return p;
>>  }
>>
>> @@ -163,6 +164,70 @@ static inline int is_write_migration_entry(swp_en=
try_t entry)
>>
>>  #endif
>>
>> +struct page_vma_mapped_walk;
>> +
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +extern void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw=
,
>> +		struct page *page);
>> +
>> +extern void remove_migration_pmd(struct page_vma_mapped_walk *pvmw,
>> +		struct page *new);
>> +
>> +extern void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd=
);
>> +
>> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
>> +{
>> +	swp_entry_t arch_entry;
>> +
>> +	arch_entry =3D __pmd_to_swp_entry(pmd);
>> +	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
>> +}
>> +
>> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>> +{
>> +	swp_entry_t arch_entry;
>> +
>> +	arch_entry =3D __swp_entry(swp_type(entry), swp_offset(entry));
>> +	return __swp_entry_to_pmd(arch_entry);
>> +}
>> +
>> +static inline int is_pmd_migration_entry(pmd_t pmd)
>> +{
>> +	return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd)=
);
>> +}
>> +#else
>> +static inline void set_pmd_migration_entry(struct page_vma_mapped_wal=
k *pvmw,
>> +		struct page *page)
>> +{
>> +	BUILD_BUG();
>> +}
>> +
>> +static inline void remove_migration_pmd(struct page_vma_mapped_walk *=
pvmw,
>> +		struct page *new)
>> +{
>> +	BUILD_BUG();
>> +}
>> +
>> +static inline void pmd_migration_entry_wait(struct mm_struct *m, pmd_=
t *p) { }
>> +
>> +static inline swp_entry_t pmd_to_swp_entry(pmd_t pmd)
>> +{
>> +	BUILD_BUG();
>> +	return swp_entry(0, 0);
>> +}
>> +
>> +static inline pmd_t swp_entry_to_pmd(swp_entry_t entry)
>> +{
>> +	BUILD_BUG();
>> +	return (pmd_t){ 0 };
>> +}
>> +
>> +static inline int is_pmd_migration_entry(pmd_t pmd)
>> +{
>> +	return 0;
>> +}
>> +#endif
>> +
>>  #ifdef CONFIG_MEMORY_FAILURE
>>
>>  extern atomic_long_t num_poisoned_pages __read_mostly;
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 421631ff3aeb..d9405ba628f6 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1641,10 +1641,27 @@ int zap_huge_pmd(struct mmu_gather *tlb, struc=
t vm_area_struct *vma,
>>  		spin_unlock(ptl);
>>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>>  	} else {
>> -		struct page *page =3D pmd_page(orig_pmd);
>> -		page_remove_rmap(page, true);
>> -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
>> -		VM_BUG_ON_PAGE(!PageHead(page), page);
>> +		struct page *page =3D NULL;
>> +		int migration =3D 0;
>> +
>> +		if (pmd_present(orig_pmd)) {
>> +			page =3D pmd_page(orig_pmd);
>> +			page_remove_rmap(page, true);
>> +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
>> +			VM_BUG_ON_PAGE(!PageHead(page), page);
>> +		} else {
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>
> Can we have IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION) instead here a=
nd below?
>

No. Both chunks have pmd_to_swp_entry(), which triggers BUILD_BUG()
when CONFIG_ARCH_ENABLE_THP_MIGRATION is not set. So we need this macro
to disable the code when THP migration is not enabled.

>> +			swp_entry_t entry;
>> +
>> +			VM_BUG_ON(!is_pmd_migration_entry(orig_pmd));
>> +			entry =3D pmd_to_swp_entry(orig_pmd);
>> +			page =3D pfn_to_page(swp_offset(entry));
>> +			migration =3D 1;
>
> I guess something like 'flush_needed' instead would be more descriptive=
=2E

Will change the name.

>> +#else
>> +			WARN_ONCE(1, "Non present huge pmd without pmd migration enabled!"=
);
>> +#endif
>> +		}
>> +
>>  		if (PageAnon(page)) {
>>  			zap_deposited_table(tlb->mm, pmd);
>>  			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
>> @@ -1653,8 +1670,10 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct=
 vm_area_struct *vma,
>>  				zap_deposited_table(tlb->mm, pmd);
>>  			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
>>  		}
>> +
>>  		spin_unlock(ptl);
>> -		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>> +		if (!migration)
>> +			tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>>  	}
>>  	return 1;
>>  }
>> @@ -2694,3 +2713,62 @@ static int __init split_huge_pages_debugfs(void=
)
>>  }
>>  late_initcall(split_huge_pages_debugfs);
>>  #endif
>> +
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +void set_pmd_migration_entry(struct page_vma_mapped_walk *pvmw,
>> +		struct page *page)
>> +{
>> +	struct vm_area_struct *vma =3D pvmw->vma;
>> +	struct mm_struct *mm =3D vma->vm_mm;
>> +	unsigned long address =3D pvmw->address;
>> +	pmd_t pmdval;
>> +	swp_entry_t entry;
>> +
>> +	if (!(pvmw->pmd && !pvmw->pte))
>> +		return;
>> +
>> +	mmu_notifier_invalidate_range_start(mm, address,
>> +			address + HPAGE_PMD_SIZE);
>> +
>> +	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
>> +	pmdval =3D pmdp_huge_clear_flush(vma, address, pvmw->pmd);
>
> We don't hold mmap_sem for write here, right?
>
> I *think* it means we can race with MADV_DONTNEED the same way as
> described in ced108037c2a.
>
> I guess pmdp_invalidate() approach is required.

Yes. You are right. I will use pmdp_invalidate() instead.


>> +	if (pmd_dirty(pmdval))
>> +		set_page_dirty(page);
>> +	entry =3D make_migration_entry(page, pmd_write(pmdval));
>> +	pmdval =3D swp_entry_to_pmd(entry);
>> +	set_pmd_at(mm, address, pvmw->pmd, pmdval);
>> +	page_remove_rmap(page, true);
>> +	put_page(page);
>> +
>> +	mmu_notifier_invalidate_range_end(mm, address,
>> +			address + HPAGE_PMD_SIZE);
>> +}
>> +
>> +void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct p=
age *new)
>> +{
>> +	struct vm_area_struct *vma =3D pvmw->vma;
>> +	struct mm_struct *mm =3D vma->vm_mm;
>> +	unsigned long address =3D pvmw->address;
>> +	unsigned long mmun_start =3D address & HPAGE_PMD_MASK;
>> +	unsigned long mmun_end =3D mmun_start + HPAGE_PMD_SIZE;
>> +	pmd_t pmde;
>> +	swp_entry_t entry;
>> +
>> +	if (!(pvmw->pmd && !pvmw->pte))
>> +		return;
>> +
>> +	entry =3D pmd_to_swp_entry(*pvmw->pmd);
>> +	get_page(new);
>> +	pmde =3D pmd_mkold(mk_huge_pmd(new, vma->vm_page_prot));
>> +	if (is_write_migration_entry(entry))
>> +		pmde =3D maybe_pmd_mkwrite(pmde, vma);
>> +
>> +	flush_cache_range(vma, mmun_start, mmun_end);
>> +	page_add_anon_rmap(new, vma, mmun_start, true);
>> +	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
>> +	flush_tlb_range(vma, mmun_start, mmun_end);
>
> Why do we need flush here? We replace non-present pmd with a present on=
e.
>
> And we are under ptl, but flush IIRC can sleep.

Right. flush is not needed here. Thanks.

>> +	if (vma->vm_flags & VM_LOCKED)
>> +		mlock_vma_page(new);
>> +	update_mmu_cache_pmd(vma, address, pvmw->pmd);
>> +}
>> +#endif
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 627671551873..cae5c3b3b491 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -215,6 +215,15 @@ static bool remove_migration_pte(struct page *pag=
e, struct vm_area_struct *vma,
>>  			new =3D page - pvmw.page->index +
>>  				linear_page_index(vma, pvmw.address);
>>
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +		/* PMD-mapped THP migration entry */
>> +		if (!pvmw.pte && pvmw.page) {
>> +			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
>> +			remove_migration_pmd(&pvmw, new);
>> +			continue;
>> +		}
>> +#endif
>> +
>>  		get_page(new);
>>  		pte =3D pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
>>  		if (pte_swp_soft_dirty(*pvmw.pte))
>> @@ -329,6 +338,27 @@ void migration_entry_wait_huge(struct vm_area_str=
uct *vma,
>>  	__migration_entry_wait(mm, pte, ptl);
>>  }
>>
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +void pmd_migration_entry_wait(struct mm_struct *mm, pmd_t *pmd)
>> +{
>> +	spinlock_t *ptl;
>> +	struct page *page;
>> +
>> +	ptl =3D pmd_lock(mm, pmd);
>> +	if (!is_pmd_migration_entry(*pmd))
>> +		goto unlock;
>> +	page =3D migration_entry_to_page(pmd_to_swp_entry(*pmd));
>> +	if (!get_page_unless_zero(page))
>> +		goto unlock;
>> +	spin_unlock(ptl);
>> +	wait_on_page_locked(page);
>> +	put_page(page);
>> +	return;
>> +unlock:
>> +	spin_unlock(ptl);
>> +}
>> +#endif
>> +
>>  #ifdef CONFIG_BLOCK
>>  /* Returns true if all buffers are successfully locked */
>>  static bool buffer_migrate_lock_buffers(struct buffer_head *head,
>> @@ -1087,7 +1117,7 @@ static ICE_noinline int unmap_and_move(new_page_=
t get_new_page,
>>  		goto out;
>>  	}
>>
>> -	if (unlikely(PageTransHuge(page))) {
>> +	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
>>  		lock_page(page);
>>  		rc =3D split_huge_page(page);
>>  		unlock_page(page);
>> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
>> index 8ec6ba230bb9..ff5517e67788 100644
>> --- a/mm/page_vma_mapped.c
>> +++ b/mm/page_vma_mapped.c
>> @@ -138,16 +138,27 @@ bool page_vma_mapped_walk(struct page_vma_mapped=
_walk *pvmw)
>>  	if (!pud_present(*pud))
>>  		return false;
>>  	pvmw->pmd =3D pmd_offset(pud, pvmw->address);
>> -	if (pmd_trans_huge(*pvmw->pmd)) {
>> +	if (pmd_trans_huge(*pvmw->pmd) || is_pmd_migration_entry(*pvmw->pmd)=
) {
>>  		pvmw->ptl =3D pmd_lock(mm, pvmw->pmd);
>> -		if (!pmd_present(*pvmw->pmd))
>> -			return not_found(pvmw);
>>  		if (likely(pmd_trans_huge(*pvmw->pmd))) {
>>  			if (pvmw->flags & PVMW_MIGRATION)
>>  				return not_found(pvmw);
>>  			if (pmd_page(*pvmw->pmd) !=3D page)
>>  				return not_found(pvmw);
>>  			return true;
>> +		} else if (!pmd_present(*pvmw->pmd)) {
>
> Shouldn't we check PVMW_MIGRATION here?

Right. I will add:

if (!(pvmw->flags & PVMW_MIGRATION))
    return not_found(pvmw);

>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +			if (unlikely(is_migration_entry(pmd_to_swp_entry(*pvmw->pmd)))) {
>> +				swp_entry_t entry =3D pmd_to_swp_entry(*pvmw->pmd);
>> +
>> +				if (migration_entry_to_page(entry) !=3D page)
>> +					return not_found(pvmw);
>> +				return true;
>> +			}
>> +#else
>> +			WARN_ONCE(1, "Non present huge pmd without pmd migration enabled!"=
);
>> +#endif
>> +			return not_found(pvmw);
>>  		} else {
>>  			/* THP pmd was split under us: handle on pte level */
>>  			spin_unlock(pvmw->ptl);

Thanks for your review.

--
Best Regards
Yan Zi

--=_MailMate_58907586-27F1-4105-B304-2A969056335B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZSoSrAAoJEEGLLxGcTqbMwEIH/0vLY57yFGgJqOZ+lmyA3QXJ
BMHEtDX0ZXZ+Kr9MXIfsh23W7U/kIPKE+kp6bWmL1rkfCPJjN2pGudYSU9znta4a
TsGWLjFw/XmKfOfhwEs/jdsuaOdqJYFLu2f6FWuI55AqlEXFL63DohaMrekxcKGd
Tq28wUujEZW6sW1Q8wyZjCyc7f7HbN+azf3rU+B9+rVS1SZm2/v1rzrFRmzf7Wp1
WzugmYtKHCGcUY9qk0ic0B70zrVEEZ6idGBR9dAOL4dlVyRcs5jJnytOeT1UV34Q
9fQ5MnF4Rip5hPuL9e7fd4/1V9m+6y95pG5QYtU5qOQpJadIpkF2AqjkpmGrIpU=
=fybN
-----END PGP SIGNATURE-----

--=_MailMate_58907586-27F1-4105-B304-2A969056335B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
