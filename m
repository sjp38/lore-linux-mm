Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7D356B025F
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 19:33:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t80so52171655pgb.0
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 16:33:28 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id u204si1053542pgb.742.2017.08.11.16.33.26
        for <linux-mm@kvack.org>;
        Fri, 11 Aug 2017 16:33:27 -0700 (PDT)
Date: Sat, 12 Aug 2017 09:33:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 6/6] mm, xfs: protect swapfile contents with immutable
 + unwritten extents
Message-ID: <20170811233323.GU21024@dastard>
References: <150243355681.8777.14902834768886160223.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150243358949.8777.17308615269167142735.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150243358949.8777.17308615269167142735.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: darrick.wong@oracle.com, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anna Schumaker <anna.schumaker@netapp.com>

On Thu, Aug 10, 2017 at 11:39:49PM -0700, Dan Williams wrote:
>  	ifp = XFS_IFORK_PTR(ip, whichfork);
> diff --git a/fs/xfs/libxfs/xfs_bmap.h b/fs/xfs/libxfs/xfs_bmap.h
> index 851982a5dfbc..a0f099289520 100644
> --- a/fs/xfs/libxfs/xfs_bmap.h
> +++ b/fs/xfs/libxfs/xfs_bmap.h
> @@ -113,6 +113,15 @@ struct xfs_extent_free_item
>  /* Only convert delalloc space, don't allocate entirely new extents */
>  #define XFS_BMAPI_DELALLOC	0x400
>  
> +/*
> + * Permit extent manipulations even if S_IOMAP_IMMUTABLE is set on the
> + * inode. This is only expected to be used in the swapfile activation
> + * case where we want to mark all swap space as unwritten so that reads
> + * return zero and writes fail with ETXTBSY. Storage access in this
> + * state can only occur via swap operations.
> + */
> +#define XFS_BMAPI_FORCE		0x800

Urk. No. Immutable means immutable.

And, as a matter of policy, we should not be changing the on disk
layout of the swapfile that is provided inside the kernel.  If the
swap file is already allocated as unwritten, great. If not, we
should not force it to be unwritten to be because then if the user
downgrades their kernel the swapfile suddenly can not be used by the
older kernel.

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
