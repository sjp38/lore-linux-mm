Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E071E6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:18:56 -0500 (EST)
Received: by pfbg73 with SMTP id g73so13867991pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:18:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 28si5831051pfk.134.2015.12.08.07.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:18:56 -0800 (PST)
Date: Tue, 8 Dec 2015 07:18:52 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Message-ID: <20151208151852.GA6688@infradead.org>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yishai Hadas <yishaih@mellanox.com>
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com, linux-mm@kvack.org

There is absolutely nothing IB specific here.  If you want to support
anonymous mmaps to allocate large contiguous pages work with the MM
folks on providing that in a generic fashion.

[full quote alert for reference:]

On Tue, Dec 08, 2015 at 05:15:06PM +0200, Yishai Hadas wrote:
> New structure 'cmem' represents the contiguous allocated memory.
> It supports:
> Allocate, Free, 'Map to virtual address' operations, etc.
> 
> Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
> ---
>  drivers/infiniband/core/Makefile |   2 +-
>  drivers/infiniband/core/cmem.c   | 245 +++++++++++++++++++++++++++++++++++++++
>  include/rdma/ib_cmem.h           |  41 +++++++
>  3 files changed, 287 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/infiniband/core/cmem.c
>  create mode 100644 include/rdma/ib_cmem.h
> 
> diff --git a/drivers/infiniband/core/Makefile b/drivers/infiniband/core/Makefile
> index d43a899..8549ea4 100644
> --- a/drivers/infiniband/core/Makefile
> +++ b/drivers/infiniband/core/Makefile
> @@ -11,7 +11,7 @@ obj-$(CONFIG_INFINIBAND_USER_ACCESS) +=	ib_uverbs.o ib_ucm.o \
>  ib_core-y :=			packer.o ud_header.o verbs.o sysfs.o \
>  				device.o fmr_pool.o cache.o netlink.o \
>  				roce_gid_mgmt.o
> -ib_core-$(CONFIG_INFINIBAND_USER_MEM) += umem.o
> +ib_core-$(CONFIG_INFINIBAND_USER_MEM) += umem.o cmem.o
>  ib_core-$(CONFIG_INFINIBAND_ON_DEMAND_PAGING) += umem_odp.o umem_rbtree.o
>  
>  ib_mad-y :=			mad.o smi.o agent.o mad_rmpp.o
> diff --git a/drivers/infiniband/core/cmem.c b/drivers/infiniband/core/cmem.c
> new file mode 100644
> index 0000000..21d8573
> --- /dev/null
> +++ b/drivers/infiniband/core/cmem.c
> @@ -0,0 +1,245 @@
> +#include <linux/mm.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/sched.h>
> +#include <linux/export.h>
> +#include <linux/dma-attrs.h>
> +#include <linux/slab.h>
> +#include <rdma/ib_cmem.h>
> +#include "uverbs.h"
> +
> +static void ib_cmem_release(struct kref *ref)
> +{
> +	struct ib_cmem *cmem;
> +	struct ib_cmem_block *cmem_block, *tmp;
> +	unsigned long ntotal_pages;
> +
> +	cmem = container_of(ref, struct ib_cmem, refcount);
> +
> +	list_for_each_entry_safe(cmem_block, tmp, &cmem->ib_cmem_block, list) {
> +		__free_pages(cmem_block->page, cmem->block_order);
> +		list_del(&cmem_block->list);
> +		kfree(cmem_block);
> +	}
> +	/* no locking is needed:
> +	  * ib_cmem_release is called from vm_close which is always called
> +	  * with mm->mmap_sem held for writing.
> +	  * The only exception is when the process shutting down but in that case
> +	  * counter not relevant any more.
> +	  */
> +	if (current->mm) {
> +		ntotal_pages = PAGE_ALIGN(cmem->length) >> PAGE_SHIFT;
> +		current->mm->pinned_vm -= ntotal_pages;
> +	}
> +	kfree(cmem);
> +}
> +
> +/**
> + * ib_cmem_release_contiguous_pages - release memory allocated by
> + *                                              ib_cmem_alloc_contiguous_pages.
> + * @cmem: cmem struct to release
> + */
> +void ib_cmem_release_contiguous_pages(struct ib_cmem *cmem)
> +{
> +	kref_put(&cmem->refcount, ib_cmem_release);
> +}
> +EXPORT_SYMBOL(ib_cmem_release_contiguous_pages);
> +
> +static void cmem_vma_open(struct vm_area_struct *area)
> +{
> +	struct ib_cmem *ib_cmem;
> +
> +	ib_cmem = (struct ib_cmem *)(area->vm_private_data);
> +
> +	/* vm_open and vm_close are always called with mm->mmap_sem held for
> +	  * writing. The only exception is when the process is shutting down, at
> +	  * which point vm_close is called with no locks held, but since it is
> +	  * after the VMAs have been detached, it is impossible that vm_open will
> +	  * be called. Therefore, there is no need to synchronize the kref_get and
> +	  * kref_put calls.
> +	*/
> +	kref_get(&ib_cmem->refcount);
> +}
> +
> +static void cmem_vma_close(struct vm_area_struct *area)
> +{
> +	struct ib_cmem *cmem;
> +
> +	cmem = (struct ib_cmem *)(area->vm_private_data);
> +
> +	ib_cmem_release_contiguous_pages(cmem);
> +}
> +
> +static const struct vm_operations_struct cmem_contig_pages_vm_ops = {
> +	.open = cmem_vma_open,
> +	.close = cmem_vma_close
> +};
> +
> +/**
> + * ib_cmem_map_contiguous_pages_to_vma - map contiguous pages into VMA
> + * @ib_cmem: cmem structure returned by ib_cmem_alloc_contiguous_pages
> + * @vma: VMA to inject pages into.
> + */
> +int ib_cmem_map_contiguous_pages_to_vma(struct ib_cmem *ib_cmem,
> +					struct vm_area_struct *vma)
> +{
> +	int ret;
> +	unsigned long page_entry;
> +	unsigned long ntotal_pages;
> +	unsigned long ncontig_pages;
> +	unsigned long total_size;
> +	struct page *page;
> +	unsigned long vma_entry_number = 0;
> +	struct ib_cmem_block *ib_cmem_block = NULL;
> +
> +	total_size = vma->vm_end - vma->vm_start;
> +	if (ib_cmem->length != total_size)
> +		return -EINVAL;
> +
> +	if (total_size != PAGE_ALIGN(total_size)) {
> +		WARN(1,
> +		     "ib_cmem_map: total size %lu not aligned to page size\n",
> +		     total_size);
> +		return -EINVAL;
> +	}
> +
> +	ntotal_pages = total_size >> PAGE_SHIFT;
> +	ncontig_pages = 1 << ib_cmem->block_order;
> +
> +	list_for_each_entry(ib_cmem_block, &ib_cmem->ib_cmem_block, list) {
> +		page = ib_cmem_block->page;
> +		for (page_entry = 0; page_entry < ncontig_pages; page_entry++) {
> +			/* We reached end of vma - going out from both loops */
> +			if (vma_entry_number >= ntotal_pages)
> +				goto end;
> +
> +			ret = vm_insert_page(vma, vma->vm_start +
> +				(vma_entry_number << PAGE_SHIFT), page);
> +			if (ret < 0)
> +				goto err_vm_insert;
> +
> +			vma_entry_number++;
> +			page++;
> +		}
> +	}
> +
> +end:
> +
> +	/* We expect to have enough pages   */
> +	if (vma_entry_number >= ntotal_pages) {
> +		vma->vm_ops =  &cmem_contig_pages_vm_ops;
> +		vma->vm_private_data = ib_cmem;
> +		return 0;
> +	}
> +	/* Not expected but if we reached here
> +	  * not enough contiguous pages were registered
> +	  */
> +	ret = -EINVAL;
> +
> +err_vm_insert:
> +
> +	zap_vma_ptes(vma, vma->vm_start, total_size);
> +	return ret;
> +}
> +EXPORT_SYMBOL(ib_cmem_map_contiguous_pages_to_vma);
> +
> +/**
> + * ib_cmem_alloc_contiguous_pages - allocate contiguous pages
> + * @context: userspace context to allocate memory for
> + * @total_size: total required size for that allocation.
> + * @page_size_order: order of one contiguous page.
> + * @numa_nude: From which numa node to allocate memory
> + *             when numa_nude < 0 use default numa_nude.
> + */
> +struct ib_cmem *ib_cmem_alloc_contiguous_pages(struct ib_ucontext *context,
> +					       unsigned long total_size,
> +					       unsigned long page_size_order,
> +					       int numa_node)
> +{
> +	struct ib_cmem *cmem;
> +	unsigned long ntotal_pages;
> +	unsigned long ncontiguous_pages;
> +	unsigned long ncontiguous_groups;
> +	struct page *page;
> +	int i;
> +	int ncontiguous_pages_order;
> +	struct ib_cmem_block *ib_cmem_block;
> +	unsigned long locked;
> +	unsigned long lock_limit;
> +
> +	if (page_size_order < PAGE_SHIFT || page_size_order > 31)
> +		return ERR_PTR(-EINVAL);
> +
> +	cmem = kzalloc(sizeof(*cmem), GFP_KERNEL);
> +	if (!cmem)
> +		return ERR_PTR(-ENOMEM);
> +
> +	kref_init(&cmem->refcount);
> +	cmem->context   = context;
> +	INIT_LIST_HEAD(&cmem->ib_cmem_block);
> +
> +	/* Total size is expected to be already page aligned -
> +	  * verifying anyway.
> +	  */
> +	ntotal_pages = PAGE_ALIGN(total_size) >> PAGE_SHIFT;
> +	/* ib_cmem_alloc_contiguous_pages is called as part of mmap
> +	  * with mm->mmap_sem held for writing.
> +	  * No need to lock
> +	  */
> +	locked     = ntotal_pages + current->mm->pinned_vm;
> +	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> +
> +	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK))
> +		goto err_alloc;
> +
> +	/* How many contiguous pages do we need in 1 block */
> +	ncontiguous_pages = (1 << page_size_order) >> PAGE_SHIFT;
> +	ncontiguous_pages_order = ilog2(ncontiguous_pages);
> +	ncontiguous_groups = (ntotal_pages >> ncontiguous_pages_order)  +
> +		(!!(ntotal_pages & (ncontiguous_pages - 1)));
> +
> +	/* Checking MAX_ORDER to prevent WARN via calling alloc_pages below */
> +	if (ncontiguous_pages_order >= MAX_ORDER)
> +		goto err_alloc;
> +	/* we set block_order before starting allocation to prevent
> +	  * a leak in a failure flow in ib_cmem_release.
> +	  * cmem->length has at that step value 0 from kzalloc as expected
> +	  */
> +	cmem->block_order = ncontiguous_pages_order;
> +	for (i = 0; i < ncontiguous_groups; i++) {
> +		/* Allocating the managed entry */
> +		ib_cmem_block = kmalloc(sizeof(*ib_cmem_block),
> +					GFP_KERNEL);
> +		if (!ib_cmem_block)
> +			goto err_alloc;
> +
> +		if (numa_node < 0)
> +			page =  alloc_pages(GFP_HIGHUSER | __GFP_ZERO |
> +					    __GFP_COMP | __GFP_NOWARN,
> +					    ncontiguous_pages_order);
> +		else
> +			page =  alloc_pages_node(numa_node,
> +						 GFP_HIGHUSER | __GFP_ZERO |
> +						 __GFP_COMP | __GFP_NOWARN,
> +						 ncontiguous_pages_order);
> +
> +		if (!page) {
> +			kfree(ib_cmem_block);
> +			/* We should deallocate previous succeeded allocatations
> +			  * if exists.
> +			  */
> +			goto err_alloc;
> +		}
> +
> +		ib_cmem_block->page = page;
> +		list_add_tail(&ib_cmem_block->list, &cmem->ib_cmem_block);
> +	}
> +
> +	cmem->length = total_size;
> +	current->mm->pinned_vm = locked;
> +	return cmem;
> +
> +err_alloc:
> +	ib_cmem_release_contiguous_pages(cmem);
> +	return ERR_PTR(-ENOMEM);
> +}
> +EXPORT_SYMBOL(ib_cmem_alloc_contiguous_pages);
> diff --git a/include/rdma/ib_cmem.h b/include/rdma/ib_cmem.h
> new file mode 100644
> index 0000000..5f26a49
> --- /dev/null
> +++ b/include/rdma/ib_cmem.h
> @@ -0,0 +1,41 @@
> +#ifndef IB_CMEM_H
> +#define IB_CMEM_H
> +
> +#include <rdma/ib_umem.h>
> +#include <rdma/ib_verbs.h>
> +
> +/* contiguous memory structure */
> +struct ib_cmem {
> +	struct ib_ucontext     *context;
> +	size_t			length;
> +	/* Link list of contiguous blocks being part of that cmem  */
> +	struct list_head ib_cmem_block;
> +
> +	/* Order of cmem block,  2^ block_order will equal number
> +	  * of physical pages per block
> +	  */
> +	unsigned long    block_order;
> +	/* Refernce counter for that memory area
> +	  * When value became 0 pages will be returned to the kernel.
> +	  */
> +	struct kref refcount;
> +};
> +
> +struct ib_cmem_block {
> +	struct list_head	list;
> +	/* page will point to the page struct of the head page
> +	  * in the current compound page.
> +	  * block order is saved once as part of ib_cmem.
> +	  */
> +	struct page            *page;
> +};
> +
> +int ib_cmem_map_contiguous_pages_to_vma(struct ib_cmem *ib_cmem,
> +					struct vm_area_struct *vma);
> +struct ib_cmem *ib_cmem_alloc_contiguous_pages(struct ib_ucontext *context,
> +					       unsigned long total_size,
> +					       unsigned long page_size_order,
> +					       int numa_node);
> +void ib_cmem_release_contiguous_pages(struct ib_cmem *cmem);
> +
> +#endif
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
