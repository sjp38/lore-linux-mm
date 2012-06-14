Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 666DA6B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:48:10 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5L009N6N45A4U0@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 14 Jun 2012 17:48:08 +0900 (KST)
Received: from AMDC159 ([106.116.37.153])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5L003H6N3SSUA0@mmp2.samsung.com> for linux-mm@kvack.org;
 Thu, 14 Jun 2012 17:48:08 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
 <20120613141211.GJ5979@phenom.dumpdata.com>
 <20120613190131.GO4829@phenom.ffwll.local>
In-reply-to: <20120613190131.GO4829@phenom.ffwll.local>
Subject: RE: [Linaro-mm-sig] [PATCHv2 0/6] ARM: DMA-mapping: new extensions for
 buffer sharing
Date: Thu, 14 Jun 2012 10:47:48 +0200
Message-id: <002901cd4a0a$667e1600$337a4200$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Daniel Vetter' <daniel@ffwll.ch>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org, 'Abhinav Kochhar' <abhinav.k@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, 'Subash Patel' <subash.ramaswamy@linaro.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

Hello,

On Wednesday, June 13, 2012 9:02 PM Daniel Vetter wrote:

> On Wed, Jun 13, 2012 at 10:12:12AM -0400, Konrad Rzeszutek Wilk wrote:
> > On Wed, Jun 13, 2012 at 01:50:12PM +0200, Marek Szyprowski wrote:

> (snipped)

> > > The third extension solves the performance issues which we observed with
> > > some advanced buffer sharing use cases, which require creating a dma
> > > mapping for the same memory buffer for more than one device. From the
> > > DMA-mapping perspective this requires to call one of the
> > > dma_map_{page,single,sg} function for the given memory buffer a few
> > > times, for each of the devices. Each dma_map_* call performs CPU cache
> > > synchronization, what might be a time consuming operation, especially
> > > when the buffers are large. We would like to avoid any useless and time
> > > consuming operations, so that was the main reason for introducing
> > > another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
> > > which lets dma-mapping core to skip CPU cache synchronization in certain
> > > cases.
> 
> Ah, here's the use-case I've missed ;-) I'm a bit vary of totally insane
> platforms that have additional caches only on the device side, and only
> for some devices. Well, tlbs belong to that, but the iommu needs to handle
> that anyway.
> 
> I think it would be good to add a blurb to the documentation that any
> device-side flushing (of tlbs or special caches or whatever) still needs
> to happen and that this is only a performance optimization to avoid the
> costly cpu cache flushing. This way the dma-buf exporter could keep track
> of whether it's 'device-coherent' and set that flag if the cpu caches don't
> need to be flushed.
> 
> Maybe also make it clear that implementing this bit is optional (like your
> doc already mentions for NO_KERNEL_MAPPING).

Ok, I can add additional comment, but support for all dma attributes is optional
(attributes are considered only as hints that might improve performance for some
use cases on some hw platforms).

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
