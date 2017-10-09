Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFC076B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 23:45:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so40496695pfd.4
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 20:45:10 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id q2si5561174pll.54.2017.10.08.20.45.09
        for <linux-mm@kvack.org>;
        Sun, 08 Oct 2017 20:45:09 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:45:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 09/12] xfs: wire up ->lease_direct()
Message-ID: <20171009034506.GI3666@dastard>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732936625.22363.7638037715540836828.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150732936625.22363.7638037715540836828.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Oct 06, 2017 at 03:36:06PM -0700, Dan Williams wrote:
> A 'lease_direct' lease requires that the vma have a valid MAP_DIRECT
> mapping established. For xfs we establish a new lease and then check if
> the MAP_DIRECT mapping has been broken. We want to be sure that the
> process will receive notification that the MAP_DIRECT mapping is being
> torn down so it knows why other code paths are throwing failures.
> 
> For example in the RDMA/ibverbs case we want ibv_reg_mr() to fail if the
> MAP_DIRECT mapping is invalid or in the process of being invalidated.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Layton <jlayton@poochiereds.net>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/xfs/xfs_file.c |   28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index e35518600e28..823b65f17429 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -1166,6 +1166,33 @@ xfs_filemap_direct_close(
>  	put_map_direct_vma(vma->vm_private_data);
>  }
>  
> +static struct lease_direct *
> +xfs_filemap_direct_lease(
> +	struct vm_area_struct	*vma,
> +	void			(*break_fn)(void *),
> +	void			*owner)
> +{
> +	struct lease_direct	*ld;
> +
> +	ld = map_direct_lease(vma, break_fn, owner);
> +
> +	if (IS_ERR(ld))
> +		return ld;
> +
> +	/*
> +	 * We now have an established lease while the base MAP_DIRECT
> +	 * lease was not broken. So, we know that the "lease holder" will
> +	 * receive a SIGIO notification when the lease is broken and
> +	 * take any necessary cleanup actions.
> +	 */
> +	if (!is_map_direct_broken(vma->vm_private_data))
> +		return ld;
> +
> +	map_direct_lease_destroy(ld);
> +
> +	return ERR_PTR(-ENXIO);

What's any of this got to do with XFS? Shouldn't it be in generic
code, and called generic_filemap_direct_lease()?

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
