Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8FA6B0311
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:46:14 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i81so7693429qke.6
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:46:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k129si2337938qkb.259.2017.05.03.11.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:46:13 -0700 (PDT)
Message-ID: <1493837167.20270.8.camel@redhat.com>
Subject: Re: [RESENT PATCH] x86/mem: fix the offset overflow when read/write
 mem
From: Rik van Riel <riel@redhat.com>
Date: Wed, 03 May 2017 14:46:07 -0400
In-Reply-To: <alpine.DEB.2.10.1705021350510.116499@chino.kir.corp.google.com>
References: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>
	 <alpine.DEB.2.10.1705021350510.116499@chino.kir.corp.google.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-hoXnknDxDS92K+dTIJiC"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, zhongjiang <zhongjiang@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>, Andrew Morton <akpm@linux-foundation.org>, arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, mgorman@techsingularity.net, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-hoXnknDxDS92K+dTIJiC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-05-02 at 13:54 -0700, David Rientjes wrote:

> > diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> > index 7e4a9d1..3a765e02 100644
> > --- a/drivers/char/mem.c
> > +++ b/drivers/char/mem.c
> > @@ -55,7 +55,7 @@ static inline int
> valid_phys_addr_range(phys_addr_t addr, size_t count)
> >=C2=A0=C2=A0
> >=C2=A0 static inline int valid_mmap_phys_addr_range(unsigned long pfn,
> size_t size)
> >=C2=A0 {
> > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return 1;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return (pfn << PAGE_SHIFT) + size <=3D _=
_pa(high_memory);
> >=C2=A0 }
> >=C2=A0 #endif
> >=C2=A0=C2=A0
>=20
> I suppose you are correct that there should be some sanity checking
> on the=C2=A0
> size used for the mmap().

My apologies for not responding earlier. It may
indeed make sense to have a sanity check here.

However, it is not as easy as simply checking the
end against __pa(high_memory). Some systems have
non-contiguous physical memory ranges, with gaps
of invalid addresses in-between.

You would have to make sure that both the beginning
and the end are valid, and that there are no gaps of
invalid pfns in the middle...

At that point, is the complexity so much that it no
longer makes sense to try to protect against root
crashing the system?

--=20
All rights reversed
--=-hoXnknDxDS92K+dTIJiC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZCiVvAAoJEM553pKExN6DYH8H/0WhU6+eB1BnSdM1Lz8d0VLc
NV1qp0758ix0rrG+EbIBfR8QjpcCaIyjtKv2tu/dnvsk2ugP724HAVjDR1AVvFyA
3nw1O2rXnPxbWMkQn40fEqOIFOmguLGbExzCay28lH4gDIUjmFI1ArxlcMBtHSch
gnWAke3kDSXmat9jswj493a0WG8w1lJwKdBIe3eqYwRL17ErhiDAqD8YBRSZiZAH
3FqAobI3mlopSFM8rMohRB6MTFy0T1g2vZgzj1SFLdOFaOsYrcfy2QEUm5hgj7oE
PFDuzr/06Yv8jzu/yuCZNoz+BSZ3YHXjcbxfameuY7OEIFrlonl05oAUDvKKa6g=
=2Cy0
-----END PGP SIGNATURE-----

--=-hoXnknDxDS92K+dTIJiC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
