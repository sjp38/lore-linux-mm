Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D163F440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:31:28 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a142so6308634oii.5
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:31:28 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id z70si6087293oia.152.2017.07.14.02.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 02:31:27 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v8 06/10] mm: thp: check pmd migration entry in common
 path
Date: Fri, 14 Jul 2017 09:29:43 +0000
Message-ID: <20170714092943.GA14125@hori1.linux.bs1.fc.nec.co.jp>
References: <20170701134008.110579-1-zi.yan@sent.com>
 <20170701134008.110579-7-zi.yan@sent.com>
In-Reply-To: <20170701134008.110579-7-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5C963B16EB7721409607A6564AF92E06@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@kernel.org" <mhocko@kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>

On Sat, Jul 01, 2017 at 09:40:04AM -0400, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
>=20
> If one of callers of page migration starts to handle thp,
> memory management code start to see pmd migration entry, so we need
> to prepare for it before enabling. This patch changes various code
> point which checks the status of given pmds in order to prevent race
> between thp migration and the pmd-related works.
>=20
> ChangeLog v1 -> v2:
> - introduce pmd_related() (I know the naming is not good, but can't
>   think up no better name. Any suggesntion is welcomed.)
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> ChangeLog v2 -> v3:
> - add is_swap_pmd()
> - a pmd entry should be pmd pointing to pte pages, is_swap_pmd(),
>   pmd_trans_huge(), pmd_devmap(), or pmd_none()
> - pmd_none_or_trans_huge_or_clear_bad() and pmd_trans_unstable() return
>   true on pmd_migration_entry, so that migration entries are not
>   treated as pmd page table entries.
>=20
> ChangeLog v4 -> v5:
> - add explanation in pmd_none_or_trans_huge_or_clear_bad() to state
>   the equivalence of !pmd_present() and is_pmd_migration_entry()
> - fix migration entry wait deadlock code (from v1) in follow_page_mask()
> - remove unnecessary code (from v1) in follow_trans_huge_pmd()
> - use is_swap_pmd() instead of !pmd_present() for pmd migration entry,
>   so it will not be confused with pmd_none()
> - change author information
>=20
> ChangeLog v5 -> v7
> - use macro to disable the code when thp migration is not enabled
>=20
> ChangeLog v7 -> v8
> - remove not used code in do_huge_pmd_wp_page()
> - copy the comment from change_pte_range() on downgrading
>   write migration entry to read to change_huge_pmd()
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/gup.c             |  7 +++--
>  fs/proc/task_mmu.c            | 33 ++++++++++++++-------
>  include/asm-generic/pgtable.h | 17 ++++++++++-
>  include/linux/huge_mm.h       | 14 +++++++--
>  mm/gup.c                      | 22 ++++++++++++--
>  mm/huge_memory.c              | 67 +++++++++++++++++++++++++++++++++++++=
++----
>  mm/memcontrol.c               |  5 ++++
>  mm/memory.c                   | 12 ++++++--
>  mm/mprotect.c                 |  4 +--
>  mm/mremap.c                   |  2 +-
>  10 files changed, 154 insertions(+), 29 deletions(-)
>=20
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 456dfdfd2249..096bbcc801e6 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -9,6 +9,7 @@
>  #include <linux/vmstat.h>
>  #include <linux/highmem.h>
>  #include <linux/swap.h>
> +#include <linux/swapops.h>
>  #include <linux/memremap.h>
> =20
>  #include <asm/mmu_context.h>
> @@ -243,9 +244,11 @@ static int gup_pmd_range(pud_t pud, unsigned long ad=
dr, unsigned long end,
>  		pmd_t pmd =3D *pmdp;
> =20
>  		next =3D pmd_addr_end(addr, end);
> -		if (pmd_none(pmd))
> +		if (!pmd_present(pmd)) {
> +			VM_BUG_ON(is_swap_pmd(pmd) && IS_ENABLED(CONFIG_MIGRATION) &&
> +					  !is_pmd_migration_entry(pmd));

This VM_BUG_ON() triggers when gup is called on hugetlb hwpoison entry.
I think that in such case kernel falls into the gup slow path, and
a page fault in follow_hugetlb_page() can properly report the error to
affected processes, so no need to alarm with BUG_ON.

Could you make this VM_BUG_ON more specific, or just remove it?

Thanks,
Naoya Horiguchi

>  			return 0;
> -		if (unlikely(pmd_large(pmd) || !pmd_present(pmd))) {
> +		} else if (unlikely(pmd_large(pmd))) {
>  			/*
>  			 * NUMA hinting faults need to be handled in the GUP
>  			 * slowpath for accounting purposes and so that they

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
