Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E980E6B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 07:40:45 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj10so42601761pad.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:40:45 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0089.outbound.protection.outlook.com. [65.55.169.89])
        by mx.google.com with ESMTPS id t75si50297222pfa.9.2016.03.01.04.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 04:40:44 -0800 (PST)
Date: Tue, 1 Mar 2016 13:40:29 +0100
From: Robert Richter <robert.richter@caviumnetworks.com>
Subject: Re: [PATCH 0/2] arm64, cma, gicv3-its: Use CMA for allocation of
 large device tables
Message-ID: <20160301124029.GV24726@rric.localdomain>
References: <1456398164-16864-1-git-send-email-rrichter@caviumnetworks.com>
 <56D42199.7040207@arm.com>
 <20160229122511.GS24726@rric.localdomain>
 <56D44812.6000309@arm.com>
 <56D4D1A1.9060305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <56D4D1A1.9060305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Tirumalesh Chalamarla <tchalamarla@cavium.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 29.02.16 15:17:53, Laura Abbott wrote:
> On 02/29/2016 05:30 AM, Marc Zyngier wrote:
> >On 29/02/16 12:25, Robert Richter wrote:
> >>On 29.02.16 10:46:49, Marc Zyngier wrote:
> >>>On 25/02/16 11:02, Robert Richter wrote:
> >>>>From: Robert Richter <rrichter@cavium.com>
> >>>>
> >>>>This series implements the use of CMA for allocation of large device
> >>>>tables for the arm64 gicv3 interrupt controller.
> >>>>
> >>>>There are 2 patches, the first is for early activation of cma, which
> >>>>needs to be done before interrupt initialization to make it available
> >>>>to the gicv3. The second implements the use of CMA to allocate
> >>>>gicv3-its device tables.
> >>>>
> >>>>This solves the problem where mem allocation is limited to 4MB. A
> >>>>previous patch sent to the list to address this that instead increases
> >>>>FORCE_MAX_ZONEORDER becomes obsolete.
> >>>
> >>>I think you're looking at the problem the wrong way. Instead of going
> >>>through CMA directly, I'd rather go through the normal DMA API
> >>>(dma_alloc_coherent), which can itself try CMA (should it be enabled).
> >>>
> >>>That will give you all the benefit of the CMA allocation, and also make
> >>>the driver more robust. I meant to do this for a while, and never found
> >>>the time. Any chance you could have a look?
> >>
> >>I was considering this first, and in fact the backend used is the
> >>same. The problem is that irq initialization is much more earlier than
> >>standard device probing. The gic even does not have its own struct
> >>device and is not initialized like devices are. This makes the whole
> >>dma_alloc_coherent() approach not feasable, at least this would
> >>require introducing and using a dev struct for the gic. But still this
> >>migth not work as it could be too early during boot. I also think
> >>there were reasons not implementing the gic as a device.
> >>
> >>I was following more the approach of iommu/mmu implementations which
> >>use dma_alloc_from_contiguous() directly. I think this is more close
> >>to the device tables for its.
> >>
> >>Code path of dma_alloc_coherent():
> >>
> >>  dma_alloc_coherent()
> >>     v
> >>  dma_alloc_attrs()             <---- Requires get_dma_ops(dev) != NULL
> >>     v
> >>  dma_alloc_from_coherent()
> >>     v
> >>  ...
> >>
> >>The difference it that dma_alloc_coherent() tries cma first and then
> >>proceeds with ops->alloc() (which is __dma_alloc() for arm64) if
> >>dma_alloc_from_coherent() fails. In my implementation I am directly
> >>using dma_alloc_from_coherent() and only for large mem sizes.
> >>
> >>So both approaches uses finally the same allocation, but for gicv3-its
> >>the generic dma framework is not used since the gic is not implemented
> >>as a device.
> >
> >And that's what I propose we change.
> >
> >The core GIC itself indeed isn't a device, and I'm not proposing we make
> >it a device (yet). But the ITS is only used much later in the game, and
> >we could move the table allocation to a different time (when the actual
> >domains are allocated, for example...). Then, we'd have a set of devices
> >available, and the DMA API is our friend again.
> >
> >	M.
> >
> 
> I did the first drop of CMA in the DMA APIs for arm64. When adding that,
> it was decided to disallow dma_alloc calls without a valid device pointer
> (c666e8d5cae7 "arm64: Warn on NULL device structure for dma APIs") so
> if the GIC code wants to use dma_alloc it _must_ have a proper device.
> 
> If the device shift still isn't feasible, a better approach might be
> what powerpc did for kvm (arch/powerpc/kvm/book3s_hv_builtin.c). This
> calls the cma_alloc functions directly and skips trying to work around
> the DMA layer.
> 
> With either option, I don't think the early initialization approach
> proposed is great. If we want CMA early, it's probably be just to
> explicitly initialize it early rather than trying to do it from
> two places. Something like:

I wasn't sure whether this works for all archs if called directly in
mm_init(). If so, ok your proposed change would be better, though a
stub for !CONFIG_CMA needs to be added. Any comment on the change
below as a replacement for patch #1?

On the other side, if we use device enablement for its, then early cma
enablement is not needed anymore. Will check how that could work.

-Robert

> 
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 29f9e77..a26712a 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -28,4 +28,5 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
>                                         struct cma **res_cma);
>  extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
>  extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
> +extern int __init cma_init_reserved_areas(void);
>  #endif
> diff --git a/init/main.c b/init/main.c
> index 58c9e37..a92bdb8 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -81,6 +81,7 @@
>  #include <linux/integrity.h>
>  #include <linux/proc_ns.h>
>  #include <linux/io.h>
> +#include <linux/cma.h>
>  #include <asm/io.h>
>  #include <asm/bugs.h>
> @@ -492,6 +493,7 @@ static void __init mm_init(void)
>         pgtable_init();
>         vmalloc_init();
>         ioremap_huge_init();
> +       cma_init_reserved_areas();
>  }
>  asmlinkage __visible void __init start_kernel(void)
> diff --git a/mm/cma.c b/mm/cma.c
> index ea506eb..42278d4 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -142,7 +142,7 @@ err:
>         return -EINVAL;
>  }
> -static int __init cma_init_reserved_areas(void)
> +int __init cma_init_reserved_areas(void)
>  {
>         int i;
> @@ -155,7 +155,6 @@ static int __init cma_init_reserved_areas(void)
>         return 0;
>  }
> -core_initcall(cma_init_reserved_areas);
>  /**
>   * cma_init_reserved_mem() - create custom contiguous area from reserved memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
