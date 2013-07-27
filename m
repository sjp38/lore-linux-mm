Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B16836B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 16:08:17 -0400 (EDT)
From: =?iso-8859-1?q?C=E9dric_Villemain?= <cedric@2ndquadrant.com>
Reply-To: cedric@2ndquadrant.com
Subject: Re: mincore() & fincore()
Date: Sat, 27 Jul 2013 22:08:04 +0200
References: <201307251658.33548.cedric@2ndquadrant.com> <20130725153207.GA17975@cmpxchg.org> <20130726015534.GA24060@hacker.(null)>
In-Reply-To: <20130726015534.GA24060@hacker.(null)>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1443171.0a6rCRdCnC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201307272208.14354.cedric@2ndquadrant.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

--nextPart1443171.0a6rCRdCnC
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> >> Johannes, I add you in CC because you're the last one who proposed
> >> something. Can I update your patch with previous suggestions from
> >> reviewers ?
> >
> >Absolutely!

OK.

> >> I'm also asking for feedback in this area, others ideas are very
> >> welcome.
> >
> >Andrew didn't like the idea of the one byte per covered page
> >representation but all proposals to express continuous ranges in a
>=20
> mincore utilize byte array and the least significant bit is used to
> check if the corresponding page is currently resident in memory, I
> don't know the history, what's the reason for not using bitmap?
>=20
> >more compact fashion had worse worst cases and a much more involved
> >interface.
> >
> >I do wonder if we should model fincore() after mincore() and add a
> >separate syscall to query page cache coverage with statistical output
> >(x present [y dirty, z active, whatever] in specified area) rather
> >than describing individual pages or continuous chunks of pages in
> >address order.  That might leave us with better interfaces than trying
> >to integrate all of this into one arcane syscall.

It should works too. My tool pgfincore (for postgresql) also outputs the nu=
mber=20
of group of contiguous in-memory page, it is to get a quick idea of=20
the access pattern: from large number of groups (random) to few groups=20
(sequential). So for this usage, I don't really need the full vector and pa=
ge=20
level information, but some stats are needed to make those sums useful.

However another usage is to snapshot/restore in-memory pages, it is useful =
in=20
at least 2 scenarios. One for simple server restart, PostgreSQL is back to=
=20
full speed faster when you're able to restore the previous cache content. T=
he=20
other one is similar, switchover to a previously 'cold' server or prepare a=
=20
server to get traffic.
=46or those use-cases, it is interesting to have the details.

=2D-=20
C=E9dric Villemain +33 (0)6 20 30 22 52
http://2ndQuadrant.fr/
PostgreSQL: Support 24x7 - D=E9veloppement, Expertise et Formation

--nextPart1443171.0a6rCRdCnC
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQEcBAABAgAGBQJR9CiuAAoJENsgH0yzVBeb778IAI+fTXtVKqCbgPRMBFWwsfAj
mFPl/w4UknDYd+116Veg+iN4+eBGGxcCOnn4Ep9AJA6m7tHgNMCs7yMlVRS8aY55
5WbWvQ4NsE4kO8XZDPW3ooClHSiLWIDf2XA0A5YIny6EKcy+xZNEFsxHXbwRlNY2
4JwcGQTm/BqNNnvWr78HhNEMrcYCkzjLY679r2T7lxlXDUlaNQO7P5qUPXQt0b2d
byw9TnoBBCo/mTiK/4YwL82l+/hTdj+safCqFl1HjdifFbYAXMpKqdVoq2COBWDq
8NRTINSUGfDFN8CEERElWZIXaH3pl92t3IgnPO1UhcXqbC6VMKLyJERrSB2F3s4=
=kche
-----END PGP SIGNATURE-----

--nextPart1443171.0a6rCRdCnC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
