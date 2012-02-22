Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 539616B00E7
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 11:27:00 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZS004U8Z0YEH00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:26:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZS00058Z0X0O@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Feb 2012 16:26:58 +0000 (GMT)
Date: Wed, 22 Feb 2012 17:26:43 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv22 13/16] drivers: add Contiguous Memory Allocator
In-reply-to: <alpine.DEB.2.00.1202212121560.962@localhost>
Message-id: <000001ccf17e$c3e50040$4baf00c0$%szyprowski@samsung.com>
Content-language: pl
References: <1329507036-24362-1-git-send-email-m.szyprowski@samsung.com>
 <1329507036-24362-14-git-send-email-m.szyprowski@samsung.com>
 <alpine.DEB.2.00.1202212121560.962@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Aaro Koskinen' <aaro.koskinen@iki.fi>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King' <linux@arm.linux.org.uk>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Benjamin Gaignard' <benjamin.gaignard@linaro.org>, 'Rob Clark' <rob.clark@linaro.org>, 'Ohad Ben-Cohen' <ohad@wizery.com>

Hello,

On Tuesday, February 21, 2012 10:30 PM Aaro Koskinen wrote:

> On Fri, 17 Feb 2012, Marek Szyprowski wrote:
> > +/**
> > + * dma_release_from_contiguous() - release allocated pages
> > + * @dev:   Pointer to device for which the pages were allocated.
> > + * @pages: Allocated pages.
> > + * @count: Number of allocated pages.
> > + *
> > + * This function releases memory allocated by dma_alloc_from_contiguous().
> > + * It returns false when provided pages do not belong to contiguous area and
> > + * true otherwise.
> > + */
> > +bool dma_release_from_contiguous(struct device *dev, struct page *pages,
> > +				 int count)
> > +{
> > +	struct cma *cma = dev_get_cma_area(dev);
> > +	unsigned long pfn;
> > +
> > +	if (!cma || !pages)
> > +		return false;
> > +
> > +	pr_debug("%s(page %p)\n", __func__, (void *)pages);
> > +
> > +	pfn = page_to_pfn(pages);
> > +
> > +	if (pfn < cma->base_pfn || pfn >= cma->base_pfn + cma->count)
> > +		return false;
> > +
> > +	VM_BUG_ON(pfn + count > cma->base_pfn);
> 
> Are you sure the VM_BUG_ON() condition is correct here?

Thanks for pointing this bug. '+ cma->count' is missing in the second part.

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
