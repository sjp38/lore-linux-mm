Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18380.36003.162081.900296@notabene.brown>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <18375.24558.876276.255804@notabene.brown> <1204280500.6243.70.camel@lappy>
	 <18379.10183.427082.282748@notabene.brown>
	 <1204500793.6240.123.camel@lappy>
	 <18380.36003.162081.900296@notabene.brown>
Content-Type: text/plain; charset=utf-8
Date: Tue, 04 Mar 2008 11:28:29 +0100
Message-Id: <1204626509.6241.39.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-04 at 10:41 +1100, Neil Brown wrote:
> Hi Peter,
> 
>  Thanks for trying to spell it out for me. :-)
> 
> On Monday March 3, a.p.zijlstra@chello.nl wrote:
> > 
> > >From my POV there is a model, and I've tried to convey it, but clearly
> > I'm failing $,3r_(Bhorribly. Let me try again:

Hmm, I wonder what went wrong there ^

> > Create a stable state where you can receive an unlimited amount of
> > network packets awaiting the one packet you need to move forward.
> 
> Yep.
> 
> > 
> > To do so we need to distinguish needed from unneeded packets; we do this
> > by means of SK_MEMALLOC. So we need to be able to receive packets up to
> > that point.
> 
> Yep.
> 
> > 
> > The unlimited amount of packets means unlimited time; which means that
> > our state must not consume memory, merely use memory. That is, the
> > amount of memory used must not grow unbounded over time.
> 
> Yes.  Good point.
> 
> > 
> > So we must guarantee that all memory allocated will be promptly freed
> > again, and never allocate more than available.
> 
> Definitely.
> 
> > 
> > Because this state is not the normal state, we need a trigger to enter
> > this state (and consequently a trigger to leave this state). We do that
> > by detecting a low memory situation just like you propose. We enter this
> > state once normal memory allocations fail and leave this state once they
> > start succeeding again.
> 
> Agreed.
> 
> > 
> > We need the accounting to ensure we never allocate more than is
> > available, but more importantly because we need to ensure progress for
> > those packets we already have allocated.
> 
> Maybe...
>  1/ Memory is used 
>      a/ in caches, such as the fragment cache and the route cache
>      b/ in transient allocations on their way from one place to
>         another. e.g. network card to fragment cache, frag cache to
>         socket. 
>     The caches can (do?) impose a natural limit on the amount of
>     memory they use.  The transient allocations should be satisfied
>     from the normal low watermark pool.  When we are in a low memory
>     conditions we can expect packet loss so we expect network streams
>     to slow down, so we expect there to be fewer bits in transit.
>     Also in low memory conditions the caches would be extra-cautious
>     not to use too much memory.
>     So it isn't completely clear (to me) that extra accounting is needed.
> 
>  2/ If we were to do accounting to "ensure progress for those packets
>     we already have allocated", then I would expect a reservation
>     (charge) of max_packet_size when a fragment arrives on the network
>     card - or at least when a new fragment is determined to not match
>     any packet already in the fragment cache.  But I didn't see that
>     in your code.  I saw incremental charges as each page arrived.
>     And that implementation does seem to fit the model.

i>>?Ah, the extra accounting I do is count the number of bytes associated
with skb data. So that we don't exhaust the reserves with incoming
packets. Like you said, packets need a little more memory in their
travels up to the socket demux.

When you look at __alloc_skb(), you'll find we charge the data size to
the reserves, and if you look at __netdev_alloc_page(), you'll see
PAGE_SIZE being changed against the skb reserve.

If we would not do this, and the incoming packet rate would be high
enough, we could exhaust the reserves and leave the packets no memory to
use on their travels to the socket demux.
 
> > A packet is received, it can be a fragment, it will be placed in the
> > fragment cache for packet re-assembly.
> 
> Understood.
> 
> > 
> > We need to ensure we can overflow this fragment cache in order that
> > something will come out at the other end. If under a fragment attack,
> > the fragment cache limit will prune the oldest fragments, freeing up
> > memory to receive new ones.
> 
> I don't understand why we want to "overflow this fragment cache".
> I picture the cache having a target size.  When under this size,
> fragments might be allowed to live longer.  When at or over the target
> size, old fragments are pruned earlier.  When in a low memory
> situation it might be even more keen to prune old fragments, to keep
> beneath the target size.
> When you say "overflow this fragment cache", I picture deliberately
> allowing the cache to get bigger than the target size.  I don't
> understand why you would want to do that.

What I mean by overflowing is: by providing more than the cache can
handle we guarantee that forward progress is made, because either the
cache will prune items - giving us memory to continue - or we'll get out
a fully assembled packet which can continue its quest :-)

If we provide less memory than the cache can hold, all memory can be
tied up in the cache, waiting for something to happen - which won't,
because we're out of memory.

> > Eventually we'd be able to receive either a whole packet, or enough
> > fragments to assemble one.
> 
> That would be important, yes.
> 
> > 
> > Next comes routing the packet; we need to know where to process the
> > packet; local or non-local. This potentially involves filling the
> > route-cache.
> > 
> > If at this point there is no memory available because we forgot to limit
> > the amount of memory available for skb allocation we again are stuck.
> 
> Those skbs we allocated - they are either sitting in the fragment
> cache, or have been attached to a SK_MEMALLOC socket, or have been
> freed - correct?  If so, then there is already a limit to how much
> memory they can consume.

