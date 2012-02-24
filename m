Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id A9FFA6B00E7
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 07:49:56 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 7/7] ARM: dma-mapping: add support for IOMMU mapper
Date: Fri, 24 Feb 2012 12:49:44 +0000
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com> <401E54CE964CD94BAE1EB4A729C7087E378E42AE18@HQMAIL04.nvidia.com> <00f301ccf2d7$b5b68570$21239050$%szyprowski@samsung.com>
In-Reply-To: <00f301ccf2d7$b5b68570$21239050$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201202241249.44731.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Krishna Reddy' <vdumpa@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>

On Friday 24 February 2012, Marek Szyprowski wrote:
> > > +static struct page **__iommu_alloc_buffer(struct device *dev, size_t
> > > +size, gfp_t gfp) {
> > > +     struct page **pages;
> > > +     int count = size >> PAGE_SHIFT;
> > > +     int i=0;
> > > +
> > > +     pages = kzalloc(count * sizeof(struct page*), gfp);
> > > +     if (!pages)
> > > +             return NULL;
> > 
> > kzalloc can fail for any size bigger than PAGE_SIZE, if the system memory is
> > fully fragmented.
> > If there is a request for size bigger than 4MB, then the pages pointer array won't
> > Fit in one page and kzalloc may fail. we should use vzalloc()/vfree()
> > when pages pointer array size needed is bigger than PAGE_SIZE.
> 
> Right, thanks for spotting this. I will fix this in the next version.

It's not clear though if that is the best solution. vzalloc comes at the
price of using up space in the vmalloc area and as well as extra TLB entries,
so we try to limit its use where possible. The other current code might fail
in out of memory situations, but if a user wants to allocate a >4MB buffer
(using up more than one physically contiguous page of pointers to pages), the
following allocation of >1024 pages will likely fail as well, so we might
just fail early.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
