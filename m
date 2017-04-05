Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9B7F6B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 10:40:35 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p68so3829808qke.12
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 07:40:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t11si17935049qtt.272.2017.04.05.07.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 07:40:35 -0700 (PDT)
Message-ID: <1491403231.16856.11.camel@redhat.com>
Subject: Re: [PATCH -mm -v2] mm, swap: Sort swap entries before free
From: Rik van Riel <riel@redhat.com>
Date: Wed, 05 Apr 2017 10:40:31 -0400
In-Reply-To: <20170405071041.24469-1-ying.huang@intel.com>
References: <20170405071041.24469-1-ying.huang@intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-i7pJR9HCuynNWIg7Aev5"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>


--=-i7pJR9HCuynNWIg7Aev5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-04-05 at 15:10 +0800, Huang, Ying wrote:
> To solve the issue, the per-CPU buffer is sorted according to the
> swap
> device before freeing the swap entries.=C2=A0=C2=A0Test shows that the ti=
me
> spent by swapcache_free_entries() could be reduced after the patch.

That makes a lot of sense.

> @@ -1075,6 +1083,8 @@ void swapcache_free_entries(swp_entry_t
> *entries, int n)
> =C2=A0
> =C2=A0	prev =3D NULL;
> =C2=A0	p =3D NULL;
> +	if (nr_swapfiles > 1)
> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp,
> NULL);

But it really wants a comment in the code, so people
reading the code a few years from now can see why
we are sorting things we are about to free.

Maybe something like:
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Sort swap entries by swap device, so each lo=
ck is only taken
once. */

> =C2=A0	for (i =3D 0; i < n; ++i) {
> =C2=A0		p =3D swap_info_get_cont(entries[i], prev);
> =C2=A0		if (p)
--=20
All rights reversed

--=-i7pJR9HCuynNWIg7Aev5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJY5QHfAAoJEM553pKExN6D5QsH/jKVMv3xd9Ur7Hmk0Rwbm9ES
zTZFkmef2Zw6Hnd1JDr/GDVyblEK+mN0xGwB1bw2QrdpeVFGZnxEvf28HMrg6lY0
uR00DuFfCi86JmtZ2jzbTwvopfORb2OO4EwZGbPJL7zWHKhJMd4J1iMcW5afiUIH
9l/d9aQnYw0ZsJfrxKtxCKssleKXvzbAZ8Mun/jH51/W7LFO5GEl7hdBWXlrevZy
exxGOuxwU2KONkvQ2jDSjpASERyDQV3cBvXas4r+eD6h4pJm8xrhaOeilqnxP2NT
Ugpo/qvMhandb2ih+ZNTkKKNrUcb4MrlXPWKrb+q0cl+53Fz8jD0PCwEj74RNHQ=
=82yH
-----END PGP SIGNATURE-----

--=-i7pJR9HCuynNWIg7Aev5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
