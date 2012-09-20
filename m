Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D17396B006C
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 21:45:00 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Wed, 19 Sep 2012 18:44:25 -0700
Subject: RE: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA
 more precisely
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
 <20120918124918.GK2505@amd.com>
 <20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com>
 <201209190759.46174.arnd@arndb.de> <20120919125020.GQ2505@amd.com>
In-Reply-To: <20120919125020.GQ2505@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

> When a device driver would only use the IOMMU-API and needs small DMA-
> able areas it has to re-implement something like the DMA-API (basically a=
n
> address allocator) for that. So I don't see a reason why both can't be us=
ed in a
> device driver.

On Tegra, the following use cases need specific IOVA mapping.
1. Few MMIO blocks need IOVA=3DPA mapping setup.
2. CPU side loads the firmware into physical memory, which has to be
mapped to a specific IOVA address, as  firmware is statically linked based
 on specific IOVA address.=20

DMA api's allow specifying only one address space per platform device.

For #1, DMA API can't be used as it doesn't allow mapping specific IOVA to =
PA.
IOMMU API can be used for mapping specific IOVA to PA. But, in order to use
 IOMMU API, the driver has to  dereference the dev pointer, get domain ptr,
 take lock, and allocate memory from dma_iommu_mapping.  This breaks
 the abstraction for struct device. Each device driver that need IOVA=3DPA =
has to
 do this, which is redundant.

For #2, physical memory allocations alone can be done through DMA as it als=
o=20
allocates IOVA space Implicitly. Even after allocating physical memory thro=
ugh
DMA API's, it would have same problem as #1 for IOVA to PA mapping.

If a fake device is expected to be created for specific IOVA allocation, th=
en it
may  lead to creating multiple fake devices per specific IOVA and per=20
ASID(unique IOVA address space).  As domain init would be done based on
device name, the fake device should have the same name as of original platf=
orm
device.

If DMA API allows allocating specific IOVA address and mapping IOVA to spec=
ific PA,
 device driver don't need to know any details of struct device and specifyi=
ng
 one mapping per device is enough and no  need for fake devices.

Comments are much appreciated.

-KR


> -----Original Message-----
> From: Joerg Roedel [mailto:joerg.roedel@amd.com]
> Sent: Wednesday, September 19, 2012 5:50 AM
> To: Arnd Bergmann
> Cc: Hiroshi Doyu; m.szyprowski@samsung.com; linux@arm.linux.org.uk;
> minchan@kernel.org; chunsang.jeong@linaro.org; linux-
> kernel@vger.kernel.org; subashrp@gmail.com; linaro-mm-sig@lists.linaro.or=
g;
> linux-mm@kvack.org; iommu@lists.linux-foundation.org; Krishna Reddy; linu=
x-
> tegra@vger.kernel.org; kyungmin.park@samsung.com;
> pullip.cho@samsung.com; linux-arm-kernel@lists.infradead.org
> Subject: Re: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA
> more precisely
>=20
> On Wed, Sep 19, 2012 at 07:59:45AM +0000, Arnd Bergmann wrote:
> > On Wednesday 19 September 2012, Hiroshi Doyu wrote:
> > > I guess that it would work. Originally I thought that using DMA-API
> > > and IOMMU-API together in driver might be kind of layering violation
> > > since IOMMU-API itself is used in DMA-API. Only DMA-API used in
> > > driver might be cleaner. Considering that DMA API traditionally
> > > handling anonymous {bus,iova} address only, introducing the concept
> > > of specific address in DMA API may not be so encouraged, though.
> > >
> > > It would be nice to listen how other SoCs have solved similar needs.
> >
> > In general, I would recommend using only the IOMMU API when you have a
> > device driver that needs to control the bus virtual address space and
> > that manages a device that resides in its own IOMMU context. I would
> > recommend using only the dma-mapping API when you have a device that
> > lives in a shared bus virtual address space with other devices, and
> > then never ask for a specific bus virtual address.
> >
> > Can you explain what devices you see that don't fit in one of those
> > two categories?
>=20
> Well, I don't think that a driver should limit to one of these 2 APIs. A =
driver can
> very well use the IOMMU-API during initialization (for example to map the
> firmware to an address the device expects it to be) and use the DMA-API l=
ater
> during normal operation to exchange data with the device.
>=20
> When a device driver would only use the IOMMU-API and needs small DMA-
> able areas it has to re-implement something like the DMA-API (basically a=
n
> address allocator) for that. So I don't see a reason why both can't be us=
ed in a
> device driver.
>=20
> Regards,
>=20
> 	Joerg
>=20
> --
> AMD Operating System Research Center
>=20
> Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach General
> Managers: Alberto Bozzo
> Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr.
> 43632

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
