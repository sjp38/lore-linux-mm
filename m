Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C60216B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 07:15:39 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so36278370wjc.4
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 04:15:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sp13si23599360wjb.45.2016.12.13.04.15.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Dec 2016 04:15:38 -0800 (PST)
Date: Tue, 13 Dec 2016 13:15:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm, dax: make pmd_fault() and friends to be the same
 as fault()
Message-ID: <20161213121535.GI15362@quack2.suse.cz>
References: <148123286127.108913.2695398781030517780.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148123286127.108913.2695398781030517780.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, dan.j.williams@intel.com, hch@lst.de

On Thu 08-12-16 14:34:21, Dave Jiang wrote:
> Instead of passing in multiple parameters in the pmd_fault() handler,
> a vmf can be passed in just like a fault() handler. This will simplify
> code and remove the need for the actual pmd fault handlers to allocate a
> vmf. Related functions are also modified to do the same.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

I like the idea however see below:

> @@ -1377,21 +1376,20 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	if (iomap.offset + iomap.length < pos + PMD_SIZE)
>  		goto unlock_entry;
>  
> -	vmf.pgoff = pgoff;
> -	vmf.flags = flags;
> -	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
> +	vmf->pgoff = pgoff;
> +	vmf->gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;

But now it's really unexpected that you change pgoff and gfp_mask because
that will propagate back to the caller and if we return VM_FAULT_FALLBACK
we may fault in wrong PTE because of this. So dax_iomap_pmd_fault() should
not modify the passed gfp_mask, just make its callers clear __GFP_FS from
it because *they* are responsible for acquiring locks / transactions that
block __GFP_FS allocations. They are also responsible for restoring
original gfp_mask once dax_iomap_pmd_fault() returns.

dax_iomap_pmd_fault() needs to modify pgoff however it must restore it to
the original value before it returns.

Otherwise the patch looks good to me.

								Honza

