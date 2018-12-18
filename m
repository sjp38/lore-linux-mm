Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF6048E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:06:20 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x18-v6so4257112lji.0
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:06:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o26-v6sor8914829ljj.36.2018.12.18.04.06.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 04:06:18 -0800 (PST)
MIME-Version: 1.0
References: <20181217202334.GA11758@jordon-HP-15-Notebook-PC> <20181218095709.GJ26090@n2100.armlinux.org.uk>
In-Reply-To: <20181218095709.GJ26090@n2100.armlinux.org.uk>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 18 Dec 2018 17:36:04 +0530
Message-ID: <CAFqt6zaVU-Fme6fErieBfBKwAm9xHUa7cXTOfqzwUJR__0JysQ@mail.gmail.com>
Subject: Re: [PATCH v4 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-rockchip@lists.infradead.org

On Tue, Dec 18, 2018 at 3:27 PM Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
>
> On Tue, Dec 18, 2018 at 01:53:34AM +0530, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Tested-by: Heiko Stuebner <heiko@sntech.de>
> > Acked-by: Heiko Stuebner <heiko@sntech.de>
> > ---
> >  drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 19 ++-----------------
> >  1 file changed, 2 insertions(+), 17 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > index a8db758..8279084 100644
> > --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > @@ -221,26 +221,11 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
> >                                             struct vm_area_struct *vma)
> >  {
> >       struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> > -     unsigned int i, count = obj->size >> PAGE_SHIFT;
> >       unsigned long user_count = vma_pages(vma);
> > -     unsigned long uaddr = vma->vm_start;
> >       unsigned long offset = vma->vm_pgoff;
> > -     unsigned long end = user_count + offset;
> > -     int ret;
> > -
> > -     if (user_count == 0)
> > -             return -ENXIO;
> > -     if (end > count)
> > -             return -ENXIO;
> >
> > -     for (i = offset; i < end; i++) {
> > -             ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
> > -             if (ret)
> > -                     return ret;
> > -             uaddr += PAGE_SIZE;
> > -     }
> > -
> > -     return 0;
> > +     return vm_insert_range(vma, vma->vm_start, rk_obj->pages + offset,
> > +                             user_count - offset);
>
> This looks like a change in behaviour.
>
> If user_count is zero, and offset is zero, then we pass into
> vm_insert_range() a page_count of zero, and vm_insert_range() does
> nothing and returns zero.
>
> However, as we can see from the above code, the original behaviour
> was to return -ENXIO in that case.

I think these checks are not necessary. I am not sure if we get into mmap
handlers of driver with user_count = 0.

>
> The other thing that I'm wondering is that if (eg) count is 8 (the
> object is 8 pages), offset is 2, and the user requests mapping 6
> pages (user_count = 6), then we call vm_insert_range() with a
> pages of rk_obj->pages + 2, and a pages_count of 6 - 2 = 4. So we
> end up inserting four pages.

Considering the scenario, user_count will remain 8 (user_count =
vma_pages(vma) ). ? No ?
Then we call vm_insert_range() with a pages of rk_obj->pages + 2, and
a pages_count
of 8 - 2 = 6. So we end up inserting 6 pages.

Please correct me if I am wrong.

>
> The original code would calculate end = 6 + 2 = 8.  i would iterate
> from 2 through 8, inserting six pages.
>
> (I hadn't spotted that second issue until I'd gone through the
> calculations manually - which is worrying.)
>
> I don't have patches 5 through 9 to look at, but I'm concerned that
> similar issues also exist in those patches.

yes, you were not cc'd for 5 - 9. Below are the patchwork links -

https://patchwork.kernel.org/patch/10734269/
https://patchwork.kernel.org/patch/10734271/
https://patchwork.kernel.org/patch/10734273/
https://patchwork.kernel.org/patch/10734277/
https://patchwork.kernel.org/patch/10734279/

>
> I'm concerned that this series seems to be introducing subtle bugs,
> it seems to be unnecessarily difficult to use this function correctly.
> I think your existing proposal for vm_insert_range() provides an
> interface that is way too easy to get wrong, and, therefore, is the
> wrong interface.
>
> I think it would be way better to have vm_insert_range() take the
> object page array without any offset adjustment, and the object
> page_count again without any adjustment, and have vm_insert_range()
> itself handle the offsetting and VMA size validation.  That would
> then give a simple interface and probably give a further reduction
> in code at each call site.
>
> Thanks.
>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
> According to speedtest.net: 11.9Mbps down 500kbps up
