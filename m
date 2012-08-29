Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A874F6B0068
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 02:55:56 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA more precisely
Date: Wed, 29 Aug 2012 09:55:30 +0300
Message-ID: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: iommu@lists.linux-foundation.org, Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

Hi,

The following APIs are needed for us to support the legacy Tegra
memory manager for devices("NvMap") with *DMA mapping API*.

New API:

 ->iova_alloc(): To allocate IOVA area.
 ->iova_alloc_at(): To allocate IOVA area at specific address.
 ->iova_free():  To free IOVA area.

 ->map_page_at(): To map page at specific IOVA.

misc:
 ->iova_get_free_total(): To return how much IOVA is available totally.
 ->iova_get_free_max():   To return the size of biggest IOVA area.

Although  NvMap itself will be replaced soon, there are cases for the
above API where we need to specify IOVA explicitly.

(1) HWAs may require the address for special purpose, like reset vector.
(2) IOVA linear mapping: ex: [RFC 5/5] ARM: dma-mapping: Introduce
    dma_map_linear_attrs() for IOVA linear map
(3) To support different heaps. To have allocation and mapping
    independently.

Some of them could be supported with creating different mappings, but
currently a device can have a single contiguous mapping, and we cannot
specifiy any address inside of a map since all IOVA alloction is done
implicitly now.

This is the revised version of:

 http://lists.linaro.org/pipermail/linaro-mm-sig/2012-May/001947.html
 http://lists.linaro.org/pipermail/linaro-mm-sig/2012-May/001948.html
 http://lists.linaro.org/pipermail/linaro-mm-sig/2012-May/001949.html

Any comment would be really appreciated.

Hiroshi Doyu (5):
  ARM: dma-mapping: New dma_map_ops->iova_get_free_{total,max}
    functions
  ARM: dma-mapping: New dma_map_ops->iova_{alloc,free}() functions
  ARM: dma-mapping: New dma_map_ops->iova_alloc*_at* function
  ARM: dma-mapping: New dma_map_ops->map_page*_at* function
  ARM: dma-mapping: Introduce dma_map_linear_attrs() for IOVA linear
    map

 arch/arm/include/asm/dma-mapping.h       |   55 +++++++++++++
 arch/arm/mm/dma-mapping.c                |  124 ++++++++++++++++++++++++++++++
 include/asm-generic/dma-mapping-common.h |   20 +++++
 include/linux/dma-mapping.h              |   14 ++++
 4 files changed, 213 insertions(+), 0 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
