Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
References: <20181217202209.GA8859@jordon-HP-15-Notebook-PC> <20181218093754.GI26090@n2100.armlinux.org.uk>
In-Reply-To: <20181218093754.GI26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 18 Dec 2018 18:27:45 +0530
Message-ID: <CAFqt6zbQkFbX57D2kJqZa_gMH7tGzY6FGUJE7Y14kmiiHEv1AA@mail.gmail.com>
Subject: Re: [PATCH v4 2/9] arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: linux-kernel-owner@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 18, 2018 at 3:08 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Tue, Dec 18, 2018 at 01:52:09AM +0530, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > ---
> >  arch/arm/mm/dma-mapping.c | 21 +++++++--------------
> >  1 file changed, 7 insertions(+), 14 deletions(-)
> >
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index 661fe48..7cbcde5 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -1582,31 +1582,24 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
> >                   void *cpu_addr, dma_addr_t dma_addr, size_t size,
> >                   unsigned long attrs)
> >  {
> > -     unsigned long uaddr = vma->vm_start;
> > -     unsigned long usize = vma->vm_end - vma->vm_start;
> > +     unsigned long page_count = vma_pages(vma);
> >       struct page **pages = __iommu_get_pages(cpu_addr, attrs);
> >       unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> >       unsigned long off = vma->vm_pgoff;
> > +     int err;
> >
> >       if (!pages)
> >               return -ENXIO;
> >
> > -     if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
> > +     if (off >= nr_pages)
> >               return -ENXIO;
>
> Are you sure you can make this change?
>
> You are restricting the offset to be within 0..nr_pages which ensures
> that the initial struct page that is passed to vm_insert_range() is
> valid, but I think the removal of the following check is unsafe.
>
> Your new vm_insert_range() function only checks page_count <=
> vma_pages(vma), which it will be since it _is_ vma_pages(vma).  With
> the removal of the second condition, there will be nothing checking
> that (eg) off may be nr_pages - 1, and page_count=50, meaning that
> vm_insert_range() will walk off the end of the page array.
>
> Please take another look at this.

This check shouldn't be removed.
>
> What about the other callsites of your new function - do they have
> the same issue?

I think other callsites don't have the same issue.

>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up
