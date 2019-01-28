Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 403288E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 01:31:56 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v24-v6so4502792ljj.10
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 22:31:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor7911090ljj.2.2019.01.27.22.31.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 Jan 2019 22:31:54 -0800 (PST)
MIME-Version: 1.0
References: <20190111151110.GA2798@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111151110.GA2798@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 28 Jan 2019 12:01:42 +0530
Message-ID: <CAFqt6zYhudeTdj02Ex6jaLYoUQ-2YhmwTvJ6+nHRcAJN7NZ99w@mail.gmail.com>
Subject: Re: [PATCH 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, joro@8bytes.org, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Fri, Jan 11, 2019 at 8:37 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?
> ---
>  drivers/iommu/dma-iommu.c | 12 +-----------
>  1 file changed, 1 insertion(+), 11 deletions(-)
>
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d1b0475..802de67 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -622,17 +622,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>
>  int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -       int ret = -ENXIO;
> -
> -       for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> -               ret = vm_insert_page(vma, uaddr, pages[i]);
> -               if (ret)
> -                       break;
> -               uaddr += PAGE_SIZE;
> -       }
> -       return ret;
> +       return vm_insert_range(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
>  }
>
>  static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
> --
> 1.9.1
>
