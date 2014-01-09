Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9317C6B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:08:18 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so6379952wib.3
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:08:18 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id r4si896428wjr.86.2014.01.09.01.08.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:08:17 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id y10so5708684wgg.0
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:08:17 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/7] mm/page_alloc: synchronize get/set pageblock
In-Reply-To: <1389251087-10224-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com> <1389251087-10224-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 09 Jan 2014 10:08:10 +0100
Message-ID: <xa1teh4hbk05.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 09 2014, Joonsoo Kim wrote:
> @@ -5927,15 +5928,19 @@ unsigned long get_pageblock_flags_group(struct pa=
ge *page,
>  	unsigned long pfn, bitidx;
>  	unsigned long flags =3D 0;
>  	unsigned long value =3D 1;
> +	unsigned int seq;
>=20=20
>  	zone =3D page_zone(page);
>  	pfn =3D page_to_pfn(page);
>  	bitmap =3D get_pageblock_bitmap(zone, pfn);
>  	bitidx =3D pfn_to_bitidx(zone, pfn);
>=20=20
> -	for (; start_bitidx <=3D end_bitidx; start_bitidx++, value <<=3D 1)
> -		if (test_bit(bitidx + start_bitidx, bitmap))
> -			flags |=3D value;
> +	do {

+		flags =3D 0;

> +		seq =3D read_seqbegin(&zone->pageblock_seqlock);
> +		for (; start_bitidx <=3D end_bitidx; start_bitidx++, value <<=3D 1)
> +			if (test_bit(bitidx + start_bitidx, bitmap))
> +				flags |=3D value;
> +	} while (read_seqretry(&zone->pageblock_seqlock, seq));
>=20=20
>  	return flags;
>  }

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

iQIcBAEBAgAGBQJSzmb6AAoJECBgQBJQdR/0Ew4P/RsSxW22DyEt524wSIwWSYKS
aOVMs2Qv/t5xtuW5wHh1rjxmAAIEoZItYYsYaBHr1tbY0X1Uw0OwcZz6DcKBERlm
hSiAHVbg3K62V4LTq0Dj8QXzEgzQvXh9T8Kvin6QBzZIRHWHTHQZweHyPMDCy5Ny
4ATCcT8qEvzCTjq584TC1fYPJgG0X+ZjgTpxNdPzFBVXXrZwTrt7DRrlrVQCtdYb
3OQktscAGv4HlImUJQWRn2pn61eKqoJk4/OcmHQX5EHet2QUZ6Bp0nwy/V2Spyis
i1+e4OFc245eMTitDeNR6duI7K/n4IOmgsTePmj7C8uVp1XqdToW2Oic9BxN3td6
4NUw8pIz+f6Fj3BMxYPD5rvBXMAeZ9lxctXT/NTy2EYVWQvVeVN4NApj/WJZ9lD8
lVxb1f8relKG3xdj73juDaZUg9w/fV3b2fuJAKiybEYa5g23Rm5Xk5elZzT8NZKy
K5pGBsm18Chr1IZewBfQlVP/MR/M2LO2Dar3q2cTNo+VQJA3a11+gzd9u18hog+m
BCn4wazugDfhwLIpMNvKPQJbwKgbTRsrzbibSYt6kRUr6DL86Gh6IYcu0PwUivJK
t+x1yYttyZQAgRxosxkTGxMbqyOXEwo7ux56E1VCHQv9yPfEia9KHv1SiBp12HGT
D7vD5QTb9GkAlUDykK0o
=mRRG
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
