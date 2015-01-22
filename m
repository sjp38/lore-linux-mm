Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 582926B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:41:56 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id bm13so1137686qab.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:41:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q9si4485163qgq.83.2015.01.22.05.41.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 05:41:55 -0800 (PST)
Date: Thu, 22 Jan 2015 08:41:52 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [RFC PATCH 6/6] xfs: lock out page faults from extent swap
 operations
Message-ID: <20150122134152.GC25345@bfoster.bfoster>
References: <1420669543-8093-1-git-send-email-david@fromorbit.com>
 <1420669543-8093-7-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420669543-8093-7-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jan 08, 2015 at 09:25:43AM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Extent swap operations are another extent manipulation operation
> that we need to ensure does not race against mmap page faults. The
> current code returns if the file is mapped prior to the swap being
> done, but it could potentially race against new page faults while
> the swap is in progress. Hence we should use the XFS_MMAPLOCK_EXCL
> for this operation, too.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_bmap_util.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> index 22a5dcb..1420caf 100644
> --- a/fs/xfs/xfs_bmap_util.c
> +++ b/fs/xfs/xfs_bmap_util.c
> @@ -1599,13 +1599,6 @@ xfs_swap_extent_flush(
>  	/* Verify O_DIRECT for ftmp */
>  	if (VFS_I(ip)->i_mapping->nrpages)
>  		return -EINVAL;
> -
> -	/*
> -	 * Don't try to swap extents on mmap()d files because we can't lock
> -	 * out races against page faults safely.
> -	 */
> -	if (mapping_mapped(VFS_I(ip)->i_mapping))
> -		return -EBUSY;
>  	return 0;
>  }
>  
> @@ -1633,13 +1626,14 @@ xfs_swap_extents(
>  	}
>  
>  	/*
> -	 * Lock up the inodes against other IO and truncate to begin with.
> -	 * Then we can ensure the inodes are flushed and have no page cache
> -	 * safely. Once we have done this we can take the ilocks and do the rest
> -	 * of the checks.
> +	 * Lock the inodes against other IO, page faults and truncate to
> +	 * begin with.  Then we can ensure the inodes are flushed and have no
> +	 * page cache safely. Once we have done this we can take the ilocks and
> +	 * do the rest of the checks.
>  	 */
> -	lock_flags = XFS_IOLOCK_EXCL;
> +	lock_flags = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
>  	xfs_lock_two_inodes(ip, tip, XFS_IOLOCK_EXCL);
> +	xfs_lock_two_inodes(ip, tip, XFS_MMAPLOCK_EXCL);
>  
>  	/* Verify that both files have the same format */
>  	if ((ip->i_d.di_mode & S_IFMT) != (tip->i_d.di_mode & S_IFMT)) {

Not introduced by this patch, but it looks like we have a couple
out_trans_cancel->out_unlock error paths after the inodes are joined to
the transaction (with lock transfer) that can result in double unlocks.
We might as well fix that up here one way or another as well...

Brian

> -- 
> 2.0.0
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
