Date: Wed, 26 Apr 2000 12:24:48 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.3.x mem balancing
Message-ID: <20000426122448.G3792@redhat.com>
References: <Pine.LNX.4.21.0004251903560.13102-100000@alpha.random> <Pine.LNX.4.21.0004252240280.14340-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004252240280.14340-100000@duckman.conectiva>; from riel@conectiva.com.br on Tue, Apr 25, 2000 at 11:10:56PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 11:10:56PM -0300, Rik van Riel wrote:
 
> > As second using 5% and 1% of critical watermarks won't give you a 6%
> > watermark for the ZONE_NORMAL _class_zone but it will give you a 1%
> > watermark instead and you probably wanted a 6% watermark to provide
> > rasonable space for atomic allocations and for having more chances of
> > doing high order allocations.
> 
> So the 1% watermark for ZONE_NORMAL is too low ... fix that.

We just shouldn't need to keep much memory free.

I'd much rather see a scheme in which we have two separate goals for 
the VM.  Goal one would be to keep a certain number of free pages in 
each class, for use by atomic allocations.  Goal two would be to have
a minimum number of pages in each class either free or on a global LRU
list which contains only pages known to be clean and unmapped (and
hence available for instant freeing without IO).

That gives us many advantages:

 * We can split kswapd into two tasks: a kswapd task for swapping, and a
   kreclaimd for freeing pages on the clean LRU.  Even while we are 
   swapping, kreclaimd can kick in to keep atomic allocations happy.

 * We can still keep the free page lists topped up on a per-zone (or
   per-class) basis, but have a global LRU of clean pages by which to
   balance the reclamation of memory between zones if we want it

 * There will be a bigger pool of pages available for reuse at short
   notice, without us having to actually throw away potentially 
   useful data until the time that the memory is actually needed.

Cleaning dirty pages for reuse, and actually freeing those pages, are
already two distinct concepts in our VM.  We ought to make that 
explicit in the free pages LRUs.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
