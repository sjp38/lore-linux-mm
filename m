Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B77F76B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:52:28 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so770237wgb.2
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 08:52:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341582855-4251-1-git-send-email-prathyush.k@samsung.com>
References: <1341582855-4251-1-git-send-email-prathyush.k@samsung.com>
Date: Fri, 6 Jul 2012 08:52:26 -0700
Message-ID: <CALYq+qROZZO=Te0N5QGj1D7UWhdBnaAmOEwi-r3JJXFpeVQqkw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH] ARM: dma-mapping: modify condition check
 while freeing pages
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prathyush K <prathyush.k@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, subash.ramaswamy@linaro.org

Hi Prathyush,

 The same should be applied even for : "__iommu_alloc_buffer" in
arch/arm/mm/dma-mappping.c

static struct page **__iommu_alloc_buffer(struct device *dev, size_t
size, gfp_t gfp)
  {
          struct page **pages;
          int count = size >> PAGE_SHIFT;
          int array_size = count * sizeof(struct page *);
          int i = 0;

          if (array_size <= PAGE_SIZE)
                  pages = kzalloc(array_size, gfp);
          else
                  pages = vzalloc(array_size);
          if (!pages)
                  return NULL;

          while (count) {
                  int j, order = __fls(count);

                  pages[i] = alloc_pages(gfp | __GFP_NOWARN, order);
                  while (!pages[i] && order)
                          pages[i] = alloc_pages(gfp | __GFP_NOWARN, --order);
                  if (!pages[i])
                          goto error;

                  if (order)
                          split_page(pages[i], order);
                  j = 1 << order;
                  while (--j)
                         pages[i + j] = pages[i] + j;

                 __dma_clear_buffer(pages[i], PAGE_SIZE << order);
                 i += 1 << order;
                 count -= 1 << order;
         }

         return pages;
 error:
         while (--i)
                 if (pages[i])
                         __free_pages(pages[i], 0);
         if (array_size < PAGE_SIZE)
                 kfree(pages);
         else
                 vfree(pages);
         return NULL;
 }

Regards,
Abhinav

On Fri, Jul 6, 2012 at 6:54 AM, Prathyush K <prathyush.k@samsung.com> wrote:
> WARNING: at mm/vmalloc.c:1471 __iommu_free_buffer+0xcc/0xd0()
> Trying to vfree() nonexistent vm area (ef095000)
> Modules linked in:
> [<c0015a18>] (unwind_backtrace+0x0/0xfc) from [<c0025a94>] (warn_slowpath_common+0x54/0x64)
> [<c0025a94>] (warn_slowpath_common+0x54/0x64) from [<c0025b38>] (warn_slowpath_fmt+0x30/0x40)
> [<c0025b38>] (warn_slowpath_fmt+0x30/0x40) from [<c0016de0>] (__iommu_free_buffer+0xcc/0xd0)
> [<c0016de0>] (__iommu_free_buffer+0xcc/0xd0) from [<c0229a5c>] (exynos_drm_free_buf+0xe4/0x138)
> [<c0229a5c>] (exynos_drm_free_buf+0xe4/0x138) from [<c022b358>] (exynos_drm_gem_destroy+0x80/0xfc)
> [<c022b358>] (exynos_drm_gem_destroy+0x80/0xfc) from [<c0211230>] (drm_gem_object_free+0x28/0x34)
> [<c0211230>] (drm_gem_object_free+0x28/0x34) from [<c0211bd0>] (drm_gem_object_release_handle+0xcc/0xd8)
> [<c0211bd0>] (drm_gem_object_release_handle+0xcc/0xd8) from [<c01abe10>] (idr_for_each+0x74/0xb8)
> [<c01abe10>] (idr_for_each+0x74/0xb8) from [<c02114e4>] (drm_gem_release+0x1c/0x30)
> [<c02114e4>] (drm_gem_release+0x1c/0x30) from [<c0210ae8>] (drm_release+0x608/0x694)
> [<c0210ae8>] (drm_release+0x608/0x694) from [<c00b75a0>] (fput+0xb8/0x228)
> [<c00b75a0>] (fput+0xb8/0x228) from [<c00b40c4>] (filp_close+0x64/0x84)
> [<c00b40c4>] (filp_close+0x64/0x84) from [<c0029d54>] (put_files_struct+0xe8/0x104)
> [<c0029d54>] (put_files_struct+0xe8/0x104) from [<c002b930>] (do_exit+0x608/0x774)
> [<c002b930>] (do_exit+0x608/0x774) from [<c002bae4>] (do_group_exit+0x48/0xb4)
> [<c002bae4>] (do_group_exit+0x48/0xb4) from [<c002bb60>] (sys_exit_group+0x10/0x18)
> [<c002bb60>] (sys_exit_group+0x10/0x18) from [<c000ee80>] (ret_fast_syscall+0x0/0x30)
>
> This patch modifies the condition while freeing to match the condition
> used while allocation. This fixes the above warning which arises when
> array size is equal to PAGE_SIZE where allocation is done using kzalloc
> but free is done using vfree.
>
> Signed-off-by: Prathyush K <prathyush.k@samsung.com>
> ---
>  arch/arm/mm/dma-mapping.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index dc560dc..62fefac 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1106,7 +1106,7 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
>         for (i = 0; i < count; i++)
>                 if (pages[i])
>                         __free_pages(pages[i], 0);
> -       if (array_size < PAGE_SIZE)
> +       if (array_size <= PAGE_SIZE)
>                 kfree(pages);
>         else
>                 vfree(pages);
> --
> 1.7.0.4
>
>
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> http://lists.linaro.org/mailman/listinfo/linaro-mm-sig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
