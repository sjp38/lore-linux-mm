Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 87A2C6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:25:31 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id ts10so132640072obc.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 04:25:31 -0800 (PST)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0061.outbound.protection.outlook.com. [207.46.100.61])
        by mx.google.com with ESMTPS id i5si21300547obh.19.2016.02.29.04.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Feb 2016 04:25:30 -0800 (PST)
Date: Mon, 29 Feb 2016 13:25:11 +0100
From: Robert Richter <robert.richter@caviumnetworks.com>
Subject: Re: [PATCH 0/2] arm64, cma, gicv3-its: Use CMA for allocation of
 large device tables
Message-ID: <20160229122511.GS24726@rric.localdomain>
References: <1456398164-16864-1-git-send-email-rrichter@caviumnetworks.com>
 <56D42199.7040207@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <56D42199.7040207@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Tirumalesh Chalamarla <tchalamarla@cavium.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 29.02.16 10:46:49, Marc Zyngier wrote:
> On 25/02/16 11:02, Robert Richter wrote:
> > From: Robert Richter <rrichter@cavium.com>
> > 
> > This series implements the use of CMA for allocation of large device
> > tables for the arm64 gicv3 interrupt controller.
> > 
> > There are 2 patches, the first is for early activation of cma, which
> > needs to be done before interrupt initialization to make it available
> > to the gicv3. The second implements the use of CMA to allocate
> > gicv3-its device tables.
> > 
> > This solves the problem where mem allocation is limited to 4MB. A
> > previous patch sent to the list to address this that instead increases
> > FORCE_MAX_ZONEORDER becomes obsolete.
> 
> I think you're looking at the problem the wrong way. Instead of going
> through CMA directly, I'd rather go through the normal DMA API
> (dma_alloc_coherent), which can itself try CMA (should it be enabled).
> 
> That will give you all the benefit of the CMA allocation, and also make
> the driver more robust. I meant to do this for a while, and never found
> the time. Any chance you could have a look?

I was considering this first, and in fact the backend used is the
same. The problem is that irq initialization is much more earlier than
standard device probing. The gic even does not have its own struct
device and is not initialized like devices are. This makes the whole
dma_alloc_coherent() approach not feasable, at least this would
require introducing and using a dev struct for the gic. But still this
migth not work as it could be too early during boot. I also think
there were reasons not implementing the gic as a device.

I was following more the approach of iommu/mmu implementations which
use dma_alloc_from_contiguous() directly. I think this is more close
to the device tables for its.

Code path of dma_alloc_coherent():

 dma_alloc_coherent()
    v
 dma_alloc_attrs()             <---- Requires get_dma_ops(dev) != NULL
    v
 dma_alloc_from_coherent()
    v
 ...

The difference it that dma_alloc_coherent() tries cma first and then
proceeds with ops->alloc() (which is __dma_alloc() for arm64) if
dma_alloc_from_coherent() fails. In my implementation I am directly
using dma_alloc_from_coherent() and only for large mem sizes.

So both approaches uses finally the same allocation, but for gicv3-its
the generic dma framework is not used since the gic is not implemented
as a device.

Does this makes sense to you?

Thanks,

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
