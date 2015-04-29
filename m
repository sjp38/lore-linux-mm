Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id B811B6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:55:26 -0400 (EDT)
Received: by wgso17 with SMTP id o17so33314248wgs.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:55:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si24084370wix.18.2015.04.29.08.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:55:25 -0700 (PDT)
Message-ID: <5540FED0.1070007@redhat.com>
Date: Wed, 29 Apr 2015 17:54:56 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse
 the page on WP fault
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="AQ1Mfdmg1FFD6oQMGhbm41BFq361wWoLO"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AQ1Mfdmg1FFD6oQMGhbm41BFq361wWoLO
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting we will be able map the same compound page with
> PTEs and PMDs. It requires adjustment to conditions when we can reuse
> the page on write-protection fault.
>=20
> For PTE fault we can't reuse the page if it's part of huge page.
>=20
> For PMD we can only reuse the page if nobody else maps the huge page or=

> it's part. We can do it by checking page_mapcount() on each sub-page,
> but it's expensive.
>=20
> The cheaper way is to check page_count() to be equal 1: every mapcount
> takes page reference, so this way we can guarantee, that the PMD is the=

> only mapping.
>=20
> This approach can give false negative if somebody pinned the page, but
> that doesn't affect correctness.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/swap.h |  3 ++-
>  mm/huge_memory.c     | 12 +++++++++++-
>  mm/swapfile.c        |  3 +++
>  3 files changed, 16 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 0428e4c84e1d..17cdd6b9456b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -524,7 +524,8 @@ static inline int page_swapcount(struct page *page)=

>  	return 0;
>  }
> =20
> -#define reuse_swap_page(page)	(page_mapcount(page) =3D=3D 1)
> +#define reuse_swap_page(page) \
> +	(!PageTransCompound(page) && page_mapcount(page) =3D=3D 1)
> =20
>  static inline int try_to_free_swap(struct page *page)
>  {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 534f353e12bf..fd8af5b9917f 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1103,7 +1103,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
> =20
>  	page =3D pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> -	if (page_mapcount(page) =3D=3D 1) {
> +	/*
> +	 * We can only reuse the page if nobody else maps the huge page or it=
's
> +	 * part. We can do it by checking page_mapcount() on each sub-page, b=
ut
> +	 * it's expensive.
> +	 * The cheaper way is to check page_count() to be equal 1: every
> +	 * mapcount takes page reference reference, so this way we can
> +	 * guarantee, that the PMD is the only mapping.
> +	 * This can give false negative if somebody pinned the page, but that=
's
> +	 * fine.
> +	 */
> +	if (page_mapcount(page) =3D=3D 1 && page_count(page) =3D=3D 1) {
>  		pmd_t entry;
>  		entry =3D pmd_mkyoung(orig_pmd);
>  		entry =3D maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6dd365d1c488..3cd5f188b996 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -887,6 +887,9 @@ int reuse_swap_page(struct page *page)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	if (unlikely(PageKsm(page)))
>  		return 0;
> +	/* The page is part of THP and cannot be reused */
> +	if (PageTransCompound(page))
> +		return 0;
>  	count =3D page_mapcount(page);
>  	if (count <=3D 1 && PageSwapCache(page)) {
>  		count +=3D page_swapcount(page);
>=20



--AQ1Mfdmg1FFD6oQMGhbm41BFq361wWoLO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQP7QAAoJEHTzHJCtsuoChrYH/32xucRXxoHc1CBBA5yUYOGZ
zxg3R9tDcG5j4JBejjgrF9fsZLCgKey7T1ARfqmHQKy4sjW5bc5TX39yoP2lTqnw
9cexlNDSf7et8ocmovZG9kx4UAsTiflXtV7JggMPAqJbhQMuWeX3/kVXsMf8tmdR
Du0hh8Ukx1BYJmEZcXJA6V9tZAbAhhnh75iO1PKkp9RPEwHqXsDiaDmYId8anWtJ
GFBvRa846dxA7XAWiXAokXxoJnWA7KoEutxGm06oeuAGlG1rowONtL+47Bcem1P2
3V23vIBeyb82ArdFLOrj7VijyGwXQbUPScA971r7/PJsuiwyY+4UGjE4+xv8odY=
=CNbG
-----END PGP SIGNATURE-----

--AQ1Mfdmg1FFD6oQMGhbm41BFq361wWoLO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
