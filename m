Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4B0A66B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 19:15:32 -0400 (EDT)
Date: Wed, 6 Jun 2012 01:15:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Hole punching and mmap races
Message-ID: <20120605231530.GB4402@quack.suse.cz>
References: <20120515224805.GA25577@quack.suse.cz>
 <20120516021423.GO25351@dastard>
 <20120516130445.GA27661@quack.suse.cz>
 <20120517074308.GQ25351@dastard>
 <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
 <20120518133250.GC5589@quack.suse.cz>
 <20120519014024.GZ25351@dastard>
 <20120524123538.GA5632@quack.suse.cz>
 <20120605055150.GF4347@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605055150.GF4347@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue 05-06-12 15:51:50, Dave Chinner wrote:
> On Thu, May 24, 2012 at 02:35:38PM +0200, Jan Kara wrote:
> > > To me the issue at hand is that we have no method of serialising
> > > multi-page operations on the mapping tree between the filesystem and
> > > the VM, and that seems to be the fundamental problem we face in this
> > > whole area of mmap/buffered/direct IO/truncate/holepunch coherency.
> > > Hence it might be better to try to work out how to fix this entire
> > > class of problems rather than just adding a complex kuldge that just
> > > papers over the current "hot" symptom....
> >   Yes, looking at the above table, the amount of different synchronization
> > mechanisms is really striking. So probably we should look at some
> > possibility of unifying at least some cases.
> 
> It seems to me that we need some thing in between the fine grained
> page lock and the entire-file IO exclusion lock. We need to maintain
> fine grained locking for mmap scalability, but we also need to be
> able to atomically lock ranges of pages.
  Yes, we also need to keep things fine grained to keep scalability of
direct IO and buffered reads...

> I guess if we were to nest a fine grained multi-state lock
> inside both the IO exclusion lock and the mmap_sem, we might be able
> to kill all problems in one go.
> 
> Exclusive access on a range needs to be granted to:
> 
> 	- direct IO
> 	- truncate
> 	- hole punch
> 
> so they can be serialised against mmap based page faults, writeback
> and concurrent buffered IO. Serialisation against themselves is an
> IO/fs exclusion problem.
> 
> Shared access for traversal or modification needs to be granted to:
> 
> 	- buffered IO
> 	- mmap page faults
> 	- writeback
> 
> Each of these cases can rely on the existing page locks or IO
> exclusion locks to provide safety for concurrent access to the same
> ranges. This means that once we have access granted to a range we
> can check truncate races once and ignore the problem until we drop
> the access.  And the case of taking a page fault within a buffered
> IO won't deadlock because both take a shared lock....
  You cannot just use a lock (not even a shared one) both above and under
mmap_sem. That is deadlockable in presence of other requests for exclusive
locking... Luckily, with buffered writes the situation isn't that bad. You
need mmap_sem only before each page is processed (in
iov_iter_fault_in_readable()). Later on in the loop we use
iov_iter_copy_from_user_atomic() which doesn't need mmap_sem. So we can
just get our shared lock after iov_iter_fault_in_readable() (or simply
leave it for ->write_begin() if we want to give control over the locking to
filesystems).
 
> We'd need some kind of efficient shared/exclusive range lock for
> this sort of exclusion, and it's entirely possible that it would
> have too much overhead to be acceptible in the page fault path. It's
> the best I can think of right now.....
>
> As it is, a range lock of this kind would be very handy for other
> things, too (like the IO exclusion locks so we can do concurrent
> buffered writes in XFS ;).
  Yes, that's what I thought as well. In particular it should be pretty
efficient in locking a single page range because that's going to be
majority of calls. I'll try to write something and see how fast it can
be...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
