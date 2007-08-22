Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0708221157180.13813@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>
	 <1187692586.6114.211.camel@twins>
	 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
	 <1187730812.5463.12.camel@lappy>
	 <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
	 <1187734144.5463.35.camel@lappy>
	 <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
	 <1187766156.6114.280.camel@twins>
	 <Pine.LNX.4.64.0708221157180.13813@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 22 Aug 2007 22:03:45 +0200
Message-Id: <1187813025.5463.85.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-22 at 12:04 -0700, Christoph Lameter wrote:
> On Wed, 22 Aug 2007, Peter Zijlstra wrote:
> 
> > Its unavoidable, at some point it just happens. Also using reclaim
> > doesn't seem like the ideal way to get out of live-locks since reclaim
> > itself can live-lock on these large boxen.
> 
> If reclaim can live lock then it needs to be fixed.

Riel is working on that.

> > As shown, there are cases where there just isn't any memory to reclaim.
> > Please accept this.
> 
> That is an extreme case that AFAIK we currently ignore and could be 
> avoided with some effort.

Its not extreme, not even rare, and its handled now. Its what
PF_MEMALLOC is for.

> The initial PF_MEMALLOC patchset seems to be 
> still enough to deal with your issues.

No it isnt. 

Take the anonyous workload, user-space will block once the page
allocator hits ALLOC_MIN. Network will be able to receive until
ALLOC_MIN|ALLOC_HIGH - if the completion doesn't arrive by then it will
start dropping all packets until there is memory again. But userspace is
wedged and hence will not consume the network traffic, hence we
deadlock.

Even if there is something to reclaim initially, if the pressure
persists that can eventually be exhausted.

> > Also, by reclaiming memory and getting out of the tight spot you give
> > the rest of the system access to that memory, and it can be used for
> > other things than getting out of the tight spot.
> 
> The rest of the system may have their own tights spots. Language the "the 
> tight spot" sets up all sort of alarms over here since you seem to be 
> thinking about a system doing a single task.

reclaim

>  The system may be handling 
> multiple critical tasks on various devices that have various memory needs. 
> So multiple critical spots can happen concurrently in multiple 
> application contexts.

yes, reclaim can be unbounded concurrent, and that is one of the
(theoretically) major problems we currently have.

> > You really want a separate allocation state that allows only reclaim to
> > access memory.
> 
> We have that with PF_MEMALLOC.

Exactly. But if you recognise the need for PF_MEMALLOC then what is this
argument about?

Networking can currently be seen as having two states:

 1 receive packets and consume memory
 2 drop all packets (when out of memory)

I need a 3rd state:

 3 receiving packets but not consuming memory

Now, I need this state when we're in PF_MEMALLOC territory, because I
need to be able to process an unspecified amount of network traffic in
order to receive the writeout completion.

In order to operate this 3rd network state, some memory is needed in
which packets can be received and when deemed not important freed and
reused.

It needs a bounded amount of memory in order to process an unbounded
amount of network traffic.

What exactly is not clear about this? If you accept the need for
PF_MEMALLOC you surely must also agree that at the point you're using it
running reclaim is useless.

> > Also, failing a memory allocation isn't bad, why are you so worried
> > about that? It happens all the time.
> 
> Its a performance impact and plainly does not make sense if there is 
> reclaimable memory availble. The common action of the vm is to reclaim if 
> there is a demand for memory. Now we suddenly abandon that approach?

I'm utterly confused by this, on one hand you recognise the need for
PF_MEMALLOC but on the other hand you're saying its not needed and
anybody needing memory (even reclaim itself) should use reclaim.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
