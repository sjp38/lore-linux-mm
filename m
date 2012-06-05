Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id AE0B46B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 01:51:55 -0400 (EDT)
Date: Tue, 5 Jun 2012 15:51:50 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120605055150.GF4347@dastard>
References: <20120515224805.GA25577@quack.suse.cz>
 <20120516021423.GO25351@dastard>
 <20120516130445.GA27661@quack.suse.cz>
 <20120517074308.GQ25351@dastard>
 <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
 <20120518133250.GC5589@quack.suse.cz>
 <20120519014024.GZ25351@dastard>
 <20120524123538.GA5632@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120524123538.GA5632@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Thu, May 24, 2012 at 02:35:38PM +0200, Jan Kara wrote:
> On Sat 19-05-12 11:40:24, Dave Chinner wrote:
> > So let's step back a moment and have a look at how we've got here.
> > The problem is that we've optimised ourselves into a corner with the
> > way we handle page cache truncation - we don't need mmap
> > serialisation because of the combination of i_size and page locks
> > mean we can detect truncated pages safely at page fault time. With
> > hole punching, we don't have that i_size safety blanket, and so we
> > need some other serialisation mechanism to safely detect whether a
> > page is valid or not at any given point in time.
> > 
> > Because it needs to serialise against IO operations, we need a
> > sleeping lock of some kind, and it can't be the existing IO lock.
> > And now we are looking at needing a new lock for hole punching, I'm
> > really wondering if the i_size/page lock truncation optimisation
> > should even continue to exist. i.e. replace it with a single
> > mechanism that works for both hole punching, truncation and other
> > functions that require exclusive access or exclusion against
> > modifications to the mapping tree.
> > 
> > But this is only one of the problems in this area.The way I see it
> > is that we have many kludges in the area of page invalidation w.r.t.
> > different types of IO, the page cache and mmap, especially when we
> > take into account direct IO. What we are seeing here is we need
> > some level of _mapping tree exclusion_ between:
> > 
> > 	1. mmap vs hole punch (broken)
> > 	2. mmap vs truncate (i_size/page lock)
> > 	3. mmap vs direct IO (non-existent)
> > 	4. mmap vs buffered IO (page lock)
> > 	5. writeback vs truncate (i_size/page lock)
> > 	6. writeback vs hole punch (page lock, possibly broken)
> > 	7. direct IO vs buffered IO (racy - flush cache before/after DIO)
>   Yes, this is a nice summary of the most interesting cases. For completeness,
> here are the remaining cases:
>   8. mmap vs writeback (page lock)
>   9. writeback vs direct IO (as direct IO vs buffered IO)
>  10. writeback vs buffered IO (page lock)
>  11. direct IO vs truncate (dio_wait)
>  12. direct IO vs hole punch (dio_wait)
>  13. buffered IO vs truncate (i_mutex for writes, i_size/page lock for reads)
>  14. buffered IO vs hole punch (fs dependent, broken for ext4)
>  15. truncate vs hole punch (fs dependent)
>  16. mmap vs mmap (page lock)
>  17. writeback vs writeback (page lock)
>  18. direct IO vs direct IO (i_mutex or fs dependent)
>  19. buffered IO vs buffered IO (i_mutex for writes, page lock for reads)
>  20. truncate vs truncate (i_mutex)
>  21. punch hole vs punch hole (fs dependent)

A lot of them are the IO exclusion side of the problem - I
ignored them just to make my discussion short and
to the point. So thanks for documenting them for everyone. :)

....

> > To me the issue at hand is that we have no method of serialising
> > multi-page operations on the mapping tree between the filesystem and
> > the VM, and that seems to be the fundamental problem we face in this
> > whole area of mmap/buffered/direct IO/truncate/holepunch coherency.
> > Hence it might be better to try to work out how to fix this entire
> > class of problems rather than just adding a complex kuldge that just
> > papers over the current "hot" symptom....
>   Yes, looking at the above table, the amount of different synchronization
> mechanisms is really striking. So probably we should look at some
> possibility of unifying at least some cases.

It seems to me that we need some thing in between the fine grained
page lock and the entire-file IO exclusion lock. We need to maintain
fine grained locking for mmap scalability, but we also need to be
able to atomically lock ranges of pages.

I guess if we were to nest a fine grained multi-state lock
inside both the IO exclusion lock and the mmap_sem, we might be able
to kill all problems in one go.

Exclusive access on a range needs to be granted to:

	- direct IO
	- truncate
	- hole punch

so they can be serialised against mmap based page faults, writeback
and concurrent buffered IO. Serialisation against themselves is an
IO/fs exclusion problem.

Shared access for traversal or modification needs to be granted to:

	- buffered IO
	- mmap page faults
	- writeback

Each of these cases can rely on the existing page locks or IO
exclusion locks to provide safety for concurrent access to the same
ranges. This means that once we have access granted to a range we
can check truncate races once and ignore the problem until we drop
the access.  And the case of taking a page fault within a buffered
IO won't deadlock because both take a shared lock....

We'd need some kind of efficient shared/exclusive range lock for
this sort of exclusion, and it's entirely possible that it would
have too much overhead to be acceptible in the page fault path. It's
the best I can think of right now.....

As it is, a range lock of this kind would be very handy for other
things, too (like the IO exclusion locks so we can do concurrent
buffered writes in XFS ;).

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
