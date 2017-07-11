Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C27CD6B04C3
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:50:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 6so9650175oik.11
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:50:11 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id u197si9232551oif.27.2017.07.10.23.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 23:50:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v8 05/10] mm: thp: enable thp migration in generic path
Date: Tue, 11 Jul 2017 06:47:37 +0000
Message-ID: <20170711064736.GB22052@hori1.linux.bs1.fc.nec.co.jp>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-6-zi.yan@sent.com>
In-Reply-To: <20170701134008.110579-6-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DC60E43D8CFB8E40AD2A88B86A100EE5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>

On Sat, Jul 01, 2017 at 09:40:03AM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
>=20
> This patch adds thp migration's core code, including conversions
> between a PMD entry and a swap entry, setting PMD migration entry,
> removing PMD migration entry, and waiting on PMD migration entries.
>=20
> This patch makes it possible to support thp migration.
> If you fail to allocate a destination page as a thp, you just split
> the source thp as we do now, and then enter the normal page migration.
> If you succeed to allocate destination thp, you enter thp migration.
> Subsequent patches actually enable thp migration for each caller of
> page migration by allowing its get_new_page() callback to
> allocate thps.
>=20
> ChangeLog v1 -> v2:
> - support pte-mapped thp, doubly-mapped thp
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> ChangeLog v2 -> v3:
> - use page_vma_mapped_walk()
> - use pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear() in
>   set_pmd_migration_entry()
>=20
> ChangeLog v3 -> v4:
> - factor out the code of removing pte pgtable page in zap_huge_pmd()
>=20
> ChangeLog v4 -> v5:
> - remove unnecessary PTE-mapped THP code in remove_migration_pmd()
>   and set_pmd_migration_entry()
> - restructure the code in zap_huge_pmd() to avoid factoring out
>   the pte pgtable page code
> - in zap_huge_pmd(), check that PMD swap entries are migration entries
> - change author information
>=20
> ChangeLog v5 -> v7
> - use macro to disable the code when thp migration is not enabled
>=20
> ChangeLog v7 -> v8
> - use IS_ENABLED instead of macro to make code look clean in
>   zap_huge_pmd() and page_vma_mapped_walk()
> - remove BUILD_BUG() in pmd_to_swp_entry() and swp_entry_to_pmd() to
>   avoid compilation error
> - rename variable 'migration' to 'flush_needed' and invert the logic in
>   zap_huge_pmd() to make code more descriptive
> - use pmdp_invalidate() in set_pmd_migration_entry() to avoid race
>   with MADV_DONTNEED
> - remove unnecessary tlb flush in remove_migration_pmd()
> - add the missing migration flag check in page_vma_mapped_walk()
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/pgtable_64.h |  2 +
>  include/linux/swapops.h           | 67 ++++++++++++++++++++++++++++++-
>  mm/huge_memory.c                  | 84 +++++++++++++++++++++++++++++++++=
+++---
>  mm/migrate.c                      | 32 ++++++++++++++-
>  mm/page_vma_mapped.c              | 18 +++++++--
>  mm/pgtable-generic.c              |  3 +-
>  mm/rmap.c                         | 13 ++++++
>  7 files changed, 207 insertions(+), 12 deletions(-)
>=20
...

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 91948fbbb0bb..b28f633cd569 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1302,6 +1302,7 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  	bool ret =3D true;
>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
> =20
> +
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>  		return true;
> @@ -1312,6 +1313,18 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  	}
> =20
>  	while (page_vma_mapped_walk(&pvmw)) {
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +		/* PMD-mapped THP migration entry */
> +		if (flags & TTU_MIGRATION) {

My testing based on mmotm-2017-07-06-16-18 showed that migrating shmem thp
caused kernel crash. I don't think this is critical because that case is
just not-prepared yet. So in order to avoid the crash, please add
PageAnon(page) check here. This makes shmem thp migration just fail.

+			if (!PageAnon(page))
+				continue;

> +			if (!pvmw.pte && page) {

Just from curiosity, do we really need this page check?
try_to_unmap() always passes down the parameter 'page' to try_to_unmap_one(=
)
via rmap_walk_* family, so I think we can assume page is always non-NULL.

Thanks,
Naoya Horiguchi

> +				VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page),
> +						page);
> +				set_pmd_migration_entry(&pvmw, page);
> +				continue;
> +			}
> +		}
> +#endif
> +
>  		/*
>  		 * If the page is mlock()d, we cannot swap it out.
>  		 * If it's recently referenced (perhaps page_referenced
> --=20
> 2.11.0
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
