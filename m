From: Neil Brown <neilb@suse.de>
Date: Fri, 29 Feb 2008 12:29:18 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18375.24558.876276.255804@notabene.brown>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: message from Peter Zijlstra on Wednesday February 27
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
	<18371.43950.150842.429997@notabene.brown>
	<1204023042.6242.271.camel@lappy>
	<18372.64081.995262.986841@notabene.brown>
	<1204099113.6242.353.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

So I've been pondering all this some more trying to find the pattern,
and things are beginning to crystalise (I hope).

One of the approaches I have been taking is to compare it to mempools
(which I think I understand) and work out what the important
differences are.

One difference is that you don't wait for memory to become available
(as I mentioned earlier).  Rather you just try to get the memory and
if it isn't available, you drop the packet.  This probably makes sense
for incoming packets as you rely on the packet being re-sent, and
hopefully various back-off algorithms will slow things down a bit so
that there is a good change that memory will be available next time...

For out going messages I'm less clear on exactly what is going on.
Maybe I haven't looked at that code properly yet, but I would expect
there would be a place for waiting for memory to become available
somewhere in the out-going path ??

But there is another important difference to mempools which I think is
worth exploring.  With mempools, you are certain that the memory will
only be used to make forward progress in writing out dirty data.  So
if you find that there isn't enough memory at the moment and you have
to wait, you can be sure someone else is making forward progress and
so waiting isn't such a bad thing.

With your reservations it isn't quite the same.  Reserved memory can
be used for related purposes.  In particular, any incoming packet can
use some reserved memory.  Once the purpose of that packet is
discovered (i.e. that matching socket is found), the memory will be
freed again.  But there is a period of time when memory is being used
for an inappropriate purpose.  The consequences of this should be
clearly understood.

In particular, the memory that is reserved for the emergency pool
should include some overhead to acknowledge the fact that memory
might be used for short periods of time for unrelated purposes.

I think we can fit this acknowledgement into the current model quite
easily, and it makes the tree structure suddenly make lots of sense
(where as before I was still struggling with it).

A key observation in this design is "Sometimes we need to allocate
emergency memory without knowing exactly what it is going to be used
for".  I think we should make that explicit in the implementation as
follows:

  We have a tree of reservations (as you already do) where levels in
  the tree correspond to more explicit knowledge of how the memory
  will be used.
  At the top level there is a generic 'page' reservation.  Below that
  to one side with have a 'SLUB/SLAB' reservation.  I'm not sure yet
  exactly what that will look like.
  Also below the 'page' reservation is a reservation for pages to hold
  incoming network fragments.
  Below the SLxB reservation is a reservation for skbs, which is
  parent to a reservation for IPv4 skbs and another for IPv6 skbs.

Each of these nodes has its own independent reservation - parents are
not simply the sum of the children.
The sum over the whole tree is given to the VM as the size of the
emergency pool to reserve for emergency allocations.

Now, every actual allocation from the emergency pool effectively comes
in at the top of the tree and moves down as its purpose is more fully
understood.  Every emergency allocation is *always* charged to one
node in the tree, though which node may change.

e.g.
  A network driver asks for a page to store a fragment.
  netdev_alloc_page calls alloc_page with __GFP_MEMALLOC set.
  If alloc_page needs to dive into the emergency pool, it first
  charges the one page against the root for the reservation tree.
  If this succeeds, it returns the page with ->reserve set.  If the
  reservation fails, it ignores the GFP_MEMALLOC and fails.
  netdev_alloc_page notices that the page is a ->reserve page, and
  knows that it has been changed to the top 'page' reservation, but it
  should be changed to the network-page reservation.  So it tried to
  charge against the network-pages reservation, and reverses the
  charge against 'pages'.  If the network-pages reservation fails, the
  page is freed and netdev_alloc_page fails.
  As you can see, the charge moves down the tree as more information
  becomes available.

  Similarly a charge might move from 'pages' to 'SLxB' to 'net_skb' to
  'ipv4_skb'.

  At the bottom levels, the reservations says how much memory is
  needed for that particular usage to be able to make sensible forward
  progress.
  At the higher levels, the reservation says how much overhead we need
  to allow to ensure that transient invalid uses don't unduly limit
  available emergency memory.  As pages are likely to be immediately
  re-charged lower down the tree, the reservation at the top level
  would probably be proportional to the number of CPUs (probably one
  page per CPU would be perfect).  Lower down, different calculations
  might suggest different intermediate reservations.

Of course, these things don't need to be explicitly structured as a
tree.  There is no need for 'parent' or 'sibling' pointers.  The code
implicitly knows where to move charges from and to.
You still need an explicit structure to allow groups of reservations
that are activated or de-activated as a whole.  That can use your
current tree structure, or whatever else turns out to make sense.

This model, I think, captures the important "allocate before charging"
aspect of reservations that you need (particularly for incoming
network packets) and it makes that rule apply throughout the different
stages that an allocated chunk of memory goes through.

With this model, alloc_page could fail more often, as it now also
fails if the top level reservation is exhausted.  This may seem
un-necessary, but I think it could be a good thing.  It means that at
very busy times (when lots of requests are needing emergency memory)
we drop requests randomly and very early.  If we are going to drop a
request eventually, dropping it early means we waste less time on it
which is probably a good thing.


So: Does this model help others with understanding how the
reservations work, or am I just over-engineering?

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
