Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8A96B0036
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:48:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so3850836pdi.37
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:48:27 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id gh1si2231203pac.147.2014.05.09.08.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:48:26 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so4563104pab.1
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:48:26 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 1/2] mm/compaction: do not count migratepages when unnecessary
In-Reply-To: <1399464550-26447-1-git-send-email-vbabka@suse.cz>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com> <1399464550-26447-1-git-send-email-vbabka@suse.cz>
Date: Fri, 09 May 2014 08:48:19 -0700
Message-ID: <xa1ty4ybvtq4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 07 2014, Vlastimil Babka wrote:
> During compaction, update_nr_listpages() has been used to count remaining
> non-migrated and free pages after a call to migrage_pages(). The freepages
> counting has become unneccessary, and it turns out that migratepages coun=
ting
> is also unnecessary in most cases.
>
> The only situation when it's needed to count cc->migratepages is when
> migrate_pages() returns with a negative error code. Otherwise, the non-ne=
gative
> return value is the number of pages that were not migrated, which is exac=
tly
> the count of remaining pages in the cc->migratepages list.
>
> Furthermore, any non-zero count is only interesting for the tracepoint of
> mm_compaction_migratepages events, because after that all remaining unmig=
rated
> pages are put back and their count is set to 0.
>
> This patch therefore removes update_nr_listpages() completely, and change=
s the
> tracepoint definition so that the manual counting is done only when the
> tracepoint is enabled, and only when migrate_pages() returns a negative e=
rror
> code.
>
> Furthermore, migrate_pages() and the tracepoints won't be called when the=
re's
> nothing to migrate. This potentially avoids some wasted cycles and reduce=
s the
> volume of uninteresting mm_compaction_migratepages events where "nr_migra=
ted=3D0
> nr_failed=3D0". In the stress-highalloc mmtest, this was about 75% of the=
 events.
> The mm_compaction_isolate_migratepages event is better for determining th=
at
> nothing was isolated for migration, and this one was just duplicating the=
 info.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

One tiny comment below:

> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  v2: checkpack and other non-functional fixes suggested by Naoya Horiguchi
>
>  include/trace/events/compaction.h | 26 ++++++++++++++++++++++----
>  mm/compaction.c                   | 31 +++++++------------------------
>  2 files changed, 29 insertions(+), 28 deletions(-)
>
> diff --git a/include/trace/events/compaction.h b/include/trace/events/com=
paction.h
> index 06f544e..aacaf0f 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -58,7 +61,22 @@ TRACE_EVENT(mm_compaction_migratepages,
>  	),
>=20=20
>  	TP_fast_assign(
> -		__entry->nr_migrated =3D nr_migrated;
> +		unsigned long nr_failed =3D 0;
> +		struct page *page;
> +
> +		/*
> +		 * migrate_pages() returns either a non-negative number
> +		 * with the number of pages that failed migration, or an
> +		 * error code, in which case we need to count the remaining
> +		 * pages manually
> +		 */
> +		if (migrate_rc >=3D 0)
> +			nr_failed =3D migrate_rc;
> +		else
> +			list_for_each_entry(page, migratepages, lru)
> +				nr_failed++;

list_for_each would suffice here.

> +
> +		__entry->nr_migrated =3D nr_all - nr_failed;
>  		__entry->nr_failed =3D nr_failed;
>  	),
>=20=20

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTbPjDAAoJECBgQBJQdR/0GgEP/2EgRhABRtUzNDgExK4GRmlW
ttL0MduqhASbq/uAfWAoWsiJAL8PgY1Yay8qGuHEUpYBoNEsRTktKAs4fR2qTatj
aCJ/PfLcBVamoxjsEbf4IF8DipWP7/+hoQrnw+FoRym5YrrGjHuOg6PHjQAsWQzm
Ob0lbLvFOP65Td2Wstyg5mk/WHmvOfh3DTsVfrKwE5mb4zsrZfebJxkF0vQ6p0C0
bvREQHBRbmTJa8kLi1InRkwcNXZ0JBEwFpt2IqBIM7IVTuMt/9kJ1AyimMkwxoI8
s0vqYFZ/WdzoivkyCP7n4H9kPa2CbFQ4kPnu6/cDAtfh/jkGZ8wXVuE64QsBttLp
ePphsQ9aWThm+9qNWF+UutoVvYnaGKiu2xMIdz1voRoWqh0mhBw8dnCZbLgmPqms
JKnWg7Cvk21XdApO2QJwfsYvEDAh6j+LMif5qtGJq0FBg0tlYDyJ4ivo4BeRyCEJ
86yDB88HeYaBqleD/06bFuqWx6Tq8YS/q4fdgc4Le84AngfyDakk6zydbfcLYWwr
T0uQLngIyH9useRwBL2yFzrwihygL1rdLP8gk67SpKjGue0p9CbWkKBjpnzDmZyi
sp6coruo0VgK/BOue5fyH43OtRn5CeMPs5f3zb6mVAaE5j4NVQuy85kwVTkehVxH
s4K2N26bPa98ZUypoVEU
=90Yo
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
