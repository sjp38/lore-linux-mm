Date: Tue, 21 Aug 2007 02:28:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070821002830.GB8414@wotan.suse.de>
References: <20070814142103.204771292@sgi.com> <20070815122253.GA15268@wotan.suse.de> <1187183526.6114.45.camel@twins> <20070816032921.GA32197@wotan.suse.de> <1187581894.6114.169.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187581894.6114.169.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 20, 2007 at 05:51:34AM +0200, Peter Zijlstra wrote:
> On Thu, 2007-08-16 at 05:29 +0200, Nick Piggin wrote:
> > Well perhaps it doesn't work for networked swap, because dirty accounting
> > doesn't work the same way with anonymous memory... but for _filesystems_,
> > right?
> > 
> > I mean, it intuitively seems like a good idea to terminate the recursive
> > allocation problem with an attempt to reclaim clean pages rather than
> > immediately let them have-at our memory reserve that is used for other
> > things as well. 
> 
> I'm concerned about the worst case scenarios, and those don't change.
> The proposed changes can be seen as an optimisation of various things,
> but they do not change the fundamental issues.

No, although it sounded like you didn't see any use in these patches.
Which be true if you're just looking at solving the theoretical deadlocks,
but I just think they might be worth looking at to practically solve some
of them and just give better reclaim behaviour in general (but in saying
that I'm not excluding your patches).


> > Well yeah I think you simply have to reserve a minimum amount of memory in
> > order to reclaim a page, and I don't see any other way to do it other than
> > what you describe to be _technically_ deadlock free.
> 
> Right, and I guess I have to go at it again, this time ensuring not to
> touch the fast-path nor sacrificing anything NUMA for simplicity in the
> reclaim path.
> 
> (I think its a good thing to be technically deadlock free - and if your
> work on the fault path rewrite and buffered write rework shows anything
> it is that you seem to agree with this)

I do of course. There is one thing to have a real lock deadlock
in some core path, and another to have this memory deadlock in a
known-to-be-dodgy configuration (Linus said last year that he didn't
want to go out of our way to support this, right?)... But if you can
solve it without impacting fastpaths etc. then I don't see any
objection to it.

 
> > But firstly, you don't _want_ to start dropping packets when you hit a tough
> > patch in reclaim -- even if you are strictly deadlock free. And secondly,
> > I think recursive reclaim could reduce the deadlocks in practice which is
> > not a bad thing as your patches aren't merged.
> 
> Non of the people who have actually used these patches seem to object to
> the dropping packets thing. Nor do I see that as a real problem,
> networks are assumed lossy - also if you really need that traffic for a
> RT app that also runs on the machine you need networked swap on (odd
> combination but hey, it should be possible) then I can make that work as
> well with a little bit more effort.

I don't mean for correctness, but for throughput. If you're doing a
lot of network operations right near the memory limit, then it could
be possible that these deadlock paths get triggered relatively often.
With Christoph's patches, I think it would tend to be less.


> > How are your deadlock patches going anyway? AFAIK they are mostly a network
> > issue and I haven't been keeping up with them for a while. 
> 
> They really do rely on some VM interaction too, network does not have
> enough information to break out of the deadlock on its own.

The thing I don't much like about your patches is the addition of more
of these global reserve type things in the allocators. They kind of
suck (not your code, just the concept of them in general -- ie. including
the PF_MEMALLOC reserve). I'd like to eventually reach a model where
reclaimable memory from a given subsystem is always backed by enough
resources to be able to reclaim it. What stopped you from going that
route with the network subsystem? (too much churn, or something
fundamental?)


> > Although you will quite likely have at least a couple of MB worth of
> > clean program text. The important part of recursive reclaim is that it
> > doesn't so easily allow reclaim to blow all memory reserves (including
> > interrupt context). Sure you still have theoretical deadlocks, but if
> > I understand correctly, they are going to be lessened. I would be
> > really interested to see if even just these recursive reclaim patches
> > eliminate the problem in practice.
> 
> were we much bothered by the buffered write deadlock? - why accept a
> known deadlock if a solid solution is quite attainable?

As a general statement, I agree of course ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
