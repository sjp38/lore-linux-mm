Message-ID: <3D253DC9.545865D4@zip.com.au>
Date: Thu, 04 Jul 2002 23:33:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: vm lock contention reduction
References: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com> <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 4 Jul 2002, Linus Torvalds wrote:
> >
> > Right now, we get roughly this behaviour simply by way of statistical
> > behaviour for the page allocator ("if somebody allocates 5 times as many
> > pages, he's 5 times as likely to have to clean something up too"), but
> > trying to be smarter about this could easily break this relative fairness.
> 
> Side note: getting some higher-level locking wrong can _seriously_ break
> this statistical behaviour.
> 
> In particular, the ext2 superblock lock at least used to be horribly
> broken and held in a lot of "bad" places: I doubt Al has gotten far enough
> to fix that brokenness. The superblock lock used to cause one process that
> blocked for something (usually reading in some bitmap or other) to cause a
> lot of _other_ processes to block quite unnecessarily on the badly placed
> lock, even though they really would have had all the resources they
> needed.

ext2 is still performing synchronous bitmap reads inside lock_super()
and yes, that shuts down the filesystem.  But once the bitmaps are
in cache, it's not a huge problem.

Unless you have an Anton-class box.   The context switch on the lock_super
in the ext2 block allocator is now one of his major throughput bottlenecks.

Although I must say, we're talking about filesystem loads here which
are purely RAM-based - fifteen-second tests which never hit disk.
This is kinda silly, because it's not a very interesting operating
region.  But it's fun - I think we've doubled 2.4 throughput now.

> That particular thing is really not a VM problem, but a ext2 issue. The
> superblock lock just isn't very well placed. I personally suspect that it
> should be replaced by a spinlock - just to force all blocking operations
> to be moved outside the lock (so that it would only protect the actual
> data structures - rather than be held around reading bitmap blocks into
> memory etc).

It can become a per-blockgroup spinlock.  That will scale splendidly.
Removing the private bitmap LRUs gets us partway toward that.   But
the bitmap buffers tend to get shoved up onto the active list real
quick when you start pushing things.

> But that's a rather painful kind of locking change to do and to test.

Well.  First locks first.  kmap_lock is a bad one on x86.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
