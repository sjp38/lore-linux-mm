Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8CF336B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 07:15:21 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MAU00K65PWQVD50@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 24 Sep 2012 20:15:20 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MAU006S7PWSLQ80@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 24 Sep 2012 20:15:19 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
 <20120918124918.GK2505@amd.com>
 <20120919095843.d1db155e0f085f4fcf64ea32@nvidia.com>
 <201209190759.46174.arnd@arndb.de> <20120919125020.GQ2505@amd.com>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC1EEB@HQMAIL04.nvidia.com>
 <505A7DB4.4090902@wwwdotorg.org>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC1F2D@HQMAIL04.nvidia.com>
 <505B35F7.2080201@wwwdotorg.org>
 <401E54CE964CD94BAE1EB4A729C7087E379FDC2372@HQMAIL04.nvidia.com>
 <20120924120415.8e6929a34c422185a98d3f82@nvidia.com>
 <1348478881.2467.27.camel@dabdike>
 <20120924124452.41070ed2ee9944d930cffffc@nvidia.com>
In-reply-to: <20120924124452.41070ed2ee9944d930cffffc@nvidia.com>
Subject: RE: How to specify IOMMU'able devices in DT (was: [RFC 0/5] ARM:
 dma-mapping: New dma_map_ops to control IOVA more precisely)
Date: Mon, 24 Sep 2012 13:14:51 +0200
Message-id: <054901cd9a45$db1a7ea0$914f7be0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'James Bottomley' <James.Bottomley@HansenPartnership.com>
Cc: 'Stephen Warren' <swarren@wwwdotorg.org>, 'Joerg Roedel' <joerg.roedel@amd.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Krishna Reddy' <vdumpa@nvidia.com>, linux@arm.linux.org.uk, minchan@kernel.org, chunsang.jeong@linaro.org, linux-kernel@vger.kernel.org, subashrp@gmail.com, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-tegra@vger.kernel.org, kyungmin.park@samsung.com, pullip.cho@samsung.com, linux-arm-kernel@lists.infradead.org

Hello,

On Monday, September 24, 2012 11:45 AM Hiroshi Doyu wrote:

> On Mon, 24 Sep 2012 11:28:01 +0200
> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
> > On Mon, 2012-09-24 at 12:04 +0300, Hiroshi Doyu wrote:
> > > diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> > > index a1a7225..9eae3be 100644
> > > --- a/drivers/base/platform.c
> > > +++ b/drivers/base/platform.c
> > > @@ -21,6 +21,8 @@
> > >  #include <linux/slab.h>
> > >  #include <linux/pm_runtime.h>
> > >
> > > +#include <asm/dma-iommu.h>
> > > +
> > >  #include "base.h"
> > >
> > >  #define to_platform_driver(drv)        (container_of((drv), struct
> > > platform_driver, \
> > > @@ -305,8 +307,19 @@ int platform_device_add(struct platform_device
> > > *pdev)
> > >                  dev_name(&pdev->dev), dev_name(pdev->dev.parent));
> > >
> > >         ret = device_add(&pdev->dev);
> > > -       if (ret == 0)
> > > -               return ret;
> > > +       if (ret)
> > > +               goto failed;
> > > +
> > > +#ifdef CONFIG_PLATFORM_ENABLE_IOMMU
> > > +       if (platform_bus_type.map && !pdev->dev.archdata.mapping) {
> > > +               ret = arm_iommu_attach_device(&pdev->dev,
> > > +                                             platform_bus_type.map);
> > > +               if (ret)
> > > +                       goto failed;
> >
> > This is horrible ... you're adding an architecture specific callback
> > into our generic code; that's really a no-no.  If the concept of
> > CONFIG_PLATFORM_ENABE_IOMMU is useful to more than just arm, then this
> > could become a generic callback.
> 
> As mentioned in the original, this is a heck to explain what is
> needed. I am looking for some generic solution for how to specify
> IOMMU info for each platform devices. I'm guessing that some other SoC
> may have the similar requirements on the above. As you mentioned, this
> solution should be a generic, not arch specific.

Please read more about bus notifiers. IMHO a good example is provided in 
the following thread:
http://www.mail-archive.com/linux-samsung-soc@vger.kernel.org/msg12238.html

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
