Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7138E00B5
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:56:02 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id l12-v6so2292747ljb.11
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:56:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor2606894lfl.19.2019.01.24.20.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 20:56:01 -0800 (PST)
MIME-Version: 1.0
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
 <20190111151154.GA2819@jordon-HP-15-Notebook-PC> <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
In-Reply-To: <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 25 Jan 2019 10:25:48 +0530
Message-ID: <CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com>
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

Hi Marek,

On Tue, Jan 22, 2019 at 8:37 PM Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
>
> Hi Souptick,
>
> On 2019-01-11 16:11, Souptick Joarder wrote:
> > Convert to use vm_insert_range_buggy to map range of kernel memory
> > to user vma.
> >
> > This driver has ignored vm_pgoff. We could later "fix" these drivers
> > to behave according to the normal vm_pgoff offsetting simply by
> > removing the _buggy suffix on the function name and if that causes
> > regressions, it gives us an easy way to revert.
>
> Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_pgof=
f by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap and =
videobuf2-core already checks that. If userspace provides an offset, which =
doesn't match any of the registered 'cookies' (reported to userspace via se=
parate v4l2 ioctl), an error is returned.

Ok, it means once the buf is selected, videobuf2-dma-sg should always
mapped buf->pages[i]
from index 0 ( irrespective of vm_pgoff value). So although we are
replacing the code with
vm_insert_range_buggy(), *_buggy* suffix will mislead others and
should not be used.
And if we replace this code with  vm_insert_range(), this will
introduce bug for *non zero*
value of vm_pgoff.

Please correct me if my understanding is wrong.

So what your opinion about this patch ? Shall I drop this patch from
current series ?
or,
There is any better way to handle this scenario ?


>
> > There is an existing bug inside gem_mmap_obj(), where user passed
> > length is not checked against buf->num_pages. For any value of
> > length > buf->num_pages it will end up overrun buf->pages[i],
> > which could lead to a potential bug.

It is not gem_mmap_obj(), it should be vb2_dma_sg_mmap().
Sorry about it.

What about this issue ? Does it looks like a valid issue ?


> >
> > This has been addressed by passing buf->num_pages as input to
> > vm_insert_range_buggy() and inside this API error condition is
> > checked which will avoid overrun the page boundary.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > ---
> >  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++++++---------=
-------
> >  1 file changed, 6 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/driver=
s/media/common/videobuf2/videobuf2-dma-sg.c
> > index 015e737..ef046b4 100644
> > --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> > @@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *bu=
f_priv)
> >  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
> >  {
> >       struct vb2_dma_sg_buf *buf =3D buf_priv;
> > -     unsigned long uaddr =3D vma->vm_start;
> > -     unsigned long usize =3D vma->vm_end - vma->vm_start;
> > -     int i =3D 0;
> > +     int err;
> >
> >       if (!buf) {
> >               printk(KERN_ERR "No memory to map\n");
> >               return -EINVAL;
> >       }
> >
> > -     do {
> > -             int ret;
> > -
> > -             ret =3D vm_insert_page(vma, uaddr, buf->pages[i++]);
> > -             if (ret) {
> > -                     printk(KERN_ERR "Remapping memory, error: %d\n", =
ret);
> > -                     return ret;
> > -             }
> > -
> > -             uaddr +=3D PAGE_SIZE;
> > -             usize -=3D PAGE_SIZE;
> > -     } while (usize > 0);
> > -
> > +     err =3D vm_insert_range_buggy(vma, buf->pages, buf->num_pages);
> > +     if (err) {
> > +             printk(KERN_ERR "Remapping memory, error: %d\n", err);
> > +             return err;
> > +     }
> >
> >       /*
> >        * Use common vm_area operations to track buffer refcount.
>
> Best regards
> --
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>
