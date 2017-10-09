Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52CEF6B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 23:08:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so13779215pfk.0
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 20:08:40 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id k8si5314747pgo.358.2017.10.08.20.08.38
        for <linux-mm@kvack.org>;
        Sun, 08 Oct 2017 20:08:39 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:08:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 03/12] fs: introduce i_mapdcount
Message-ID: <20171009030824.GG3666@dastard>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732933283.22363.570426117546397495.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150732933283.22363.570426117546397495.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Oct 06, 2017 at 03:35:32PM -0700, Dan Williams wrote:
> When ->iomap_begin() sees this count being non-zero and determines that
> the block map of the file needs to be modified to satisfy the I/O
> request it will instead return an error. This is needed for MAP_DIRECT
> where, due to locking constraints, we can't rely on xfs_break_layouts()
> to protect against allocating write-faults either from the process that
> setup the MAP_DIRECT mapping nor other processes that have the file
> mapped.  xfs_break_layouts() requires XFS_IOLOCK which is problematic to
> mix with the XFS_MMAPLOCK in the fault path.
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
>  fs/xfs/xfs_iomap.c |    9 +++++++++
>  include/linux/fs.h |   31 +++++++++++++++++++++++++++++++
>  2 files changed, 40 insertions(+)
> 
> diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> index a1909bc064e9..6816f8ebbdcf 100644
> --- a/fs/xfs/xfs_iomap.c
> +++ b/fs/xfs/xfs_iomap.c
> @@ -1053,6 +1053,15 @@ xfs_file_iomap_begin(
>  			goto out_unlock;
>  		}
>  		/*
> +		 * If a file has MAP_DIRECT mappings disable block map
> +		 * updates. This should only effect mmap write faults as
> +		 * other paths are protected by an FL_LAYOUT lease.
> +		 */
> +		if (i_mapdcount_read(inode)) {
> +			error = -ETXTBSY;
> +			goto out_unlock;
> +		}

That looks really fragile. For one, it's going to miss modifications
to reflinked files altogether. Ignoring that, however, I don't want to
have to care one bit about the internals of the MAP_DIRECT
implementation in the filesystem code. Hide it behind something with
an obvious name that returns the appropriate error and the
filesystem code becomes self documenting:

	if ((flags & IOMAP_WRITE) && imap_needs_alloc(inode, &imap, nimaps)) {
		.....
		error = iomap_can_allocate(inode);
		if (error)
			goto out_unlock;

Then you can put all the MAP_DIRECT stuff and the comments
explaining what is does inside the generic function that determines
if we are allowed to allocate on that inode or not.

> +		/*
>  		 * We cap the maximum length we map here to MAX_WRITEBACK_PAGES
>  		 * pages to keep the chunks of work done where somewhat symmetric
>  		 * with the work writeback does. This is a completely arbitrary
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index c2b9bf3dc4e9..f83871b188ff 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -642,6 +642,9 @@ struct inode {
>  	atomic_t		i_count;
>  	atomic_t		i_dio_count;
>  	atomic_t		i_writecount;
> +#ifdef CONFIG_FS_DAX
> +	atomic_t		i_mapdcount;	/* count of MAP_DIRECT vmas */
> +#endif

Is there any way to avoid growing the struct inode for this?

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
