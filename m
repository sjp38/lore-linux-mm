Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 605AA6B0073
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 18:09:55 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id 19so10552091ykq.10
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 15:09:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k70si9825306yhq.173.2015.01.12.15.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 15:09:54 -0800 (PST)
Date: Mon, 12 Jan 2015 15:09:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 08/20] dax,ext2: Replace the XIP page fault handler
 with the DAX page fault handler
Message-Id: <20150112150952.b44ee750a6292284e7a909ff@linux-foundation.org>
In-Reply-To: <1414185652-28663-9-git-send-email-matthew.r.wilcox@intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<1414185652-28663-9-git-send-email-matthew.r.wilcox@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Fri, 24 Oct 2014 17:20:40 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:

> Instead of calling aops->get_xip_mem from the fault handler, the
> filesystem passes a get_block_t that is used to find the appropriate
> blocks.
> 
> ...
>
> +static int copy_user_bh(struct page *to, struct buffer_head *bh,
> +			unsigned blkbits, unsigned long vaddr)
> +{
> +	void *vfrom, *vto;
> +	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
> +		return -EIO;
> +	vto = kmap_atomic(to);
> +	copy_user_page(vto, vfrom, vaddr, to);
> +	kunmap_atomic(vto);

Again, please check the cache-flush aspects.  copy_user_page() appears
to be reponsible for handling coherency issues on the destination
vaddr, but what about *vto?

> +	return 0;
> +}
> +
> +static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
> +			struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	struct address_space *mapping = inode->i_mapping;
> +	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	void *addr;
> +	unsigned long pfn;
> +	pgoff_t size;
> +	int error;
> +
> +	mutex_lock(&mapping->i_mmap_mutex);
> +
> +	/*
> +	 * Check truncate didn't happen while we were allocating a block.
> +	 * If it did, this block may or may not be still allocated to the
> +	 * file.  We can't tell the filesystem to free it because we can't
> +	 * take i_mutex here.

(what's preventing us from taking i_mutex?)

>  	   In the worst case, the file still has blocks
> +	 * allocated past the end of the file.
> +	 */
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (unlikely(vmf->pgoff >= size)) {
> +		error = -EIO;
> +		goto out;
> +	}

How does this play with holepunching?  Checking i_size won't work there?

> +	error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
> +	if (error < 0)
> +		goto out;
> +	if (error < PAGE_SIZE) {
> +		error = -EIO;
> +		goto out;

hm, what's going on here.  It's known that bh->b_size >= PAGE_SIZE?  I
don't recall seeing anything which explained that to me.  Help.

> +	}
> +
> +	if (buffer_unwritten(bh) || buffer_new(bh))
> +		clear_page(addr);
> +
> +	error = vm_insert_mixed(vma, vaddr, pfn);
> +
> + out:
> +	mutex_unlock(&mapping->i_mmap_mutex);
> +
> +	if (bh->b_end_io)
> +		bh->b_end_io(bh, 1);
> +
> +	return error;
> +}
> +
> +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	struct file *file = vma->vm_file;
> +	struct address_space *mapping = file->f_mapping;
> +	struct inode *inode = mapping->host;
> +	struct page *page;
> +	struct buffer_head bh;
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	unsigned blkbits = inode->i_blkbits;
> +	sector_t block;
> +	pgoff_t size;
> +	int error;
> +	int major = 0;
> +
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
> +	bh.b_size = PAGE_SIZE;

ah, there.

PAGE_SIZE varies a lot between architectures.  What are the
implications of this>?

> + repeat:
> +	page = find_get_page(mapping, vmf->pgoff);
> +	if (page) {
> +		if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
> +			page_cache_release(page);
> +			return VM_FAULT_RETRY;
> +		}
> +		if (unlikely(page->mapping != mapping)) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		if (unlikely(vmf->pgoff >= size)) {
> +			error = -EIO;

What happened when this happens?

> +			goto unlock_page;
> +		}
> +	}
> +
> +	error = get_block(inode, block, &bh, 0);
> +	if (!error && (bh.b_size < PAGE_SIZE))
> +		error = -EIO;

How could this happen?

> +	if (error)
> +		goto unlock_page;
> +
> +	if (!buffer_mapped(&bh) && !buffer_unwritten(&bh) && !vmf->cow_page) {
> +		if (vmf->flags & FAULT_FLAG_WRITE) {
> +			error = get_block(inode, block, &bh, 1);
> +			count_vm_event(PGMAJFAULT);
> +			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +			major = VM_FAULT_MAJOR;
> +			if (!error && (bh.b_size < PAGE_SIZE))
> +				error = -EIO;
> +			if (error)
> +				goto unlock_page;
> +		} else {
> +			return dax_load_hole(mapping, page, vmf);
> +		}
> +	}
> +
> +	if (vmf->cow_page) {
> +		struct page *new_page = vmf->cow_page;
> +		if (buffer_written(&bh))
> +			error = copy_user_bh(new_page, &bh, blkbits, vaddr);
> +		else
> +			clear_user_highpage(new_page, vaddr);
> +		if (error)
> +			goto unlock_page;
> +		vmf->page = page;
> +		if (!page) {
> +			mutex_lock(&mapping->i_mmap_mutex);
> +			/* Check we didn't race with truncate */
> +			size = (i_size_read(inode) + PAGE_SIZE - 1) >>
> +								PAGE_SHIFT;
> +			if (vmf->pgoff >= size) {
> +				mutex_unlock(&mapping->i_mmap_mutex);
> +				error = -EIO;
> +				goto out;
> +			}
> +		}
> +		return VM_FAULT_LOCKED;
> +	}
> +
> +	/* Check we didn't race with a read fault installing a new page */
> +	if (!page && major)
> +		page = find_lock_page(mapping, vmf->pgoff);
> +
> +	if (page) {
> +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> +							PAGE_CACHE_SIZE, 0);
> +		delete_from_page_cache(page);
> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +
> +	error = dax_insert_mapping(inode, &bh, vma, vmf);
> +
> + out:
> +	if (error == -ENOMEM)
> +		return VM_FAULT_OOM | major;
> +	/* -EBUSY is fine, somebody else faulted on the same PTE */
> +	if ((error < 0) && (error != -EBUSY))
> +		return VM_FAULT_SIGBUS | major;
> +	return VM_FAULT_NOPAGE | major;
> +
> + unlock_page:
> +	if (page) {
> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +	goto out;
> +}
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
