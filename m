Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B0F126B0096
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:43:00 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hm6so2005558wib.8
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:42:59 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: WARN if freed memory is still in use
In-Reply-To: <1352718446-32313-1-git-send-email-m.szyprowski@samsung.com>
References: <1352718446-32313-1-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 12 Nov 2012 17:42:50 +0100
Message-ID: <xa1t8va6zsad.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 12 2012, Marek Szyprowski wrote:
> Memory return to free_contig_range() must have no other references. Let
> kernel to complain loudly if page reference count is not equal to 1.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 022e4ed..290c2eb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5888,8 +5888,13 @@ done:
>=20=20
>  void free_contig_range(unsigned long pfn, unsigned nr_pages)
>  {
> -	for (; nr_pages--; ++pfn)
> -		__free_page(pfn_to_page(pfn));
> +	struct page *page =3D pfn_to_page(pfn);
> +	int refcount =3D nr_pages;
> +	for (; nr_pages--; page++) {
> +		refcount -=3D page_count(page) =3D=3D 1;
> +		__free_page(page);
> +	}
> +	WARN(refcount !=3D 0, "some pages are still in use!\n");

This decrementing logic seem backward to me.  Why not:

	struct page *page =3D pfn_to_page(pfn);
	unsigned int refcount =3D 0;
	for (; nr_pages--; page++) {
		refcount +=3D page_count(page) !=3D 1;
		__free_page(page);
	}
	WARN(refcount !=3D 0, "some pages are still in use!\n");

>  }
>  #endif

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

iQIcBAEBAgAGBQJQoScKAAoJECBgQBJQdR/0sNQQAIxdNyaczFaJA055aFVoZCoG
6w4IxqtMZeD96Vk0XD1msOH8wzmBknWEsknqKcRVEIp1Q05stiVlpn3Ny+1sUl6i
SjdUcVcyGJESvtQEA+af5M/PnOxXLj7kuFUGZ/knTOgN79V7cnR/3NvGpP8IBBJ4
xZeI/+PgxKXRIB07UqNeLnX6bQrwubxPPTOAZa9WzqajrtcT9RBD5qQRT4wzxzGb
+5MCVCa0GhhIfOXr7qsdMETIA+kJXycm9SMfVmJw3yoNt+GwLDKltQBRWMzH8xkN
404/qPkikDuNBdSRVRPhohQQ0JaOGOVk6r1pfGS8EDjEjGX0T8/r/OvihChdZ5fI
yxi0pMY9qBX2ExVkIwzbQ7no/vpFs1e/OmvpU4TCA/sBvxSAqn6n4slhJKAzHJai
emW78Y/j+obR5q8VdQaYPMgmI8ZW8y9GhhGIh8/COa6/wu+Gw2PJLTHLjRYQKe5D
90bTDChvuLc0ZNw0dTZ0GTvmMHqiGmpQnh/gMJAOuIYKHgyBWuDmqisnq+/M3HDz
MVIozN8sWLNn0+nbVt+CjfroQC42rcKhUP9AOwBqyUfC6o1gFFR4EBJFj7FLP/fM
zR15WXlKy5gkLLEAeLNca6Uy7ihoPTSn4Evhcpw7qYNVB2WjdsqQNyUrP7RmsPVy
LU7Y37q/6j/xF1gDrWgF
=4w/2
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
