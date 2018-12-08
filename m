Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3AA88E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 14:58:05 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id p65-v6so1899008ljb.16
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 11:58:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k4-v6sor4300933ljc.11.2018.12.08.11.58.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Dec 2018 11:58:04 -0800 (PST)
MIME-Version: 1.0
References: <20181206184103.GA25872@jordon-HP-15-Notebook-PC>
In-Reply-To: <20181206184103.GA25872@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 9 Dec 2018 01:31:40 +0530
Message-ID: <CAFqt6zY9JjGhedtmhYh-+mxSMrYs6P5vtQDMSzCfL02CbLys=g@mail.gmail.com>
Subject: Re: [PATCH v3 2/9] arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org

Hi Robin,

On Fri, Dec 7, 2018 at 12:07 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  arch/arm/mm/dma-mapping.c | 21 +++++++--------------
>  1 file changed, 7 insertions(+), 14 deletions(-)
>
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> index 661fe48..4eec323 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -1582,31 +1582,24 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
>                     void *cpu_addr, dma_addr_t dma_addr, size_t size,
>                     unsigned long attrs)
>  {
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long usize = vma->vm_end - vma->vm_start;
> +       unsigned long page_count = vma_pages(vma);
>         struct page **pages = __iommu_get_pages(cpu_addr, attrs);
>         unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
>         unsigned long off = vma->vm_pgoff;
> +       int err;
>
>         if (!pages)
>                 return -ENXIO;
>
> -       if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
> +       if (off >= nr_pages || page_count > nr_pages - off)
>                 return -ENXIO;
>
>         pages += off;
> +       err = vm_insert_range(vma, vma->vm_start, pages, page_count);

Just to clarify, do we need to adjust page_count with vma->vm_pgoff as
original code
have not consider it and run the loop for entire range irrespective of
vma->vm_pgoff value ?

> +       if (err)
> +               pr_err("Remapping memory failed: %d\n", err);
>
> -       do {
> -               int ret = vm_insert_page(vma, uaddr, *pages++);
> -               if (ret) {
> -                       pr_err("Remapping memory failed: %d\n", ret);
> -                       return ret;
> -               }
> -               uaddr += PAGE_SIZE;
> -               usize -= PAGE_SIZE;
> -       } while (usize > 0);
> -
> -       return 0;
> +       return err;
>  }
>  static int arm_iommu_mmap_attrs(struct device *dev,
>                 struct vm_area_struct *vma, void *cpu_addr,
> --
> 1.9.1
>
