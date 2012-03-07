Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B519E6B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 02:16:28 -0500 (EST)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Wed, 7 Mar 2012 08:16:01 +0100
Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <20120307.091601.458605132780655792.hdoyu@nvidia.com>
References: <401E54CE964CD94BAE1EB4A729C7087E37970113FE@HQMAIL04.nvidia.com><20120307.080952.2152478004740487196.hdoyu@nvidia.com><20120307.083706.2087121294965856946.hdoyu@nvidia.com>
In-Reply-To: <20120307.083706.2087121294965856946.hdoyu@nvidia.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, Krishna Reddy <vdumpa@nvidia.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "shariq.hasnain@linaro.org" <shariq.hasnain@linaro.org>, "arnd@arndb.de" <arnd@arndb.de>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "andrzej.p@samsung.com" <andrzej.p@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>

From: Hiroshi DOYU <hdoyu@nvidia.com>
Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Date: Wed, 07 Mar 2012 08:37:06 +0200 (EET)
Message-ID: <20120307.083706.2087121294965856946.hdoyu@nvidia.com>

> From: Hiroshi DOYU <hdoyu@nvidia.com>
> Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
> Date: Wed, 07 Mar 2012 08:09:52 +0200 (EET)
> Message-ID: <20120307.080952.2152478004740487196.hdoyu@nvidia.com>
>=20
> > From: Krishna Reddy <vdumpa@nvidia.com>
> > Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapp=
er
> > Date: Tue, 6 Mar 2012 23:48:42 +0100
> > Message-ID: <401E54CE964CD94BAE1EB4A729C7087E37970113FE@HQMAIL04.nvidia=
.com>
> >=20
> > > > > +struct dma_iommu_mapping *
> > > > > +arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, =
size_t size,
> > > > > +                        int order)
> > > > > +{
> > > > > +       unsigned int count =3D (size >> PAGE_SHIFT) - order;
> > > > > +       unsigned int bitmap_size =3D BITS_TO_LONGS(count) * sizeo=
f(long);
> > >=20
> > > The count calculation doesn't seem correct. "order" is log2 number an=
d
> > >  size >> PAGE_SHIFT is number of pages.=20
> > >=20
> > > If size is passed as 64*4096(256KB) and order is 6(allocation granula=
rity is 2^6 pages=3D256KB),
> > >  just 1 bit is enough to manage allocations.  So it should be 4 bytes=
 or one long.
> >=20
> > Good catch!
> >=20
> > > But the calculation gives count =3D 64 - 6 =3D 58 and=20
> > > Bitmap_size gets set to (58/(4*8)) * 4 =3D 8 bytes, which is incorrec=
t.
> >=20
> > "order" isn't the order of size passed, which is minimal *page*
> > allocation order which client decides whatever, just in case.
> >=20
> > > It should be as follows.
> > > unsigned int count =3D 1 << get_order(size) - order;
>=20
> To be precise, as below?
>=20
>  unsigned int count =3D 1 << (get_order(size) - order);

This could be:
