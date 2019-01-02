Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1E418E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 06:16:22 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id y1so14258808wrd.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 03:16:22 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id w8si28710877wrp.196.2019.01.02.03.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 03:16:21 -0800 (PST)
Date: Wed, 2 Jan 2019 11:15:54 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range
Message-ID: <20190102111553.GG26090@n2100.armlinux.org.uk>
References: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
 <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zZU6c3MyVQpCegntu1ZxtFri=HMwZJ3xg+tCxRARo3zMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, robin.murphy@arm.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Wed, Jan 02, 2019 at 04:23:15PM +0530, Souptick Joarder wrote:
> On Mon, Dec 24, 2018 at 6:53 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > Convert to use vm_insert_range to map range of kernel memory
> > to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
> > ---
> >  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
> >  1 file changed, 7 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > index 015e737..898adef 100644
> > --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
> >  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
> >  {
> >         struct vb2_dma_sg_buf *buf = buf_priv;
> > -       unsigned long uaddr = vma->vm_start;
> > -       unsigned long usize = vma->vm_end - vma->vm_start;
> > -       int i = 0;
> > +       unsigned long page_count = vma_pages(vma);
> > +       int err;
> >
> >         if (!buf) {
> >                 printk(KERN_ERR "No memory to map\n");
> >                 return -EINVAL;
> >         }
> >
> > -       do {
> > -               int ret;
> > -
> > -               ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> > -               if (ret) {
> > -                       printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> > -                       return ret;
> > -               }
> > -
> > -               uaddr += PAGE_SIZE;
> > -               usize -= PAGE_SIZE;
> > -       } while (usize > 0);
> > -
> > +       err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> > +       if (err) {
> > +               printk(KERN_ERR "Remapping memory, error: %d\n", err);
> > +               return err;
> > +       }
> >
> 
> Looking into the original code -
> drivers/media/common/videobuf2/videobuf2-dma-sg.c
> 
> Inside vb2_dma_sg_alloc(),
>            ...
>            buf->num_pages = size >> PAGE_SHIFT;
>            buf->dma_sgt = &buf->sg_table;
> 
>            buf->pages = kvmalloc_array(buf->num_pages, sizeof(struct page *),
>                                                        GFP_KERNEL | __GFP_ZERO);
>            ...
> 
> buf->pages has index upto  *buf->num_pages*.
> 
> now inside vb2_dma_sg_mmap(),
> 
>            unsigned long usize = vma->vm_end - vma->vm_start;
>            int i = 0;
>            ...
>            do {
>                  int ret;
> 
>                  ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
>                  if (ret) {
>                            printk(KERN_ERR "Remapping memory, error:
> %d\n", ret);
>                            return ret;
>                  }
> 
>                 uaddr += PAGE_SIZE;
>                 usize -= PAGE_SIZE;
>            } while (usize > 0);
>            ...
> is it possible for any value of  *i  > (buf->num_pages)*,
> buf->pages[i] is going to overrun the page boundary ?

Yes it is, and you've found an array-overrun condition that is
triggerable from userspace - potentially non-root userspace too.
Depending on what it can cause to be mapped without oopsing the
kernel, it could be very serious.  At best, it'll oops the kernel.
At worst, it could expose pages of memory that userspace should
not have access to.

This is why I've been saying that we need a helper that takes the
_object_ and the user request, and does all the checking internally,
so these kinds of checks do not get overlooked.

A good API is one that helpers authors avoid bugs.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
