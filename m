From: frankeh@us.ibm.com
Message-ID: <852568D3.00670E44.00@D51MTA07.pok.ibm.com>
Date: Tue, 2 May 2000 14:46:14 -0400
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Rik...


Rik van Riel <riel@conectiva.com.br> on 05/02/2000 02:15:18 PM

   Please respond to riel@nl.linux.org

   To:  Hubertus Franke/Watson/IBM@IBMUS
   cc:  Andrea Arcangeli <andrea@suse.de>, Roger Larsson
        <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu,
        linux-mm@kvack.org
   Subject:     Re: kswapd @ 60-80% CPU during heavy HD i/o.



   On Tue, 2 May 2000 frankeh@us.ibm.com wrote:

   > It makes sense to me to make the number of pools configurable
   > and not tie them directly to the number of nodes in a NUMA
   > system. In particular allow memory pools (i.e. instance of
   > pg_dat_t) to be smaller than a node size.

   *nod*



   We should have different memory zones per node on
   Intel-handi^Wequipped NUMA machines.

Wouldn't that be orthogonal....
Anyway, I believe x86 NUMA machines will exist in the future, so I am not
ready to trash them right now, whether I like their architecture or not.



   > The smart things that I see has to happen is to allow a set of
   processes to
   > be attached to a set of memory pools and the OS basically enforcing
   > allocation in those constraints. I brought this up before and I think
   > Andrea proposed something similar. Allocation should take place in
   those
   > pools along the allocation levels based on GFP_MASK, so first allocate
   on
   > HIGH along all specified pools and if unsuccessful, then fallback on a
   > previous level.

   That idea is broken if you don't do balancing of VM load between
   zones.



   > With each pool we should associate a kswapd.

   How will local page replacement help you if the node next door
   has practically unloaded virtual memory? You need to do global
   page replacement of some sort...

You wouldn't balance a zone until you have checked on the same level (e.g.
HIGHMEM) on all the specified nodes. Then and only then you fall back. So
we aren't doing any local page replacement unless I can not satisfy a page
request within the given resource set.
That means something along the following pseudo code

   forall zonelevels
        forall nodes in resource set
             zone = pgdat[node].zones[zonelevel];
             if (zone->free_pages > threshold)
                  alloc_page;
                  return;
             set kswapd_required flag   (kick)

   balance zones;   // couldn't allocate a page in the desired resource set
so start balancing.


Now balancing zones kicks the kswaps or helps out... global balancing can
take place by servicing the pgdat_t with the highest number of kicks...
I think it is ok to have pools with unused memory lying around if a
particular resource set does not include those pools. How else are you
planning to control locality and affinity within memory other than using
resource sets.
We take the same approach in the kernel, for instance we have a minimum
file cache size, because we know that we can increase throughput by doing
so.


   > Making the size of the pools configurable allows to control the
   > velocity at which we can swap out. Standard Queuing theory: if
   > we can't get the desired througput, then increase the number of
   > servers, here kswapd.

   What we _could_ do is have one (or maybe even a few) kswapds
   doing global replacement with io-less and more fine-grained
   swap_out() and shrink_mmap() functions, and per-node kswapds
   taking care of the IO and maybe even a per-node inactive list
   (though that would probably be *bad* for page replacement).

That is workable .......


   Then again, if your machine can't get the desired throughput,
   how would adding kswapds help??? Have you taken a look at
   mm/page_alloc.c::alloc_pages()? If kswapd can't keep up, the
   biggest memory consumers will help a hand and prevent the
   rest of the system from thrashing too much.

Correct...

However, having finer grain pools also allows you to deal with potential
lock contention, which is one of the biggest impedements to scale up.
characteristics of NUMA machines are large memory and large number of CPUs.
This implies that there will be increased lock contention, for instance on
the lock that protects the
memory pool. Also increased lock contention can arise by increased lock
hold time, which I assume is somewhat related to the size of the memory. So
decreasing lock contention time by limiting the number of pages that are
managed per pool could remove an arising bottleneck.


   regards,

   Rik
   --
   The Internet is not a network of computers. It is a network
   of people. That is its real strength.

   Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
   http://www.conectiva.com/        http://www.surriel.com/


regards...

Hubertus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
