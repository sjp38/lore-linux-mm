Date: Tue, 21 Aug 2007 15:43:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <1187734144.5463.35.camel@lappy>
Message-ID: <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>  <1187692586.6114.211.camel@twins>
  <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
 <1187730812.5463.12.camel@lappy>  <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
 <1187734144.5463.35.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Peter Zijlstra wrote:

> Also, all I want is for slab to honour gfp flags like page allocation
> does, nothing more, nothing less.
> 
> (well, actually slightly less, since I'm only really interrested in the
> ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER -> ALLOC_NO_WATERMARKS transition and
> not all higher ones)

I am still not sure what that brings you. There may be multiple 
PF_MEMALLOC going on at the same time. On a large system with N cpus
there may be more than N of these that can steal objects from one another. 

A NUMA system will be shot anyways if memory gets that problematic to 
handle since the OS cannot effectively place memory if all zones are 
overallocated so that only a few pages are left.


> I want slab to fail when a similar page alloc would fail, no magic.

Yes I know. I do not want allocations to fail but that reclaim occurs in 
order to avoid failing any allocation. We need provisions that 
make sure that we never get into such a bad memory situation that would
cause severe slowless and usually end up in a livelock anyways.

> > > Anonymous pages are a there to stay, and we cannot tell people how to
> > > use them. So we need some free or freeable pages in order to avoid the
> > > vm deadlock that arises from all memory dirty.
> > 
> > No one is trying to abolish Anonymous pages. Free memory is readily 
> > available on demand if one calls reclaim. Your scheme introduces complex 
> > negotiations over a few scraps of memory when large amounts of memory 
> > would still be readily available if one would do the right thing and call 
> > into reclaim.
> 
> This is the thing I contend, there need not be large amounts of memory
> around. In my test prog the hot code path fits into a single page, the
> rest can be anonymous.

Thats a bit extreme.... We need to make sure that there are larger amounts 
of memory around. Pages are used for all shorts of short term uses (like 
slab shrinking etc etc.). If memory is that low that a single page matters
then we are in very bad shape anyways.

> > Sounds like you would like to change the way we handle memory in general 
> > in the VM? Reclaim (and thus finding freeable pages) is basic to Linux 
> > memory management.
> 
> Not quite, currently we have free pages in the reserves, if you want to
> replace some (or all) of that by freeable pages then that is a change.

We have free pages primarily to optimize the allocation. Meaning we do not 
have to run reclaim on every call. We want to use all of memory. The 
reserves are there for the case that we cannot call into reclaim. The easy 
solution if that is problematic is to enhance the reclaim to work in the
critical situations that we care about.


> > Sorry I just got into this a short time ago and I may need a few cycles 
> > to get this all straight. An approach that uses memory instead of 
> > ignoring available memory is certainly better.
> 
> Sure if and when possible. There will always be need to fall back to the
> reserves.

Maybe. But we can certainly avoid that as much as possible which would 
also increase our ability to use all available memory instead of leaving 
some of it unused./

> A bit off-topic, re that reclaim from atomic context:
> Currently we try to hold spinlocks only for short periods of time so
> that reclaim can be preempted, if you run all of reclaim from a
> non-preemptible context you get very large preemption latencies and if
> done from int context it'd also generate large int latencies.

If you call into the page allocator from an interrupt context then you are 
already in bad shape since we may check pcps lists and then potentially 
have to traverse the zonelists and check all sorts of things. If we 
would implement atomic reclaim then the reserves may become a latency 
optimizations. At least we will not fail anymore if the reserves are out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
