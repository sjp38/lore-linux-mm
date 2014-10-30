Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC4F90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 09:13:21 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id q107so3914457qgd.0
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 06:13:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t98si12170246qga.109.2014.10.30.06.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 06:13:20 -0700 (PDT)
Message-ID: <5452395C.6030500@redhat.com>
Date: Thu, 30 Oct 2014 09:13:00 -0400
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zram: avoid kunmap_atomic a NULL pointer
References: <000001cff409$bf7bfa50$3e73eef0$%yang@samsung.com>
In-Reply-To: <000001cff409$bf7bfa50$3e73eef0$%yang@samsung.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="aNCk04KK8cB7B5LaiQrSCXbd3MMSeB3rj"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, 'Minchan Kim' <minchan@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Nitin Gupta' <ngupta@vflare.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--aNCk04KK8cB7B5LaiQrSCXbd3MMSeB3rj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/30/2014 02:20 AM, Weijie Yang wrote:
> zram could kunmap_atomic a NULL pointer in a rare situation:
> a zram page become a full-zeroed page after a partial write io.
> The current code doesn't handle this case and kunmap_atomic a
> NULL porinter, which panic the kernel.
>=20
> This patch fixes this issue.
>=20
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  drivers/block/zram/zram_drv.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_dr=
v.c
> index 2ad0b5b..3920ee4 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -560,7 +560,8 @@ static int zram_bvec_write(struct zram *zram, struc=
t bio_vec *bvec, u32 index,
>  	}
> =20
>  	if (page_zero_filled(uncmem)) {
> -		kunmap_atomic(user_mem);
> +		if (user_mem)
> +			kunmap_atomic(user_mem);
>  		/* Free memory associated with this sector now. */
>  		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
>  		zram_free_page(zram, index);
>=20



--aNCk04KK8cB7B5LaiQrSCXbd3MMSeB3rj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUUjlcAAoJEHTzHJCtsuoC0aQIAKvyIPhInikRYcPf6TpYxmxk
N5+v4eP306EGErJ7vwMgPEGZLc/wuWrVxayv9vQZpH9y1T+nPn03NvUT6yvS8Wld
6PrgcdxUlUGqzb3l8KJqOAmTtwElLdmLEnYSnzTGp+QJ7opAKZGZ/l0n+N5dlwtZ
fWY7iVMuSX0xFu5l7+aNiiyTyT2ojqoj9IIjV3qMQnf2tLNKj0GDbSbA9ZSy+Uet
n/EQixaer0+voHyNSUZeyNawgI/EP81AGrd9bOHn5U8+JBI1EuT5YaHSkVR0h9S7
tH9Zsj19wAwdvPMvhQyCD/ez3P/FVvMdrcVejFylDvM7/7aEucvOE/MfysyZDS8=
=bB3h
-----END PGP SIGNATURE-----

--aNCk04KK8cB7B5LaiQrSCXbd3MMSeB3rj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
