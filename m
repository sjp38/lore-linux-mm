Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7B98E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 10:48:47 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id f5-v6so8850925ljj.17
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 07:48:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22-v6sor31090951ljb.22.2019.01.02.07.48.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 07:48:44 -0800 (PST)
MIME-Version: 1.0
References: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
 <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com> <20190102111553.GG26090@n2100.armlinux.org.uk>
In-Reply-To: <20190102111553.GG26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 2 Jan 2019 21:22:34 +0530
Message-ID: <CAFqt6zadJ-4xh256BqzALnGY31nDAU=5XwUaSaz5OcJuOc7Bfg@mail.gmail.com>
Subject: Re: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, robin.murphy@arm.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Wed, Jan 2, 2019 at 4:46 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Wed, Jan 02, 2019 at 04:23:15PM +0530, Souptick Joarder wrote:
> > On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > >
> > > Convert to use vm_insert_range to map range of kernel memory
> > > to user vma.
> > >
> > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > > Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > > Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> > > ---
> > >  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
> > >  1 file changed, 7 insertions(+), 16 deletions(-)
> > >
> > > diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > index 015e737..898adef 100644
> > > --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > > @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
> > >  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
> > >  {
> > >         struct vb2_dma_sg_buf *buf = buf_priv;
> > > -       unsigned long uaddr = vma->vm_start;
> > > -       unsigned long usize = vma->vm_end - vma->vm_start;
> > > -       int i = 0;
> > > +       unsigned long page_count = vma_pages(vma);
> > > +       int err;
> > >
> > >         if (!buf) {
> > >                 printk(KERN_ERR "No memory to map\n");
> > >                 return -EINVAL;
> > >         }
> > >
> > > -       do {
> > > -               int ret;
> > > -
> > > -               ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> > > -               if (ret) {
> > > -                       printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> > > -                       return ret;
> > > -               }
> > > -
> > > -               uaddr += PAGE_SIZE;
> > > -               usize -= PAGE_SIZE;
> > > -       } while (usize > 0);
> > > -
> > > +       err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> > > +       if (err) {
> > > +               printk(KERN_ERR "Remapping memory, error: %d\n", err);
> > > +               return err;
> > > +       }
> > >
> >
> > Looking into the original code -
> > drivers/media/common/videobuf2/videobuf2-dma-sg.c
> >
> > Inside vb2_dma_sg_alloc(),
> >            ...
> >            buf->num_pages = size >> PAGE_SHIFT;
> >            buf->dma_sgt = &buf->sg_table;
> >
> >            buf->pages = kvmalloc_array(buf->num_pages, sizeof(struct page *),
> >                                                        GFP_KERNEL | __GFP_ZERO);
> >            ...
> >
> > buf->pages has index upto  *buf->num_pages*.
> >
> > now inside vb2_dma_sg_mmap(),
> >
> >            unsigned long usize = vma->vm_end - vma->vm_start;
> >            int i = 0;
> >            ...
> >            do {
> >                  int ret;
> >
> >                  ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> >                  if (ret) {
> >                            printk(KERN_ERR "Remapping memory, error:
> > %d\n", ret);
> >                            return ret;
> >                  }
> >
> >                 uaddr += PAGE_SIZE;
> >                 usize -= PAGE_SIZE;
> >            } while (usize > 0);
> >            ...
> > is it possible for any value of  *i  > (buf->num_pages)*,
> > buf->pages[i] is going to overrun the page boundary ?
>
> Yes it is, and you've found an array-overrun condition that is
> triggerable from userspace - potentially non-root userspace too.
> Depending on what it can cause to be mapped without oopsing the
> kernel, it could be very serious.  At best, it'll oops the kernel.
> At worst, it could expose pages of memory that userspace should
> not have access to.
>
> This is why I've been saying that we need a helper that takes the
> _object_ and the user request, and does all the checking internally,
> so these kinds of checks do not get overlooked.

ok, while replacing this code with the suggested vm_insert_range_buggy(),
we could fixed this issue.


>
> A good API is one that helpers authors avoid bugs.
>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up
