Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 32B6F6B00A4
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:26:38 -0400 (EDT)
Received: by eaaf11 with SMTP id f11so685537eaa.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 09:26:36 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/4] cma: fix counting of isolated pages
In-Reply-To: <1345805120-797-2-git-send-email-b.zolnierkie@samsung.com>
References: <1345805120-797-1-git-send-email-b.zolnierkie@samsung.com> <1345805120-797-2-git-send-email-b.zolnierkie@samsung.com>
Date: Fri, 24 Aug 2012 18:26:29 +0200
Message-ID: <xa1tzk5k2r4a.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, minchan@kernel.org, mgorman@suse.de, kyungmin.park@samsung.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> writes:
> Isolated free pages shouldn't be accounted to NR_FREE_PAGES counter.
> Fix it by properly decreasing/increasing NR_FREE_PAGES counter in
> set_migratetype_isolate()/unset_migratetype_isolate() and removing
> counter adjustment for isolated pages from free_one_page() and
> split_free_page().

Other than a minor comment, looks reasonable to me.

> ---
>  mm/page_alloc.c     |  7 +++++--
>  mm/page_isolation.c | 13 ++++++++++---
>  2 files changed, 15 insertions(+), 5 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b94429e..e9bbd7c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -688,7 +688,8 @@ static void free_one_page(struct zone *zone, struct p=
age *page, int order,
>  	zone->pages_scanned =3D 0;
>=20=20
>  	__free_one_page(page, zone, order, migratetype);
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)

No need to call get_pageblock_migratetype().  You have this information
in migratetype variable.

> +		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
>  	spin_unlock(&zone->lock);
>  }
>=20=20

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

iQIcBAEBAgAGBQJQN6s1AAoJECBgQBJQdR/0XHsP/1vqQOvrA6RF/bHZIvf7Bu/E
PQIeawsc6rCsG7hAYxw3gS6jzy61ZVpdII6xbi+QHvNhXxUL4FO+aa8E5rv0Ni5N
B3PJ7VaqSvpST5uWEWCnBArj1tNvRgSDtoF88ODBvxM1pfAfdS9GzrNZfkcAQS1J
u+fudmCYlX0hf3P9C24YnjeD39ctH1bD0ybiAo/64MIy3NOOSXfq2+GaGHeySRnq
iZnOrcjyPtNwUvt1ohYM7kIaaHBu6VPFD58wjRoURUBinlFMHQm3W6JFsq/sYb7m
YuNNpiYW4LM3Tn6Ct1rKtTZ6v3XKh4s9Hsi8wuWB2SMa+VsTNzYFJf+HLtmK82Wc
BIR8xwR3+0BB/s1CyhD5sfVxjq1IMGtvN1uxc3O8QBfWZA6sE+McHl9D8+gwIQLy
iYAZuYQu7R0//BASLZK3VLOt+JbgCC9689EsONBxdN1te/rGn5F8CXvqj1QKZ7FF
4UVsmhrm7Hhf8BOGc5i2Nk3vPkNG2YXdJxVvtKUXktzbBBqjinCHmtdNnHH0MbUK
TMKHQsDCe2AXOdnviikCfVl7CQThr70R/SKMnhNZAtYv1ppPsfQrI8TeCCPgXzk8
FpeXFaKPy0aJN/b4R6dV0xLzWyWk+AVIPlUlQXdyALc1jQ5W2Cao9Ztrc3jpJUCz
HVsHy0Wxt8AOrTbl9BJW
=ltf9
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
