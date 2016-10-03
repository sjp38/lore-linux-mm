Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05AC16B0253
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 05:35:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so53508017wmg.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 02:35:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wn5si33746465wjb.200.2016.10.03.02.35.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Oct 2016 02:35:15 -0700 (PDT)
Date: Mon, 3 Oct 2016 11:35:13 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 04/12] ext2: remove support for DAX PMD faults
Message-ID: <20161003093513.GJ6457@quack2.suse.cz>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-5-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-5-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Thu 29-09-16 16:49:22, Ross Zwisler wrote:
> DAX PMD support was added via the following commit:
> 
> commit e7b1ea2ad658 ("ext2: huge page fault support")
> 
> I believe this path to be untested as ext2 doesn't reliably provide block
> allocations that are aligned to 2MiB.  In my testing I've been unable to
> get ext2 to actually fault in a PMD.  It always fails with a "pfn
> unaligned" message because the sector returned by ext2_get_block() isn't
> aligned.
> 
> I've tried various settings for the "stride" and "stripe_width" extended
> options to mkfs.ext2, without any luck.
> 
> Since we can't reliably get PMDs, remove support so that we don't have an
> untested code path that we may someday traverse when we happen to get an
> aligned block allocation.  This should also make 4k DAX faults in ext2 a
> bit faster since they will no longer have to call the PMD fault handler
> only to get a response of VM_FAULT_FALLBACK.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext2/file.c | 29 ++++++-----------------------
>  1 file changed, 6 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 0ca363d..0f257f8 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -107,27 +107,6 @@ static int ext2_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	return ret;
>  }
>  
> -static int ext2_dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
> -						pmd_t *pmd, unsigned int flags)
> -{
> -	struct inode *inode = file_inode(vma->vm_file);
> -	struct ext2_inode_info *ei = EXT2_I(inode);
> -	int ret;
> -
> -	if (flags & FAULT_FLAG_WRITE) {
> -		sb_start_pagefault(inode->i_sb);
> -		file_update_time(vma->vm_file);
> -	}
> -	down_read(&ei->dax_sem);
> -
> -	ret = dax_pmd_fault(vma, addr, pmd, flags, ext2_get_block);
> -
> -	up_read(&ei->dax_sem);
> -	if (flags & FAULT_FLAG_WRITE)
> -		sb_end_pagefault(inode->i_sb);
> -	return ret;
> -}
> -
>  static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  		struct vm_fault *vmf)
>  {
> @@ -154,7 +133,11 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  
>  static const struct vm_operations_struct ext2_dax_vm_ops = {
>  	.fault		= ext2_dax_fault,
> -	.pmd_fault	= ext2_dax_pmd_fault,
> +	/*
> +	 * .pmd_fault is not supported for DAX because allocation in ext2
> +	 * cannot be reliably aligned to huge page sizes and so pmd faults
> +	 * will always fail and fail back to regular faults.
> +	 */
>  	.page_mkwrite	= ext2_dax_fault,
>  	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
>  };
> @@ -166,7 +149,7 @@ static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
>  
>  	file_accessed(file);
>  	vma->vm_ops = &ext2_dax_vm_ops;
> -	vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;
> +	vma->vm_flags |= VM_MIXEDMAP;
>  	return 0;
>  }
>  #else
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
