Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA8A76B000A
	for <linux-mm@kvack.org>; Tue,  8 May 2018 05:09:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s84-v6so17815072oig.17
        for <linux-mm@kvack.org>; Tue, 08 May 2018 02:09:11 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id s132-v6si8560555ois.86.2018.05.08.02.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 02:09:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm] mm, pagemap: Hide swap entry for unprivileged users
Date: Tue, 8 May 2018 09:07:34 +0000
Message-ID: <20180508090734.GA27996@hori1.linux.bs1.fc.nec.co.jp>
References: <20180508012745.7238-1-ying.huang@intel.com>
In-Reply-To: <20180508012745.7238-1-ying.huang@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <AAC608D4D314694BA2DE2476E4788BEB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrei Vagin <avagin@openvz.org>, Michal Hocko <mhocko@suse.com>, Jerome Glisse <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, May 08, 2018 at 09:27:45AM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> In ab676b7d6fbf ("pagemap: do not leak physical addresses to
> non-privileged userspace"), the /proc/PID/pagemap is restricted to be
> readable only by CAP_SYS_ADMIN to address some security issue.  In
> 1c90308e7a77 ("pagemap: hide physical addresses from non-privileged
> users"), the restriction is relieved to make /proc/PID/pagemap
> readable, but hide the physical addresses for non-privileged users.
> But the swap entries are readable for non-privileged users too.  This
> has some security issues.  For example, for page under migrating, the
> swap entry has physical address information.  So, in this patch, the
> swap entries are hided for non-privileged users too.
>=20
> Fixes: 1c90308e7a77 ("pagemap: hide physical addresses from non-privilege=
d users")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: Andrei Vagin <avagin@openvz.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Daniel Colascione <dancol@google.com>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi ying huang,

This patch looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  fs/proc/task_mmu.c | 26 ++++++++++++++++----------
>  1 file changed, 16 insertions(+), 10 deletions(-)
>=20
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index a20c6e495bb2..ff947fdd7c71 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1258,8 +1258,9 @@ static pagemap_entry_t pte_to_pagemap_entry(struct =
pagemapread *pm,
>  		if (pte_swp_soft_dirty(pte))
>  			flags |=3D PM_SOFT_DIRTY;
>  		entry =3D pte_to_swp_entry(pte);
> -		frame =3D swp_type(entry) |
> -			(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
> +		if (pm->show_pfn)
> +			frame =3D swp_type(entry) |
> +				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
>  		flags |=3D PM_SWAP;
>  		if (is_migration_entry(entry))
>  			page =3D migration_entry_to_page(entry);
> @@ -1310,11 +1311,14 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigne=
d long addr, unsigned long end,
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  		else if (is_swap_pmd(pmd)) {
>  			swp_entry_t entry =3D pmd_to_swp_entry(pmd);
> -			unsigned long offset =3D swp_offset(entry);
> +			unsigned long offset;
> =20
> -			offset +=3D (addr & ~PMD_MASK) >> PAGE_SHIFT;
> -			frame =3D swp_type(entry) |
> -				(offset << MAX_SWAPFILES_SHIFT);
> +			if (pm->show_pfn) {
> +				offset =3D swp_offset(entry) +
> +					((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +				frame =3D swp_type(entry) |
> +					(offset << MAX_SWAPFILES_SHIFT);
> +			}
>  			flags |=3D PM_SWAP;
>  			if (pmd_swp_soft_dirty(pmd))
>  				flags |=3D PM_SOFT_DIRTY;
> @@ -1332,10 +1336,12 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigne=
d long addr, unsigned long end,
>  			err =3D add_to_pagemap(addr, &pme, pm);
>  			if (err)
>  				break;
> -			if (pm->show_pfn && (flags & PM_PRESENT))
> -				frame++;
> -			else if (flags & PM_SWAP)
> -				frame +=3D (1 << MAX_SWAPFILES_SHIFT);
> +			if (pm->show_pfn) {
> +				if (flags & PM_PRESENT)
> +					frame++;
> +				else if (flags & PM_SWAP)
> +					frame +=3D (1 << MAX_SWAPFILES_SHIFT);
> +			}
>  		}
>  		spin_unlock(ptl);
>  		return err;
> --=20
> 2.17.0
>=20
> =
