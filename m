Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0536B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:04:26 -0400 (EDT)
Received: by qgii95 with SMTP id i95so47437334qgi.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:04:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h52si6125058qgf.43.2015.07.31.08.04.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 08:04:25 -0700 (PDT)
Message-ID: <55BB8E72.3070101@redhat.com>
Date: Fri, 31 Jul 2015 17:04:18 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 26/36] mm: rework mapcount accounting to enable 4k mapping
 of THPs
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-27-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="dVxK5qvaVXt57cPEtw6iK7PGQCnqsKvWT"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dVxK5qvaVXt57cPEtw6iK7PGQCnqsKvWT
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound.
> It means we need to track mapcount on per small page basis.
>=20
> Straight-forward approach is to use ->_mapcount in all subpages to trac=
k
> how many time this subpage is mapped with PMDs or PTEs combined. But
> this is rather expensive: mapping or unmapping of a THP page with PMD
> would require HPAGE_PMD_NR atomic operations instead of single we have
> now.
>=20
> The idea is to store separately how many times the page was mapped as
> whole -- compound_mapcount. This frees up ->_mapcount in subpages to
> track PTE mapcount.
>=20
> We use the same approach as with compound page destructor and compound
> order to store compound_mapcount: use space in first tail page,
> ->mapping this time.
>=20
> Any time we map/unmap whole compound page (THP or hugetlb) -- we
> increment/decrement compound_mapcount. When we map part of compound pag=
e
> with PTE we operate on ->_mapcount of the subpage.
>=20
> page_mapcount() counts both: PTE and PMD mappings of the page.
>=20
> Basically, we have mapcount for a subpage spread over two counters.
> It makes tricky to detect when last mapcount for a page goes away.
>=20
> We introduced PageDoubleMap() for this. When we split THP PMD for the
> first time and there's other PMD mapping left we offset up ->_mapcount
> in all subpages by one and set PG_double_map on the compound page.
> These additional references go away with last compound_mapcount.

So this stays even if all PTE mappings goes and the page is again mapped
only with PMD. I'm not sure how often that happen and if it's an issue
worth caring about.

Acked-by: Jerome Marchand <jmarchan@redhat.com>

>=20
> This approach provides a way to detect when last mapcount goes away on
> per small page basis without introducing new overhead for most common
> cases.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h         | 26 +++++++++++-
>  include/linux/mm_types.h   |  1 +
>  include/linux/page-flags.h | 37 +++++++++++++++++
>  include/linux/rmap.h       |  4 +-
>  mm/debug.c                 |  5 ++-
>  mm/huge_memory.c           |  2 +-
>  mm/hugetlb.c               |  4 +-
>  mm/memory.c                |  2 +-
>  mm/migrate.c               |  2 +-
>  mm/page_alloc.c            | 14 +++++--
>  mm/rmap.c                  | 99 +++++++++++++++++++++++++++++++++++---=
--------
>  11 files changed, 161 insertions(+), 35 deletions(-)
>=20



--dVxK5qvaVXt57cPEtw6iK7PGQCnqsKvWT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVu45yAAoJEHTzHJCtsuoChpAIAID15Mk3hNRBtyVEuHmKrIbT
iija0wYPAvqCigt5d2PepMXSsbhlOEm2dnrMJsvYCnaoc+ZWsbmYxLJtPr67j3qO
6/tMYLlezS3zBOhKCFSNjixWxNg8gue/Rbd5ZsyIE+EMNA5jDHlNv6c0cp67fqQH
lTzRvbTHknNnmLjmMGzjBwms5Y4bvzlsOsnBQ8mPyrrF9Ua0sY3MDJmJAjIeZ7Mt
570TFbtU5xKFaAhNJdEGZSpUM1EAs7yN2VBH3Vv9ZaVu2BVQOCzBy9PrHGL38fMZ
XkHr4K7IdrYRxl+hl5qsA41F6C1BZ2EMm7n8YvcWXEDMgGpDVyqy8JOfGhd0IXo=
=l3De
-----END PGP SIGNATURE-----

--dVxK5qvaVXt57cPEtw6iK7PGQCnqsKvWT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
