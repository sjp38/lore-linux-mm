Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id B5E576B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:32:06 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id oh2so18918348lbb.3
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:32:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3si18925003lbs.13.2015.12.21.09.32.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 09:32:05 -0800 (PST)
Date: Mon, 21 Dec 2015 18:32:02 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 5/7] ext2: call dax_pfn_mkwrite() for DAX fsync/msync
Message-ID: <20151221173202.GB7030@quack.suse.cz>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-6-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450502540-8744-6-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri 18-12-15 22:22:18, Ross Zwisler wrote:
> To properly support the new DAX fsync/msync infrastructure filesystems
> need to call dax_pfn_mkwrite() so that DAX can track when user pages are
> dirtied.

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/ext2/file.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ext2/file.c b/fs/ext2/file.c
> index 11a42c5..2c88d68 100644
> --- a/fs/ext2/file.c
> +++ b/fs/ext2/file.c
> @@ -102,8 +102,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  {
>  	struct inode *inode = file_inode(vma->vm_file);
>  	struct ext2_inode_info *ei = EXT2_I(inode);
> -	int ret = VM_FAULT_NOPAGE;
>  	loff_t size;
> +	int ret;
>  
>  	sb_start_pagefault(inode->i_sb);
>  	file_update_time(vma->vm_file);
> @@ -113,6 +113,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
>  	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  	if (vmf->pgoff >= size)
>  		ret = VM_FAULT_SIGBUS;
> +	else
> +		ret = dax_pfn_mkwrite(vma, vmf);
>  
>  	up_read(&ei->dax_sem);
>  	sb_end_pagefault(inode->i_sb);
> -- 
> 2.5.0
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
