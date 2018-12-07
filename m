Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id EED578E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 15:38:14 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x9-v6so1378429ljd.21
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 12:38:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor1444670lfl.47.2018.12.07.12.38.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 12:38:13 -0800 (PST)
MIME-Version: 1.0
References: <20181206184343.GA30569@jordon-HP-15-Notebook-PC> <d02ad9d7-d0f6-c891-bb7e-fdf6661f651c@arm.com>
In-Reply-To: <d02ad9d7-d0f6-c891-bb7e-fdf6661f651c@arm.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Dec 2018 02:11:49 +0530
Message-ID: <CAFqt6zYF5fFQuGFGss3D1q=jKJGPOD33XLmZiAkBFT9zx_55LA@mail.gmail.com>
Subject: Re: [PATCH v3 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robin.murphy@arm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, joro@8bytes.org, Linux-MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, Dec 7, 2018 at 7:17 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 06/12/2018 18:43, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >   drivers/iommu/dma-iommu.c | 13 +++----------
> >   1 file changed, 3 insertions(+), 10 deletions(-)
> >
> > diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> > index d1b0475..a2c65e2 100644
> > --- a/drivers/iommu/dma-iommu.c
> > +++ b/drivers/iommu/dma-iommu.c
> > @@ -622,17 +622,10 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
> >
> >   int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
> >   {
> > -     unsigned long uaddr = vma->vm_start;
> > -     unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> > -     int ret = -ENXIO;
> > +     unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> >
> > -     for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> > -             ret = vm_insert_page(vma, uaddr, pages[i]);
> > -             if (ret)
> > -                     break;
> > -             uaddr += PAGE_SIZE;
> > -     }
> > -     return ret;
> > +     return vm_insert_range(vma, vma->vm_start,
> > +                             pages + vma->vm_pgoff, count);
>
> You also need to adjust count to compensate for the pages skipped by
> vm_pgoff, otherwise you've got an out-of-bounds dereference triggered
> from userspace, which is pretty high up the "not good" scale (not to
> mention the entire call would then propagate -EFAULT back from
> vm_insert_page() and thus always appear to fail for nonzero offsets).

So this should something similar to ->

        return vm_insert_range(vma, vma->vm_start,
                                pages + vma->vm_pgoff, count - vma->vm_pgoff);
