Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4BAE440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 14:29:10 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g53so40783926qtc.6
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 11:29:10 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l41si8440769qtf.200.2017.07.14.11.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 11:29:09 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v8 06/10] mm: thp: check pmd migration entry in common
 path
Date: Fri, 14 Jul 2017 14:29:07 -0400
Message-ID: <3144A36B-4C90-4BEF-B4A7-3658D37DE618@sent.com>
In-Reply-To: <20170714092943.GA14125@hori1.linux.bs1.fc.nec.co.jp>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-7-zi.yan@sent.com>
 <20170714092943.GA14125@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_546E1D85-A473-489E-A5D6-0DF3E5FC933B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_546E1D85-A473-489E-A5D6-0DF3E5FC933B_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 14 Jul 2017, at 5:29, Naoya Horiguchi wrote:

> On Sat, Jul 01, 2017 at 09:40:04AM -0400, Zi Yan wrote:
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
>> ChangeLog v5 -> v7
>> - use macro to disable the code when thp migration is not enabled
>>
>> ChangeLog v7 -> v8
>> - remove not used code in do_huge_pmd_wp_page()
>> - copy the comment from change_pte_range() on downgrading
>>   write migration entry to read to change_huge_pmd()
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  arch/x86/mm/gup.c             |  7 +++--
>>  fs/proc/task_mmu.c            | 33 ++++++++++++++-------
>>  include/asm-generic/pgtable.h | 17 ++++++++++-
>>  include/linux/huge_mm.h       | 14 +++++++--
>>  mm/gup.c                      | 22 ++++++++++++--
>>  mm/huge_memory.c              | 67 ++++++++++++++++++++++++++++++++++=
+++++----
>>  mm/memcontrol.c               |  5 ++++
>>  mm/memory.c                   | 12 ++++++--
>>  mm/mprotect.c                 |  4 +--
>>  mm/mremap.c                   |  2 +-
>>  10 files changed, 154 insertions(+), 29 deletions(-)
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
>>
>>  #include <asm/mmu_context.h>
>> @@ -243,9 +244,11 @@ static int gup_pmd_range(pud_t pud, unsigned long=
 addr, unsigned long end,
>>  		pmd_t pmd =3D *pmdp;
>>
>>  		next =3D pmd_addr_end(addr, end);
>> -		if (pmd_none(pmd))
>> +		if (!pmd_present(pmd)) {
>> +			VM_BUG_ON(is_swap_pmd(pmd) && IS_ENABLED(CONFIG_MIGRATION) &&
>> +					  !is_pmd_migration_entry(pmd));
>
> This VM_BUG_ON() triggers when gup is called on hugetlb hwpoison entry.=

> I think that in such case kernel falls into the gup slow path, and
> a page fault in follow_hugetlb_page() can properly report the error to
> affected processes, so no need to alarm with BUG_ON.
>
> Could you make this VM_BUG_ON more specific, or just remove it?

I will remove it, since adding code to detect hugetlb hwpoison entry
to existing VM_BUG_ON() will be quite messy.

Thanks for pointing this out.

--
Best Regards
Yan Zi

--=_MailMate_546E1D85-A473-489E-A5D6-0DF3E5FC933B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZaQ1zAAoJEEGLLxGcTqbMk8cH/0C8SZ75UHrk0e8/ETXdRoVu
Ro3WvxjQFNUjdPE7Z7AgrUWLLvVTe+RekVV3CuNRHKXs0rl7Zxw2oATlrR/YUTQw
E8AjB092K1buEOOvec0eHmiWffWacaTzwTGLcgrr6Z1fJXYAcLh67xMq0i9vkyaM
TiHd5RVjvMzYX8ntDJqri+7rz/DqrUmqJ0EUSQxLwkVIbBFBQwv07tbtoIJrM6XP
7qZkY7dLtJps3i//wVzRd5VbH3jBujZabOjPl4+3Qz0fFeVUB19AByYuKkQC0szy
QDT0D7PeuiFsAPvi1gSACGQs0GVeyK+vVXGHxxcuUJIgQ2hJh/SPBbpVakDMAeg=
=ttWN
-----END PGP SIGNATURE-----

--=_MailMate_546E1D85-A473-489E-A5D6-0DF3E5FC933B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
