Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB5E6B016A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 11:04:27 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <77feea14-0eff-433d-a3af-b1eb973efce8@default>
Date: Tue, 9 Aug 2011 08:03:52 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V6 2/4] mm: frontswap: core code
References: <20110808204615.GA15864@ca-server1.us.oracle.com
 4E41439D0200007800050581@nat28.tlf.novell.com>
In-Reply-To: <4E41439D0200007800050581@nat28.tlf.novell.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@novell.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

> > +#ifndef CONFIG_FRONTSWAP
> > +/* all inline routines become no-ops and all externs are ignored */
> > +#define frontswap_enabled (0)
> > +#endif
> > +
> > +static inline int frontswap_test(struct swap_info_struct *sis, pgoff_t
> > offset)
> > +{
> > +=09int ret =3D 0;
> > +
> > +=09if (frontswap_enabled && sis->frontswap_map)
> > +=09=09ret =3D test_bit(offset % BITS_PER_LONG,
> > +=09=09=09&sis->frontswap_map[offset/BITS_PER_LONG]);
>=20
> =09if (sis->frontswap_map)
> =09=09ret =3D test_bit(offset, sis->frontswap_map);
>=20
> (since sis->frontswap_map can't be non-NULL without
> frontswap_enabled being true, and since test_bit() itself already
> does what you open-coded here.

Hi Jan --

Thanks for the review!

> since test_bit() itself already does what you open-coded here

Good catch.  Will change.  Either is correct and I suspect the
compiler may end up generating the same code, but your code
is much more succinct.

> (since sis->frontswap_map can't be non-NULL without
> frontswap_enabled being true

As noted in the comment immediately preceding, the frontswap_enabled
check serves a second purpose:  When CONFIG_FRONTSWAP is
disabled, this entire inline function devolves to a compile-time
constant (0), which avoids a handful of ifdef's in the
core swap subsystem.  (This approach was originally suggested
for cleancache by Jeremy Fitzhardinge.)

Also, though this patch never unsets frontswap_enabled, it is
a global and some future tmem backend might unset it, so
it's probably best to leave the extra test anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
