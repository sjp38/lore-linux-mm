Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7F27B6B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 15:05:52 -0400 (EDT)
From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [Linaro-mm-sig] [PATCH 6/8] drivers: add Contiguous Memory Allocator
Date: Mon, 11 Jul 2011 21:01:17 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <201107091657.07925.jkrzyszt@tis.icnet.pl> <001e01cc3fd1$159f7bf0$40de73d0$%szyprowski@samsung.com>
In-Reply-To: <001e01cc3fd1$159f7bf0$40de73d0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201107112101.18601.jkrzyszt@tis.icnet.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Arnd Bergmann' <arnd@arndb.de>, 'Marin Mitov' <mitov@issp.bas.bg>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Guennadi Liakhovetski' <g.liakhovetski@gmx.de>, linaro-mm-sig@lists.linaro.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Dnia poniedzia=C5=82ek, 11 lipca 2011 o 15:47:32 Marek Szyprowski napisa=C5=
=82(a):
> Hello,
>=20
> On Saturday, July 09, 2011 4:57 PM Janusz Krzysztofik	wrote:
> > On Wed, 6 Jul 2011 at 16:59:45 Arnd Bergmann wrote:
> > > On Wednesday 06 July 2011, Nicolas Pitre wrote:
> > > > On Wed, 6 Jul 2011, Russell King - ARM Linux wrote:
> > > > > Another issue is that when a platform has restricted DMA
> > > > > regions, they typically don't fall into the highmem zone.=20
> > > > > As the dmabounce code allocates from the DMA coherent
> > > > > allocator to provide it with guaranteed DMA-able memory,
> > > > > that would be rather inconvenient.
> > > >=20
> > > > Do we encounter this in practice i.e. do those platforms
> > > > requiring large contiguous allocations motivating this work
> > > > have such DMA restrictions?
> > >=20
> > > You can probably find one or two of those, but we don't have to
> > > optimize for that case. I would at least expect the maximum size
> > > of the allocation to be smaller than the DMA limit for these,
> > > and consequently mandate that they define a sufficiently large
> > > CONSISTENT_DMA_SIZE for the crazy devices, or possibly add a
> > > hack to unmap some low memory and call
> > > dma_declare_coherent_memory() for the device.
> >=20
> > Once found that Russell has dropped his "ARM: DMA: steal memory for
> > DMA coherent mappings" for now, let me get back to this idea of a
> > hack that would allow for safely calling
> > dma_declare_coherent_memory() in order to assign a device with a
> > block of contiguous memory for exclusive use.
>=20
> We tested such approach and finally with 3.0-rc1 it works fine. You
> can find an example for dma_declare_coherent() together with
> required memblock_remove() calls in the following patch series:
> http://www.spinics.net/lists/linux-samsung-soc/msg05026.html
> "[PATCH 0/3 v2] ARM: S5P: Add support for MFC device on S5PV210 and
> EXYNOS4"
>=20
> > Assuming there should be no problem with successfully allocating a
> > large continuous block of coherent memory at boot time with
> > dma_alloc_coherent(), this block could be reserved for the device.
> > The only problem is with the dma_declare_coherent_memory() calling
> > ioremap(), which was designed with a device's dedicated physical
> > memory in mind, but shouldn't be called on a memory already
> > mapped.
>=20
> All these issues with ioremap has been finally resolved in 3.0-rc1.
> Like Russell pointed me in
> http://www.spinics.net/lists/arm-kernel/msg127644.html, ioremap can
> be fixed to work on early reserved memory areas by selecting
> ARCH_HAS_HOLES_MEMORYMODEL Kconfig option.

I'm not sure. Recently I tried to refresh my now 7 months old patch in=20
which I used that 'memblock_remove() then dma_declare_coherent_memery()'=20
method[1]. It was different from your S5P MFC example in that it didn't=20
punch any holes in the system memory, only stole a block of SDRAM from=20
its tail. But Russell reminded me again: "we should not be mapping SDRAM=20
using device mappings."[2]. Would defining ARCH_HAS_HOLES_MEMORYMODEL=20
(even if it was justified) make any diference in my case? I don't think=20
so. Wnat I think, after Russell, is that we still need that obligatory=20
ioremap() removed from dma_declare_coherent_memory(), or made it=20
optional, or a separate dma_declare_coherent_memory()-like function=20
without (obligatory) ioremap() provided by the DMA API, in order to get=20
the dma_declare_coherent_memery() method being accepted without any=20
reservations when used inside arch/arm, I'm afraid.

Thanks,
Janusz

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2010-December/034=
644.html
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2011-June/052488.=
html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
