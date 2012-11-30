Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B17106B0072
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 03:06:34 -0500 (EST)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Fri, 30 Nov 2012 09:06:25 +0100
Subject: Re: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU devices
Message-ID: <20121130.100625.755725517856599433.hdoyu@nvidia.com>
References: <20120924.145014.1452596970914043018.hdoyu@nvidia.com><20121128.154832.539666140149950229.hdoyu@nvidia.com><50B83D34.2030006@gmail.com>
In-Reply-To: <50B83D34.2030006@gmail.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "nvmarkzhang@gmail.com" <nvmarkzhang@gmail.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "swarren@wwwdotorg.org" <swarren@wwwdotorg.org>, "joro@8bytes.org" <joro@8bytes.org>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "arnd@arndb.de" <arnd@arndb.de>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Mark Zhang <nvmarkzhang@gmail.com> wrote @ Fri, 30 Nov 2012 05:59:32 +0100:

> On 11/28/2012 09:48 PM, Hiroshi Doyu wrote:
> > Hiroshi Doyu <hdoyu@nvidia.com> wrote @ Mon, 24 Sep 2012 14:50:14 +0300=
 (EEST):
> > ...
> >>>>> On Mon, 2012-09-24 at 12:04 +0300, Hiroshi Doyu wrote:
> >>>>>> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> >>>>>> index a1a7225..9eae3be 100644
> >>>>>> --- a/drivers/base/platform.c
> >>>>>> +++ b/drivers/base/platform.c
> >>>>>> @@ -21,6 +21,8 @@
> >>>>>>  #include <linux/slab.h>
> >>>>>>  #include <linux/pm_runtime.h>
> >>>>>>
> >>>>>> +#include <asm/dma-iommu.h>
> >>>>>> +
> >>>>>>  #include "base.h"
> >>>>>>
> >>>>>>  #define to_platform_driver(drv)        (container_of((drv), struc=
t
> >>>>>> platform_driver, \
> >>>>>> @@ -305,8 +307,19 @@ int platform_device_add(struct platform_devic=
e
> >>>>>> *pdev)
> >>>>>>                  dev_name(&pdev->dev), dev_name(pdev->dev.parent))=
;
> >>>>>>
> >>>>>>         ret =3D device_add(&pdev->dev);
> >>>>>> -       if (ret =3D=3D 0)
> >>>>>> -               return ret;
> >>>>>> +       if (ret)
> >>>>>> +               goto failed;
> >>>>>> +
> >>>>>> +#ifdef CONFIG_PLATFORM_ENABLE_IOMMU
> >>>>>> +       if (platform_bus_type.map && !pdev->dev.archdata.mapping) =
{
> >>>>>> +               ret =3D arm_iommu_attach_device(&pdev->dev,
> >>>>>> +                                             platform_bus_type.ma=
p);
> >>>>>> +               if (ret)
> >>>>>> +                       goto failed;
> >>>>>
> >>>>> This is horrible ... you're adding an architecture specific callbac=
k
> >>>>> into our generic code; that's really a no-no.  If the concept of
> >>>>> CONFIG_PLATFORM_ENABE_IOMMU is useful to more than just arm, then t=
his
> >>>>> could become a generic callback.
> >>>>
> >>>> As mentioned in the original, this is a heck to explain what is
> >>>> needed. I am looking for some generic solution for how to specify
> >>>> IOMMU info for each platform devices. I'm guessing that some other S=
oC
> >>>> may have the similar requirements on the above. As you mentioned, th=
is
> >>>> solution should be a generic, not arch specific.
> >>>
> >>> Please read more about bus notifiers. IMHO a good example is provided=
 in=20
> >>> the following thread:
> >>> http://www.mail-archive.com/linux-samsung-soc@vger.kernel.org/msg1223=
8.html
> >>
> >> This bus notifier seems enough flexible to afford the variation of
> >> IOMMU map info, like Tegra ASID, which could be platform-specific, and
> >> the other could be common too. There's already iommu_bus_notifier
> >> too. I'll try to implement something base on this.
> >=20
> > Experimentally implemented as below. With the followig patch, each
> > device could specify its own map in DT, and automatically the device
> > would be attached to the map.
> >=20
> > There is a case that some devices share a map. This patch doesn't
> > suppor such case yet.
> >=20
> > From 8cb75bb6f3a8535a077e0e85265f87c1f1289bfd Mon Sep 17 00:00:00 2001
> > From: Hiroshi Doyu <hdoyu@nvidia.com>
> > Date: Wed, 28 Nov 2012 14:47:04 +0200
> > Subject: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU devices
> >=20
> > platform_bus notifier registers IOMMU devices if dma-window is
> > specified.
> >=20
> > Its format is:
> >   dma-window =3D <"start" "size">;
> > ex)
> >   dma-window =3D <0x12345000 0x8000>;
> >=20
> > Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> > ---
> >  arch/arm/mach-tegra/board-dt-tegra30.c |   40 ++++++++++++++++++++++++=
++++++++
> >  1 file changed, 40 insertions(+)
> >=20
> > diff --git a/arch/arm/mach-tegra/board-dt-tegra30.c b/arch/arm/mach-teg=
ra/board-dt-tegra30.c
> > index a2b6cf1..570d718 100644
> > --- a/arch/arm/mach-tegra/board-dt-tegra30.c
> > +++ b/arch/arm/mach-tegra/board-dt-tegra30.c
> > @@ -30,9 +30,11 @@
> >  #include <linux/of_fdt.h>
> >  #include <linux/of_irq.h>
> >  #include <linux/of_platform.h>
> > +#include <linux/of_iommu.h>
> > =20
> >  #include <asm/mach/arch.h>
> >  #include <asm/hardware/gic.h>
> > +#include <asm/dma-iommu.h>
> > =20
> >  #include "board.h"
> >  #include "clock.h"
> > @@ -86,10 +88,48 @@ static __initdata struct tegra_clk_init_table tegra=
_dt_clk_init_table[] =3D {
> >  	{ NULL,		NULL,		0,		0},
> >  };
> > =20
> > +#ifdef CONFIG_ARM_DMA_USE_IOMMU
> > +static int tegra_iommu_device_notifier(struct notifier_block *nb,
> > +				       unsigned long event, void *_dev)
> > +{
> > +	struct dma_iommu_mapping *map =3D NULL;
> > +	struct device *dev =3D _dev;
> > +	dma_addr_t base;
> > +	size_t size;
> > +	int err;
> > +
> > +	switch (event) {
> > +	case BUS_NOTIFY_ADD_DEVICE:
> > +		err =3D of_get_dma_window(dev->of_node, NULL, 0, NULL, &base,
> > +					&size);
> > +		if (!err)
> > +			map =3D arm_iommu_create_mapping(&platform_bus_type,
> > +						       base, size, 0);
> > +		if (IS_ERR_OR_NULL(map))
> > +			break;
> > +		if (arm_iommu_attach_device(dev, map))
>=20
> Add "arm_iommu_release_mapping" here.

Yes.

> And finally we see this patch, that's great. :)

I'll move the location of patch to drivers/iommu/tegra-smmu.c and repost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