>  
>  	switch (iomap.type) {
>  	case IOMAP_MAPPED:
> -		result = dax_pmd_insert_mapping(vma, pmd, &vmf, address,
> -				&iomap, pos, write, &entry);
> +		result = dax_pmd_insert_mapping(vma, vmf->pmd, vmf,
> +				vmf->address, &iomap, pos, write, &entry);
>  		break;
>  	case IOMAP_UNWRITTEN:
>  	case IOMAP_HOLE:
>  		if (WARN_ON_ONCE(write))
>  			goto unlock_entry;
> -		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
> -				&entry);
> +		result = dax_pmd_load_hole(vma, vmf->pmd, vmf, vmf->address,
> +				&iomap, &entry);
>  		break;
>  	default:
>  		WARN_ON_ONCE(1);
> @@ -1417,12 +1415,11 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>  	}
>   fallback:
>  	if (result == VM_FAULT_FALLBACK) {
> -		split_huge_pmd(vma, pmd, address);
> +		split_huge_pmd(vma, vmf->pmd, vmf->address);
>  		count_vm_event(THP_FAULT_FALLBACK);
>  	}
>  out:
> -	trace_dax_pmd_fault_done(inode, vma, address, flags, pgoff, max_pgoff,
> -			result);
> +	trace_dax_pmd_fault_done(inode, vma, vmf, max_pgoff, result);
>  	return result;
>  }
>  EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index d663d3d..10b64ba 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -275,21 +275,20 @@ static int ext4_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	return result;
>  }
>  
> -static int ext4_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
> -						pmd_t *pmd, unsigned int flags)
> +static int
> +ext4_dax_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	int result;
>  	struct inode *inode = file_inode(vma->vm_file);
>  	struct super_block *sb = inode->i_sb;
> -	bool write = flags & FAULT_FLAG_WRITE;
> +	bool write = vmf->flags & FAULT_FLAG_WRITE;
>  
>  	if (write) {
>  		sb_start_pagefault(sb);
>  		file_update_time(vma->vm_file);
>  	}
>  	down_read(&EXT4_I(inode)->i_mmap_sem);
> -	result = dax_iomap_pmd_fault(vma, addr, pmd, flags,
> -				     &ext4_iomap_ops);
> +	result = dax_iomap_pmd_fault(vma, vmf, &ext4_iomap_ops);
>  	up_read(&EXT4_I(inode)->i_mmap_sem);
>  	if (write)
>  		sb_end_pagefault(sb);
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index d818c16..df0009f 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1526,9 +1526,7 @@ xfs_filemap_fault(
>  STATIC int
>  xfs_filemap_pmd_fault(
>  	struct vm_area_struct	*vma,
> -	unsigned long		addr,
> -	pmd_t			*pmd,
> -	unsigned int		flags)
> +	struct vm_fault *vmf)
>  {
>  	struct inode		*inode = file_inode(vma->vm_file);
>  	struct xfs_inode	*ip = XFS_I(inode);
> @@ -1539,16 +1537,16 @@ xfs_filemap_pmd_fault(
>  
>  	trace_xfs_filemap_pmd_fault(ip);
>  
> -	if (flags & FAULT_FLAG_WRITE) {
> +	if (vmf->flags & FAULT_FLAG_WRITE) {
>  		sb_start_pagefault(inode->i_sb);
>  		file_update_time(vma->vm_file);
>  	}
>  
>  	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> -	ret = dax_iomap_pmd_fault(vma, addr, pmd, flags, &xfs_iomap_ops);
> +	ret = dax_iomap_pmd_fault(vma, vmf, &xfs_iomap_ops);
>  	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
>  
> -	if (flags & FAULT_FLAG_WRITE)
> +	if (vmf->flags & FAULT_FLAG_WRITE)
>  		sb_end_pagefault(inode->i_sb);
>  
>  	return ret;
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index 6e36b11..9761c90 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -71,16 +71,15 @@ static inline unsigned int dax_radix_order(void *entry)
>  		return PMD_SHIFT - PAGE_SHIFT;
>  	return 0;
>  }
> -int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> -		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops);
> +int dax_iomap_pmd_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +		struct iomap_ops *ops);
>  #else
>  static inline unsigned int dax_radix_order(void *entry)
>  {
>  	return 0;
>  }
>  static inline int dax_iomap_pmd_fault(struct vm_area_struct *vma,
> -		unsigned long address, pmd_t *pmd, unsigned int flags,
> -		struct iomap_ops *ops)
> +		struct vm_fault *vmf, struct iomap_ops *ops)
>  {
>  	return VM_FAULT_FALLBACK;
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 30f416a..aef645b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -347,8 +347,7 @@ struct vm_operations_struct {
>  	void (*close)(struct vm_area_struct * area);
>  	int (*mremap)(struct vm_area_struct * area);
>  	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
> -	int (*pmd_fault)(struct vm_area_struct *, unsigned long address,
> -						pmd_t *, unsigned int flags);
> +	int (*pmd_fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
>  	void (*map_pages)(struct vm_fault *vmf,
>  			pgoff_t start_pgoff, pgoff_t end_pgoff);
>  
> diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
> index c3b0aae..a98665b 100644
> --- a/include/trace/events/fs_dax.h
> +++ b/include/trace/events/fs_dax.h
> @@ -8,9 +8,8 @@
>  
>  DECLARE_EVENT_CLASS(dax_pmd_fault_class,
>  	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
> -		unsigned long address, unsigned int flags, pgoff_t pgoff,
> -		pgoff_t max_pgoff, int result),
> -	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result),
> +		struct vm_fault *vmf, pgoff_t max_pgoff, int result),
> +	TP_ARGS(inode, vma, vmf, max_pgoff, result),
>  	TP_STRUCT__entry(
>  		__field(unsigned long, ino)
>  		__field(unsigned long, vm_start)
> @@ -29,9 +28,9 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
>  		__entry->vm_start = vma->vm_start;
>  		__entry->vm_end = vma->vm_end;
>  		__entry->vm_flags = vma->vm_flags;
> -		__entry->address = address;
> -		__entry->flags = flags;
> -		__entry->pgoff = pgoff;
> +		__entry->address = vmf->address;
> +		__entry->flags = vmf->flags;
> +		__entry->pgoff = vmf->pgoff;
>  		__entry->max_pgoff = max_pgoff;
>  		__entry->result = result;
>  	),
> @@ -54,9 +53,9 @@ DECLARE_EVENT_CLASS(dax_pmd_fault_class,
>  #define DEFINE_PMD_FAULT_EVENT(name) \
>  DEFINE_EVENT(dax_pmd_fault_class, name, \
>  	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
> -		unsigned long address, unsigned int flags, pgoff_t pgoff, \
> +		struct vm_fault *vmf, \
>  		pgoff_t max_pgoff, int result), \
> -	TP_ARGS(inode, vma, address, flags, pgoff, max_pgoff, result))
> +	TP_ARGS(inode, vma, vmf, max_pgoff, result))
>  
>  DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
>  DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
> diff --git a/mm/memory.c b/mm/memory.c
> index e37250f..8ec36cf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3447,8 +3447,7 @@ static int create_huge_pmd(struct vm_fault *vmf)
>  	if (vma_is_anonymous(vma))
>  		return do_huge_pmd_anonymous_page(vmf);
>  	if (vma->vm_ops->pmd_fault)
> -		return vma->vm_ops->pmd_fault(vma, vmf->address, vmf->pmd,
> -				vmf->flags);
> +		return vma->vm_ops->pmd_fault(vma, vmf);
>  	return VM_FAULT_FALLBACK;
>  }
>  
> @@ -3457,8 +3456,7 @@ static int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>  	if (vma_is_anonymous(vmf->vma))
>  		return do_huge_pmd_wp_page(vmf, orig_pmd);
>  	if (vmf->vma->vm_ops->pmd_fault)
> -		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf->address,
> -				vmf->pmd, vmf->flags);
> +		return vmf->vma->vm_ops->pmd_fault(vmf->vma, vmf);
>  
>  	/* COW handled on pte level: split pmd */
>  	VM_BUG_ON_VMA(vmf->vma->vm_flags & VM_SHARED, vmf->vma);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
