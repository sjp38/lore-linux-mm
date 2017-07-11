Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97BD06B0506
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:00:39 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i21so34817oib.0
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:00:39 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0109.outbound.protection.outlook.com. [104.47.34.109])
        by mx.google.com with ESMTPS id q128si15150oic.246.2017.07.11.07.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 07:00:36 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v8 05/10] mm: thp: enable thp migration in generic path
Date: Tue, 11 Jul 2017 10:00:30 -0400
Message-ID: <F7626C3B-4F03-4144-B5DF-23CB45E4373D@cs.rutgers.edu>
In-Reply-To: <20170711064736.GB22052@hori1.linux.bs1.fc.nec.co.jp>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-6-zi.yan@sent.com>
 <20170711064736.GB22052@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_8804FA40-CC25-4A55-BF3B-6B4A404F8436_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_8804FA40-CC25-4A55-BF3B-6B4A404F8436_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 11 Jul 2017, at 2:47, Naoya Horiguchi wrote:

> On Sat, Jul 01, 2017 at 09:40:03AM -0400, Zi Yan wrote:
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
>> ChangeLog v7 -> v8
>> - use IS_ENABLED instead of macro to make code look clean in
>>   zap_huge_pmd() and page_vma_mapped_walk()
>> - remove BUILD_BUG() in pmd_to_swp_entry() and swp_entry_to_pmd() to
>>   avoid compilation error
>> - rename variable 'migration' to 'flush_needed' and invert the logic i=
n
>>   zap_huge_pmd() to make code more descriptive
>> - use pmdp_invalidate() in set_pmd_migration_entry() to avoid race
>>   with MADV_DONTNEED
>> - remove unnecessary tlb flush in remove_migration_pmd()
>> - add the missing migration flag check in page_vma_mapped_walk()
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  arch/x86/include/asm/pgtable_64.h |  2 +
>>  include/linux/swapops.h           | 67 ++++++++++++++++++++++++++++++=
-
>>  mm/huge_memory.c                  | 84 ++++++++++++++++++++++++++++++=
++++++---
>>  mm/migrate.c                      | 32 ++++++++++++++-
>>  mm/page_vma_mapped.c              | 18 +++++++--
>>  mm/pgtable-generic.c              |  3 +-
>>  mm/rmap.c                         | 13 ++++++
>>  7 files changed, 207 insertions(+), 12 deletions(-)
>>
> ...
>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 91948fbbb0bb..b28f633cd569 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1302,6 +1302,7 @@ static bool try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
>>  	bool ret =3D true;
>>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
>>
>> +
>>  	/* munlock has nothing to gain from examining un-locked vmas */
>>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>>  		return true;
>> @@ -1312,6 +1313,18 @@ static bool try_to_unmap_one(struct page *page,=
 struct vm_area_struct *vma,
>>  	}
>>
>>  	while (page_vma_mapped_walk(&pvmw)) {
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +		/* PMD-mapped THP migration entry */
>> +		if (flags & TTU_MIGRATION) {
>
> My testing based on mmotm-2017-07-06-16-18 showed that migrating shmem =
thp
> caused kernel crash. I don't think this is critical because that case i=
s
> just not-prepared yet. So in order to avoid the crash, please add
> PageAnon(page) check here. This makes shmem thp migration just fail.
>
> +			if (!PageAnon(page))
> +				continue;
>

Thanks for your testing. I will add this check in my next version.


>> +			if (!pvmw.pte && page) {
>
> Just from curiosity, do we really need this page check?
> try_to_unmap() always passes down the parameter 'page' to try_to_unmap_=
one()
> via rmap_walk_* family, so I think we can assume page is always non-NUL=
L.

You are right. Checking page is not necessary here. I will remove it in m=
y
next version.



--
Best Regards
Yan Zi

--=_MailMate_8804FA40-CC25-4A55-BF3B-6B4A404F8436_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZZNn+AAoJEEGLLxGcTqbMMv0IAJAb91WfGug4UFMxLmIs5rCV
Wkq5adDVyRLYJ1MGqip/AfkPkT0aQjQD3xW40JxW1z3FrsJ6X5HZksh9kLCUvu9W
OTjJ0Fj94n67sP7pt1gYUwTLZ3Rga5v9fBc7g0kKa58g2BPdaXZCLpqjV1X8mIW9
X5bAVPvoDZ903850ncykP3u08PKvtf4MEFtixK/TUe8XO+MDACR14g5CfPjYYoI0
DrhA9VDB7o2Eg/0GqNHDN36/Vs5e/mOOQ9UkuaV9ZQrKCMLhi1P9jVVEwBFBsZmi
2I03ke2KsLneK1dXrw41NndD4jvsmazCIpGP25/6KuCCI0mQ7MRp5D1ztplJBzc=
=eW63
-----END PGP SIGNATURE-----

--=_MailMate_8804FA40-CC25-4A55-BF3B-6B4A404F8436_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
