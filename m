Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 5AFF16B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:20:05 -0400 (EDT)
Received: by eaaf11 with SMTP id f11so190837eaa.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 07:20:03 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC 2/2] cma: support MIGRATE_DISCARD
In-Reply-To: <1344934627-8473-3-git-send-email-minchan@kernel.org>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org> <1344934627-8473-3-git-send-email-minchan@kernel.org>
Date: Tue, 14 Aug 2012 16:19:55 +0200
Message-ID: <xa1t7gt1pnck.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Minchan Kim <minchan@kernel.org> writes:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drop clean cache pages instead of migration so that
> migration latency could be reduced. Of course, it could
> evict code pages but latency of big contiguous memory
> is more important than some background application's slow down
> in mobile embedded enviroment.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

This looks good to me.

> ---
>  include/linux/migrate_mode.h |   11 +++++++---
>  mm/migrate.c                 |   50 +++++++++++++++++++++++++++++++++---=
------
>  mm/page_alloc.c              |    2 +-
>  3 files changed, 49 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index ebf3d89..04ca19c 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -6,11 +6,16 @@
>   *	on most operations but not ->writepage as the potential stall time
>   *	is too significant
>   * MIGRATE_SYNC will block when migrating pages
> + * MIGRTATE_DISCARD will discard clean cache page instead of migration
> + *
> + * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
> + * together as OR flag.
>   */
>  enum migrate_mode {
> -	MIGRATE_ASYNC,
> -	MIGRATE_SYNC_LIGHT,
> -	MIGRATE_SYNC,
> +	MIGRATE_ASYNC =3D 1 << 0,
> +	MIGRATE_SYNC_LIGHT =3D 1 << 1,
> +	MIGRATE_SYNC =3D 1 << 2,
> +	MIGRATE_DISCARD =3D 1 << 3,
>  };

Since CMA is the only user of MIGRATE_DISCARD it may be worth it to
guard it inside an #ifdef, eg:

#ifdef CONFIG_CMA
	MIGRATE_DISCARD =3D 1 << 3,
#define is_migrate_discard(mode) (((mode) & MIGRATE_DISCARD) =3D=3D MIGRATE=
_DISCARD)
#endif

=20=20
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 77ed2d7..8119a59 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -685,9 +685,12 @@ static int __unmap_and_move(struct page *page, struc=
t page *newpage,
>  	int remap_swapcache =3D 1;
>  	struct mem_cgroup *mem;
>  	struct anon_vma *anon_vma =3D NULL;
> +	enum ttu_flags ttu_flags;
> +	bool discard_mode =3D false;
> +	bool file =3D false;
>=20=20
>  	if (!trylock_page(page)) {
> -		if (!force || mode =3D=3D MIGRATE_ASYNC)
> +		if (!force || mode & MIGRATE_ASYNC)

+		if (!force || (mode & MIGRATE_ASYNC))

>  			goto out;
>=20=20
>  		/*


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
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQKl6LAAoJECBgQBJQdR/0goYP/0/hPtydiXAf13PcPR+dWLrx
UhGN2//ZkV8KnA11/q/1fLJ7mIuUoR84gGi9PPkQUOdos5iOxoVj9yMB+UWlok68
qwrsOeBwJZLcYzpeLP3UAyuElxUBWCs4A/zvRXjA9Sb8Bnk0p7W/ONqfIjeYQsyN
phpxS8dEZkwLff4QOaQpHNYopTxDyBfjzbL2F0vlnXfP0NuLVEYk6BDE1d1oCXWt
7t61/34i3e5fNYGCybgxcmMWG32vzg6i1a1MTt4kXFVg+H8PtC8iM2u+/o0Ma2oW
76le3gW1P3zGFreBABKYViyu3MUEdS5yNzjspvCM7d20nTLlxKN7ZnqZF2Pmldwb
VU/eCmWTNbA3aCH+2zjbuV1M08CS4TmQcQa+T2Txp6PctRM6zfoM1v/kxdTgHKIW
PdtXiYN1yryjHGb6RDt34W9VGhEmiJ4wOtVb1taDHODM/VzrWe8YRIqvyqDjqTD8
PoyeoP4lqA71KZelHJh5KY7YXw0owROkesoADZcxWJ01D4jRo5m6G+ZkyfiAwVgj
IE3g4T5wcG4BxVPGazIni3HqoPX0HbSdbb7SnI4MHoSK1LypBGmuKsaoAqSb3o28
8qXxNNfPO2Cj6TNxyJDAkBnUXGL5b2nQYF1FR2Ha4t79ljqsMAX+54JqkOErWMtE
1MeBYF5Gv4LtAgQONM6c
=v1Nm
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
