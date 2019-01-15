Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0804D8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:50:11 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id e12-v6so375368ljb.18
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 20:50:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor761449lfl.63.2019.01.14.20.50.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 20:50:08 -0800 (PST)
MIME-Version: 1.0
References: <20190111151235.GA2836@jordon-HP-15-Notebook-PC> <f6eef305-daf3-dad8-96e3-d2f93d169fd4@oracle.com>
In-Reply-To: <f6eef305-daf3-dad8-96e3-d2f93d169fd4@oracle.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 15 Jan 2019 10:19:55 +0530
Message-ID: <CAFqt6zYFR5FHXTLsSQ2DKgZDQtuNB2jZWK6ZLUAscG9vMnSk3Q@mail.gmail.com>
Subject: Re: [PATCH 8/9] xen/gntdev.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Juergen Gross <jgross@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 15, 2019 at 4:58 AM Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> On 1/11/19 10:12 AM, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>
> (although it would be good to mention in the commit that you are also
> replacing count with vma_pages(vma), and why)

The original code was using count ( *count = vma_pages(vma)* )
which is same as this patch. Do I need capture it change log ?

>
>
> > ---
> >  drivers/xen/gntdev.c | 16 ++++++----------
> >  1 file changed, 6 insertions(+), 10 deletions(-)
> >
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index b0b02a5..ca4acee 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
> >  {
> >       struct gntdev_priv *priv = flip->private_data;
> >       int index = vma->vm_pgoff;
> > -     int count = vma_pages(vma);
> >       struct gntdev_grant_map *map;
> > -     int i, err = -EINVAL;
> > +     int err = -EINVAL;
> >
> >       if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
> >               return -EINVAL;
> >
> >       pr_debug("map %d+%d at %lx (pgoff %lx)\n",
> > -                     index, count, vma->vm_start, vma->vm_pgoff);
> > +                     index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
> >
> >       mutex_lock(&priv->lock);
> > -     map = gntdev_find_map_index(priv, index, count);
> > +     map = gntdev_find_map_index(priv, index, vma_pages(vma));
> >       if (!map)
> >               goto unlock_out;
> >       if (use_ptemod && map->vma)
> > @@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
> >               goto out_put_map;
> >
> >       if (!use_ptemod) {
> > -             for (i = 0; i < count; i++) {
> > -                     err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> > -                             map->pages[i]);
> > -                     if (err)
> > -                             goto out_put_map;
> > -             }
> > +             err = vm_insert_range(vma, map->pages, map->count);
> > +             if (err)
> > +                     goto out_put_map;
> >       } else {
> >  #ifdef CONFIG_X86
> >               /*
>
