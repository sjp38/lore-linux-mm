Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0D8B86B005D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 15:00:01 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so5856669wgb.2
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 12:00:00 -0700 (PDT)
Date: Wed, 13 Jun 2012 21:01:31 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCHv2 0/6] ARM: DMA-mapping: new extensions
 for buffer sharing
Message-ID: <20120613190131.GO4829@phenom.ffwll.local>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
 <20120613141211.GJ5979@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120613141211.GJ5979@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arch@vger.kernel.org, Abhinav Kochhar <abhinav.k@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Subash Patel <subash.ramaswamy@linaro.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Wed, Jun 13, 2012 at 10:12:12AM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Jun 13, 2012 at 01:50:12PM +0200, Marek Szyprowski wrote:
> > Hello,
> > 
> > This is an updated version of the patch series introducing a new
> > features to DMA mapping subsystem to let drivers share the allocated
> > buffers (preferably using recently introduced dma_buf framework) easy
> > and efficient.
> > 
> > The first extension is DMA_ATTR_NO_KERNEL_MAPPING attribute. It is
> > intended for use with dma_{alloc, mmap, free}_attrs functions. It can be
> > used to notify dma-mapping core that the driver will not use kernel
> > mapping for the allocated buffer at all, so the core can skip creating
> > it. This saves precious kernel virtual address space. Such buffer can be
> > accessed from userspace, after calling dma_mmap_attrs() for it (a
> > typical use case for multimedia buffers). The value returned by
> > dma_alloc_attrs() with this attribute should be considered as a DMA
> > cookie, which needs to be passed to dma_mmap_attrs() and
> > dma_free_attrs() funtions.
> > 
> > The second extension is required to let drivers to share the buffers
> > allocated by DMA-mapping subsystem. Right now the driver gets a dma
> > address of the allocated buffer and the kernel virtual mapping for it.
> > If it wants to share it with other device (= map into its dma address
> > space) it usually hacks around kernel virtual addresses to get pointers
> > to pages or assumes that both devices share the DMA address space. Both
> > solutions are just hacks for the special cases, which should be avoided
> > in the final version of buffer sharing. To solve this issue in a generic
> > way, a new call to DMA mapping has been introduced - dma_get_sgtable().
> > It allocates a scatter-list which describes the allocated buffer and
> > lets the driver(s) to use it with other device(s) by calling
> > dma_map_sg() on it.
> 
> What about the cases where the driver wants to share the buffer but there
> are multiple IOMMUs? So the DMA address returned initially would be
> different on the other IOMMUs? Would the driver have to figure this out
> or would the DMA/IOMMU implementation be in charge of that?

You still have to map the allocated sg table into each device address
space, so I think this is all covered. The reason dma-buf specs that the
returned sg list must be mapped into device address space already is to
support special-purpose remapping units that are not handled by the core
dma api.

> And what about IOMMU's that don't do DMA_ATTR_NO_KERNEL_MAPPING?
> Can they just ignore it and do what they did before ? (I presume yes).
> 
> > 
> > The third extension solves the performance issues which we observed with
> > some advanced buffer sharing use cases, which require creating a dma
> > mapping for the same memory buffer for more than one device. From the
> > DMA-mapping perspective this requires to call one of the
> > dma_map_{page,single,sg} function for the given memory buffer a few
> > times, for each of the devices. Each dma_map_* call performs CPU cache
> > synchronization, what might be a time consuming operation, especially
> > when the buffers are large. We would like to avoid any useless and time
> > consuming operations, so that was the main reason for introducing
> > another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
> > which lets dma-mapping core to skip CPU cache synchronization in certain
> > cases.

Ah, here's the use-case I've missed ;-) I'm a bit vary of totally insane
platforms that have additional caches only on the device side, and only
for some devices. Well, tlbs belong to that, but the iommu needs to handle
that anyway.

I think it would be good to add a blurb to the documentation that any
device-side flushing (of tlbs or special caches or whatever) still needs
to happen and that this is only a performance optimization to avoid the
costly cpu cache flushing. This way the dma-buf exporter could keep track
of whether it's 'device-coherent' and set that flag if the cpu caches don't
need to be flushed.

Maybe also make it clear that implementing this bit is optional (like your
doc already mentions for NO_KERNEL_MAPPING).

Yours, Daniel


> > 
> > The proposed patches have been rebased on the latest Linux kernel
> > v3.5-rc2 with 'ARM: replace custom consistent dma region with vmalloc'
> > patches applied (for more information, please refer to the 
> > http://www.spinics.net/lists/arm-kernel/msg179202.html thread).
> > 
> > The patches together with all dependences are also available on the
> > following GIT branch:
> > 
> > git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.5-rc2-dma-ext-v2
> > 
> > Best regards
> > Marek Szyprowski
> > Samsung Poland R&D Center
> > 
> > Changelog:
> > 
> > v2:
> > - rebased onto v3.5-rc2 and adapted for CMA and dma-mapping changes
> > - renamed dma_get_sgtable() to dma_get_sgtable_attrs() to match the convention
> >   of the other dma-mapping calls with attributes
> > - added generic fallback function for dma_get_sgtable() for architectures with
> >   simple dma-mapping implementations
> > 
> > v1: http://thread.gmane.org/gmane.linux.kernel.mm/78644
> >     http://thread.gmane.org/gmane.linux.kernel.cross-arch/14435 (part 2)
> > - initial version
> > 
> > Patch summary:
> > 
> > Marek Szyprowski (6):
> >   common: DMA-mapping: add DMA_ATTR_NO_KERNEL_MAPPING attribute
> >   ARM: dma-mapping: add support for DMA_ATTR_NO_KERNEL_MAPPING
> >     attribute
> >   common: dma-mapping: introduce dma_get_sgtable() function
> >   ARM: dma-mapping: add support for dma_get_sgtable()
> >   common: DMA-mapping: add DMA_ATTR_SKIP_CPU_SYNC attribute
> >   ARM: dma-mapping: add support for DMA_ATTR_SKIP_CPU_SYNC attribute
> > 
> >  Documentation/DMA-attributes.txt         |   42 ++++++++++++++++++
> >  arch/arm/common/dmabounce.c              |    1 +
> >  arch/arm/include/asm/dma-mapping.h       |    3 +
> >  arch/arm/mm/dma-mapping.c                |   69 ++++++++++++++++++++++++------
> >  drivers/base/dma-mapping.c               |   18 ++++++++
> >  include/asm-generic/dma-mapping-common.h |   18 ++++++++
> >  include/linux/dma-attrs.h                |    2 +
> >  include/linux/dma-mapping.h              |    3 +
> >  8 files changed, 142 insertions(+), 14 deletions(-)
> > 
> > -- 
> > 1.7.1.569.g6f426
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig

-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
