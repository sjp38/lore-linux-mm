Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f49.google.com (mail-vn0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 36C9E6B006E
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:56:14 -0400 (EDT)
Received: by vnbg7 with SMTP id g7so3828372vnb.11
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:56:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l10si164309vdb.74.2015.04.29.08.56.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:56:13 -0700 (PDT)
Message-ID: <5540FF16.1040302@redhat.com>
Date: Wed, 29 Apr 2015 17:56:06 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 06/28] mm: handle PTE-mapped tail pages in gerneric
 fast gup implementaiton
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-7-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Mr4KAS709sCE3X8HEOfGWFv2nUxsuwWOP"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Mr4KAS709sCE3X8HEOfGWFv2nUxsuwWOP
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting we are going to see THP tail pages mapped with PTE=
=2E
> Generic fast GUP rely on page_cache_get_speculative() to obtain
> reference on page. page_cache_get_speculative() always fails on tail
> pages, because ->_count on tail pages is always zero.
>=20
> Let's handle tail pages in gup_pte_range().
>=20
> New split_huge_page() will rely on migration entries to freeze page's
> counts. Recheck PTE value after page_cache_get_speculative() on head
> page should be enough to serialize against split.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/gup.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>=20
> diff --git a/mm/gup.c b/mm/gup.c
> index ebdb39b3e820..eaeeae15006b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1051,7 +1051,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long=
 addr, unsigned long end,
>  		 * for an example see gup_get_pte in arch/x86/mm/gup.c
>  		 */
>  		pte_t pte =3D READ_ONCE(*ptep);
> -		struct page *page;
> +		struct page *head, *page;
> =20
>  		/*
>  		 * Similar to the PMD case below, NUMA hinting must take slow
> @@ -1063,15 +1063,17 @@ static int gup_pte_range(pmd_t pmd, unsigned lo=
ng addr, unsigned long end,
> =20
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page =3D pte_page(pte);
> +		head =3D compound_head(page);
> =20
> -		if (!page_cache_get_speculative(page))
> +		if (!page_cache_get_speculative(head))
>  			goto pte_unmap;
> =20
>  		if (unlikely(pte_val(pte) !=3D pte_val(*ptep))) {
> -			put_page(page);
> +			put_page(head);
>  			goto pte_unmap;
>  		}
> =20
> +		VM_BUG_ON_PAGE(compound_head(page) !=3D head, page);
>  		pages[*nr] =3D page;
>  		(*nr)++;
> =20
>=20



--Mr4KAS709sCE3X8HEOfGWFv2nUxsuwWOP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQP8WAAoJEHTzHJCtsuoCXBcH/iaIMxM2NinYqfL+c/kHezYB
gt82/+WhQHkU0meCMreKPnc30c+xO7H8nTvipflj7s7qzoulmGuUSipOwkIXmQs+
ecOMqpaZYrNFl0JJ7MjrHVJKOZS6UKXT3vKxxfxX6uJLGmLB0ZkgutMZmPTGC30G
z83PYfkXa2ySdclFnNDhxjljc+ltN/WtE8qDHttQlWBho2/NJFQgzQlwt/qmSCDt
UWBA2LP4Oqe8OvkluGwLW9Z23qbPkK4NJ0SrLeKr6yCDVV5aD5QwckxAo18pjESl
qgy0BKHKKWRk1l16xRccONMWLKKjSfSCK2YVl2ZHU8W37uC94DIGRFvdLBTpyFo=
=5ibC
-----END PGP SIGNATURE-----

--Mr4KAS709sCE3X8HEOfGWFv2nUxsuwWOP--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
