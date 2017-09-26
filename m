Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62A616B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 20:31:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i130so18811505pgc.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 17:31:19 -0700 (PDT)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id t62si4867120pgt.394.2017.09.25.17.31.17
        for <linux-mm@kvack.org>;
        Mon, 25 Sep 2017 17:31:18 -0700 (PDT)
Date: Tue, 26 Sep 2017 10:31:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/7] xfs: re-enable XFS per-inode DAX
Message-ID: <20170926003114.GN10955@dastard>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-8-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-8-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:14:04PM -0600, Ross Zwisler wrote:
> Re-enable the XFS per-inode DAX flag, preventing S_DAX from changing when
> any mappings are present.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/xfs/xfs_ioctl.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 386b437..7a24dd5 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1012,12 +1012,10 @@ xfs_diflags_to_linux(
>  		inode->i_flags |= S_NOATIME;
>  	else
>  		inode->i_flags &= ~S_NOATIME;
> -#if 0	/* disabled until the flag switching races are sorted out */
>  	if ((xflags & FS_XFLAG_DAX) || (ip->i_mount->m_flags & XFS_MOUNT_DAX))
>  		inode->i_flags |= S_DAX;
>  	else
>  		inode->i_flags &= ~S_DAX;
> -#endif
>  }
>  
>  static bool
> @@ -1049,6 +1047,8 @@ xfs_ioctl_setattr_xflags(
>  {
>  	struct xfs_mount	*mp = ip->i_mount;
>  	uint64_t		di_flags2;
> +	struct address_space	*mapping = VFS_I(ip)->i_mapping;
> +	bool			dax_changing;
>  
>  	/* Can't change realtime flag if any extents are allocated. */
>  	if ((ip->i_d.di_nextents || ip->i_delayed_blks) &&
> @@ -1084,10 +1084,23 @@ xfs_ioctl_setattr_xflags(
>  	if (di_flags2 && ip->i_d.di_version < 3)
>  		return -EINVAL;
>  
> +	dax_changing = xfs_is_dax_state_changing(fa->fsx_xflags, ip);
> +	if (dax_changing) {
> +		i_mmap_lock_read(mapping);
> +		if (mapping_mapped(mapping)) {
> +			i_mmap_unlock_read(mapping);
> +			return -EBUSY;
> +		}
> +	}
> +
>  	ip->i_d.di_flags = xfs_flags2diflags(ip, fa->fsx_xflags);
>  	ip->i_d.di_flags2 = di_flags2;
>  
>  	xfs_diflags_to_linux(ip);
> +
> +	if (dax_changing)
> +		i_mmap_unlock_read(mapping);

Is this safe to be taking here under the ILOCK_EXCL? i.e. this is
the lock order here:

IOLOCK_EXCL -> MMAPLOCK_EXCL -> ILOCK_EXCL -> i_mmap_rwsem

The truncate path must run outside the ILOCK
context, and it does this order via unmap_mapping_range:

IOLOCK_EXCL -> MMAPLOCK_EXCL -> i_mmap_rwsem

On a page fault, we do:

	mmap_sem -> MMAPLOCK_EXCL -> page lock -> ILOCK_EXCL

Which gives the order

IOLOCK_EXCL
  -> mmap_sem
     -> MMAPLOCK_EXCL
	-> page lock
	   -> ILOCK_EXCL
	      -> i_mmap_rwsem

What I'm not clear on is what the orders between page locks and
pte locks and i_mapping_tree_lock and i_mmap_rwsem. If there's any
locks that the filesystem can take above the ILOCK that are also
taken under the i_mmap_rwsem, then we have a deadlock vector.

Historically we've avoided any mm/ level interactions under the
ILOCK_EXCL because of it's location in the page fault path locking
order (e.g. lockdep will go nuts if we take a page fault with the
ILOCK held). Hence I'm extremely wary of putting any other mm/ level
locks under the ILOCK like this without a clear explanation of the
locking orders and why it won't deadlock....

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
