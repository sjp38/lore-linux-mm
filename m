Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 625C26B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:28:09 -0400 (EDT)
Message-ID: <1348478881.2467.27.camel@dabdike>
Subject: Re: How to specify IOMMU'able devices in DT (was: [RFC 0/5] ARM:
 dma-mapping: New dma_map_ops to control IOVA more precisely)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 24 Sep 2012 13:28:01 +0400
In-Reply-To: <20120924120415.8e6929a34c422185a98d3f82@nvidia.com>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: Stephen Warren <swarren@wwwdotorg.org>, Joerg Roedel <joerg.roedel@amd.com>, Arnd Bergmann <arnd@arndb.de>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, Krishna Reddy <vdumpa@nvidia.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "minchan@kernel.org" <minchan@kernel.org>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "subashrp@gmail.com" <subashrp@gmail.com>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, 2012-09-24 at 12:04 +0300, Hiroshi Doyu wrote:
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index a1a7225..9eae3be 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -21,6 +21,8 @@
>  #include <linux/slab.h>
>  #include <linux/pm_runtime.h>
> 
> +#include <asm/dma-iommu.h>
> +
>  #include "base.h"
> 
>  #define to_platform_driver(drv)        (container_of((drv), struct
> platform_driver, \
> @@ -305,8 +307,19 @@ int platform_device_add(struct platform_device
> *pdev)
>                  dev_name(&pdev->dev), dev_name(pdev->dev.parent));
> 
>         ret = device_add(&pdev->dev);
> -       if (ret == 0)
> -               return ret;
> +       if (ret)
> +               goto failed;
> +
> +#ifdef CONFIG_PLATFORM_ENABLE_IOMMU
> +       if (platform_bus_type.map && !pdev->dev.archdata.mapping) {
> +               ret = arm_iommu_attach_device(&pdev->dev,
> +                                             platform_bus_type.map);
> +               if (ret)
> +                       goto failed;

This is horrible ... you're adding an architecture specific callback
into our generic code; that's really a no-no.  If the concept of
CONFIG_PLATFORM_ENABE_IOMMU is useful to more than just arm, then this
could become a generic callback.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
