Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4346B07CA
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:30:46 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id x69so5686555lff.0
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 21:30:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z26sor7411388lfe.67.2018.11.15.21.30.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 21:30:44 -0800 (PST)
MIME-Version: 1.0
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC> <9655a12e-bd3d-aca2-6155-38924028eb5d@infradead.org>
In-Reply-To: <9655a12e-bd3d-aca2-6155-38924028eb5d@infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 16 Nov 2018 11:00:30 +0530
Message-ID: <CAFqt6zbLjtDab3Bz67trbnQRQdutvgA=YvAFhoW4bxsg657mGQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Thu, Nov 15, 2018 at 11:44 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 11/15/18 7:45 AM, Souptick Joarder wrote:
> > Previouly drivers have their own way of mapping range of
> > kernel pages/memory into user vma and this was done by
> > invoking vm_insert_page() within a loop.
> >
> > As this pattern is common across different drivers, it can
> > be generalized by creating a new function and use it across
> > the drivers.
> >
> > vm_insert_range is the new API which will be used to map a
> > range of kernel memory/pages to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >  include/linux/mm_types.h |  3 +++
> >  mm/memory.c              | 28 ++++++++++++++++++++++++++++
> >  mm/nommu.c               |  7 +++++++
> >  3 files changed, 38 insertions(+)
>
> Hi,
>
> What is the opposite of vm_insert_range() or even of vm_insert_page()?
> or is there no need for that?

There is no opposite function of vm_insert_range() / vm_insert_page().
My understanding is, in case of any error, mmap handlers will return the
err to user process and user space will decide the next action. So next
time when mmap handler is getting invoked it will map from the beginning.
Correct me if I am wrong.
>
>
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 15c417e..da904ed 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1478,6 +1478,34 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
> >  }
> >
> >  /**
> > + * vm_insert_range - insert range of kernel pages into user vma
> > + * @vma: user vma to map to
> > + * @addr: target user address of this page
> > + * @pages: pointer to array of source kernel pages
> > + * @page_count: no. of pages need to insert into user vma
>
> s/no./number/

I didn't get it ??
>
> > + *
> > + * This allows drivers to insert range of kernel pages they've allocated
> > + * into a user vma. This is a generic function which drivers can use
> > + * rather than using their own way of mapping range of kernel pages into
> > + * user vma.
> > + */
> > +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> > +                     struct page **pages, unsigned long page_count)
> > +{
> > +     unsigned long uaddr = addr;
> > +     int ret = 0, i;
> > +
> > +     for (i = 0; i < page_count; i++) {
> > +             ret = vm_insert_page(vma, uaddr, pages[i]);
> > +             if (ret < 0)
> > +                     return ret;
>
> For a non-trivial value of page_count:
> Is it a problem if vm_insert_page() succeeds for several pages
> and then fails?

No, it will be considered as total failure and mmap handler will return
the err to user space.
>
> > +             uaddr += PAGE_SIZE;
> > +     }
> > +
> > +     return ret;
> > +}
> > +
> > +/**
> >   * vm_insert_page - insert single page into user vma
> >   * @vma: user vma to map to
> >   * @addr: target user address of this page
>
>
> thanks.
> --
> ~Randy
