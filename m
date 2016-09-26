Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61AC06B02C9
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:38:07 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m184so192667928qkb.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:38:07 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id f65si14840503qkj.9.2016.09.26.08.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:38:06 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v1 00/12] THP migration support
Date: Mon, 26 Sep 2016 11:38:05 -0400
Message-ID: <A0AA1E30-A897-4A48-9972-9BE1813AA57C@sent.com>
In-Reply-To: <20160926152234.14809-1-zi.yan@sent.com>
References: <20160926152234.14809-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_F8B56444-5998-4367-A46F-3EF15585435B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_F8B56444-5998-4367-A46F-3EF15585435B_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 26 Sep 2016, at 11:22, zi.yan@sent.com wrote:

> From: Zi Yan <zi.yan@cs.rutgers.edu>
>
> Hi all,
>
> This patchset is based on Naoya Horiguchi's page migration enchancement=

> for thp patchset with additional IBM ppc64 support. And I rebase it
> on the latest upstream commit.
>
> The motivation is that 4KB page migration is underutilizing the memory
> bandwidth compared to 2MB THP migration.

Sorry, in ppc64, 64KB page was used as the base page and 16MB THP
was used.

>
> As part of my internship work in NVIDIA, I compared the bandwidth
> utilizations between 512 4KB pages and 1 2MB page in both x86_64 and pp=
c64.
> And the results show that migrating 512 4KB pages takes only 3x and 1.1=
5x of
> the time, compared to migrating single 2MB THP, in x86_64 and ppc64
> respectively.
>
> Here are the actual BW numbers (total_data_size/migration_time):
>         | 512 4KB pages | 1 2MB THP  |  1 4KB page
> x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s
> ppc64   |  6.14GB/s     |  7.10GB/s  |   1.24GB/s

And the BW number should be:
         | 512 4KB pages | 1 2MB THP  |  1 4KB page
 x86_64  |  0.98GB/s     |  2.97GB/s  |   0.06GB/s

         | 512 64KB pages | 1 16MB THP  |  1 64KB page
 ppc64   |  6.14GB/s      |  7.10GB/s   |   1.24GB/s

>
> Any comments or advices are welcome.
>
> Here is the original message from Naoya:
>
> This patchset enhances page migration functionality to handle thp migra=
tion
> for various page migration's callers:
>  - mbind(2)
>  - move_pages(2)
>  - migrate_pages(2)
>  - cgroup/cpuset migration
>  - memory hotremove
>  - soft offline
>
> The main benefit is that we can avoid unnecessary thp splits, which hel=
ps us
> avoid performance decrease when your applications handles NUMA optimiza=
tion on
> their own.
>
> The implementation is similar to that of normal page migration, the key=
 point
> is that we modify a pmd to a pmd migration entry in swap-entry like for=
mat.
> pmd_present() is not simple and it's not enough by itself to determine =
whether
> a given pmd is a pmd migration entry. See patch 3/11 and 5/11 for detai=
ls.
>
> Here're topics which might be helpful to start discussion:
>
> - at this point, this functionality is limited to x86_64.
>
> - there's alrealy an implementation of thp migration in autonuma code o=
f which
>   this patchset doesn't touch anything because it works fine as it is.
>
> - fallback to thp split: current implementation just fails a migration =
trial if
>   thp migration fails. It's possible to retry migration after splitting=
 the thp,
>   but that's not included in this version.
>
> Thanks,
> Zi Yan
> ---
>
> Naoya Horiguchi (11):
>   mm: mempolicy: add queue_pages_node_check()
>   mm: thp: introduce CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>   mm: thp: add helpers related to thp/pmd migration
>   mm: thp: enable thp migration in generic path
>   mm: thp: check pmd migration entry in common path
>   mm: soft-dirty: keep soft-dirty bits over thp migration
>   mm: hwpoison: fix race between unpoisoning and freeing migrate source=

>     page
>   mm: hwpoison: soft offline supports thp migration
>   mm: mempolicy: mbind and migrate_pages support thp migration
>   mm: migrate: move_pages() supports thp migration
>   mm: memory_hotplug: memory hotremove supports thp migration
>
> Zi Yan (1):
>   mm: ppc64: Add THP migration support for ppc64.
>
>  arch/powerpc/Kconfig                         |   4 +
>  arch/powerpc/include/asm/book3s/64/pgtable.h |  23 ++++
>  arch/x86/Kconfig                             |   4 +
>  arch/x86/include/asm/pgtable.h               |  28 ++++
>  arch/x86/include/asm/pgtable_64.h            |   2 +
>  arch/x86/include/asm/pgtable_types.h         |   8 +-
>  arch/x86/mm/gup.c                            |   3 +
>  fs/proc/task_mmu.c                           |  20 +--
>  include/asm-generic/pgtable.h                |  34 ++++-
>  include/linux/huge_mm.h                      |  13 ++
>  include/linux/swapops.h                      |  64 ++++++++++
>  mm/Kconfig                                   |   3 +
>  mm/gup.c                                     |   8 ++
>  mm/huge_memory.c                             | 184 +++++++++++++++++++=
++++++--
>  mm/memcontrol.c                              |   2 +
>  mm/memory-failure.c                          |  41 +++---
>  mm/memory.c                                  |   5 +
>  mm/memory_hotplug.c                          |   8 ++
>  mm/mempolicy.c                               | 108 ++++++++++++----
>  mm/migrate.c                                 |  49 ++++++-
>  mm/page_isolation.c                          |   9 ++
>  mm/rmap.c                                    |   5 +
>  22 files changed, 549 insertions(+), 76 deletions(-)
>
> -- =

> 2.9.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>


--
Best Regards
Yan Zi

--=_MailMate_F8B56444-5998-4367-A46F-3EF15585435B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJX6UDdAAoJEEGLLxGcTqbMTGwIALHb6nTaDClJLKgXVAjtzz2k
ohOT2n2NQSjDTgzFbCItaxEr1p4eJGcsCfpV4w1u3VsmCHK3Yvc9F9kwQWg7SF4t
XM6DTtwgDGHWrwmmvPxvSO/5zXeQjosoe7dFuaz1bU3yoxNTymcJZSDqNSL+EOyt
j0+ORBDbvjlTyQ1i66WZhDXbyjwHXYsSB8KYAGfrUGM/4Rm6D1E65YveuBDF+BwZ
j/AxQH3fAUnWYxgufKuy6BXqhsvNaV9IF/XcjhReMrkNQiGcRFfR4akUbMN1zczW
CCIY37ovRAjUn6MXEMlsKjiJSWY4jydsnKIyzKc3wWnOXdTwT78O1yyvrey2Fog=
=yBx2
-----END PGP SIGNATURE-----

--=_MailMate_F8B56444-5998-4367-A46F-3EF15585435B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
