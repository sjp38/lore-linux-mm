Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 527576B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:01:14 -0400 (EDT)
Received: by qkdg63 with SMTP id g63so29926091qkd.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:01:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h198si6087023qhc.43.2015.07.31.08.01.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:01:13 -0700 (PDT)
Message-ID: <55BB8DB2.9010804@redhat.com>
Date: Fri, 31 Jul 2015 17:01:06 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 25/36] mm, thp: remove infrastructure for handling splitting
 PMDs
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-26-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="jCnAjDinooNRbjf9lMCdIgBHUl6rEm5Ov"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jCnAjDinooNRbjf9lMCdIgBHUl6rEm5Ov
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> With new refcounting we don't need to mark PMDs splitting. Let's drop c=
ode
> to handle this.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  fs/proc/task_mmu.c            |  8 +++---
>  include/asm-generic/pgtable.h |  9 -------
>  include/linux/huge_mm.h       | 21 +++++----------
>  mm/gup.c                      | 12 +--------
>  mm/huge_memory.c              | 60 ++++++++++-------------------------=
--------
>  mm/memcontrol.c               | 13 ++--------
>  mm/memory.c                   | 18 ++-----------
>  mm/mincore.c                  |  2 +-
>  mm/mremap.c                   | 15 +++++------
>  mm/pgtable-generic.c          | 14 ----------
>  mm/rmap.c                     |  4 +--
>  11 files changed, 37 insertions(+), 139 deletions(-)
>=20

snip

> @@ -1616,23 +1605,14 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
>   * Note that if it returns 1, this routine returns without unlocking p=
age
>   * table locks. So callers must unlock them.
>   */

The comment above should be updated. It otherwise looks good.

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> -int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
> +bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
>  		spinlock_t **ptl)
>  {
>  	*ptl =3D pmd_lock(vma->vm_mm, pmd);
> -	if (likely(pmd_trans_huge(*pmd))) {
> -		if (unlikely(pmd_trans_splitting(*pmd))) {
> -			spin_unlock(*ptl);
> -			wait_split_huge_page(vma->anon_vma, pmd);
> -			return -1;
> -		} else {
> -			/* Thp mapped by 'pmd' is stable, so we can
> -			 * handle it as it is. */
> -			return 1;
> -		}
> -	}
> +	if (likely(pmd_trans_huge(*pmd)))
> +		return true;
>  	spin_unlock(*ptl);
> -	return 0;
> +	return false;
>  }
> =20
>  /*



--jCnAjDinooNRbjf9lMCdIgBHUl6rEm5Ov
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu42yAAoJEHTzHJCtsuoCzGIH+wadxSCDKCQJdTtfDGkZ/etf
LcKAt9ovQoNpUoSh+IdSKXOt3zYdkZN/49VVTkD8du7DjL/S6rjz2hpmsvrtLHDe
uMRyxSQhCQbcyTb6rGjk+7lnJ5zWD6qCUtz6HOl0rrF2cTSSCtApGvNVA1gtcmZB
sOUVGk6oMiH6flbqJTsC6udziGPw/Q+8KqFmUlEQKX7sF9HF8c87SnihyGnO0IrF
Pb0+uMEyZ6Oys3ZD/zN/z2MBZlrtDfZegkYSEzVDAFBvWtyeE35JjgSqu8Qee3Fb
vdWFmaY1k0MbT4HUm7SVbhLLDoDdXJMF+ze58rvHPbdTKfN3RK+SLVlFJCKgens=
=kzGP
-----END PGP SIGNATURE-----

--jCnAjDinooNRbjf9lMCdIgBHUl6rEm5Ov--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
