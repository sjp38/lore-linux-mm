Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBB4D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:12:31 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w185so2478111ita.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:12:31 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0097.outbound.protection.outlook.com. [104.47.36.97])
        by mx.google.com with ESMTPS id s27si5155520ioi.18.2017.02.23.08.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 08:12:27 -0800 (PST)
Message-ID: <58AF09D9.3050401@cs.rutgers.edu>
Date: Thu, 23 Feb 2017 10:12:09 -0600
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/14] mm: page migration enhancement for thp
References: <20170205161252.85004-1-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="------------enigE8B6B278229F6B3388EF32F3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, akpm@linux-foundation.org

--------------enigE8B6B278229F6B3388EF32F3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Ping.

Just want to get comments on THP migration part (Patch 4-14). If they
look OK, I can rebase THP migration part on mmotm-2017-02-22-16-28 and
send them out for merging.

Thanks.

Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>=20
> Hi all,
>=20
> The patches are rebased on mmotm-2017-02-01-15-35 with feedbacks from=20
> Naoya Horiguchi's v2 patches.
>=20
> I fix a bug in zap_pmd_range() and include the fixes in Patches 1-3.
> The racy check in zap_pmd_range() can miss pmd_protnone and pmd_migrati=
on_entry,
> which leads to PTE page table not freed.
>=20
> In Patch 4, I move _PAGE_SWP_SOFT_DIRTY to bit 1. Because bit 6 (used i=
n v2)
> can be set by some CPUs by mistake and the new swap entry format does n=
ot use
> bit 1-4.
>=20
> I also adjust two core migration functions, set_pmd_migration_entry() a=
nd
> remove_migration_pmd(), to use Kirill A. Shutemov's page_vma_mapped_wal=
k()
> function. Patch 8 needs Kirill's comments, since I also add changes
> to his page_vma_mapped_walk() function with pmd_migration_entry handlin=
g.
>=20
> In Patch 8, I replace pmdp_huge_get_and_clear() with pmdp_huge_clear_fl=
ush()
> in set_pmd_migration_entry() to avoid data corruption after page migrat=
ion.
>=20
> In Patch 9, I include is_pmd_migration_entry() in pmd_none_or_trans_hug=
e_or_clear_bad().
> Otherwise, a pmd_migration_entry is treated as pmd_bad and cleared, whi=
ch
> leads to deposited PTE page table not freed.
>=20
> I personally use this patchset with my customized kernel to test freque=
nt
> page migrations by replacing page reclaim with page migration.
> The bugs fixed in Patches 1-3 and 8 was discovered while I am testing m=
y kernel.
> I did a 16-hour stress test that has ~7 billion total page migrations.
> No error or data corruption was found.=20
>=20
>=20
> General description=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> This patchset enhances page migration functionality to handle thp migra=
tion
> for various page migration's callers:
>  - mbind(2)
>  - move_pages(2)
>  - migrate_pages(2)
>  - cgroup/cpuset migration
>  - memory hotremove
>  - soft offline
>=20
> The main benefit is that we can avoid unnecessary thp splits, which hel=
ps us
> avoid performance decrease when your applications handles NUMA optimiza=
tion on
> their own.
>=20
> The implementation is similar to that of normal page migration, the key=
 point
> is that we modify a pmd to a pmd migration entry in swap-entry like for=
mat.
>=20
>=20
> Any comments or advices are welcomed.
>=20
> Best Regards,
> Yan Zi
>=20
> Naoya Horiguchi (11):
>   mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
>   mm: mempolicy: add queue_pages_node_check()
>   mm: thp: introduce separate TTU flag for thp freezing
>   mm: thp: introduce CONFIG_ARCH_ENABLE_THP_MIGRATION
>   mm: thp: enable thp migration in generic path
>   mm: thp: check pmd migration entry in common path
>   mm: soft-dirty: keep soft-dirty bits over thp migration
>   mm: hwpoison: soft offline supports thp migration
>   mm: mempolicy: mbind and migrate_pages support thp migration
>   mm: migrate: move_pages() supports thp migration
>   mm: memory_hotplug: memory hotremove supports thp migration
>=20
> Zi Yan (3):
>   mm: thp: make __split_huge_pmd_locked visible.
>   mm: thp: create new __zap_huge_pmd_locked function.
>   mm: use pmd lock instead of racy checks in zap_pmd_range()
>=20
>  arch/x86/Kconfig                     |   4 +
>  arch/x86/include/asm/pgtable.h       |  17 ++
>  arch/x86/include/asm/pgtable_64.h    |   2 +
>  arch/x86/include/asm/pgtable_types.h |  10 +-
>  arch/x86/mm/gup.c                    |   4 +-
>  fs/proc/task_mmu.c                   |  37 +++--
>  include/asm-generic/pgtable.h        | 105 ++++--------
>  include/linux/huge_mm.h              |  36 ++++-
>  include/linux/rmap.h                 |   1 +
>  include/linux/swapops.h              | 146 ++++++++++++++++-
>  mm/Kconfig                           |   3 +
>  mm/gup.c                             |  20 ++-
>  mm/huge_memory.c                     | 302 +++++++++++++++++++++++++++=
++------
>  mm/madvise.c                         |   2 +
>  mm/memcontrol.c                      |   2 +
>  mm/memory-failure.c                  |  31 ++--
>  mm/memory.c                          |  33 ++--
>  mm/memory_hotplug.c                  |  17 +-
>  mm/mempolicy.c                       | 124 ++++++++++----
>  mm/migrate.c                         |  66 ++++++--
>  mm/mprotect.c                        |   6 +-
>  mm/mremap.c                          |   2 +-
>  mm/page_vma_mapped.c                 |  13 +-
>  mm/pagewalk.c                        |   2 +
>  mm/pgtable-generic.c                 |   3 +-
>  mm/rmap.c                            |  21 ++-
>  26 files changed, 770 insertions(+), 239 deletions(-)
>=20

--=20
Best Regards,
Yan Zi


--------------enigE8B6B278229F6B3388EF32F3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJYrwnZAAoJEEGLLxGcTqbMsmcH/R8UUSIQRS573AkfTRdrWpCP
3pdoTD9m3DTUEwKUiEDs6oRY4h3wt+mRRmFURf4yDKLkmReQJ0M1EBdaSmet7hzr
EXJvSfGZc6tT1qoVEWoYRrxmdun+kNh0X0iV5CHlFzFT1cZMiUUybOK7tn+qwNxw
db568YnbGGRJb0bA06nGGLs1u52yVhnO4WCOFdGv1FRGXKRsXVgVrs2bIjMCDGmr
QQaNzkss2vjEXSNHoZqSL379T26xxalBSNYZ1d1sJyvM/xtRePgFgFrgYm3d1o5h
7dYF5pCi0fErGXAkMHrDJEWAaJ4JLiFfxqlcXJywdEeg3wzkfcqn8pRBDDPhHhM=
=Bzuf
-----END PGP SIGNATURE-----

--------------enigE8B6B278229F6B3388EF32F3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
