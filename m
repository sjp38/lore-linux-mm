Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4AAF76B0074
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 08:48:45 -0500 (EST)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Wed, 28 Nov 2012 14:48:32 +0100
Subject: [PATCH 1/1] ARM: tegra: bus_notifier registers IOMMU devices(was:
 How to specify IOMMU'able devices in DT)
Message-ID: <20121128.154832.539666140149950229.hdoyu@nvidia.com>
References: <20120924124452.41070ed2ee9944d930cffffc@nvidia.com><054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com><20120924.145014.1452596970914043018.hdoyu@nvidia.com>
In-Reply-To: <20120924.145014.1452596970914043018.hdoyu@nvidia.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "swarren@wwwdotorg.org" <swarren@wwwdotorg.org>, "joro@8bytes.org" <joro@8bytes.org>
Cc: "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "arnd@arndb.de" <arnd@arndb.de>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hiroshi Doyu <hdoyu@nvidia.com> wrote @ Mon, 24 Sep 2012 14:50:14 +0300 (EE=
ST):
...
> > > > On Mon, 2012-09-24 at 12:04 +0300, Hiroshi Doyu wrote:
> > > > > diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> > > > > index a1a7225..9eae3be 100644
> > > > > --- a/drivers/base/platform.c
> > > > > +++ b/drivers/base/platform.c
> > > > > @@ -21,6 +21,8 @@
> > > > >  #include <linux/slab.h>
> > > > >  #include <linux/pm_runtime.h>
> > > > >
> > > > > +#include <asm/dma-iommu.h>
> > > > > +
> > > > >  #include "base.h"
> > > > >
> > > > >  #define to_platform_driver(drv)        (container_of((drv), stru=
ct
> > > > > platform_driver, \
> > > > > @@ -305,8 +307,19 @@ int platform_device_add(struct platform_devi=
ce
> > > > > *pdev)
> > > > >                  dev_name(&pdev->dev), dev_name(pdev->dev.parent)=
);
> > > > >
> > > > >         ret =3D device_add(&pdev->dev);
> > > > > -       if (ret =3D=3D 0)
> > > > > -               return ret;
> > > > > +       if (ret)
> > > > > +               goto failed;
> > > > > +
> > > > > +#ifdef CONFIG_PLATFORM_ENABLE_IOMMU
> > > > > +       if (platform_bus_type.map && !pdev->dev.archdata.mapping)=
 {
> > > > > +               ret =3D arm_iommu_attach_device(&pdev->dev,
> > > > > +                                             platform_bus_type.m=
ap);
> > > > > +               if (ret)
> > > > > +                       goto failed;
> > > >
> > > > This is horrible ... you're adding an architecture specific callbac=
k
> > > > into our generic code; that's really a no-no.  If the concept of
> > > > CONFIG_PLATFORM_ENABE_IOMMU is useful to more than just arm, then t=
his
> > > > could become a generic callback.
> > >=20
> > > As mentioned in the original, this is a heck to explain what is
> > > needed. I am looking for some generic solution for how to specify
> > > IOMMU info for each platform devices. I'm guessing that some other So=
C
> > > may have the similar requirements on the above. As you mentioned, thi=
s
> > > solution should be a generic, not arch specific.
> >=20
> > Please read more about bus notifiers. IMHO a good example is provided i=
n=20
> > the following thread:
> > http://www.mail-archive.com/linux-samsung-soc@vger.kernel.org/msg12238.=
html
>=20
> This bus notifier seems enough flexible to afford the variation of
> IOMMU map info, like Tegra ASID, which could be platform-specific, and
> the other could be common too. There's already iommu_bus_notifier
> too. I'll try to implement something base on this.

Experimentally implemented as below. With the followig patch, each
device could specify its own map in DT, and automatically the device
would be attached to the map.

There is a case that some devices share a map. This patch doesn't
suppor such case yet.
