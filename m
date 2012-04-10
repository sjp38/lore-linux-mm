Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B18576B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 08:52:01 -0400 (EDT)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M29008RLL2JGD@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 10 Apr 2012 13:51:55 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M29005VVL2LV1@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 10 Apr 2012 13:51:57 +0100 (BST)
Date: Tue, 10 Apr 2012 14:51:55 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 07/10] ARM: dma-mapping: move all dma bounce code to
 separate dma ops structure
In-reply-to: <201204101224.24959.arnd@arndb.de>
Message-id: <002801cd1718$b556a1e0$2003e5a0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1334055852-19500-1-git-send-email-m.szyprowski@samsung.com>
 <1334055852-19500-8-git-send-email-m.szyprowski@samsung.com>
 <201204101224.24959.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>

Hi Arnd,

On Tuesday, April 10, 2012 2:24 PM Arnd Bergmann wrote:

> On Tuesday 10 April 2012, Marek Szyprowski wrote:
> > This patch removes dma bounce hooks from the common dma mapping
> > implementation on ARM architecture and creates a separate set of
> > dma_map_ops for dma bounce devices.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> 
> I could be misunderstanding something, but it looks like this
> one should come before patch 6, where you remove
> some of the dmabounce functions. Can you clarify?

Before patch no 6, there were custom methods for all scatter/gather
related operations. They iterated over the whole scatter list and called
cache related operations directly (which in turn checked if we use dma
bounce code or not and called respective version). Patch no 6 changed
them not to use such shortcut for direct calling cache related operations.

Instead it provides similar loop over scatter list and calls methods
from the current device's dma_map_ops structure. This way, after patch no 
7 these functions call simple dma_map_page() method for all standard 
devices and dma bounce aware version for devices registered for dma 
bouncing (with use different dma_map_ops).

I can provide a separate set of scatter/gather list related functions for
the linear dma mapping implementation and dma bouncing implementation 
if you think that the current approach is too complicated or 
over-engineered.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
