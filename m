Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7829E6B0069
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 20:09:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so18704458pgn.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 17:09:01 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id e62si1161205pfa.196.2017.09.25.17.08.59
        for <linux-mm@kvack.org>;
        Mon, 25 Sep 2017 17:09:00 -0700 (PDT)
Date: Tue, 26 Sep 2017 09:29:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/7] xfs: protect S_DAX transitions in XFS write path
Message-ID: <20170925232945.GL10955@dastard>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-5-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-5-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:14:01PM -0600, Ross Zwisler wrote:
> In the current XFS write I/O path we check IS_DAX() in
> xfs_file_write_iter() to decide whether to do DAX I/O, direct I/O or
> buffered I/O.  This check is done without holding the XFS_IOLOCK, though,
> which means that if we allow S_DAX to be manipulated via the inode flag we
> can run into this race:
> 
> CPU 0                           CPU 1
> -----                           -----
> xfs_file_write_iter()
>   IS_DAX() << returns false
> 			    xfs_ioctl_setattr()
> 			      xfs_ioctl_setattr_dax_invalidate()
> 			       xfs_ilock(XFS_MMAPLOCK|XFS_IOLOCK)
> 			      sets S_DAX
> 			      releases XFS_MMAPLOCK and XFS_IOLOCK
>   xfs_file_buffered_aio_write()
>   does buffered I/O to DAX inode, death
> 
> Fix this by ensuring that we only check S_DAX when we hold the XFS_IOLOCK
> in the write path.

NACK. This breaks concurrent direct IO write semantics. We must not
take XFS_IOLOCK_EXCL on direct IO writes unless it is absolutely
necessary - there are lots of applications out there that rely on
these semantics for performance.

CHeers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
