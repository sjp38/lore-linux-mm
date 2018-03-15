Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7386B0009
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 21:40:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m6-v6so2114694pln.8
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 18:40:04 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0093.outbound.protection.outlook.com. [104.47.37.93])
        by mx.google.com with ESMTPS id j11si2992934pfi.57.2018.03.14.18.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 18:40:03 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH -mm] mm, madvise, THP: Use THP aligned address in
 madvise_free_huge_pmd()
Date: Wed, 14 Mar 2018 21:39:54 -0400
Message-ID: <869F4AAA-5BBA-40D6-916F-6919E515D271@cs.rutgers.edu>
In-Reply-To: <20180315011840.27599-1-ying.huang@intel.com>
References: <20180315011840.27599-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D918F561-2FC7-4795-8EA5-369E1EC9958A_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, jglisse@redhat.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D918F561-2FC7-4795-8EA5-369E1EC9958A_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

This cannot happen.

Two address parameters are passed: addr and next.
If =E2=80=9Caddr=E2=80=9D is not aligned and =E2=80=9Cnext=E2=80=9D is al=
igned or the end of madvise range, which might not be aligned,
either way next - addr < HPAGE_PMD_SIZE.

This means the code in =E2=80=9Cif (next - addr !=3D HPAGE_PMD_SIZE)=E2=80=
=9D, which is above your second hunk,
will split the THP between =E2=80=9Caddr=E2=80=9D and =E2=80=9Cnext=E2=80=
=9D and get out as long as =E2=80=9Caddr=E2=80=9C is not aligned.
Thus, the code in your second hunk should always get aligned =E2=80=9Cadd=
r=E2=80=9D.

Let me know if I miss anything.

=E2=80=94
Best Regards,
Yan Zi

On 14 Mar 2018, at 21:18, Huang, Ying wrote:

> From: Huang Ying <ying.huang@intel.com>
>
> The address argument passed in madvise_free_huge_pmd() may be not THP
> aligned.  But some THP operations like pmdp_invalidate(),
> set_pmd_at(), and tlb_remove_pmd_tlb_entry() need the address to be
> THP aligned.  Fix this via using THP aligned address for these
> functions in madvise_free_huge_pmd().
>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: jglisse@redhat.com
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 0cc62405de9c..c5e1bfb08bd7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1617,6 +1617,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb=
, struct vm_area_struct *vma,
>  	struct page *page;
>  	struct mm_struct *mm =3D tlb->mm;
>  	bool ret =3D false;
> +	unsigned long haddr =3D addr & HPAGE_PMD_MASK;
>
>  	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
>
> @@ -1663,12 +1664,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *t=
lb, struct vm_area_struct *vma,
>  	unlock_page(page);
>
>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> -		pmdp_invalidate(vma, addr, pmd);
> +		pmdp_invalidate(vma, haddr, pmd);
>  		orig_pmd =3D pmd_mkold(orig_pmd);
>  		orig_pmd =3D pmd_mkclean(orig_pmd);
>
> -		set_pmd_at(mm, addr, pmd, orig_pmd);
> -		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> +		set_pmd_at(mm, haddr, pmd, orig_pmd);
> +		tlb_remove_pmd_tlb_entry(tlb, pmd, haddr);
>  	}
>
>  	mark_page_lazyfree(page);
> -- =

> 2.16.1

--=_MailMate_D918F561-2FC7-4795-8EA5-369E1EC9958A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlqpzuoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzJ7XB/9zWV2AhzeiHiU7rDo4Zz1oa5/J
Bezggv7XS03LbSeHrYHaSo0NufxvGoE3gADqUQrMDrfq8LkYc7a6iua9IXBHOzrh
kU+tXVuhmPKbUKplXfXc1oeSVoi/4qHcdgcUiYYMKX6GNCsJzm6FgxB+xNvxrAq+
2b4hYoXO02eFaTlOgEgwu27IDH07P0PhEzEXTsXEoNi87TDPoc1xeoybz/ATOI09
L4SFXg6XlpkHQR9wt4cf3zSqdj8wyXU5sdUJa0C4+SmfNq3nz1ek452G3PNPbxCA
KfjWQbzbzdw5qnFD/tPxk/coQ6mRKeRPyAs5t8R0VyJtAMLRqeVQreRgqZUF
=IQbt
-----END PGP SIGNATURE-----

--=_MailMate_D918F561-2FC7-4795-8EA5-369E1EC9958A_=--
