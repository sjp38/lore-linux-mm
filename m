Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 20F986B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:09:12 -0400 (EDT)
Received: by lahi5 with SMTP id i5so2335729lah.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:09:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
References: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com> <1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 10 May 2012 22:08:39 -0400
Message-ID: <CAP=VYLr=NeGvppR4ONpnRh=gjCSPdKxYj1HYh_FvadAeUzcbBQ@mail.gmail.com>
Subject: Re: [PATCHv9 10/10] ARM: dma-mapping: add support for IOMMU mapper
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, linux-next@vger.kernel.org

On Wed, Apr 18, 2012 at 9:44 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> This patch add a complete implementation of DMA-mapping API for
> devices which have IOMMU support.

Hi Marek,

It looks like this patch breaks no-MMU builds on ARM, at least
according to git bisect.  Here is a link to a linux-next failure:

http://kisskb.ellerman.id.au/kisskb/buildresult/6291233/

arch/arm/mm/dma-mapping.c:726:42: error: 'pgprot_kernel' undeclared
(first use in this function)
make[2]: *** [arch/arm/mm/dma-mapping.o] Error 1

Please have a look, thanks.

Paul.
---


>
> This implementation tries to optimize dma address space usage by remappin=
g
> all possible physical memory chunks into a single dma address space chunk=
.
>
> DMA address space is managed on top of the bitmap stored in the
> dma_iommu_mapping structure stored in device->archdata. Platform setup
> code has to initialize parameters of the dma address space (base address,
> size, allocation precision order) with arm_iommu_create_mapping()
> function.
> To reduce the size of the bitmap, all allocations are aligned to the
> specified order of base 4 KiB pages.
>
> dma_alloc_* functions allocate physical memory in chunks, each with
> alloc_pages() function to avoid failing if the physical memory gets
> fragmented. In worst case the allocated buffer is composed of 4 KiB page
> chunks.
>
> dma_map_sg() function minimizes the total number of dma address space
> chunks by merging of physical memory chunks into one larger dma address
> space chunk. If requested chunk (scatter list entry) boundaries
> match physical page boundaries, most calls to dma_map_sg() requests will
> result in creating only one chunk in dma address space.
>
> dma_map_page() simply creates a mapping for the given page(s) in the dma
> address space.
>
> All dma functions also perform required cache operation like their
> counterparts from the arm linear physical memory mapping version.
>
> This patch contains code and fixes kindly provided by:
> - Krishna Reddy <vdumpa@nvidia.com>,
> - Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
> - Hiroshi DOYU <hdoyu@nvidia.com>
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
> ---
> =A0arch/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +
> =A0arch/arm/include/asm/device.h =A0 =A0| =A0 =A03 +
> =A0arch/arm/include/asm/dma-iommu.h | =A0 34 ++
> =A0arch/arm/mm/dma-mapping.c =A0 =A0 =A0 =A0| =A0727
> +++++++++++++++++++++++++++++++++++++-
> =A0arch/arm/mm/vmregion.h =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A05 files changed, 759 insertions(+), 15 deletions(-)
> =A0create mode 100644 arch/arm/include/asm/dma-iommu.h
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
