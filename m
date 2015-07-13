Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 724E96B0256
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 11:05:04 -0400 (EDT)
Received: by lbbzr7 with SMTP id zr7so3694025lbb.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:05:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id un9si15809380wjc.60.2015.07.13.08.05.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jul 2015 08:05:02 -0700 (PDT)
Date: Mon, 13 Jul 2015 17:05:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 07/10] dax: Add huge page fault support
Message-ID: <20150713150500.GB17075@quack.suse.cz>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
 <1436560165-8943-8-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436560165-8943-8-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Fri 10-07-15 16:29:22, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> This is the support code for DAX-enabled filesystems to allow them to
> provide huge pages in response to faults.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

...

> +int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> +		pmd_t *pmd, unsigned int flags, get_block_t get_block,
> +		dax_iodone_t complete_unwritten)
> +{
> +	struct file *file = vma->vm_file;
> +	struct address_space *mapping = file->f_mapping;
> +	struct inode *inode = mapping->host;
> +	struct buffer_head bh;
> +	unsigned blkbits = inode->i_blkbits;
> +	unsigned long pmd_addr = address & PMD_MASK;
> +	bool write = flags & FAULT_FLAG_WRITE;
> +	long length;
> +	void *kaddr;
> +	pgoff_t size, pgoff;
> +	sector_t block, sector;
> +	unsigned long pfn;
> +	int result = 0;
> +
> +	/* Fall back to PTEs if we're going to COW */
> +	if (write && !(vma->vm_flags & VM_SHARED))
> +		return VM_FAULT_FALLBACK;
> +	/* If the PMD would extend outside the VMA */
> +	if (pmd_addr < vma->vm_start)
> +		return VM_FAULT_FALLBACK;
> +	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
> +		return VM_FAULT_FALLBACK;
> +
> +	pgoff = ((pmd_addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +	/* If the PMD would cover blocks out of the file */
> +	if ((pgoff | PG_PMD_COLOUR) >= size)
> +		return VM_FAULT_FALLBACK;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = (sector_t)pgoff << (PAGE_SHIFT - blkbits);
> +
> +	bh.b_size = PMD_SIZE;
> +	length = get_block(inode, block, &bh, write);
> +	if (length)
> +		return VM_FAULT_SIGBUS;
> +	i_mmap_lock_read(mapping);
> +
> +	/*
> +	 * If the filesystem isn't willing to tell us the length of a hole,
> +	 * just fall back to PTEs.  Calling get_block 512 times in a loop
> +	 * would be silly.
> +	 */
> +	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
> +		goto fallback;
> +
> +	/* Guard against a race with truncate */
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (pgoff >= size) {
> +		result = VM_FAULT_SIGBUS;
> +		goto out;
> +	}

So if this is a writeable fault and we race with truncate, we can leave
stale blocks beyond i_size, can't we? Ah, looking at dax_insert_mapping()
this seems to be a documented quirk of DAX mmap code. Would be worth
mentioning here as well so that people don't wonder...

Otherwise the patch looks good to me.

								Honza

> +	if ((pgoff | PG_PMD_COLOUR) >= size)
> +		goto fallback;
> +
> +	if (is_huge_zero_pmd(*pmd))
> +		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
> +
> +	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
> +		bool set;
> +		spinlock_t *ptl;
> +		struct mm_struct *mm = vma->vm_mm;
> +		struct page *zero_page = get_huge_zero_page();
> +		if (unlikely(!zero_page))
> +			goto fallback;
> +
> +		ptl = pmd_lock(mm, pmd);
> +		set = set_huge_zero_page(NULL, mm, vma, pmd_addr, pmd,
> +								zero_page);
> +		spin_unlock(ptl);
> +		result = VM_FAULT_NOPAGE;
> +	} else {
> +		sector = bh.b_blocknr << (blkbits - 9);
> +		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
> +						bh.b_size);
> +		if (length < 0) {
> +			result = VM_FAULT_SIGBUS;
> +			goto out;
> +		}
> +		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
> +			goto fallback;
> +
> +		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> +			int i;
> +			for (i = 0; i < PTRS_PER_PMD; i++)
> +				clear_page(kaddr + i * PAGE_SIZE);
> +			count_vm_event(PGMAJFAULT);
> +			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +			result |= VM_FAULT_MAJOR;
> +		}
> +
> +		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
> +	}
> +
> + out:
> +	i_mmap_unlock_read(mapping);
> +
> +	if (buffer_unwritten(&bh))
> +		complete_unwritten(&bh, !(result & VM_FAULT_ERROR));
> +
> +	return result;
> +
> + fallback:
> +	count_vm_event(THP_FAULT_FALLBACK);
> +	result = VM_FAULT_FALLBACK;
> +	goto out;
> +}
> +EXPORT_SYMBOL_GPL(__dax_pmd_fault);
> +
> +/**
> + * dax_pmd_fault - handle a PMD fault on a DAX file
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * When a page fault occurs, filesystems may call this helper in their
> + * pmd_fault handler for DAX files.
> + */
> +int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> +			pmd_t *pmd, unsigned int flags, get_block_t get_block,
> +			dax_iodone_t complete_unwritten)
> +{
> +	int result;
> +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +
> +	if (flags & FAULT_FLAG_WRITE) {
> +		sb_start_pagefault(sb);
> +		file_update_time(vma->vm_file);
> +	}
> +	result = __dax_pmd_fault(vma, address, pmd, flags, get_block,
> +				complete_unwritten);
> +	if (flags & FAULT_FLAG_WRITE)
> +		sb_end_pagefault(sb);
> +
> +	return result;
> +}
> +EXPORT_SYMBOL_GPL(dax_pmd_fault);
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGES */
> +
>  /**
>   * dax_pfn_mkwrite - handle first write to DAX page
>   * @vma: The virtual memory area where the fault occurred
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 9b51f9d..b415e52 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -14,6 +14,20 @@ int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
>  		dax_iodone_t);
>  int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
>  		dax_iodone_t);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
> +				unsigned int flags, get_block_t, dax_iodone_t);
> +int __dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
> +				unsigned int flags, get_block_t, dax_iodone_t);
> +#else
> +static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
> +				pmd_t *pmd, unsigned int flags, get_block_t gb,
> +				dax_iodone_t di)
> +{
> +	return VM_FAULT_FALLBACK;
> +}
> +#define __dax_pmd_fault dax_pmd_fault
> +#endif
>  int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
>  #define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
>  #define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
