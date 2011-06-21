Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 36B926B017D
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 07:23:47 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=iso-8859-2
Received: from spt2.w1.samsung.com ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN5002UI0ZJQI60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 21 Jun 2011 12:23:43 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN500F7P0ZI4V@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 21 Jun 2011 12:23:42 +0100 (BST)
Date: Tue, 21 Jun 2011 13:23:35 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent method
 to more generic alloc/free_attrs
In-reply-to: <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
Message-id: <002401cc3005$a941c010$fbc54030$%szyprowski@samsung.com>
Content-language: pl
Content-transfer-encoding: quoted-printable
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
 <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KyongHo Cho' <pullip.cho@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

Hello,

On Monday, June 20, 2011 4:46 PM KyongHo Cho wrote:

> On Mon, Jun 20, 2011 at 4:50 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>=20
> > =A0struct dma_map_ops {
> > - =A0 =A0 =A0 void* (*alloc_coherent)(struct device *dev, size_t =
size,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
dma_addr_t *dma_handle, gfp_t gfp);
> > - =A0 =A0 =A0 void (*free_coherent)(struct device *dev, size_t size,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void =
*vaddr, dma_addr_t dma_handle);
> > + =A0 =A0 =A0 void* (*alloc)(struct device *dev, size_t size,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
dma_addr_t *dma_handle, gfp_t gfp,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
dma_attrs *attrs);
> > + =A0 =A0 =A0 void (*free)(struct device *dev, size_t size,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void =
*vaddr, dma_addr_t dma_handle,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
dma_attrs *attrs);
> > + =A0 =A0 =A0 int (*mmap)(struct device *, struct vm_area_struct *,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *, =
dma_addr_t, size_t, struct dma_attrs
> *attrs);
> > +
> > =A0 =A0 =A0 =A0dma_addr_t (*map_page)(struct device *dev, struct =
page *page,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned =
long offset, size_t size,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum =
dma_data_direction dir,
>=20
> I still don't agree with your idea that change alloc_coherent() with
> alloc().

> As I said before, we actually do not need dma_alloc_writecombine() =
anymore
> because it is not different from dma_alloc_coherent() in ARM.

You already got a reply that dropping dma_alloc_writecombine() is no
go on ARM.

> Most of other architectures do not have dma_alloc_writecombine().

That's not a problem. Once we agree on dma_alloc_attrs(), the drivers
can be changed to use DMA_ATTR_WRITE_COMBINE attribute. If the platform
doesn't support the attribute, it is just ignored. That's the whole
point of the attributes extension. Once a driver is converted to=20
dma_alloc_attrs(), it can be used without any changes either on =
platforms
that supports some specific attributes or the one that doesn't implement
support for any of them.

> If you want dma_alloc_coherent() to allocate user virtual address,
> I believe that it is also available with mmap() you introduced.

Allocation is a separate operation from mapping to userspace. Mmap
operation should just map the buffer (represented by a cookie of type
dma_addr_t) to user address space.

Note that some drivers (like framebuffer drivers for example) also
needs to have both types of mapping - one for user space and one for
kernel virtual space.

Best regards
--=20
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
