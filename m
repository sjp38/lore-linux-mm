Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72AA86B5900
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 17:15:46 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k21-v6so15838516qtj.23
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 14:15:46 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id z27-v6si2725784qvc.180.2018.08.31.14.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 14:15:45 -0700 (PDT)
Message-ID: <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
From: Rik van Riel <riel@surriel.com>
Date: Fri, 31 Aug 2018 17:15:39 -0400
In-Reply-To: <20180831203450.2536-1-guro@fb.com>
References: <20180831203450.2536-1-guro@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5zJmtvGhdpjMbqPTGgaf"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>


--=-5zJmtvGhdpjMbqPTGgaf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-08-31 at 13:34 -0700, Roman Gushchin wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fa2c150ab7b9..c910cf6bf606 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -476,6 +476,10 @@ static unsigned long do_shrink_slab(struct
> shrink_control *shrinkctl,
>  	delta =3D freeable >> priority;
>  	delta *=3D 4;
>  	do_div(delta, shrinker->seeks);
> +
> +	if (delta =3D=3D 0 && freeable > 0)
> +		delta =3D min(freeable, batch_size);
> +
>  	total_scan +=3D delta;
>  	if (total_scan < 0) {
>  		pr_err("shrink_slab: %pF negative objects to delete
> nr=3D%ld\n",

I agree that we need to shrink slabs with fewer than
4096 objects, but do we want to put more pressure on
a slab the moment it drops below 4096 than we applied
when it had just over 4096 objects on it?

With this patch, a slab with 5000 objects on it will
get 1 item scanned, while a slab with 4000 objects on
it will see shrinker->batch or SHRINK_BATCH objects
scanned every time.

I don't know if this would cause any issues, just
something to ponder.

If nobody things this is a problem, you can give the
patch my:

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-5zJmtvGhdpjMbqPTGgaf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAluJr/sACgkQznnekoTE
3oORTwgAv23YdpXURejxj0dK5yd07yA/fu6+B4F3wMqsPJOkSoctfZUWvPjVoYaC
cFMh2AzoAg/nCn8hN7uetZKGbjYlLjNuKWAzSPEIn8Nay+H/erpYRKcdemCRHYg5
9CLxaxlFK/lBfuBEwjAvoiizmiuCOm+ZqtBSl5zO3k63TypAD9E8jYHKE02Inr3d
WCwgkh2pUc0h0aSZZK2wmHj5ori86UAyjEBmrPmtPfktUwUqtmhQ8ewilyFVLylE
N54npyirQF1/wxziYyFeaCZibE7vn8fjghAQmXzgJ8wXkd38FUyKUaUH7LT0KDXs
JCzeNs24VoGD/JGH8WyoqOLUtrnQiw==
=W3kT
-----END PGP SIGNATURE-----

--=-5zJmtvGhdpjMbqPTGgaf--
