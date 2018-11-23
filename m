Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 225E66B32F4
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 16:34:59 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so4738698pgt.11
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 13:34:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e1-v6si56652637ple.148.2018.11.23.13.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Nov 2018 13:34:57 -0800 (PST)
Date: Fri, 23 Nov 2018 13:34:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20181123213448.GW3065@bombadil.infradead.org>
References: <20181115154950.GA27985@jordon-HP-15-Notebook-PC>
 <bbad42cb-4a76-a7e7-c385-db77f1cc588b@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bbad42cb-4a76-a7e7-c385-db77f1cc588b@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, joro@8bytes.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, Nov 23, 2018 at 05:23:06PM +0000, Robin Murphy wrote:
> On 15/11/2018 15:49, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> > 
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >   drivers/iommu/dma-iommu.c | 12 ++----------
> >   1 file changed, 2 insertions(+), 10 deletions(-)
> > 
> > diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> > index d1b0475..69c66b1 100644
> > --- a/drivers/iommu/dma-iommu.c
> > +++ b/drivers/iommu/dma-iommu.c
> > @@ -622,17 +622,9 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
> >   int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
> >   {
> > -	unsigned long uaddr = vma->vm_start;
> > -	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > -	int ret = -ENXIO;
> > +	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > -	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> > -		ret = vm_insert_page(vma, uaddr, pages[i]);
> > -		if (ret)
> > -			break;
> > -		uaddr += PAGE_SIZE;
> > -	}
> > -	return ret;
> > +	return vm_insert_range(vma, vma->vm_start, pages, count);
> 
> AFIACS, vm_insert_range() doesn't respect vma->vm_pgoff, so doesn't this
> break partial mmap()s of a large buffer? (which I believe can be a thing)

Whoops.  That should have been:

return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff, count);

I suppose.

Although arguably we should respect vm_pgoff inside vm_insert_region()
and then callers automatically get support for vm_pgoff without having
to think about it ... although we should then also pass in the length
of the pages array to avoid pages being mapped in which aren't part of
the allocated array.

Hm.  More thought required.
