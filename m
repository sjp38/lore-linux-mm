From: Neil Brown <neilb@suse.de>
Date: Mon, 3 Mar 2008 09:18:47 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18379.10183.427082.282748@notabene.brown>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: message from Peter Zijlstra on Friday February 29
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
	<18371.43950.150842.429997@notabene.brown>
	<1204023042.6242.271.camel@lappy>
	<18372.64081.995262.986841@notabene.brown>
	<1204099113.6242.353.camel@lappy>
	<18375.24558.876276.255804@notabene.brown>
	<1204280500.6243.70.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Friday February 29, a.p.zijlstra@chello.nl wrote:
> 
> The tx path is a bit fuzzed. I assume it has an upper limit, take a stab
> at that upper limit and leave it at that.
> 
> It should be full of holes, and there is some work on writeout
> throttling to fill some of them - but I haven't seen any lockups in this
> area for a long long while.

I think this is very interesting and useful.

You seem to be saying that the write-throttling is enough to avoid any
starvation on the transmit path. i.e. the VM is limiting the amount
of dirty memory so that when we desperately need memory on the
writeout path we can always get it, without lots of careful
accounting.

So why doesn't this work on for the receive side?  What - exactly - is
the difference.

I think the difference is that on the receive side we have to hand
out memory before we know how it will be used (i.e. whether it is for
a SK_MEMALLOC socket or not) and so emergency memory could get stuck
in some non-emergency usage.

So suppose we forgot about all the allocation tracking (that doesn't
seem to be needed on the send side so maybe isn't on the receive side)
and just focus on not letting emergency memory get used for the wrong
thing.

So: Have some global flag that says "we are into the emergency pool"
which gets set the first time an allocation has to dip below the low
water mark, and cleared when an allocation succeeds without needing to
dip that low.

Then whenever we have memory that might have been allocated from below
the watermark (i.e. an incoming packet) and we find out that it isn't
required for write-out (i.e. it gets attached to a socket for which
SK_MEMALLOC is not set) we test the global flag and if it is set, we
drop the packet and free the memory.

To clarify: 
   no new accounting
   no new reservations
   just "drop non-writeout packets when we are low on memory"

Is there any chance that could work reliably?

I call this the "Linus" approach because I remember reading somewhere
(that google cannot find for me) where Linus said he didn't think a
provably correct implementation was the way to go - just something
that made it very likely that we won't run out of memory at an awkward
time.

I guess my position is that any accounting that we do needs to have a
clear theoretical model underneath it so we can reason about it.
I cannot see the clear model in beneath the current code so I'm trying
to come up with models that seem to capture the important elements of
the code, and to explore them.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
