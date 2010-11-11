Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 59FAC6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 19:23:47 -0500 (EST)
Date: Thu, 11 Nov 2010 11:23:39 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101111002339.GA3372@amd>
References: <20101109123246.GA11477@amd>
 <20101110051813.GS2715@dastard>
 <20101110063229.GA5700@amd>
 <20101110110549.GV2715@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110110549.GV2715@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 10:05:49PM +1100, Dave Chinner wrote:
> On Wed, Nov 10, 2010 at 05:32:29PM +1100, Nick Piggin wrote:
> > On Wed, Nov 10, 2010 at 04:18:13PM +1100, Dave Chinner wrote:
> > > On Tue, Nov 09, 2010 at 11:32:46PM +1100, Nick Piggin wrote:
> > > > Hi,
> > > > 
> > > > I'm doing some works that require per-zone shrinkers, I'd like to get
> > > > the vmscan part signed off and merged by interested mm people, please.
> > > > 
> > > 
> > > There are still plenty of unresolved issues with this general
> > > approach to scaling object caches that I'd like to see sorted out
> > > before we merge any significant shrinker API changes. Some things of
> > 
> > No changes, it just adds new APIs.
> > 
> > 
> > > the top of my head:
> > > 
> > > 	- how to solve impendence mismatches between VM scalability
> > > 	  techniques and subsystem scalabilty techniques that result
> > > 	  in shrinker cross-muliplication explosions. e.g. XFS
> > > 	  tracks reclaimable inodes in per-allocation group trees,
> > > 	  so we'd get AG x per-zone LRU trees using this shrinker
> > > 	  method.  Think of the overhead on a 1000AG filesystem on a
> > > 	  1000 node machine with 3-5 zones per node....
> > 
> > That's an interesting question, but no reason to hold anything up.
> > It's up to the subsystem to handle it, or if they can't handle it
> > sanely, you can elect to get no different behaviour than today.
> 
> See, this is what I think is the problem - you answer any concerns
> by saying that the problem is entirely the responsibility of the
> subsystem to handle. You've decided how you want shrinkers to work,
> and everything else is SEP (somebody else's problem).

Um, wrong. I provide an API to drive shrinkers, giving sufficient
information (and nothing more). You are the one deciding that it is
the problem of the API to somehow fix up all the implementations.

If you can actually suggest how such a magical API would look like,
please do. Otherwise, please try to get a better understanding of
my API and understand it does nothing more than provide required
information for proper zone based scanning.


> > I would say that per-zone is important for the above case, because it
> > shrinks properly, based on memory pressure and pressure settings (eg.
> > zone reclaim), and also obviously so that the reclaim threads are
> > scanning node-local-memory so it doesn't have to pull objects from
> > all over the interconnect.
> > 
> > With 1000 nodes and 1000AG filesystem, probably NxM is overkill, but
> > there is no reason you couldn't have one LRU per X AGs.
> 
> And when it's only 1 node or 50 nodes or 50 AGs or 5000 AGs? I don't
> like encoding _guesses_ at what might be a good configuration for an
> arbitrary NxM configuration because they are rarely right. That's
> exactly what you are suggesting here - that I solve this problem by
> making guesses at how it might scale and coming up with some
> arbitrary mapping scheme to handle it.

Still, it's off topic for shrinker API discussion, I'd be happy to
help with ideas or questions about your particular implementation.

Note you can a: ignore the new information the API gives you, or b:
understand that your current case of 1000 LRUs spread globally over
1000 nodes sucks much much worse than even a poor per-zone distribution,
and make some actual use of the new information.


> > All this is obviously implementation details -- pagecache reclaim does
> > not want to know about this, so it doesn't affect the API.
> 
> i.e. it's another SEP solution.

Uh, yes in fact it is the problem of the shrinker implementation to
be a good implementation.


> > > 	- changes from global LRU behaviour to something that is not
> > > 	  at all global - effect on workloads that depend on large
> > > 	  scale caches that span multiple nodes is largely unknown.
> > > 	  It will change IO patterns and affect system balance and
> > > 	  performance of the system. How do we
> > > 	  test/categorise/understand these problems and address such
> > > 	  balance issues?
> > 
> > You've brought this up before several times and I've answered it.
> > 
> > The default configuration basically doesn't change much. Caches are
> > allowed to fill up all zones and nodes, exactly the same as today.
> > 
> > On the reclaim side, when you have a global shortage, it will evenly
> > shrink objects from all zones, so it still approximates LRU behaviour
> > because number of objects far exceeds number of zones. This is exactly
> > how per-zone pagecache scanning works too.
> 
> The whole point of the zone-based reclaim is that shrinkers run
> when there are _local_ shortages on the _local_ LRUs and this will
> happen much more often than global shortages, especially on large
> machines. It will result in a change of behaviour, no question about
> it.

But if you have a global workload, then you tend to get relatively
even pressure and it tends to approximate global LRU (especially if
you do memory spreading of your slabs).

Yes there will be some differences, but it's not some giant scary
change, it just can be tested with some benchmarks and people can
complain if something hurts. Bringing reclaim closer to how pagecache
is reclaimed I think should make things more understandable though.


> However, this is not reason for not moving to this model - what I'm
> asking is what the plan for categorising problems that arise as a
> result of such a change? How do we go about translating random
> reports like "I do this and it goes X% slower on 2.6.xx" to "that's
> a result of the new LRU reclaim model, and you should do <this> to
> try to resolve it". How do we triage such reports? What are our
> options to resolve such problems? Are there any knobs we should add
> at the beginning to give users ways of changing the behaviour to be
> more like the curent code? We've got lots of different knobs to
> control page cache reclaim behaviour - won't some of them be
> relevant to per-zone slab cache reclaim?

Really? Same as any other heuristic or performance change. We merge
thousands of them every release cycle, and at least a couple of major
ones.


> > > 	- your use of this shrinker architecture for VFS
> > > 	  inode/dentry cache scalability requires adding lists and
> > > 	  locks to the MM struct zone for each object cache type
> > > 	  (inode, dentry, etc). As such, it is not a generic
> > > 	  solution because it cannot be used for per-instance caches
> > > 	  like the per-mount inode caches XFS uses.
> > 
> > Of course it doesn't. You can use kmalloc.
> 
> Right - another SEP solution.

What??? Stop saying this. In the above paragraph you were going crazy
about your wrong and obviously unfounded solution that other subsystems
can't use it. I tell you that they can, ie. with kmalloc.

I could spell it out if it is not obvious. You would allocate an array
of LRU structures to fit all zones in the system. And then you would
index into that array with zone_to_nid and zone_idx. OK?

It is not "SEP solution". If a shrinker implementation wants to use per
zone LRUs, then it is that shrinker implementation's problem to allocate
space for them. OK so far?

And if a shrinker implementation doesn't want to do that, and instead
wants a global LRU, then it's the implementation's problem to allocate
space for that. And if it wants per AG LRUs, then it's the
implementation's problem to allocate space for that. See any patterns
emerging?

> The reason people are using shrinkers is that it is simple to
> implement a basic one. But implementing a scalable shrinker right
> now is fucking hard - look at all the problems we've had with XFS
> mostly because of the current API and the unbound parallelism of
> direct reclaim.
> 
> This new API is a whole new adventure that not many people are going
> to have machines capable of executing behavioural testing or
> stressing. If everyone is forced to implement their own "scalable
> shrinker" we'll end up with a rat's nest of different
> implementations with similar but subtly different sets of bugs...

No, they are not forced to do anything. Stop with this strawman already.
Did you read the patch? 0 change to any existing implementation.


> > > 	  i.e. nothing can actually use this infrastructure change
> > > 	  without tying itself directly into the VM implementation,
> > > 	  and even then not every existing shrinker can use this
> > > 	  method of scaling. i.e. some level of abstraction from the
> > > 	  VM implementation is needed in the shrinker API.
> > 
> > "zones" is the abstraction. The thing which all allocation and
> > management of memory is based on, everywhere you do any allocations
> > in the kernel. A *shrinker* implementation, a thing which is called
> > in response to memory shortage in a given zone, has to know about
> > zones. End of story. "Tied to the memory management implementation"
> > is true to the extent that it is part of the memory management
> > implementation.
> >  
> > 
> > > 	- it has been pointed out that slab caches are generally
> > > 	  allocated out of a single zone per node, so per-zone
> > > 	  shrinker granularity seems unnecessary.
> > 
> > No they are not, that's just total FUD. Where was that "pointed out"?
> 
> Christoph Hellwig mentioned it, I think Christoph Lameter asked
> exactly this question, I've mentioned it, and you even mentioned at
> one point that zones were effectively a per-node construct....

Christoph Hellwig mentioned lots of things that were wrong.

Lameter had a reasonable discussion and I showed how per-node shrinker
can cause imbalance, and how subsystems that only care about nodes can
use the zone shrinker to get exactly the same information (because it
provides a superset). And that was the end of that. If you had followed
the discussion you wouldn't keep bringing up this again and again.


> > Slabs are generally allocated from every zone except for highmem and
> > movable, and moreover there is nothing to prevent a shrinker
> > implementation from needing to shrink highmem and movable pages as
> > well.
> >
> > > 	- doesn't solve the unbound direct reclaim shrinker
> > > 	  parallelism that is already causing excessive LRU lock
> > > 	  contention on 8p single node systems. While
> > > 	  per-LRU/per-node solves the larger scalability issue, it
> > > 	  doesn't address scalability within the node. This is soon
> > > 	  going to be 24p per node and that's more than enough to
> > > 	  cause severe problems with a single lock and list...
> > 
> > It doesn't aim to solve that. It doesn't prevent that from being
> > solved either (and improving parallelism in a subsystem generally,
> > you know, helps with lock contention due to lots of threads in there,
> > right?).
> 
> Sure, but you keep missing the point that it's a problem that is
> more important to solve for the typical 2S or 4S server than scaling

I am not missing that point. I am solving a different problem. Other
people are looking at the reclaim parallelism problem. Why don't you
go and bother them?

> to 1000 nodes is.  An architecture that allows unbounded parallelism
> is, IMO, fundamentally broken from a scalability point of view.
> Such behaviour indicates that the effects of such levels of
> parallelism weren't really considered with the subsystem was
> designed.
> 
> I make this point because of the observation I made that shrinkers
> are by far the most efficient when only a single thread is running
> reclaim on a particular LRU.  Reclaim parallelism on a single LRU
> only made reclaim go slower and consume more CPU, and direct reclaim
> is definitely causing such parallelism and slowdowns (I can point
> you to the XFS mailing list posting again if you want).

And having more LRUs, more locks, fewer CPUs contending each lock
and LRU, and node locality (yes it is important even on 2S and 4S
systems) is going to do nothing but help that.


> I've previously stated that reducing/controlling the level of
> parallelism can be just as effective at providing serious
> scalability improvements as fine grained locking. So you don't
> simply scoff and mock me for suggesting it like you did last time,

I didn't mock you. On the contrary I agreed that there are 2 problems
here, and that lots of threads in reclaim is one of them. I know this
myself first hand because the pagecache LRUs have the same problems.
And I pointed out that people were looking at the other problem, and
that it was mostly indpendent of per-zone locking in implementation,
and in functionality the per-zone locking would help the unbounded
paralellism anyway.

That you thought I was mocking you by providing an answer like that,
I don't know. Maybe I got frustrated sometime after the 5th time you
brought up exactly the same thing.


> >From that experience, what I suggest is that we provide the same
> sort of _controlled parallelism_ for the generic shrinker
> infrastructure. We abstract out the lists and locks completely, and
> simply provide a "can you free this object" callback to the
> subsystem. I suggested we move shrinker callbacks out of direct
> reclaim to the (per-node) kswapd. having thought about it a bit
> more, a simpler (and probably better) alternative would be to allow
> only a single direct reclaimer to act on a specific LRU at a time,
> as this would allow different LRUs to be reclaimed in parallel.
> Either way, this bounds the amount of parallelism the shrinker will
> place on the lists and locks, thereby solving both the internal node
> scalability issues and the scaling to many nodes problems.

No to abstracting lists and locks completely, and adding callbacks.
That just way over complicates things and doesn't allow shrinkers
flexibility. There is nothing wrong with allowing shrinkers to do
whatever they need to shrink memory.

The problem is that reclaim allows too many threads into the shrinkers.
And it is not a shrinker only problem, it also affects the pagecache
LRUs. So the right way to do it is solve it the same way for both
shrinkers and pagecache, and put some limiting in reclaim/direct reclaim
paths. When you do that, shrinkers will be limited as well. People have
looked at this at various points (I don't know what progress is on it
now though).


> Such an abstraction also keeps all the details of how the objects
> are stored in LRUs and selected for reclaim completely hidden from
> the subsystems.

Well then that would be wrong because the locking and the access
patterns are fundamental properties of the subsystem, not the MM
reclaim subsystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
