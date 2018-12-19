Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23F8A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 02:38:14 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k22-v6so5091233ljk.12
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 23:38:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor10905125ljd.6.2018.12.18.23.38.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 23:38:12 -0800 (PST)
MIME-Version: 1.0
References: <20181217202448.GA14918@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181217202448.GA14918@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 19 Dec 2018 13:08:00 +0530
Message-ID: <CAFqt6zZ9JxE_GZ97On54YzdUtgbShL3q0JjK4j2CEMVpAJbejA@mail.gmail.com>
Subject: Re: [PATCH v4 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, joro@8bytes.org
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, robin.murphy@arm.com

On Tue, Dec 18, 2018 at 1:50 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>

Cc'd: Robin Murphy
> ---
>  drivers/iommu/dma-iommu.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
> index d1b0475..de7ffd8 100644
> --- a/drivers/iommu/dma-iommu.c
> +++ b/drivers/iommu/dma-iommu.c
> @@ -622,17 +622,10 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
>
>  int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -       int ret = -ENXIO;
> +       unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
>
> -       for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
> -               ret = vm_insert_page(vma, uaddr, pages[i]);
> -               if (ret)
> -                       break;
> -               uaddr += PAGE_SIZE;
> -       }
> -       return ret;
> +       return vm_insert_range(vma, vma->vm_start, pages + vma->vm_pgoff,
> +                               count - vma->vm_pgoff);
>  }
>
>  static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
> --
> 1.9.1
>
