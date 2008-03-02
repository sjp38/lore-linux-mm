Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18379.10183.427082.282748@notabene.brown>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <18375.24558.876276.255804@notabene.brown> <1204280500.6243.70.camel@lappy>
	 <18379.10183.427082.282748@notabene.brown>
Content-Type: text/plain; charset=utf-8
Date: Mon, 03 Mar 2008 00:33:13 +0100
Message-Id: <1204500793.6240.123.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-03 at 09:18 +1100, Neil Brown wrote:
> On Friday February 29, a.p.zijlstra@chello.nl wrote:
> > 
> > The tx path is a bit fuzzed. I assume it has an upper limit, take a stab
> > at that upper limit and leave it at that.
> > 
> > It should be full of holes, and there is some work on writeout
> > throttling to fill some of them - but I haven't seen any lockups in this
> > area for a long long while.
> 
> I think this is very interesting and useful.
> 
> You seem to be saying that the write-throttling is enough to avoid any
> starvation on the transmit path. i.e. the VM is limiting the amount
> of dirty memory so that when we desperately need memory on the
> writeout path we can always get it, without lots of careful
> accounting.
> 
> So why doesn't this work on for the receive side?  What - exactly - is
> the difference.

The TX path needs to be able to make progress in that it must be able to
send out at least one full request (page). The thing the TX path must
not do is tie up so much memory sending out pages that we can't receive
any incoming packets.

So, having a throttle on the amount of writes in progress, and
sufficient memory to back those, seem like a solid way here.

NFS has such a limit in its congestion logic. But I'm quite sure I'm
failing to allocate enough memory to back it, as I got confused by the
whole RPC code.

> I think the difference is that on the receive side we have to hand
> out memory before we know how it will be used (i.e. whether it is for
> a SK_MEMALLOC socket or not) and so emergency memory could get stuck
> in some non-emergency usage.
> 
> So suppose we forgot about all the allocation tracking (that doesn't
> seem to be needed on the send side so maybe isn't on the receive side)
> and just focus on not letting emergency memory get used for the wrong
> thing.
> 
> So: Have some global flag that says "we are into the emergency pool"
> which gets set the first time an allocation has to dip below the low
> water mark, and cleared when an allocation succeeds without needing to
> dip that low.

That is basically what the slub logic I added does. Except that global
flags in the vm make people very nervous, so its a little more complex.

> Then whenever we have memory that might have been allocated from below
> the watermark (i.e. an incoming packet) 

Which is what I do in the skb_alloc() path.

> and we find out that it isn't
> required for write-out (i.e. it gets attached to a socket for which
> SK_MEMALLOC is not set) we test the global flag and if it is set, we
> drop the packet and free the memory.

Which is somewhat more complex than you make it sound, but that is
exactly what I do.

> To clarify: 
>    no new accounting
>    no new reservations
>    just "drop non-writeout packets when we are low on memory"
> 
> Is there any chance that could work reliably?

You need to be able to overflow the ip fragement assembly cache, or we
could get stuck with all memory in fragments.

Same for other memory usage before we hit the socket de-multiplex, like
the route-cache.

I just refined those points here; you need to drop more that
non-writeout packets, you need to drop all packets not meant for
SK_MEMALLOC.

You also need to allow some writeout packets, because if you hit 'oom'
and need to write-out some pages to free up memory,...

I did the reservation because I wanted some guarantee we'd be able to
over-flow the caches mentioned. The alternative is working with the
variable ratio that the current reserve has.

The accounting makes the whole system more robust. I wanted to make the
state stable enough to survive a connection drop, or server reset for a
long while, and it does. During a swapping workload and heavy network
load, I can pull the network cable, or shut down the NFS server and
leave it down for over 30 minutes. When I bring it back up again, stuff
resumes.

> I call this the "Linus" approach because I remember reading somewhere
> (that google cannot find for me) where Linus said he didn't think a
> provably correct implementation was the way to go - just something
> that made it very likely that we won't run out of memory at an awkward
> time.
> 
> I guess my position is that any accounting that we do needs to have a
> clear theoretical model underneath it so we can reason about it.
> I cannot see the clear model in beneath the current code so I'm trying
> to come up with models that seem to capture the important elements of
> the code, and to explore them.

>From my POV there is a model, and I've tried to convey it, but clearly
I'm failing i>>?horribly. Let me try again:

Create a stable state where you can receive an unlimited amount of
network packets awaiting the one packet you need to move forward.

To do so we need to distinguish needed from unneeded packets; we do this
by means of SK_MEMALLOC. So we need to be able to receive packets up to
that point.

The unlimited amount of packets means unlimited time; which means that
our state must not consume memory, merely use memory. That is, the
amount of memory used must not grow unbounded over time.

So we must guarantee that all memory allocated will be promptly freed
again, and never allocate more than available.

Because this state is not the normal state, we need a trigger to enter
this state (and consequently a trigger to leave this state). We do that
by detecting a low memory situation just like you propose. We enter this
state once normal memory allocations fail and leave this state once they
start succeeding again.

We need the accounting to ensure we never allocate more than is
available, but more importantly because we need to ensure progress for
those packets we already have allocated.

A packet is received, it can be a fragment, it will be placed in the
fragment cache for packet re-assembly.

We need to ensure we can overflow this fragment cache in order that
something will come out at the other end. If under a fragment attack,
the fragment cache limit will prune the oldest fragments, freeing up
memory to receive new ones.

Eventually we'd be able to receive either a whole packet, or enough
fragments to assemble one.

Next comes routing the packet; we need to know where to process the
packet; local or non-local. This potentially involves filling the
route-cache.

If at this point there is no memory available because we forgot to limit
the amount of memory available for skb allocation we again are stuck.

The route-cache, like the fragment assembly, is already accounted and
will prune old (unused) entries once the total memory usage exceeds a
pre-determined amount of memory.

Eventually we'll end up at socket demux, matching packets to sockets
which allows us to either toss the packet or consume it. Dropping
packets is allowed because network is assumed lossy, and we have not yet
acknowledged the receive.

Does this make sense?


Then we have TX, which like I said above needs to operate under certain
limits as well. We need to be able to send out packets when under
pressure in order to relieve said pressure.

We need to ensure doing so will not exhaust our reserves.

Writing out a page typically takes a little memory, you fudge some
packets with protocol info, mtu size etc.. send them out, and wait for
an acknowledge from the other end, and drop the stuff and go on writing
other pages.

So sending out pages does not consume memory if we're able to receive
ACKs. Being able to receive packets what what all the previous was
about.

Now of course there is some RPC concurrency, TCP windows and other
funnies going on, but I assumed - and I don't think that's a wrong
assumption - that sending out pages will consume endless amounts of
memory.

Nor will it keep on sending pages, once there is a certain amount of
packets outstanding (nfs congestion logic), it will wait, at which point
it should have no memory in use at all.

Anyway I did get lost in the RPC code, and I know I didn't fully account
everything, but under some (hopefully realistic) assumptions I think the
model is sound.

Does this make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
