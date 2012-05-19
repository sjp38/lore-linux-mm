Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 280C76B0081
	for <linux-mm@kvack.org>; Fri, 18 May 2012 21:40:30 -0400 (EDT)
Date: Sat, 19 May 2012 11:40:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120519014024.GZ25351@dastard>
References: <20120515224805.GA25577@quack.suse.cz>
 <20120516021423.GO25351@dastard>
 <20120516130445.GA27661@quack.suse.cz>
 <20120517074308.GQ25351@dastard>
 <20120517232829.GA31028@quack.suse.cz>
 <20120518101210.GX25351@dastard>
 <20120518133250.GC5589@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120518133250.GC5589@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Fri, May 18, 2012 at 03:32:50PM +0200, Jan Kara wrote:
> On Fri 18-05-12 20:12:10, Dave Chinner wrote:
> > On Fri, May 18, 2012 at 01:28:29AM +0200, Jan Kara wrote:
> > > On Thu 17-05-12 17:43:08, Dave Chinner wrote:
> > > > On Wed, May 16, 2012 at 03:04:45PM +0200, Jan Kara wrote:
> > > > > On Wed 16-05-12 12:14:23, Dave Chinner wrote:
> > > > IIRC, it's a rare case (that I consider insane, BTW):  read from a
> > > > file with into a buffer that is a mmap()d region of the same file
> > > > that has not been faulted in yet.....
> > >   With punch hole, the race is less insane - just punching hole in the area
> > > which is accessed via mmap could race in a bad way AFAICS.
> > 
> > Seems the simple answer to me is to prevent page faults while hole
> > punching, then....
>   Yes, that's what I was suggesting in the beginning :) And I was asking
> whether people are OK with another lock in the page fault path (in
> particular in ->page_mkwrite)

Right. I probably should have been clearer in what I said. We got
back here from considering another IO level lock and all the
complexity it adds to just solve the hole punch problem....

> or whether someone has a better idea (e.g.
> taking mmap_sem in the hole punching path seems possible but I'm not sure
> whether that would be considered acceptable abuse).

That's for the VM guys to answer, but it seems wrong to me to have
to treat hole punching differently to truncation....

The thing is, mmap IO is completely unlocked from an IO perspective,
and that means we cannot guarantee exclusion from IO without using
the IO exclusion lock. That's the simplest way we can make mmap
serialise sanely against direct IO and hole punching. Hole punching
is inherently a filesystem operation (just like truncation), and
mmap operations must stall while it is in progress. It's just that
we have the problem that we allow the mmap_sem to be taken inside
the IO exclusion locks...

So let's step back a moment and have a look at how we've got here.
The problem is that we've optimised ourselves into a corner with the
way we handle page cache truncation - we don't need mmap
serialisation because of the combination of i_size and page locks
mean we can detect truncated pages safely at page fault time. With
hole punching, we don't have that i_size safety blanket, and so we
need some other serialisation mechanism to safely detect whether a
page is valid or not at any given point in time.

Because it needs to serialise against IO operations, we need a
sleeping lock of some kind, and it can't be the existing IO lock.
And now we are looking at needing a new lock for hole punching, I'm
really wondering if the i_size/page lock truncation optimisation
should even continue to exist. i.e. replace it with a single
mechanism that works for both hole punching, truncation and other
functions that require exclusive access or exclusion against
modifications to the mapping tree.

But this is only one of the problems in this area.The way I see it
is that we have many kludges in the area of page invalidation w.r.t.
different types of IO, the page cache and mmap, especially when we
take into account direct IO. What we are seeing here is we need
some level of _mapping tree exclusion_ between:

	1. mmap vs hole punch (broken)
	2. mmap vs truncate (i_size/page lock)
	3. mmap vs direct IO (non-existent)
	4. mmap vs buffered IO (page lock)
	5. writeback vs truncate (i_size/page lock)
	6. writeback vs hole punch (page lock, possibly broken)
	7. direct IO vs buffered IO (racy - flush cache before/after DIO)

#1, #2, #5 and #6 could be solved by a rw-lock for the operations -
read for mmap/writeback, exclusive for hole-punch and truncation.
That, however, doesn't work for #3 and #4 as the exclusion is
inverted - direct/buffered IO would require a shared mode lock and
mmap requires the exclusive lock.  Similarly, #7 requires a shared
lock for direct IO, and a shared lock for buffered IO, but exclusion
between the two for overlapping ranges. But no one locking primitive
that currently exists can give us this set of semantics....

Right now we are talking about hacking in some solution to #1, while
ignoring the wider range of related but ignored/papered over
problems we also have. I don't have a magic bullet that solves all
of these problems, but I think it is worth recognising and
considering that this problem is much larger than just hole punching
and that these problems have been there for a *long time*.

To me the issue at hand is that we have no method of serialising
multi-page operations on the mapping tree between the filesystem and
the VM, and that seems to be the fundamental problem we face in this
whole area of mmap/buffered/direct IO/truncate/holepunch coherency.
Hence it might be better to try to work out how to fix this entire
class of problems rather than just adding a complex kuldge that just
papers over the current "hot" symptom....

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
