Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69C716B000D
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:20:58 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p73-v6so12250510qkp.2
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:20:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 193-v6sor1094949qkm.123.2018.10.12.09.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 09:20:57 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm/thp: fix call to mmu_notifier in
 set_pmd_migration_entry()
Date: Fri, 12 Oct 2018 12:20:54 -0400
Message-ID: <DB07F115-B404-4AB0-9D54-BC20C3A3F2B0@cs.rutgers.edu>
In-Reply-To: <20181012160953.5841-1-jglisse@redhat.com>
References: <20181012160953.5841-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_906B21A9-2CB1-46F5-85D0-2BB0F3A26498_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, David Nellans <dnellans@nvidia.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_906B21A9-2CB1-46F5-85D0-2BB0F3A26498_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12 Oct 2018, at 12:09, jglisse@redhat.com wrote:

> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> Inside set_pmd_migration_entry() we are holding page table locks and
> thus we can not sleep so we can not call invalidate_range_start/end()
>
> So remove call to mmu_notifier_invalidate_range_start/end() and add
> call to mmu_notifier_invalidate_range(). Note that we are already
> calling mmu_notifier_invalidate_range_start/end() inside the function
> calling set_pmd_migration_entry() (see try_to_unmap_one()).
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: David Nellans <dnellans@nvidia.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 533f9b00147d..93cb80fe12cb 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2885,9 +2885,6 @@ void set_pmd_migration_entry(struct page_vma_mapp=
ed_walk *pvmw,
>  	if (!(pvmw->pmd && !pvmw->pte))
>  		return;
>
> -	mmu_notifier_invalidate_range_start(mm, address,
> -			address + HPAGE_PMD_SIZE);
> -
>  	flush_cache_range(vma, address, address + HPAGE_PMD_SIZE);
>  	pmdval =3D *pvmw->pmd;
>  	pmdp_invalidate(vma, address, pvmw->pmd);
> @@ -2898,11 +2895,9 @@ void set_pmd_migration_entry(struct page_vma_map=
ped_walk *pvmw,
>  	if (pmd_soft_dirty(pmdval))
>  		pmdswp =3D pmd_swp_mksoft_dirty(pmdswp);
>  	set_pmd_at(mm, address, pvmw->pmd, pmdswp);
> +	mmu_notifier_invalidate_range(mm, address, address + HPAGE_PMD_SIZE);=

>  	page_remove_rmap(page, true);
>  	put_page(page);
> -
> -	mmu_notifier_invalidate_range_end(mm, address,
> -			address + HPAGE_PMD_SIZE);
>  }
>
>  void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct pa=
ge *new)
> -- =

> 2.17.2

Yes, these are the redundant calls to mmu_notifier_invalidate_range_start=
/end()
in set_pmd_migration_entry(). Thanks for the patch.

Fixes: 616b8371539a6 (mm: thp: enable thp migration in generic path)

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>



=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_906B21A9-2CB1-46F5-85D0-2BB0F3A26498_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlvAyeYWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzLdvB/9sSW6PhPP3b8PepHGMrweMmbAq
IAHFaZPjvCVTv44YZ252VsCc7Qrbiy2zGyHZiGqSxSBAq/nUykKl5EbgJ/O1j0hT
L/akDOrb7YCCgogc0UJMGaqZxbtJuCr/YDj0TPG7+5CTpmSrdiojRoVl5U6yiKmF
lblWlIrITT8K2JjHQuPLmz6MlHWhVL4jhYNzxjMgNBPA+m/2rqcb8Kd9Sq+YhkjC
3npyQykfs7vg3BIbRXaaXvipvQP/yynLKkhC4AqkIjlzXSjHpuLQU34Dlu1GGjcs
DyZgn3FwFejiabqzwsnDlkq9XBExfQsfF+dTVk4MyvuowDgFHIRSbPF0/FwX
=fw1N
-----END PGP SIGNATURE-----

--=_MailMate_906B21A9-2CB1-46F5-85D0-2BB0F3A26498_=--
