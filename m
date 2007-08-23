Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0708221306080.15775@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>
	 <1187692586.6114.211.camel@twins>
	 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
	 <1187730812.5463.12.camel@lappy>
	 <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
	 <1187734144.5463.35.camel@lappy>
	 <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
	 <1187766156.6114.280.camel@twins>
	 <Pine.LNX.4.64.0708221157180.13813@schroedinger.engr.sgi.com>
	 <1187813025.5463.85.camel@lappy>
	 <Pine.LNX.4.64.0708221306080.15775@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 23 Aug 2007 09:39:00 +0200
Message-Id: <1187854740.6114.319.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-22 at 13:16 -0700, Christoph Lameter wrote:
> On Wed, 22 Aug 2007, Peter Zijlstra wrote:


> > > > As shown, there are cases where there just isn't any memory to reclaim.
                                                                       ^^^^^^^
> > > > Please accept this.

> > > That is an extreme case that AFAIK we currently ignore and could be 
> > > avoided with some effort.
> > 
> > Its not extreme, not even rare, and its handled now. Its what
> > PF_MEMALLOC is for.
> 
> No its not. If you have all pages allocated as anonymous pages and your 
> writeout requires more pages than available in the reserves then you are 
> screwed either way regardless if you have PF_MEMALLOC set or not.

Christoph, we were talking about memory to reclaim, no about exhausting
the reserves.

> > > The initial PF_MEMALLOC patchset seems to be 
> > > still enough to deal with your issues.
> > 
> > Take the anonyous workload, user-space will block once the page
> > allocator hits ALLOC_MIN. Network will be able to receive until
> > ALLOC_MIN|ALLOC_HIGH - if the completion doesn't arrive by then it will
> > start dropping all packets until there is memory again. But userspace is
> > wedged and hence will not consume the network traffic, hence we
> > deadlock.
> > 
> > Even if there is something to reclaim initially, if the pressure
> > persists that can eventually be exhausted.
> 
> Sure ultimately you will end up with pages that are all unreclaimable if 
> you reclaim all reclaimable memory.
> 
> > > multiple critical tasks on various devices that have various memory needs. 
> > > So multiple critical spots can happen concurrently in multiple 
> > > application contexts.
> > 
> > yes, reclaim can be unbounded concurrent, and that is one of the
> > (theoretically) major problems we currently have.
> 
> So your patchset is not fixing it?

No, and I never said it would. I've been meaning to do one that does
though. Just haven't come around to actually doing it :-/

> > > We have that with PF_MEMALLOC.
> > 
> > Exactly. But if you recognise the need for PF_MEMALLOC then what is this
> > argument about?
> 
> The PF_MEMALLOC patchset f.e. is about avoiding to go out of 
> memory when there is still memory available even if we are doing a 
> PF_MEMALLOC allocation and would OOM otherwise.

Right, but as long as there is a need for PF_MEMALLOC there is a need
for the patches I proposed.

> > Networking can currently be seen as having two states:
> > 
> >  1 receive packets and consume memory
> >  2 drop all packets (when out of memory)
> > 
> > I need a 3rd state:
> > 
> >  3 receiving packets but not consuming memory
> 
> So far a good idea. If you are not consuming memory then why are the 
> allocators involved?

Because I do need to receive some packets, its just that I'll free them
again. So it won't keep consuming memory. This needs a little pool of
memory in order to operate in a stable state.

Its: alloc, receive, inspect, free
total memory use: 0
memory delta: a little
 
(its just that you need to be able to receive a significant number of
packets, not 1, due to funny things like ip-defragmentation before you
can be sure to actually receive 1 whole tcp packet - but the idea is the
same)

> > Now, I need this state when we're in PF_MEMALLOC territory, because I
> > need to be able to process an unspecified amount of network traffic in
> > order to receive the writeout completion.
> > 
> > In order to operate this 3rd network state, some memory is needed in
> > which packets can be received and when deemed not important freed and
> > reused.
> > 
> > It needs a bounded amount of memory in order to process an unbounded
> > amount of network traffic.
> > 
> > What exactly is not clear about this? If you accept the need for
> > PF_MEMALLOC you surely must also agree that at the point you're using it
> > running reclaim is useless.
> 
> Yes looks like you would like to add something to the network layer to 
> filter important packets. As long as you stay within PF_MEMALLOC 
> boundaries you can allocate and throw packets away. If you want to have a 
> reserve that is secure and just for you then you need to take it away from 
> the reserves (which in turn will lead reclaim to restore them).

Ah, but also note that _using_ PF_MEMALLOC is the trigger to enter that
3rd network state. These two are tightly coupled. You only need this 3rd
state when under PF_MEMALLOC, otherwise we could just receive normally.

So, my thinking was that, if the current reserves are good enough to
keep the system 'deadlock' free, I can just enlarge the reserves by
whatever it is I need for that network state and we're all good, no?

Why separate these two? If the current reserve is large enough (and
theoretically it is not - but I'm meaning to fix that) it will not
consume the extra memory I added below.

Note how:
  [PATCH 09/10] mm: emergency pool
pushes up the current reserves in a fashion so as to maintain the
relative operating range of the page allocator (distance between
min,low,high and scaling of the wmarks under ALLOC_HIGH|ALLOC_HARDER).

> > > > Also, failing a memory allocation isn't bad, why are you so worried
> > > > about that? It happens all the time.
> > > 
> > > Its a performance impact and plainly does not make sense if there is 
> > > reclaimable memory availble. The common action of the vm is to reclaim if 
> > > there is a demand for memory. Now we suddenly abandon that approach?
> > 
> > I'm utterly confused by this, on one hand you recognise the need for
> > PF_MEMALLOC but on the other hand you're saying its not needed and
> > anybody needing memory (even reclaim itself) should use reclaim.
> 
> The VM reclaims memory on demand but in exceptional limited cases where we 
> cannot do so we use the reserves. I am sure you know this.

Its the abandon part I got confused about. I'm not at all abandoning
reclaim, its just that I must operate under PF_MEMALLOC, so reclaim is
pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
