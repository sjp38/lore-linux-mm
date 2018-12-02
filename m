Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 257746B6321
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 06:13:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e12so5121814edd.16
        for <linux-mm@kvack.org>; Sun, 02 Dec 2018 03:13:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b6si3360051edf.49.2018.12.02.03.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Dec 2018 03:13:34 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB2B9SGv032232
	for <linux-mm@kvack.org>; Sun, 2 Dec 2018 06:13:32 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p48un9f1v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 02 Dec 2018 06:13:32 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 2 Dec 2018 11:13:30 -0000
Date: Sun, 2 Dec 2018 13:13:13 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 1/9] mm: Introduce new vm_insert_range API
References: <20181202061944.GA3094@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181202061944.GA3094@jordon-HP-15-Notebook-PC>
Message-Id: <20181202111313.GC6959@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Sun, Dec 02, 2018 at 11:49:44AM +0530, Souptick Joarder wrote:
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
> Tested-by: Heiko Stuebner <heiko@sntech.de>
> ---
>  include/linux/mm_types.h |  3 +++
>  mm/memory.c              | 38 ++++++++++++++++++++++++++++++++++++++
>  mm/nommu.c               |  7 +++++++
>  3 files changed, 48 insertions(+)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5ed8f62..15ae24f 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -523,6 +523,9 @@ extern void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
>  extern void tlb_finish_mmu(struct mmu_gather *tlb,
>  				unsigned long start, unsigned long end);
> 
> +int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
> +			struct page **pages, unsigned long page_count);
> +

This seem to belong to include/linux/mm.h, near vm_insert_page()

>  static inline void init_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	atomic_set(&mm->tlb_flush_pending, 0);
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
> -- 
> 1.9.1
> 

-- 
Sincerely yours,
Mike.
