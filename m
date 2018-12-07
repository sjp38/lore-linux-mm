Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD4C48E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 09:48:41 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id l1so1482108wrn.3
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 06:48:41 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id c192si2871319wme.168.2018.12.07.06.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 06:48:40 -0800 (PST)
Date: Fri, 7 Dec 2018 12:47:37 -0200
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: [PATCH v3 1/9] mm: Introduce new vm_insert_range API
Message-ID: <20181207124737.123cb2e1@coco.lan>
In-Reply-To: <20181206183945.GA20932@jordon-HP-15-Notebook-PC>
References: <20181206183945.GA20932@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, boris.ostrovsky@oracle.com, jgross@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

Em Fri, 7 Dec 2018 00:09:45 +0530
Souptick Joarder <jrdr.linux@gmail.com> escreveu:

> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
> 
> As this pattern is common across different drivers, it can
> be generalized by creating a new function and use it across
> the drivers.
> 
> vm_insert_range is the new API which will be used to map a
> range of kernel memory/pages to user vma.
> 
> This API is tested by Heiko for Rockchip drm driver, on rk3188,
> rk3288, rk3328 and rk3399 with graphics.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> Tested-by: Heiko Stuebner <heiko@sntech.de>

Looks good to me.

Reviewed-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

> ---
>  include/linux/mm.h |  2 ++
>  mm/memory.c        | 38 ++++++++++++++++++++++++++++++++++++++
>  mm/nommu.c         |  7 +++++++
>  3 files changed, 47 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fcf9cc9..2bc399f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2506,6 +2506,8 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> +			struct page **pages, unsigned long page_count);
>  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn);
>  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/memory.c b/mm/memory.c
> index 15c417e..84ea46c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1478,6 +1478,44 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  
>  /**
> + * vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @addr: target user address of this page
> + * @pages: pointer to array of source kernel pages
> + * @page_count: number of pages need to insert into user vma
> + *
> + * This allows drivers to insert range of kernel pages they've allocated
> + * into a user vma. This is a generic function which drivers can use
> + * rather than using their own way of mapping range of kernel pages into
> + * user vma.
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously-inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully-inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise
> + */
> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> +			struct page **pages, unsigned long page_count)
> +{
> +	unsigned long uaddr = addr;
> +	int ret = 0, i;
> +
> +	for (i = 0; i < page_count; i++) {
> +		ret = vm_insert_page(vma, uaddr, pages[i]);
> +		if (ret < 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	}
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +/**
>   * vm_insert_page - insert single page into user vma
>   * @vma: user vma to map to
>   * @addr: target user address of this page
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 749276b..d6ef5c7 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -473,6 +473,13 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
>  
> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> +			struct page **pages, unsigned long page_count)
> +{
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
>  /*
>   *  sys_brk() for the most part doesn't need the global kernel
>   *  lock, except when an application is doing something nasty



Thanks,
Mauro
