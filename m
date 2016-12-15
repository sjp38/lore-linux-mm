Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA726B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:46:47 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so23091142wjc.6
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:46:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id za3si1531555wjb.172.2016.12.15.05.46.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 05:46:45 -0800 (PST)
Date: Thu, 15 Dec 2016 14:46:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/3] dax: masking off __GFP_FS in fs DAX handlers
Message-ID: <20161215134641.GA13811@quack2.suse.cz>
References: <148174532372.194339.4875475197715168429.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148174532372.194339.4875475197715168429.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

On Wed 14-12-16 12:55:23, Dave Jiang wrote:
> The callers into dax needs to clear __GFP_FS since they are responsible
> for acquiring locks / transactions that block __GFP_FS allocation. They
> will restore the lag when dax function return.
                   ^^^ flags             ^^^ returns.

Otherwise the patch looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> ---
>  fs/dax.c          |    1 +
>  fs/ext2/file.c    |    9 ++++++++-
>  fs/ext4/file.c    |   10 +++++++++-
>  fs/xfs/xfs_file.c |   14 +++++++++++++-
>  4 files changed, 31 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index d3fe880..6395bc6 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1380,6 +1380,7 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	vmf.pgoff = pgoff;
>  	vmf.flags = flags;
>  	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
> +	vmf.gfp_mask &= ~__GFP_FS;
>  
>  	switch (iomap.type) {
>  	case IOMAP_MAPPED:
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index b0f2415..8422d5f 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -92,16 +92,19 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	struct inode *inode = file_inode(vma->vm_file);
>  	struct ext2_inode_info *ei = EXT2_I(inode);
>  	int ret;
> +	gfp_t old_gfp = vmf->gfp_mask;
>  
>  	if (vmf->flags & FAULT_FLAG_WRITE) {
>  		sb_start_pagefault(inode->i_sb);
>  		file_update_time(vma->vm_file);
>  	}
> +	vmf->gfp_mask &= ~__GFP_FS;
>  	down_read(&ei->dax_sem);
>  
>  	ret = dax_iomap_fault(vma, vmf, &ext2_iomap_ops);
>  
>  	up_read(&ei->dax_sem);
> +	vmf->gfp_mask = old_gfp;
>  	if (vmf->flags & FAULT_FLAG_WRITE)
>  		sb_end_pagefault(inode->i_sb);
>  	return ret;
> @@ -114,6 +117,7 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  	struct ext2_inode_info *ei = EXT2_I(inode);
>  	loff_t size;
>  	int ret;
> +	gfp_t old_gfp = vmf->gfp_mask;
>  
>  	sb_start_pagefault(inode->i_sb);
>  	file_update_time(vma->vm_file);
> @@ -123,8 +127,11 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  	if (vmf->pgoff >= size)
>  		ret = VM_FAULT_SIGBUS;
> -	else
> +	else {
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_pfn_mkwrite(vma, vmf);
> +		vmf->gfp_mask = old_gfp;
> +	}
>  
>  	up_read(&ei->dax_sem);
>  	sb_end_pagefault(inode->i_sb);
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index d663d3d..a3f2bf0 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -261,14 +261,17 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	struct inode *inode = file_inode(vma->vm_file);
>  	struct super_block *sb = inode->i_sb;
>  	bool write = vmf->flags & FAULT_FLAG_WRITE;
> +	gfp_t old_gfp = vmf->gfp_mask;
>  
>  	if (write) {
>  		sb_start_pagefault(sb);
>  		file_update_time(vma->vm_file);
>  	}
> +	vmf->gfp_mask &= ~__GFP_FS;
>  	down_read(&EXT4_I(inode)->i_mmap_sem);
>  	result = dax_iomap_fault(vma, vmf, &ext4_iomap_ops);
>  	up_read(&EXT4_I(inode)->i_mmap_sem);
> +	vmf->gfp_mask = old_gfp;
>  	if (write)
>  		sb_end_pagefault(sb);
>  
> @@ -320,8 +323,13 @@ static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  	if (vmf->pgoff >= size)
>  		ret = VM_FAULT_SIGBUS;
> -	else
> +	else {
> +		gfp_t old_gfp = vmf->gfp_mask;
> +
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_pfn_mkwrite(vma, vmf);
> +		vmf->gfp_mask = old_gfp;
> +	}
>  	up_read(&EXT4_I(inode)->i_mmap_sem);
>  	sb_end_pagefault(sb);
>  
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index d818c16..52202b4 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1474,7 +1474,11 @@ xfs_filemap_page_mkwrite(
>  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
>  
>  	if (IS_DAX(inode)) {
> +		gfp_t old_gfp = vmf->gfp_mask;
> +
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
> +		vmf->gfp_mask = old_gfp;
>  	} else {
>  		ret = iomap_page_mkwrite(vma, vmf, &xfs_iomap_ops);
>  		ret = block_page_mkwrite_return(ret);
> @@ -1502,13 +1506,16 @@ xfs_filemap_fault(
>  
>  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
>  	if (IS_DAX(inode)) {
> +		gfp_t old_gfp = vmf->gfp_mask;
>  		/*
>  		 * we do not want to trigger unwritten extent conversion on read
>  		 * faults - that is unnecessary overhead and would also require
>  		 * changes to xfs_get_blocks_direct() to map unwritten extent
>  		 * ioend for conversion on read-only mappings.
>  		 */
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_iomap_fault(vma, vmf, &xfs_iomap_ops);
> +		vmf->gfp_mask = old_gfp;
>  	} else
>  		ret = filemap_fault(vma, vmf);
>  	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> @@ -1581,8 +1588,13 @@ xfs_filemap_pfn_mkwrite(
>  	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  	if (vmf->pgoff >= size)
>  		ret = VM_FAULT_SIGBUS;
> -	else if (IS_DAX(inode))
> +	else if (IS_DAX(inode)) {
> +		gfp_t old_gfp = vmf->gfp_mask;
> +
> +		vmf->gfp_mask &= ~__GFP_FS;
>  		ret = dax_pfn_mkwrite(vma, vmf);
> +		vmf->gfp_mask = old_gfp;
> +	}
>  	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
>  	sb_end_pagefault(inode->i_sb);
>  	return ret;
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
