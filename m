Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 051F98E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:01:03 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p65-v6so5746956ljb.16
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 23:01:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor3813636lfk.58.2019.01.21.23.01.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 23:01:00 -0800 (PST)
MIME-Version: 1.0
References: <20190111150712.GA2696@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150712.GA2696@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 22 Jan 2019 12:30:47 +0530
Message-ID: <CAFqt6zYOpbwc8518f27W8_YOkuprdJJLyJg1fFB==wrFZLdEYQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Fri, Jan 11, 2019 at 8:33 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
>
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
>
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
>
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Suggested-by: Russell King <linux@armlinux.org.uk>
> Suggested-by: Matthew Wilcox <willy@infradead.org>

Any comment on these APIs ?

> ---
>  include/linux/mm.h |  4 +++
>  mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/nommu.c         | 14 ++++++++++
>  3 files changed, 99 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de9..9d1dff6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2514,6 +2514,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>                         unsigned long pfn, unsigned long size, pgprot_t);
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num);
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num);
>  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>                         unsigned long pfn);
>  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d29..00e66df 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>
> +/**
> + * __vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + * @offset: user's requested vm_pgoff
> + *
> + * This allows drivers to insert range of kernel pages they've allocated
> + * into a user vma.
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context.
> + * Return: 0 on success and error code otherwise.
> + */
> +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num, unsigned long offset)
> +{
> +       unsigned long count = vma_pages(vma);
> +       unsigned long uaddr = vma->vm_start;
> +       int ret, i;
> +
> +       /* Fail if the user requested offset is beyond the end of the object */
> +       if (offset > num)
> +               return -ENXIO;
> +
> +       /* Fail if the user requested size exceeds available object size */
> +       if (count > num - offset)
> +               return -ENXIO;
> +
> +       for (i = 0; i < count; i++) {
> +               ret = vm_insert_page(vma, uaddr, pages[offset + i]);
> +               if (ret < 0)
> +                       return ret;
> +               uaddr += PAGE_SIZE;
> +       }
> +
> +       return 0;
> +}
> +
> +/**
> + * vm_insert_range - insert range of kernel pages starts with non zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps an object consisting of `num' `pages', catering for the user's
> + * requested vm_pgoff
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +/**
> + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps a set of pages, always starting at page[0]
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return __vm_insert_range(vma, pages, num, 0);
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>                         pfn_t pfn, pgprot_t prot, bool mkwrite)
>  {
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 749276b..21d101e 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +                       unsigned long num)
> +{
> +       return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +                               unsigned long num)
> +{
> +       return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  /*
>   *  sys_brk() for the most part doesn't need the global kernel
>   *  lock, except when an application is doing something nasty
> --
> 1.9.1
>
