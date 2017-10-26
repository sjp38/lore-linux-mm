Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 351F06B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 17:16:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l24so3724366pgu.22
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 14:16:35 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id r1si3462069plb.713.2017.10.26.14.16.32
        for <linux-mm@kvack.org>;
        Thu, 26 Oct 2017 14:16:33 -0700 (PDT)
Date: Fri, 27 Oct 2017 08:16:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 17/17] xfs: support for synchronous DAX faults
Message-ID: <20171026211611.GC3666@dastard>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-18-jack@suse.cz>
 <20171024222322.GX3666@dastard>
 <20171026154804.GF31161@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026154804.GF31161@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>

On Thu, Oct 26, 2017 at 05:48:04PM +0200, Jan Kara wrote:
> On Wed 25-10-17 09:23:22, Dave Chinner wrote:
> > On Tue, Oct 24, 2017 at 05:24:14PM +0200, Jan Kara wrote:
> > > From: Christoph Hellwig <hch@lst.de>
> > > 
> > > Return IOMAP_F_DIRTY from xfs_file_iomap_begin() when asked to prepare
> > > blocks for writing and the inode is pinned, and has dirty fields other
> > > than the timestamps.
> > 
> > That's "fdatasync dirty", not "fsync dirty".
> 
> Correct.
> 
> > IOMAP_F_DIRTY needs a far better description of it's semantics than
> > "/* block mapping is not yet on persistent storage */" so we know
> > exactly what filesystems are supposed to be implementing here. I
> > suspect that what it really is meant to say is:
> > 
> > /*
> >  * IOMAP_F_DIRTY indicates the inode has uncommitted metadata to
> >  * written data and requires fdatasync to commit to persistent storage.
> >  */
> 
> I'll update the comment. Thanks!
> 
> > [....]
> > 
> > > diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> > > index f179bdf1644d..b43be199fbdf 100644
> > > --- a/fs/xfs/xfs_iomap.c
> > > +++ b/fs/xfs/xfs_iomap.c
> > > @@ -33,6 +33,7 @@
> > >  #include "xfs_error.h"
> > >  #include "xfs_trans.h"
> > >  #include "xfs_trans_space.h"
> > > +#include "xfs_inode_item.h"
> > >  #include "xfs_iomap.h"
> > >  #include "xfs_trace.h"
> > >  #include "xfs_icache.h"
> > > @@ -1086,6 +1087,10 @@ xfs_file_iomap_begin(
> > >  		trace_xfs_iomap_found(ip, offset, length, 0, &imap);
> > >  	}
> > >  
> > > +	if ((flags & IOMAP_WRITE) && xfs_ipincount(ip) &&
> > > +	    (ip->i_itemp->ili_fsync_fields & ~XFS_ILOG_TIMESTAMP))
> > > +		iomap->flags |= IOMAP_F_DIRTY;
> > 
> > This is the very definition of an inode that is "fdatasync dirty".
> > 
> > Hmmmm, shouldn't this also be set for read faults, too?
> 
> No, read faults don't need to set IOMAP_F_DIRTY since user cannot write any
> data to the page which he'd then like to be persistent. The only reason why
> I thought it could be useful for a while was that it would be nice to make
> MAP_SYNC mapping provide the guarantee that data you see now is the data
> you'll see after a crash

Isn't that the entire point of MAP_SYNC? i.e. That when we return
from a page fault, the app knows that the data and it's underlying
extent is on persistent storage?

> but we cannot provide that guarantee for RO
> mapping anyway if someone else has the page mapped as well. So I just
> decided not to return IOMAP_F_DIRTY for read faults.

If there are multiple MAP_SYNC mappings to the inode, I would have
expected that they all sync all of the data/metadata on every page
fault, regardless of who dirtied the inode. An RO mapping doesn't
mean the data/metadata on the inode can't change, it just means it
can't change through that mapping.  Running fsync() to guarantee the
persistence of that data/metadata doesn't actually changing any
data....

IOWs, if read faults don't guarantee the mapped range has stable
extents on a MAP_SYNC mapping, then I think MAP_SYNC is broken
because it's not giving consistent guarantees to userspace. Yes, it
works fine when only one MAP_SYNC mapping is modifying the inode,
but the moment we have concurrent operations on the inode that
aren't MAP_SYNC or O_SYNC this goes out the window....

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
