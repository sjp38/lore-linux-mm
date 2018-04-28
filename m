Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA656B0005
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 16:41:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e20so4496211pff.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 13:41:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p73si1436605pfk.275.2018.04.28.13.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 13:41:26 -0700 (PDT)
Date: Sat, 28 Apr 2018 13:41:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180428204118.GA3305@bombadil.infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427161456.GD27853@wotan.suse.de>
 <20180428084221.GD31684@infradead.org>
 <20180428185514.GW27853@wotan.suse.de>
 <alpine.DEB.2.20.1804282145450.2532@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804282145450.2532@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, Christoph Hellwig <hch@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Sat, Apr 28, 2018 at 09:46:52PM +0200, Julia Lawall wrote:
> FWIW, here is my semantic patch and the output - it reports on things that
> appear to be too small and things that it doesn't know about.
> 
> What are the relevant pci wrappers?  I didn't find them.

Basically all of the functions in include/linux/pci-dma-compat.h

> too small: drivers/gpu/drm/i915/i915_drv.c:1138: 30
> too small: drivers/net/wireless/broadcom/b43/dma.c:1068: 30
> unknown: sound/pci/ctxfi/cthw20k2.c:2033: DMA_BIT_MASK(dma_bits)
> unknown: sound/pci/ctxfi/cthw20k2.c:2034: DMA_BIT_MASK(dma_bits)

This one's good:

        const unsigned int dma_bits = BITS_PER_LONG;

> unknown: drivers/scsi/megaraid/megaraid_sas_base.c:6036: consistent_mask

and this one:
        consistent_mask = (instance->adapter_type == VENTURA_SERIES) ?
                                DMA_BIT_MASK(64) : DMA_BIT_MASK(32);

> unknown: drivers/net/wireless/ath/wil6210/txrx.c:200: DMA_BIT_MASK(wil->dma_addr_size)

        if (wil->dma_addr_size > 32)
                dma_set_mask_and_coherent(dev,
                                          DMA_BIT_MASK(wil->dma_addr_size));

> unknown: drivers/net/ethernet/netronome/nfp/nfp_main.c:452: DMA_BIT_MASK(NFP_NET_MAX_DMA_BITS)

drivers/net/ethernet/netronome/nfp/nfp_net.h:#define NFP_NET_MAX_DMA_BITS       40

> unknown: drivers/gpu/host1x/dev.c:199: host->info->dma_mask

Looks safe ...

drivers/gpu/host1x/bus.c:       device->dev.coherent_dma_mask = host1x->dev->coherent_dma_mask;
drivers/gpu/host1x/bus.c:       device->dev.dma_mask = &device->dev.coherent_dma_mask;
drivers/gpu/host1x/dev.c:       .dma_mask = DMA_BIT_MASK(32),
drivers/gpu/host1x/dev.c:       .dma_mask = DMA_BIT_MASK(32),
drivers/gpu/host1x/dev.c:       .dma_mask = DMA_BIT_MASK(34),
drivers/gpu/host1x/dev.c:       .dma_mask = DMA_BIT_MASK(34),
drivers/gpu/host1x/dev.c:       .dma_mask = DMA_BIT_MASK(34),
drivers/gpu/host1x/dev.c:       dma_set_mask_and_coherent(host->dev, host->info->dma_mask);
drivers/gpu/host1x/dev.h:       u64 dma_mask; /* mask of addressable memory */

... but that reminds us that maybe some drivers aren't using dma_set_mask()
but rather touching dma_mask directly.

... 57 more to look at ...
