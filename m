Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCD96B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 12:31:52 -0500 (EST)
Received: by wesx3 with SMTP id x3so6890200wes.7
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 09:31:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bj7si47922187wjc.132.2015.02.20.09.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 09:31:50 -0800 (PST)
Message-ID: <54E76F63.7020203@redhat.com>
Date: Fri, 20 Feb 2015 18:31:15 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 05/24] mm, proc: adjust PSS calculation
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-6-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uVLENov71cI4SvFvdH8POx0KjoqClp2uH"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uVLENov71cI4SvFvdH8POx0KjoqClp2uH
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/12/2015 05:18 PM, Kirill A. Shutemov wrote:
> With new refcounting all subpages of the compound page are not nessessa=
ry
> have the same mapcount. We need to take into account mapcount of every
> sub-page.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
>  1 file changed, 22 insertions(+), 21 deletions(-)
>=20
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 98826d08a11b..8a0a78174cc6 100644
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
> +	unsigned long size =3D 1UL << nr;

Shouldn't that be:
	unsigned long size =3D nr << PAGE_SHIFT;

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



--uVLENov71cI4SvFvdH8POx0KjoqClp2uH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU529oAAoJEHTzHJCtsuoCW0UH/0kJTrb4s5/JY4+r/mRLRRu0
wuvg+7HA0xe9STqHYNn4OHC3sWQWY9Uuzu9RZrxmSB+t7cUI8v0FDSmGcEtnnVWz
58jAMhCgSbfWHqR2DVl+azn4/3QwZLACmSsHhBg8uZJa/OJ+P+LxYWQHjFpeye4/
geDEVWZ9wiV50C4jcD8gNVQcrAx2TPkX+xHBwbjMOBcJnHnsUPeiLnerDvyZTDJW
gNYfcFste9jD7yEcBvjAqcLiKVpP2x3/gX7it9ey1bOt1xHZevDYR66WzuwRSWtM
WpWuTLReT4ORSKnl+pTaQAhMXS31z9amwn31Rdy+/lkSW/0Km0AtSz1xlbqnmEM=
=2kBP
-----END PGP SIGNATURE-----

--uVLENov71cI4SvFvdH8POx0KjoqClp2uH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
