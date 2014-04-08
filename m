Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3E36B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 18:05:31 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so1206550eek.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 15:05:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si4540677eel.163.2014.04.08.15.05.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 15:05:29 -0700 (PDT)
Date: Wed, 9 Apr 2014 00:05:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140408220525.GC26019@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:33, Matthew Wilcox wrote:
> Instead of calling aops->get_xip_mem from the fault handler, the
> filesystem passes a get_block_t that is used to find the appropriate
> blocks.
  I have some suggestions below...

> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  fs/dax.c           | 207 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/ext2/file.c     |  35 ++++++++-
>  include/linux/fs.h |   4 +-
>  mm/filemap_xip.c   | 206 ----------------------------------------------------
>  4 files changed, 243 insertions(+), 209 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 66a6bda..863749c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -19,8 +19,12 @@
>  #include <linux/buffer_head.h>
>  #include <linux/fs.h>
>  #include <linux/genhd.h>
> +#include <linux/highmem.h>
> +#include <linux/memcontrol.h>
> +#include <linux/mm.h>
>  #include <linux/mutex.h>
>  #include <linux/uio.h>
> +#include <linux/vmstat.h>
>  
>  static long dax_get_addr(struct inode *inode, struct buffer_head *bh,
>  								void **addr)
> @@ -32,6 +36,16 @@ static long dax_get_addr(struct inode *inode, struct buffer_head *bh,
>  	return ops->direct_access(bdev, sector, addr, &pfn, bh->b_size);
>  }
>  
> +static long dax_get_pfn(struct inode *inode, struct buffer_head *bh,
> +							unsigned long *pfn)
> +{
> +	struct block_device *bdev = bh->b_bdev;
> +	const struct block_device_operations *ops = bdev->bd_disk->fops;
> +	void *addr;
> +	sector_t sector = bh->b_blocknr << (inode->i_blkbits - 9);
> +	return ops->direct_access(bdev, sector, &addr, pfn, bh->b_size);
> +}
> +
>  static void dax_new_buf(void *addr, unsigned size, unsigned first,
>  					loff_t offset, loff_t end, int rw)
>  {
> @@ -214,3 +228,196 @@ ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
>  	return retval;
>  }
>  EXPORT_SYMBOL_GPL(dax_do_io);
> +
> +/*
> + * The user has performed a load from a hole in the file.  Allocating
> + * a new page in the file would cause excessive storage usage for
> + * workloads with sparse files.  We allocate a page cache page instead.
> + * We'll kick it out of the page cache if it's ever written to,
> + * otherwise it will simply fall out of the page cache under memory
> + * pressure without ever having been dirtied.
> + */
> +static int dax_load_hole(struct address_space *mapping, struct page *page,
> +							struct vm_fault *vmf)
> +{
> +	unsigned long size;
> +	struct inode *inode = mapping->host;
> +	if (!page)
> +		page = find_or_create_page(mapping, vmf->pgoff,
> +						GFP_KERNEL | __GFP_ZERO);
> +	if (!page)
> +		return VM_FAULT_OOM;
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size) {
  Maybe comment here that we have to recheck i_size so that we don't create
pages in the area truncate_pagecache() has already evicted.

> +		unlock_page(page);
> +		page_cache_release(page);
> +		return VM_FAULT_SIGBUS;
> +	}
> +
> +	vmf->page = page;
> +	return VM_FAULT_LOCKED;
> +}
> +
> +static void copy_user_bh(struct page *to, struct inode *inode,
> +				struct buffer_head *bh, unsigned long vaddr)
> +{
> +	void *vfrom, *vto;
> +	dax_get_addr(inode, bh, &vfrom);	/* XXX: error handling */
  The error handling here is missing as the comment suggests :)

> +	vto = kmap_atomic(to);
> +	copy_user_page(vto, vfrom, vaddr, to);
> +	kunmap_atomic(vto);
> +}
> +
> +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	struct file *file = vma->vm_file;
> +	struct inode *inode = file_inode(file);
> +	struct address_space *mapping = file->f_mapping;
> +	struct page *page;
> +	struct buffer_head bh;
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	sector_t block;
> +	pgoff_t size;
> +	unsigned long pfn;
> +	int error;
> +	int major = 0;
> +
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - inode->i_blkbits);
> +	bh.b_size = PAGE_SIZE;
> +
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
> +	}
> +
> +	error = get_block(inode, block, &bh, 0);
> +	if (error || bh.b_size < PAGE_SIZE)
> +		goto sigbus;
> +
> +	if (!buffer_written(&bh) && !vmf->cow_page) {
> +		if (vmf->flags & FAULT_FLAG_WRITE) {
> +			error = get_block(inode, block, &bh, 1);
> +			count_vm_event(PGMAJFAULT);
> +			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
> +			major = VM_FAULT_MAJOR;
> +			if (error || bh.b_size < PAGE_SIZE)
> +				goto sigbus;
> +		} else {
> +			return dax_load_hole(mapping, page, vmf);
> +		}
> +	}
> +
> +	/* Recheck i_size under i_mmap_mutex */
> +	mutex_lock(&mapping->i_mmap_mutex);
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (unlikely(vmf->pgoff >= size)) {
> +		mutex_unlock(&mapping->i_mmap_mutex);
> +		goto sigbus;
> +	}
> +	if (vmf->cow_page) {
> +		if (buffer_written(&bh))
> +			copy_user_bh(vmf->cow_page, inode, &bh, vaddr);
> +		else
> +			clear_user_highpage(vmf->cow_page, vaddr);
> +		if (page) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +		}
> +		/* do_cow_fault() will release the i_mmap_mutex */
> +		return VM_FAULT_COWED;
> +	}
> +
> +	if (buffer_unwritten(&bh) || buffer_new(&bh))
> +		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
  Where is dax_clear_blocks() defined?

