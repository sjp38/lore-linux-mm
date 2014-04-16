Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE906B0037
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:05:07 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so10539836pbb.3
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:05:06 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id pg5si12063113pab.440.2014.04.15.23.05.04
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 23:05:05 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:04:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] XFS: ensure xfs_file_*_read cannot deadlock in
 memory allocation.
Message-ID: <20140416060459.GE15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040336.10604.90380.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416040336.10604.90380.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> xfs_file_*_read holds an inode lock while calling a generic 'read'
> function.  These functions perform read-ahead and are quite likely to
> allocate memory.

Yes, that's what reading data from disk requires.

> So set PF_FSTRANS to ensure they avoid __GFP_FS and so don't recurse
> into a filesystem to free memory.

We already have that protection via the
> 
> This can be a problem with loop-back NFS mounts, if free_pages ends up
> wating in nfs_release_page(), and nfsd is blocked waiting for the lock
> that this code holds.
> 
> This was found both by lockdep and as a real deadlock during testing.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/xfs/xfs_file.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 64b48eade91d..88b33ef64668 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -243,6 +243,7 @@ xfs_file_aio_read(
>  	ssize_t			ret = 0;
>  	int			ioflags = 0;
>  	xfs_fsize_t		n;
> +	unsigned int		pflags;
>  
>  	XFS_STATS_INC(xs_read_calls);
>  
> @@ -290,6 +291,10 @@ xfs_file_aio_read(
>  	 * proceeed concurrently without serialisation.
>  	 */
>  	xfs_rw_ilock(ip, XFS_IOLOCK_SHARED);
> +	/* As we hold a lock, we must ensure that any allocation
> +	 * in generic_file_aio_read avoid __GFP_FS
> +	 */
> +	current_set_flags_nested(&pflags, PF_FSTRANS);

Ugh. No. This is Simply Wrong.

We handle the memory allocations in the IO path with
GFP_NOFS/KM_NOFS where necessary.

We also do this when setting up regular file inodes in
xfs_setup_inode():

        /*
         * Ensure all page cache allocations are done from GFP_NOFS context to
         * prevent direct reclaim recursion back into the filesystem and blowing
         * stacks or deadlocking.
         */
        gfp_mask = mapping_gfp_mask(inode->i_mapping);
        mapping_set_gfp_mask(inode->i_mapping, (gfp_mask & ~(__GFP_FS)));

Which handles all of the mapping allocations that occur within the
page cache read/write paths.

Remember, you removed the KM_NOFS code from the XFS allocator that
caused it to clear __GFP_FS in an earlier patch - the read Io path
is one of the things you broke by doing that....

If there are places where we don't use GFP_NOFS context allocations
that we should, then we need to fix them individually....

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
