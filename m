Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2B346B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 11:07:33 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p29so114496533pgn.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:07:33 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id f12si24848259plm.262.2017.05.24.08.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 08:07:32 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id f27so33272894pfe.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 08:07:32 -0700 (PDT)
Date: Wed, 24 May 2017 23:07:30 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in
 __insert_vmap_area()
Message-ID: <20170524150730.GA8445@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
 <20170524121135.GF14733@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
In-Reply-To: <20170524121135.GF14733@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 24, 2017 at 02:11:35PM +0200, Michal Hocko wrote:
>On Wed 24-05-17 18:03:47, Wei Yang wrote:
>> The vmap RB tree store the elements in order and no overlap between any =
of
>> them. The comparison in __insert_vmap_area() is to decide which direction
>> the search should follow and make sure the new vmap_area is not overlap
>> with any other.
>>=20
>> Current implementation fails to do the overlap check.
>>=20
>> When first "if" is not true, it means
>>=20
>>     va->va_start >=3D tmp_va->va_end
>>=20
>> And with the truth
>>=20
>>     xxx->va_end > xxx->va_start
>>=20
>> The deduction is
>>=20
>>     va->va_end > tmp_va->va_start
>>=20
>> which is the condition in second "if".
>>=20
>> This patch changes a little of the comparison in __insert_vmap_area() to
>> make sure it forbids the overlapped vmap_area.
>
>Why do we care about overlapping vmap areas at this level. This is an
>internal function and all the sanity checks should have been done by
>that time AFAIR. Could you describe the problem which you are trying to
>fix/address?
>

No problem it tries to fix.

I just follow the original idea, which tries to catch the exception case by
the BUG(). While in the above analysis, the BUG() will never be triggered.

So we have two options:
1. Still tries to catch the exception by change the "if" a little.
2. If we don't care about the overlap case, the "if" clause could be
   simplified.  Only "if ... else ..." is enough.

You prefer the second one?

>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/vmalloc.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 0b057628a7ba..8087451cb332 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -360,9 +360,9 @@ static void __insert_vmap_area(struct vmap_area *va)
>> =20
>>  		parent =3D *p;
>>  		tmp_va =3D rb_entry(parent, struct vmap_area, rb_node);
>> -		if (va->va_start < tmp_va->va_end)
>> +		if (va->va_end <=3D tmp_va->va_start)
>>  			p =3D &(*p)->rb_left;
>> -		else if (va->va_end > tmp_va->va_start)
>> +		else if (va->va_start >=3D tmp_va->va_end)
>>  			p =3D &(*p)->rb_right;
>>  		else
>>  			BUG();
>> --=20
>> 2.11.0
>>=20
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZJaGyAAoJEKcLNpZP5cTd7MoP/3SAJEKFvL//jeNOGlS3ySun
07GjBw1jv0qtt4je9Y5P0trBLadYHhk3JgORKiJR3/E3/R0248evGGYbODh56sp4
YUMX5L/3ha6IjlCd8HDxPW47P8nWRfOoKDfDNNIOeBSt2/XUISN4f8KVrB6OtMkH
gBqpdCJxmWtRDHqxzLBrv84+WNarCRP3HA4KB254VA5BNkE1QI5AnGOW0oVqzMiN
HmkqecS0LX/NQoQaisQ+GXn108sdcohOrkp2AZM3n3whSJAyDZ+w68hXl7LmjYBF
MVr8nBs5vC0lzQIkRRum0naWfS4ki3HfDT+zmT8Foqc+z0UOSgCF+qvoy8HcUvIx
AVOYlRa1RyJ8zOqDADlFfeB6pIVivhss1tf8kZj/2optksDivCgTF42+0w3DDem1
SAK22ZHxYXEadrYVuY01bvgqJJAyr0Gps/lcDsXsad7+vwlVQOasgXzwJiBBKZIH
m4HsFwrwPgSJqaKm83XTcSTjfPcjNsq35wo1qCggMqhY+76GXqkrPnbMYWeVLza3
ydqnU/hEAaWeK5fU7s8n6GLDRvc24PbFxoxlXFZ+1YWZwviFwuv7MVJvlTGUQAb2
K8R9NC0oM+xQhf34Heaik3h/NNEhVkDG5RgPnkj9Bp5Dkjltk8XAnZeBhOjOQrDr
DReSpuTPYP/8ybjx4e7z
=8rUC
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
