Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id C651B6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 02:43:29 -0400 (EDT)
Date: Thu, 23 Aug 2012 15:43:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v2 0/4] ARM: dma-mapping: IOMMU atomic allocation
Message-ID: <20120823064357.GD5369@bbox>
References: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345702229-9539-1-git-send-email-hdoyu@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: m.szyprowski@samsung.com, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, pullip.cho@samsung.com

On Thu, Aug 23, 2012 at 09:10:25AM +0300, Hiroshi Doyu wrote:
> Hi,
> 
> The commit e9da6e9 "ARM: dma-mapping: remove custom consistent dma
> region" breaks the compatibility with existing drivers. This causes
> the following kernel oops(*1). That driver has called dma_pool_alloc()
> to allocate memory from the interrupt context, and it hits
> BUG_ON(in_interrpt()) in "get_vm_area_caller()". This patch seris
> fixes this problem with making use of the pre-allocate atomic memory
> pool which DMA is using in the same way as DMA does now.
> 
> Any comment would be really appreciated.
> 
> v2:
> Don't modify attrs(DMA_ATTR_NO_KERNEL_MAPPING) for atomic allocation. (Marek)
> Skip vzalloc (KyongHo, Minchan)

Huh? I would like to correct exactly. I didn't say that kzalloc unify is okay.
As KyongHo said, there are other usecases for allocating big buffer but
I can't agree his opinion that it's system memory shortage if the allocation
fails. Because there are lots of freeable pages(cached page + anon pages
with swap , shrinkable slab and so on). But as I said early, VM can't do
anything except relying on kswapd in atomic context while there are a ton
of freeable pages in system and we can't gaurantee kswapd will do something
for us before seeing the page allocation failure in process context.
Especially, UP is more problem. So, it never indicate system needs more memory.

Atomic high order allocation is very fragile in VM POV
so caller should have fallback mechanism. Otherwise, don't do that.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
