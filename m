Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA04593
	for <linux-mm@kvack.org>; Tue, 19 May 1998 18:55:02 -0400
Date: Tue, 19 May 1998 23:46:01 +0100
Message-Id: <199805192246.XAA03125@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Q: Swap Locking Reinstatement
In-Reply-To: <m1somf2arx.fsf@flinx.npwt.net>
References: <m1somf2arx.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 12 May 1998 20:57:05 -0500, ebiederm+eric@npwt.net (Eric
W. Biederman) said:

> Recently the swap lockmap has been readded.

> Was that just as a low cost sanity check, to use especially while
> there were bugs in some of the low level disk drivers?

> Was there something that really needs the swap lockmap?

Yes, there was a bug.  The problem occurs when:

	page X is owned by process A
	process B tries to swap out page X from A's address space
	process A exits or execs
	process B's swap IO completes.

The IO completion is an interrupt (we perform async swaps where
possible).  Now, if we dereference the swap entry belonging to page X
at IO completion time, then the entry is protected against reuse while
the IO is in flight.  However, that requires making the entire swap map
interrupt safe.  It is much more efficient to keep the lock map separate
and to use atomic bitops on it to allow us to do the IO completion
unlock in an interrupt-safe manner.

A similar race occurs when

	process B tries to swap out page X from A's address space
	process A tries to swap it back in
	process B's swap IO completes.

Now process A may, or may not, get the right data from disk depending on
the (undefined) ordering of the IOs submitted by A and B.

> The reason I am asking is that this causes conflicts with my shmfs
> kernel patches.  I directly read/write swap pages through a variation
> of rw_swap_page, and during I/O they must stay in the page cache, but
> _not_ on the swapper inode, and the way the swap lockmap is currently
> implemented causes a problem.

Sorry, but right now it is definitely needed.

--Stephen
