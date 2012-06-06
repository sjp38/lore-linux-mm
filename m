Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 40ECA8D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 09:36:23 -0400 (EDT)
Date: Wed, 6 Jun 2012 23:36:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120606133616.GL22848@dastard>
References: <20120517074308.GQ25351@dastard>
 <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
 <20120518133250.GC5589@quack.suse.cz>
 <20120519014024.GZ25351@dastard>
 <20120524123538.GA5632@quack.suse.cz>
 <20120605055150.GF4347@dastard>
 <20120605231530.GB4402@quack.suse.cz>
 <20120606000636.GG22848@dastard>
 <20120606095827.GA6304@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120606095827.GA6304@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, Jun 06, 2012 at 11:58:27AM +0200, Jan Kara wrote:
> On Wed 06-06-12 10:06:36, Dave Chinner wrote:
> > On Wed, Jun 06, 2012 at 01:15:30AM +0200, Jan Kara wrote:
> > > On Tue 05-06-12 15:51:50, Dave Chinner wrote:
> > > > On Thu, May 24, 2012 at 02:35:38PM +0200, Jan Kara wrote:
> > > > > > To me the issue at hand is that we have no method of serialising
> > > > > > multi-page operations on the mapping tree between the filesystem and
> > > > > > the VM, and that seems to be the fundamental problem we face in this
> > > > > > whole area of mmap/buffered/direct IO/truncate/holepunch coherency.
> > > > > > Hence it might be better to try to work out how to fix this entire
> > > > > > class of problems rather than just adding a complex kuldge that just
> > > > > > papers over the current "hot" symptom....
> > > > >   Yes, looking at the above table, the amount of different synchronization
> > > > > mechanisms is really striking. So probably we should look at some
> > > > > possibility of unifying at least some cases.
> > > > 
> > > > It seems to me that we need some thing in between the fine grained
> > > > page lock and the entire-file IO exclusion lock. We need to maintain
> > > > fine grained locking for mmap scalability, but we also need to be
> > > > able to atomically lock ranges of pages.
> > >   Yes, we also need to keep things fine grained to keep scalability of
> > > direct IO and buffered reads...
> > > 
> > > > I guess if we were to nest a fine grained multi-state lock
> > > > inside both the IO exclusion lock and the mmap_sem, we might be able
> > > > to kill all problems in one go.
> > > > 
> > > > Exclusive access on a range needs to be granted to:
> > > > 
> > > > 	- direct IO
> > > > 	- truncate
> > > > 	- hole punch
> > > > 
> > > > so they can be serialised against mmap based page faults, writeback
> > > > and concurrent buffered IO. Serialisation against themselves is an
> > > > IO/fs exclusion problem.
> > > > 
> > > > Shared access for traversal or modification needs to be granted to:
> > > > 
> > > > 	- buffered IO
> > > > 	- mmap page faults
> > > > 	- writeback
> > > > 
> > > > Each of these cases can rely on the existing page locks or IO
> > > > exclusion locks to provide safety for concurrent access to the same
> > > > ranges. This means that once we have access granted to a range we
> > > > can check truncate races once and ignore the problem until we drop
> > > > the access.  And the case of taking a page fault within a buffered
> > > > IO won't deadlock because both take a shared lock....
> > >   You cannot just use a lock (not even a shared one) both above and under
> > > mmap_sem. That is deadlockable in presence of other requests for exclusive
> > > locking...
> > 
> > Well, that's assuming that exclusive lock requests form a barrier to
> > new shared requests. Remember that I'm talking about a range lock
> > here, which we can make up whatever semantics we'd need, including
> > having "shared lock if already locked shared" nested locking
> > semantics which avoids this page-fault-in-buffered-IO-copy-in/out
> > problem....
>   That's true. But if you have semantics like this, constant writing to
> or reading from a file could starve e.g. truncate. So I'd prefer not to
> open this can of worms and keep semantics of rw semaphores if possible.

Except truncate uses the i_mutex/i_iolock for exclusion, so it would
never get held off any more than it already does by buffered IO in
this case. i.e. the mapping tree range lock is inside the locks used
for truncate serialisation, so we don't have a situation where other
operations woul dbe held off by such an IO pattern...

> Furthermore, with direct IO you have to set in stone the ordering of
> mmap_sem and range lock anyway because there we need an exclusive lock.

Yes, mmap basically requires exclusive mmap_sem->shared range lock ordering. For
direct IO, we only need the mmap_sem for the get_user_pages() call
IIRC, so that requires exclusive range lock-> shared mmap_sem
ordering. Unless we can lift the range lock in the mmap path outside
the mmap_sem, we're still in the same boat....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
