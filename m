Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1786B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 19:07:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 87-v6so6203375pfq.8
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:07:17 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id p9-v6si25658492pls.378.2018.10.10.16.07.14
        for <linux-mm@kvack.org>;
        Wed, 10 Oct 2018 16:07:15 -0700 (PDT)
Date: Thu, 11 Oct 2018 10:06:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 05/25] vfs: check file ranges before cloning files
Message-ID: <20181010230639.GN6311@dastard>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <153913027326.32295.7601238218404639876.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153913027326.32295.7601238218404639876.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Tue, Oct 09, 2018 at 05:11:13PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Move the file range checks from vfs_clone_file_prep into a separate
> generic_remap_checks function so that all the checks are collected in a
> central location.  This forms the basis for adding more checks from
> generic_write_checks that will make cloning's input checking more
> consistent with write input checking.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
....
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1717,12 +1717,12 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>   * Returns: 0 for "nothing to clone", 1 for "something to clone", or
>   * the usual negative error code.
>   */
> -int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
> -			       struct inode *inode_out, loff_t pos_out,
> -			       u64 *len, bool is_dedupe)
> +int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
> +			struct file *file_out, loff_t pos_out,
> +			u64 *len, bool is_dedupe)
>  {
> -	loff_t bs = inode_out->i_sb->s_blocksize;
> -	loff_t blen;
> +	struct inode *inode_in = file_inode(file_in);
> +	struct inode *inode_out = file_inode(file_out);
>  	loff_t isize;
>  	bool same_inode = (inode_in == inode_out);
>  	int ret;
> @@ -1740,10 +1740,7 @@ int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
>  	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
>  		return -EINVAL;
>  
> -	/* Are we going all the way to the end? */
>  	isize = i_size_read(inode_in);
> -	if (isize == 0)
> -		return 0;

This looks like a change of behaviour. Instead of skipping zero
legnth source files and returning success, this will now return
-EINVAL as other checks fail? That needs to be documented in the
commit message if it's intentional and a valid change to make...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
