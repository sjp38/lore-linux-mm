Date: Thu, 4 Jul 2002 23:08:00 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vm lock contention reduction
In-Reply-To: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com>
Message-ID: <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 4 Jul 2002, Linus Torvalds wrote:
>
> Right now, we get roughly this behaviour simply by way of statistical
> behaviour for the page allocator ("if somebody allocates 5 times as many
> pages, he's 5 times as likely to have to clean something up too"), but
> trying to be smarter about this could easily break this relative fairness.

Side note: getting some higher-level locking wrong can _seriously_ break
this statistical behaviour.

In particular, the ext2 superblock lock at least used to be horribly
broken and held in a lot of "bad" places: I doubt Al has gotten far enough
to fix that brokenness. The superblock lock used to cause one process that
blocked for something (usually reading in some bitmap or other) to cause a
lot of _other_ processes to block quite unnecessarily on the badly placed
lock, even though they really would have had all the resources they
needed.

That particular thing is really not a VM problem, but a ext2 issue. The
superblock lock just isn't very well placed. I personally suspect that it
should be replaced by a spinlock - just to force all blocking operations
to be moved outside the lock (so that it would only protect the actual
data structures - rather than be held around reading bitmap blocks into
memory etc).

But that's a rather painful kind of locking change to do and to test.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
