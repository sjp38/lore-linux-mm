Date: Thu, 20 Mar 2008 14:20:32 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 01/30] swap over network documentation
Message-Id: <20080320142032.9279e288.randy.dunlap@oracle.com>
In-Reply-To: <20080320202120.024907000@chello.nl>
References: <20080320201042.675090000@chello.nl>
	<20080320202120.024907000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, neilb@suse.de, miklos@szeredi.hu, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008 21:10:43 +0100 Peter Zijlstra wrote:

> Document describing the problem and proposed solution
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  Documentation/network-swap.txt |  270 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 270 insertions(+)
> 
> Index: linux-2.6/Documentation/network-swap.txt
> ===================================================================
> --- /dev/null
> +++ linux-2.6/Documentation/network-swap.txt
> @@ -0,0 +1,270 @@

...

> +There are several major parts to this enhancement:
> +
> +1/ page->reserve, GFP_MEMALLOC

...

> +  For memory allocated using slab/slub: If a page that is added to a
> +  kmem_cache is found to have page->reserve set, then a  s->reserve

                                                    then an

> +  flag is set for the whole kmem_cache.  Further allocations will only
> +  be returned from that page (or any other page in the cache) if they
> +  are emergency allocation (i.e. PF_MEMALLOC or GFP_MEMALLOC is set).

                   allocations

> +  Non-emergency allocations will block in alloc_page until a
> +  non-reserve page is available.  Once a non-reserve page has been
> +  added to the cache, the s->reserve flag on the cache is removed.
> +
> +  Because slab objects have no individual state its hard to pass

                                                   it's (or "it is")

> +  reserve state along, the current code relies on a regular alloc

                          so the

> +  failing. There are various allocation wrappers help here.

                                           wrappers to help here.  (?)

> +
> +  This allows us to
> +   a/ request use of the emergency pool when allocating memory
> +     (GFP_MEMALLOC), and
> +   b/ to find out if the emergency pool was used.
> +
> +2/ SK_MEMALLOC, sk_buff->emergency.
> +
...
> +
> +  Similarly, if an skb is ever queued for delivery to user-space for

                                                         user-space, for

> +  example by netfilter, the ->emergency flag is tested and the skb is
> +  released if ->emergency is set. (so obviously the storage route may
> +  not pass through a userspace helper, otherwise the packets will never
> +  arrive and we'll deadlock)
> +
> +  This ensures that memory from the emergency reserve can be used to
> +  allow swapout to proceed, but will not get caught up in any other
> +  network queue.
> +
> +
> +3/ pages_emergency
> +
...
> +
> +  So a new "watermark" is defined: pages_emergency.  This is
> +  effectively added to the current low water marks, so that pages from
> +  this emergency pool can only be allocated if one of PF_MEMALLOC or
> +  GFP_MEMALLOC are set.

                  is set.

> +
> +  pages_emergency can be changed dynamically based on need.  When
> +  swapout over the network is required, pages_emergency is increased
> +  to cover the maximum expected load.  When network swapout is
> +  disabled, pages_emergency is decreased.
> +
> +  To determine how much to increase it by, we introduce reservation
> +  groups....
> +
> +3a/ reservation groups
> +
> +  The memory used transiently for swapout can be in a number of
> +  different places.  e.g. the network route cache, the network

               places, e.g.,

> +  fragment cache, in transit between network card and socket, or (in
> +  the case of NFS) in sunrpc data structures awaiting a reply.
> +  We need to ensure each of these is limited in the amount of memory
> +  they use, and that the maximum is included in the reserve.
> +

...

> +
> +4/ low-mem accounting
> +
> +  Most places that might hold on to emergency memory (e.g. route
> +  cache, fragment cache etc) already place a limit on the amount of

            fragment cache, etc.)

> +  memory that they can use.  This limit can simply be reserved using
> +  the above mechanism and no more needs to be done.
> +
> +  However some memory usage might not be accounted with sufficient

     However,

> +  firmness to allow an appropriate emergency reservation.  The
> +  in-flight skbs for incoming packets is on such example.

                                            one

> +
> +  To support this, a low-overhead mechanism for accounting memory
> +  usage against the reserves is provided.  This mechanism uses the
> +  same data structure that is used to store the emergency memory
> +  reservations through the addition of a 'usage' field.
> +
> +  Before we attempt allocation from the memory reserves, we much check

s/much/must/ ?

> +  if the resulting 'usage' is below the reservation. If so, we increase
> +  the usage and attempt the allocation (which should succeed). If
> +  the projected 'usage' exceeds the reservation we'll either fail the
> +  allocation, or wait for 'usage' to decrease enough so that it would
> +  succeed, depending on __GFP_WAIT.
> +
> +  When memory that was allocated for that purpose is freed, the
> +  'usage' field is checked again.  If it is non-zero, then the size of
> +  the freed memory is subtracted from the usage, making sure the usage
> +  never becomes less than zero.
> +
> +  This provides adequate accounting with minimal overheads when not in
> +  a low memory condition.  When a low memory condition is encountered
> +  it does add the cost of a spin lock necessary to serialise updates
> +  to 'usage'.
> +
> +
> +
> +5/ swapon/swapoff/swap_out/swap_in
> +
> +  So that a filesystem (e.g. NFS) can know when to set SK_MEMALLOC on
> +  any network socket that it uses, and can know when to account
> +  reserve memory carefully, new address_space_operations are
> +  available.
> +  "swapon" requests that an address space (i.e a file) be make ready

                                             (i.e.
s/make/made/

> +  for swapout.  swap_out and swap_in request the actual IO.  They
> +  together must ensure that each swap_out request can succeed without
> +  allocating more emergency memory that was reserved by swapon. swapoff
> +  is used to reverse the state changes caused by swapon when we disable
> +  the swap file.
> +
> +
> +Thanks for reading this far.  I hope it made sense :-)
> +
> +Neil Brown (with updates from Peter Zijlstra)


Thanks.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
