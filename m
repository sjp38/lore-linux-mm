Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBD096B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:09:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d10so3779154qke.8
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:09:39 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0104.outbound.protection.outlook.com. [104.47.33.104])
        by mx.google.com with ESMTPS id t56si2305447qta.24.2017.03.24.09.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 09:09:38 -0700 (PDT)
Message-ID: <58D544B5.20102@cs.rutgers.edu>
Date: Fri, 24 Mar 2017 11:09:25 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v4 06/11] mm: thp: check pmd migration entry in common
 path
References: <20170313154507.3647-1-zi.yan@sent.com> <20170313154507.3647-7-zi.yan@sent.com> <20170324145042.bda52glerop5wydx@node.shutemov.name>
In-Reply-To: <20170324145042.bda52glerop5wydx@node.shutemov.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig987999214556999BA2161050"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

--------------enig987999214556999BA2161050
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Kirill A. Shutemov wrote:
> On Mon, Mar 13, 2017 at 11:45:02AM -0400, Zi Yan wrote:
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
>> - a pmd entry should be pmd pointing to pte pages, is_swap_pmd(),
>>   pmd_trans_huge(), pmd_devmap(), or pmd_none()
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
>>  fs/proc/task_mmu.c            | 22 +++++++++------
>>  include/asm-generic/pgtable.h |  3 +-
>>  include/linux/huge_mm.h       | 14 +++++++--
>>  mm/gup.c                      | 22 +++++++++++++--
>>  mm/huge_memory.c              | 66 ++++++++++++++++++++++++++++++++++=
++++-----
>>  mm/madvise.c                  |  2 ++
>>  mm/memcontrol.c               |  2 ++
>>  mm/memory.c                   |  9 ++++--
>>  mm/mprotect.c                 |  6 ++--
>>  mm/mremap.c                   |  2 +-
>>  11 files changed, 124 insertions(+), 28 deletions(-)
>>
<snip>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index 94fab8fa432b..2b1effb16242 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -272,6 +272,15 @@ struct page *follow_page_mask(struct vm_area_stru=
ct *vma,
>>  			return page;
>>  		return no_page_table(vma, flags);
>>  	}
>> +	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>> +		return no_page_table(vma, flags);
>> +	if (!pmd_present(*pmd)) {
>> +retry:
>> +		if (likely(!(flags & FOLL_MIGRATION)))
>> +			return no_page_table(vma, flags);
>> +		pmd_migration_entry_wait(mm, pmd);
>> +		goto retry;
>=20
> This looks a lot like endless loop if flags contain FOLL_MIGRATION. Hm?=

>=20
> I guess retry label should be on previous line.

You are right. It should be:

+	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
+		return no_page_table(vma, flags);
+retry:
+	if (!pmd_present(*pmd)) {
+		if (likely(!(flags & FOLL_MIGRATION)))
+			return no_page_table(vma, flags);
+		pmd_migration_entry_wait(mm, pmd);
+		goto retry;

>=20
>> +	}
>>  	if (pmd_devmap(*pmd)) {
>>  		ptl =3D pmd_lock(mm, pmd);
>>  		page =3D follow_devmap_pmd(vma, address, pmd, flags);
>> @@ -286,6 +295,15 @@ struct page *follow_page_mask(struct vm_area_stru=
ct *vma,
>>  		return no_page_table(vma, flags);
>> =20
>>  	ptl =3D pmd_lock(mm, pmd);
>> +	if (unlikely(!pmd_present(*pmd))) {
>> +retry_locked:
>> +		if (likely(!(flags & FOLL_MIGRATION))) {
>> +			spin_unlock(ptl);
>> +			return no_page_table(vma, flags);
>> +		}
>> +		pmd_migration_entry_wait(mm, pmd);
>> +		goto retry_locked;
>=20
> Again. That's doesn't look right..

It will be changed:

 	ptl =3D pmd_lock(mm, pmd);
+retry_locked:
+	if (unlikely(!pmd_present(*pmd))) {
+		if (likely(!(flags & FOLL_MIGRATION))) {
+			spin_unlock(ptl);
+			return no_page_table(vma, flags);
+		}
+		pmd_migration_entry_wait(mm, pmd);
+		goto retry_locked;

>=20
>> +	}
>>  	if (unlikely(!pmd_trans_huge(*pmd))) {
>>  		spin_unlock(ptl);
>>  		return follow_page_pte(vma, address, pmd, flags);
>> @@ -341,7 +359,7 @@ static int get_gate_page(struct mm_struct *mm, uns=
igned long address,
>>  	pud =3D pud_offset(pgd, address);
>>  	BUG_ON(pud_none(*pud));
>>  	pmd =3D pmd_offset(pud, address);
>> -	if (pmd_none(*pmd))
>> +	if (!pmd_present(*pmd))
>>  		return -EFAULT;
>>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>>  	pte =3D pte_offset_map(pmd, address);
>> @@ -1369,7 +1387,7 @@ static int gup_pmd_range(pud_t pud, unsigned lon=
g addr, unsigned long end,
>>  		pmd_t pmd =3D READ_ONCE(*pmdp);
>> =20
>>  		next =3D pmd_addr_end(addr, end);
>> -		if (pmd_none(pmd))
>> +		if (!pmd_present(pmd))
>>  			return 0;
>> =20
>>  		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index a9c2a0ef5b9b..3f18452f3eb1 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -898,6 +898,21 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struc=
t mm_struct *src_mm,
>> =20
>>  	ret =3D -EAGAIN;
>>  	pmd =3D *src_pmd;
>> +
>> +	if (unlikely(is_pmd_migration_entry(pmd))) {
>=20
> Shouldn't you first check that the pmd is not present?

is_pmd_migration_entry() checks !pmd_present().

in linux/swapops.h, is_pmd_migration_entry is defined as:

static inline int is_pmd_migration_entry(pmd_t pmd)
{
    return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd))=
;
}


>=20
>> +		swp_entry_t entry =3D pmd_to_swp_entry(pmd);
>> +
>> +		if (is_write_migration_entry(entry)) {
>> +			make_migration_entry_read(&entry);
>> +			pmd =3D swp_entry_to_pmd(entry);
>> +			set_pmd_at(src_mm, addr, src_pmd, pmd);
>> +		}
>> +		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
>> +		ret =3D 0;
>> +		goto out_unlock;
>> +	}
>> +	WARN_ONCE(!pmd_present(pmd), "Uknown non-present format on pmd.\n");=

>=20
> Typo.

Got it.

>=20
>> +
>>  	if (unlikely(!pmd_trans_huge(pmd))) {
>>  		pte_free(dst_mm, pgtable);
>>  		goto out_unlock;
>> @@ -1204,6 +1219,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pm=
d_t orig_pmd)
>>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>>  		goto out_unlock;j
>> =20
>> +	if (unlikely(!pmd_present(orig_pmd)))
>> +		goto out_unlock;
>> +
>>  	page =3D pmd_page(orig_pmd);
>>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>>  	/*
>> @@ -1338,7 +1356,15 @@ struct page *follow_trans_huge_pmd(struct vm_ar=
ea_struct *vma,
>>  	if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>>  		goto out;
>> =20
>> -	page =3D pmd_page(*pmd);
>> +	if (is_pmd_migration_entry(*pmd)) {
>=20
> Again, I don't think it's it's safe to check if pmd is migration entry
> before checking if it's present.
>=20
>> +		swp_entry_t entry;
>> +
>> +		entry =3D pmd_to_swp_entry(*pmd);
>> +		page =3D pfn_to_page(swp_offset(entry));
>> +		if (!is_migration_entry(entry))
>> +			goto out;
>=20
> I don't understand how it suppose to work.
> You take swp_offset() of entry before checking if it's migration entry.=

> What's going on?

This chunk of change inside follow_trans_huge_pmd() is not needed.
Because two callers, smaps_pmd_entry() and follow_page_mask(), guarantee
that the pmd points to a present entry.

I will drop this chunk in the next version.

>=20
>> +	} else
>> +		page =3D pmd_page(*pmd);
>>  	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);=

>>  	if (flags & FOLL_TOUCH)
>>  		touch_pmd(vma, addr, pmd);
>> @@ -1534,6 +1560,9 @@ bool madvise_free_huge_pmd(struct mmu_gather *tl=
b, struct vm_area_struct *vma,
>>  	if (is_huge_zero_pmd(orig_pmd))
>>  		goto out;
>> =20
>> +	if (unlikely(!pmd_present(orig_pmd)))
>> +		goto out;
>> +
>>  	page =3D pmd_page(orig_pmd);
>>  	/*
>>  	 * If other processes are mapping this page, we couldn't discard
>> @@ -1766,6 +1795,20 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
>>  	if (prot_numa && pmd_protnone(*pmd))
>>  		goto unlock;
>> =20
>> +	if (is_pmd_migration_entry(*pmd)) {
>> +		swp_entry_t entry =3D pmd_to_swp_entry(*pmd);
>> +
>> +		if (is_write_migration_entry(entry)) {
>> +			pmd_t newpmd;
>> +
>> +			make_migration_entry_read(&entry);
>> +			newpmd =3D swp_entry_to_pmd(entry);
>> +			set_pmd_at(mm, addr, pmd, newpmd);
>> +		}
>> +		goto unlock;
>> +	} else if (!pmd_present(*pmd))
>> +		WARN_ONCE(1, "Uknown non-present format on pmd.\n");
>=20
> Another typo.

Got it.

Thanks for all your comments.

--=20
Best Regards,
Yan Zi


--------------enig987999214556999BA2161050
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY1US2AAoJEEGLLxGcTqbMooMH+wYgd5Lm3zvaMZn4S7JJK9KD
WcvaNB3k7OPz/S4X3Tcrp1pLuReCfmt57EZ8Hz2DjT9TnAT7u0OYRQR9KR2xD1ER
iJ01X8+lXX1bI1zSvdq6aqLpRj11oCHvtuSp1DXym6QEVH5mJMtdHRvYSuXjg4Cj
Nq3FwWBXMzt3Ixr4uib2hHPDhwvSEkerQ3usYAJeonvALnTNCWFCa8oabBcmQVBA
ltWF6WqKEqb6vu8XaT2RhElqJ3pnWotm0Vy50sEiU+uKet8I/o52uZvwYM7tafGc
05OxWjHBNo0WzYmo51ag9IGqjXPQb7iRKawpoh55wmLh0+Et5nui1hX+d4qMOM4=
=SKiM
-----END PGP SIGNATURE-----

--------------enig987999214556999BA2161050--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
