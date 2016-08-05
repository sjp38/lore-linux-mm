Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0289C6B0253
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:09:08 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so156109516lfe.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:09:07 -0700 (PDT)
Received: from imgpgp01.kl.imgtec.org (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTPS id b189si8312032wmd.92.2016.08.05.03.53.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 03:53:00 -0700 (PDT)
Date: Fri, 5 Aug 2016 11:52:57 +0100
From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [PATCH 03/34] mm, vmscan: move LRU lists to node
Message-ID: <20160805105256.GH19514@jhogan-linux.le.imgtec.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
 <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
 <20160805084115.GO2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="o7gdRJTuwFmWapyH"
Content-Disposition: inline
In-Reply-To: <20160805084115.GO2799@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, metag <linux-metag@vger.kernel.org>

--o7gdRJTuwFmWapyH
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 05, 2016 at 09:41:15AM +0100, Mel Gorman wrote:
> On Thu, Aug 04, 2016 at 09:59:17PM +0100, James Hogan wrote:
> > > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >=20
> > This breaks boot on metag architecture:
> > Oops: err 0007 (Data access general read/write fault) addr 00233008 [#1]
> >=20
> > It appears to be in node_page_state_snapshot() (via
> > pgdat_reclaimable()), and have come via mm_init. Here's the relevant
> > bit of the backtrace:
> >=20
> >     node_page_state_snapshot@0x4009c884(enum node_stat_item item =3D
> > ???, struct pglist_data * pgdat =3D ???) + 0x48
> >     pgdat_reclaimable(struct pglist_data * pgdat =3D 0x402517a0)
> >     show_free_areas(unsigned int filter =3D 0) + 0x2cc
> >     show_mem(unsigned int filter =3D 0) + 0x18
> >     mm_init@0x4025c3d4()
> >     start_kernel() + 0x204
> >=20
> > __per_cpu_offset[0] =3D=3D 0x233000 (close to bad addr),
> > pgdat->per_cpu_nodestats =3D NULL. and setup_per_cpu_pageset()
> > definitely hasn't been called yet (mm_init is called before
> > setup_per_cpu_pageset()).
> >=20
> > Any ideas what the correct solution is (and why presumably others
> > haven't seen the same issue on other architectures?).
> >=20
>=20
> metag calls show_mem in mem_init() before the pagesets are initialised.

Indeed, I didn't spot yesterday evening that this appears to be
different to other arches.

> What's surprising is that it worked for the zone stats as it appears
> that calling zone_reclaimable() from that context should also have
> broken. Did anything change recently that would have avoided the
> zone->pageset dereference in zone_reclaimable() before?

It appears that zone_pcp_init() was already setting zone->pageset to
&boot_pageset, via paging_init():

zone_pcp_init@0x40265d54(struct zone * zone =3D ???)
free_area_init_core@0x40265c18(struct pglist_data * pgdat =3D ???) + 0x138
free_area_init_node(int nid =3D 0, unsigned long * zones_size =3D ???, unsi=
gned long node_start_pfn =3D ???, unsigned long * zholes_size =3D ???) + 0x=
1a0
free_area_init_nodes(unsigned long * max_zone_pfn =3D ???) + 0x440
paging_init(unsigned long mem_end =3D 0x4fe00000) + 0x378
setup_arch(char ** cmdline_p =3D 0x4024e038) + 0x2b8
start_kernel() + 0x54

setup_arch() is called prior to mm_init(), which explains why it wasn't
crashing before.

> The easiest option would be to not call show_mem from arch code until
> after the pagesets are setup.

Since no other arches seem to do show_mem earily during boot like metag,
and doing so doesn't really add much value, I'm happy to remove it
anyway.

However could your change break other things and need fixing anyway?

Thanks!
James

--o7gdRJTuwFmWapyH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXpHAIAAoJEGwLaZPeOHZ6ejsP/2zVPMn7XAabdJU3V+1N9NXu
Hl6obf8BVvlvR0v/7oOwXBUm12WBpszPZTtRMpsiO/SiswdKzC21waKH13q9EUDN
u2GZKep8xGM7Y8ax/PvlEUl/2fE8ScUDSGwnwGTcaFc9ohbED5TeVVsVCz3sq2KF
TCU90z2w0mGo8Avs5DFLPImG6gUwd4irINjPY9nSMzbfdDPKG3lHzvdAOXdbN+1a
0ZRpyrzH3BbqQLB/HVyHxRxRVDYnEqYu5IEdhyakxyW4pcR0SAnkf8Pihw/G+hYM
lXEwEet+7BOJtKlw8hsYuQRo0oytOKcKC9FbaN+XzKPag7oCTukIdNvO57iXjYrr
GNYZDa6Q806NG5y1CC5/R78Y4O2SN0mXxWsjK7blYGPNv6gbj+YluyGJxYtLiLhP
ngJvDpqooBUhJiJlwGrVSoOlYIqGRQKN2SedE8FkdAofazBYwY9AJ2m0X2fr6Ox8
o0i6M/enrR7chNn6C9TXbLGpJHcoYCWrJ3orWSXHCX2mB7yyXx9ZBTjP3HkgDh+E
mZtwKsBMtJTf3eXXSjBnajx0C0SQ2kVk+rDAuNvZR1rdwsWNiShmXdJRJm/8XBWz
x27No+iqfj0Hd6y9Eun/RHUbj5aTf4crxwyDKglPkOybbl7RZg6feRk6hAsA7pfs
QgK+HAduAvPVo7bRTdnT
=TJUm
-----END PGP SIGNATURE-----

--o7gdRJTuwFmWapyH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
