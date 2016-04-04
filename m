Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2F16B026D
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 17:39:52 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id j35so164293623qge.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 14:39:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s66si7254479qgs.69.2016.04.04.14.39.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 14:39:51 -0700 (PDT)
Message-ID: <1459805987.6219.32.camel@redhat.com>
Subject: Re: [PATCH 2/3] mm: filemap: only do access activations on reads
From: Rik van Riel <riel@redhat.com>
Date: Mon, 04 Apr 2016 17:39:47 -0400
In-Reply-To: <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
	 <1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
	 <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-+aUhSBlSH//uD0f91LF4"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andres Freund <andres@anarazel.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-+aUhSBlSH//uD0f91LF4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-04-04 at 14:22 -0700, Andrew Morton wrote:
> On Mon,=C2=A0=C2=A04 Apr 2016 13:13:37 -0400 Johannes Weiner <hannes@cmpx=
chg.or
> g> wrote:
>=20
> >=20
> > Andres Freund observed that his database workload is struggling
> > with
> > the transaction journal creating pressure on frequently read pages.
> >=20
> > Access patterns like transaction journals frequently write the same
> > pages over and over, but in the majority of cases those pages are
> > never read back. There are no caching benefits to be had for those
> > pages, so activating them and having them put pressure on pages
> > that
> > do benefit from caching is a bad choice.
> Read-after-write is a pretty common pattern: temporary files for
> example.=C2=A0=C2=A0What are the opportunities for regressions here?
>=20
> Did you consider providing userspace with a way to hint "this file is
> probably write-then-not-read"?

I suspect the opportunity for regressions is fairly small,
considering that temporary files usually have a very short
life span, and will likely be read-after-written before they
get evicted from the inactive list.

As for hinting, I suspect it may make sense to differentiate
between whole page and partial page writes, where partial
page writes use FGP_ACCESSED, and whole page writes do not,
under the assumption that if we write a partial page, there
may be a higher chance that other parts of the page get
accessed again for other writes (or reads).

I do not know whether that assumption holds :)

--=20
All Rights Reversed.


--=-+aUhSBlSH//uD0f91LF4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXAt8jAAoJEM553pKExN6D0/UH/0lrnFvOaxMhv6Cp70k05042
57s0Bv19QUPSny7a0Cg+SMFZUDj5QH7TjzSaai0yPvaxY9uI6a7mxeRf+JbnHl8c
S0DTT8l6W5rA30Hu2SZNdRHY8gcSztxkQ8o1viUZqXwYIL439YBKU0w7JsxmvtWO
WL2dpsrWX/O0kX7jTIeOnfdLerF4xm2rWOSoGTpJdFTEd94vfIRMTX5icVbXqIgn
1sh1Npy1dtlcoVzrpSW8eF0CxHw77XnLPWWeCM10sWghtm1z/IV9tc8MDogm1CLy
7Rl6ozbu8FW7rMoOPZa1GRpzVMGW8y8qE2MoJy+ysCj9Wqb/R6gyn/YAMU7ug+E=
=T6PJ
-----END PGP SIGNATURE-----

--=-+aUhSBlSH//uD0f91LF4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
