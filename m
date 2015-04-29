Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f51.google.com (mail-vn0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id A95316B006C
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:59:28 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so3878381vnb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:59:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si41306573vdv.34.2015.04.29.08.59.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:59:27 -0700 (PDT)
Message-ID: <5540FFD9.4050100@redhat.com>
Date: Wed, 29 Apr 2015 17:59:21 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 08/28] khugepaged: ignore pmd tables with THP mapped
 with ptes
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-9-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="bVU0EXvulTMJdRN9NkSFCBE2sLMReps5V"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--bVU0EXvulTMJdRN9NkSFCBE2sLMReps5V
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> Prepare khugepaged to see compound pages mapped with pte. For now we
> won't collapse the pmd table with such pte.
>=20
> khugepaged is subject for future rework wrt new refcounting.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/huge_memory.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fa3d4f78b716..ffc30e4462c1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2653,6 +2653,11 @@ static int khugepaged_scan_pmd(struct mm_struct =
*mm,
>  		page =3D vm_normal_page(vma, _address, pteval);
>  		if (unlikely(!page))
>  			goto out_unmap;
> +
> +		/* TODO: teach khugepaged to collapse THP mapped with pte */
> +		if (PageCompound(page))
> +			goto out_unmap;
> +
>  		/*
>  		 * Record which node the original page is from and save this
>  		 * information to khugepaged_node_load[].
> @@ -2663,7 +2668,6 @@ static int khugepaged_scan_pmd(struct mm_struct *=
mm,
>  		if (khugepaged_scan_abort(node))
>  			goto out_unmap;
>  		khugepaged_node_load[node]++;
> -		VM_BUG_ON_PAGE(PageCompound(page), page);
>  		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>  			goto out_unmap;
>  		/*
>=20



--bVU0EXvulTMJdRN9NkSFCBE2sLMReps5V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQP/ZAAoJEHTzHJCtsuoCEm0H/3DwdTYmET6xFbPCUp+fnrcU
ft5A43mwMvO0jxlNqt7wXe/YQ1gdrqETBzWeCd/xEICykvgeQKMkijV4yDm9AZLu
NnNMwKfRfhosg9Yx2VLT64jJvAAz9lIzc7wQTN9T6bYnUjby0GHbRffPszblcrTP
/L9/a0r6fEI8p2FMYwag81EZ9z5lYqU/7Q65bgCmLT87zPPOn39+i3Z2tdOQ9nzU
gyj/CUwpYt6hCDhz82R9Q9XkVdl2yDU/cTZYiIa6i7RqJe79J1H+DVtnUkUOdOYW
/4zGwZ0wyd1Rtx0VMthdpXXVA+j5VsOksQtPJJ+dpk70CkqxZizMzvQpCnucs50=
=zcfB
-----END PGP SIGNATURE-----

--bVU0EXvulTMJdRN9NkSFCBE2sLMReps5V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
