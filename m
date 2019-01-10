Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D22A18E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:44:26 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id c4so9576169ioh.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:44:26 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o133si9598650ith.20.2019.01.10.03.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 03:44:25 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm/shmem: make find_get_pages_range() work for huge page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190110030838.84446-1-yuzhao@google.com>
Date: Thu, 10 Jan 2019 04:43:57 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A7BE64E0-8F88-46AC-A330-E1AB23A50073@oracle.com>
References: <20190110030838.84446-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, Dave Chinner <david@fromorbit.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 9, 2019, at 8:08 PM, Yu Zhao <yuzhao@google.com> wrote:
>=20
> find_get_pages_range() and find_get_pages_range_tag() already
> correctly increment reference count on head when seeing compound
> page, but they may still use page index from tail. Page index
> from tail is always zero, so these functions don't work on huge
> shmem. This hasn't been a problem because, AFAIK, nobody calls
> these functions on (huge) shmem. Fix them anyway just in case.
>=20
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
> mm/filemap.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 81adec8ee02c..cf5fd773314a 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1704,7 +1704,7 @@ unsigned find_get_pages_range(struct =
address_space *mapping, pgoff_t *start,
>=20
> 		pages[ret] =3D page;
> 		if (++ret =3D=3D nr_pages) {
> -			*start =3D page->index + 1;
> +			*start =3D xas.xa_index + 1;
> 			goto out;
> 		}
> 		continue;
> @@ -1850,7 +1850,7 @@ unsigned find_get_pages_range_tag(struct =
address_space *mapping, pgoff_t *index,
>=20
> 		pages[ret] =3D page;
> 		if (++ret =3D=3D nr_pages) {
> -			*index =3D page->index + 1;
> +			*index =3D xas.xa_index + 1;
> 			goto out;
> 		}
> 		continue;
> --=20

While this works, it seems like this would be more readable for future =
maintainers were it to
instead squirrel away the value for *start/*index when ret was zero on =
the first iteration through
the loop.

Though xa_index is designed to hold the first index of the entry, it =
seems inappropriate to have
these routines deference elements of xas directly; I guess it depends on =
how opaque we want to keep
xas and struct xa_state.

Does anyone else have a feeling one way or the other? I could be =
persuaded either way.=
