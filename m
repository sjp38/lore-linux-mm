Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4A51D6B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:57:15 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so1890653pde.18
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:57:14 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id pg1si1560809pdb.486.2014.07.23.09.57.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 09:57:14 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so1927879pde.4
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:57:13 -0700 (PDT)
Message-ID: <53CFE965.5020304@gmail.com>
Date: Wed, 23 Jul 2014 19:57:09 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 10/22] Replace the XIP page fault handler with the
 DAX page fault handler
References: <cover.1406058387.git.matthew.r.wilcox@intel.com> <00ad731b459e32ce965af8530bcd611a141e41b6.1406058387.git.matthew.r.wilcox@intel.com>
In-Reply-To: <00ad731b459e32ce965af8530bcd611a141e41b6.1406058387.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: willy@linux.intel.com

On 07/22/2014 10:47 PM, Matthew Wilcox wrote:
> Instead of calling aops->get_xip_mem from the fault handler, the
> filesystem passes a get_block_t that is used to find the appropriate
> blocks.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c           | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/ext2/file.c     |  35 ++++++++-
>  include/linux/fs.h |   4 +-
>  mm/filemap_xip.c   | 206 -------------------------------------------------
>  4 files changed, 257 insertions(+), 209 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 02e226f..4ab4890 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -19,9 +19,13 @@
>  #include <linux/buffer_head.h>
>  #include <linux/fs.h>
>  #include <linux/genhd.h>
> +#include <linux/highmem.h>
> +#include <linux/memcontrol.h>
> +#include <linux/mm.h>
>  #include <linux/mutex.h>
>  #include <linux/sched.h>
>  #include <linux/uio.h>
> +#include <linux/vmstat.h>
>  
>  int dax_clear_blocks(struct inode *inode, sector_t block, long size)
>  {
> @@ -64,6 +68,14 @@ static long dax_get_addr(struct buffer_head *bh, void **addr, unsigned blkbits)
>  	return bdev_direct_access(bh->b_bdev, sector, addr, &pfn, bh->b_size);
>  }
>  
> +static long dax_get_pfn(struct buffer_head *bh, unsigned long *pfn,
> +							unsigned blkbits)
> +{
> +	void *addr;
> +	sector_t sector = bh->b_blocknr << (blkbits - 9);
> +	return bdev_direct_access(bh->b_bdev, sector, &addr, pfn, bh->b_size);
> +}
> +
>  static void dax_new_buf(void *addr, unsigned size, unsigned first, loff_t pos,
>  			loff_t end)
>  {
> @@ -228,3 +240,212 @@ ssize_t dax_do_io(int rw, struct kiocb *iocb, struct inode *inode,
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

Do you like this ?? I understand that you cannot use the ZERO page or
such global page on a page cache since each instance needs its own
list_head/index/mapping and so on. But why use any page at all.

use a global ZERO page, either the system global, or static local to
this system. map it to the current application VMA in question, using it's
pfn (page_to_pfn) just like you do with real DAX-blocks from prd.

Then at mkwrite you can compare the current pte's pfn to the page_to_pfn(ZERO_PAGE)
or just re--block-get the block and if it is an hole you know it was the ZERO_PAGE,

and so use the vma_replace to set in an allocated real dax-block for writing.

Surly we should be able to stay on the pfn and virtual pointers domain without
use of any pages, also for this trivial zero-blocks stuff, No?

All that said there is something I do not understand in this code and the old code
as well. Please help.

Say app A reads an hole, then app B reads an hole. Both now point to the same
zero page pfn, now say app B writes to that hole, mkwrite will convert it to
a real dax-block pfn and will map the new pfn in the faulting vma. But what about
app A, will it read the old pfn? who loops on all VMA's that have some mapping
and invalidates those mapping.

Same with truncate. App A mmap-read a block, app B does a read-mmap then a truncate.
who loops on all VMA mappings of these blocks to invalidate them. With page-cache and
pages we have a list of all VMA's that currently have mappings on a page, but with
dax-pfns (dax-blocks) we do *not* have page struct, who keeps the list of current
active vma-mappings?

(I know it must be there just can't register where in code, probably need to read
 this more carefully)

Thanks
Boaz

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
> +	/* Recheck i_size under page lock to avoid truncate race */
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size) {
> +		unlock_page(page);
> +		page_cache_release(page);
> +		return VM_FAULT_SIGBUS;
> +	}
> +
> +	vmf->page = page;
> +	return VM_FAULT_LOCKED;
> +}
> +
> +static int copy_user_bh(struct page *to, struct buffer_head *bh,
> +			unsigned blkbits, unsigned long vaddr)
> +{
> +	void *vfrom, *vto;
> +	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
> +		return -EIO;
> +	vto = kmap_atomic(to);
> +	copy_user_page(vto, vfrom, vaddr, to);
> +	kunmap_atomic(vto);
> +	return 0;
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
> +	unsigned blkbits = inode->i_blkbits;
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
> +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
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
> +	} else {
> +		mutex_lock(&mapping->i_mmap_mutex);
> +	}
> +
> +	/* Guard against a race with truncate */
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (unlikely(vmf->pgoff >= size))
> +		goto sigbus;
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
> +			mutex_unlock(&mapping->i_mmap_mutex);
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
> +		if (!error) {
> +			__SetPageUptodate(new_page);
> +			vm_insert_page(vma, vaddr, new_page);
> +		}
> +		if (page) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +		} else {
> +			mutex_unlock(&mapping->i_mmap_mutex);
> +		}
> +		return error ? VM_FAULT_SIGBUS : VM_FAULT_NOPAGE;
> +	}
> +
> +	if (buffer_unwritten(&bh) || buffer_new(&bh))
> +		dax_clear_blocks(inode, bh.b_blocknr, bh.b_size);
> +
> +	error = dax_get_pfn(&bh, &pfn, blkbits);
> +	if (error > 0)
> +		error = vm_replace_mixed(vma, vaddr, pfn);
> +
> +	if (!page) {
> +		mutex_unlock(&mapping->i_mmap_mutex);
> +		/*
> +		 * We may have raced with another thread which has inserted
> +		 * a zero page at this address.  Remove it now if we did.
> +		 */
> +		page = find_lock_page(mapping, vmf->pgoff);
> +	}
> +
> +	if (page) {
> +		delete_from_page_cache(page);
> +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> +							PAGE_CACHE_SIZE, 0);
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
> +	} else {
> +		mutex_unlock(&mapping->i_mmap_mutex);
> +	}
> +	return VM_FAULT_SIGBUS;
> +}
> +
> +/**
> + * dax_fault - handle a page fault on a DAX file
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * When a page fault occurs, filesystems may call this helper in their
> + * fault handler for DAX files.
> + */
> +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	int result;
> +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +
> +	if (vmf->flags & FAULT_FLAG_WRITE) {
> +		sb_start_pagefault(sb);
> +		file_update_time(vma->vm_file);
> +	}
> +	result = do_dax_fault(vma, vmf, get_block);
> +	if (vmf->flags & FAULT_FLAG_WRITE)
> +		sb_end_pagefault(sb);
> +
> +	return result;
> +}
> +EXPORT_SYMBOL_GPL(dax_fault);
> +
> +/**
> + * dax_mkwrite - convert a read-only page to read-write in a DAX file
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + * @get_block: The filesystem method used to translate file offsets to blocks
> + *
> + * DAX handles reads of holes by adding pages full of zeroes into the
> + * mapping.  If the page is subsequenty written to, we have to allocate
> + * the page on media and free the page that was in the cache.
> + */
> +int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	return dax_fault(vma, vmf, get_block);
> +}
> +EXPORT_SYMBOL_GPL(dax_mkwrite);
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index a247123..da8dc64 100644
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
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index e38138b..d4259e1 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -49,6 +49,7 @@ struct swap_info_struct;
>  struct seq_file;
>  struct workqueue_struct;
>  struct iov_iter;
> +struct vm_fault;
>  
>  extern void __init inode_init(void);
>  extern void __init inode_init_early(void);
> @@ -2464,10 +2465,11 @@ extern int nonseekable_open(struct inode * inode, struct file * filp);
>  
>  #ifdef CONFIG_FS_XIP
>  int dax_clear_blocks(struct inode *, sector_t block, long size);
> -extern int xip_file_mmap(struct file * file, struct vm_area_struct * vma);
>  extern int xip_truncate_page(struct address_space *mapping, loff_t from);
>  ssize_t dax_do_io(int rw, struct kiocb *, struct inode *, struct iov_iter *,
>  		loff_t, get_block_t, dio_iodone_t, int flags);
> +int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
> +int dax_mkwrite(struct vm_area_struct *, struct vm_fault *, get_block_t);
>  #else
>  static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
>  {
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index f7c37a1..9dd45f3 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -22,212 +22,6 @@
>  #include <asm/io.h>
>  
>  /*
> - * We do use our own empty page to avoid interference with other users
> - * of ZERO_PAGE(), such as /dev/zero
> - */
> -static DEFINE_MUTEX(xip_sparse_mutex);
> -static seqcount_t xip_sparse_seq = SEQCNT_ZERO(xip_sparse_seq);
> -static struct page *__xip_sparse_page;
> -
> -/* called under xip_sparse_mutex */
> -static struct page *xip_sparse_page(void)
> -{
> -	if (!__xip_sparse_page) {
> -		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_ZERO);
> -
> -		if (page)
> -			__xip_sparse_page = page;
> -	}
> -	return __xip_sparse_page;
> -}
> -
> -/*
> - * __xip_unmap is invoked from xip_unmap and
> - * xip_write
> - *
> - * This function walks all vmas of the address_space and unmaps the
> - * __xip_sparse_page when found at pgoff.
> - */
> -static void
> -__xip_unmap (struct address_space * mapping,
> -		     unsigned long pgoff)
> -{
> -	struct vm_area_struct *vma;
> -	struct mm_struct *mm;
> -	unsigned long address;
> -	pte_t *pte;
> -	pte_t pteval;
> -	spinlock_t *ptl;
> -	struct page *page;
> -	unsigned count;
> -	int locked = 0;
> -
> -	count = read_seqcount_begin(&xip_sparse_seq);
> -
> -	page = __xip_sparse_page;
> -	if (!page)
> -		return;
> -
> -retry:
> -	mutex_lock(&mapping->i_mmap_mutex);
> -	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
> -		mm = vma->vm_mm;
> -		address = vma->vm_start +
> -			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> -		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> -		pte = page_check_address(page, mm, address, &ptl, 1);
> -		if (pte) {
> -			/* Nuke the page table entry. */
> -			flush_cache_page(vma, address, pte_pfn(*pte));
> -			pteval = ptep_clear_flush(vma, address, pte);
> -			page_remove_rmap(page);
> -			dec_mm_counter(mm, MM_FILEPAGES);
> -			BUG_ON(pte_dirty(pteval));
> -			pte_unmap_unlock(pte, ptl);
> -			/* must invalidate_page _before_ freeing the page */
> -			mmu_notifier_invalidate_page(mm, address);
> -			page_cache_release(page);
> -		}
> -	}
> -	mutex_unlock(&mapping->i_mmap_mutex);
> -
> -	if (locked) {
> -		mutex_unlock(&xip_sparse_mutex);
> -	} else if (read_seqcount_retry(&xip_sparse_seq, count)) {
> -		mutex_lock(&xip_sparse_mutex);
> -		locked = 1;
> -		goto retry;
> -	}
> -}
> -
> -/*
> - * xip_fault() is invoked via the vma operations vector for a
> - * mapped memory region to read in file data during a page fault.
> - *
> - * This function is derived from filemap_fault, but used for execute in place
> - */
> -static int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> -{
> -	struct file *file = vma->vm_file;
> -	struct address_space *mapping = file->f_mapping;
> -	struct inode *inode = mapping->host;
> -	pgoff_t size;
> -	void *xip_mem;
> -	unsigned long xip_pfn;
> -	struct page *page;
> -	int error;
> -
> -	/* XXX: are VM_FAULT_ codes OK? */
> -again:
> -	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> -	if (vmf->pgoff >= size)
> -		return VM_FAULT_SIGBUS;
> -
> -	error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 0,
> -						&xip_mem, &xip_pfn);
> -	if (likely(!error))
> -		goto found;
> -	if (error != -ENODATA)
> -		return VM_FAULT_OOM;
> -
> -	/* sparse block */
> -	if ((vma->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
> -	    (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)) &&
> -	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
> -		int err;
> -
> -		/* maybe shared writable, allocate new block */
> -		mutex_lock(&xip_sparse_mutex);
> -		error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 1,
> -							&xip_mem, &xip_pfn);
> -		mutex_unlock(&xip_sparse_mutex);
> -		if (error)
> -			return VM_FAULT_SIGBUS;
> -		/* unmap sparse mappings at pgoff from all other vmas */
> -		__xip_unmap(mapping, vmf->pgoff);
> -
> -found:
> -		/* We must recheck i_size under i_mmap_mutex */
> -		mutex_lock(&mapping->i_mmap_mutex);
> -		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
> -							PAGE_CACHE_SHIFT;
> -		if (unlikely(vmf->pgoff >= size)) {
> -			mutex_unlock(&mapping->i_mmap_mutex);
> -			return VM_FAULT_SIGBUS;
> -		}
> -		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
> -							xip_pfn);
> -		mutex_unlock(&mapping->i_mmap_mutex);
> -		if (err == -ENOMEM)
> -			return VM_FAULT_OOM;
> -		/*
> -		 * err == -EBUSY is fine, we've raced against another thread
> -		 * that faulted-in the same page
> -		 */
> -		if (err != -EBUSY)
> -			BUG_ON(err);
> -		return VM_FAULT_NOPAGE;
> -	} else {
> -		int err, ret = VM_FAULT_OOM;
> -
> -		mutex_lock(&xip_sparse_mutex);
> -		write_seqcount_begin(&xip_sparse_seq);
> -		error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 0,
> -							&xip_mem, &xip_pfn);
> -		if (unlikely(!error)) {
> -			write_seqcount_end(&xip_sparse_seq);
> -			mutex_unlock(&xip_sparse_mutex);
> -			goto again;
> -		}
> -		if (error != -ENODATA)
> -			goto out;
> -
> -		/* We must recheck i_size under i_mmap_mutex */
> -		mutex_lock(&mapping->i_mmap_mutex);
> -		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
> -							PAGE_CACHE_SHIFT;
> -		if (unlikely(vmf->pgoff >= size)) {
> -			ret = VM_FAULT_SIGBUS;
> -			goto unlock;
> -		}
> -		/* not shared and writable, use xip_sparse_page() */
> -		page = xip_sparse_page();
> -		if (!page)
> -			goto unlock;
> -		err = vm_insert_page(vma, (unsigned long)vmf->virtual_address,
> -							page);
> -		if (err == -ENOMEM)
> -			goto unlock;
> -
> -		ret = VM_FAULT_NOPAGE;
> -unlock:
> -		mutex_unlock(&mapping->i_mmap_mutex);
> -out:
> -		write_seqcount_end(&xip_sparse_seq);
> -		mutex_unlock(&xip_sparse_mutex);
> -
> -		return ret;
> -	}
> -}
> -
> -static const struct vm_operations_struct xip_file_vm_ops = {
> -	.fault	= xip_file_fault,
> -	.page_mkwrite	= filemap_page_mkwrite,
> -	.remap_pages = generic_file_remap_pages,
> -};
> -
> -int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
> -{
> -	BUG_ON(!file->f_mapping->a_ops->get_xip_mem);
> -
> -	file_accessed(file);
> -	vma->vm_ops = &xip_file_vm_ops;
> -	vma->vm_flags |= VM_MIXEDMAP;
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(xip_file_mmap);
> -
> -/*
>   * truncate a page used for execute in place
>   * functionality is analog to block_truncate_page but does use get_xip_mem
>   * to get the page instead of page cache
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
