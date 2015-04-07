Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7816B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 12:28:52 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so25722013wia.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 09:28:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hd7si13675576wjc.67.2015.04.07.09.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 09:28:51 -0700 (PDT)
Date: Tue, 7 Apr 2015 18:28:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] dax: use pfn_mkwrite to update c/mtime + freeze
 protection
Message-ID: <20150407162846.GI14897@quack.suse.cz>
References: <55239645.9000507@plexistor.com>
 <552398C6.1010304@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <552398C6.1010304@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On Tue 07-04-15 11:43:50, Boaz Harrosh wrote:
> From: Yigal Korman <yigal@plexistor.com>
> 
> [v1]
> Without this patch, c/mtime is not updated correctly when mmap'ed page is
> first read from and then written to.
> 
> A new xfstest is submitted for testing this (generic/080)
> 
> [v2]
> Jan Kara has pointed out that if we add the
> sb_start/end_pagefault pair in the new pfn_mkwrite we
> are then fixing another bug where: A user could start
> writing to the page while filesystem is frozen.
  The patch looks good to me. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> CC: Jan Kara <jack@suse.cz>
> CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: Stable Tree <stable@vger.kernel.org>
> 
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  fs/dax.c           | 17 +++++++++++++++++
>  fs/ext2/file.c     |  1 +
>  fs/ext4/file.c     |  1 +
>  include/linux/fs.h |  1 +
>  4 files changed, 20 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ed1619e..d0bd1f4 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -464,6 +464,23 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  EXPORT_SYMBOL_GPL(dax_fault);
>  
>  /**
> + * dax_pfn_mkwrite - handle first write to DAX page
> + * @vma: The virtual memory area where the fault occurred
> + * @vmf: The description of the fault
> + *
> + */
> +int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> +{
> +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> +
> +	sb_start_pagefault(sb);
> +	file_update_time(vma->vm_file);
> +	sb_end_pagefault(sb);
> +	return VM_FAULT_NOPAGE;
> +}
> +EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
> +
> +/**
>   * dax_zero_page_range - zero a range within a page of a DAX file
>   * @inode: The file being truncated
>   * @from: The file offset that is being truncated to
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index e317017..866a3ce 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -39,6 +39,7 @@ static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  static const struct vm_operations_struct ext2_dax_vm_ops = {
>  	.fault		= ext2_dax_fault,
>  	.page_mkwrite	= ext2_dax_mkwrite,
> +	.pfn_mkwrite	= dax_pfn_mkwrite,
>  };
>  
>  static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index 598abbb..aa78c70 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -206,6 +206,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  static const struct vm_operations_struct ext4_dax_vm_ops = {
>  	.fault		= ext4_dax_fault,
>  	.page_mkwrite	= ext4_dax_mkwrite,
> +	.pfn_mkwrite	= dax_pfn_mkwrite,
>  };
>  #else
>  #define ext4_dax_vm_ops	ext4_file_vm_ops
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 368e349..394035f 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2628,6 +2628,7 @@ int dax_clear_blocks(struct inode *, sector_t block, long size);
>  int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
>  int dax_truncate_page(struct inode *, loff_t from, get_block_t);
>  int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
> +int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
>  #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
>  
>  #ifdef CONFIG_BLOCK
> -- 
> 1.9.3
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
