Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4C486B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 13:53:30 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p21so3826080qke.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 10:53:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si732780qtd.309.2017.07.06.10.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 10:53:29 -0700 (PDT)
Message-ID: <1499363602.26846.3.camel@redhat.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
From: Rik van Riel <riel@redhat.com>
Date: Thu, 06 Jul 2017 13:53:22 -0400
In-Reply-To: <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org>
References: <20170706002718.GA102852@beast>
	 <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org>
	 <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com>
	 <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-TTPbMwPKrIF57ub/jS5Z"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>


--=-TTPbMwPKrIF57ub/jS5Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-07-06 at 10:55 -0500, Christoph Lameter wrote:
> On Thu, 6 Jul 2017, Kees Cook wrote:
>=20
> > On Thu, Jul 6, 2017 at 6:43 AM, Christoph Lameter <cl@linux.com>
> > wrote:
> > > On Wed, 5 Jul 2017, Kees Cook wrote:
> > >=20
> > > > @@ -3536,6 +3565,9 @@ static int kmem_cache_open(struct
> > > > kmem_cache *s, unsigned long flags)
> > > > =C2=A0{
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s->flags =3D kmem_cache_flags(s=
->size, flags, s->name, s-
> > > > >ctor);
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s->reserved =3D 0;
> > > > +#ifdef CONFIG_SLAB_FREELIST_HARDENED
> > > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s->random =3D get_random_long();
> > > > +#endif
> > > >=20
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (need_reserve_slab_rcu && (s=
->flags &
> > > > SLAB_TYPESAFE_BY_RCU))
> > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0s->reserved =3D sizeof(struct rcu_head);
> > > >=20
> > >=20
> > > So if an attacker knows the internal structure of data then he
> > > can simply
> > > dereference page->kmem_cache->random to decode the freepointer.
> >=20
> > That requires a series of arbitrary reads. This is protecting
> > against
> > attacks that use an adjacent slab object write overflow to write
> > the
> > freelist pointer. This internal structure is very reliable, and has
> > been the basis of freelist attacks against the kernel for a decade.
>=20
> These reads are not arbitrary. You can usually calculate the page
> struct
> address easily from the address and then do a couple of loads to get
> there.
>=20
> Ok so you get rid of the old attacks because we did not have that
> hardening in effect when they designed their approaches?

The hardening protects against situations where
people do not have arbitrary code execution and
memory read access in the kernel, with the goal
of protecting people from acquiring those abilities.

> > It is a probabilistic defense, but then so is the stack protector.
> > This is a similar defense; while not perfect it makes the class of
> > attack much more difficult to mount.
>=20
> Na I am not convinced of the "much more difficult". Maybe they will
> just
> have to upgrade their approaches to fetch the proper values to
> decode.

Easier said than done. Most of the time there is an
unpatched vulnerability outstanding, there is only
one known issue, before the kernel is updated by the
user, to a version that does not have that issue.

Bypassing kernel hardening typically requires the
use of multiple vulnerabilities, and the absence of
roadblocks (like hardening) that make a type of
vulnerability exploitable.

Between usercopy hardening, and these slub freelist
canaries (which is what they effectively are), several
classes of exploits are no longer usable.

--=20
All rights reversed
--=-TTPbMwPKrIF57ub/jS5Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZXnkSAAoJEM553pKExN6DoJ8H/246qByk+IS3lx3yY9XFbZ8m
l6ze5e2Dwfa+bYeXu7Q4zgJGr3OGknoZKyBFkVouKI6Fxn3/sZFj8IwfyYOmbH2k
oKDd0CclXQ7Y7FDTVjAgD6cLgfvvpw74aFAcbzVzGWns60t1IIAuf3mSD65DIDsx
uzOdAmm61xuEANV3WU0K6EEy+Va6NOQ6RnBzL+2ne4KKHKkaD7rqWKo001dPHQrQ
HlOufRwLzQIHXO+mtU0hdfqMTcbpHm/Ayx9FEZOtHzHWnwPHCqbX3uE5m47Y8ruW
MybozDSl47riIwVN+58SvcQsBC9qzEwMFxXbd2qLUxvLyg/SGs/yOgwFWAhCF3g=
=cVCF
-----END PGP SIGNATURE-----

--=-TTPbMwPKrIF57ub/jS5Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
