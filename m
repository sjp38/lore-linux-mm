Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9227E6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:45:54 -0400 (EDT)
Received: by igcau2 with SMTP id au2so3236557igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:45:54 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id t8si282367igz.37.2015.03.26.13.45.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 13:45:54 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so3168322igb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:45:53 -0700 (PDT)
Message-ID: <55146FFF.80809@gmail.com>
Date: Thu, 26 Mar 2015 16:45:51 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com> <20150318153100.5658b741277f3717b52e42d9@linux-foundation.org> <550A5FF8.90504@gmail.com> <CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com> <550E6D9D.1060507@gmail.com> <5512E0C0.6060406@suse.cz> <55131F70.7020503@gmail.com> <alpine.DEB.2.10.1503251710400.31453@chino.kir.corp.google.com> <551351CA.3090803@gmail.com> <alpine.DEB.2.10.1503251914260.16714@chino.kir.corp.google.com> <55137C06.9020608@gmail.com> <5514410C.7090408@suse.cz>
In-Reply-To: <5514410C.7090408@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CXXGB5B0s7ABUfNSFOK4Jx0Xl5vd2XchI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Aliaksey Kandratsenka <alkondratenko@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CXXGB5B0s7ABUfNSFOK4Jx0Xl5vd2XchI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

> Are you sure it's due to page faults and not khugepaged + high value
> (such as the default 511) of max_ptes_none? As reported here?
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D93111
>=20
> Once you have faulted in a THP, and then purged part of it and split it=
,
> I don't think page faults in the purged part can lead to a new THP
> collapse, only khugepaged can do that AFAIK.
> And if you mmap smaller than 2M areas (i.e. your 256K chunks), that
> should prevent THP page faults on the first fault within the chunk as w=
ell.

Hm, that's probably it. The page faults would still be an issue when
reserving ranges on 64-bit for parallel chunk allocation and to make
sure the lowest address chunks are the oldest from the start, which is
likely down the road.

A nice property of 2M chunks is that mremap doesn't need to split huge
pages and neither does purging at the chunk level. I'd expect that to be
a *good thing* rather than something that needs to be avoided due to an
aggressive heuristic.


--CXXGB5B0s7ABUfNSFOK4Jx0Xl5vd2XchI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVFHAAAAoJEPnnEuWa9fIqXJwP/RgybET2Sd1xie/EZsHeHqvZ
yBo3tIlGwKT8JU2aYRRp7sNkqx6W3MWLofQ8Liuz/OPwxF4RhgHL93pJrmLL5Hxi
2XYNMbri9fvTT2e5jkW6QrDdtRg9CC2vW4MmhDW8sCoewFxa1SDXOILAHp9uE0RI
0Yt+S04W/HLS9jjhVRheBoX9aCx5atUQ8dwoHKyaFl+LD+C11etXpWNjj1VVIFdw
Wa+rKnLZT+E/4IPRHYdPzwuacwkovk8Tzw3Ma/PzE14YYeVDHUkowjsrsVxaWB+q
s94irGZZYH9aiF7unhvSZorPvrgxr7Gcl0x/gWb2glUzSvnsTp/ICc3b6dllOkJE
C9aezfij/X0j2vP/A2ZT/5fuQQ2kzZgL5iVBkYbB2sYqobEkJjl4tTRHEj5FqidZ
ezN7a6y4Eyl+vrYbXSDtmr9YdyMkIlphfVtzr4386mhthlmFzXYcTu32XF4Gt8jV
ecfZSd9UzHvgZUDTicSI9oIXuWHwq0TYrtTS1BP0gOij6YTYWRA/mp3z+Cyew6wH
ecUFl0zWtRV1CwBzwIR53Sce2Wi5qnIWGzZoWihkecHToMB4j4XI+OcHT6MAh2NV
rlZ8St8In+dwQoy5ZmhlpCQo9yDIByAdX1mPqWBtD3kE+KM50W4EGxLK/XPzVrIW
TBK7XZXuMvg3mCIi2Gox
=Q199
-----END PGP SIGNATURE-----

--CXXGB5B0s7ABUfNSFOK4Jx0Xl5vd2XchI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
