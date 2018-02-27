Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5576B0006
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 12:01:19 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v64so5186049wma.4
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 09:01:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si9932737wrr.538.2018.02.27.09.01.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 09:01:11 -0800 (PST)
Date: Tue, 27 Feb 2018 18:01:10 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 04/12] ext2, dax: define ext2_dax_*() infrastructure
 in all cases
Message-ID: <20180227170110.uymbsfbk33unpjid@quack2.suse.cz>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151970521671.26729.14342103844044388890.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151970521671.26729.14342103844044388890.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Jan Kara <jack@suse.com>

On Mon 26-02-18 20:20:16, Dan Williams wrote:
> In preparation for fixing S_DAX to be defined in the CONFIG_FS_DAX=n +
> CONFIG_DEV_DAX=y case, move the definition of these routines outside of
> the "#ifdef CONFIG_FS_DAX" guard. This is also a coding-style fix to
> move all ifdef handling to header files rather than in the source. The
> compiler will still be able to determine that all the related code can
> be discarded in the CONFIG_FS_DAX=n case.
> 
> Cc: Jan Kara <jack@suse.com>
> Cc: <stable@vger.kernel.org>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext2/file.c      |    8 --------
>  include/linux/dax.h |   10 ++++++++--
>  2 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 1c7ea1bcddde..5ac98d074323 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -29,7 +29,6 @@
>  #include "xattr.h"
>  #include "acl.h"
>  
> -#ifdef CONFIG_FS_DAX
>  static ssize_t ext2_dax_read_iter(struct kiocb *iocb, struct iov_iter *to)
>  {
>  	struct inode *inode = iocb->ki_filp->f_mapping->host;
> @@ -128,9 +127,6 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
>  	vma->vm_flags |= VM_MIXEDMAP;
>  	return 0;
>  }
> -#else
> -#define ext2_file_mmap	generic_file_mmap
> -#endif
>  
>  /*
>   * Called when filp is released. This happens when all file descriptors
> @@ -162,19 +158,15 @@ int ext2_fsync(struct file *file, loff_t start, loff_t end, int datasync)
>  
>  static ssize_t ext2_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
>  {
> -#ifdef CONFIG_FS_DAX
>  	if (IS_DAX(iocb->ki_filp->f_mapping->host))
>  		return ext2_dax_read_iter(iocb, to);
> -#endif
>  	return generic_file_read_iter(iocb, to);
>  }
>  
>  static ssize_t ext2_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
>  {
> -#ifdef CONFIG_FS_DAX
>  	if (IS_DAX(iocb->ki_filp->f_mapping->host))
>  		return ext2_dax_write_iter(iocb, from);
> -#endif
>  	return generic_file_write_iter(iocb, from);
>  }
>  
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 0185ecdae135..47edbce4fc52 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -93,8 +93,6 @@ void dax_flush(struct dax_device *dax_dev, void *addr, size_t size);
>  void dax_write_cache(struct dax_device *dax_dev, bool wc);
>  bool dax_write_cache_enabled(struct dax_device *dax_dev);
>  
> -ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
> -		const struct iomap_ops *ops);
>  int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
>  		    pfn_t *pfnp, int *errp, const struct iomap_ops *ops);
>  int dax_finish_sync_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
> @@ -107,6 +105,8 @@ int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
>  int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
>  		unsigned int offset, unsigned int length);
> +ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
> +		const struct iomap_ops *ops);
>  #else
>  static inline int __dax_zero_page_range(struct block_device *bdev,
>  		struct dax_device *dax_dev, sector_t sector,
> @@ -114,6 +114,12 @@ static inline int __dax_zero_page_range(struct block_device *bdev,
>  {
>  	return -ENXIO;
>  }
> +
> +static inline ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
> +		const struct iomap_ops *ops)
> +{
> +	return -ENXIO;
> +}
>  #endif
>  
>  static inline bool dax_mapping(struct address_space *mapping)
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
