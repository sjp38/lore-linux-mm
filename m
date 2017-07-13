Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1737440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:28:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s4so54815015pgr.3
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 04:28:33 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0099.outbound.protection.outlook.com. [104.47.36.99])
        by mx.google.com with ESMTPS id a8si4348462plt.556.2017.07.13.04.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jul 2017 04:28:32 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v8 05/10] mm: thp: enable thp migration in generic path
Date: Thu, 13 Jul 2017 07:28:24 -0400
Message-ID: <F7B0F5C1-F8ED-4029-87ED-F1757975E767@cs.rutgers.edu>
In-Reply-To: <20170713093040.GA24851@hori1.linux.bs1.fc.nec.co.jp>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-6-zi.yan@sent.com>
 <20170711064736.GB22052@hori1.linux.bs1.fc.nec.co.jp>
 <F7626C3B-4F03-4144-B5DF-23CB45E4373D@cs.rutgers.edu>
 <20170713093040.GA24851@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_773430CB-F76A-4A3A-A9BD-72F39805FF95_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_773430CB-F76A-4A3A-A9BD-72F39805FF95_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 13 Jul 2017, at 5:30, Naoya Horiguchi wrote:

> On Tue, Jul 11, 2017 at 10:00:30AM -0400, Zi Yan wrote:
>> On 11 Jul 2017, at 2:47, Naoya Horiguchi wrote:
>>
>>> On Sat, Jul 01, 2017 at 09:40:03AM -0400, Zi Yan wrote:
>>>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>>>
>>>> This patch adds thp migration's core code, including conversions
>>>> between a PMD entry and a swap entry, setting PMD migration entry,
>>>> removing PMD migration entry, and waiting on PMD migration entries.
>>>>
>>>> This patch makes it possible to support thp migration.
>>>> If you fail to allocate a destination page as a thp, you just split
>>>> the source thp as we do now, and then enter the normal page migratio=
n.
>>>> If you succeed to allocate destination thp, you enter thp migration.=

>>>> Subsequent patches actually enable thp migration for each caller of
>>>> page migration by allowing its get_new_page() callback to
>>>> allocate thps.
>>>>
>>>> ChangeLog v1 -> v2:
>>>> - support pte-mapped thp, doubly-mapped thp
>>>>
>>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>>
>>>> ChangeLog v2 -> v3:
>>>> - use page_vma_mapped_walk()
>>>> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear() i=
n
>>>>   set_pmd_migration_entry()
>>>>
>>>> ChangeLog v3 -> v4:
>>>> - factor out the code of removing pte pgtable page in zap_huge_pmd()=

>>>>
>>>> ChangeLog v4 -> v5:
>>>> - remove unnecessary PTE-mapped THP code in remove_migration_pmd()
>>>>   and set_pmd_migration_entry()
>>>> - restructure the code in zap_huge_pmd() to avoid factoring out
>>>>   the pte pgtable page code
>>>> - in zap_huge_pmd(), check that PMD swap entries are migration entri=
es
>>>> - change author information
>>>>
>>>> ChangeLog v5 -> v7
>>>> - use macro to disable the code when thp migration is not enabled
>>>>
>>>> ChangeLog v7 -> v8
>>>> - use IS_ENABLED instead of macro to make code look clean in
>>>>   zap_huge_pmd() and page_vma_mapped_walk()
>>>> - remove BUILD_BUG() in pmd_to_swp_entry() and swp_entry_to_pmd() to=

>>>>   avoid compilation error
>>>> - rename variable 'migration' to 'flush_needed' and invert the logic=
 in
>>>>   zap_huge_pmd() to make code more descriptive
>>>> - use pmdp_invalidate() in set_pmd_migration_entry() to avoid race
>>>>   with MADV_DONTNEED
>>>> - remove unnecessary tlb flush in remove_migration_pmd()
>>>> - add the missing migration flag check in page_vma_mapped_walk()
>>>>
>>>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> ---
>>>>  arch/x86/include/asm/pgtable_64.h |  2 +
>>>>  include/linux/swapops.h           | 67 ++++++++++++++++++++++++++++=
++-
>>>>  mm/huge_memory.c                  | 84 ++++++++++++++++++++++++++++=
++++++++---
>>>>  mm/migrate.c                      | 32 ++++++++++++++-
>>>>  mm/page_vma_mapped.c              | 18 +++++++--
>>>>  mm/pgtable-generic.c              |  3 +-
>>>>  mm/rmap.c                         | 13 ++++++
>>>>  7 files changed, 207 insertions(+), 12 deletions(-)
>>>>
>>> ...
>>>
>>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>>> index 91948fbbb0bb..b28f633cd569 100644
>>>> --- a/mm/rmap.c
>>>> +++ b/mm/rmap.c
>>>> @@ -1302,6 +1302,7 @@ static bool try_to_unmap_one(struct page *page=
, struct vm_area_struct *vma,
>>>>  	bool ret =3D true;
>>>>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
>>>>
>>>> +
>>>>  	/* munlock has nothing to gain from examining un-locked vmas */
>>>>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>>>>  		return true;
>>>> @@ -1312,6 +1313,18 @@ static bool try_to_unmap_one(struct page *pag=
e, struct vm_area_struct *vma,
>>>>  	}
>>>>
>>>>  	while (page_vma_mapped_walk(&pvmw)) {
>>>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>>>> +		/* PMD-mapped THP migration entry */
>>>> +		if (flags & TTU_MIGRATION) {
>>>
>>> My testing based on mmotm-2017-07-06-16-18 showed that migrating shme=
m thp
>>> caused kernel crash. I don't think this is critical because that case=
 is
>>> just not-prepared yet. So in order to avoid the crash, please add
>>> PageAnon(page) check here. This makes shmem thp migration just fail.
>>>
>>> +			if (!PageAnon(page))
>>> +				continue;
>>>
>>
>> Thanks for your testing. I will add this check in my next version.
>
> Sorry, the code I'm suggesting above doesn't work because it makes norm=
al
> pagecache migration fail.  This check should come after making sure tha=
t
> pvmw.pte is NULL.

Right. I think the two ifs are confusing. Replacing the chunk with:

if (!pvmw.pte && (flags & TTU_MIGRATION)) {
    VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page),
            page);

    if (!PageAnon(page))
        continue;

    set_pmd_migration_entry(&pvmw, page);
    continue;
}

would be better.

BTW, is your page migration test suite available online? If so, I could u=
se
it to test my code.

Thanks.



=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_773430CB-F76A-4A3A-A9BD-72F39805FF95_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZZ1lYAAoJEEGLLxGcTqbMATcH/jlryvtdD8CdWHv0Nn+mjFZF
OmFqpxbSJ9yCHVPNC/YTd79FI25lF/F7YcSkl5U2cXL2JSkJmeqcDink1dEs1mP6
64wnONqDtRqJWCMEBrdnC9gftKZNhjyV80O3OdRl5oG0LPRk3pi/1fwuSCE1COq9
1u8r1BL84aK0d59XuvRTmTJEbmZ6naI3pk3Zfq6k5UAcyXDt9jgisph6xvqKPhq7
QQIx3scYTS3HTcfbDwi0C844jH8u9bIIlBnAgKc6evV8FN7z8r6wZif32+4vZit7
Cy5fD0jaENV/Q8ly+edWHMEWGh4Wo1V+hj73ozwm+PKIhA322kd1c5p+wPINzF4=
=gCIF
-----END PGP SIGNATURE-----

--=_MailMate_773430CB-F76A-4A3A-A9BD-72F39805FF95_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
