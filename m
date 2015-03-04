Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0136B00A0
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 12:19:46 -0500 (EST)
Received: by widex7 with SMTP id ex7so32307730wid.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 09:19:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r5si9489702wix.76.2015.03.04.09.19.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 09:19:43 -0800 (PST)
Date: Wed, 4 Mar 2015 18:19:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3] DAX: use pfn_mkwrite to update c/mtime
Message-ID: <20150304171935.GA5443@quack.suse.cz>
References: <54F733BD.7060807@plexistor.com>
 <54F73746.5020300@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F73746.5020300@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed 04-03-15 18:48:06, Boaz Harrosh wrote:
> From: Yigal Korman <yigal@plexistor.com>
> 
> Without this patch, c/mtime is not updated correctly when mmap'ed page is
> first read from and then written to.
> 
> A new xfstest is submitted for testing this (generic/080)
> 
> Signed-off-by: Yigal Korman <yigal@plexistor.com>
> Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
> ---
>  fs/dax.c           | 13 +++++++++++++
>  fs/ext2/file.c     |  1 +
>  fs/ext4/file.c     |  1 +
>  include/linux/fs.h |  1 +
>  4 files changed, 16 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index ed1619e..cd63adc 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -464,6 +464,19 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
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
> +	file_update_time(vma->vm_file);
> +	return VM_FAULT_NOPAGE;
> +}
> +EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
  Hum, you likely want a freeze protection in there as well
(sb_start_pagefault() and sb_end_pagefault()). Don't you?  Otherwise user
could start writing to the page while filesystem is frozen.  That's another
bug you could mention in your description.

								Honza

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
> index 33a09da..b43a7a6 100644
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
> index b4d71b5..24af817 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2597,6 +2597,7 @@ int dax_clear_blocks(struct inode *, sector_t block, long size);
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
