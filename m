Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 191096B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 15:48:28 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id fl17so1032917vcb.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 12:48:27 -0800 (PST)
Message-ID: <5099779A.8050009@gmail.com>
Date: Tue, 06 Nov 2012 15:48:26 -0500
From: Xi Wang <xi.wang@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix NULL checking in dma_pool_create()
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com> <20121105123738.0a0490a7.akpm@linux-foundation.org> <50982698.7050605@gmail.com> <20121105132651.f52549b6.akpm@linux-foundation.org>
In-Reply-To: <20121105132651.f52549b6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/5/12 4:26 PM, Andrew Morton wrote:
> 
> OK, so it seems that those drivers have never been tested on a
> CONFIG_NUMA kernel.  whee.
> 
> So we have a large amount of code here which ostensibly supports
> dev==NULL but which has not been well tested.  Take a look at
> dma_alloc_coherent(), dma_free_coherent() - are they safe?  Unobvious.

It's probably ok to call dma_alloc_coherent()/dma_free_coherent() with a
NULL dev.  Quite a few drivers do that.

> dmam_pool_destroy() will clearly cause an oops:
> 
> devres_destroy()
> ->devres_remove()
>    ->spin_lock_irqsave(&dev->devres_lock, flags);

Not sure if I missed anything, but I haven't found any use of
dmam_pool_destroy() in the tree..

> I'm thinking we should disallow dev==NULL.  We have a lot of code in
> mm/dmapool.c which _attempts_ to support this case, but is largely
> untested and obviously isn't working.  I don't think it's a good idea
> to try to fix up and then support this case on behalf of a handful of
> scruffy drivers.  It would be better to fix the drivers, then simplify
> the core code.  drivers/usb/gadget/amd5536udc.c can probably use
> dev->gadget.dev and drivers/net/wan/ixp4xx_hss.c can probably use
> port->netdev->dev, etc.

After more search I've still only found 4 files that invoke
dma_pool_create() with a NULL dev.

arch/arm/mach-s3c64xx/dma.c
drivers/usb/gadget/amd5536udc.c
drivers/net/wan/ixp4xx_hss.c
drivers/net/ethernet/xscale/ixp4xx_eth.c

So, yeah, we could fix those drivers instead, such as adding
"WARN_ON_ONCE(dev == NULL)" as you suggested.

- xi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
