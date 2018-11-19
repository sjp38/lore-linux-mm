Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 079496B1A5A
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:42:19 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p86-v6so6186146lja.2
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 02:42:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o87sor8432394lfg.70.2018.11.19.02.42.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 02:42:17 -0800 (PST)
MIME-Version: 1.0
References: <20181115154912.GA27969@jordon-HP-15-Notebook-PC> <ed294bea-bf07-6a4d-51ec-9e7082703b61@gmail.com>
In-Reply-To: <ed294bea-bf07-6a4d-51ec-9e7082703b61@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 19 Nov 2018 16:12:03 +0530
Message-ID: <CAFqt6zZ_FnWg2K3Lh=-1KFOk1XteHnroua6QzJrKo+khZTgieg@mail.gmail.com>
Subject: Re: [Xen-devel] [PATCH 5/9] drm/xen/xen_drm_front_gem.c: Convert to
 use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andr2000@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, oleksandr_andrushchenko@epam.com, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org

On Mon, Nov 19, 2018 at 3:22 PM Oleksandr Andrushchenko
<andr2000@gmail.com> wrote:
>
> On 11/15/18 5:49 PM, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Reviewed-by: Matthew Wilcox <willy@infradead.org>
> > ---
> >   drivers/gpu/drm/xen/xen_drm_front_gem.c | 20 ++++++--------------
> >   1 file changed, 6 insertions(+), 14 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
> > index 47ff019..a3eade6 100644
> > --- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
> > +++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
> > @@ -225,8 +225,7 @@ struct drm_gem_object *
> >   static int gem_mmap_obj(struct xen_gem_object *xen_obj,
> >                       struct vm_area_struct *vma)
> >   {
> > -     unsigned long addr = vma->vm_start;
> > -     int i;
> > +     int err;
> I would love to keep ret, not err

Sure, will add it in v2.
But I think, err is more appropriate here.

> >
> >       /*
> >        * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
> > @@ -247,18 +246,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
> >        * FIXME: as we insert all the pages now then no .fault handler must
> >        * be called, so don't provide one
> >        */
> > -     for (i = 0; i < xen_obj->num_pages; i++) {
> > -             int ret;
> > -
> > -             ret = vm_insert_page(vma, addr, xen_obj->pages[i]);
> > -             if (ret < 0) {
> > -                     DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
> > -                     return ret;
> > -             }
> > -
> > -             addr += PAGE_SIZE;
> > -     }
> > -     return 0;
> > +     err = vm_insert_range(vma, vma->vm_start, xen_obj->pages,
> > +                             xen_obj->num_pages);
> > +     if (err < 0)
> > +             DRM_ERROR("Failed to insert pages into vma: %d\n", err);
> > +     return err;
> >   }
> >
> >   int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
>
> With the above fixed,
>
> Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
>
