Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD576B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 23:40:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l188so40349007pfc.7
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 20:40:35 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id n59si442626plb.358.2017.10.08.20.40.32
        for <linux-mm@kvack.org>;
        Sun, 08 Oct 2017 20:40:34 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:40:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 06/12] xfs: wire up MAP_DIRECT
Message-ID: <20171009034030.GH3666@dastard>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732934955.22363.14950885120988262779.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150732934955.22363.14950885120988262779.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Oct 06, 2017 at 03:35:49PM -0700, Dan Williams wrote:
> MAP_DIRECT is an mmap(2) flag with the following semantics:
> 
>   MAP_DIRECT
>   When specified with MAP_SHARED_VALIDATE, sets up a file lease with the
>   same lifetime as the mapping. Unlike a typical F_RDLCK lease this lease
>   is broken when a "lease breaker" attempts to write(2), change the block
>   map (fallocate), or change the size of the file. Otherwise the mechanism
>   of a lease break is identical to the typical lease break case where the
>   lease needs to be removed (munmap) within the number of seconds
>   specified by /proc/sys/fs/lease-break-time. If the lease holder fails to
>   remove the lease in time the kernel will invalidate the mapping and
>   force all future accesses to the mapping to trigger SIGBUS.
> 
>   In addition to lease break timeouts causing faults in the mapping to
>   result in SIGBUS, other states of the file will trigger SIGBUS at fault
>   time:
> 
>       * The file is not DAX capable
>       * The file has reflinked (copy-on-write) blocks
>       * The fault would trigger the filesystem to allocate blocks
>       * The fault would trigger the filesystem to perform extent conversion
> 
>   In other words, MAP_DIRECT expects and enforces a fully allocated file
>   where faults can be satisfied without modifying block map metadata.
> 
>   An unprivileged process may establish a MAP_DIRECT mapping on a file
>   whose UID (owner) matches the filesystem UID of the  process. A process
>   with the CAP_LEASE capability may establish a MAP_DIRECT mapping on
>   arbitrary files
> 
>   ERRORS
>   EACCES Beyond the typical mmap(2) conditions that trigger EACCES
>   MAP_DIRECT also requires the permission to set a file lease.
> 
>   EOPNOTSUPP The filesystem explicitly does not support the flag
> 
>   SIGBUS Attempted to write a MAP_DIRECT mapping at a file offset that
>          might require block-map updates, or the lease timed out and the
>          kernel invalidated the mapping.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/xfs/Kconfig                  |    2 -
>  fs/xfs/xfs_file.c               |  102 +++++++++++++++++++++++++++++++++++++++
>  include/linux/mman.h            |    3 +
>  include/uapi/asm-generic/mman.h |    1 
>  4 files changed, 106 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/xfs/Kconfig b/fs/xfs/Kconfig
> index f62fc6629abb..f8765653a438 100644
> --- a/fs/xfs/Kconfig
> +++ b/fs/xfs/Kconfig
> @@ -112,4 +112,4 @@ config XFS_ASSERT_FATAL
>  
>  config XFS_LAYOUT
>  	def_bool y
> -	depends on EXPORTFS_BLOCK_OPS
> +	depends on EXPORTFS_BLOCK_OPS || FS_DAX
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index ebdd0bd2b261..e35518600e28 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -40,12 +40,22 @@
>  #include "xfs_iomap.h"
>  #include "xfs_reflink.h"
>  
> +#include <linux/mman.h>
>  #include <linux/dcache.h>
>  #include <linux/falloc.h>
>  #include <linux/pagevec.h>
> +#include <linux/mapdirect.h>
>  #include <linux/backing-dev.h>
>  
>  static const struct vm_operations_struct xfs_file_vm_ops;
> +static const struct vm_operations_struct xfs_file_vm_direct_ops;
> +
> +static inline bool
> +is_xfs_map_direct(
> +		struct vm_area_struct *vma)
> +{
> +	return vma->vm_ops == &xfs_file_vm_direct_ops;
> +}

Namespacing (xfs_vma_is_direct) and whitespace damage.

>  
>  /*
>   * Clear the specified ranges to zero through either the pagecache or DAX.
> @@ -1008,6 +1018,26 @@ xfs_file_llseek(
>  	return vfs_setpos(file, offset, inode->i_sb->s_maxbytes);
>  }
>  
> +static int
> +xfs_vma_checks(
> +	struct vm_area_struct	*vma,
> +	struct inode		*inode)

Exactly what are we checking for - function name doesn't tell me,
and there's no comments, either?

> +{
> +	if (!is_xfs_map_direct(vma))
> +		return 0;
> +
> +	if (!is_map_direct_valid(vma->vm_private_data))
> +		return VM_FAULT_SIGBUS;
> +
> +	if (xfs_is_reflink_inode(XFS_I(inode)))
> +		return VM_FAULT_SIGBUS;
> +
> +	if (!IS_DAX(inode))
> +		return VM_FAULT_SIGBUS;

And how do we get is_xfs_map_direct() set to true if we don't have a
DAX inode or the inode has shared extents?

> +
> +	return 0;
> +}
> +
>  /*
>   * Locking for serialisation of IO during page faults. This results in a lock
>   * ordering of:
> @@ -1024,6 +1054,7 @@ __xfs_filemap_fault(
>  	enum page_entry_size	pe_size,
>  	bool			write_fault)
>  {
> +	struct vm_area_struct	*vma = vmf->vma;
>  	struct inode		*inode = file_inode(vmf->vma->vm_file);

You missed this vmf->vma....

.....
>  
> +#define XFS_MAP_SUPPORTED (LEGACY_MAP_MASK | MAP_DIRECT)
> +
> +STATIC int
> +xfs_file_mmap_validate(
> +	struct file		*filp,
> +	struct vm_area_struct	*vma,
> +	unsigned long		map_flags,
> +	int			fd)
> +{
> +	struct inode		*inode = file_inode(filp);
> +	struct xfs_inode	*ip = XFS_I(inode);
> +	struct map_direct_state	*mds;
> +
> +	if (map_flags & ~(XFS_MAP_SUPPORTED))
> +		return -EOPNOTSUPP;
> +
> +	if ((map_flags & MAP_DIRECT) == 0)
> +		return xfs_file_mmap(filp, vma);
> +
> +	file_accessed(filp);
> +	vma->vm_ops = &xfs_file_vm_direct_ops;
> +	if (IS_DAX(inode))
> +		vma->vm_flags |= VM_MIXEDMAP | VM_HUGEPAGE;

And if it isn't a DAX inode? what is MAP_DIRECT supposed to do then?

> +	mds = map_direct_register(fd, vma);
> +	if (IS_ERR(mds))
> +		return PTR_ERR(mds);
> +
> +	/* flush in-flight faults */
> +	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
> +	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);

Urk. That's nasty. And why is it even necessary? Please explain why
this is necessary in the comment, because it's not at all obvious to
me...

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
