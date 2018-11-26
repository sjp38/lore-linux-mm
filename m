Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE206B405E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 00:36:58 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id e12-v6so4984694ljb.18
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:36:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o87sor13220323lfg.70.2018.11.25.21.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 21:36:56 -0800 (PST)
MIME-Version: 1.0
References: <20181115154826.GA27948@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181115154826.GA27948@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 26 Nov 2018 11:06:42 +0530
Message-ID: <CAFqt6zZy0-dy=a+KDrx7V1-j37pAVmt2r6bOkjgHwiopG-L+xA@mail.gmail.com>
Subject: Re: [PATCH 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org

Hi Heiko,

On Thu, Nov 15, 2018 at 9:14 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any feedback for this patch ?

> ---
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 20 ++------------------
>  1 file changed, 2 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> index a8db758..2cb83bb 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> @@ -221,26 +221,10 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
>                                               struct vm_area_struct *vma)
>  {
>         struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> -       unsigned int i, count = obj->size >> PAGE_SHIFT;
>         unsigned long user_count = vma_pages(vma);
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long offset = vma->vm_pgoff;
> -       unsigned long end = user_count + offset;
> -       int ret;
> -
> -       if (user_count == 0)
> -               return -ENXIO;
> -       if (end > count)
> -               return -ENXIO;
>
> -       for (i = offset; i < end; i++) {
> -               ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
> -               if (ret)
> -                       return ret;
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range(vma, vma->vm_start, rk_obj->pages,
> +                               user_count);
>  }
>
>  static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
> --
> 1.9.1
>
