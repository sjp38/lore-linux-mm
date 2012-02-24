Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 677486B00EC
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 08:18:08 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZW00A9ZFM6HG90@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Feb 2012 13:18:06 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZW00I6XFM5X9@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Feb 2012 13:18:06 +0000 (GMT)
Date: Fri, 24 Feb 2012 14:18:02 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv6 7/7] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <201202241249.44731.arnd@arndb.de>
Message-id: <013301ccf2f6$bc4ad840$34e088c0$%szyprowski@samsung.com>
Content-language: pl
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E378E42AE18@HQMAIL04.nvidia.com>
 <00f301ccf2d7$b5b68570$21239050$%szyprowski@samsung.com>
 <201202241249.44731.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: 'Krishna Reddy' <vdumpa@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>

Hello,

On Friday, February 24, 2012 1:50 PM Arnd Bergmann wrote:

> On Friday 24 February 2012, Marek Szyprowski wrote:
> > > > +static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> > > > +size, gfp_t gfp) {
> > > > +     struct page **pages;
> > > > +     int count = size >> PAGE_SHIFT;
> > > > +     int i=0;
> > > > +
> > > > +     pages = kzalloc(count * sizeof(struct page*), gfp);
> > > > +     if (!pages)
> > > > +             return NULL;
> > >
> > > kzalloc can fail for any size bigger than PAGE_SIZE, if the system memory is
> > > fully fragmented.
> > > If there is a request for size bigger than 4MB, then the pages pointer array won't
> > > Fit in one page and kzalloc may fail. we should use vzalloc()/vfree()
> > > when pages pointer array size needed is bigger than PAGE_SIZE.
> >
> > Right, thanks for spotting this. I will fix this in the next version.
> 
> It's not clear though if that is the best solution. vzalloc comes at the
> price of using up space in the vmalloc area and as well as extra TLB entries,
> so we try to limit its use where possible. The other current code might fail
> in out of memory situations, but if a user wants to allocate a >4MB buffer
> (using up more than one physically contiguous page of pointers to pages), the
> following allocation of >1024 pages will likely fail as well, so we might
> just fail early.

I want to use some kind of chained arrays, each of at most of PAGE_SIZE. This code 
doesn't really need to keep these page pointers in contiguous virtual memory area, so
it will not be a problem here.

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
