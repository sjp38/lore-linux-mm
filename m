Date: Tue, 2 May 2000 14:45:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <852568D3.005FC088.00@D51MTA07.pok.ibm.com>
Message-ID: <Pine.LNX.4.21.0005021438550.10610-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: Andrea Arcangeli <andrea@suse.de>, Roger Larsson <roger.larsson@norran.net>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000 frankeh@us.ibm.com wrote:

> It makes sense to me to make the number of pools configurable
> and not tie them directly to the number of nodes in a NUMA
> system. In particular allow memory pools (i.e. instance of
> pg_dat_t) to be smaller than a node size.

*nod*

We should have different memory zones per node on
Intel-handi^Wequipped NUMA machines.

> The smart things that I see has to happen is to allow a set of processes to
> be attached to a set of memory pools and the OS basically enforcing
> allocation in those constraints. I brought this up before and I think
> Andrea proposed something similar. Allocation should take place in those
> pools along the allocation levels based on GFP_MASK, so first allocate on
> HIGH along all specified pools and if unsuccessful, then fallback on a
> previous level.

That idea is broken if you don't do balancing of VM load between
zones.

> With each pool we should associate a kswapd.

How will local page replacement help you if the node next door
has practically unloaded virtual memory? You need to do global
page replacement of some sort...

> Making the size of the pools configurable allows to control the
> velocity at which we can swap out. Standard Queuing theory: if
> we can't get the desired througput, then increase the number of
> servers, here kswapd.

What we _could_ do is have one (or maybe even a few) kswapds
doing global replacement with io-less and more fine-grained
swap_out() and shrink_mmap() functions, and per-node kswapds
taking care of the IO and maybe even a per-node inactive list
(though that would probably be *bad* for page replacement).

Then again, if your machine can't get the desired throughput,
how would adding kswapds help??? Have you taken a look at
mm/page_alloc.c::alloc_pages()? If kswapd can't keep up, the
biggest memory consumers will help a hand and prevent the
rest of the system from thrashing too much.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
