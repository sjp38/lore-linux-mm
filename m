Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6659D6B005A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 00:50:56 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so55167qcq.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 21:50:55 -0800 (PST)
Message-ID: <50A3313D.1000809@gmail.com>
Date: Wed, 14 Nov 2012 00:50:53 -0500
From: Xi Wang <xi.wang@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: fix null dev in dma_pool_create()
References: <1352097996-25808-1-git-send-email-xi.wang@gmail.com> <50A2BE19.7000604@gmail.com> <20121113165847.4dcf968c.akpm@linux-foundation.org>
In-Reply-To: <20121113165847.4dcf968c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Thomas Dahlmann <dahlmann.thomas@arcor.de>, Felipe Balbi <balbi@ti.com>, Krzysztof Halasa <khc@pm.waw.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 11/13/12 7:58 PM, Andrew Morton wrote:
> I'm not sure that I really suggested doing this :(

You suggested WARN_ON_ONCE(!dev); I changed it to WARN_ON(!dev) and
kept the NULL check..
 
> We know there are a few scruffy drivers which are passing in dev==0.
> 
> Those drivers don't oops because nobody is testing them on NUMA
> systems.
> 
> With this patch, the kernel will now cause runtime warnings to be
> emitted from those drivers.  Even on non-NUMA systems.
> 
> This is a problem!  What will happen is that this code will get
> released by Linus and will propagate to users mainly via distros and
> eventually end-user bug reports will trickle back saying "hey, I got
> this warning".  Slowly people will fix the scruffy drivers and those
> fixes will propagate out from Linus's tree into -stable and then into
> distros and then into the end-users hands.
> 
> This is *terribly* inefficient!  It's a lot of work for a lot of people
> and it involves long delays.
> 
> So let's not do any of that!  Let us try to get those scruffy drivers
> fixed up *before* we add this warning.
> 
> As a nice side-effect of that work, we can then clean up the dmapool
> code so it doesn't need to worry about handling the dev==0 special
> case.
> 
> So.  To start this off, can you please generate a list of the offending
> drivers?  Then we can hunt down the maintainers and we'll see what can be
> done.

I like this plan.

Here's the list of drivers that invoke dma_pool_create() with NULL dev,
as well as possible fixes, from previous emails.

* arch/arm/mach-s3c64xx/dma.c

Use dmac->dev for dma_pool_create() in s3c64xx_dma_init1()?  Probably
need to add ->dma_pool to struct s3c64xx_dmac.

* drivers/usb/gadget/amd5536udc.c (2)

Use dev->gadget.dev or dev->pdev->dev for dma_pool_create()?  Also move
the init_dma_pools() call after the assignments in udc_pci_probe().

* drivers/net/wan/ixp4xx_hss.c
* drivers/net/ethernet/xscale/ixp4xx_eth.c

Use port->netdev->dev for dma_pool_create()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
