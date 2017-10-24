Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9E816B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 18:23:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b6so18218760pff.18
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 15:23:27 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id a33si691117plc.53.2017.10.24.15.23.25
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 15:23:26 -0700 (PDT)
Date: Wed, 25 Oct 2017 09:23:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Message-ID: <20171024222322.GX3666@dastard>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-18-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024152415.22864-18-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>

On Tue, Oct 24, 2017 at 05:24:14PM +0200, Jan Kara wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Return IOMAP_F_DIRTY from xfs_file_iomap_begin() when asked to prepare
> blocks for writing and the inode is pinned, and has dirty fields other
> than the timestamps.

That's "fdatasync dirty", not "fsync dirty".

IOMAP_F_DIRTY needs a far better description of it's semantics than
"/* block mapping is not yet on persistent storage */" so we know
exactly what filesystems are supposed to be implementing here. I
suspect that what it really is meant to say is:

/*
 * IOMAP_F_DIRTY indicates the inode has uncommitted metadata to
 * written data and requires fdatasync to commit to persistent storage.
 */

[....]

> diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> index f179bdf1644d..b43be199fbdf 100644
> --- a/fs/xfs/xfs_iomap.c
> +++ b/fs/xfs/xfs_iomap.c
> @@ -33,6 +33,7 @@
>  #include "xfs_error.h"
>  #include "xfs_trans.h"
>  #include "xfs_trans_space.h"
> +#include "xfs_inode_item.h"
>  #include "xfs_iomap.h"
>  #include "xfs_trace.h"
>  #include "xfs_icache.h"
> @@ -1086,6 +1087,10 @@ xfs_file_iomap_begin(
>  		trace_xfs_iomap_found(ip, offset, length, 0, &imap);
>  	}
>  
> +	if ((flags & IOMAP_WRITE) && xfs_ipincount(ip) &&
> +	    (ip->i_itemp->ili_fsync_fields & ~XFS_ILOG_TIMESTAMP))
> +		iomap->flags |= IOMAP_F_DIRTY;

This is the very definition of an inode that is "fdatasync dirty".

Hmmmm, shouldn't this also be set for read faults, too?

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
