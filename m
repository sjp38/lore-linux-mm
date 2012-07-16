Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 1A11E6B0080
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:41:03 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so5037186bkc.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:41:01 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 3/3] mm: fix return value in __alloc_contig_migrate_range()
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
	<1342455272-32703-3-git-send-email-js1304@gmail.com>
Date: Mon, 16 Jul 2012 19:40:56 +0200
In-Reply-To: <1342455272-32703-3-git-send-email-js1304@gmail.com> (Joonsoo
	Kim's message of "Tue, 17 Jul 2012 01:14:32 +0900")
Message-ID: <871ukbr4d3.fsf@erwin.mina86.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

--=-=-=
Content-Transfer-Encoding: quoted-printable

Joonsoo Kim <js1304@gmail.com> writes:

> migrate_pages() would return positive value in some failure case,
> so 'ret > 0 ? 0 : ret' may be wrong.
> This fix it and remove one dead statement.
>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>

Have you actually encountered this problem?  If migrate_pages() fails
with a positive value, the code that you are removing kicks in and
=2DEBUSY is assigned to ret (now that I look at it, I think that in the
current code the "return ret > 0 ? 0 : ret;" statement could be reduced
to "return ret;").  Your code seems to be cleaner, but the commit
message does not look accurate to me.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4403009..02d4519 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5673,7 +5673,6 @@ static int __alloc_contig_migrate_range(unsigned lo=
ng start, unsigned long end)
>  			}
>  			tries =3D 0;
>  		} else if (++tries =3D=3D 5) {
> -			ret =3D ret < 0 ? ret : -EBUSY;
>  			break;
>  		}
>=20=20
> @@ -5683,7 +5682,7 @@ static int __alloc_contig_migrate_range(unsigned lo=
ng start, unsigned long end)
>  	}
>=20=20
>  	putback_lru_pages(&cc.migratepages);
> -	return ret > 0 ? 0 : ret;
> +	return ret <=3D 0 ? ret : -EBUSY;
>  }
>=20=20
>  /*

=2D-=20
Best regards,                                          _     _
 .o. | Liege of Serenly Enlightened Majesty of       o' \,=3D./ `o
 ..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
 ooo +-<mina86-mina86.com>-<jid:mina86-jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQBFIpAAoJECBgQBJQdR/0Gn4P/0pr6sIB9P2fneQiC+7zj495
09WOd/w9J0HPOg9wAjtXD6+NEDGUq6GywUUXWddB1g6yBbJsvHl+CL4tFkgoCO3Y
p/hwVAh/ouQA+Yhnqnv7E8UnAWgRjQlEB02p3DbNPwJ1kqtz/OhMDm0jNKOSL6rj
TkSYPDtgHABo5UXPrC2LRl5JDfM3Xwnavfxs6c8Ze0hgddsJ/tr2NHRgELy4mS6X
9gj4e7W65L8KBPj2kACI54dm2vbKBZXbqKeJn0rfUCUHDvt7tWDrtXb58uvsNQTS
whfp+TO5ysmk/zf4ENlokijQFs24rvTVk22vV4Joyu2NaelhGvsZ8GOjURyaDp0R
hmBepZDFrGWe5nTu1e3iHIBpyd3CPQ+a2gIxUOZqBEX49+/6qs6WRgOYBeuLIJGB
vveb+Tf52ph7Lx+EPuNHBSnY7dd5Ux+n64znL6wHK4Y8Qf2QMovhZcsq4ERY2xy7
3/KKiXCsKYKihrjIRtcKbYUS33NoGWLCu1+76+kD9zoYFpCHJyT9YmoSwwGAYHx1
A4BSKLiOYVASQWU+nuCunlDJDvzA+J4lsPO7mLXbqT8aeGkZpWmTdXWI+8jCJYDu
Q6mKpzk5uf4mAdAtCd066j9rCYDSKHGYpaAtRlDwF/BxbiPu5r2uy2kUafqWgZDS
xpyxqIZhkty7uZr2ZLxW
=gy2Q
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
