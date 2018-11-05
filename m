Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAEE16B0284
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:51:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f62-v6so458212qtb.17
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:51:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g185si7820023qkd.81.2018.11.05.13.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:51:48 -0800 (PST)
Date: Mon, 5 Nov 2018 14:51:41 -0700
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [RFC PATCH v4 06/13] vfio: parallelize vfio_pin_map_dma
Message-ID: <20181105145141.6f9937f6@w520.home>
In-Reply-To: <20181105165558.11698-7-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
	<20181105165558.11698-7-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon,  5 Nov 2018 11:55:51 -0500
Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> When starting a large-memory kvm guest, it takes an excessively long
> time to start the boot process because qemu must pin all guest pages to
> accommodate DMA when VFIO is in use.  Currently just one CPU is
> responsible for the page pinning, which usually boils down to page
> clearing time-wise, so the ways to optimize this are buying a faster
> CPU ;-) or using more of the CPUs you already have.
> 
> Parallelize with ktask.  Refactor so workqueue workers pin with the mm
> of the calling thread, and to enable an undo callback for ktask to
> handle errors during page pinning.
> 
> Performance results appear later in the series.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  drivers/vfio/vfio_iommu_type1.c | 106 +++++++++++++++++++++++---------
>  1 file changed, 76 insertions(+), 30 deletions(-)
> 
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index d9fd3188615d..e7cfbf0c8071 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -41,6 +41,7 @@
>  #include <linux/notifier.h>
>  #include <linux/dma-iommu.h>
>  #include <linux/irqdomain.h>
> +#include <linux/ktask.h>
>  
>  #define DRIVER_VERSION  "0.2"
>  #define DRIVER_AUTHOR   "Alex Williamson <alex.williamson@redhat.com>"
> @@ -395,7 +396,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
>   */
>  static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  				  long npage, unsigned long *pfn_base,
> -				  unsigned long limit)
> +				  unsigned long limit, struct mm_struct *mm)
>  {
>  	unsigned long pfn = 0;
>  	long ret, pinned = 0, lock_acct = 0;
> @@ -403,10 +404,10 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  	dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
>  
>  	/* This code path is only user initiated */
> -	if (!current->mm)
> +	if (!mm)
>  		return -ENODEV;
>  
> -	ret = vaddr_get_pfn(current->mm, vaddr, dma->prot, pfn_base);
> +	ret = vaddr_get_pfn(mm, vaddr, dma->prot, pfn_base);
>  	if (ret)
>  		return ret;
>  
> @@ -418,7 +419,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  	 * pages are already counted against the user.
>  	 */
>  	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> -		if (!dma->lock_cap && current->mm->locked_vm + 1 > limit) {
> +		if (!dma->lock_cap && mm->locked_vm + 1 > limit) {
>  			put_pfn(*pfn_base, dma->prot);
>  			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
>  					limit << PAGE_SHIFT);
> @@ -433,7 +434,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  	/* Lock all the consecutive pages from pfn_base */
>  	for (vaddr += PAGE_SIZE, iova += PAGE_SIZE; pinned < npage;
>  	     pinned++, vaddr += PAGE_SIZE, iova += PAGE_SIZE) {
> -		ret = vaddr_get_pfn(current->mm, vaddr, dma->prot, &pfn);
> +		ret = vaddr_get_pfn(mm, vaddr, dma->prot, &pfn);
>  		if (ret)
>  			break;
>  
> @@ -445,7 +446,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>  
>  		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
>  			if (!dma->lock_cap &&
> -			    current->mm->locked_vm + lock_acct + 1 > limit) {
> +			    mm->locked_vm + lock_acct + 1 > limit) {
>  				put_pfn(pfn, dma->prot);
>  				pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n",
>  					__func__, limit << PAGE_SHIFT);
> @@ -752,15 +753,15 @@ static size_t unmap_unpin_slow(struct vfio_domain *domain,
>  }
>  
>  static long vfio_unmap_unpin(struct vfio_iommu *iommu, struct vfio_dma *dma,
> +			     dma_addr_t iova, dma_addr_t end,
>  			     bool do_accounting)
>  {
> -	dma_addr_t iova = dma->iova, end = dma->iova + dma->size;
>  	struct vfio_domain *domain, *d;
>  	LIST_HEAD(unmapped_region_list);
>  	int unmapped_region_cnt = 0;
>  	long unlocked = 0;
>  
> -	if (!dma->size)
> +	if (iova == end)
>  		return 0;
>  
>  	if (!IS_IOMMU_CAP_DOMAIN_IN_CONTAINER(iommu))
> @@ -777,7 +778,7 @@ static long vfio_unmap_unpin(struct vfio_iommu *iommu, struct vfio_dma *dma,
>  				      struct vfio_domain, next);
>  
>  	list_for_each_entry_continue(d, &iommu->domain_list, next) {
> -		iommu_unmap(d->domain, dma->iova, dma->size);
> +		iommu_unmap(d->domain, iova, end - iova);
>  		cond_resched();
>  	}
>  
> @@ -818,8 +819,6 @@ static long vfio_unmap_unpin(struct vfio_iommu *iommu, struct vfio_dma *dma,
>  		}
>  	}
>  
> -	dma->iommu_mapped = false;
> -
>  	if (unmapped_region_cnt)
>  		unlocked += vfio_sync_unpin(dma, domain, &unmapped_region_list);
>  
> @@ -830,14 +829,21 @@ static long vfio_unmap_unpin(struct vfio_iommu *iommu, struct vfio_dma *dma,
>  	return unlocked;
>  }
>  
> -static void vfio_remove_dma(struct vfio_iommu *iommu, struct vfio_dma *dma)
> +static void vfio_remove_dma_finish(struct vfio_iommu *iommu,
> +				   struct vfio_dma *dma)
>  {
> -	vfio_unmap_unpin(iommu, dma, true);
> +	dma->iommu_mapped = false;
>  	vfio_unlink_dma(iommu, dma);
>  	put_task_struct(dma->task);
>  	kfree(dma);
>  }
>  
> +static void vfio_remove_dma(struct vfio_iommu *iommu, struct vfio_dma *dma)
> +{
> +	vfio_unmap_unpin(iommu, dma, dma->iova, dma->iova + dma->size, true);
> +	vfio_remove_dma_finish(iommu, dma);
> +}
> +
>  static unsigned long vfio_pgsize_bitmap(struct vfio_iommu *iommu)
>  {
>  	struct vfio_domain *domain;
> @@ -1031,20 +1037,29 @@ static int vfio_iommu_map(struct vfio_iommu *iommu, dma_addr_t iova,
>  	return ret;
>  }
>  
> -static int vfio_pin_map_dma(struct vfio_iommu *iommu, struct vfio_dma *dma,
> -			    size_t map_size)
> +struct vfio_pin_args {
> +	struct vfio_iommu *iommu;
> +	struct vfio_dma *dma;
> +	unsigned long limit;
> +	struct mm_struct *mm;
> +};
> +
> +static int vfio_pin_map_dma_chunk(unsigned long start_vaddr,
> +				  unsigned long end_vaddr,
> +				  struct vfio_pin_args *args)
>  {
> -	dma_addr_t iova = dma->iova;
> -	unsigned long vaddr = dma->vaddr;
> -	size_t size = map_size;
> +	struct vfio_dma *dma = args->dma;
> +	dma_addr_t iova = dma->iova + (start_vaddr - dma->vaddr);
> +	unsigned long unmapped_size = end_vaddr - start_vaddr;
> +	unsigned long pfn, mapped_size = 0;
>  	long npage;
> -	unsigned long pfn, limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  	int ret = 0;
>  
> -	while (size) {
> +	while (unmapped_size) {
>  		/* Pin a contiguous chunk of memory */
> -		npage = vfio_pin_pages_remote(dma, vaddr + dma->size,
> -					      size >> PAGE_SHIFT, &pfn, limit);
> +		npage = vfio_pin_pages_remote(dma, start_vaddr + mapped_size,
> +					      unmapped_size >> PAGE_SHIFT,
> +					      &pfn, args->limit, args->mm);
>  		if (npage <= 0) {
>  			WARN_ON(!npage);
>  			ret = (int)npage;
> @@ -1052,22 +1067,50 @@ static int vfio_pin_map_dma(struct vfio_iommu *iommu, struct vfio_dma *dma,
>  		}
>  
>  		/* Map it! */
> -		ret = vfio_iommu_map(iommu, iova + dma->size, pfn, npage,
> -				     dma->prot);
> +		ret = vfio_iommu_map(args->iommu, iova + mapped_size, pfn,
> +				     npage, dma->prot);
>  		if (ret) {
> -			vfio_unpin_pages_remote(dma, iova + dma->size, pfn,
> +			vfio_unpin_pages_remote(dma, iova + mapped_size, pfn,
>  						npage, true);
>  			break;
>  		}
>  
> -		size -= npage << PAGE_SHIFT;
> -		dma->size += npage << PAGE_SHIFT;
> +		unmapped_size -= npage << PAGE_SHIFT;
> +		mapped_size   += npage << PAGE_SHIFT;
>  	}
>  
> +	return (ret == 0) ? KTASK_RETURN_SUCCESS : ret;

Overall I'm a big fan of this, but I think there's an undo problem
here.  Per 03/13, kc_undo_func is only called for successfully
completed chunks and each kc_thread_func should handle cleanup of any
intermediate work before failure.  That's not done here afaict.  Should
we be calling the vfio_pin_map_dma_undo() manually on the completed
range before returning error?

> +}
> +
> +static void vfio_pin_map_dma_undo(unsigned long start_vaddr,
> +				  unsigned long end_vaddr,
> +				  struct vfio_pin_args *args)
> +{
> +	struct vfio_dma *dma = args->dma;
> +	dma_addr_t iova = dma->iova + (start_vaddr - dma->vaddr);
> +	dma_addr_t end  = dma->iova + (end_vaddr   - dma->vaddr);
> +
> +	vfio_unmap_unpin(args->iommu, args->dma, iova, end, true);
> +}
> +
> +static int vfio_pin_map_dma(struct vfio_iommu *iommu, struct vfio_dma *dma,
> +			    size_t map_size)
> +{
> +	unsigned long limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> +	int ret = 0;
> +	struct vfio_pin_args args = { iommu, dma, limit, current->mm };
> +	/* Stay on PMD boundary in case THP is being used. */
> +	DEFINE_KTASK_CTL(ctl, vfio_pin_map_dma_chunk, &args, PMD_SIZE);

PMD_SIZE chunks almost seems too convenient, I wonder a) is that really
enough work per thread, and b) is this really successfully influencing
THP?  Thanks,

Alex

> +
> +	ktask_ctl_set_undo_func(&ctl, vfio_pin_map_dma_undo);
> +	ret = ktask_run((void *)dma->vaddr, map_size, &ctl);
> +
>  	dma->iommu_mapped = true;
>  
>  	if (ret)
> -		vfio_remove_dma(iommu, dma);
> +		vfio_remove_dma_finish(iommu, dma);
> +	else
> +		dma->size += map_size;
>  
>  	return ret;
>  }
> @@ -1229,7 +1272,8 @@ static int vfio_iommu_replay(struct vfio_iommu *iommu,
>  
>  				npage = vfio_pin_pages_remote(dma, vaddr,
>  							      n >> PAGE_SHIFT,
> -							      &pfn, limit);
> +							      &pfn, limit,
> +							      current->mm);
>  				if (npage <= 0) {
>  					WARN_ON(!npage);
>  					ret = (int)npage;
> @@ -1497,7 +1541,9 @@ static void vfio_iommu_unmap_unpin_reaccount(struct vfio_iommu *iommu)
>  		long locked = 0, unlocked = 0;
>  
>  		dma = rb_entry(n, struct vfio_dma, node);
> -		unlocked += vfio_unmap_unpin(iommu, dma, false);
> +		unlocked += vfio_unmap_unpin(iommu, dma, dma->iova,
> +					     dma->iova + dma->size, false);
> +		dma->iommu_mapped = false;
>  		p = rb_first(&dma->pfn_list);
>  		for (; p; p = rb_next(p)) {
>  			struct vfio_pfn *vpfn = rb_entry(p, struct vfio_pfn,
