Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 1A55C6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 05:30:16 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so4289360wey.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:30:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
References: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
Date: Tue, 16 Oct 2012 11:30:14 +0200
Message-ID: <CAKMK7uEuwYG8F=OL6rOrYWWjdmDhA2UZSFTYO7xETi=4DJigLQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] DMA-mapping & IOMMU - physically
 contiguous allocations
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Inki Dae <inki.dae@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Mon, Oct 15, 2012 at 4:03 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> Some devices, which have IOMMU, for some use cases might require to
> allocate a buffers for DMA which is contiguous in physical memory. Such
> use cases appears for example in DRM subsystem when one wants to improve
> performance or use secure buffer protection.
>
> I would like to ask if adding a new attribute, as proposed in this RFC
> is a good idea? I feel that it might be an attribute just for a single
> driver, but I would like to know your opinion. Should we look for other
> solution?

One thing to consider is that up to know all allocation constraints
have been stored somewhere in struct device, either in the dma
attributes (for the more generic stuff) or somewhere in platform
specific data (e.g. for special cma pools). The design of dma_buf
relies on this: The exporter/buffer allocator only sees all the struct
device *devs that want to take part in sharing a given buffer. With
this proposal some of these allocation constraints get moved to alloc
time and aren't visible in the struct device any more. Now I that
dma_buf isn't really there yet and no one has yet implemented a
generic exporter that would allocate the dma_buf at the right spot for
all cases, but I think we should consider this to not draw ourselves
into an ugly api corner.

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
