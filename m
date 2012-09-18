Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id DD8C46B0087
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 08:49:37 -0400 (EDT)
Date: Tue, 18 Sep 2012 14:49:18 +0200
From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [RFC 0/5] ARM: dma-mapping: New dma_map_ops to control IOVA more
 precisely
Message-ID: <20120918124918.GK2505@amd.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: m.szyprowski@samsung.com, linux@arm.linux.org.uk, arnd@arndb.de, minchan@kernel.org, chunsang.jeong@linaro.org, linux-kernel@vger.kernel.org, subashrp@gmail.com, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, vdumpa@nvidia.com, linux-tegra@vger.kernel.org, kyungmin.park@samsung.com, pullip.cho@samsung.com, linux-arm-kernel@lists.infradead.org

On Wed, Aug 29, 2012 at 09:55:30AM +0300, Hiroshi Doyu wrote:
> The following APIs are needed for us to support the legacy Tegra
> memory manager for devices("NvMap") with *DMA mapping API*.

Maybe I am not understanding the need completly. Can you elaborate on
why this is needed for legacy Tegra?

> New API:
> 
>  ->iova_alloc(): To allocate IOVA area.
>  ->iova_alloc_at(): To allocate IOVA area at specific address.
>  ->iova_free():  To free IOVA area.
> 
>  ->map_page_at(): To map page at specific IOVA.

This sounds like a layering violation. The situation today is as
follows:

	DMA-API   : Handle DMA-addresses including an address allocator
	IOMMU-API : Full control over DMA address space, no address
	            allocator

So what you want to do add to the DMA-API is already part of the
IOMMU-API.

Here is my suggestion what you can do instead of extending the DMA-API.
You can use the IOMMU-API to initialize the device address space with
any mappings at the IOVAs you need the mappings. In the end you allocate
another free range in the device address space and use that to satisfy
DMA-API allocations. Any reason why that could not work?


Regards,

	Joerg

-- 
AMD Operating System Research Center

Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach
General Managers: Alberto Bozzo
Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr. 43632

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
