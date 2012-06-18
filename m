Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8092E6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 05:03:46 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5T009792I7VPP0@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 18 Jun 2012 18:03:44 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5T00LLM2HPLBB0@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 18 Jun 2012 18:03:43 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
 <20120618105059.12c709d68240ad18c5f8c7a5@nvidia.com>
In-reply-to: <20120618105059.12c709d68240ad18c5f8c7a5@nvidia.com>
Subject: RE: [PATCH/RFC 0/2] ARM: DMA-mapping: new extensions for buffer
 sharing (part 2)
Date: Mon, 18 Jun 2012 11:03:24 +0200
Message-id: <017b01cd4d31$3c855640$b59002c0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Hiroshi Doyu' <hdoyu@nvidia.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Subash Patel' <subash.ramaswamy@linaro.org>, 'Sumit Semwal' <sumit.semwal@linaro.org>, 'Abhinav Kochhar' <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hi,

On Monday, June 18, 2012 9:51 AM Hiroshi Doyu wrote:

> On Wed, 6 Jun 2012 15:17:35 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> 
> > This is a continuation of the dma-mapping extensions posted in the
> > following thread:
> > http://thread.gmane.org/gmane.linux.kernel.mm/78644
> >
> > We noticed that some advanced buffer sharing use cases usually require
> > creating a dma mapping for the same memory buffer for more than one
> > device. Usually also such buffer is never touched with CPU, so the data
> > are processed by the devices.
> >
> > From the DMA-mapping perspective this requires to call one of the
> > dma_map_{page,single,sg} function for the given memory buffer a few
> > times, for each of the devices. Each dma_map_* call performs CPU cache
> > synchronization, what might be a time consuming operation, especially
> > when the buffers are large. We would like to avoid any useless and time
> > consuming operations, so that was the main reason for introducing
> > another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
> > which lets dma-mapping core to skip CPU cache synchronization in certain
> > cases.
> 
> I had implemented the similer patch(*1) to optimize/skip the cache
> maintanace, but we did this with "dir", not with "attr", making use of
> the existing DMA_NONE to skip cache operations. I'm just interested in
> why you choose attr for this purpose. Could you enlight me why attr is
> used here?

I also thought initially about adding new dma direction for this feature,
but then I realized that there might be cases where the real direction of
the data transfer might be needed (for example to set io read/write
attributes for the mappings) and this will lead us to 3 new dma directions.
The second reason was the compatibility with existing code. There are
already drivers which use DMA_NONE type for their internal stuff. Adding
support for new dma attributes requires changes in all implementations of
dma-mapping for all architectures. DMA attributes are imho better fits
this case. They are by default optional, so other architectures are free
to leave them unimplemented and the drivers should still work correctly.
 
Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
