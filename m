Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDB06B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 21:58:14 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x3so2787303qcv.26
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 18:58:14 -0700 (PDT)
Received: from mail-qc0-x22e.google.com (mail-qc0-x22e.google.com [2607:f8b0:400d:c01::22e])
        by mx.google.com with ESMTPS id 68si12124114qgk.162.2014.04.30.18.58.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 18:58:13 -0700 (PDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so2772212qcz.5
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 18:58:13 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
In-Reply-To: <20140425082941.GA11428@js1304-P5Q-DELUXE>
References: <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org> <535590FC.10607@suse.cz> <20140421235319.GD7178@bbox> <53560D3F.2030002@suse.cz> <20140422065224.GE24292@bbox> <53566BEA.2060808@suse.cz> <20140423025806.GA11184@js1304-P5Q-DELUXE> <53576C08.2080003@suse.cz> <CAAmzW4OjKcrzXYNG6KN8acbOVfVtFmu-1COKpNQJrraBTmWGiA@mail.gmail.com> <5357CEB2.1070900@suse.cz> <20140425082941.GA11428@js1304-P5Q-DELUXE>
Date: Wed, 30 Apr 2014 21:58:06 -0400
Message-ID: <xa1t38gu1cr5.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 25 2014, Joonsoo Kim wrote:
> Subject: [PATCH] mm-compaction-cleanup-isolate_freepages-fix3
>
> What I did here is taking end_pfn out of the loop and considering zone
> boundary once. After then, we can just set previous pfn to end_pfn on
> every iteration to move scanning window. With this change, we can remove
> local variable, z_end_pfn.
>
> Another things I did are removing max() operation and un-needed
> assignment to isolate variable.
>
> In addition, I change both the variable names, from pfn and
> end_pfn to block_start_pfn and block_end_pfn, respectively.
> They represent their meaning perfectly.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 1c992dc..ba80bea 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -671,10 +671,10 @@ static void isolate_freepages(struct zone *zone,
>  				struct compact_control *cc)
>  {
>  	struct page *page;
> -	unsigned long pfn;	     /* scanning cursor */
> +	unsigned long block_start_pfn;	/* start of current pageblock */
> +	unsigned long block_end_pfn;	/* end of current pageblock */
>  	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
>  	unsigned long next_free_pfn; /* start pfn for scaning at next round */
> -	unsigned long z_end_pfn;     /* zone's end pfn */
>  	int nr_freepages =3D cc->nr_freepages;
>  	struct list_head *freelist =3D &cc->freepages;
>=20=20
> @@ -682,31 +682,33 @@ static void isolate_freepages(struct zone *zone,
>  	 * Initialise the free scanner. The starting point is where we last
>  	 * successfully isolated from, zone-cached value, or the end of the
>  	 * zone when isolating for the first time. We need this aligned to
> -	 * the pageblock boundary, because we do pfn -=3D pageblock_nr_pages
> -	 * in the for loop.
> +	 * the pageblock boundary, because we do
> +	 * block_start_pfn -=3D pageblock_nr_pages in the for loop.
> +	 * For ending point, take care when isolating in last pageblock of a
> +	 * a zone which ends in the middle of a pageblock.
>  	 * The low boundary is the end of the pageblock the migration scanner
>  	 * is using.
>  	 */
> -	pfn =3D cc->free_pfn & ~(pageblock_nr_pages-1);
> +	block_start_pfn =3D cc->free_pfn & ~(pageblock_nr_pages-1);
> +	block_end_pfn =3D min(block_start_pfn + pageblock_nr_pages,
> +						zone_end_pfn(zone));
>  	low_pfn =3D ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
>=20=20
>  	/*
> -	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
> -	 * isolated, the pfn < low_pfn check will kick in.
> +	 * If no pages are isolated, the block_start_pfn < low_pfn check
> +	 * will kick in.
>  	 */
>  	next_free_pfn =3D 0;
>=20=20
> -	z_end_pfn =3D zone_end_pfn(zone);
> -
>  	/*
>  	 * Isolate free pages until enough are available to migrate the
>  	 * pages on cc->migratepages. We stop searching if the migrate
>  	 * and free page scanners meet or enough free pages are isolated.
>  	 */
> -	for (; pfn >=3D low_pfn && cc->nr_migratepages > nr_freepages;
> -					pfn -=3D pageblock_nr_pages) {
> +	for (;block_start_pfn >=3D low_pfn && cc->nr_migratepages > nr_freepage=
s;
> +				block_end_pfn =3D block_start_pfn,
> +				block_start_pfn -=3D pageblock_nr_pages) {
>  		unsigned long isolated;
> -		unsigned long end_pfn;
>=20=20
>  		/*
>  		 * This can iterate a massively long zone without finding any
> @@ -715,7 +717,7 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		cond_resched();
>=20=20
> -		if (!pfn_valid(pfn))
> +		if (!pfn_valid(block_start_pfn))
>  			continue;
>=20=20
>  		/*
> @@ -725,7 +727,7 @@ static void isolate_freepages(struct zone *zone,
>  		 * i.e. it's possible that all pages within a zones range of
>  		 * pages do not belong to a single zone.
>  		 */
> -		page =3D pfn_to_page(pfn);
> +		page =3D pfn_to_page(block_start_pfn);
>  		if (page_zone(page) !=3D zone)
>  			continue;
>=20=20
> @@ -738,15 +740,8 @@ static void isolate_freepages(struct zone *zone,
>  			continue;
>=20=20
>  		/* Found a block suitable for isolating free pages from */
> -		isolated =3D 0;
> -
> -		/*
> -		 * Take care when isolating in last pageblock of a zone which
> -		 * ends in the middle of a pageblock.
> -		 */
> -		end_pfn =3D min(pfn + pageblock_nr_pages, z_end_pfn);
> -		isolated =3D isolate_freepages_block(cc, pfn, end_pfn,
> -						   freelist, false);
> +		isolated =3D isolate_freepages_block(cc, block_start_pfn,
> +					block_end_pfn, freelist, false);
>  		nr_freepages +=3D isolated;
>=20=20
>  		/*
> @@ -754,9 +749,9 @@ static void isolate_freepages(struct zone *zone,
>  		 * looking for free pages, the search will restart here as
>  		 * page migration may have returned some pages to the allocator
>  		 */
> -		if (isolated) {
> +		if (isolated && next_free_pfn =3D=3D 0) {
>  			cc->finished_update_free =3D true;
> -			next_free_pfn =3D max(next_free_pfn, pfn);
> +			next_free_pfn =3D block_start_pfn;
>  		}
>  	}
>=20=20
> @@ -767,7 +762,7 @@ static void isolate_freepages(struct zone *zone,
>  	 * If we crossed the migrate scanner, we want to keep it that way
>  	 * so that compact_finished() may detect this
>  	 */
> -	if (pfn < low_pfn)
> +	if (block_start_pfn < low_pfn)
>  		next_free_pfn =3D cc->migrate_pfn;
>=20=20
>  	cc->free_pfn =3D next_free_pfn;
> --=20
> 1.7.9.5
>

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

iQIcBAEBAgAGBQJTYaouAAoJECBgQBJQdR/0wDYQAJG2aOzFkimxHCWTzS3M5Fh/
a0LPlfTzVTv2c0fATyaHennpQHo7O5w3ezZ0P/5EHmb9/wi36s390ZSOT+u+Z5BE
AZl/cisSMfBq9dFb8roazj06tpc4vGQe76eXZ6lOD7Khkm5rZrRIqe/wd9dOhdQ2
2DDbP2rdljhgW7Vf91+mo+18n/eWaclUGe25uMT5PgEPAHY+Yxt4oMOMowiJ6cU8
55TFZdqDU7Z1MIgZZnHlRYjq+UjPxkAM5yJjzQ/q8EGdqSzllW5IZk4kNGxqZCgB
ljjKYCVcrqesq886rl5mThQdxL+/XbqlEF8zzg1HaX3IKo1FA3XNV+5txKuBXg+N
0r8YefVwpc41WIPRizmbgwZZp24DIYIRcYp9UGuC6E4hAyvXSrfJNUdZS7csZqbT
BSxiayt6WXycEIdvo7ZW0UJmQTWlJhastcaWvhHYDrutUgAG0WoUmjSVXlCbArWD
lOHPU7XUQkLRLgLltmzAQeymychhoP8rxrW/yaD1r0jV+z/MPkTkv6rZ7Xc2J3Fk
d7L+U+NXmqKlIOrJ2v2UWckt51COBElwCNPeEkOurO7pRSKaPqJS3ZKfznoh1L/c
zm2E7re4BlM4zCnv4fiWTjqsK5ZWn+VPfvCJqyGoppzE3kaVDkHtNFr1q/++FoZS
FBcinBQiObs7qrvXMSwz
=fuv5
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
