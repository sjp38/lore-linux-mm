Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 32DC06B0071
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 17:58:46 -0400 (EDT)
Date: Thu, 7 Jun 2012 23:58:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Hole punching and mmap races
Message-ID: <20120607215835.GB393@quack.suse.cz>
References: <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
 <20120518133250.GC5589@quack.suse.cz>
 <20120519014024.GZ25351@dastard>
 <20120524123538.GA5632@quack.suse.cz>
 <20120605055150.GF4347@dastard>
 <20120605231530.GB4402@quack.suse.cz>
 <20120606000636.GG22848@dastard>
 <20120606095827.GA6304@quack.suse.cz>
 <20120606133616.GL22848@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120606133616.GL22848@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed 06-06-12 23:36:16, Dave Chinner wrote:
> On Wed, Jun 06, 2012 at 11:58:27AM +0200, Jan Kara wrote:
> > On Wed 06-06-12 10:06:36, Dave Chinner wrote:
> > > On Wed, Jun 06, 2012 at 01:15:30AM +0200, Jan Kara wrote:
> > > > On Tue 05-06-12 15:51:50, Dave Chinner wrote:
> > > > > On Thu, May 24, 2012 at 02:35:38PM +0200, Jan Kara wrote:
> > > > > > > To me the issue at hand is that we have no method of serialising
> > > > > > > multi-page operations on the mapping tree between the filesystem and
> > > > > > > the VM, and that seems to be the fundamental problem we face in this
> > > > > > > whole area of mmap/buffered/direct IO/truncate/holepunch coherency.
> > > > > > > Hence it might be better to try to work out how to fix this entire
> > > > > > > class of problems rather than just adding a complex kuldge that just
> > > > > > > papers over the current "hot" symptom....
> > > > > >   Yes, looking at the above table, the amount of different synchronization
> > > > > > mechanisms is really striking. So probably we should look at some
> > > > > > possibility of unifying at least some cases.
> > > > > 
> > > > > It seems to me that we need some thing in between the fine grained
> > > > > page lock and the entire-file IO exclusion lock. We need to maintain
> > > > > fine grained locking for mmap scalability, but we also need to be
> > > > > able to atomically lock ranges of pages.
> > > >   Yes, we also need to keep things fine grained to keep scalability of
> > > > direct IO and buffered reads...
> > > > 
> > > > > I guess if we were to nest a fine grained multi-state lock
> > > > > inside both the IO exclusion lock and the mmap_sem, we might be able
> > > > > to kill all problems in one go.
> > > > > 
> > > > > Exclusive access on a range needs to be granted to:
> > > > > 
> > > > > 	- direct IO
> > > > > 	- truncate
> > > > > 	- hole punch
> > > > > 
> > > > > so they can be serialised against mmap based page faults, writeback
> > > > > and concurrent buffered IO. Serialisation against themselves is an
> > > > > IO/fs exclusion problem.
> > > > > 
> > > > > Shared access for traversal or modification needs to be granted to:
> > > > > 
> > > > > 	- buffered IO
> > > > > 	- mmap page faults
> > > > > 	- writeback
> > > > > 
> > > > > Each of these cases can rely on the existing page locks or IO
> > > > > exclusion locks to provide safety for concurrent access to the same
> > > > > ranges. This means that once we have access granted to a range we
> > > > > can check truncate races once and ignore the problem until we drop
> > > > > the access.  And the case of taking a page fault within a buffered
> > > > > IO won't deadlock because both take a shared lock....
> > > >   You cannot just use a lock (not even a shared one) both above and under
> > > > mmap_sem. That is deadlockable in presence of other requests for exclusive
> > > > locking...
> > > 
> > > Well, that's assuming that exclusive lock requests form a barrier to
> > > new shared requests. Remember that I'm talking about a range lock
> > > here, which we can make up whatever semantics we'd need, including
> > > having "shared lock if already locked shared" nested locking
> > > semantics which avoids this page-fault-in-buffered-IO-copy-in/out
> > > problem....
> >   That's true. But if you have semantics like this, constant writing to
> > or reading from a file could starve e.g. truncate. So I'd prefer not to
> > open this can of worms and keep semantics of rw semaphores if possible.
> 
> Except truncate uses the i_mutex/i_iolock for exclusion, so it would
> never get held off any more than it already does by buffered IO in
> this case. i.e. the mapping tree range lock is inside the locks used
> for truncate serialisation, so we don't have a situation where other
> operations woul dbe held off by such an IO pattern...
  True. I was just hoping that i_mutex won't be needed if we get our new
lock right.

> > Furthermore, with direct IO you have to set in stone the ordering of
> > mmap_sem and range lock anyway because there we need an exclusive lock.
> 
> Yes, mmap basically requires exclusive mmap_sem->shared range lock ordering. For
> direct IO, we only need the mmap_sem for the get_user_pages() call
> IIRC, so that requires exclusive range lock-> shared mmap_sem
> ordering. Unless we can lift the range lock in the mmap path outside
> the mmap_sem, we're still in the same boat....
  Yes. Just as I said before it is not an unsolvable situation since for
direct IO we can grab our lock after get_user_pages() call. I was thinking
about it for a while and I realized, that if we have range lock that we
take during page fault, buffered IO, direct IO, truncate, punch hole, we
actually don't need a shared version of it. Just the fact it would be range
lock is enough to avoid serialization.

Also I was thinking that since lock ordering forces our new lock to be
relatively close to page lock and page lock is serializing quite some of
IO operations anyway, it might be workable (and actually reasonably easy
to grasp for developers) if the range lock is coupled with page lock - i.e.
locking a range will be equivalent to locking each page in a range, except
that this way you can "lock" pages which are not present and thus forbid
their creation. Also we could implement the common case of locking a range
containing single page by just taking page lock so we save modification of
interval tree in the common case and generally make the tree smaller (of
course, at the cost of somewhat slowing down cases where we want to lock
larger ranges).

Using something like this in ext4 should be reasonably easy, we'd just need
to change some code to move page lock up in locking order to make locking
of ranges useful. Would it be also usable for XFS?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
