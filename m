Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59FBE6B0253
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 05:57:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so87159541wmg.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 02:57:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k133si17923020wmf.125.2016.10.03.02.57.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 02:57:50 -0700 (PDT)
Date: Mon, 3 Oct 2016 11:57:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 09/12] dax: correct dax iomap code namespace
Message-ID: <20161003095749.GO6457@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-10-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-10-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu 29-09-16 16:49:27, Ross Zwisler wrote:
> The recently added DAX functions that use the new struct iomap data
> structure were named iomap_dax_rw(), iomap_dax_fault() and
> iomap_dax_actor().  These are actually defined in fs/dax.c, though, so
> should be part of the "dax" namespace and not the "iomap" namespace.
> Rename them to dax_iomap_rw(), dax_iomap_fault() and dax_iomap_actor()
> respectively.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Suggested-by: Dave Chinner <david@fromorbit.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/dax.c            | 16 ++++++++--------
>  fs/ext2/file.c      |  6 +++---
>  fs/xfs/xfs_file.c   |  8 ++++----
>  include/linux/dax.h |  4 ++--
>  4 files changed, 17 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index b5e7b13..6977e5e 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1024,7 +1024,7 @@ EXPORT_SYMBOL_GPL(dax_truncate_page);
>  
>  #ifdef CONFIG_FS_IOMAP
>  static loff_t
> -iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
> +dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		struct iomap *iomap)
>  {
>  	struct iov_iter *iter = data;
> @@ -1081,7 +1081,7 @@ iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  }
>  
>  /**
> - * iomap_dax_rw - Perform I/O to a DAX file
> + * dax_iomap_rw - Perform I/O to a DAX file
>   * @iocb:	The control block for this I/O
>   * @iter:	The addresses to do I/O from or to
>   * @ops:	iomap ops passed from the file system
> @@ -1091,7 +1091,7 @@ iomap_dax_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>   * and evicting any page cache pages in the region under I/O.
>   */
>  ssize_t
> -iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
> +dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
>  		struct iomap_ops *ops)
>  {
>  	struct address_space *mapping = iocb->ki_filp->f_mapping;
> @@ -1121,7 +1121,7 @@ iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
>  
>  	while (iov_iter_count(iter)) {
>  		ret = iomap_apply(inode, pos, iov_iter_count(iter), flags, ops,
> -				iter, iomap_dax_actor);
> +				iter, dax_iomap_actor);
>  		if (ret <= 0)
>  			break;
>  		pos += ret;
> @@ -1131,10 +1131,10 @@ iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
>  	iocb->ki_pos += done;
>  	return done ? done : ret;
>  }
> -EXPORT_SYMBOL_GPL(iomap_dax_rw);
> +EXPORT_SYMBOL_GPL(dax_iomap_rw);
>  
>  /**
> - * iomap_dax_fault - handle a page fault on a DAX file
> + * dax_iomap_fault - handle a page fault on a DAX file
>   * @vma: The virtual memory area where the fault occurred
>   * @vmf: The description of the fault
>   * @ops: iomap ops passed from the file system
> @@ -1143,7 +1143,7 @@ EXPORT_SYMBOL_GPL(iomap_dax_rw);
>   * or mkwrite handler for DAX files. Assumes the caller has done all the
>   * necessary locking for the page fault to proceed successfully.
>   */
> -int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			struct iomap_ops *ops)
>  {
>  	struct address_space *mapping = vma->vm_file->f_mapping;
> @@ -1245,5 +1245,5 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  		return VM_FAULT_SIGBUS | major;
>  	return VM_FAULT_NOPAGE | major;
>  }
> -EXPORT_SYMBOL_GPL(iomap_dax_fault);
> +EXPORT_SYMBOL_GPL(dax_iomap_fault);
>  #endif /* CONFIG_FS_IOMAP */
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 0f257f8..32a4913 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -38,7 +38,7 @@ static ssize_t ext2_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
>  		return 0; /* skip atime */
>  
>  	inode_lock_shared(inode);
> -	ret = iomap_dax_rw(iocb, to, &ext2_iomap_ops);
> +	ret = dax_iomap_rw(iocb, to, &ext2_iomap_ops);
>  	inode_unlock_shared(inode);
>  
>  	file_accessed(iocb->ki_filp);
> @@ -62,7 +62,7 @@ static ssize_t ext2_dax_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  	if (ret)
>  		goto out_unlock;
>  
> -	ret = iomap_dax_rw(iocb, from, &ext2_iomap_ops);
> +	ret = dax_iomap_rw(iocb, from, &ext2_iomap_ops);
>  	if (ret > 0 && iocb->ki_pos > i_size_read(inode)) {
>  		i_size_write(inode, iocb->ki_pos);
>  		mark_inode_dirty(inode);
> @@ -99,7 +99,7 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	}
>  	down_read(&ei->dax_sem);
>  
> -	ret = iomap_dax_fault(vma, vmf, &ext2_iomap_ops);
> +	ret = dax_iomap_fault(vma, vmf, &ext2_iomap_ops);
>  
>  	up_read(&ei->dax_sem);
>  	if (vmf->flags & FAULT_FLAG_WRITE)
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 882f264..00293d2 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -342,7 +342,7 @@ xfs_file_dax_read(
>  		return 0; /* skip atime */
>  
>  	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
> -	ret = iomap_dax_rw(iocb, to, &xfs_iomap_ops);
> +	ret = dax_iomap_rw(iocb, to, &xfs_iomap_ops);
>  	xfs_rw_iunlock(ip, XFS_IOLOCK_SHARED);
>  
>  	file_accessed(iocb->ki_filp);
> @@ -721,7 +721,7 @@ xfs_file_dax_write(
>  
>  	trace_xfs_file_dax_write(ip, count, pos);
>  
> -	ret = iomap_dax_rw(iocb, from, &xfs_iomap_ops);
> +	ret = dax_iomap_rw(iocb, from, &xfs_iomap_ops);
>  	if (ret > 0 && iocb->ki_pos > i_size_read(inode)) {
>  		i_size_write(inode, iocb->ki_pos);
>  		error = xfs_setfilesize(ip, pos, ret);
> @@ -1468,7 +1468,7 @@ xfs_filemap_page_mkwrite(
>  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
>  
>  	if (IS_DAX(inode)) {
> -		ret = iomap_dax_fault(vma, vmf, &xfs_iomap_ops);
> +		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
>  	} else {
>  		ret = iomap_page_mkwrite(vma, vmf, &xfs_iomap_ops);
>  		ret = block_page_mkwrite_return(ret);
> @@ -1502,7 +1502,7 @@ xfs_filemap_fault(
>  		 * changes to xfs_get_blocks_direct() to map unwritten extent
>  		 * ioend for conversion on read-only mappings.
>  		 */
> -		ret = iomap_dax_fault(vma, vmf, &xfs_iomap_ops);
> +		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
>  	} else
>  		ret = filemap_fault(vma, vmf);
>  	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index d9a8350..c4a51bb 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -11,13 +11,13 @@ struct iomap_ops;
>  /* We use lowest available exceptional entry bit for locking */
>  #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
>  
> -ssize_t iomap_dax_rw(struct kiocb *iocb, struct iov_iter *iter,
> +ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
>  		struct iomap_ops *ops);
>  ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *,
>  		  get_block_t, dio_iodone_t, int flags);
>  int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
> -int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			struct iomap_ops *ops);
>  int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
>  int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index);
> -- 
> 2.7.4
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