> +
> +	error = dax_get_pfn(inode, &bh, &pfn);
> +	if (error > 0)
> +		error = vm_insert_mixed(vma, vaddr, pfn);
  When there's a hole (thus page != NULL) and we are called from
dax_mkwrite(), this will always return EBUSY, correct?

> +	mutex_unlock(&mapping->i_mmap_mutex);
> +
> +	if (page) {
> +		delete_from_page_cache(page);
> +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> +							PAGE_CACHE_SIZE, 0);
  Here we unmap the PTE pointing to the hole page but then we'll have to
retry the fault again to fill in the pfn we've got? This seems wrong. I'd
say we want to remap the PTE from the hole page to a pfn we've got while
holding i_mmap_mutex. remap_pfn_range() almost does what you need, except
that you also need that to work for normal pages. So you might need to
create a new helper in mm layer for that.

> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +
> +	if (error == -ENOMEM)
> +		return VM_FAULT_OOM;
> +	/* -EBUSY is fine, somebody else faulted on the same PTE */
> +	if (error != -EBUSY)
> +		BUG_ON(error);
> +	return VM_FAULT_NOPAGE | major;
> +
> + sigbus:
> +	if (page) {
> +		unlock_page(page);
> +		page_cache_release(page);
> +	}
> +	return VM_FAULT_SIGBUS;
> +}
> +
> +/**
> + * dax_fault - handle a page fault on an XIP file
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * When a page fault occurs, filesystems may call this helper in their
> + * fault handler for XIP files.
> + */
> +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	int result;
> +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +
> +	sb_start_pagefault(sb);
  You don't need any filesystem freeze protection for the fault handler
since that's not going to modify the filesystem.

> +	file_update_time(vma->vm_file);
  Why do you update m/ctime? We are only reading the file...

> +	result = do_dax_fault(vma, vmf, get_block);
> +	sb_end_pagefault(sb);
> +
> +	return result;
> +}
> +EXPORT_SYMBOL_GPL(dax_fault);
> +
> +/**
> + * dax_mkwrite - convert a read-only page to read-write in an XIP file
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * XIP handles reads of holes by adding pages full of zeroes into the
> + * mapping.  If the page is subsequenty written to, we have to allocate
> + * the page on media and free the page that was in the cache.
> + */
> +int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	int result;
> +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +
> +	sb_start_pagefault(sb);
> +	file_update_time(vma->vm_file);
> +	result = do_dax_fault(vma, vmf, get_block);
> +	sb_end_pagefault(sb);
> +
> +	return result;
> +}
> +EXPORT_SYMBOL_GPL(dax_mkwrite);
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index ef5cf96..e3ce10d 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -25,6 +25,37 @@
>  #include "xattr.h"
>  #include "acl.h"
>  
> +#ifdef CONFIG_EXT2_FS_XIP
> +static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	return dax_fault(vma, vmf, ext2_get_block);
> +}
> +
> +static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	return dax_mkwrite(vma, vmf, ext2_get_block);
> +}
> +
> +static const struct vm_operations_struct ext2_dax_vm_ops = {
> +	.fault		= ext2_dax_fault,
> +	.page_mkwrite	= ext2_dax_mkwrite,
> +	.remap_pages	= generic_file_remap_pages,
> +};
> +
> +static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	if (!IS_DAX(file_inode(file)))
> +		return generic_file_mmap(file, vma);
> +
> +	file_accessed(file);
> +	vma->vm_ops = &ext2_dax_vm_ops;
> +	vma->vm_flags |= VM_MIXEDMAP;
> +	return 0;
> +}
> +#else
> +#define ext2_file_mmap	generic_file_mmap
> +#endif
> +
>  /*
>   * Called when filp is released. This happens when all file descriptors
>   * for a single struct file are closed. Note that different open() calls
> @@ -70,7 +101,7 @@ const struct file_operations ext2_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= ext2_compat_ioctl,
>  #endif
> -	.mmap		= generic_file_mmap,
> +	.mmap		= ext2_file_mmap,
  So what's the point of ext2_file_operations ever handling IS_DAX()
inodes? Actually ext2_file_operations and ext2_xip_file_operations seem to
be the same after this patch so either you drop ext2_xip_file_operations
(I'm for this) or you can leave generic_file_mmap here and assume
ext2_file_mmap is always called for IS_DAX() inodes.

>  	.open		= dquot_file_open,
>  	.release	= ext2_release_file,
>  	.fsync		= ext2_fsync,
> @@ -89,7 +120,7 @@ const struct file_operations ext2_xip_file_operations = {
>  #ifdef CONFIG_COMPAT
>  	.compat_ioctl	= ext2_compat_ioctl,
>  #endif
> -	.mmap		= xip_file_mmap,
> +	.mmap		= ext2_file_mmap,
>  	.open		= dquot_file_open,
>  	.release	= ext2_release_file,
>  	.fsync		= ext2_fsync,

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
