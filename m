Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 653776B40A6
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 01:44:39 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id l12-v6so5091179ljb.11
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 22:44:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s30sor12215792lfc.1.2018.11.25.22.44.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 22:44:37 -0800 (PST)
MIME-Version: 1.0
References: <20181115154950.GA27985@jordon-HP-15-Notebook-PC>
 <bbad42cb-4a76-a7e7-c385-db77f1cc588b@arm.com> <20181123213448.GW3065@bombadil.infradead.org>
In-Reply-To: <20181123213448.GW3065@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 26 Nov 2018 12:14:22 +0530
Message-ID: <CAFqt6zYmy5SdZY6_1BXFbY2pBQaNd+Z8R71wHEs6nKmxjht07A@mail.gmail.com>
Subject: Re: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: robin.murphy@arm.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, joro@8bytes.org, Linux-MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Sat, Nov 24, 2018 at 3:04 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Nov 23, 2018 at 05:23:06PM +0000, Robin Murphy wrote:
> > On 15/11/2018 15:49, Souptick Joarder wrote:
> > > Convert to use vm_insert_range() to map range of kernel
> > > memory to user vma.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > > ---
> > >   drivers/iommu/dma-iommu.c | 12 ++----------
> > >   1 file changed, 2 insertions(+), 10 deletions(-)
> > >
> > > diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> > > index d1b0475..69c66b1 100644
> > > --- a/drivers/iommu/dma-iommu.c
> > > +++ b/drivers/iommu/dma-iommu.c
> > > @@ -622,17 +622,9 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
> > >   int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
> > >   {
> > > -   unsigned long uaddr = vma->vm_start;
> > > -   unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > > -   int ret = -ENXIO;
> > > +   unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > > -   for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> > > -           ret = vm_insert_page(vma, uaddr, pages[i]);
> > > -           if (ret)
> > > -                   break;
> > > -           uaddr += PAGE_SIZE;
> > > -   }
> > > -   return ret;
> > > +   return vm_insert_range(vma, vma->vm_start, pages, count);
> >
> > AFIACS, vm_insert_range() doesn't respect vma->vm_pgoff, so doesn't this
> > break partial mmap()s of a large buffer? (which I believe can be a thing)
>
> Whoops.  That should have been:
>
> return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff, count);

I am unable to trace back where vma->vm_pgoff is set for this driver ? if any ?
If default value set to 0 then I think existing code is correct.

>
> I suppose.
>

> Although arguably we should respect vm_pgoff inside vm_insert_region()
> and then callers automatically get support for vm_pgoff without having
> to think about it ...

I assume, vm_insert_region() means vm_insert_range(). If we respect vm_pgoff
inside vm_insert_range, for any uninitialized/ error value set for vm_pgoff from
drivers will introduce a bug inside core mm which might be difficult
to trace back.
But when vm_pgoff set and passed from caller (drivers) it might be
easy to figure out.

> although we should then also pass in the length
> of the pages array to avoid pages being mapped in which aren't part of
> the allocated array.

Mostly Partial mapping is done by starting from an index and mapped it till
end of pages array. Calculating length of the pages array will have a small
overhead for each drivers.

Please correct me if I am wrong.
