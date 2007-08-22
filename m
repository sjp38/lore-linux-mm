Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>
	 <1187692586.6114.211.camel@twins>
	 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
	 <1187730812.5463.12.camel@lappy>
	 <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
	 <1187734144.5463.35.camel@lappy>
	 <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 22 Aug 2007 09:02:36 +0200
Message-Id: <1187766156.6114.280.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 15:43 -0700, Christoph Lameter wrote:
> On Wed, 22 Aug 2007, Peter Zijlstra wrote:
> 
> > Also, all I want is for slab to honour gfp flags like page allocation
> > does, nothing more, nothing less.
> > 
> > (well, actually slightly less, since I'm only really interrested in the
> > ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER -> ALLOC_NO_WATERMARKS transition and
> > not all higher ones)
> 
> I am still not sure what that brings you. There may be multiple 
> PF_MEMALLOC going on at the same time. On a large system with N cpus
> there may be more than N of these that can steal objects from one another. 

Yes, quite aware of that, and have ideas on how to properly fix that.
Once it is, the reserves can be shrunk too, perhaps you can work on
this?

> A NUMA system will be shot anyways if memory gets that problematic to 
> handle since the OS cannot effectively place memory if all zones are 
> overallocated so that only a few pages are left.

Also not a new problem.

> > I want slab to fail when a similar page alloc would fail, no magic.
> 
> Yes I know. I do not want allocations to fail but that reclaim occurs in 
> order to avoid failing any allocation. We need provisions that 
> make sure that we never get into such a bad memory situation that would
> cause severe slowless and usually end up in a livelock anyways.

Its unavoidable, at some point it just happens. Also using reclaim
doesn't seem like the ideal way to get out of live-locks since reclaim
itself can live-lock on these large boxen.

> > > > Anonymous pages are a there to stay, and we cannot tell people how to
> > > > use them. So we need some free or freeable pages in order to avoid the
> > > > vm deadlock that arises from all memory dirty.
> > > 
> > > No one is trying to abolish Anonymous pages. Free memory is readily 
> > > available on demand if one calls reclaim. Your scheme introduces complex 
> > > negotiations over a few scraps of memory when large amounts of memory 
> > > would still be readily available if one would do the right thing and call 
> > > into reclaim.
> > 
> > This is the thing I contend, there need not be large amounts of memory
> > around. In my test prog the hot code path fits into a single page, the
> > rest can be anonymous.
> 
> Thats a bit extreme.... We need to make sure that there are larger amounts 
> of memory around. Pages are used for all shorts of short term uses (like 
> slab shrinking etc etc.). If memory is that low that a single page matters
> then we are in very bad shape anyways.

Yes we are, but its a legitimate situation. Denying it won't get us very
far. Also placing a large bound on anonymous memory usage is not going
to be appreciated by the userspace people.

Slab cache will also be at a minimum is the pressure persists for a
while.

> > > Sounds like you would like to change the way we handle memory in general 
> > > in the VM? Reclaim (and thus finding freeable pages) is basic to Linux 
> > > memory management.
> > 
> > Not quite, currently we have free pages in the reserves, if you want to
> > replace some (or all) of that by freeable pages then that is a change.
> 
> We have free pages primarily to optimize the allocation. Meaning we do not 
> have to run reclaim on every call. We want to use all of memory. The 
> reserves are there for the case that we cannot call into reclaim. 

> The easy 
> solution if that is problematic is to enhance the reclaim to work in the
> critical situations that we care about.

As shown, there are cases where there just isn't any memory to reclaim.
Please accept this.

Also, by reclaiming memory and getting out of the tight spot you give
the rest of the system access to that memory, and it can be used for
other things than getting out of the tight spot.

You really want a separate allocation state that allows only reclaim to
access memory.

> > > Sorry I just got into this a short time ago and I may need a few cycles 
> > > to get this all straight. An approach that uses memory instead of 
> > > ignoring available memory is certainly better.
> > 
> > Sure if and when possible. There will always be need to fall back to the
> > reserves.
> 
> Maybe. But we can certainly avoid that as much as possible which would 
> also increase our ability to use all available memory instead of leaving 
> some of it unused./
> 
> > A bit off-topic, re that reclaim from atomic context:
> > Currently we try to hold spinlocks only for short periods of time so
> > that reclaim can be preempted, if you run all of reclaim from a
> > non-preemptible context you get very large preemption latencies and if
> > done from int context it'd also generate large int latencies.
> 
> If you call into the page allocator from an interrupt context then you are 
> already in bad shape since we may check pcps lists and then potentially 
> have to traverse the zonelists and check all sorts of things. 

Only an issue on these obscenely large NUMA boxen, normal machines don't
have large zone lists. No reason to hurt the small boxen in favour of
the large boxen.

> If we 
> would implement atomic reclaim then the reserves may become a latency 
> optimizations. At least we will not fail anymore if the reserves are out.

Yes it will, because there is no guarantee that there is anything
reclaimable.

Also, failing a memory allocation isn't bad, why are you so worried
about that? It happens all the time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
