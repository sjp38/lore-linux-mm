Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 770448E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 15:27:03 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id l12-v6so1363550ljb.11
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 12:27:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor3124253ljj.25.2018.12.07.12.27.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 12:27:01 -0800 (PST)
MIME-Version: 1.0
References: <20181206184227.GA28656@jordon-HP-15-Notebook-PC> <ca1779ea-7a87-971c-24c4-4a1c77a72e92@arm.com>
In-Reply-To: <ca1779ea-7a87-971c-24c4-4a1c77a72e92@arm.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Dec 2018 02:00:36 +0530
Message-ID: <CAFqt6zbMbvB1ckwhSsBATrq5M-HQ6qk95sCWCoTTFFnwzBAnng@mail.gmail.com>
Subject: Re: [PATCH v3 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robin.murphy@arm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, Linux-MM <linux-mm@kvack.org>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-rockchip@lists.infradead.org

On Fri, Dec 7, 2018 at 8:20 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 06/12/2018 18:42, Souptick Joarder wrote:
> > Convert to use vm_insert_range() to map range of kernel
> > memory to user vma.
> >
> > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > Tested-by: Heiko Stuebner <heiko@sntech.de>
> > Acked-by: Heiko Stuebner <heiko@sntech.de>
> > ---
> >   drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 20 ++------------------
> >   1 file changed, 2 insertions(+), 18 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > index a8db758..2cb83bb 100644
> > --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> > @@ -221,26 +221,10 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
> >                                             struct vm_area_struct *vma)
> >   {
> >       struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> > -     unsigned int i, count = obj->size >> PAGE_SHIFT;
> >       unsigned long user_count = vma_pages(vma);
> > -     unsigned long uaddr = vma->vm_start;
> > -     unsigned long offset = vma->vm_pgoff;
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
> > +     return vm_insert_range(vma, vma->vm_start, rk_obj->pages,
> > +                             user_count);
>
> We're losing vm_pgoff handling here, which given the implication in
> 57de50af162b, may well be a regression for at least some combination of
> GPU and userspace driver (I assume that commit was in the context of
> some version of the Arm Mali driver, possibly on RK3288).

In commit  57de50af162b, vma->vm_pgoff = 0 for GEM mmap handler context
and removing it from common path which means if call stack looks like
rockchip_gem_mmap_buf() -> rockchip_drm_gem_object_mmap() ->
rockchip_drm_gem_object_mmap_iommu(), then we might have a non zero
vma->vm_pgoff context which is not handled.

This is the problem you are pointing ? right ?
