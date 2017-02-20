Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 223786B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 11:49:31 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 89so19514301wrr.2
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:49:31 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id s64si13002249wmf.16.2017.02.20.08.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 08:49:29 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id r18so15372973wmd.3
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 08:49:29 -0800 (PST)
Date: Mon, 20 Feb 2017 17:49:26 +0100
From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH 0/8] ARM: sun8i: a33: Mali improvements
Message-ID: <20170220164926.GB15493@ulmo.ba.sec>
References: <10fd28cb-269a-ec38-ecfb-b7c86be3e716@math.uni-bielefeld.de>
 <20170216184524.cxcy2ux37yrwutla@lukather>
 <2cecfc48-576f-3888-08aa-1fe2edc3c752@math.uni-bielefeld.de>
 <20170217154341.vn7uqvdaijtrj64s@lukather>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="jho1yZJdad60DJr+"
Content-Disposition: inline
In-Reply-To: <20170217154341.vn7uqvdaijtrj64s@lukather>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Tobias Jakobi <tjakobi@math.uni-bielefeld.de>, Mark Rutland <mark.rutland@arm.com>, thomas.petazzoni@free-electrons.com, devicetree@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, wens@csie.org, Rob Herring <robh+dt@kernel.org>, linux-arm-kernel@lists.infradead.org


--jho1yZJdad60DJr+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 17, 2017 at 04:43:41PM +0100, Maxime Ripard wrote:
> On Fri, Feb 17, 2017 at 01:45:44PM +0100, Tobias Jakobi wrote:
> > Hello Maxime,
> >=20
> > Maxime Ripard wrote:
> > > Hi,
> > >=20
> > > On Thu, Feb 16, 2017 at 01:43:06PM +0100, Tobias Jakobi wrote:
> > >> I was wondering about the following. Wasn't there some strict
> > >> requirement about code going upstream, which also included that there
> > >> was a full open-source driver stack for it?
> > >>
> > >> I don't see how this is the case for Mali, neither in the kernel, no=
r in
> > >> userspace. I'm aware that the Mali kernel driver is open-source. But=
 it
> > >> is not upstream, maintained out of tree, and won't land upstream in =
its
> > >> current form (no resemblence to a DRM driver at all). And let's not =
talk
> > >> about the userspace part.
> > >>
> > >> So, why should this be here?
> > >=20
> > > The device tree is a representation of the hardware itself. The state
> > > of the driver support doesn't change the hardware you're running on,
> > > just like your BIOS/UEFI on x86 won't change the device it reports to
> > > Linux based on whether it has a driver for it.
> >
> > Like Emil already said, the new bindings and the DT entries are solely
> > introduced to support a proprietary out-of-tree module.
>=20
> No. This new binding and the DT entries are solely introduced to
> describe a device found in a number of SoCs, just like any other DT
> binding we have.
>=20
> > The current workflow when introducing new DT entries is the following:
> > - upstream a driver that uses the entries
> > - THEN add the new entries
>=20
> And that's never been the preferred workflow, for *any* patches.

Actually it has. How else are you going to test that your driver really
works? You've got to have both pieces before you can verify that they're
both adequate. So the typical workflow is to:

	1) define the bindings
	2) write a driver that implements the bindings
	3) add entries to device tree files

Usually it doesn't matter in which order you do the above because they
are all part of the same patch series. But that's not what you're doing
here. The more general problem here is that you're providing device tree
content (and therefore ABI) that's based on a binding which has no
upstream users. So you don't actually have a way of validating that what
you merge is going to be an adequate description.

You're probably going to respond: "but DT describes hardware, so it must
be known already, there won't be a need for changes". Unfortunately that
is only partially true. We've had a number of occasions where it later
turned out that a binding was in fact not an adequate description, and
then we've had to jump through hoops in order to preserve backwards
compatibility. That's already annoying enough if you've got in-tree
users, but it's going to be even more painful if you start out with an
out-of-tree user.

All of that said, you've got an Acked-by from Rob and that's about as
good as it's going to get. So I'm not going to NAK this. But I will
caution against this, because I don't think you're doing yourself any
favours with this.

So perhaps the question that we should ask is this: what do you gain by
merging this series? The fact remains that you don't have an upstream
driver that implements this binding, so ultimately you're going to be
carrying patches in some development tree anyway. Why not simply stash
these patches into the same tree? That should be about the same amount
of work for you and your users, but it has the advantage of not locking
you into something that you may regret.

Thierry

--jho1yZJdad60DJr+
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlirHhQACgkQ3SOs138+
s6FTnw/9EJ9tYw2epzLEyhXBwUGr72cbdpBZTYDphMUMwcHlU4xLXARs6jm/LzRu
GQDgjfki1eh+GwQVFbgnItvTWzIZ061yfczuiHbhJgU8xL8XBNrHgHP4USXLmv/w
s2Csc7o9+oAptoIlcBp9TJbF76gVs00n7y/Oe8tAaZzgWaJ+TJub0un9B/fpwe9w
FZb+j7x0LQyf/I5dfV6LpawM/W69a8zWy2NI9AJJPT5XVFml38GoP03O5XPfHkJY
FAzAFlSgENebLKbRI7bHcBOdvjJXgdmIKUpFm3rqNLpGqjY7YMy2FSjpy89N//u/
vcLgalLeBs41uHLVEiZeCBw/bu9DQIgnEUQ3459PLZdkrWZlGbb6wfv6syF9jg5O
JbyupqxrEF3GBcBcF6Y7hZJaaKpy29Y6udHA302TUrpxdl8Ezodg2UhONWNzDHKK
NGuYNpp7J8TA+r28qjuet0LybpkTc5nHOEw2rRfz6y4YYJJO0IRkw/C7W3wMwF0A
6oBDsi00Tx8bf0iE8alQthbSF2rS3HHtgJzosALNbV6IPPPbTpw6/og4lC/2PKCo
PXODwFqewYxir3hd6IING3VuhbfxAP04ReN1HR0d2jEQA57Ox4ixjdKwgvxCpJSQ
mu4weF/HgANfltzkXWO8C46L3FuzKoNmF9oSYx8QrYjUbFI7r/Y=
=SM/f
-----END PGP SIGNATURE-----

--jho1yZJdad60DJr+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
