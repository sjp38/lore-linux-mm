Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 345326B00DC
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 22:57:58 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so177768pad.10
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 19:57:57 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id wk8si1239504pab.59.2014.06.09.19.57.55
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 19:57:57 -0700 (PDT)
Date: Tue, 10 Jun 2014 12:01:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/3] CMA: generalize CMA reserved area management
 functionality
Message-ID: <20140610030141.GC19036@js1304-P5Q-DELUXE>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401757919-30018-2-git-send-email-iamjoonsoo.kim@lge.com>
 <87zjhrtfwm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87zjhrtfwm.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 05, 2014 at 11:09:05PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Currently, there are two users on CMA functionality, one is the DMA
> > subsystem and the other is the kvm on powerpc. They have their own code
> > to manage CMA reserved area even if they looks really similar.
> > From my guess, it is caused by some needs on bitmap management. Kvm side
> > wants to maintain bitmap not for 1 page, but for more size. Eventually it
> > use bitmap where one bit represents 64 pages.
> >
> > When I implement CMA related patches, I should change those two places
> > to apply my change and it seem to be painful to me. I want to change
> > this situation and reduce future code management overhead through
> > this patch.
> >
> > This change could also help developer who want to use CMA in their
> > new feature development, since they can use CMA easily without
> > copying & pasting this reserved area management code.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> 
> The way patches are split makes it difficult to review. Will it be
> possible to make changes against one implementation and them move that
> to generic code. That helps in finding out what exactly changed.
> 

Hello,

You are right! I will respin this patchset as the form you
recommended.

> >
> > diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> > index 00e13ce..b3fe1cc 100644
> > --- a/drivers/base/Kconfig
> > +++ b/drivers/base/Kconfig
> > @@ -283,7 +283,7 @@ config CMA_ALIGNMENT
> >
> >  	  If unsure, leave the default value "8".
> >
> > -config CMA_AREAS
> > +config DMA_CMA_AREAS
> >  	int "Maximum count of the CMA device-private areas"
> >  	default 7
> >  	help
> 
> for ex: The above can be a seperate patch along with further DMA related
> cleanups . 

Okay.

> 
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index 83969f8..48cdac8 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -186,7 +186,7 @@ static int __init cma_activate_area(struct cma *cma)
> >  	return 0;
> >  }
> >
> > -static struct cma cma_areas[MAX_CMA_AREAS];
> > +static struct cma cma_areas[MAX_DMA_CMA_AREAS];
> >  static unsigned cma_area_count;
> >
> >  static int __init cma_init_reserved_areas(void)
> > diff --git a/include/linux/cma.h b/include/linux/cma.h
> > new file mode 100644
> > index 0000000..60ba06f
> > --- /dev/null
> > +++ b/include/linux/cma.h
> > @@ -0,0 +1,28 @@
> > +/*
> > + * Contiguous Memory Allocator
> > + *
> > + * Copyright LG Electronics Inc., 2014
> > + * Written by:
> > + *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License as
> > + * published by the Free Software Foundation; either version 2 of the
> > + * License or (at your optional) any later version of the license.
> > + *
> > + */
> > +
> > +#ifndef __CMA_H__
> > +#define __CMA_H__
> > +
> > +struct cma;
> > +
> > +extern struct page *cma_alloc(struct cma *cma, unsigned long count,
> > +				unsigned long align);
> > +extern bool cma_release(struct cma *cma, struct page *pages,
> > +				unsigned long count);
> > +extern int __init cma_declare_contiguous(phys_addr_t size, phys_addr_t base,
> > +				phys_addr_t limit, phys_addr_t alignment,
> > +				unsigned long bitmap_shift, bool fixed,
> > +				struct cma **res_cma);
> > +#endif
> > diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
> > index 772eab5..dfb1dc9 100644
> > --- a/include/linux/dma-contiguous.h
> > +++ b/include/linux/dma-contiguous.h
> > @@ -63,7 +63,7 @@ struct device;
> >   * There is always at least global CMA area and a few optional device
> >   * private areas configured in kernel .config.
> >   */
> > -#define MAX_CMA_AREAS	(1 + CONFIG_CMA_AREAS)
> > +#define MAX_DMA_CMA_AREAS  (1 + CONFIG_DMA_CMA_AREAS)
> >
> >  extern struct cma *dma_contiguous_default_area;
> >
> > @@ -123,7 +123,7 @@ bool dma_release_from_contiguous(struct device *dev, struct page *pages,
> >
> >  #else
> >
> > -#define MAX_CMA_AREAS	(0)
> > +#define MAX_DMA_CMA_AREAS	(0)
> >
> >  static inline struct cma *dev_get_cma_area(struct device *dev)
> >  {
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 7511b4a..0877ddc 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -515,6 +515,17 @@ config CMA_DEBUG
> >  	  processing calls such as dma_alloc_from_contiguous().
> >  	  This option does not affect warning and error messages.
> >
> > +config CMA_AREAS
> > +	int "Maximum count of the CMA areas"
> > +	depends on CMA
> > +	default 7
> > +	help
> > +	  CMA allows to create CMA areas for particular purpose, mainly,
> > +	  used as device private area. This parameter sets the maximum
> > +	  number of CMA area in the system.
> > +
> > +	  If unsure, leave the default value "7".
> > +
> 
> If we have 7 declare continugous request, a kvm cma allocation request will fail ?

Yes. If you need more, you can increase it. :)

> >  config ZBUD
> >  	tristate
> >  	default n
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 1eaa70b..bc0422b 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> > @@ -62,3 +62,4 @@ obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
> >  obj-$(CONFIG_ZBUD)	+= zbud.o
> >  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
> >  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
> > +obj-$(CONFIG_CMA)	+= cma.o
> > diff --git a/mm/cma.c b/mm/cma.c
> > new file mode 100644
> > index 0000000..0dae88d
> > --- /dev/null
> > +++ b/mm/cma.c
> > @@ -0,0 +1,329 @@
> > +/*
> > + * Contiguous Memory Allocator
> > + *
> > + * Copyright (c) 2010-2011 by Samsung Electronics.
> > + * Copyright IBM Corporation, 2013
> > + * Copyright LG Electronics Inc., 2014
> > + * Written by:
> > + *	Marek Szyprowski <m.szyprowski@samsung.com>
> > + *	Michal Nazarewicz <mina86@mina86.com>
> > + *	Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > + *	Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License as
> > + * published by the Free Software Foundation; either version 2 of the
> > + * License or (at your optional) any later version of the license.
> > + */
> > +
> > +#define pr_fmt(fmt) "cma: " fmt
> > +
> > +#ifdef CONFIG_CMA_DEBUG
> > +#ifndef DEBUG
> > +#  define DEBUG
> > +#endif
> > +#endif
> > +
> > +#include <linux/memblock.h>
> > +#include <linux/err.h>
> > +#include <linux/mm.h>
> > +#include <linux/mutex.h>
> > +#include <linux/sizes.h>
> > +#include <linux/slab.h>
> > +
> > +struct cma {
> > +	unsigned long	base_pfn;
> > +	unsigned long	count;
> > +	unsigned long	*bitmap;
> > +	unsigned long	bitmap_shift;
> 
> I guess this is added to accommodate the kvm specific alloc chunks. May
> be you should do this as a patch against kvm implementation and then
> move the code to generic ?

Yes, this is for kvm specific alloc chunks. I will consider which one
is better for the base implementation and makes patches against it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