Not really, there is no natural limit to the amount of packets that can
be in transit between RX and socket demux. So we need the extra (skb)
accounting to impose that.

> > The route-cache, like the fragment assembly, is already accounted and
> > will prune old (unused) entries once the total memory usage exceeds a
> > pre-determined amount of memory.
> 
> Good.  So as long as the normal emergency reserves covers the size of
> the route cache plus the size of the fragment cache plus a little bit
> of slack, we should be safe - yes?

Basically (except for the last point), unless I've missed something in
the net-stack. 

> > Eventually we'll end up at socket demux, matching packets to sockets
> > which allows us to either toss the packet or consume it. Dropping
> > packets is allowed because network is assumed lossy, and we have not yet
> > acknowledged the receive.
> > 
> > Does this make sense?
> 
> Lots of it does, yes.

Good, making progress here :-)

> > Then we have TX, which like I said above needs to operate under certain
> > limits as well. We need to be able to send out packets when under
> > pressure in order to relieve said pressure.
> 
> Catch-22 ?? :-)

Yeah, swapping is such fun.. Which is why we have these reserves. We
only fake we're out of memory, but secretly we do have some left. But,
sssh don't tell user-space :-)

> > We need to ensure doing so will not exhaust our reserves.
> > 
> > Writing out a page typically takes a little memory, you fudge some
> > packets with protocol info, mtu size etc.. send them out, and wait for
> > an acknowledge from the other end, and drop the stuff and go on writing
> > other pages.
> 
> Yes, rate-limiting those write-outs should keep that moving.
> 
> > 
> > So sending out pages does not consume memory if we're able to receive
> > ACKs. Being able to receive packets what what all the previous was
> > about.
> > 
> > Now of course there is some RPC concurrency, TCP windows and other
> > funnies going on, but I assumed - and I don't think that's a wrong
> > assumption - that sending out pages will consume endless amounts of
>                                           ^not ??

Uhm yeah, sorry about that.

> > memory.
> 
> Sounds fair.
> 
> > 
> > Nor will it keep on sending pages, once there is a certain amount of
> > packets outstanding (nfs congestion logic), it will wait, at which point
> > it should have no memory in use at all.
> 
> Providing it frees any headers it attached to each page (or had
> allocated them from a private pool), it should have no memory in use.
> I'd have to check through the RPC code (I get lost in there too) to
> see how much memory is tied up by each outstanding page write.
> 
> > 
> > Anyway I did get lost in the RPC code, and I know I didn't fully account
> > everything, but under some (hopefully realistic) assumptions I think the
> > model is sound.
> > 
> > Does this make sense?
> 
> Yes.
> 
> So I can see two possible models here.
> 
> The first is the "bounded cache" or "locally bounded" model.
> At every step in the path from writepage to clear_page_writeback,
> the amount of extra memory used is bounded by some local rules.
> NFS and RPC uses congestion logic to limit the number of outstanding
> writes.  For incoming packets, the fragment cache and route cache
> impose their own limits.
> We simply need that the VM reserves a total amount of memory to meet
> the sum of those local limits.
> 
> Your code embodies this model with the tree of reservations.  The root
> of the tree stores the sum of all the reservations below, and this
> number is given to the VM.
> The value of the tree is that different components can register their
> needs independently, and the whole tree (or subtrees) can be attached
> or not depending on global conditions, such as whether there are any
> SK_MEMALLOC sockets or not.
> 
> However I don't see how the charging that you implemented fits into
> this model.
> You don't do any significant charging for the route cache.  But you do
> for skbs.  Why?  Don't the majority of those skbs live in the fragment
> cache?  Doesn't it account their size? (Maybe it doesn't.... maybe it
> should?).

To impose a limit on the amount of skb data in transit. Like stated
above, there is (afaik) no natural limit on this.

> I also don't see the value of tracking pages to see if they are
> 'reserve' pages or not.  The decision to drop an skb that is not for
> an SK_MEMALLOC socket should be based on whether we are currently
> short on memory.  Not whether we were short on memory when the skb was
> allocated.

That comes from accounting, once you need to account data you need to
know when to start accounting, and keep state so that you can properly
un-account.

Also, from a practical POV its easier to detect our lack of memory from
an allocation site, that outside of it.

> The second model that could fit is "total accounting". 
> In this model we reserve memory at each stage including the transient
> stages (packet that has arrived but isn't in fragment cache yet).
> As memory moves around, we move the charging from one reserve to
> another.  If the target reserve doesn't have an space, we drop the
> message.
> On the transmit side, that means putting the page back on a queue for
> sending later.  On the receive side that means discarding the packet
> and waiting for a resend.
> This model makes it easy for the various limits to be very different
> while under memory pressure that otherwise.  It also means they are
> imposed differently which isn't so good.
> 
> So:
>  - Why do you impose skb allocation limits beyond what is imposed
>    by the fragment cache?

To impose a limit on the amount of skbs in transit. The fragment cache
only imposes a limit on the amount of data held for packet assembly. Not
the total amount of skb data between receive and socket demux.

>  - Why do you need to track whether each allocation is a reserve or
>    not?

To do accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
