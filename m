From: Daniel Phillips <phillips@istop.com>
Subject: Re: Network vm deadlock... solution?
Date: Wed, 3 Aug 2005 06:13:37 +1000
References: <200508020654.32693.phillips@istop.com> <1123003658.3754.28.camel@w-sridhar2.beaverton.ibm.com>
In-Reply-To: <1123003658.3754.28.camel@w-sridhar2.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508030613.37359.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(cross-posted to linux-mm now)

On Wednesday 03 August 2005 03:27, Sridhar Samudrala wrote:
> On Tue, 2005-08-02 at 06:54 +1000, Daniel Phillips wrote:
> > Hi guys,
> >
> > Well I have been reading net code seriously for two days, so I am still
> > basically a complete network klutz.  But we have a nasty network-realted
> > vm deadlock that needs fixing and there seems to be little choice but to
> > wade in and try to sort things out.
>
> We are also working on a similar problem where a set of critical TCP
> connections need to successfully send/receive messages even under very
> low memory conditions. But the assumption is that the low memory
> situation lasts only for a short time(in the order of few minutes)
> which should not cause any TCP timeouts to expire so that normal
> connections can recover once the low memory situation is resolved.

A few minutes!!!  In cluster applications at least, that TCP timeout can be a 
DOS of the whole cluster, and will certainly cause the node to miss multiple 
heartbeats, thus being ejected from the cluster and possibly rebooted.  So it 
would be better if we can always be sure of handling the block IO traffic, 
barring physical network disconnection or similar.

A point on memory pressure: here, we are not talking about the continuous 
state of running under heavy load, but rather the microscopically short 
periods where not a single page of memory is available to normal tasks.  It 
is when a block IO event happens to land inside one of those microscopically 
short periods that we run into problems.

> > Here is the plan:
> >
> >   * All protocols used on an interface that supports block IO must be
> >     vm-aware.
> >
> > If we wish, we can leave it up to the administrator to ensure that only
> > vm-aware protocols are used on an interface that supports block IO, or we
> > can do some automatic checking.
> >
> >   * Any socket to be used for block IO will be marked as a "vmhelper".
>
> I am assuming your 'vmhelper' is similar to a critical socket which can
> be marked using a new socket option(ex: SO_CRITICAL).

Yes.  I originally intended to use the term "vmhelper" to mean any task lying 
in the block IO path, so I would like the terminology to match if possible.  
In general, the above flag denotes a socket that is throttled by its user and 
implies emergency allocation from a particular reserve.  I plan to use the 
classic PF_MEMALLOC reserve because I think this is correct, efficient, and 
more flexible than a mempool.  So really, this flag is SO_MEMALLOC, meaning 
that the socket is properly throttled and can therefore can draw from the 
MEMALLOC pool.

Looking over the thread from march:
   
http://thunker.thunk.org/pipermail/ksummit-2005-discuss/2005-March/000199.html

I see that Andrea is really close to the same idea.  He suggests attaching a 
pointer to a mempool to each socket, and to understand NULL as meaning 
"unthrottled".  This will work, but it is unnecessarily messy.  (The other 
simplification everybody seems to have missed is the easy way of bypassing 
the softnet queues, assuming this works.)

OK, I will go with SO_MEMALLOC for the time being.  SO_CRITICAL could mean so 
many other things.

> > The number of protocols that need to have this special knowledge is quite
> > small, e.g.: tcp, udp, sctp, icmp, arp, maybe a few others.  We are
> > talking about a line or two of code in each to add the necessary
> > awareness.
> >
> >   * Inside the network driver, when memory is low we will allocate space
> >     for every incoming packet from a memory reserve, regardless of
> > whether it is related to block IO or not.
> >
> >   * Under low memory, we call the protocol layer synchronously instead of
> >     queuing the packet through softnet.
> >
> > We do not necessarily have to bypass softnet, since there is a mechanism
> > for thottling packets at this point.  However, there is a big problem
> > with throttling here: we haven't classified the packet yet, so the
> > throttling might discard some block IO packets, which is exactly what we
> > don't want to do under memory pressure.
> >
> >   * The protocol receive handler does the socket lookup, then if memory
> > is low, discards any packet not belonging to a vmhelper socket.
> >
> > Roughly speaking, the driver allocates each skb via:
> >
> >         skb = memory_pressure ? dev_alloc_skb_reserve() :
> > dev_alloc_skb();
>
> Instead of changing all the drivers to make them vm aware, we could add
> a new priority flag(something like GFP_CRITICAL) which can be passed to
> __dev_alloc_skb(). dev_alloc_skb becomes
>     return __dev_alloc_skb(length, GFP_ATOMIC|GFP_CRITICAL);

Good point: there is no need for the alloc_skb_reserve variant.  To be 
consistent, this would be GFP_ATOMIC|GFP_MEMALLOC.  The point is, we allow 
atomic allocation to dig right to the bottom of available physical memory 
under these conditions.  If we hit bottom, it was a static analysis error and 
we deserve to die[1].

> Based on the memory pressure conditon, the VM can decide if the skb
> needs to allocated from an emergency reserve.

Yes, it is a better factoring.

> > Then the driver hands off the packet to netif_rx, which does:
> >
> >         if (from_reserve(skb)) {
> > 		netif_receive_skb(skb);
> >                 return;
> > 	}
> >
> > And in the protocol handler we have:
> >
> >         if (memory_pressure && !is_vmhelper(sock) && from_reserve(skb))
> >                 goto drop_the_packet;
>
> I am not sure if we need the from_reserve() checks above.
> We have to assume that all incoming packets are critical until we can
> find the matching sk in the protocol handler code.

We already found the sk, I spelled it "sock" above, sorry ;-)

But there is a redundant test there: we already checked for memory_pressure 
probably less than a microsecond earlier in the same linear execution path, 
so all we need is:

        if (!is_vmhelper(sock) && from_reserve(skb))
                goto drop_the_packet;

We can be pretty sure that if there was memory pressure back there, there is 
still at least as much at this point.

I will change "is_vmhelper" to "is_memalloc" for consistency.  I expect there 
will be a fine debate over which is better, mempools or generic memalloc, but 
the patch is certainly shorter with memalloc, so I will stay with that unless 
somebody comes up with a substantive problem.

[1] It is a slight exaggeration to say that all these paths are statically 
analyzable because we can dynamically configure some of the code paths in 
question, e.g., device-mapper devices.  To accommodate this using the 
PF_MEMALLOC reserve, we will need to invent a mechanism of resizing the 
reserve as the kernel configuration changes.  But first things first, let's 
just leave that manual for the time being.  (Yes, I know that mempool "just 
does this", but the memalloc reserve can just do it too, with less code.)

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
