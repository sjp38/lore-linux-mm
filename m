Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 90A756B0009
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 18:30:43 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id 77so52774679ioc.2
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:30:43 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id m5si50077645igx.20.2015.12.30.15.30.41
        for <linux-mm@kvack.org>;
        Wed, 30 Dec 2015 15:30:42 -0800 (PST)
Date: Thu, 31 Dec 2015 10:30:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/8] xfs: Support for transparent PUD pages
Message-ID: <20151230233007.GA6682@dastard>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
 <1450974037-24775-8-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450974037-24775-8-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu, Dec 24, 2015 at 11:20:36AM -0500, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Call into DAX to provide support for PUD pages, just like the PMD cases.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> ---
>  fs/xfs/xfs_file.c  | 33 +++++++++++++++++++++++++++++++++
>  fs/xfs/xfs_trace.h |  1 +
>  2 files changed, 34 insertions(+)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index f5392ab..a81b942 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1600,6 +1600,38 @@ xfs_filemap_pmd_fault(
>  	return ret;
>  }
>  
> +STATIC int
> +xfs_filemap_pud_fault(
> +	struct vm_area_struct	*vma,
> +	unsigned long		addr,
> +	pud_t			*pud,
> +	unsigned int		flags)
> +{
> +	struct inode		*inode = file_inode(vma->vm_file);
> +	struct xfs_inode	*ip = XFS_I(inode);
> +	int			ret;
> +
> +	if (!IS_DAX(inode))
> +		return VM_FAULT_FALLBACK;
> +
> +	trace_xfs_filemap_pud_fault(ip);
> +
> +	if (flags & FAULT_FLAG_WRITE) {
> +		sb_start_pagefault(inode->i_sb);
> +		file_update_time(vma->vm_file);
> +	}
> +
> +	xfs_ilock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> +	ret = __dax_pud_fault(vma, addr, pud, flags, xfs_get_blocks_dax_fault,
> +			      NULL);
> +	xfs_iunlock(XFS_I(inode), XFS_MMAPLOCK_SHARED);
> +
> +	if (flags & FAULT_FLAG_WRITE)
> +		sb_end_pagefault(inode->i_sb);
> +
> +	return ret;
> +}
> +
>  /*
>   * pfn_mkwrite was originally inteneded to ensure we capture time stamp
>   * updates on write faults. In reality, it's need to serialise against
> @@ -1637,6 +1669,7 @@ xfs_filemap_pfn_mkwrite(
>  static const struct vm_operations_struct xfs_file_vm_ops = {
>  	.fault		= xfs_filemap_fault,
>  	.pmd_fault	= xfs_filemap_pmd_fault,
> +	.pud_fault	= xfs_filemap_pud_fault,

This is getting silly - we now have 3 different page fault handlers
that all do exactly the same thing. Please abstract this so that the
page/pmd/pud is transparent and gets passed through to the generic
handler code that then handles the differences between page/pmd/pud
internally.

This, after all, is the original reason that the ->fault handler was
introduced....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
