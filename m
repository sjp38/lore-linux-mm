Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7072A6B03A1
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:18:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j201so59054607oih.17
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:18:06 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0128.outbound.protection.outlook.com. [104.47.42.128])
        by mx.google.com with ESMTPS id y70si317009oia.202.2017.04.21.08.18.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 08:18:05 -0700 (PDT)
Message-ID: <58FA22A1.105@cs.rutgers.edu>
Date: Fri, 21 Apr 2017 10:17:53 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/11] mm: thp: check pmd migration entry in common
 path
References: <20170420204752.79703-1-zi.yan@sent.com> <20170420204752.79703-7-zi.yan@sent.com> <edb7c113-4c25-4e5b-9182-594c002cbf93@linux.vnet.ibm.com>
In-Reply-To: <edb7c113-4c25-4e5b-9182-594c002cbf93@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig595100625FACE9F209DE01E4"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig595100625FACE9F209DE01E4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Anshuman Khandual wrote:
> On 04/21/2017 02:17 AM, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
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
>> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() retur=
n
>>   true on pmd_migration_entry, so that migration entries are not
>>   treated as pmd page table entries.
>>
>> ChangeLog v4 -> v5:
>> - add explanation in pmd_none_or_trans_huge_or_clear_bad() to state
>>   the equivalence of !pmd_present() and is_pmd_migration_entry()
>> - fix migration entry wait deadlock code (from v1) in follow_page_mask=
()
>> - remove unnecessary code (from v1) in follow_trans_huge_pmd()
>> - use is_swap_pmd() instead of !pmd_present() for pmd migration entry,=

