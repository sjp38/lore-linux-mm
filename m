Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C89A66B0389
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:17:10 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id s186so4834052qkb.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 07:17:10 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0104.outbound.protection.outlook.com. [104.47.38.104])
        by mx.google.com with ESMTPS id d17si8188132qke.138.2017.02.09.07.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 07:17:10 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 08/14] mm: thp: enable thp migration in generic path
Date: Thu, 9 Feb 2017 09:17:01 -0600
Message-ID: <7AE21E4F-EEEB-4C24-8158-473770119436@cs.rutgers.edu>
In-Reply-To: <20170209091528.GB15649@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-9-zi.yan@sent.com>
 <20170209091528.GB15649@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_250D46D4-7E4E-424F-A7BB-743748908B10_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>

--=_MailMate_250D46D4-7E4E-424F-A7BB-743748908B10_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 9 Feb 2017, at 3:15, Naoya Horiguchi wrote:

> On Sun, Feb 05, 2017 at 11:12:46AM -0500, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  arch/x86/include/asm/pgtable_64.h |   2 +
>>  include/linux/swapops.h           |  70 +++++++++++++++++-
>>  mm/huge_memory.c                  | 151 +++++++++++++++++++++++++++++=
+++++----
>>  mm/migrate.c                      |  29 +++++++-
>>  mm/page_vma_mapped.c              |  13 +++-
>>  mm/pgtable-generic.c              |   3 +-
>>  mm/rmap.c                         |  14 +++-
>>  7 files changed, 259 insertions(+), 23 deletions(-)
>>
> ...
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 6893c47428b6..fd54bbdc16cf 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1613,20 +1613,51 @@ int __zap_huge_pmd_locked(struct mmu_gather *t=
lb, struct vm_area_struct *vma,
>>  		atomic_long_dec(&tlb->mm->nr_ptes);
>>  		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
>>  	} else {
>> -		struct page *page =3D pmd_page(orig_pmd);
>> -		page_remove_rmap(page, true);
>> -		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
>> -		VM_BUG_ON_PAGE(!PageHead(page), page);
>> -		if (PageAnon(page)) {
>> -			pgtable_t pgtable;
>> -			pgtable =3D pgtable_trans_huge_withdraw(tlb->mm, pmd);
>> -			pte_free(tlb->mm, pgtable);
>> -			atomic_long_dec(&tlb->mm->nr_ptes);
>> -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
>> +		struct page *page;
>> +		int migration =3D 0;
>> +
>> +		if (!is_pmd_migration_entry(orig_pmd)) {
>> +			page =3D pmd_page(orig_pmd);
>> +			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
>> +			VM_BUG_ON_PAGE(!PageHead(page), page);
>> +			page_remove_rmap(page, true);
>
>> +			if (PageAnon(page)) {
>> +				pgtable_t pgtable;
>> +
>> +				pgtable =3D pgtable_trans_huge_withdraw(tlb->mm,
>> +								      pmd);
>> +				pte_free(tlb->mm, pgtable);
>> +				atomic_long_dec(&tlb->mm->nr_ptes);
>> +				add_mm_counter(tlb->mm, MM_ANONPAGES,
>> +					       -HPAGE_PMD_NR);
>> +			} else {
>> +				if (arch_needs_pgtable_deposit())
>> +					zap_deposited_table(tlb->mm, pmd);
>> +				add_mm_counter(tlb->mm, MM_FILEPAGES,
>> +					       -HPAGE_PMD_NR);
>> +			}
>
> This block is exactly equal to the one in else block below,
> So you can factor out into some function.

Of course, I will do that.

>
>>  		} else {
>> -			if (arch_needs_pgtable_deposit())
>> -				zap_deposited_table(tlb->mm, pmd);
>> -			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
>> +			swp_entry_t entry;
>> +
>> +			entry =3D pmd_to_swp_entry(orig_pmd);
>> +			page =3D pfn_to_page(swp_offset(entry));
>
>> +			if (PageAnon(page)) {
>> +				pgtable_t pgtable;
>> +
>> +				pgtable =3D pgtable_trans_huge_withdraw(tlb->mm,
>> +								      pmd);
>> +				pte_free(tlb->mm, pgtable);
>> +				atomic_long_dec(&tlb->mm->nr_ptes);
>> +				add_mm_counter(tlb->mm, MM_ANONPAGES,
>> +					       -HPAGE_PMD_NR);
>> +			} else {
>> +				if (arch_needs_pgtable_deposit())
>> +					zap_deposited_table(tlb->mm, pmd);
>> +				add_mm_counter(tlb->mm, MM_FILEPAGES,
>> +					       -HPAGE_PMD_NR);
>> +			}
>
>> +			free_swap_and_cache(entry); /* waring in failure? */
>> +			migration =3D 1;
>>  		}
>>  		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
>>  	}
>> @@ -2634,3 +2665,97 @@ static int __init split_huge_pages_debugfs(void=
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
>> +	if (pvmw->pmd && !pvmw->pte) {
>> +		pmd_t pmdswp;
>> +
>> +		mmu_notifier_invalidate_range_start(mm, address,
>> +				address + HPAGE_PMD_SIZE);
>
> Don't you have to put mmu_notifier_invalidate_range_* outside this if b=
lock?

I think I need to add mmu_notifier_invalidate_page() in else block.

Because Kirill's page_vma_mapped_walk() iterates each PMD or PTE.
In set_pmd_migration_etnry(), if the page is PMD-mapped, it will be calle=
d once
with PMD, then mmu_notifier_invalidate_range_* can be used. On the other =
hand,
if the page is PTE-mapped, the function will be called 1~512 times depend=
ing
on how many PTEs are present. mmu_notifier_invalidate_range_* is not suit=
able.
mmu_notifier_invalidate_page() on the corresponding subpage should work.



--
Best Regards
Yan Zi

--=_MailMate_250D46D4-7E4E-424F-A7BB-743748908B10_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYnIftAAoJEEGLLxGcTqbMWiQH/AvqJQhxcHKZkh3FW8nDAH9M
9HzFEn3Q5Up5NrVIY1J1rq0fTAil1MCNvftGr2Yk4FKa8Rp91roIvbFDYSyFJMmr
kR51f7ykcvyty3FlngtUF9fDSup9RzMFXII/z9m/HcSBmeRAMumINAnBdqQwO6Sc
GNDJpoZcIXI4m+TjO2yMgQpSYbl1dxKlpFNsdMCfSVE8Vv7eT7PGH5W7wDc288zc
p7i/XlEuakShtYh3k2EnjX93JRrd5rWz26cqnRde5qAOqlngpHKlF4V3ZyJjV3KH
hgDm6mrYgNFCkBFR0GsOjicZ40L36AWk2Ckm18h0lBlRwXdwY7LpDK5ee6IIkLI=
=EbXh
-----END PGP SIGNATURE-----

--=_MailMate_250D46D4-7E4E-424F-A7BB-743748908B10_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
