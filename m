Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 450466B0255
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:12:55 -0400 (EDT)
Received: by qged69 with SMTP id d69so47683408qge.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:12:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q106si6142675qgq.84.2015.07.31.08.12.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:12:54 -0700 (PDT)
Message-ID: <55BB906F.5090802@redhat.com>
Date: Fri, 31 Jul 2015 17:12:47 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 31/36] thp, mm: split_huge_page(): caller need to lock
 page
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-32-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="iHoBrwQPgn5DP9CdXDtGWHceFubJduJiN"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iHoBrwQPgn5DP9CdXDtGWHceFubJduJiN
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> We're going to use migration entries instead of compound_lock() to
> stabilize page refcounts. Setup and remove migration entries require
> page to be locked.
>=20
> Some of split_huge_page() callers already have the page locked. Let's
> require everybody to lock the page before calling split_huge_page().
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/memory-failure.c | 10 ++++++++--
>  mm/migrate.c        |  8 ++++++--
>  2 files changed, 14 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index ef33ccf37224..f32a607d1aa3 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1143,15 +1143,18 @@ int memory_failure(unsigned long pfn, int trapn=
o, int flags)
>  				put_page(hpage);
>  			return -EBUSY;
>  		}
> +		lock_page(hpage);
>  		if (unlikely(split_huge_page(hpage))) {
>  			pr_err("MCE: %#lx: thp split failed\n", pfn);
>  			if (TestClearPageHWPoison(p))
>  				atomic_long_sub(nr_pages, &num_poisoned_pages);
> +			unlock_page(hpage);
>  			put_page(p);
>  			if (p !=3D hpage)
>  				put_page(hpage);
>  			return -EBUSY;
>  		}
> +		unlock_page(hpage);
>  		VM_BUG_ON_PAGE(!page_count(p), p);
>  		hpage =3D compound_head(p);
>  	}
> @@ -1714,10 +1717,13 @@ int soft_offline_page(struct page *page, int fl=
ags)
>  		return -EBUSY;
>  	}
>  	if (!PageHuge(page) && PageTransHuge(hpage)) {
> -		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
> +		lock_page(page);
> +		ret =3D split_huge_page(hpage);
> +		unlock_page(page);
> +		if (unlikely(ret)) {
>  			pr_info("soft offline: %#lx: failed to split THP\n",
>  				pfn);
> -			return -EBUSY;
> +			return ret;
>  		}
>  	}
> =20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 67970faf544d..a9dbfd356e9d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -933,9 +933,13 @@ static ICE_noinline int unmap_and_move(new_page_t =
get_new_page,
>  		goto out;
>  	}
> =20
> -	if (unlikely(PageTransHuge(page)))
> -		if (unlikely(split_huge_page(page)))
> +	if (unlikely(PageTransHuge(page))) {
> +		lock_page(page);
> +		rc =3D split_huge_page(page);
> +		unlock_page(page);
> +		if (rc)
>  			goto out;
> +	}
> =20
>  	rc =3D __unmap_and_move(page, newpage, force, mode);
> =20
>=20



--iHoBrwQPgn5DP9CdXDtGWHceFubJduJiN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5BvAAoJEHTzHJCtsuoCtfEH/1x8vpClqOVzqOxPZubdr9+g
AI8jcTEOd9Ei5wGna8GVB1bi0C1771hZCr8lFR/4AtxrHKrdo1/HQqW6ndIeW/Pb
FdMA+xWTCQpVRmh6qO15JwiwpzHd2it+xyIlg2mvBSOhx0qQb7zG1EkxcDNGx0gM
95AXYyUMUQmpy8jEi+lDyTHeNb7xKZJAZujLcX1if7FmIhOyUjySwUw+zepSHxyN
QuG3haPiwIpeHdSpXFO/4+ERNRVPCMR9P3pttfMurLRVqm9bQj69kAsK5cI/nG+v
EK/yqnUOtMIlMKe64LWifgas9bvjaQeVyKz0CwJ9JGuyRZApc9LBiBSx1NkBrng=
=wwS8
-----END PGP SIGNATURE-----

--iHoBrwQPgn5DP9CdXDtGWHceFubJduJiN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
