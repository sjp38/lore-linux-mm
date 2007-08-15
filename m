Date: Wed, 15 Aug 2007 13:29:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1187183526.6114.45.camel@twins>
Message-ID: <Pine.LNX.4.64.0708151324121.7326@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <20070815122253.GA15268@wotan.suse.de>
 <1187183526.6114.45.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2007, Peter Zijlstra wrote:

> Christoph's suggestion to set min_free_kbytes to 20% is ridiculous - nor
> does it solve all deadlocks :-(

Only if min_free_kbytes is really the mininum number of free pages and not 
the mininum number of clean pages as I suggested.

All deadlocks? There are numerous ones that can come about for different 
reasons. Which ones are we talking about?

> RX
>  - we basically need infinite memory to receive the network reply
>    to complete writeout. Consider the following scenario:

There is no infinite memory. At some point you need to bound the amount 
of memory that the network allocates.

>  - so we need a threshold of some sorts to start tossing non-critical
>    network packets away. (because the consumer of these packets may be
>    the one swapping and is therefore frozen)

Right.

> <> What Christoph is proposing is doing recursive reclaim and not
> initiating writeout. This will only work _IFF_ there are clean pages
> about. Which in the general case need not be true (memory might be
> packed with anonymous pages - consider an MPI cluster doing computation
> stuff). So this gets us a workload dependant solution - which IMHO is
> bad!

In the general case this is true even for an MPI job because the MPI job 
needs to have executable code and libraries in memory. At mininum these 
are reclaimable.
 
> Also his suggestion to crank up min_free_kbytes to 20% of machine memory
> is not workable (again imagine this MPI cluster loosing 20% of its
> collective memory, very much out of the question).

It is workable. If you crank the min_clean_pages (this is essentially 
what it is) up to 20% then you basically reserve 20% of your memory for 
executable pages and page cache pages. And in an emergency these can be 
reclaimed to resolve any OOM issues. Note that my patch only accesses 
these reserves when we would otherwise OOM. This is rare.

> Nor does that solve the TCP deadlock, you need some additional condition
> to break that.

But that is an issue that is better handled in the network stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
