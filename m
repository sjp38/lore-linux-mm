Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 141456B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 10:13:42 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id dr1so954172wgb.1
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 07:13:40 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] CMA: call to putback_lru_pages
In-Reply-To: <20121219152736.1daa3d58.akpm@linux-foundation.org>
References: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com> <xa1tlicwiagh.fsf@mina86.com> <20121219152736.1daa3d58.akpm@linux-foundation.org>
Date: Thu, 20 Dec 2012 16:13:33 +0100
Message-ID: <xa1tobhohi3m.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 20 2012, Andrew Morton <akpm@linux-foundation.org> wrote:
> __alloc_contig_migrate_range() is a bit twisty.  How does this look?
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/page_alloc.c:__alloc_contig_migrate_range(): cleanup
>
> - `ret' is always zero in the we-timed-out case
> - remove a test-n-branch in the wrapup code
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/page_alloc.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cle=
anup mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_contig_migrate_range-cleanup
> +++ a/mm/page_alloc.c
> @@ -5804,7 +5804,6 @@ static int __alloc_contig_migrate_range(
>  			}
>  			tries =3D 0;
>  		} else if (++tries =3D=3D 5) {
> -			ret =3D ret < 0 ? ret : -EBUSY;

I don't really follow this change.

If migration for a page failed, migrate_pages() will return a positive
value, which _alloc_contig_migrate_range() must interpret as a failure,
but with this change, it is possible to exit the loop after migration of
some pages failed and with ret > 0 which will be interpret as success.

On top of that, because ret > 0, =E2=80=9Cif (ret < 0) putback_movable_page=
s()=E2=80=9D
won't be executed thus pages from cc->migratepages will leak.  I must be
missing something here...

>  			break;
>  		}
>=20=20
> @@ -5817,9 +5816,11 @@ static int __alloc_contig_migrate_range(
>  				    0, false, MIGRATE_SYNC,
>  				    MR_CMA);
>  	}
> -	if (ret < 0)
> +	if (ret < 0) {
>  		putback_movable_pages(&cc->migratepages);
> -	return ret > 0 ? 0 : ret;
> +		return ret;
> +	}
> +	return 0;
>  }

This second hunk looks right.

>=20=20
>  /**
> _
>
>
> Also, what's happening here?
>
> 			pfn =3D isolate_migratepages_range(cc->zone, cc,
> 							 pfn, end, true);
> 			if (!pfn) {
> 				ret =3D -EINTR;
> 				break;
> 			}
>
> The isolate_migratepages_range() return value is undocumented and
> appears to make no sense.  It returns zero if fatal_signal_pending()
> and if too_many_isolated&&!cc->sync.  Returning -EINTR in the latter
> case is daft.

__alloc_contig_migrate_range() is always called with cc->sync =3D=3D true,
so the latter never happens in our case.  As such, the condition
terminates the loop if a fatal signal is pending.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ0ysdAAoJECBgQBJQdR/0kmoP/2RDwLHeieOMaQg7hXyOz1/9
E9XLsq+OTEptnOo+7RiM1D/2lamdLN6r++YIPIwFp51O7HjGDubgZlRS+7lMuZCe
RE3wHq5VjHlxkLT/hZXjuKU1zWiKnBMxQ0fea8KOu+uZKO9vK7AwdyVK+ojvdu8k
W4VPey/ZwZx6AHFJYs68zh3KYHAB08oaskXio7B7M0/8wEka1NWH66h2xpxdTwsq
45/hN3UAWmONIYiL2gkwWskKDEVwatHypEZCulQYzSngpxyTk47I7kIqTkseogcg
B+beAYhT3qKvlIeIoEwjJ7pGJ+XFzobjpQn4H2AstvhsYAPdSAN2lgRF/EInbSUm
1PFalC7OtcTJniDp+t7pwonJvHFIaUVB/aCJJE+eMsx1wUqvLNfuLga7mQmwDHFk
0YLsUrRUYbFc5jj2o3vUUt6zzMmY2XfoL5pz983qPyBb5qS74qAXdsQQRZXAtRoI
xsnnDVVOZVUS+1dMrbDORj26mf3wXgoPw0UqUfCv3xouie719Nmsnjed3ryi4pxA
va7dbpcx8rmp2eTcQtOFsqo5dXSfbLVUwIoR9GeOC3nYIV5ZiZzCHsdSL0g3FK9E
Fodf4uwaerc0SSQoHhTKEjBvcY9FAMjY7Mb4dILpGz8h24TPAVuQA1yQXWCezMEa
PHAfit6UvdADrVhW4Bj0
=4Ltn
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
