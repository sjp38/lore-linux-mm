Date: Thu, 17 Jan 2008 16:21:29 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
Message-ID: <20080117052129.GJ155259@sgi.com>
References: <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com> <400452490.28636@ustc.edu.cn> <20080115194415.64ba95f2.akpm@linux-foundation.org> <400457571.32162@ustc.edu.cn> <20080115204236.6349ac48.akpm@linux-foundation.org> <400459376.04290@ustc.edu.cn> <20080115215149.a881efff.akpm@linux-foundation.org> <E1JF4Ey-0000x4-5p@localhost.localdomain> <20080116223510.GY155407@sgi.com> <E1JFLEW-0002oE-G1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1JFLEW-0002oE-G1@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 17, 2008 at 11:16:00AM +0800, Fengguang Wu wrote:
> On Thu, Jan 17, 2008 at 09:35:10AM +1100, David Chinner wrote:
> > On Wed, Jan 16, 2008 at 05:07:20PM +0800, Fengguang Wu wrote:
> > > On Tue, Jan 15, 2008 at 09:51:49PM -0800, Andrew Morton wrote:
> > > > > Then to do better ordering by adopting radix tree(or rbtree
> > > > > if radix tree is not enough),
> > > > 
> > > > ordering of what?
> > > 
> > > Switch from time to location.
> > 
> > Note that data writeback may be adversely affected by location
> > based writeback rather than time based writeback - think of
> > the effect of location based data writeback on an app that
> > creates lots of short term (<30s) temp files and then removes
> > them before they are written back.
> 
> A small(e.g. 5s) time window can still be enforced, but...

Yes, you could, but that will then result in non-deterministic
performance for repeated workloads because the order of file
writeback will not be consistent.

e.g.  the first run is fast because the output file is at lower
offset than the temp file meaning the temp file gets deleted
without being written.

The second run is slow because the location of the files is
reversed and the temp file is written to disk before the
final output file and hence the run is much slower because
it writes much more.

The third run is also slow, but the files are like the first
fast run. However, pdflush tries to write the temp file back
within 5s of it being dirtied so it skips it and writes
the output file first.

The difference between the first+second case can be found by
knowing that inode number determines writeback order, but
there is no obvious clue as to why the first+third runs are
different.

This is exactly the sort of non-deterministic behaviour we 
want to avoid in a writeback algorithm.

> > Hmmmm - I'm wondering if we'd do better to split data writeback from
> > inode writeback. i.e. we do two passes.  The first pass writes all
> > the data back in time order, the second pass writes all the inodes
> > back in location order.
> > 
> > Right now we interleave data and inode writeback, (i.e.  we do data,
> > inode, data, inode, data, inode, ....). I'd much prefer to see all
> > data written out first, then the inodes. ->writepage often dirties
> > the inode and hence if we need to do multiple do_writepages() calls
> > on an inode to flush all the data (e.g. congestion, large amounts of
> > data to be written, etc), we really shouldn't be calling
> > write_inode() after every do_writepages() call. The inode
> > should not be written until all the data is written....
> 
> That may do good to XFS. Another case is documented as follows:
> "the write_inode() function of a typical fs will perform no I/O, but
> will mark buffers in the blockdev mapping as dirty."

Yup, but in that situation ->write_inode() does not do any I/O, so
it will work with any high level inode writeback ordering or timing
scheme equally well.  As a result, that's not the case we need to
optimise at all.

FWIW, the NFS client is likely to work better with split data/
inode writeback as it also has to mark the inode dirty on async
write completion (to get ->write_inode called to issue a commit
RPC). Hence delaying the inode write until after all the data
is written makes sense there as well....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
