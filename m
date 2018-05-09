Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 924816B051D
	for <linux-mm@kvack.org>; Wed,  9 May 2018 10:38:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63so24447233pfl.12
        for <linux-mm@kvack.org>; Wed, 09 May 2018 07:38:52 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j3-v6si26200957pld.300.2018.05.09.07.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 07:38:51 -0700 (PDT)
Date: Wed, 9 May 2018 07:38:43 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v9 9/9] xfs, dax: introduce xfs_break_dax_layouts()
Message-ID: <20180509143843.GH11261@magnolia>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152461283072.17530.11313844322317294220.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152461283072.17530.11313844322317294220.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 24, 2018 at 04:33:50PM -0700, Dan Williams wrote:
> xfs_break_dax_layouts(), similar to xfs_break_leased_layouts(), scans
> for busy / pinned dax pages and waits for those pages to go idle before
> any potential extent unmap operation.
> 
> dax_layout_busy_page() handles synchronizing against new page-busy
> events (get_user_pages). It invalidates all mappings to trigger the
> get_user_pages slow path which will eventually block on the xfs inode
> lock held in XFS_MMAPLOCK_EXCL mode. If dax_layout_busy_page() finds a
> busy page it returns it for xfs to wait for the page-idle event that
> will fire when the page reference count reaches 1 (recall ZONE_DEVICE
> pages are idle at count 1, see generic_dax_pagefree()).
> 
> While waiting, the XFS_MMAPLOCK_EXCL lock is dropped in order to not
> deadlock the process that might be trying to elevate the page count of
> more pages before arranging for any of them to go idle. I.e. the typical
> case of submitting I/O is that iov_iter_get_pages() elevates the
> reference count of all pages in the I/O before starting I/O on the first
> page. The process of elevating the reference count of all pages involved
> in an I/O may cause faults that need to take XFS_MMAPLOCK_EXCL.
> 
> Although XFS_MMAPLOCK_EXCL is dropped while waiting, XFS_IOLOCK_EXCL is
> held while sleeping. We need this to prevent starvation of the truncate
> path as continuous submission of direct-I/O could starve the truncate
> path indefinitely if the lock is dropped.
> 
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I should've acked this explicitly since it's xfs code,
Acked-by: Darrick J. Wong <darrick.wong@oracle.com>

The rest of it looks fine enough to me too, but there's no
Acked-by-goober tag to put on them. :P

--D

> ---
>  fs/xfs/xfs_file.c |   59 +++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 48 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 1a5176b21803..4e98d0dcc035 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -718,6 +718,37 @@ xfs_file_write_iter(
>  	return ret;
>  }
>  
> +static void
> +xfs_wait_dax_page(
> +	struct inode		*inode,
> +	bool			*did_unlock)
> +{
> +	struct xfs_inode        *ip = XFS_I(inode);
> +
> +	*did_unlock = true;
> +	xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> +	schedule();
> +	xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
> +}
> +
> +static int
> +xfs_break_dax_layouts(
> +	struct inode		*inode,
> +	uint			iolock,
> +	bool			*did_unlock)
> +{
> +	struct page		*page;
> +
> +	*did_unlock = false;
> +	page = dax_layout_busy_page(inode->i_mapping);
> +	if (!page)
> +		return 0;
> +
> +	return ___wait_var_event(&page->_refcount,
> +			atomic_read(&page->_refcount) == 1, TASK_INTERRUPTIBLE,
> +			0, 0, xfs_wait_dax_page(inode, did_unlock));
> +}
> +
>  int
>  xfs_break_layouts(
>  	struct inode		*inode,
> @@ -729,17 +760,23 @@ xfs_break_layouts(
>  
>  	ASSERT(xfs_isilocked(XFS_I(inode), XFS_IOLOCK_SHARED|XFS_IOLOCK_EXCL));
>  
> -	switch (reason) {
> -	case BREAK_UNMAP:
> -		ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
> -		/* fall through */
> -	case BREAK_WRITE:
> -		error = xfs_break_leased_layouts(inode, iolock, &retry);
> -		break;
> -	default:
> -		WARN_ON_ONCE(1);
> -		return -EINVAL;
> -	}
> +	do {
> +		switch (reason) {
> +		case BREAK_UNMAP:
> +			ASSERT(xfs_isilocked(XFS_I(inode), XFS_MMAPLOCK_EXCL));
> +
> +			error = xfs_break_dax_layouts(inode, *iolock, &retry);
> +			/* fall through */
> +		case BREAK_WRITE:
> +			if (error || retry)
> +				break;
> +			error = xfs_break_leased_layouts(inode, iolock, &retry);
> +			break;
> +		default:
> +			WARN_ON_ONCE(1);
> +			return -EINVAL;
> +		}
> +	} while (error == 0 && retry);
>  
>  	return error;
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
