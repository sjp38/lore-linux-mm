Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CF3B36B0070
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 13:24:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <89702248-0c3f-465c-bc1f-2115a21c8c89@default>
Date: Fri, 31 Aug 2012 10:23:21 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] frontswap: support exclusive gets if tmem backend is
 capable
References: <5557ec97-daa1-41a6-b3db-671f116ddc50@default>
 <20120831170814.GF18929@localhost.localdomain>
In-Reply-To: <20120831170814.GF18929@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

> From: Konrad Rzeszutek Wilk

Hi Konrad --

Thanks for the fast feedback!

> > +#define FRONTSWAP_HAS_EXCLUSIVE_GETS
> > +extern void frontswap_tmem_exclusive_gets(bool);
>=20
> I don't think you need the #define here..

The #define is used by an ifdef in the backend to ensure
that it is using a version of frontswap that has this feature,
so avoids the need for the frontend (frontswap) and
the backend (e.g. zcache2) to merge in lockstep.

> > +EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
>=20
> We got two of these now - the writethrough and this one. Merging
> them in one function and one flag might be better. So something like:
> static int frontswap_mode =3D 0;
>
> void frontswap_set_mode(int set_mode)
> {
> =09if (mode & (FRONTSWAP_WRITETH | FRONTSWAP_EXCLUS..)
> =09=09mode |=3D set_mode;
> }

IMHO, it's too soon to try to optimize this.  One or
both of these may go away.   Or the mode may become
more fine-grained in the future (e.g. to allow individual
gets to be exclusive).

So unless you object strongly, let's just leave this
as is for now and revisit in the future if more "modes"
are needed.
=20
> ... and
> > +
> > +/*
> >   * Called when a swap device is swapon'd.
> >   */
> >  void __frontswap_init(unsigned type)
> > @@ -174,8 +190,13 @@ int __frontswap_load(struct page *page)
> >  =09BUG_ON(sis =3D=3D NULL);
> >  =09if (frontswap_test(sis, offset))
> >  =09=09ret =3D (*frontswap_ops.load)(type, offset, page);
> > -=09if (ret =3D=3D 0)
> > +=09if (ret =3D=3D 0) {
> >  =09=09inc_frontswap_loads();
> > +=09=09if (frontswap_tmem_exclusive_gets_enabled) {
>=20
> For these perhaps use asm goto for optimization? Is this showing up in
> perf as a hotspot? The asm goto might be a bit too much.

This is definitely not a performance hotspot.  Frontswap code
only is ever executed in situations where a swap-to-disk would
otherwise have occurred.  And in this case, this code only
gets executed after the frontswap_test has confirmed that
tmem does already contain the page of data, in which case
there is thousands of cycles spent copying and/or decompressing.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
