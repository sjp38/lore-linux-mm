Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
References: <20000924231240.D5571@athlon.random>
	<Pine.LNX.4.21.0009242310510.8705-100000@elte.hu>
	<20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random>
	<20000925003650.A20748@home.ds9a.nl>
	<20000925014137.B6249@athlon.random> <20000925172442.J2615@redhat.com>
	<20000925190347.E27677@athlon.random>
	<20000925190657.N2615@redhat.com>
	<20000925213242.A30832@athlon.random>
	<20000925205457.Y2615@redhat.com>
From: Christoph Rohland <cr@sap.com>
Date: 26 Sep 2000 08:54:23 +0200
Message-ID: <qwwd7hriqxs.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Mon, Sep 25, 2000 at 09:32:42PM +0200, Andrea Arcangeli wrote:
> 
> > Having shrink_mmap that browse the mapped page cache is useless
> > as having shrink_mmap browsing kernel memory and anonymous pages
> > as it does in 2.2.x as far I can tell. It's an algorithm
> > complexity problem and it will waste lots of CPU.
> 
> It's a compromise between CPU cost and Getting It Right.  Ignoring the
> mmap is not a good solution either.
> 
> > Now think this simple real life example. A 2G RAM machine running
> > an executable image of 1.5G, 300M in shm and 200M in cache.

Hey that's ridiculous: 1.5G executable image and 300M shm? Take it
vice-versa and you are approaching real life.

> OK, and here's another simple real life example.  A 2GB RAM machine
> running something like Oracle with a hundred client processes all
> shm-mapping the same shared memory segment.

That sound much more realistic.

> Oh, and you're also doing lots of file IO.  How on earth do you decide
> what to swap and what to page out in this sort of scenario, where
> basically the whole of memory is data cache, some of which is mapped
> and some of which is not?
> 
> If you don't separate out the propagation of referenced bits from the
> actual page aging, then every time you pass over the whole VM working
> set, you're likely to find a handful of live references to some of the
> shared memory, and a hundred or so references that haven't done
> anything since last time.  Anything that only ages per-pte, not
> per-page, is simply going to die horribly under such load, and any
> imbalance between pure filesystem cache and VM pressure will be
> magnified to the point where one dominates.

Yes and that's why I stress most of the patch levels with my ipctst
program on a highmem machine. It's simulating a load like this: A lot
of processes attached to shm segments and trashing them. There were
very few kernels which really worked with that load without totally
breaking or killing processes _way_ too early.

> Hence my observation that it's really easy to find special cases where
> certain optimisations make a ton of sense, but you often lose balance
> in the process.  

O.K. My test case is such a special case, but it is related to real
live transactional load on a highend server.

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
