Message-ID: <400539769.00869@ustc.edu.cn>
Date: Thu, 17 Jan 2008 11:16:00 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
References: <1200386774.15103.20.camel@twins> <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com> <400452490.28636@ustc.edu.cn> <20080115194415.64ba95f2.akpm@linux-foundation.org> <400457571.32162@ustc.edu.cn> <20080115204236.6349ac48.akpm@linux-foundation.org> <400459376.04290@ustc.edu.cn> <20080115215149.a881efff.akpm@linux-foundation.org> <E1JF4Ey-0000x4-5p@localhost.localdomain> <20080116223510.GY155407@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080116223510.GY155407@sgi.com>
Message-Id: <E1JFLEW-0002oE-G1@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 09:35:10AM +1100, David Chinner wrote:
> On Wed, Jan 16, 2008 at 05:07:20PM +0800, Fengguang Wu wrote:
> > On Tue, Jan 15, 2008 at 09:51:49PM -0800, Andrew Morton wrote:
> > > > Then to do better ordering by adopting radix tree(or rbtree
> > > > if radix tree is not enough),
> > > 
> > > ordering of what?
> > 
> > Switch from time to location.
> 
> Note that data writeback may be adversely affected by location
> based writeback rather than time based writeback - think of
> the effect of location based data writeback on an app that
> creates lots of short term (<30s) temp files and then removes
> them before they are written back.

A small(e.g. 5s) time window can still be enforced, but...

> Also, data writeback locatio cannot be easily derived from
> the inode number in pretty much all cases. "near" in terms
> of XFS means the same AG which means the data could be up to
> a TB away from the inode, and if you have >1TB filesystems
> usingthe default inode32 allocator, file data is *never*
> placed near the inode - the inodes are in the first TB of
> the filesystem, the data is rotored around the rest of the
> filesystem.
> 
> And with delayed allocation, you don't know where the data is even
> going to be written ahead of the filesystem ->writepage call, so you
> can't do optimal location ordering for data in this case.

Agreed.

> Hmmmm - I'm wondering if we'd do better to split data writeback from
> inode writeback. i.e. we do two passes.  The first pass writes all
> the data back in time order, the second pass writes all the inodes
> back in location order.
> 
> Right now we interleave data and inode writeback, (i.e.  we do data,
> inode, data, inode, data, inode, ....). I'd much prefer to see all
> data written out first, then the inodes. ->writepage often dirties
> the inode and hence if we need to do multiple do_writepages() calls
> on an inode to flush all the data (e.g. congestion, large amounts of
> data to be written, etc), we really shouldn't be calling
> write_inode() after every do_writepages() call. The inode
> should not be written until all the data is written....

That may do good to XFS. Another case is documented as follows:
"the write_inode() function of a typical fs will perform no I/O, but
will mark buffers in the blockdev mapping as dirty."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
