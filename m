Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4F966B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 11:30:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e13so279078itc.12
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 08:30:33 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0095.outbound.protection.outlook.com. [104.47.33.95])
        by mx.google.com with ESMTPS id q64si2999812ioi.231.2017.03.24.08.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Mar 2017 08:30:32 -0700 (PDT)
Message-ID: <58D53B8A.9040508@cs.rutgers.edu>
Date: Fri, 24 Mar 2017 10:30:18 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/11] mm: thp: enable thp migration in generic path
References: <20170313154507.3647-1-zi.yan@sent.com> <20170313154507.3647-6-zi.yan@sent.com> <20170324142829.qkqymugqp4ge33ky@node.shutemov.name>
In-Reply-To: <20170324142829.qkqymugqp4ge33ky@node.shutemov.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enig5AA7F2B0050CD50B25544333"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

--------------enig5AA7F2B0050CD50B25544333
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Kirill,

Kirill A. Shutemov wrote:
> On Mon, Mar 13, 2017 at 11:45:01AM -0400, Zi Yan wrote:
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
>> ChangeLog v3 -> v4:
>> - factor out the code of removing pte pgtable page in zap_huge_pmd()
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>=20
> See few questions below.
>=20
> It would be nice to split it into few patches. Probably three or four.

This patch was two separate ones in v2:
1. introduce remove_pmd_migration_entry(), set_migration_pmd() and other
auxiliary functions,
2. enable THP migration in the migration path.

But the first one of these two patches would be dead code, since no one
else uses it. Michal also suggested merging two patches into one when he
reviewed v2.

If you have any suggestion, I am OK to split this patch and make it
smaller.

<snip>

>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index cda4c2778d04..0bbad6dcf95a 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -211,6 +211,12 @@ static int remove_migration_pte(struct page *page=
, struct vm_area_struct *vma,
>>  		new =3D page - pvmw.page->index +
>>  			linear_page_index(vma, pvmw.address);
>> =20
>> +		/* PMD-mapped THP migration entry */
>> +		if (!PageHuge(page) && PageTransCompound(page)) {
>> +			remove_migration_pmd(&pvmw, new);
>> +			continue;
>> +		}
>> +
>=20
> Any reason not to share PTE handling of non-THP with THP?

You mean PTE-mapped THPs? I was mostly reuse Naoya's patches. But at
first look, it seems PTE-mapped THP handling code is the same as
existing PTE handling code.

This part of code can be changed to:

+		/* PMD-mapped THP migration entry */
+		if (!pvmw.pte && pvmw.page) {
+                       VM_BUG_ON_PAGE(!PageTransCompound(page), page);
+			remove_migration_pmd(&pvmw, new);
+			continue;
+		}
+

>=20
>>  		get_page(new);
>>  		pte =3D pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
>>  		if (pte_swp_soft_dirty(*pvmw.pte))

<snip>

>> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
>> index 4ed5908c65b0..9d550a8a0c71 100644
>> --- a/mm/pgtable-generic.c
>> +++ b/mm/pgtable-generic.c
>> @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct =
*vma, unsigned long address,
>>  {
>>  	pmd_t pmd;
>>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>> -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
>> +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
>> +		  !pmd_devmap(*pmdp));
>=20
> How does this? _flush doesn't make sense for !present.

Right. It should be:

-	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
+	VM_BUG_ON((pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
+		  !pmd_devmap(*pmdp)) || !pmd_present(*pmdp));


>=20
>>  	pmd =3D pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
>>  	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>>  	return pmd;
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 555cc7ebacf6..2c65abbd7a0e 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1298,6 +1298,7 @@ static int try_to_unmap_one(struct page *page, s=
truct vm_area_struct *vma,
>>  	int ret =3D SWAP_AGAIN;
>>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
>> =20
>> +
>>  	/* munlock has nothing to gain from examining un-locked vmas */
>>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>>  		return SWAP_AGAIN;
>> @@ -1308,6 +1309,14 @@ static int try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
>>  	}
>> =20
>>  	while (page_vma_mapped_walk(&pvmw)) {
>> +		/* THP migration */
>> +		if (flags & TTU_MIGRATION) {
>> +			if (!PageHuge(page) && PageTransCompound(page)) {
>> +				set_pmd_migration_entry(&pvmw, page);
>=20
> Again, it would be nice share PTE handling. It should be rather similar=
,
> no?

At first look, it should work. I will change it. If it works, it will be
included in the next version.

This can also shrink the patch size.

Thanks.


--=20
Best Regards,
Yan Zi


--------------enig5AA7F2B0050CD50B25544333
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJY1TuLAAoJEEGLLxGcTqbM8kwH/jzQHYz1mobmrhjihLiD6wbg
bxTHBa7LSQ4YDgmsketcKpMbD/eDyh0wGBUQznsjQzIVNwpI229x4/tdfopdiDpN
lA3IDwMBIVck/8Bd6jEwV6Wu6cMV6UT6jDyoKcsgqNcWDHEOMu3s2un+tSCLtRJ6
qIYhqkfLzK4tju9bf3Myc5PolM0mrcnBLSAmZU2bCzrFl4st5WrYjy5pKXDzBKWl
KIl7Bi7hf8cUC3/L14cuMsd+PxZCXkghJLCT6hUrJwpFX+/KFQ8VDxDIVoM4x83R
WYe+w8cyJBPWC9r3Oc8VWQam+5HjNCWm52XLRZg763KtsewIuc+ask0Yc4TGlqM=
=fiAz
-----END PGP SIGNATURE-----

--------------enig5AA7F2B0050CD50B25544333--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