>>   so it will not be confused with pmd_none()
>> - change author information
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  arch/x86/mm/gup.c             |  7 +++--
>>  fs/proc/task_mmu.c            | 30 +++++++++++++--------
>>  include/asm-generic/pgtable.h | 17 +++++++++++-
>>  include/linux/huge_mm.h       | 14 ++++++++--
>>  mm/gup.c                      | 22 ++++++++++++++--
>>  mm/huge_memory.c              | 61 ++++++++++++++++++++++++++++++++++=
++++-----
>>  mm/memcontrol.c               |  5 ++++
>>  mm/memory.c                   | 12 +++++++--
>>  mm/mprotect.c                 |  4 +--
>>  mm/mremap.c                   |  2 +-
>>  10 files changed, 145 insertions(+), 29 deletions(-)
>>
>> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
>> index 456dfdfd2249..096bbcc801e6 100644
>> --- a/arch/x86/mm/gup.c
>> +++ b/arch/x86/mm/gup.c
>> @@ -9,6 +9,7 @@
>>  #include <linux/vmstat.h>
>>  #include <linux/highmem.h>
>>  #include <linux/swap.h>
>> +#include <linux/swapops.h>
>>  #include <linux/memremap.h>
>> =20
>>  #include <asm/mmu_context.h>
>> @@ -243,9 +244,11 @@ static int gup_pmd_range(pud_t pud, unsigned long=
 addr, unsigned long end,
>>  		pmd_t pmd =3D *pmdp;
>> =20
>>  		next =3D pmd_addr_end(addr, end);
>> -		if (pmd_none(pmd))
>> +		if (!pmd_present(pmd)) {
>> +			VM_BUG_ON(is_swap_pmd(pmd) && IS_ENABLED(CONFIG_MIGRATION) &&
>> +					  !is_pmd_migration_entry(pmd));
>>  			return 0;
>> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
>> +		} else if (unlikely(pmd_large(pmd))) {
>>  			/*
>>  			 * NUMA hinting faults need to be handled in the GUP
>>  			 * slowpath for accounting purposes and so that they
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 5c8359704601..57489dcd71c4 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -600,7 +600,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned lo=
ng addr, unsigned long end,
>> =20
>>  	ptl =3D pmd_trans_huge_lock(pmd, vma);
>>  	if (ptl) {
>> -		smaps_pmd_entry(pmd, addr, walk);
>> +		if (pmd_present(*pmd))
>> +			smaps_pmd_entry(pmd, addr, walk);
>>  		spin_unlock(ptl);
>>  		return 0;
>>  	}
>> @@ -942,6 +943,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsign=
ed long addr,
>>  			goto out;
>>  		}
>> =20
>> +		if (!pmd_present(*pmd))
>> +			goto out;
>> +
>=20
> These pmd_present() checks should have been done irrespective of the
> presence of new PMD migration entries. Please separate them out in a
> different clean up patch.

Not really. The introduction of PMD migration entries makes
pmd_trans_huge_lock() return a lock when PMD is a swap entry (See
changes on pmd_trans_huge_lock() in this patch). This was not the case
before, where pmd_trans_huge_lock() returned NULL if PMD entry was
pmd_none() and both two chunks were not reachable.

Maybe I should use is_swap_pmd() to clarify the confusion.

<snip>

>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 7406d88445bf..3479e9caf2fa 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -912,6 +912,22 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struc=
t mm_struct *src_mm,
>> =20
>>  	ret =3D -EAGAIN;
>>  	pmd =3D *src_pmd;
>> +
>> +	if (unlikely(is_swap_pmd(pmd))) {
>> +		swp_entry_t entry =3D pmd_to_swp_entry(pmd);
>> +
>> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
>> +				  !is_pmd_migration_entry(pmd));
>> +		if (is_write_migration_entry(entry)) {
>> +			make_migration_entry_read(&entry);
>=20
> We create a read migration entry after detecting a write ?

When copying page tables, COW mappings require pages in both parent and
child to be set to read. In copy_huge_pmd(), only anonymous VMAs are
copied and the other VMAs will be refilled on fault. Writable anonymous
VMAs have VM_MAYWRITE set but not VM_SHARED and this matches
is_cow_mapping(). So all mappings copied in this function are COW mapping=
s.

>=20
>> +			pmd =3D swp_entry_to_pmd(entry);
>> +			set_pmd_at(src_mm, addr, src_pmd, pmd);
>> +		}
>> +		set_pmd_at(dst_mm, addr, dst_pmd, pmd);
>> +		ret =3D 0;
>> +		goto out_unlock;
>> +	}
>> +
>>  	if (unlikely(!pmd_trans_huge(pmd))) {
>>  		pte_free(dst_mm, pgtable);
>>  		goto out_unlock;
>> @@ -1218,6 +1234,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pm=
d_t orig_pmd)
>>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>>  		goto out_unlock;
>> =20
>> +	if (unlikely(!pmd_present(orig_pmd)))
>> +		goto out_unlock;
>> +
>>  	page =3D pmd_page(orig_pmd);
>>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>>  	/*
>> @@ -1548,6 +1567,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *t=
lb, struct vm_area_struct *vma,
>>  	if (is_huge_zero_pmd(orig_pmd))
>>  		goto out;
>> =20
>> +	if (unlikely(!pmd_present(orig_pmd))) {
>> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
>> +				  !is_pmd_migration_entry(orig_pmd));
>> +		goto out;
>> +	}
>> +
>>  	page =3D pmd_page(orig_pmd);
>>  	/*
>>  	 * If other processes are mapping this page, we couldn't discard
>> @@ -1758,6 +1783,21 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
>>  	preserve_write =3D prot_numa && pmd_write(*pmd);
>>  	ret =3D 1;
>> =20
>> +	if (is_swap_pmd(*pmd)) {
>> +		swp_entry_t entry =3D pmd_to_swp_entry(*pmd);
>> +
>> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
>> +				  !is_pmd_migration_entry(*pmd));
>> +		if (is_write_migration_entry(entry)) {
>> +			pmd_t newpmd;
>> +
>> +			make_migration_entry_read(&entry);
>=20
> Same here or maybe I am missing something.


I follow the same pattern in change_pte_range() (mm/mprotect.c). The
comment there says "A protection check is difficult so just be safe and
disable write".

--=20
Best Regards,
Yan Zi


--------------enig595100625FACE9F209DE01E4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY+iKhAAoJEEGLLxGcTqbMWKEH/iKaVELdk3qnEdda35UMMiyA
QQqPq6qwdxLe6Ti1LeEMew0gEzbkYhvtF8bS92ZDqpLbOVLBPNZc/Rta5Og3dWgB
UnYwO1ytg2hghRm/lj7B1tVht/x+x74XZxDA9ohySwX5I/iWUOjbVz7ieCnpZtmj
hXNxl1ldWdGxfTp4ptOpqXCkvBBQsgM+FkKsDnw1BKsHYkgoLSPX5kW3VnCqHquh
z8jydKCw1NBryq63izEshctQcQcnnUPYj1kQYGrweOpzQrZZY1HTR6KdYHP1sjkB
iMfzXVkGNAuGGsYEStC9ldfZdEFC4WMiwv+W9jY30K6yBp2+hHiZ3G3S4gdnS8I=
=m0h0
-----END PGP SIGNATURE-----

--------------enig595100625FACE9F209DE01E4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
