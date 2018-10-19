Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD436B0006
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 00:02:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 43-v6so24946907ple.19
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 21:02:37 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id i64-v6si23826809pfg.119.2018.10.18.21.02.34
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 21:02:35 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:48:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/7] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20181019034847.GM18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-8-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-8-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:18PM -0400, Josef Bacik wrote:
> ->page_mkwrite is extremely expensive in btrfs.  We have to reserve
> space, which can take 6 lifetimes, and we could possibly have to wait on
> writeback on the page, another several lifetimes.  To avoid this simply
> drop the mmap_sem if we didn't have the cached page and do all of our
> work and return the appropriate retry error.  If we have the cached page
> we know we did all the right things to set this page up and we can just
> carry on.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  fs/btrfs/inode.c   | 41 +++++++++++++++++++++++++++++++++++++++--
>  include/linux/mm.h | 14 ++++++++++++++
>  mm/filemap.c       |  3 ++-
>  3 files changed, 55 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 3ea5339603cf..6b723d29bc0c 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -8809,7 +8809,9 @@ static void btrfs_invalidatepage(struct page *page, unsigned int offset,
>  vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  {
>  	struct page *page = vmf->page;
> -	struct inode *inode = file_inode(vmf->vma->vm_file);
> +	struct file *file = vmf->vma->vm_file, *fpin;
> +	struct mm_struct *mm = vmf->vma->vm_mm;
> +	struct inode *inode = file_inode(file);
>  	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
>  	struct extent_io_tree *io_tree = &BTRFS_I(inode)->io_tree;
>  	struct btrfs_ordered_extent *ordered;
> @@ -8828,6 +8830,29 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  
>  	reserved_space = PAGE_SIZE;
>  
> +	/*
> +	 * We have our cached page from a previous mkwrite, check it to make
> +	 * sure it's still dirty and our file size matches when we ran mkwrite
> +	 * the last time.  If everything is OK then return VM_FAULT_LOCKED,
> +	 * otherwise do the mkwrite again.
> +	 */
> +	if (vmf->flags & FAULT_FLAG_USED_CACHED) {
> +		lock_page(page);
> +		if (vmf->cached_size == i_size_read(inode) &&
> +		    PageDirty(page))
> +			return VM_FAULT_LOCKED;
> +		unlock_page(page);
> +	}

What does the file size have to do with whether we can use the
initialised page or not? The file can be extended by other
data operations (like write()) while a page fault is in progress,
so I'm not sure how or why this check makes any sense.

I also don't see anything btrfs specific here, so....

> +	/*
> +	 * mkwrite is extremely expensive, and we are holding the mmap_sem
> +	 * during this, which means we can starve out anybody trying to
> +	 * down_write(mmap_sem) for a long while, especially if we throw cgroups
> +	 * into the mix.  So just drop the mmap_sem and do all of our work,
> +	 * we'll loop back through and verify everything is ok the next time and
> +	 * hopefully avoid doing the work twice.
> +	 */
> +	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);

why can't all this be done by the caller of ->page_mkwrite?

>  	sb_start_pagefault(inode->i_sb);
>  	page_start = page_offset(page);
>  	page_end = page_start + PAGE_SIZE - 1;
> @@ -8844,7 +8869,7 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  	ret2 = btrfs_delalloc_reserve_space(inode, &data_reserved, page_start,
>  					   reserved_space);
>  	if (!ret2) {
> -		ret2 = file_update_time(vmf->vma->vm_file);
> +		ret2 = file_update_time(file);
>  		reserved = 1;
>  	}
>  	if (ret2) {
> @@ -8943,6 +8968,14 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  		btrfs_delalloc_release_extents(BTRFS_I(inode), PAGE_SIZE, true);
>  		sb_end_pagefault(inode->i_sb);
>  		extent_changeset_free(data_reserved);
> +		if (fpin) {
> +			unlock_page(page);
> +			fput(fpin);
> +			get_page(page);
> +			vmf->cached_size = size;
> +			vmf->cached_page = page;
> +			return VM_FAULT_RETRY;
> +		}
>  		return VM_FAULT_LOCKED;

And this can all be done by the caller, too.

I'm not seeing anything btrfs sepcific here - maybe I'm missing
something, but this all looks likes it should be in the high level
mm/ code, not in the filesystem code.

>  	}
>  
> @@ -8955,6 +8988,10 @@ vm_fault_t btrfs_page_mkwrite(struct vm_fault *vmf)
>  out_noreserve:
>  	sb_end_pagefault(inode->i_sb);
>  	extent_changeset_free(data_reserved);
> +	if (fpin) {
> +		fput(fpin);
> +		down_read(&mm->mmap_sem);
> +	}
>  	return ret;
>  }
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a7305d193c71..02b420be6b06 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -370,6 +370,13 @@ struct vm_fault {
>  					 * next time we loop through the fault
>  					 * handler for faster lookup.
>  					 */
> +	loff_t cached_size;		/* ->page_mkwrite handlers may drop
> +					 * the mmap_sem to avoid starvation, in
> +					 * which case they need to save the
> +					 * i_size in order to verify the cached
> +					 * page we're using the next loop
> +					 * through hasn't changed under us.
> +					 */

You still haven't explained what the size verification is actually
required for.

>  	/* These three entries are valid only while holding ptl lock */
>  	pte_t *pte;			/* Pointer to pte entry matching
>  					 * the 'address'. NULL if the page
> @@ -1437,6 +1444,8 @@ extern vm_fault_t handle_mm_fault_cacheable(struct vm_fault *vmf);
>  extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  			    unsigned long address, unsigned int fault_flags,
>  			    bool *unlocked);
> +extern struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma,
> +					     int flags);
>  void unmap_mapping_pages(struct address_space *mapping,
>  		pgoff_t start, pgoff_t nr, bool even_cows);
>  void unmap_mapping_range(struct address_space *mapping,
> @@ -1463,6 +1472,11 @@ static inline int fixup_user_fault(struct task_struct *tsk,
>  	BUG();
>  	return -EFAULT;
>  }
> +static inline struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma,
> +						    int flags)
> +{
> +	return NULL;
> +}
>  static inline void unmap_mapping_pages(struct address_space *mapping,
>  		pgoff_t start, pgoff_t nr, bool even_cows) { }
>  static inline void unmap_mapping_range(struct address_space *mapping,
> diff --git a/mm/filemap.c b/mm/filemap.c
> index e9cb44bd35aa..8027f082d74f 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2366,7 +2366,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
>  EXPORT_SYMBOL(generic_file_read_iter);
>  
>  #ifdef CONFIG_MMU
> -static struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int flags)
> +struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int flags)
>  {
>  	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) == FAULT_FLAG_ALLOW_RETRY) {
>  		struct file *file;
> @@ -2377,6 +2377,7 @@ static struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma, int fla
>  	}
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(maybe_unlock_mmap_for_io);

These API mods (if this functionality remains in the filesystem
code) belong in whatever patch introduced this function.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
