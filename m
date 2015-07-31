Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C56026B0258
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:13:45 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so47483085qge.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:13:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si6127227qky.109.2015.07.31.08.13.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:13:45 -0700 (PDT)
Message-ID: <55BB90A2.2090908@redhat.com>
Date: Fri, 31 Jul 2015 17:13:38 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 32/36] thp: reintroduce split_huge_page()
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-33-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CgU9jP0hnaaHaHKvVhsHscoIBlKhaEP1s"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CgU9jP0hnaaHaHKvVhsHscoIBlKhaEP1s
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> This patch adds implementation of split_huge_page() for new
> refcountings.
>=20
> Unlike previous implementation, new split_huge_page() can fail if
> somebody holds GUP pin on the page. It also means that pin on page
> would prevent it from bening split under you. It makes situation in
> many places much cleaner.
>=20
> The basic scheme of split_huge_page():
>=20
>   - Check that sum of mapcounts of all subpage is equal to page_count()=

>     plus one (caller pin). Foll off with -EBUSY. This way we can avoid
>     useless PMD-splits.
>=20
>   - Freeze the page counters by splitting all PMD and setup migration
>     PTEs.
>=20
>   - Re-check sum of mapcounts against page_count(). Page's counts are
>     stable now. -EBUSY if page is pinned.
>=20
>   - Split compound page.
>=20
>   - Unfreeze the page by removing migration entries.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/huge_mm.h |   7 +-
>  include/linux/pagemap.h |  13 +-
>  mm/huge_memory.c        | 318 ++++++++++++++++++++++++++++++++++++++++=
++++++++
>  mm/internal.h           |  26 +++-
>  mm/rmap.c               |  21 ----
>  5 files changed, 357 insertions(+), 28 deletions(-)
>=20
>=20



--CgU9jP0hnaaHaHKvVhsHscoIBlKhaEP1s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu5CiAAoJEHTzHJCtsuoCMosH/RZupRA45qRHsJC95qFpHL3P
4VlrZ4r6cNzNFbZKvF5qdwnPfRvpEVhxeLO5vfCgPHbgAvsa6Mj1ga0eC68Z916o
5pwHtKI/lTuvNqpzySoDyzgMQ8uBPJN2H+8EUWi+bZj1Kdu+B8wASSqDhCOxngrG
o3KxF7ALaEFORD/F5TtEBDylEK0hSMQEROa3wOCAf3smIWvFVSyg0IeI83IM3NBW
lyFuFjV6NhCaU9BqmoMVb6Ry5bS3vcEDsQv289zN/FuW9DiCwOibUI34qc+Zmpf6
No4pynt7AUSdAXq5YAT/AajTFlzt8/rW9g0CNdINDqL0ofaTEiMCH6PY5wftVR8=
=tHnU
-----END PGP SIGNATURE-----

--CgU9jP0hnaaHaHKvVhsHscoIBlKhaEP1s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
