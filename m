Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f52.google.com (mail-vn0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 01E7D6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:49:42 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so3804184vnb.7
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:49:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y14si12272628vdi.26.2015.04.29.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:49:41 -0700 (PDT)
Message-ID: <5540FD86.6060001@redhat.com>
Date: Wed, 29 Apr 2015 17:49:26 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 01/28] mm, proc: adjust PSS calculation
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="i6313ODBstho809IHJ3ROGRpetkdrm6jH"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--i6313ODBstho809IHJ3ROGRpetkdrm6jH
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting all subpages of the compound page are not nessessa=
ry
> have the same mapcount. We need to take into account mapcount of every
> sub-page.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
>  1 file changed, 22 insertions(+), 21 deletions(-)
>=20
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 956b75d61809..95bc384ee3f7 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -449,9 +449,10 @@ struct mem_size_stats {
>  };
> =20
>  static void smaps_account(struct mem_size_stats *mss, struct page *pag=
e,
> -		unsigned long size, bool young, bool dirty)
> +		bool compound, bool young, bool dirty)
>  {
> -	int mapcount;
> +	int i, nr =3D compound ? hpage_nr_pages(page) : 1;
> +	unsigned long size =3D nr * PAGE_SIZE;
> =20
>  	if (PageAnon(page))
>  		mss->anonymous +=3D size;
> @@ -460,23 +461,23 @@ static void smaps_account(struct mem_size_stats *=
mss, struct page *page,
>  	/* Accumulate the size in pages that have been accessed. */
>  	if (young || PageReferenced(page))
>  		mss->referenced +=3D size;
> -	mapcount =3D page_mapcount(page);
> -	if (mapcount >=3D 2) {
> -		u64 pss_delta;
> =20
> -		if (dirty || PageDirty(page))
> -			mss->shared_dirty +=3D size;
> -		else
> -			mss->shared_clean +=3D size;
> -		pss_delta =3D (u64)size << PSS_SHIFT;
> -		do_div(pss_delta, mapcount);
> -		mss->pss +=3D pss_delta;
> -	} else {
> -		if (dirty || PageDirty(page))
> -			mss->private_dirty +=3D size;
> -		else
> -			mss->private_clean +=3D size;
> -		mss->pss +=3D (u64)size << PSS_SHIFT;
> +	for (i =3D 0; i < nr; i++) {
> +		int mapcount =3D page_mapcount(page + i);
> +
> +		if (mapcount >=3D 2) {
> +			if (dirty || PageDirty(page + i))
> +				mss->shared_dirty +=3D PAGE_SIZE;
> +			else
> +				mss->shared_clean +=3D PAGE_SIZE;
> +			mss->pss +=3D (PAGE_SIZE << PSS_SHIFT) / mapcount;
> +		} else {
> +			if (dirty || PageDirty(page + i))
> +				mss->private_dirty +=3D PAGE_SIZE;
> +			else
> +				mss->private_clean +=3D PAGE_SIZE;
> +			mss->pss +=3D PAGE_SIZE << PSS_SHIFT;
> +		}
>  	}
>  }
> =20
> @@ -500,7 +501,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned lo=
ng addr,
> =20
>  	if (!page)
>  		return;
> -	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte))=
;
> +
> +	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
>  }
> =20
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -516,8 +518,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned lo=
ng addr,
>  	if (IS_ERR_OR_NULL(page))
>  		return;
>  	mss->anonymous_thp +=3D HPAGE_PMD_SIZE;
> -	smaps_account(mss, page, HPAGE_PMD_SIZE,
> -			pmd_young(*pmd), pmd_dirty(*pmd));
> +	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
>  }
>  #else
>  static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>=20



--i6313ODBstho809IHJ3ROGRpetkdrm6jH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQP2LAAoJEHTzHJCtsuoCP+AIAK5wZ/wSCwlmUyV0nKXb2qJp
CFDPg+iFAvaU9+TFFm9OrBVpuYoVdSx9FiWhWmW2d/CKVJ386qAnm33bEaVe9vVG
ReuoWdX9i/00uqsFcWe0/CBScb7MWS04L3pnDKPFJAv5Fzb8PU1Pm5bA0thjRKk7
4E2sL04ZpYW4kKK/RsUdMCufH0On9jSHYTHAcg3U49cTaNMUjhejWYmM7KH1HIAY
azTCWv7wrYbiJ04rG4Lemc+Te5cVR8fLGg+VIOpPyk+iewcMBe2tijxzwx6VCaYb
iqodx7ZLYgqv4M+t0VEmicp2YnajRlQNmjh7KWpUuQNeYxYigNfAXJFMXJH4MAs=
=BmAl
-----END PGP SIGNATURE-----

--i6313ODBstho809IHJ3ROGRpetkdrm6jH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
