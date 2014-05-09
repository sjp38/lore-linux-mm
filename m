Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 489926B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 11:44:16 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so4497434pab.26
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:44:16 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id gw6si2219969pac.208.2014.05.09.08.44.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 08:44:15 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so4513913pab.31
        for <linux-mm@kvack.org>; Fri, 09 May 2014 08:44:14 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 1/3] CMA: remove redundant retrying code in __alloc_contig_migrate_range
In-Reply-To: <1399509144-8898-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Fri, 09 May 2014 08:44:06 -0700
Message-ID: <xa1t7g5vx8hl.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, May 07 2014, Joonsoo Kim wrote:
> We already have retry logic in migrate_pages(). It does retry 10 times.
> So if we keep this retrying code in __alloc_contig_migrate_range(), we
> would try to migrate some unmigratable page in 50 times. There is just one
> small difference in -ENOMEM case. migrate_pages() don't do retry
> in this case, however, current __alloc_contig_migrate_range() does. But,
> I think that this isn't problem, because in this case, we may fail again
> with same reason.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I think there was a reason for the retries in
__alloc_contig_migrate_range but perhaps those are no longer valid.

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5dba293..674ade7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6185,7 +6185,6 @@ static int __alloc_contig_migrate_range(struct comp=
act_control *cc,
>  	/* This function is based on compact_zone() from compaction.c. */
>  	unsigned long nr_reclaimed;
>  	unsigned long pfn =3D start;
> -	unsigned int tries =3D 0;
>  	int ret =3D 0;
>=20=20
>  	migrate_prep();
> @@ -6204,10 +6203,6 @@ static int __alloc_contig_migrate_range(struct com=
pact_control *cc,
>  				ret =3D -EINTR;
>  				break;
>  			}
> -			tries =3D 0;
> -		} else if (++tries =3D=3D 5) {
> -			ret =3D ret < 0 ? ret : -EBUSY;
> -			break;
>  		}
>=20=20
>  		nr_reclaimed =3D reclaim_clean_pages_from_list(cc->zone,
> @@ -6216,6 +6211,10 @@ static int __alloc_contig_migrate_range(struct com=
pact_control *cc,
>=20=20
>  		ret =3D migrate_pages(&cc->migratepages, alloc_migrate_target,
>  				    0, MIGRATE_SYNC, MR_CMA);
> +		if (ret) {
> +			ret =3D ret < 0 ? ret : -EBUSY;
> +			break;
> +		}
>  	}
>  	if (ret < 0) {
>  		putback_movable_pages(&cc->migratepages);

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

iQIcBAEBAgAGBQJTbPfGAAoJECBgQBJQdR/0nJQP/0htX/xZxE1ePn5SBbCWts+2
Zx9ESFvp1aZEQKrPQ/u692Imj99GtbUntwK4NPH9ponpK9ErSFoONK8h1FP2hgLG
KF8IhmKSy3D2J37r/kLLmmSHJqw52uqIu1UefbUv3fDgHvULd9kKz0eRPNn4dJTv
9+Vv7AbW69v39Owwp2R84y7t5SrPGN/SlqABzii296zmGkXQrWkDwRFk17FJ/KqA
RkmMSzkR+hMmAfefd2WcFeUASJDqTDMTxBKiUmEs9/WKSbkTRVa+Z+MRvpnKBTDs
Ra6Ya13fbFDKAVXivZiU+fIJkxnCQmPUfbjoZQn6T9FwkC89aVZKnLyPldKcPKg5
BjtoX7/HWrK3ERrV+n3CjqwITZZ4kMWbY8O81PgmM0HFZKdunEdqZCj07O0og7G3
xW/zGGlpXRBeDQa6xAm08ZInl3PTt5yq89Sl6vrNmOsubjrNiP4HNfR5dSHk08Ly
69Cs3SpCrNp64IzISO8QjabCw7oGzZoMrl6bnWaHSmNllOZwkAPTGQjq4kS8kcH5
KAqtF0tgQZcqLRh8dnQI7/WS6r5ClcHnuKQpN+4XXXo6B00Dc0B7ypBMRlPYgKJ8
FoxIMP6HyFTxxEtrndpfC4q6jcleoBRSWXkOYFArFu6az9egW3wlIYCYUpGprDZh
Gt6W2uDFcn0rHqEJoXGl
=+M2V
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
