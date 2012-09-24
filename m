Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 7C6846B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 07:50:25 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Mon, 24 Sep 2012 13:50:14 +0200
Subject: Re: How to specify IOMMU'able devices in DT
Message-ID: <20120924.145014.1452596970914043018.hdoyu@nvidia.com>
References: <1348478881.2467.27.camel@dabdike><20120924124452.41070ed2ee9944d930cffffc@nvidia.com><054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com>
In-Reply-To: <054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>
Cc: "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "swarren@wwwdotorg.org" <swarren@wwwdotorg.org>, "joerg.roedel@amd.com" <joerg.roedel@amd.com>, "arnd@arndb.de" <arnd@arndb.de>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Marek,

Marek Szyprowski <m.szyprowski@samsung.com> wrote @ Mon, 24 Sep 2012 13:14:=
51 +0200:

> Hello,
>=20
> On Monday, September 24, 2012 11:45 AM Hiroshi Doyu wrote:
>=20
> > On Mon, 24 Sep 2012 11:28:01 +0200
> > James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> >=20
> > > On Mon, 2012-09-24 at 12:04 +0300, Hiroshi Doyu wrote:
> > > > diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> > > > index a1a7225..9eae3be 100644
> > > > --- a/drivers/base/platform.c
> > > > +++ b/drivers/base/platform.c
> > > > @@ -21,6 +21,8 @@
> > > >  #include <linux/slab.h>
> > > >  #include <linux/pm_runtime.h>
> > > >
> > > > +#include <asm/dma-iommu.h>
> > > > +
> > > >  #include "base.h"
> > > >
> > > >  #define to_platform_driver(drv)        (container_of((drv), struct
> > > > platform_driver, \
> > > > @@ -305,8 +307,19 @@ int platform_device_add(struct platform_device
> > > > *pdev)
> > > >                  dev_name(&pdev->dev), dev_name(pdev->dev.parent));
> > > >
> > > >         ret =3D device_add(&pdev->dev);
> > > > -       if (ret =3D=3D 0)
> > > > -               return ret;
> > > > +       if (ret)
> > > > +               goto failed;
> > > > +
> > > > +#ifdef CONFIG_PLATFORM_ENABLE_IOMMU
> > > > +       if (platform_bus_type.map && !pdev->dev.archdata.mapping) {
> > > > +               ret =3D arm_iommu_attach_device(&pdev->dev,
> > > > +                                             platform_bus_type.map=
);
> > > > +               if (ret)
> > > > +                       goto failed;
> > >
> > > This is horrible ... you're adding an architecture specific callback
> > > into our generic code; that's really a no-no.  If the concept of
> > > CONFIG_PLATFORM_ENABE_IOMMU is useful to more than just arm, then thi=
s
> > > could become a generic callback.
> >=20
> > As mentioned in the original, this is a heck to explain what is
> > needed. I am looking for some generic solution for how to specify
> > IOMMU info for each platform devices. I'm guessing that some other SoC
> > may have the similar requirements on the above. As you mentioned, this
> > solution should be a generic, not arch specific.
>=20
> Please read more about bus notifiers. IMHO a good example is provided in=
=20
> the following thread:
> http://www.mail-archive.com/linux-samsung-soc@vger.kernel.org/msg12238.ht=
ml

This bus notifier seems enough flexible to afford the variation of
IOMMU map info, like Tegra ASID, which could be platform-specific, and
the other could be common too. There's already iommu_bus_notifier
too. I'll try to implement something base on this.

Thanks for the good info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
