Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 933408E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:42:10 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id g92-v6so403096ljg.23
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 21:42:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor786275lfj.71.2019.01.14.21.42.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 21:42:08 -0800 (PST)
MIME-Version: 1.0
References: <20190111151326.GA2853@jordon-HP-15-Notebook-PC> <8b0e0809-8e66-079d-1186-90b3f2df7a38@oracle.com>
In-Reply-To: <8b0e0809-8e66-079d-1186-90b3f2df7a38@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 15 Jan 2019 11:11:56 +0530
Message-ID: <CAFqt6zbgrdhoaZXW+5vHu2kV-LmtXMGAcmrv+28i78x0z4Fweg@mail.gmail.com>
Subject: Re: [PATCH 9/9] xen/privcmd-buf.c: Convert to use vm_insert_range_buggy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 15, 2019 at 5:01 AM Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> On 1/11/19 10:13 AM, Souptick Joarder wrote:
> > Convert to use vm_insert_range_buggy() to map range of kernel
> > memory to user vma.
> >
> > This driver has ignored vm_pgoff. We could later "fix" these drivers
> > to behave according to the normal vm_pgoff offsetting simply by
> > removing the _buggy suffix on the function name and if that causes
> > regressions, it gives us an easy way to revert.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > ---
> >  drivers/xen/privcmd-buf.c | 8 ++------
> >  1 file changed, 2 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
> > index de01a6d..a9d7e97 100644
> > --- a/drivers/xen/privcmd-buf.c
> > +++ b/drivers/xen/privcmd-buf.c
> > @@ -166,12 +166,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
> >       if (vma_priv->n_pages != count)
> >               ret = -ENOMEM;
> >       else
> > -             for (i = 0; i < vma_priv->n_pages; i++) {
> > -                     ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
> > -                                          vma_priv->pages[i]);
> > -                     if (ret)
> > -                             break;
> > -             }
> > +             ret = vm_insert_range_buggy(vma, vma_priv->pages,
> > +                                             vma_priv->n_pages);
>
> This can use the non-buggy version. But since the original code was
> indeed buggy in this respect I can submit this as a separate patch later.
>
> So
>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Thanks Boris.
>
>
> >
> >       if (ret)
> >               privcmd_buf_vmapriv_free(vma_priv);
>
