Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7055E5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 06:55:28 -0400 (EDT)
Date: Mon, 20 Apr 2009 12:55:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH][RFC] videobuf-dma-config: zero copy USERPTR support
Message-ID: <20090420105459.GB6674@cmpxchg.org>
References: <20090420100003.8113.14986.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090420100003.8113.14986.sendpatchset@rx1.opensource.se>
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-media@vger.kernel.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 20, 2009 at 07:00:03PM +0900, Magnus Damm wrote:
> From: Magnus Damm <damm@igel.co.jp>
> 
> Zero copy video frame capture from user space using V4L2 USERPTR.
> 
> This patch adds USERPTR support to the videobuf-dma-contig buffer code.
> Since videobuf-dma-contig is designed to handle physically contiguous
> memory, this patch modifies the videobuf-dma-contig code to only accept
> a pointer physically contiguous memory. For now only VM_PFNMAP vmas are
> supported, so forget hotplug.
> 
> On SuperH Mobile we use this approach for our V4L2 CEU driver together
> with various multimedia accelerator blocks that are exported to user 
> space using UIO. The UIO kernel code exports physically contiugous memory
> to user space and lets the user space application mmap() this memory and
> pass a pointer using the USERPTR interface for V4L2 zero copy operation.
> 
> With this approach we support zero copy capture, hardware scaling and
> various forms of hardware encoding.
> 
> Hopefully this patch is useful for other SoCs. For user space example
> code I suggest having a look at the USERPTR implementation in capture.c.
> 
> Any comments? Does anyone need to use memory backed by struct page?
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  drivers/media/video/videobuf-dma-contig.c |  138 +++++++++++++++++++++++++++--
>  1 file changed, 131 insertions(+), 7 deletions(-)
> 
> --- 0001/drivers/media/video/videobuf-dma-contig.c
> +++ work/drivers/media/video/videobuf-dma-contig.c	2009-04-20 18:04:32.000000000 +0900
> @@ -17,6 +17,8 @@
>  #include <linux/init.h>
>  #include <linux/module.h>
>  #include <linux/mm.h>
> +#include <linux/hugetlb.h>
> +#include <linux/pagemap.h>
>  #include <linux/dma-mapping.h>
>  #include <media/videobuf-dma-contig.h>
>  
> @@ -25,6 +27,7 @@ struct videobuf_dma_contig_memory {
>  	void *vaddr;
>  	dma_addr_t dma_handle;
>  	unsigned long size;
> +	int is_userptr;
>  };
>  
>  #define MAGIC_DC_MEM 0x0733ac61
> @@ -108,6 +111,117 @@ static struct vm_operations_struct video
>  	.close    = videobuf_vm_close,
>  };
>  
> +static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
> +{
> +	mem->is_userptr = 0;
> +	mem->dma_handle = 0;
> +	mem->size = 0;
> +}
> +
> +/* modelled after follow_phys() in mm/memory.c */
> +static int get_pfn(struct vm_area_struct *vma,
> +		   unsigned long address, unsigned long *pfnp)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep, pte;
> +	spinlock_t *ptl;
> +
> +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
> +		goto no_page_table;
> +
> +	pgd = pgd_offset(mm, address);
> +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> +		goto no_page_table;
> +
> +	pud = pud_offset(pgd, address);
> +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> +		goto no_page_table;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> +		goto no_page_table;
> +
> +	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
> +	if (pmd_huge(*pmd))
> +		goto no_page_table;
> +
> +	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (!ptep)
> +		goto no_page_table;
> +
> +	pte = *ptep;
> +	if (!pte_present(pte))
> +		goto unlock;
> +
> +	*pfnp = pte_pfn(pte);
> +	pte_unmap_unlock(ptep, ptl);
> +	return 0;
> +unlock:
> +	pte_unmap_unlock(ptep, ptl);
> +no_page_table:
> +	return -EINVAL;
> +}

It would be nice to have a follow_pfn() instead that shares its body
with follow_phys().

> +static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
> +					struct videobuf_buffer *vb)
> +{
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	unsigned long prev_pfn, this_pfn;
> +	unsigned long pages_done, user_address;
> +	int ret;
> +
> +	mem->size = PAGE_ALIGN(vb->size);
> +	mem->is_userptr = 0;
> +	ret = -EINVAL;
> +
> +	down_read(&mm->mmap_sem);
> +
> +	vma = find_vma(mm, vb->baddr);
> +	if (!vma)
> +		goto out_up;
> +
> +	if ((vb->baddr + mem->size) > vma->vm_end)
> +		goto out_up;
> +
> +	pages_done = 0;
> +	prev_pfn = 0; /* kill warning */
> +	user_address = vb->baddr;
> +
> +	while (pages_done < (mem->size >> PAGE_SHIFT)) {
> +		ret = get_pfn(vma, user_address, &this_pfn);
> +		if (ret)
> +			break;
> +
> +		if (pages_done == 0) {
> +			prev_pfn = this_pfn;
> +			mem->dma_handle = this_pfn << PAGE_SHIFT;
> +		} else {
> +			if (this_pfn != (prev_pfn + 1))
> +				ret = -EFAULT;

} else if (...) ?

> +		}
> +
> +		if (ret)
> +			break;
> +
> +		prev_pfn = this_pfn;
> +		user_address += PAGE_SIZE;
> +		pages_done++;
> +	}
> +
> +	if (!ret && pages_done)

If ret is zero, pages_done is always non-zero.

> +		mem->is_userptr = 1;
> +
> + out_up:
> +	up_read(&current->mm->mmap_sem);
> +
> +	return ret;
> +}
> +

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
